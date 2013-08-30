/obj/effect/spelleffect
	unacidable = 1
//
// Summon gateway: Used to delay or cancel a powerful spell.
//
/obj/effect/spelleffect/summon
	name = "astral gateway"
	desc = "Something's coming through!"
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"

	New(var/L,var/mob/caster, var/complete_time, var/obj/effect/knowspell/spell)
		..(L)
		SetLuminosity(1)
		spawn(0)
			if(do_after(caster, complete_time) && src && loc && spell)
				spell.cast(caster,loc)
				loc = null
			else
				if(src && loc)
					visible_message("[src] disappears with a \i [magic_soundfx()].")
					var/datum/effect/effect/system/harmless_smoke_spread/smoke = new
					smoke.set_up(1, 0, loc)
					smoke.start()
					loc = null

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/nullrod))
			loc = null

/obj/effect/spelleffect/light
	name = "dancing lights"
	desc = "So bright, so ethereal."
	density = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="red_1"
	var/mob/target = null

	New(l,duration = 450)
		..()
		SetLuminosity(4)
		processing_objects.Add(src)
		spawn(duration)
			del src
	process()

/obj/effect/spelleffect/forcewall
	name = "wall of force"
	desc = "A space wizard's magic wall."
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield"
	anchored = 1.0
	opacity = 0
	density = 1
	unacidable = 1
	var/mob/caster = null

	New(l,c,d = 0)
		..()
		spawn(0)
			air_update_turf(1)
		caster = c
		if(!istype(caster)) caster = null
		if(d)
			spawn(d)
				del src

	Del()
		density = 0
		air_update_turf(1)
		loc = null
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/nullrod))
			visible_message("\red [src] shatters!")
			del src
			return
		if(W.force)
			reliability -= W.force
			if(!prob(reliability))
				visible_message("\red [src] shatters!")
				del src
				return
		..()



	// used to make the forcewall impermable to air, but permeable to the caster
	CanPass(atom/movable/mover)
		if(mover == caster)
			return 1
		return !density
	CanAtmosPass()
		return 0

/obj/effect/spelleffect/jaunt
	name = "water vapor"
	icon = 'icons/mob/mob.dmi'
	icon_state = "empty"
	var/dissipate_icon_state = "liquify"
	var/reform_icon_state = "reappear"
	anchored = 1
	density = 1
	var/mob/caster = null
	var/duration = 50

	proc/start(var/mob/user)
		loc = get_turf(user)

		caster = user
		dir = user.dir
		anchored = 1
		density = 1

		caster.loc = src
		flick(dissipate_icon_state, src)
		sleep(12)
		density = 0
		anchored = 0

		spawn(duration)
			if(src)
				end()

	proc/end()
		anchored = 1
		density = 1
		flick(reform_icon_state,src)
		sleep(9)
		caster.dir = dir
		for(var/atom/movable/AM in src)
			AM.loc = loc
			if(ismob(AM) && AM:client)
				AM:client.eye = AM
		anchored = 0
		density = 0
		sleep(5) // without which the user would experience a momentary black screen as the eye hasn't transitioned I guess
		del src

	relaymove(mob/user, direction)
		if(user != caster || anchored)// || (world.time < last_move+1))
			return
		var/turf/T = get_step(src,direction)
		if(T.flags&NOJAUNT)
			caster << "[T] is warded!  You cannot enter."
			return
		loc = T
		//last_move = world.time


/obj/item/projectile/magic
	icon = 'icons/obj/wizard.dmi'
	var/mob/caster
	var/duration = 150
	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1

		if(istype(mover, /obj/item/projectile))
			var/obj/item/projectile/other = mover
			if(istype(mover,/obj/item/projectile/magic) && other.shot_from == shot_from)
				return 1
			return prob(90)
		else
			return 1
	New()
		..()
		if(usr)
			caster = usr
		spawn(duration)
			del src // why are these not dying

/obj/item/projectile/magic/fireball
	name = "fireball"
	icon_state = "fireball"
	damage_type = BURN
	nodamage = 1

	on_hit(var/atom/target, var/blocked = 0)
		if(target != caster)
			explosion(target, -1,0,2)

/obj/item/projectile/magic/knives
	name = "magic blade"
	icon_state = "render"
	damage_type = BRUTE
	damage = 12
	weaken = 1

/obj/item/projectile/magic/homing
	var/homing_speed = 3
	duration = 50

	process()
		if(kill_count < 1)
			delete()
			return
		kill_count--
		spawn while(src && src.loc && current)
			if((!( current ) || loc == current))
				current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
			step_towards(src, current)
			sleep(homing_speed)
			if(!bumped && !isturf(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						Bump(original)
						sleep(1)
		return

/obj/item/projectile/magic/homing/magicmissile
	name = "magic missile"
	desc = "BZZZZAP"
	icon_state = "magicm"
	damage_type = BURN
	damage = 10
	weaken = 5
	process()
		..()
		src && new /obj/effect/spelleffect/bullettrail/magicmissile(loc)

	on_hit(var/atom/movable/target, var/blocked = 0)
		if(target != caster)
			..(target,blocked)

/obj/effect/spelleffect/bullettrail/magicmissile
	name = "magic missile"
	desc = "BZZZZAP"
	icon_state = "magicmd"
	New()
		..()
		spawn(20)
			del src

/obj/item/projectile/magic/homing/knives
	name = "magic blade"

	icon_state = "render"
	damage_type = BRUTE
	damage = 15
	weaken = 1
	on_hit(var/atom/movable/target, var/blocked = 0)
		if(target != caster)
			..(target,blocked)

/obj/item/projectile/magic/homing/forcearrow
	name = "force arrow"
	desc = "Not the other arrow."
	icon_state = "arrow"
	damage_type = BRUTE
	damage = 5
	throwforce = 3 // by coincidence this is the same name as the variable used for how heavily you throw things
	// but in this case I mean how heavily do you throw the target

	on_hit(var/atom/movable/target, var/blocked = 0)
		if(!istype(target) || target.anchored) return
		if(target == caster) return
		var/turf/throw_target = get_turf(target)
		var/counter = 5

		while(counter--)
			throw_target = get_step_away(throw_target,starting,200)
		if(!throw_target) return
		var/mob/living/ML = target
		if(istype(ML))
			ML.Weaken(1)
		target.throw_at(throw_target,rand(throwforce,throwforce*2),1)
