/obj/machinery/door/airlock/glass_large
	name = "glass airlock"
	icon = 'icons/obj/doors/Door2x1glassfull.dmi'
	opacity = 0
	doortype = 10
	bound_width = 64
	glass = 1

/obj/machinery/door/airlock/glass_large/update_nearby_tiles(need_rebuild)
	if(!air_master) return 0
	var/list/update_tiles = locs.Copy()
	for(var/turf/T in locs)
		update_heat_protection(T)
		update_tiles += T
		update_tiles |= get_step(T,NORTH)
		update_tiles |= get_step(T,SOUTH)
		update_tiles |= get_step(T,EAST)
		update_tiles |= get_step(T,WEST)

	for(var/turf/simulated/TS in update_tiles)
		if(TS.parent && need_rebuild)
			air_master.groups_to_rebuild += TS.parent
		else
			air_master.tiles_to_update += TS
	return 1