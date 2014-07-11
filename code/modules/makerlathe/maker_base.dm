
/obj/machinery/maker
	name = "autolathe"
	desc = "It produces items."
	icon_state = "autolathe"
	flags = NOREACT
	density = 1
	anchored = 1

	var/busy = 0
	var/obj/item/jammed = null
	reliability = 100
	var/current_menu = null

	var/obj/item/weapon/reagent_containers/glass/beaker = null

	// Contain a cached list by menu name, taking into account hacked/emagged:
	// all_menus[null] = list(main menu)
	// all_items[menu1 name] = list(menu1)
	var/list/all_menus			= list() // list cache

	// At compile time, these product lists contain typepaths and strings:
	// items in main menu
	// menu1 name, menu1 items
	// menu2 name, menu2 items
	// etc
	// These are consulted when building the all_menus list.

	var/list/std_products		= list() // always available
	var/list/server_products	= list() // synched from database
	var/list/hack_products		= list() // available when board hacked
	var/list/researchable		= list() // available once researched - go into std products
	var/list/junk_recipes		= list() // trash generated when malfunctioning

	var/list/recycleable		= list() // types of acceptable reagents to recieve from recycled objects, eg, just iron and glass
	var/list/starting_reagents	= list() // map objects at initialize time may get some starting resources
	component_parts				= list() //


	var/component_cost_multiplier = 1
	var/component_time_multiplier = 1

	var/obj/item/weapon/circuitboard/maker/board
	var/board_type = /obj/item/weapon/circuitboard/maker // subtypes of the machine have subtypes of boards
	var/datum/wires/maker/wires
	var/wire_type = /datum/wires/maker
	var/build_anim = "autolathe_n"

	// wire status
	var/id_scrambled = 0// no id required, random failures with junktech
	var/shorted = 0		// shocky
	var/overdrive = 0	// high speed, high power use, heat generation
	var/junktech = 0	// reliability plummets, machine may jam, wastes materials


/obj/machinery/maker/New()
	wires = new wire_type(src)

	default_parts()
	std_products  = initialize_products(std_products)
	hack_products = initialize_products(hack_products)
	junk_recipes  = initialize_products(junk_recipes, 0)

	..()

/obj/machinery/maker/initialize()
	..()
	default_reagents()

/obj/machinery/maker/proc/initialize_products(var/list/menu, var/allow_menus = 1)
	if(!menu) return null
	var/c_menu = null
	var/list/result = list()
	if(istype(menu) && menu.len)
		for(var/entry in menu)
			if(istext(entry) && allow_menus)
				c_menu = entry
				all_menus |= entry
			else if(ispath(entry))
				if(istype(menu[entry],/list))
					result += new/datum/data/maker_product(src, entry, c_menu, menu[entry])
				else
					result += new/datum/data/maker_product(src, entry, c_menu)
	return result


/obj/machinery/maker/proc/build_menu_cache()
	if(all_menus[current_menu] != null)
		return
	all_menus[current_menu] = list()
	for(var/datum/data/maker_product/M in std_products)
		if(M.menu_name == current_menu)
			all_menus[current_menu] += M
	if(board.hacked)
		for(var/datum/data/maker_product/M in hack_products)
			if(M.menu_name == current_menu)
				all_menus[current_menu] += M


/obj/machinery/maker/proc/default_reagents()
	for(var/entry in starting_reagents)
		var/amt = starting_reagents[entry]
		if(amt <= 0) amt = 100
		reagents.add_reagent(entry,amt)

