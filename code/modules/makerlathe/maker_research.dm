/*
	The researchable list is different in syntax from the other lists, because we
	need to keep track of which designs have been activated on this machine in case
	we need to remove them later.

	Note that design research files can be uploaded onto hacked lathes.  This requires
	* Pulse the dataport wire to unlock the dataport, then either:
	* Deconstruct the machine and mutitool the board to unlock it, or
	* Emag the machine with the dataport open

	The machine must still be capable of constructing the researched design, however,
	it does not need to be on the pre-approved construction list.  That list is only
	used to filter out designs from the R&D server sync.  Once the design is uploaded via
	disk, it will no longer disappear during server sync if the server copy is deleted!

	As always it pays to have a backup.
*/
/obj/machinery/maker/proc/server_connect()
	busy = 1
	busy_message = "Searching for servers..."
	updateUsrDialog()
	sleep(100)
	server = locate(/obj/machinery/r_n_d/server/robotics) in world
	busy = 0

/obj/machinery/maker/proc/add_design(var/datum/design/D)
	if(D.build_path in researchable)
		var/entry = researchable[D.build_path]
		if(!entry || istext(entry)) // new tech - must create product.  The text placeholder is the menu it will be under
			var/datum/data/maker_product/P = new(src, D.build_path, entry)
			std_products += P
			researchable[D.build_path] = P
		return 1
	return 0

/obj/machinery/maker/proc/remove_design(var/datum/data/maker_product/P)
	if(ispath(P,/obj/item))
		for(var/datum/data/maker_product/test in std_products)
			if(test.result_typepath == P)
				P = test
				break
		if(!istype(P))
			return 0

	if(researchable[P.result_typepath] == P)
		researchable[P.result_typepath] = P.menu_name
		std_products -= P
		if(istype(all_menus[P.menu_name],/list))
			all_menus[P.menu_name] -= P
		qdel(P)
		return 1
	return 0

/obj/machinery/maker/proc/research_sync()
	if(!server || server.disabled) return
	busy = 1
	busy_message = "Synchronizing files with server..."
	updateUsrDialog()
	var/list/research_files = server.files.known_designs
	sleep(10 * researchable.len)
	server.produce_heat(100)

	var/list/unsynched = researchable.Copy() // keeps track of research that might have disappeared
	for(var/datum/design/D in research_files)
		if(add_design(D))
			unsynched -= D.build_path // research has not disappeared

	// If the research is not in the list of files, remove it from our memory
	for(var/entry in unsynched)
		var/datum/data/maker_product/P = unsynched[entry]
		if(istype(P)) // only if the design has been lost
			remove_design(P)
	busy = 0