//
// Decay: causes special-effects style station destruction.
// Panels are ripped off the walls and floor, floor sections are ripped up,
//
//

// Called when the singularity attempts to destroy a turf
/turf/proc/gravity_decay()
	if(prob(65)) return
	for(var/obj/O in contents)
		O.anchored = 0
	return

/turf/simulated/proc/disintegrate()
	return

/turf/simulated/gravity_decay()
	if(prob(25)) return
	var/counter = 0
	for(var/d in cardinal)
		var/turf/simulated/TS = get_step(src,d)
		if(istype(TS))
			counter++

	if(prob(100 - (29 * counter)))
		new /obj/structure/faketurf(src,counter)
	else if(prob(11))
		disintegrate()
	return



/turf/simulated/floor/disintegrate()
	// rip off tile, if present
	for(var/obj/O in contents)
		O.anchored = 0
		if(istype(O,/obj/machinery))
			O:stat |= pick(NOPOWER,BROKEN,MAINT,EMPED)
			O.update_icon()
	if(floor_tile)
		floor_tile.loc = src
		floor_tile = null
		intact = 0
		SetLuminosity(0)
		if(prob(33))
			break_tile()
		else
			update_icon()
			levelupdate()
		return
	else if(prob(27))
		new /obj/structure/faketurf(loc)
	else if(prob(33))
		break_tile()

/turf/simulated/floor/engine/disintegrate()
	if(prob(80))
		return
	..()
/turf/simulated/wall/disintegrate()
	if(prob(10))
		dismantle_wall(1,0)
		return
	if(prob(60))
		dismantle_wall(0,0)
	return

/turf/simulated/wall/reinforced/disintegrate()
	if(prob(75))
		return
	if(prob(30))
		dismantle_wall(1,0) // catastrophic
		return
	if(prob(40))
		dismantle_wall(0,0)
	return

// Created when the singularity pulls a floor or wall out
/obj/structure/faketurf
	var/last_movement
	var/original_type
	var/list/anchored_objects = null

	New(var/atom/newloc,var/counter=0)
		if(!istype(newloc,/turf/simulated))
			del src
			return
		if(istype(newloc,/turf/simulated/wall/reinforced) || istype(newloc,/turf/simulated/floor/engine))
			if(prob(counter*20)) // reinforced - harder to destroy
				del src
				return
		loc = newloc

		name = loc.name
		desc = loc.desc
		icon_state = loc.icon_state
		icon = loc.icon
		dir = loc.dir
		density = loc.density
		opacity = loc.opacity
		original_type = loc.type
		last_movement = world.time
		anchored_objects = list()
		for(var/obj/O in loc.contents)
			if(O.anchored)
				anchored_objects += O
			if(istype(O,/obj/machinery))
				var/obj/machinery/OM = O
				OM.stat |= NOPOWER
				OM.update_icon()

		if(prob(33)) // doing this immediately affects the chances of other turfs coming off
			loc:ChangeTurf(/turf/space)
		else
			spawn(1)
				loc:ChangeTurf(/turf/space)
		processing_objects.Add(src)

		spawn(rand(2,8))
			step_rand(src)

	process()
		if(!loc)
			del src
			return
		if(world.time >= (last_movement + 35))
			if(!istype(loc,/turf/space) || !original_type)
				del src
				return
			var/turf/simulated/TS = new original_type(loc)
			TS.name = name
			TS.desc = desc
			TS.dir = dir
			TS.icon = icon
			TS.icon_state = icon_state
			del src
			return
	Move()
		..()
		for(var/obj/O in anchored_objects)
			if(!O || !O.anchored)
				anchored_objects -= O
				continue
			if(prob(10))
				O.anchored = 0
				anchored_objects -= O
				step_rand(O)
				continue
			if(prob(10))
				O.ex_act(3)
				continue
			O.loc = loc
		last_movement = world.time

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(istype(mover,/obj/structure/faketurf))
			return 0
		return ..(mover,target,height,air_group)
	// There is also an exception in turf/simulated/Enter() to prevent this from entering one of those tiles, ever.

