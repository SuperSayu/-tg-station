/*
	Much of this code is to handle legacy item cost variables
	The only reason why this occurs is because I am running
	out of time before I have to move and there are an egregious
	number of judgement calls involved in changing the build cost
	of every single item in the game.

	In the future please slowly (or quickly!) replace all of the
	build costs with a standardized system
*/
/obj/item/proc/determine_cost()
	if(istype(maker_cost))
		return maker_cost.Copy()
	if(istext(maker_cost))
		return makertext2list(maker_cost)
	if(m_amt || g_amt)
		var/list/cost = list()
		if(m_amt) cost["iron"] = m_amt
		if(g_amt) cost["glass"] = g_amt
		return cost
	var/global/list/design_datums = null
	if(!design_datums)
		design_datums = list()
		for(var/t in typesof(/datum/design) - /datum/design)
			var/datum/design/temp = new t()
			design_datums[temp.build_path] = temp
	if(type in design_datums)
		var/list/cost = list()
		var/datum/design/D = design_datums[type]
		if(!D || !D.materials.len)
			warning("[type]/determine_cost(): bad design")
			return null
		for(var/entry in D.materials)
			var/value = D.materials[entry]
			switch(entry)
				if("$metal") cost["iron"] = value
				if("$clown") cost["bananium"] = value
				else
					if(text2ascii(entry,1) == 36) // $ - all the other sheet names are now reagents
						entry = copytext(entry,2)
					cost[entry] = value
		return cost
	return null

/obj/item/robot_parts/determine_cost()
	if(!construction_cost) return null
	var/list/cost = construction_cost.Copy()
	if("metal" in cost)
		cost["iron"] = cost["metal"]
		cost -= "metal"
	cost["time"] = construction_time
	return cost

/obj/item/mecha_parts/determine_cost()
	if(!construction_cost) return null
	var/list/cost = construction_cost.Copy()
	if("metal" in cost)
		cost["iron"] = cost["metal"]
		cost -= "metal"
	cost["time"] = construction_time
	return cost

// todo maybe contents list check?
/obj/item/proc/maker_disassemble(var/obj/machinery/maker/M)
	var/list/cost = determine_cost()
	for(var/entry in cost)
		if(ispath(entry, /obj/item/weapon/stock_parts))
			var/amount = cost[entry]
			while(amount > 0)
				var/obj/O = new entry(M)
				M.stock_parts += O
				if(!(O.type in M.stock_names))
					M.stock_names[O.type] = O.name
				amount--
			continue

		if(M.reagents.total_volume >= M.reagents.maximum_volume)
			continue

		var/value = cost[entry]
		if(value <= 0 || isnull(value))	// negative values are used up in the build process, not recovered; null value is required by the build process but not consumed
			continue					// zero value is used to indicate fill reagents.
		M.reagents.add_reagent(entry,value) // amt is used when the incoming is a stack

	if(reagents && reagents.total_volume)
		if(!M.recycleable)
			reagents.trans_to(M,reagents.total_volume)
		else
			for(var/datum/reagent/R in reagents.reagent_list)
				if(M.reagents.total_volume >= M.reagents.maximum_volume)
					break
				if(R.id in M.recycleable)
					reagents.trans_id_to(M,R.id,R.volume)
			//Overflow cup
			if(reagents.total_volume)
				if(M.beaker)
					reagents.trans_to(M.beaker, reagents.total_volume)
				else
					M.reliability-- // no overflow cup means stuff is sloshing around in there
	qdel(src)

/obj/item/stack/maker_disassemble(var/obj/machinery/maker/M)
	var/max_insertable = 1
	var/space = M.reagents.maximum_volume - M.reagents.total_volume
	var/per_unit = 0
	var/list/cost = determine_cost()
	for(var/entry in cost)
		if(cost[entry] <= 0) continue
		per_unit += cost[entry]
	max_insertable = min(amount, round(space / per_unit))

	for(var/entry in cost)
		if(ispath(entry, /obj/item/weapon/stock_parts))
			var/amount = cost[entry] * max_insertable
			while(amount > 0)
				var/obj/O = new entry(M)
				M.stock_parts += O
				if(!(O.type in M.stock_names))
					M.stock_names[O.type] = O.name
				amount--
			continue

		if(M.reagents.total_volume >= M.reagents.maximum_volume)
			continue

		var/value = cost[entry]
		if(value <= 0 || isnull(value))	// negative values are used up in the build process, not recovered; null value is required by the build process but not consumed
			continue					// zero value is used to indicate fill reagents.
		M.reagents.add_reagent(entry,value * max_insertable)

	if(reagents && reagents.total_volume)
		if(!M.recycleable)
			reagents.trans_to(M,reagents.total_volume)
		else
			for(var/datum/reagent/R in reagents.reagent_list)
				if(M.reagents.total_volume >= M.reagents.maximum_volume)
					break
				if(R.id in M.recycleable)
					reagents.trans_id_to(M,R.id,R.volume)
			//Overflow cup
			if(reagents.total_volume)
				if(M.beaker)
					reagents.trans_to(M.beaker, reagents.total_volume)
				else
					M.reliability-- // no overflow cup means stuff is sloshing around in there
	use(max_insertable)
	return