/obj/machinery/maker/proc/default_parts()
	if(component_parts.len) return
	board = new board_type(null)
	component_parts += board
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/maker/RefreshParts()
	var/rating = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		rating += MB.rating
	var/resource_max = rating * 25000
	if(reagents)
		reagents.maximum_volume = resource_max
		if(reagents.total_volume > reagents.maximum_volume)
			reagents.remove_any(resource_max - reagents.total_volume)
	else
		create_reagents(resource_max)

	rating = 1
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		rating *= (1.05 - 0.05 * M.rating) // rating 1 -> 100%, 2->95, etc
		reliability = 100 + 5*M.rating

	component_cost_multiplier = rating			// .95, .90, .85
	component_time_multiplier = rating * rating // .90, .81, .72

	if(overdrive)
		component_time_multiplier *= 0.75
		reliability -= 5
	if(junktech)
		reliability -= 25
	if(emagged)
		reliability -= 10

	for(var/datum/data/maker_product/P in std_products + hack_products)
		P.recalculate(component_cost_multiplier, component_time_multiplier)
	board = locate() in component_parts
	for(var/entry in all_menus)
		all_menus[entry] = null

/obj/machinery/maker/proc/filter_recycling(var/obj/item/I)
	if(!reagents || reagents.total_volume >= reagents.maximum_volume)
		return 0
	if(!istype(I) || !I.maker_cost) return
	if(!recycleable) // null -> anything
		return 1
	var/list/results = I.maker_cost - recycleable - "time"
	if(istype(results))
		for(var/entry in results) // recycleable list is acceptable reagents, if it's not recycleable, don't accept it
			usr << "[src] cannot recycle [entry]"
			return 0
	return 1

// if you want different insert anims for different objects, override this
/obj/machinery/maker/proc/insert_anim(var/obj/item/I)
	flick("autolathe_o",src)
	sleep(10)

/obj/machinery/maker/proc/decompose(var/obj/item/I)
	if(!filter_recycling(I))
		return 0
	I.loc = src
	insert_anim(I)

	for(var/entry in I.maker_cost - "time")
		if(reagents.total_volume >= reagents.maximum_volume)
			return 0
		reagents.add_reagent(entry,I.maker_cost[entry])

	// reagents get recycled, stored, or dumped
	if(I.reagents && I.reagents.total_volume)
		for(var/datum/reagent/R in I.reagents.reagent_list)
			if(reagents.total_volume < reagents.maximum_volume)
				if(R.id in recycleable)
					I.reagents.trans_id_to(src,R.id,R.volume)
		//Overflow cup
		if(I.reagents.total_volume)
			if(beaker)
				I.reagents.trans_to(beaker, I.reagents.total_volume)
			else
				reliability-- // no overflow cup means stuff is sloshing around in there
	qdel(I)
	return 1



/obj/machinery/maker/proc/drop_resource(var/type, var/obj/container, var/amount = 0)
	if(type == null)
		for(var/datum/reagent/entry in reagents.reagent_list)
			drop_resource(entry.id, container, amount)
	var/datum/reagent/R = reagents.has_reagent(type)
	if(!R) return
	if(!R.resource_item && !container)
		reagents.remove_reagent(type)
		return

/obj/machinery/maker/proc/make(var/datum/data/maker_product/P)
	if(!istype(P) || !(P in all_menus[current_menu]))
		return
	var/junk = 0
	if(!prob(reliability))
		P.deduct_cost(src) // waste resources -- todo, probably less than this
		if(!prob(reliability) && length(junk_recipes))
			P = pick(junk_recipes) // junk product
			junk = 1
	if(overdrive)
		var/turf/simulated/T = loc
		if(istype(T) && T.air)
			var/datum/gas_mixture/local = T.air.remove_ratio(0.25)
			local.temperature += P.time_cost // more resource use -> more time spent & more hot air
			T.assume_air(local)
			air_update_turf()
	use_power = 2
	busy = 1
	if(build_anim)
		flick(build_anim,src)
	use_power(P.time_cost)
	var/obj/item/result = P.build(src)
	busy = 0
	use_power = 1 + overdrive
	if(!result)
		return
	else if(!prob(reliability))
		jammed = result
		jammed.loc = src
		visible_message("[jammed] gets stuck in [src]!")
	else if(junk)
		visible_message("[src] spits out \a [result]!")
	else
		visible_message("[src] produces \a [result].")
