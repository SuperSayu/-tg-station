/datum/data/maker_product
	// resultant item name
	name = "product"
	// menus are used to separate products into legible categories
	var/menu_name = null

	// cost - indexed by resource prototype, eg,
	// cost["cardboard"] = 1000 - that is not 1000 sheets, but 1000 of the resource
	var/time_cost = 10 // cost increases as resource use increases
	var/list/cost // cost reduced by maker parts after recalculation
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
		qdel(template)
	else if(istype(template))
		name = template.name
		result_typepath = template.type
		original_cost = template.maker_cost.Copy()
		// we didn't make it, don't destroy it
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
		if(!M.reagents.has_reagent(entry,cost[entry]))
			return 0
	return 1

/datum/data/maker_product/proc/deduct_cost(var/obj/machinery/maker/M)
	if(!M.reagents) return 0
	for(var/entry in cost)
		M.reagents.remove_reagent(entry,cost[entry],1)
	return 1

/datum/data/maker_product/proc/build(var/obj/machinery/maker/M)
	if( M.stat&(BROKEN|NOPOWER) ) return 0
	if( !check_cost(M) )
		M.visible_message("[M] does not have enough to build [name]")
		return 0
	deduct_cost(M)
	sleep(time_cost)
	return new result_typepath(M.loc)
