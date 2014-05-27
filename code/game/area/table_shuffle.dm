/area
	var/parsed = 0
	// These lists are only for roundstart.  They are not guaranteed to be correct afterwards.
	var/list/tables = list()
	var/list/racks = list()
	var/list/empty_floors = list()

/area/hallway/primary
	parsed = 1 // skip
/area/tdome
	parsed = 1 // skip

/proc/parse_area(var/area/A)
	if(!istype(A)) return
	if(A.parsed) return
	A.parsed = 1
	A = A.master
	for(var/area/A2 in A.related)
		A2.parsed = 1
		for(var/turf/simulated/floor/F in A2)
			var/clean = 1
			for(var/obj/O in F)
				if(!O.density || O.flags&ON_BORDER) continue
				clean = 0
				if(istype(O,/obj/structure/table))
					A.tables |= F
					break
				if(istype(O,/obj/structure/rack))
					A.racks |= F
					break
			if(clean)
				A.empty_floors |= F

/obj/structure/table/var/shuffle_exempt = 0
/obj/structure/table/initialize()
	..()
	if(shuffle_exempt) return
	var/area/A = get_area(src)
	if(!A || !A.parsed) return
	A = A.master
	if(A.tables.len > 1)
		for(var/obj/item/I in loc)
			if(prob(91)) continue
			if(I.anchored || I.invisibility) continue
			I.loc = pick(A.tables)

/obj/structure/rack/var/shuffle_exempt = 0
/obj/structure/rack/initialize()
	..()
	if(shuffle_exempt) return
	var/area/A = get_area(src)
	if(!A || !A.parsed) return
	A = A.master
	if(A.racks.len > 1)
		for(var/obj/item/I in loc)
			if(prob(93)) continue
			if(I.anchored || I.invisibility) continue
			I.loc = pick(A.racks)

/obj/item/weapon/storage/initialize()
	..()
	var/area/A = get_area(src)
	if(!A || !A.parsed) return
	A = A.master
	var/list/scatter = init_scatter()
	if(scatter.len)
		var/list/targets = A.tables + A.racks // floor locations of tables or racks
		if(!targets.len) return
		for(var/obj/item/I in scatter)
			I.loc = pick(targets) // should already have removed from storage


// vending machines also do this, see machines/vending.dm
/*
/proc/shuffle_area(var/area/A)
	if(!istype(A)) return
	if(A.parsed) return
	var/list/stuff = list()
	for(var/area/A2 in A.related)
		A2.parsed = 1
		stuff += A2.contents

	var/list/tables = list()
	var/list/items = list()
	var/list/venders = list()
	for(var/obj/machinery/vending/V in stuff)
		venders += V

	for(var/obj/structure/table/T in stuff)
		if(T.shuffle_exempt) continue
		tables += T.locs[1] // turf not the actual structure
	if(tables.len)
		for(var/obj/item/I in stuff)
			if(I.anchored) continue
			if((I.loc in tables) && prob(9))
				items += I
		for(var/obj/machinery/vending/V in venders)
			items += V.init_vend()
		for(var/obj/item/weapon/storage/S in stuff)
			items += S.init_scatter() // some things like toolboxes, donut boxes, cig packs, etc, will distribute crap.
		if(items.len)
			redistribute(tables,items)

	tables = list()
	items = list()

	for(var/obj/structure/rack/R in stuff)
		tables += R.locs[1]
	if(tables.len)
		for(var/obj/item/I in stuff)
			if(I.anchored) continue
			if((I.loc in tables) && prob(7))
				items += I
		for(var/obj/machinery/vending/V in venders)
			items += V.init_vend()
	if(items.len)
		redistribute(tables,items, optimal_range = 7)

/proc/redistribute(var/list/locations, var/list/items, var/optimal_range = 5)
	for(var/obj/O in items)
		if(!locations.len)
			return
		var/tries = 2
		var/turf/T = pick(locations)

		while(tries && get_dist(T,O) > optimal_range)
			tries--
			T = pick(locations)
		O.loc = T
*/