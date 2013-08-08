/obj/effect/knowspell/projectile
	var/projectile_type = /obj/item/projectile/reagent/bananacreme
	var/projectile_count = 1
	var/projectile_spread = 0 // 0: none; 1: repeat-fire; 2: spread-fire;

/obj/effect/knowspell/projectile/proc/fire(var/obj/item/projectile/P, var/atom/target, var/turf/start, var/turf/end, var/mob/user)
	P.shot_from = src
	if(start == end)			//Fire the projectile
		user.bullet_act(P)
		del(P)
		return
	P.original = target
	P.starting = start
	if(!target || !end) // scatter randomly, this is magic
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
		P.yo = end.y - start.y
		P.xo = end.x - start.x
		P.current = target
	user.next_move = max(world.time + 4, user.next_move + 2)

	spawn()
		P && P.process()

	return

/obj/effect/knowspell/projectile/cast(mob/caster, atom/target as obj|mob|turf)
	var/turf/start = get_turf(caster)
	var/turf/end
	if(target)
		end = get_turf(target)
	else
		end = get_edge_target_turf(caster, caster.dir)
		target = end

	if(projectile_spread < 2 || projectile_count == 1)
		var/counter = projectile_count
		spawn()
			while(counter--)
				fire(new projectile_type(start),target,start,end, caster)
				if(projectile_spread == 1) // string out the shots over time
					sleep(2)
	else
		var/dir_out = get_dir(start,end)
		var/dir_ccw = turn(dir_out,90)
		var/dir_cw = turn(dir_out,-90)
		var/counter = projectile_count
		spawn()
			fire(new projectile_type(start),target,start,end, caster)
			counter--
			var/turf/cw = end
			var/turf/ccw = end
			while(counter--)
				cw = get_step(cw, dir_cw)
				fire(new projectile_type(start),target,start,cw, caster)
				if(counter--)
					ccw = get_step(ccw, dir_ccw)
					fire(new projectile_type(start),target,start,ccw, caster)


/obj/effect/knowspell/projectile/throw/prepare(mob/user as mob)
	if(!cast_check(user))
		return
	create_spellthrower(user)

/obj/effect/knowspell/projectile/throw/afterattack(mob/living/target, mob/living/caster)
	activate(caster,target)

/obj/effect/knowspell/projectile/throw/fireball
	name = "fireball"
	desc = "Throws an exploding firebolt.  Some danger of friendly fire."
	require_clothing = 1

	projectile_count = 1
	projectile_spread = 0
	projectile_type = /obj/item/projectile/magic/fireball

	chargemax = 60
	incantation = "FLAMMUS NAVAL"
	incant_volume = 2

/obj/effect/knowspell/projectile/throw/knives
	name = "spray of knives"
	desc = "Throws a wall of metal towards the target."
	require_clothing = 0

	projectile_count = 7
	projectile_spread = 2
	projectile_type = /obj/item/projectile/magic/knives

	chargemax = 80
	incantation = "SLIZEN DIZE"
	incant_volume = 2

// /obj/effect/knowspell/projectile/throw/thunder
/obj/effect/knowspell/projectile/scatter
	var/target_lying = 1
	var/target_dead = 0
	var/target_animals = 0

/obj/effect/knowspell/projectile/scatter/cast(var/mob/caster as mob)
	var/turf/start = get_turf(caster)

	var/list/possible_targets = list()
	for(var/mob/living/LM in view(caster, 7))
		if(LM == caster) continue
		if(!target_dead && LM.stat & DEAD) continue
		if(!target_lying && LM.lying) continue
		if(!target_animals && !istype(LM,/mob/living/carbon)) continue
		possible_targets += LM

	var/counter = projectile_count
	var/list/backup = possible_targets.Copy()
	while(counter--)
		var/mob/target = pick_n_take(possible_targets)
		var/turf/end = get_turf(target)
		var/turf/near = get_step_rand(get_step_towards(start,target))
		if(prob(25)) near = get_step_rand(near)
		fire(new projectile_type(near), target, near, end, caster)

		if(!possible_targets.len && counter && backup.len) // Ensure it doesn't double up unless there are not enough targets
			possible_targets = backup.Copy()


/obj/effect/knowspell/projectile/scatter/magicmissile
	name = "magic missile"
	desc = "Sends several stunning projectiles after your nearby foes."

	require_clothing = 0

	projectile_count = 5
	projectile_spread = 0 // doesn't matter
	projectile_type = /obj/item/projectile/magic/homing/magicmissile

	chargemax = 150
	incantation = "FORTI GY AMA"
	incant_volume = 2

/obj/effect/knowspell/projectile/scatter/forcearrow
	name = "force arrow"
	desc = "Sends several bolts of magical force after your nearby foes."
	require_clothing = 1
	target_animals = 1

	projectile_count = 5
	projectile_spread = 0 // doesn't matter
	projectile_type = /obj/item/projectile/magic/homing/forcearrow

	chargemax = 150
	incantation = "LINKTU DAPAS"
	incant_volume = 1

/obj/effect/knowspell/projectile/scatter/knives
	name = "bloodthirsty knives"
	desc = "Sends several sharp bits of magical metal after your nearby foes."
	require_clothing = 1

	projectile_count = 5
	projectile_spread = 0 // doesn't matter
	projectile_type = /obj/item/projectile/magic/homing/knives

	chargemax = 150
	incantation = "CUUK SPE ZIAL"
	incant_volume = 1
