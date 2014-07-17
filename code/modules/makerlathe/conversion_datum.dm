/*
	This exists to support converting reagents into
	another reagent.  For example, the biogenerator
	may wish to convert nutriment into milk or some
	other bioproduct, and a medical lathe may want
	to be able to create N2O (laughing gas) so that
	you can fill anesthetic tanks.

	This is a subtype of the datum found in maker_datum.

	For reagent conversion recipes, the modified cost list is mandatory.
	Adding "output"= to the list will change the amount produced.
*/
/datum/data/maker_product/reagent_converter
	result_typepath = /datum/reagent/water
	var/reagent_id
	var/production_amount = 50

/datum/data/maker_product/reagent_converter/New(var/obj/machinery/maker/source, var/datum/reagent/template, var/menu, var/list/modified_cost = null)
	if(ispath(template,/datum/reagent)) // typepath
		generate(source, new template(), modified_cost, destroy = 1)
	else if(istype(template))
		generate(source, template, modified_cost, destroy = 0)
	else
		del src
	menu_name = menu

/datum/data/maker_product/reagent_converter/generate(var/obj/machinery/maker/source, var/datum/reagent/template, var/list/modified_cost, var/destroy = 0)
	name = template.name
	result_typepath = template.type
	reagent_id = template.id

	if(istype(modified_cost))
		cost = modified_cost
	else
		cost = null

	if(destroy) qdel(template) // got everything we need thanks

	if(!cost) // not valid recipe
		del(src)

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
			if("output")
				production_amount = cost[entry]
				cost -= entry
			else
				if(ispath(entry,/obj/item/weapon/stock_parts))
					if(!source.stock_parts) // null stock parts list indicates it cannot accept parts
						del(src)
						return
					cost[entry] = 0 // reagent conversion only uses stock parts as catalysts
					continue

				if(cost[entry] > 0) // required reagent
					if(!(entry in source.recycleable)) // cannot be built on this machine]
						del(src)
						return
				build_total += abs(cost[entry])

	build_total = round( build_total / 100 )
	time_cost = max( 15, build_total + time_mod )
	name = "[production_amount] [name]"

/datum/data/maker_product/reagent_converter/deduct_cost(var/obj/machinery/maker/M, var/cost_multiplier = 1)
	var/datum/reagents/source = M.reagents
	if(!source) return null
	for(var/entry in cost)
		if(ispath(entry)) continue // we do not deduct
		source.remove_reagent(entry,abs(cost[entry] * cost_multiplier),1)
	return null

/datum/data/maker_product/reagent_converter/build(var/obj/machinery/maker/M, var/mob/user = null)
	if( M.stat&(BROKEN|NOPOWER) ) return 0
	if( !check_cost(M, user) )
		return 0
	if(M.build_anim)
		flick(M.build_anim,M)

	M.use_power(time_cost * M.component_time_multiplier + power_cost)
	deduct_cost(M, M.component_cost_multiplier)

	sleep(time_cost)
	M.reagents.add_reagent(reagent_id, production_amount)

	return null