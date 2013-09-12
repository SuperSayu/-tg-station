/area/var/shuffled = 0
/proc/shuffle_area(var/area/A)
	if(!istype(A)) return
	if(A.shuffled) return
	var/list/stuff = list()
	for(var/area/A2 in A.related)
		A2.shuffled = 1
		stuff += A2.contents
	//var/list/contents = area_contents(A) // ignore lighting subareas
	var/list/tables = list()
	var/list/items = list()

	for(var/obj/structure/table/T in stuff)
		tables += T.locs[1] // turf not the actual structure

	for(var/obj/item/I in stuff)
		if(I.anchored) continue
		if((I.loc in tables) && prob(7))
			items |= I
	if(items.len)
		redistribute(tables,items)

	tables = list()
	items = list()

	for(var/obj/structure/rack/R in stuff)
		tables += R.locs[1]

	for(var/obj/item/I in stuff)
		if(I.anchored) continue
		if((I.loc in tables) && prob(7))
			items |= I

	redistribute(tables,items, optimal_range = 7)

/proc/redistribute(var/list/locations, var/list/items, var/optimal_range = 4)
	for(var/obj/O in items)
		if(!locations.len)
			return
		var/tries = 3
		var/turf/T = pick(locations)

		while(tries && get_dist(T,O) > optimal_range)
			tries--
			T = pick(locations)
		O.loc = T
