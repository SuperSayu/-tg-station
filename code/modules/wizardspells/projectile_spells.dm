/*
	Projectile spells (Rework)

	There are two basic modes for projectile spells, and they were at first subtypes.
	Either you can shoot directly at a target, or you can scatter a bunch of (usually homing) shots.

	This tree can function one of these ways:
	* Fire at selected atom, no homing
	* Fire at selected mob, homing
	* Spreadfire randomly, no homing
	* Spreadfire at random mobs, homing

	The overhead for these spells is a little high, forgive the mess...
*/

/obj/effect/knowspell/projectile
	castingmode = CAST_SPELL|CAST_SELF|CAST_RANGED|CAST_MELEE
	var/projectile_type = /obj/item/projectile/reagent/bananacreme
	var/projectile_count = 1
	var/projectile_spread = 0 // 0: none; 1: repeat-fire; 2: spread-fire;

	var/allow_spreadcast = 1 // If 0, create a spellthrower on normal cast

	var/homing = 0	// If 1, bullets are spawned to chase after mobs
	var/target_lying = 1
	var/target_dead = 0
	var/target_animals = 0

	var/directcast_charge = 0
	var/directcast_projectile_count = 1

	var/tmp/was_directcast

/obj/effect/knowspell/projectile/prepare(mob/user as mob)
	if(!allow_spreadcast)
		if(!cast_check(user))
			return
		create_spellthrower(user)
		return
	was_directcast = 0
	activate(user,null)

/obj/effect/knowspell/projectile/afterattack(var/mob/target, var/mob/caster)
	was_directcast = 1
	activate(caster,target)

/obj/effect/knowspell/projectile/attack(var/mob/target, var/mob/caster)
	was_directcast = 1
	activate(caster,target) // be sure not to suicide yourself here

/obj/effect/knowspell/projectile/charge_required(caster,target)
	if(was_directcast)
		return directcast_charge
	return chargemax

// Used to filter homing shots
/obj/effect/knowspell/projectile/proc/valid(var/mob/caster, var/mob/living/M)
	if(M == caster) return 0
	if(!istype(M)) return 0
	if(!target_lying && M.lying) return 0
	if(!target_dead && M.stat&DEAD) return 0
	if(!target_animals && !istype(M,/mob/living/carbon/human)) return 0
	return 1

// Used when homing and scattershot are combined
/obj/effect/knowspell/projectile/filter_target(var/mob/caster as mob, var/mob/target)
	if(was_directcast || !homing)
		return null

	var/list/possible_targets = list()
	for(var/mob/living/LM in view(caster, 7))
		if(valid(caster,LM))
			possible_targets += LM
	return possible_targets

/obj/effect/knowspell/projectile/proc/fire(var/obj/item/projectile/magic/P, var/atom/target, var/turf/start, var/turf/end, var/mob/user, var/sidestep = 0, var/sidestep_dir = 0)
//	P.shot_from = src
	if(start == end)			//Fire the projectile
		target.bullet_act(P)
		qdel(P)
		return
	P.original = target
	P.starting = start
	P.firer = user
	if(homing) sidestep=0
	if(istype(P))
		P.sidestep = sidestep
		P.sidestep_dir = sidestep_dir
		P.caster = user
	if(!target || !end) // scatter randomly, this is magic
		if(!allow_spreadcast)
			qdel(P)
			return
		P.yo = rand(-5,5)
		P.xo = rand(-5,5)
		end = locate(start.x + P.xo, start.y + P.yo, start.z)
		target = end
		for(var/atom/movable/AM in end)
			if(AM.anchored) continue
			if(prob(25))
				target = AM
				break
		P.original = target
		P.current = start
	else
		while(sidestep)
			end = get_step(end,sidestep_dir)
			sidestep--
		P.yo = end.y - start.y
		P.xo = end.x - start.x
		P.current = target
	user.next_move = max(world.time + 4, user.next_move + 2)

	spawn()
		if(!P) return
		if(homing && !isturf(target))
			P.process_homing()
		else
			P.process()

	return

/obj/effect/knowspell/projectile/cast(mob/caster, atom/target as obj|mob|turf, var/list/possible_targets)
	if(was_directcast)
		var/turf/start = get_turf(caster)
		var/turf/end
		if(target)
			end = get_turf(target)
		else
			end = get_edge_target_turf(caster, caster.dir)
			target = end

		if(projectile_spread < 2 || projectile_count == 1)
			var/counter = directcast_projectile_count
			spawn()
				while(counter--)
					fire(new projectile_type(start),target,start,end, caster)
					if(projectile_spread == 1) // string out the shots over time
						sleep(5)
						start = get_turf(caster)
		else
			var/dir_out = get_dir(start,end)
			var/dir_ccw = turn(dir_out,90)
			var/dir_cw = turn(dir_out,-90)
			var/counter = directcast_projectile_count
			var/outsteps = 0
			spawn()
				fire(new projectile_type(start),target,start,end, caster)
				counter--
				while(counter--)
					outsteps++
					fire(new projectile_type(start),target,start,end, caster,outsteps,dir_cw)
					if(counter--)
						fire(new projectile_type(start),target,start,end, caster,outsteps,dir_ccw)
	else
		var/turf/start = get_turf(caster)

		if(!homing || !istype(possible_targets,/list)) // disable homing and just go fucking nuts
			var/counter = projectile_count
			while(counter--)
				fire(new projectile_type(start),null,start,null,caster)
			return

		possible_targets += null // some chance of stray shots
		var/list/backup = possible_targets.Copy()

		var/counter = projectile_count
		while(counter--)
			target = pick_n_take(possible_targets)
			var/turf/end = get_turf(target)
			var/out_dir = turn(get_dir(start,target), pick(-90,-45,0,45,90))
			var/turf/s = get_step(start,out_dir)
			fire(new projectile_type(s), target, s, end, caster)

			if(!possible_targets.len && counter && backup.len) // Ensure it doesn't double up unless there are not enough targets
				possible_targets = backup.Copy()

