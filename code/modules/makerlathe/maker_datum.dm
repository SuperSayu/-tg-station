/*
	Maker datum - used by all maker machines to store cost and recycling info
	This datum is responsible for deducting costs when an item is constructed,
	as well as determining if it can be built in the first place, and actually
	creating the item on behalf of the maker machine.
*/
/datum/data/maker_product
	name = "product"
	var/menu_name = null

	// cost - indexed by resource prototype, eg,
	// cost["cardboard"] = 1000 - that is not 1000 sheets, but 1000 of the resource
	var/list/cost = null
	var/description = null // cached makerlathe entry
	var/power_cost = 0 // extra power to use during creation; maker_cost["power"]
	var/time_cost = 10 // time taken, also default power use
	var/time_mod = 0   // maker_cost["time"]
	var/list/reagent_fill = null // reagents that have to be added to the cost, but may or may not be present for recycling...

	// Item produced
	var/result_typepath = /obj/item/weapon/bikehorn

/datum/data/maker_product/New(var/obj/machinery/maker/source, var/obj/item/template, var/menu, var/list/modified_cost = null)
	if(ispath(template,/obj/item)) // typepath
		generate(source, new template(null), modified_cost, destroy = 1)
	else if(istype(template))
		generate(source, template, modified_cost, destroy = 0)
	else
		del src
	menu_name = menu

/*
	Determines the cost structure for this product from a template item.
	In general, this is exactly what the maker_cost list on any given item says.

	The complications are items with their own reagents, or other special properties,
	such as power cells and air tanks.  Additionally, extra functionality exists to
	allow you to tweak the costs of things.  You can supply a modified cost list
	when you create the datum, alter the time or power requirements, and indicate
	reagents that are not recovered by recycling the item (negative values in the cost list).

	Note that generate() will del(src) if the item cannot be built by the given maker machine.
*/
/datum/data/maker_product/proc/generate(var/obj/machinery/maker/source, var/obj/item/template, var/list/modified_cost, var/destroy = 0)
	name = template.name
	result_typepath = template.type

	if(findtext(name,"\improper",1,3))
		name = copytext(name, 3) // the improper macro gets turned into some sort of 2-byte glyph that does not get removed

	if(istype(modified_cost))
		cost = modified_cost
	else
		cost = template.maker_cost.Copy()

	if(!cost) // not valid makerthing
		if(destroy) qdel(template)
		del(src)

	if(template.reagents)
		// these are taking up a bit too much space here, moving them to named procs
		calculate_reagent_fill(template.reagents)

	else if(ispath(result_typepath, /obj/item/weapon/tank)) // I cannot think of an oop way to do this sorry
		var/obj/item/weapon/tank/T = template
		// these are taking up a bit too much space here, moving them to named procs
		calculate_gas_reagents(T.air_contents)

	if(destroy) qdel(template) // got everything we need thanks

	var/build_total = 0
	for(var/entry in cost)
		switch(entry)
			if("time")
				time_mod = cost[entry]
				cost -= "time"
			if("power")
				power_cost += cost[entry]
				power_cost = max(0,power_cost)
				cost -= "power" // don't want it to show up
			else
				if(ispath(entry,/obj/item/weapon/stock_parts))
					if(!source.stock_parts && cost[entry] >= 0) // null stock parts list indicates it cannot accept parts
						del(src)
						return
					continue // but otherwise it's okay
				if(cost[entry] >= 0) // required reagent
					if(!(entry in source.recycleable)) // cannot be built on this machine]
						del(src)
						return

				build_total += abs(cost[entry])
	build_total = round( build_total / 100 )
	time_cost = max( 15, build_total + time_mod )

/*
	Tell the maker machine if we have enough resources to build this
	If user is specified, alert them upon failure.
*/
/datum/data/maker_product/proc/check_cost(var/obj/machinery/maker/M, var/mob/user = null)
	if(!M.reagents)
		if(user)
			user << "<span class='warning'>[M] appears to have some sort of internal fault.</span>"
		return 0
	var/list/stock = list()
	for(var/obj/O in stock_parts)
		stock[O.type]++
	for(var/entry in cost)

		// In the case of stock parts (batteries, capacitors, etc)
		// note =0 still requires one, it just isn't used up

		// todo: there is a fault here that I am too tired to fix
		// where you could count the same component twice
		// if for example you need both a quality manip and a lesser manip,
		// but only have the quality one
		if(ispath(entry, /obj/item/weapon/stock_parts))
			var/amt = abs(cost[entry])
			var/have = 0
			for(var/t in stock)
				if(ispath(t, entry)) // accept subtypes
					have += stock[t]
			if(amt > have) // not enough
				if(user) // skip this code if nobody is listening, I do not have a way to cache names for this right now
					if(!(entry in M.stock_names))
						var/obj/S = new entry(null)
						M.stock_names[S.type] = S.name
						qdel(S)
					var/part = M.stock_names[entry]
					user << "<span class='warning'>You need [amt] more [part]\s to create \a [name].</span>"
				return 0
			continue

		// The rest are reagents, by reagent id

		// Some are optional, if present they are added to the
		if(isnull(cost[entry])) continue // reagents of the built object

		if(!M.reagents.has_reagent(entry,abs(cost[entry] * M.component_cost_multiplier)))
			if(user)
				var/datum/reagent/R = chemical_reagents_list[entry]
				if(R)
					user << "<span class='warning'>[M] does not have enough [R.name] to create \a [name].</span>"
				else
					user << "<span class='warning'>[M] does not have enough ...[entry]? That's odd.</span>" // graceful-exception-handling station 2014
			return 0
	return 1

