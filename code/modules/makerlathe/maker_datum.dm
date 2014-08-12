/*
	Maker datum - used by all maker machines to store cost and recycling info
	This datum is responsible for deducting costs when an item is constructed,
	as well as determining if it can be built in the first place, and actually
	creating the item on behalf of the maker machine.
*/
// This is basically a wrapper for params2list that ensures that all numbers are numbers and all paths are paths
/proc/makertext2list(var/text)
	var/list/cost = params2list(text)
	for(var/entry in cost)
		if(text2ascii(entry) == 47) // "/" : indicates the following is a path string
			var/path = text2path(entry)
			if(ispath(path, /obj/item/weapon/stock_parts))
				cost[path] = cost[entry]
				cost.Remove(entry)
				continue
		cost[entry] = text2num(cost[entry])
	return cost

/datum/data/maker_product
	name = "product"
	var/description = null // cached makerlathe entry
	var/cache_time = 0 // time of description cache - compared to makerlathe last multiplier change

	var/menu_name = null

	// cost - indexed by resource prototype, eg,
	// cost["cardboard"] = 1000 - that is not 1000 sheets, but 1000 of the resource
	var/list/cost = null

	var/power_cost = 0 // extra power to use during creation; maker_cost["power"]
	var/time_cost = 10 // time taken, also default power use
	var/list/filler = null // reagents that are added if present during construction

	// Item produced
	var/result_typepath = /obj/item/weapon/bikehorn

/datum/data/maker_product/New(var/obj/machinery/maker/source, var/obj/item/template, var/menu, var/list/modified_cost = null)
	if(ispath(template,/obj/item)) // typepath
		generate(source, new template(null), modified_cost, destroy = 1)
	else if(istype(template))
		generate(source, template, modified_cost, destroy = 0)
	else
		if(isnull(template)) // these can pop up in the list, don't worry about it
			del(src)
			return
		// but if that's not the case then what are we dealing with?
		var/t
		if(istype(template,/datum))
			t = "[template] ([template.type])"
		else
			t = "[template]"
		return fail_creation(source, "bad template: [t]")
	menu_name = menu

/datum/data/maker_product/proc/fail_creation(var/obj/machinery/maker/source, var/reason)
	warning("[source] ([source.type]) could not create [result_typepath]: [reason]")
	del(src)

// one-line wonder: prevent warnings when uploading files
/datum/data/maker_product/uploaded/fail_creation()
	del(src)

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
	else if(istext(modified_cost))
		cost = makertext2list(modified_cost)
	else
		cost = template.determine_cost()

	if(!cost) // not valid makerthing
		if(destroy) qdel(template)
		return fail_creation(source, "null cost list")

	filler = template.get_maker_fill(src)

	if(destroy) qdel(template) // got everything we need thanks

	var/build_total = 0
	var/time_mod = 0
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
						return fail_creation(source, "[source] cannot handle required stock parts")
					continue // but otherwise it's okay
				if(cost[entry] >= 0) // required reagent
					if(source.recycleable && !(entry in source.recycleable)) // cannot be built on this machine
						return fail_creation(source, "[source] lacks access to reagent [entry]")

				build_total += abs(cost[entry])
	if(time_mod)
		time_cost = time_mod
	else
		build_total = round( build_total / 100 )
		time_cost = max( 15, build_total + time_mod )

/datum/data/maker_product/proc/build_desc(var/obj/machinery/maker/M)
	if(description && cache_time >= M.last_multiplier_change)
		return description
	cache_time = world.time
	var/t = round(time_cost * M.component_time_multiplier)
	. = "<a href='?\ref[M];build=\ref[src]' style='white-space:nowrap;'>[name]</a> <i><small>[t/10]s <br>"
	for(var/entry in cost)
		var/amt = cost[entry]

		// stock parts
		if(ispath(entry, /obj/item/weapon/stock_parts))
			var/n = M.stock_names[entry]
			if(!(entry in M.stock_names))
				var/obj/O = new entry(null)
				M.stock_names[entry] = O.name
				n = O.name
				qdel(O)
			var/u
			switch(amt)
				if(-1000 to -1)
					u = "[-amt] [n]s (<u title='Component will not be recovered when item is recycled'>Used</u>)"
				if(0)
					u = "[n] (<u title='Component required for construction but not destroyed'>Catalyst</u>)"
				if(1)
					u = "[amt] [n]"
				if(2 to 1000)
					u = "[amt] [n]s"
				else
					u = "<u title='Code glitch, report this'>???</u> [n]s"

			. += "<span style='white-space:nowrap;'>&nbsp;[u]</span>"
			continue

		// otherwise, reagent
		var/u
		var/datum/reagent/R = chemical_reagents_list[entry]
		if(!R) continue
		if(isnull(amt))
			u = "<u title='Optional: items built without fillers will be empty.'>Fill with</u> [R.name]"
		else if(amt == 0)
			u = "[R.name] (<u title='Required ingredient, not consumed'>Catalyst</u>)"
		else if(amt < 0)
			u = "[-amt * M.component_cost_multiplier] [R.name] (<u title='Ingredient will not be recovered when item is recycled'>Used</u>)"
		else
			u = "[amt * M.component_cost_multiplier] [R.name]"
		// null (fill reagents) not applicable here

		. += "<span style='white-space:nowrap;'>&nbsp;[u]</span>"
	. += "</small></i>"
	description = .
	// return .