/obj/item/weapon/tank/maker_disassemble(var/obj/machinery/maker/M)
	// handle recycling compressed gasses
	if(!reagents && air_contents)
		create_reagents(10000) // temporary and who cares honestly
		reagents.add_reagent("oxygen",air_contents.oxygen * GAS_REAGENT_RATIO)
		reagents.add_reagent("nitrogen",air_contents.oxygen * GAS_REAGENT_RATIO)
		reagents.add_reagent("plasma",air_contents.toxins * GAS_REAGENT_RATIO)
		reagents.add_reagent("co2",air_contents.carbon_dioxide * GAS_REAGENT_RATIO)
		var/datum/gas/sleeping_agent/gas = locate() in air_contents.trace_gases
		if(gas) reagents.add_reagent("n2o",gas.moles * GAS_REAGENT_RATIO)
	..()

/obj/item/weapon/stock_parts/maker_disassemble(var/obj/machinery/maker/M)
	if(M.stock_parts && !M.recycle_stock_parts)
		M.stock_parts += src
		src.loc = M
		if(!(type in M.stock_names))
			M.stock_names[type] = initial(name)
		return 1 // do not delete
	..()

/*
	Makerlathes want us to spawn empty unless there are enough
	fill reagents to cover the "cost" of our starting reagents.
	This code reduces starting reagents to the proper amount.
*/
/obj/item/proc/get_maker_fill(var/datum/data/maker_product/P)
	if(!reagents) return null

	var/list/fill = list()
	for(var/entry in P.cost)
		if(isnull(P.cost[entry]))
			var/datum/reagent/R = reagents.has_reagent(entry)
			if(R)
				fill[entry] = R.volume
	if(fill.len)
		return fill
	return null

/obj/item/proc/maker_build(var/list/fill)
	if(!fill || !fill.len || !reagents)	return src // not returning src deletes the object
	for(var/entry in fill)
		var/datum/reagent/R = reagents.has_reagent(entry)
		if(R)
			R.volume = fill[entry]
		else if(fill[entry] > 0)
			reagents.add_reagent(entry,fill[entry])
	reagents.update_total()
	return src // no item upgrade

// You would think air tanks can fill from nearby air; consider instead that the ability for the lathe
// to hold and manage compressed air is expressed by having the correct reagent in the recycleables list.
/obj/item/weapon/tank/get_maker_fill(var/datum/data/maker_product/P)
	if(!air_contents) return null

	var/list/fill = list()
	if(air_contents.oxygen)
		fill["oxygen"] = round(air_contents.oxygen * GAS_REAGENT_RATIO) + 1
	if(air_contents.toxins)
		fill["plasma"] = round(air_contents.toxins * GAS_REAGENT_RATIO) + 1
	if(air_contents.nitrogen)
		fill["nitrogen"] = round(air_contents.nitrogen * GAS_REAGENT_RATIO) + 1
	if(air_contents.carbon_dioxide)
		fill["co2"] = round(air_contents.carbon_dioxide * GAS_REAGENT_RATIO) + 1

	var/datum/gas/sleeping_agent/gas = locate() in air_contents.trace_gases
	if(gas && gas.moles)
		fill["n2o"] = round(gas.moles * GAS_REAGENT_RATIO) + 1
	fill &= P.cost // only reagents in the cost can be fill reagents - not that this will likely affect much?

	if(fill.len)
		return fill
	return null

