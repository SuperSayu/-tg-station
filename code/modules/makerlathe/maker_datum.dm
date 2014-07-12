/datum/data/maker_product
	// resultant item name
	name = "product"
	// menus are used to separate products into legible categories
	var/menu_name = null

	// cost - indexed by resource prototype, eg,
	// cost["cardboard"] = 1000 - that is not 1000 sheets, but 1000 of the resource
	var/list/cost // cost reduced by maker parts after recalculation
	var/time_cost = 10 // cost increases as resource use increases
	var/list/reagent_fill = null // reagents that have to be added to the cost, but may or may not be present for recycling...
	var/build_fill = null

	var/list/original_cost = list("iron" = 1000)

	// Item produced
	var/result_typepath = /obj/item/weapon/bikehorn

/datum/data/maker_product/New(var/obj/machinery/maker/source, var/obj/item/template, var/menu, var/list/modified_cost = null)
	menu_name = menu
	if(ispath(template,/obj/item))
		template = new template(null)
		name = template.name
		result_typepath = template.type
		original_cost = template.maker_cost
		for(var/entry in original_cost)
			if(!original_cost[entry]) // zero here indicates it is a reagent filling
				if(!reagent_fill) reagent_fill = list()
				var/datum/reagent/R = template.reagents.has_reagent(entry)
				if(R)
					reagent_fill[entry] = R.volume
		qdel(template)
	else if(istype(template))
		name = template.name
		result_typepath = template.type
		original_cost = template.maker_cost.Copy()
		for(var/entry in original_cost)
			if(!original_cost[entry]) // zero here indicates it is a reagent filling
				if(!reagent_fill) reagent_fill = list()
				var/datum/reagent/R = template.reagents.has_reagent(entry)
				if(R)
					reagent_fill[entry] = R.volume
	else
		del(src)
	if(modified_cost)
		original_cost = modified_cost
	if(!original_cost) // not valid makerthing
		del(src)

	recalculate(source.component_cost_multiplier, source.component_time_multiplier)

/datum/data/maker_product/proc/recalculate(var/cost_multiplier, var/time_multiplier)
	cost = original_cost.Copy()
	var/build_total = 0
	for(var/entry in cost)
		cost[entry] *= cost_multiplier
		build_total += cost[entry]
	build_total = round(build_total / 100)
	time_cost = build_total * time_multiplier
	time_cost = max(15, time_cost)

/datum/data/maker_product/proc/check_cost(var/obj/machinery/maker/M)
	if(!M.reagents) return 0
	for(var/entry in cost)
		if(!cost[entry]) continue // these are optional, if present they are added to the
		if(!M.reagents.has_reagent(entry,cost[entry])) // reagents of the built object
			return 0
	return 1

/datum/data/maker_product/proc/deduct_cost(var/obj/machinery/maker/M)
	if(!M.reagents) return 0
	for(var/entry in cost)
		M.reagents.remove_reagent(entry,cost[entry],1)
	if(reagent_fill && length(reagent_fill))
		build_fill = list()
		for(var/entry in reagent_fill)		// build_fill will indicate how much of the optional reagents
			var/datum/reagent/R = M.reagents.has_reagent(entry) // will get put into the final object
			if(R)							// In many cases this will mean removing reagents from the template.
				build_fill[entry] = min(reagent_fill[entry], R.volume)
			else
				build_fill[entry] = 0

	return 1

/datum/data/maker_product/proc/build(var/obj/machinery/maker/M)
	if( M.stat&(BROKEN|NOPOWER) ) return 0
	if( !check_cost(M) )
		M.visible_message("[M] does not have enough to build [name]")
		return 0
	deduct_cost(M)
	sleep(time_cost)
	var/obj/item/result = new result_typepath(M.loc)
	if(build_fill && result.reagents)	// build_fill indicates fill reagents (fire extinguisher water, etc) that we took from the lathe
		for(var/entry in build_fill)	// this allows fire extinguishers built without water to have none, same for welding tools, etc
			var/datum/reagent/R = result.reagents.has_reagent(entry)
			if(R)
				R.volume = build_fill[entry]
			else if(build_fill[entry] > 0)
				result.reagents.add_reagent(entry,build_fill[entry])
				R = result.reagents.has_reagent(entry)
			if(R)
				M.reagents.remove_reagent(entry,R.volume)
		result.reagents.update_total()
	build_fill = null
	return result
