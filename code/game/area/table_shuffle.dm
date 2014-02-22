/area/var/shuffled = 0
/proc/shuffle_area(var/area/A)
	if(!istype(A)) return
	if(A.shuffled) return
	var/list/stuff = list()
	for(var/area/A2 in A.related)
		A2.shuffled = 1
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