/obj/item/weapon/tank/maker_build(var/list/fill)
	if(!fill || !fill.len || !air_contents) return src
	air_contents.carbon_dioxide = 0
	air_contents.oxygen = 0
	air_contents.nitrogen = 0
	air_contents.toxins = 0

	var/amt = fill["oxygen"]
	if(amt > 0)
		air_contents.oxygen =  amt / GAS_REAGENT_RATIO

	amt = fill["nitrogen"]
	if(amt > 0)
		air_contents.nitrogen =  amt / GAS_REAGENT_RATIO

	amt = fill["plasma"]
	if(amt > 0)
		air_contents.toxins =  amt / GAS_REAGENT_RATIO

	amt = fill["co2"]
	if(amt > 0)
		air_contents.carbon_dioxide =  amt / GAS_REAGENT_RATIO

	amt = fill["n2o"]
	if(amt > 0)
		var/datum/gas/sleeping_agent/gas = locate() in air_contents.trace_gases
		if(!gas)
			gas = new
			air_contents.trace_gases += gas
		gas.moles =  amt / GAS_REAGENT_RATIO

	return src // no item upgrade

/obj/item/weapon/disk/nuclear/maker_cost = null
/obj/item/weapon/extinguisher/maker_cost = list("iron" = 1500, "water" = null) // null indicates it is a fill reagent
/obj/item/weapon/weldingtool/maker_cost = list("iron" = 500, /obj/item/weapon/stock_parts/manipulator = 1, "fuel" = null)

/obj/item/stack
	maker_cost = null

/obj/item/stack
	rods
		maker_cost = list("iron" = 300)
	cable_coil
		maker_cost = list("iron" = 250)

/obj/item/stack/medical
	bruise_pack
		maker_cost = list("bicaridine" = 50)
	ointment
		maker_cost = list("dermaline" = 50)

// these amounts should equal the reagent's resource_amt var
/obj/item/stack/sheet
	metal
		maker_cost = list("iron" = MINERAL_MATERIAL_AMOUNT)
	plasteel
		maker_cost = list("plasteel" = MINERAL_MATERIAL_AMOUNT)	// maker reagent
	glass
		maker_cost = list("glass" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	rglass
		maker_cost = list("rglass" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	cardboard
		maker_cost = list("cardboard" = MINERAL_MATERIAL_AMOUNT)	// maker reagent
	cloth
		maker_cost = list("cloth" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	leather
		maker_cost = list("leather" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	xenochitin
		maker_cost = list("xenol" = MINERAL_MATERIAL_AMOUNT)		// maker reagent

/obj/item/stack/sheet/mineral
	clown
		maker_cost = list("bananium" = MINERAL_MATERIAL_AMOUNT)	// maker reagent
	diamond
		maker_cost = list("diamond" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	gold
		maker_cost = list("gold" = MINERAL_MATERIAL_AMOUNT)
	plasma
		maker_cost = list("splasma" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	sandstone
		maker_cost = list("sandstone" = MINERAL_MATERIAL_AMOUNT)	// maker reagent
	silver
		maker_cost = list("silver" = MINERAL_MATERIAL_AMOUNT)
	uranium
		maker_cost = list("uranium" = MINERAL_MATERIAL_AMOUNT)
	wood
		maker_cost = list("wood" = MINERAL_MATERIAL_AMOUNT)		// maker reagent

/obj/item/stack/tile
	carpet
		maker_cost = list("carpet" = 50)		// maker reagent
	grass
		maker_cost = list("grass" = 50)			// maker reagent
	light
		maker_cost = list("iron" = 150, "glass" = 250)
	plasteel
		maker_cost = list("iron" = 500)
	wood
		maker_cost = list("wood" = 250)			// maker reagent

/obj/item/weapon/tank
	oxygen
		maker_cost = list("iron" = 1500, "oxygen" = null)
	emergency_oxygen
		maker_cost = list("iron" = 500, "oxygen" = null)
	plasma
		maker_cost = list("iron" = 1500, "plasma" = null)

/obj/item/clothing/under/maker_cost = list("cloth" = 500)
/obj/item/clothing/suit/hazardvest/maker_cost = list("cloth" = 850)

/obj/item/weapon/circuitboard/maker_cost = list("glass" = 1000, "copper" = 5, "sacid" = -20) // negative value means build cost but not recycleable

/obj/item/weapon/reagent_containers/food/snacks/maker_cost = list("nutriment" = -50)
/obj/item/weapon/storage
	belt/maker_cost = list("leather" = 500)
	bag/maker_cost = list("leather" = 500)
	backpack/maker_cost = list("cloth" = 500)
	backpack/satchel/maker_cost = list("leather" = 500)
	briefcase/maker_cost = list("leather" = 1000)
	wallet/maker_cost = list("leather" = 250)

/obj/item/weapon/reagent_containers/glass/bottle/maker_cost = list("glass" = BOTTLE_GLASS_COST)
/obj/item/weapon/storage/box/maker_cost = list("cardboard" = 250)
/obj/item/weapon/storage/fancy/maker_cost = list("cardboard" = 500)