/obj/effect/knowspell/projectile/fireball
	name = "fireball"
	desc = "Throws an exploding firebolt.  Some danger of friendly fire."
	require_clothing = 1
	castingmode = CAST_SPELL|CAST_RANGED

	wand_state = "firewand"

	directcast_projectile_count = 1
	projectile_spread = 0
	projectile_type = /obj/item/projectile/magic/fireball

	chargemax = 60
	directcast_charge = 60
	incantation = "FLAMMUS NAVAL"
	incant_volume = 2

/obj/effect/knowspell/projectile/knives
	name = "spray of knives"
	desc = "Throws a wall of metal towards the target."
	require_clothing = 0


	target_lying = 1
	projectile_count = 7
	directcast_projectile_count = 3
	projectile_spread = 2
	projectile_type = /obj/item/projectile/magic/knives

	chargemax = 80
	directcast_charge = 40
	incantation = "SLIZEN DIZE"
	incant_volume = 2

/obj/effect/knowspell/projectile/change
	name = "bolt of change"
	desc = "Transforms the target.  Too powerful to cast without a magic item."
	castingmode = CAST_RANGED|CAST_MELEE

	wand_state = "polywand"

	homing = 1
	target_animals = 1
	target_dead = 1
	target_lying = 1
	allow_spreadcast = 0
	projectile_count = 1
	directcast_projectile_count = 1
	projectile_spread = 0
	projectile_type = /obj/item/projectile/magic/change

	chargemax = 200
	directcast_charge = 200
	incantation = "TRUMAN STAR"
	incant_volume = 2

/obj/effect/knowspell/projectile/animate
	name = "animation ray"
	desc = "Brings objects to life."
	castingmode = CAST_SPELL|CAST_RANGED|CAST_MELEE

	wand_state = "polywand"
	staff_state = "animation"

	homing = 0
	allow_spreadcast = 0
	projectile_count = 1
	directcast_projectile_count = 1
	projectile_spread = 0
	projectile_type = /obj/item/projectile/magic/animate

	chargemax = 500
	directcast_charge = 500
	incantation = "FAN TA ZIA"
	incant_volume = 2

/obj/effect/knowspell/projectile/frost
	name = "frost bolt"
	desc = "Lower's your opponent's temperature.  May cause cold burns."

	homing = 1
	projectile_count = 6
	directcast_projectile_count = 1
	projectile_spread = 1
	projectile_type = /obj/item/projectile/magic/cold

	chargemax = 150
	directcast_charge = 230
	incantation = "FROS TIS"
	incant_volume = 1

/obj/effect/knowspell/projectile/sweep
	name = "sweeping bolt"
	desc = "Cleans up scum, living or otherwise."

	staff_state = "generic"

	homing = 0
	directcast_projectile_count = 3
	projectile_count = 9
	projectile_spread = 2
	projectile_type = /obj/item/projectile/magic/sweep

	chargemax = 100
	directcast_charge = 45
	incantation = "CLIN SWIP"
	incant_volume = 2


/obj/effect/knowspell/projectile/magicmissile
	name = "magic missile"
	desc = "Shoots stunning projectiles after your nearby foes."

	require_clothing = 0

	homing = 1
	projectile_count = 5
	directcast_projectile_count = 2
	projectile_spread = 1
	projectile_type = /obj/item/projectile/magic/magicmissile

	chargemax = 150
	directcast_charge = 50
	incantation = "FORTI GY AMA"
	incant_volume = 2

/obj/effect/knowspell/projectile/forcearrow
	name = "force arrow"
	desc = "Shoots bolts of magical force after your nearby foes."
	require_clothing = 1
	homing = 1

	projectile_count = 5
	projectile_spread = 1
	projectile_type = /obj/item/projectile/magic/forcearrow

	chargemax = 150
	directcast_charge = 50
	directcast_projectile_count = 2
	incantation = "LINKTU DAPAS"
	incant_volume = 1
/obj/effect/knowspell/projectile/grease
	name = "grease arrow"
	desc = "Coats the floor with a nasty substance."
	require_clothing = 1
	homing = 0
	projectile_count = 4
	projectile_spread = 2
	directcast_projectile_count = 1
	projectile_type = /obj/item/projectile/magic/grease

	chargemax = 250
	directcast_charge = 150
	incantation = "SLI PUNSLID"
	incant_volume = 1