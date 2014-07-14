

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

	var/power_cost = 0 // items with batteries will use up energy during creation

	var/list/original_cost = null

	// Item produced
	var/result_typepath = /obj/item/weapon/bikehorn

/datum/data/maker_product/New(var/obj/machinery/maker/source, var/obj/item/template, var/menu, var/list/modified_cost = null)
	menu_name = menu
	if(ispath(template,/obj/item))
		template = new template(null)
		name = template.name
		result_typepath = template.type
		original_cost = template.maker_cost.Copy()
		if(template.reagents)
			for(var/entry in original_cost)
				if(!original_cost[entry]) // zero here indicates it is a reagent filling
					if(!reagent_fill) reagent_fill = list()
					var/datum/reagent/R = template.reagents.has_reagent(entry)
					if(R)
						reagent_fill[entry] = R.volume
		else if(ispath(result_typepath, /obj/item/weapon/tank)) // I cannot think of an oop way to do this sorry
			if(!reagent_fill) reagent_fill = list()
			var/obj/item/weapon/tank/T = template
			var/datum/gas_mixture/air_temp = T.air_contents
			if(air_temp.oxygen) reagent_fill["oxygen"] = round(air_temp.oxygen * GAS_REAGENT_RATIO) + 1
			if(air_temp.toxins) reagent_fill["plasma"] = round(air_temp.toxins * GAS_REAGENT_RATIO) + 1
			if(air_temp.nitrogen) reagent_fill["nitrogen"] = round(air_temp.nitrogen * GAS_REAGENT_RATIO) + 1
			if(air_temp.carbon_dioxide) reagent_fill["co2"] = round(air_temp.carbon_dioxide * GAS_REAGENT_RATIO) + 1
			var/datum/gas/sleeping_agent/gas = locate() in air_temp.trace_gases
			if(gas && gas.moles)
				reagent_fill["n2o"] = round(gas.moles * GAS_REAGENT_RATIO) + 1


		var/obj/item/weapon/stock_parts/cell/C = template
		if(!istype(C)) C = locate() in C.contents
		if(istype(C))
			power_cost = C.maxcharge
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
		var/obj/item/weapon/stock_parts/cell/C = locate() in template.contents + template
		if(C)
			power_cost = C.maxcharge
	else
		del src

	if(istype(modified_cost))
		original_cost = modified_cost.Copy()
	if(!original_cost) // not valid makerthing
		del src
	for(var/entry in original_cost)
		if(original_cost[entry] > 0 && !(entry in source.recycleable)) // mandatory resource cannot be produced here
			del src

	if(findtext(name,"\improper"))
		name = copytext(name, 3) // the improper macro gets turned into some sort of 2-byte glyph that does not get removed

	cost = original_cost.Copy()
	recalculate(source.component_cost_multiplier, source.component_time_multiplier)

/datum/data/maker_product/proc/recalculate(var/cost_multiplier, var/time_multiplier)
	src.cost = original_cost.Copy()
	var/build_total = 0
	for(var/entry in cost)
		//cost[entry] = cost_multiplier * cost[entry]
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
	M.use_power(time_cost + power_cost)

	return 1

/datum/data/maker_product/proc/build(var/obj/machinery/maker/M)
	if( M.stat&(BROKEN|NOPOWER) ) return 0
	if( !check_cost(M) )
		M.visible_message("[M] does not have enough to build [name]")
		return 0
	if(M.build_anim)
		flick(M.build_anim,M)
	deduct_cost(M)
	sleep(time_cost)
	var/obj/item/result = new result_typepath(M.loc)

	// build_fill indicates fill reagents (welding fuel, etc) that we took from the lathe
	// these reagents *have already been deducted* so we do not need to add any logic here for that.

	// You would think air tanks can fill from nearby air; consider instead that the ability for the lathe
	// to hold and manage compressed air is expressed by having the correct reagent in the recycleables list.
	if(build_fill)
		if(result.reagents)
			for(var/entry in build_fill)
				var/datum/reagent/R = result.reagents.has_reagent(entry)
				if(R)
					R.volume = build_fill[entry]
				else if(build_fill[entry] > 0)
					result.reagents.add_reagent(entry,build_fill[entry])
					R = result.reagents.has_reagent(entry)
				if(R)
					M.reagents.remove_reagent(entry,R.volume)
			result.reagents.update_total()

		else if(ispath(result_typepath, /obj/item/weapon/tank)) // this is clumsy but should fill tanks from reagents
			var/obj/item/weapon/tank/T = result
			var/datum/gas_mixture/air_temp = T.air_contents
			air_temp.carbon_dioxide = 0
			air_temp.oxygen = 0
			air_temp.nitrogen = 0
			air_temp.toxins = 0

			var/amt = build_fill["oxygen"]
			if(amt > 0)
				air_temp.oxygen =  amt / GAS_REAGENT_RATIO
				M.reagents.remove_reagent("oxygen", amt)

			amt = build_fill["nitrogen"]
			if(amt > 0)
				air_temp.nitrogen =  amt / GAS_REAGENT_RATIO
				M.reagents.remove_reagent("nitrogen", amt)

			amt = build_fill["plasma"]
			if(amt > 0)
				air_temp.toxins =  amt / GAS_REAGENT_RATIO
				M.reagents.remove_reagent("plasma", amt)

			amt = build_fill["co2"]
			if(amt > 0)
				air_temp.carbon_dioxide =  amt / GAS_REAGENT_RATIO
				M.reagents.remove_reagent("co2", amt)

			amt = build_fill["n2o"]
			if(amt > 0)
				var/datum/gas/sleeping_agent/gas = locate() in air_temp.trace_gases
				if(!gas)
					gas = new
					air_temp.trace_gases += gas
				gas.moles =  amt / GAS_REAGENT_RATIO
				M.reagents.remove_reagent("n2o", amt)

		build_fill = null
	return result
