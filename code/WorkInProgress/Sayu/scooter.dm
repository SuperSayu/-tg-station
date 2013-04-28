/proc/CW(var/dir)
	switch(dir)
		if(1)
			return 4
		if(2)
			return 8
		if(4)
			return 2
		if(8)
			return 1
	return 0
/proc/CCW(var/dir)
	switch(dir)
		if(1)
			return 8
		if(2)
			return 4
		if(4)
			return 1
		if(8)
			return 2
	return 0
/proc/flipdir(var/dir)
	switch(dir)
		if(1)
			return 2
		if(2)
			return 1
		if(4)
			return 8
		if(8)
			return 4
	return 0

/obj/machinery/scooter
	name = "Delivery Scooter"
	desc = "A moped for deliverying bulky packages.  Runs off gaseous plasma."
	icon = 'icons/WIP_Sayu.dmi'
	icon_state = "moped"
	density = 1

	var/obj/item/weapon/tank/fueltank = null
	var/mob/living/carbon/pilot = null
	var/obj/structure/closet/cargo = null

	var/max_speed = 3

	var/speed = 0
	var/upright = 1
	var/fueled = 0
	var/wipe_dir = 0
	var/bloody_tires = 0

	New()
		..()
		update_icon()

	verb/board()
		set name = "Mount Scooter"
		set src in range(1)
		if(pilot || !upright) return
		if(do_after(usr,15) && !pilot)
			pilot = usr
			pilot.loc = loc
			pilot.buckled = src
			usr << "You climb on [src] and buckle up."
			pilot.update_canmove()
			pilot.dir = dir

	proc/righten()
		set name = "Uprighten Scooter"
		set src  in range(1)
		if(!upright)
			upright = 1
			update_icon()

	proc/RunOver(var/atom/movable/AM)
		var/hit_mass = speed+1
		if(pilot) hit_mass++
		if(cargo) hit_mass++

		if(istype(AM,/mob)) // laying down on the job
			var/mob/living/M = AM
			M.apply_damage(hit_mass*5,BRUTE,null,M.run_armor_check()+1)
			M.Weaken(hit_mass/2)
			bloody_tires += 2
			return
		if(istype(AM,/obj/item))
			if(prob(25))
				var/turf/target = loc
				var/d = flipdir(dir)
				if(!upright) d = dir
				var/i = speed
				while(i)
					i--
					target=get_step(target,d)
				AM.throw_at(target,speed,speed)



	Move()
		if(..())
			if(speed>1)
				for(var/atom/movable/AM in loc)
					if(AM == src || AM == pilot || AM.anchored) continue
					if(istype(AM,/mob/dead) || istype(AM,/obj/effect)) continue
					RunOver(AM)

			if(bloody_tires > 0)
				bloody_tires--
				var/obj/effect/decal/cleanable/blood/T
				if(upright)
					T = new/obj/effect/decal/cleanable/blood/tracks(loc)
				else // splat
					T = new(loc)
					if(bloody_tires)
						bloody_tires--
				T.dir = dir


		if(!upright)
			dir = wipe_dir

		if(pilot && pilot.buckled == src)
			pilot.loc = loc


	MouseDrop_T(atom/movable/AM as obj|mob, mob/user as mob)
		if(AM == user && !pilot)
			usr = user
			board()
		else if(!cargo && istype(AM,/obj/structure/closet))
			cargo = AM
			cargo.loc = src
			update_icon()
		return

	attack_hand(mob/user as mob)
		if(!upright)
			user << "You start to pick up [src]"
			if(do_after(user,50))
				righten()
				user << "You get [src] back upright."
			return

		if(pilot)
			if(user == pilot)
				eject_pilot()
			else if(user.a_intent == "disarm")
				eject_pilot()

			if(speed && prob(speed*30))
				wipeout()
			update_icon()
			return
		if(speed && prob(speed*30))
			wipeout()
			return

		if(!speed && cargo)
			cargo.loc = loc
			cargo = null
			update_icon()
			return

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/tank) && !fueltank)
			fueltank = W
			user.drop_item()
			W.loc = src
			return
		if(istype(W,/obj/item/weapon/crowbar) && fueltank && !speed)
			fueltank.loc = loc
			fueltank = null
			fueled = null
			return
		..(W,user)

	proc/eject_pilot()
		pilot.buckled = null
		if(speed > 2)
			pilot.Weaken(speed)
			var/turf/T = get_turf(loc)
			var/i = speed
			var/d1 = CW(dir)
			var/d2 = CCW(dir)
			while(i)
				i--
				T = get_step(T,dir)
				T = get_step(T, pick(d1, d2))

			walk_towards(pilot, T,8-(2*speed))
			spawn(25)
				walk(pilot,0)
			pilot << "You lose your footing as you hit the ground!"
			pilot.take_organ_damage(speed*5)
		pilot.update_canmove()
		pilot = null

	relaymove(var/mob/user as mob, var/direction)
		if(user != pilot || !upright) return

		if(direction == dir && combust())
			speed = min(speed+1,max_speed)
			walk(src,dir,8-(2*speed))

		else if(direction == flipdir(dir))
			speed = max(speed-1, 0)
			if(!speed)
				walk(src,0)

		else
			if( speed <= 3 )
				dir = direction
				update_icon()
				if(speed)
					walk(src,dir,8-(2*speed))
			else
				wipe_dir = direction
				wipeout()
	update_icon()
		if(upright)
			icon_state = "moped"
			if(dir < 3)
				layer = FLY_LAYER
			else
				layer = OBJ_LAYER
		else
			icon_state = "moped_flipped"
			layer = FLY_LAYER

		if(cargo)
			icon_state += "_cargo"

		if(pilot)
			pilot.dir = dir

	process()
		if(!speed)
			return

		if(!upright || !combust())
			speed = max(speed-1,0)
			if(speed)
				walk(src,dir,8-(2*speed))
			else
				walk(src,0)

	proc/combust()
		if(!fueltank || !isturf(loc))
			fueled = 0
			return 0
		var/turf/simulated/T = loc
		if(!T.air)
			fueled = 0
			return 0
		var/datum/gas_mixture/engine = fueltank.air_contents.remove(0.25)
		var/datum/gas_mixture/carb = T.air.remove_ratio(0.25)
		var/t = engine.toxins + carb.toxins
		var/o = engine.oxygen + carb.oxygen
		var/reaction_rate = min(t/2,o)
		var/low_o2 = 0

		if(reaction_rate < 0.1) // ideally .125
			fueled = 0
			if((t > 2*o)) // excess fuel
				low_o2 = 1
		else
			fueled = 1

		if(reaction_rate > 0.05)
			var/temp = min(2*reaction_rate,engine.toxins)
			engine.toxins -= temp
			t -= temp
			carb.toxins -= t

			temp = min(reaction_rate, engine.oxygen)
			engine.oxygen -= temp
			o -= temp
			carb.oxygen -= o

			carb.carbon_dioxide += reaction_rate
			var/heat_capacity = carb.heat_capacity()
			if(heat_capacity == 0 || heat_capacity == null)
				heat_capacity = 1
			carb.temperature = min((carb.temperature*heat_capacity + 80000)/heat_capacity, 1000)

			fueltank.air_contents.merge(engine)
			T.air.merge(carb)
		else
			T.air.merge(carb)


		if(!fueled)
			var/rough_noise = pick("sputters","coughs","pops")
			visible_message("\The [src] [rough_noise]")
			if(low_o2 && prob(33))
				var/obj/effect/smoke
				if(prob(60))
					smoke = new /obj/effect/effect/bad_smoke(loc)
				else
					smoke = new /obj/effect/effect/harmless_smoke(loc)
				spawn(0)
					while(smoke)
						sleep(rand(25,75))
						step_rand(smoke)
		return fueled


	proc/wipeout(var/hit = 0)
		upright = 0
		update_icon()
		if(!speed)
			return
		var/turf/target = get_edge_target_turf(src, dir)
		if(pilot && pilot.buckled == src)
			if(hit)
				pilot.buckled = null
				pilot.loc = loc
				if(prob(30))
					step_rand(pilot)
				pilot.throw_at(target,speed,speed)
				pilot = null
			else
				eject_pilot()
		if(hit)
			if(speed > 2)
				if(cargo)
					cargo.loc = loc
					if(prob(30))
						step_rand(cargo)
					cargo.throw_at(target,speed,speed)
					cargo = null
				rupture_tank()
			speed = 0
			walk(src,0)
		update_icon()



	proc/rupture_tank()
		if(!fueltank) return
		var/amount_lost = pick(1, 0.5, 0.5, 0.25, 0.25, 0.25, 0.125) // 1:100%
		var/turf/simulated/T = get_turf(loc)
		var/datum/gas_mixture/temp = fueltank.air_contents.remove_ratio(amount_lost)
		var/t_volume = temp.return_volume()
		T.assume_air(temp)
		T.hotspot_expose(500,t_volume)

	Bump(var/atom/A)
		var/hit_mass = speed
		if(pilot) hit_mass++
		if(cargo) hit_mass++

		if(speed>2)
			wipeout(1)

		if(istype(A,/turf) || istype(A,/obj/structure) || istype(A,/obj/machinery))
			speed = 0
			walk(src,0)
			if(hit_mass >= 5)
				A.ex_act(3)
		if(istype(A,/mob))
			var/mob/living/M = A
			step_away(M,src)
			M.Weaken(hit_mass)
			M.apply_damage(hit_mass*5,BRUTE,null,M.run_armor_check())
		..()