/*
	Deduct the cost of this plan prior to it actually being built.
	Return a list of optional reagents that were used in construction,
	as they will be used to add reagents to the result.
*/
/datum/data/maker_product/proc/deduct_cost(var/obj/machinery/maker/M, var/cost_multiplier = 1)
	var/datum/reagents/source = M.reagents
	if(!source) return null
	for(var/entry in cost)
		if(ispath(entry, /obj/item/weapon/stock_parts))
			var/amt = abs(cost[entry])
			while(amt > 0)
				// todo:
				// locate() uses an implicit istype() instead of type==, which means that depending on how the stock parts list
				// is organized, you may end up using more expensive components before less expensive ones.
				// for now, you will just have to organize your maker_cost list with expensive components first.
				var/obj/item/weapon/stock_parts/S = locate(entry) in M.stock_parts
				if(S)
					amt--
					M.stock_parts -= S
					qdel(S) // todo add these to the build_fill return list instead, have the target item handle them
		else
			source.remove_reagent(entry,abs(cost[entry] * cost_multiplier),1)


	if(reagent_fill && length(reagent_fill))
		var/list/build_fill = list()
		for(var/entry in reagent_fill)
			var/datum/reagent/R = source.has_reagent(entry)
			if(R)
				var/amt = min(reagent_fill[entry], R.volume)
				build_fill[entry] = amt
				R.volume -= amt
			else
				build_fill[entry] = 0
		source.update_total()
		return build_fill

	return null

/datum/data/maker_product/proc/build(var/obj/machinery/maker/M, var/mob/user = null)
	if( M.stat&(BROKEN|NOPOWER) ) return 0
	if( !check_cost(M, user) )
		return 0
	if(M.build_anim)
		flick(M.build_anim,M)
	M.use_power(time_cost * M.component_time_multiplier + power_cost)

	// In order to create the illusion that we are filling items with reagents,
	// we actually have to take them away; most items start filled, and in fact that
	// is how we calculate the appropriate reagent level.  deduct_cost() will track
	// these so-called fill reagents and let us know what level they should be at.
	// Note that the optional reagents *have already been deducted* with the rest.
	var/list/build_fill = deduct_cost(M, M.component_cost_multiplier)


	sleep(time_cost)
	var/obj/item/result = new result_typepath(M.loc)

	if(build_fill)
		if(result.reagents)
			//Takes the list of optional reagents and determines how much of the item's
			//existing reagents to take away, to simulate the item not being completely
			//filled.
			reagent_fill(result.reagents,build_fill)
		else if(ispath(result_typepath, /obj/item/weapon/tank))
			// Same as the above, but for the air contents of an air tank.
			var/obj/item/weapon/tank/T = result
			tank_fill(T.air_contents, build_fill)

	return result


/datum/data/maker_product/proc/calculate_reagent_fill(var/datum/reagents/source)
	if(!source) return
	for(var/entry in cost)
		if(isnull(cost[entry])) // null here indicates it is a reagent filling
			if(!reagent_fill) reagent_fill = list()
			var/datum/reagent/R = source.has_reagent(entry)
			if(R)
				reagent_fill[entry] = R.volume

/datum/data/maker_product/proc/reagent_fill(var/datum/reagents/target, var/list/fill)
	if(!target || !fill || !length(fill)) return
	for(var/entry in fill)
		var/datum/reagent/R = target.has_reagent(entry)
		if(R)
			R.volume = fill[entry]
		else if(fill[entry] > 0)
			target.add_reagent(entry,fill[entry])
			R = target.has_reagent(entry)
	target.update_total()

// You would think air tanks can fill from nearby air; consider instead that the ability for the lathe
// to hold and manage compressed air is expressed by having the correct reagent in the recycleables list.
/datum/data/maker_product/proc/calculate_gas_reagents(var/datum/gas_mixture/source)
	if(!source) return
	if(!reagent_fill) reagent_fill = list()
	if(source.oxygen)
		reagent_fill["oxygen"] = round(source.oxygen * GAS_REAGENT_RATIO) + 1
	if(source.toxins)
		reagent_fill["plasma"] = round(source.toxins * GAS_REAGENT_RATIO) + 1
	if(source.nitrogen)
		reagent_fill["nitrogen"] = round(source.nitrogen * GAS_REAGENT_RATIO) + 1
	if(source.carbon_dioxide)
		reagent_fill["co2"] = round(source.carbon_dioxide * GAS_REAGENT_RATIO) + 1

	var/datum/gas/sleeping_agent/gas = locate() in source.trace_gases
	if(gas && gas.moles)
		reagent_fill["n2o"] = round(gas.moles * GAS_REAGENT_RATIO) + 1
	reagent_fill &= cost // only reagents in the cost can be fill reagents - not that this will likely affect much?

/datum/data/maker_product/proc/tank_fill(var/datum/gas_mixture/target, var/list/fill)
	target.carbon_dioxide = 0
	target.oxygen = 0
	target.nitrogen = 0
	target.toxins = 0

	var/amt = fill["oxygen"]
	if(amt > 0)
		target.oxygen =  amt / GAS_REAGENT_RATIO

	amt = fill["nitrogen"]
	if(amt > 0)
		target.nitrogen =  amt / GAS_REAGENT_RATIO

	amt = fill["plasma"]
	if(amt > 0)
		target.toxins =  amt / GAS_REAGENT_RATIO

	amt = fill["co2"]
	if(amt > 0)
		target.carbon_dioxide =  amt / GAS_REAGENT_RATIO

	amt = fill["n2o"]
	if(amt > 0)
		var/datum/gas/sleeping_agent/gas = locate() in target.trace_gases
		if(!gas)
			gas = new
			target.trace_gases += gas
		gas.moles =  amt / GAS_REAGENT_RATIO