/*
	Tell the maker machine if we have enough resources to build this
	If user is specified, alert them upon failure.
*/
/datum/data/maker_product/proc/check_cost(var/obj/machinery/maker/M)
	if(!M.reagents)
		M.user_announce("<span class='warning'>[M] appears to have some sort of internal fault.</span>", "You hear a haunting buzz.")
		return 0
	var/list/stock = list()
	var/reliability_mod = 1 // in actuality, reliability / 100, but this is an estimate...
	if(M.overdrive) reliability_mod -= 0.05
	if(M.junktech) reliability_mod -= 0.10
	var/cost_multiplier = M.component_cost_multiplier / reliability_mod // lower reliability -> higher costs
	for(var/obj/O in M.stock_parts)
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
				if(!(entry in M.stock_names))
					var/obj/S = new entry(null)
					M.stock_names[S.type] = S.name
					qdel(S)
				var/part = M.stock_names[entry]
				var/s = ""
				if(amt > 1) s = "s"
				M.user_announce("<span class='warning'>You need [amt] more [part][s] to create \a [name].</span>", "You hear a buzz.")
				return 0
			continue

		// The rest are reagents, by reagent id

		// Some are optional, if present they are added to the
		if(isnull(cost[entry])) continue // reagents of the built object

		if(!M.reagents.has_reagent(entry,abs(cost[entry] * cost_multiplier)))
			var/datum/reagent/R = chemical_reagents_list[entry]
			if(R)
				M.user_announce("<span class='warning'>[M] does not have enough [R.name] to create \a [name].</span>", "You hear a buzz.")
			else
				M.user_announce("<span class='warning'>[M] does not have enough ...[entry]? That's odd.</span>", "You hear a haunting buzz.")
			return 0
	return 1

/*
	Deduct the cost of this plan prior to it actually being built.
	Return a list of optional reagents that were used in construction,
	as they will be used to add reagents to the result.
*/
/datum/data/maker_product/proc/deduct_cost(var/obj/machinery/maker/M, var/cost_multiplier)
	var/datum/reagents/source = M.reagents
	if(!source) return null
	var/list/build_fill = list()

	for(var/entry in cost)
		if(ispath(entry, /obj/item/weapon/stock_parts))
			var/amt = abs(cost[entry]) * cost_multiplier
			while(amt > 0)
				// todo:
				// locate() uses an implicit istype() instead of type==, which means that depending on how the stock parts list
				// is organized, you may end up using more expensive components before less expensive ones.
				// at worst this will cause you to fail to get all the components.
				// for now, you will just have to organize your maker_cost list with expensive components first.
				var/obj/item/weapon/stock_parts/S = locate(entry) in M.stock_parts
				if(S)
					amt--
					M.stock_parts -= S
					S.loc = null // temporary location
					build_fill += S
		else
			source.remove_reagent(entry,abs(cost[entry] * cost_multiplier),1)


	if(filler && length(filler))
		for(var/entry in filler)
			var/datum/reagent/R = source.has_reagent(entry)
			if(R)
				var/amt = min(filler[entry], R.volume)
				build_fill[entry] = amt
				R.volume -= amt
			else
				build_fill[entry] = 0
		source.update_total()

	if(build_fill.len)
		return build_fill
	return null

/datum/data/maker_product/proc/build(var/obj/machinery/maker/M)
	if( M.stat&(BROKEN|NOPOWER) ) return 0
	if( !check_cost(M) )
		return 0
	if(M.build_anim)
		flick(M.build_anim,M)
	var/reliability_mod = M.reliability
	if(M.overdrive) reliability_mod -= 5
	if(M.junktech) reliability_mod -= 10
	reliability_mod /= 100
	if(reliability_mod > 1) reliability_mod = 1

	var/time_taken = time_cost * M.component_time_multiplier / reliability_mod // lower reliability -> longer build
	if(M.overdrive) time_taken *= 0.85
	time_taken = round(time_taken)
	M.use_power(time_taken + power_cost)

	// In order to create the illusion that we are filling items with reagents,
	// we actually have to take them away; most items start filled, and in fact that
	// is how we calculate the appropriate reagent level.  deduct_cost() will deduct
	// these so-called fill reagents and let us know what level they should be at.
	// It will also keep track of stock parts used in construction, in case you want
	// to improve the item.

	var/cost_multiplier = M.component_cost_multiplier / reliability_mod // lower reliability -> higher cost
	var/list/build_fill = deduct_cost(M, cost_multiplier)

	sleep(time_taken)
	var/obj/item/result = new result_typepath(M.loc)

	if(build_fill)
		var/new_result = result.maker_build(build_fill) // usually we will not change the item, but it allows it to happen
		if(new_result != result)
			if(istype(new_result,/list) && !(result in new_result))
				qdel(result)
				result = new_result
			else if(isobj(new_result) || result.loc == null) // item was replaced or is being destroyed(?)
				qdel(result)
				result = new_result

	return result
