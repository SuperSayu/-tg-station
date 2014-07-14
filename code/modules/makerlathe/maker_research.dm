/*
	The researchable list is different in syntax from the other lists, because we
	need to keep track of which designs have been activated on this machine in case
	we need to remove them later.
*/
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

/obj/machinery/maker/proc/research_sync(var/list/research_files)
	var/list/unsynched = researchable.Copy() // keeps track of research that might have disappeared
	for(var/datum/design/D in research_files)
		if(add_design(D))
			unsynched -= D.build_path // research has not disappeared

	// If the research is not in the list of files, remove it from our memory
	for(var/entry in unsynched)
		var/datum/data/maker_product/P = unsynched[entry]
		if(istype(P)) // only if the design has been discovered
			remove_design(P)