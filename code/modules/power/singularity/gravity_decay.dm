// Created when the singularity pulls a floor or wall out
/obj/structure/faketurf
	var/last_movement
	var/original_type
	var/list/anchored_objects = null
	anchored = 0
	layer = TURF_LAYER + 0.1

	New(var/turf/simulated/newloc,var/counter=0)
		if(!istype(newloc) || newloc.baseturf == newloc.type)
			del src
			return
		if(istype(newloc,/turf/simulated/wall/r_wall) || istype(newloc,/turf/simulated/floor/engine))
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
				if(istype(O,/obj/effect/meteor))
					continue
				anchored_objects += O
			if(istype(O,/obj/machinery))
				var/obj/machinery/OM = O
				OM.stat |= NOPOWER
				OM.update_icon()
		var/turf/T = loc
		if(prob(33)) // doing this immediately affects the chances of other turfs coming off
			T.ChangeTurf(T.baseturf)
		else
			spawn(1)
				if(loc)
					T.ChangeTurf(T.baseturf)
		SSobj.processing |= src

		spawn(rand(2,8))
			if(loc)
				step_rand(src)

/obj/structure/faketurf/process()
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

/obj/structure/faketurf/Move()
	..()
	for(var/obj/O in anchored_objects)
		if(!O || !O.anchored || O.loc != loc)
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

/obj/structure/faketurf/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover,/obj/structure/faketurf))
		return 0
	return ..(mover,target,height,air_group)

/obj/structure/lattice/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover,/obj/structure/faketurf))
		return 0
	return ..(mover,target,height,air_group)

/obj/structure/faketurf/ex_act()
	return
// There is also an exception in turf/simulated/Enter() to prevent this from entering one of those tiles, ever.

/obj/structure/faketurf/singularity_pull(S,current_size)
	if(prob(current_size * 5))
		step_to(src,S)

//Disable these
/obj/structure/faketurf/throw_at()
	return
/obj/structure/faketurf/SpinAnimation()
	return