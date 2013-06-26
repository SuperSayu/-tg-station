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

// Note: You cannot click a door (as carbon/simpleanimal) when you are only adjacent to the non-canonical loc
// (which is to say, diagonal to the right side of the door).  This is a consequence of the click code, which
// only considers distance to the canonical location, which you are 2 squares away from.  Bumping the door
// still works, because the door is physically in that location.

// This could be fixed, but you would have to rewrite the click handler.  Significantly, it would mean a second version
// of it that only applies to movable atoms, since non-moveable atoms don't have the locs[] list.

// I will consider rewriting it to make the whole click system more maintainable, but in the meantime, this is a minor inconvenience.