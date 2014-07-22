

/obj/machinery/maker
	name = "autolathe"
	desc = "It produces items."
	flags = NOREACT
	density = 1
	anchored = 1

	icon_state = "autolathe"
	var/icon_base = "autolathe"
	var/icon_open = "autolathe_t"
	var/build_anim = "autolathe_n"
	var/default_insert_anim = "autolathe_o"
	// there is also an insert_anim(item) proc
	// if you have different animations for inserting different
	// stacks or items, you can override it.

	var/busy = 0
	var/busy_message = "" // Takes over the screen with a message while busy
	var/obj/item/jammed = null
	reliability = 100
	var/current_menu = null
	var/main_menu_name = "Main Menu"

	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/obj/item/weapon/circuitboard/maker/board = null

	var/board_type = null // /obj/item/weapon/circuitboard/maker		// board type - must be set to allow disassembly!
	var/beaker_type = /obj/item/weapon/reagent_containers/glass/bucket	// if set, the beaker will be autocreated for map objects
	var/list/starting_reagents	= list()								// map objects at initialize time may get some starting resources


	// Contain a cached list by menu name, taking into account hacked/emagged:
	// the main menu is null
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

	var/list/junk_recipes		= list() // trash generated when malfunctioning - no menus here
	var/list/researchable		= list() // available once researched - go into std products list

	var/list/recycleable		= list() // acceptable reagents to recieve from recycled objects, eg, just iron and glass.  Does not handle stock parts.
	component_parts				= list() // generic machine var

	// For queue and stock parts lists, if the value is null,
	// that functionality is disabled (queues or handling stock parts in item recipes)

	var/list/queue				= list()
	var/list/stock_parts		= list()
	var/global/list/stock_names	= list() // name cache by part type - sort of awkward but acceptable

	var/recycle_stock_parts		= 0 	 // ui toggle for storing or recycling stock parts - you do not need to change this
	var/show_queue				= 0		 // ui toggle for showing queue instead of menus
	var/autostart_queue			= 1		 // toggle for auto-building items vs queueing them
	var/building				= 0		 // queue is running
	var/allstop					= 0

	var/component_cost_multiplier = 1
	var/component_time_multiplier = 1

	var/obj/machinery/r_n_d/server/server // for downloading plans

	var/datum/wires/maker/wires
	var/wire_type = /datum/wires/maker

	// wire status
	var/id_scrambled = 0// no id required, random failures with junktech
	var/shorted = 0		// shocky
	var/overdrive = 0	// high speed, high power use, heat generation
	var/junktech = 0	// reliability plummets, machine may jam, wastes materials
	var/last_multiplier_change = 0 // set this to the current time when something affecting costs changes, it will recalculate entries


/obj/machinery/maker/New()
	wires = new wire_type(src)

	default_parts()
	std_products  = initialize_products(std_products)
	hack_products = initialize_products(hack_products)
	junk_recipes  = initialize_products(junk_recipes, 0)
	if(!main_menu_name && !current_menu)
		current_menu = all_menus[1]

	power_change()
	..()
	update_icon()

/obj/machinery/maker/initialize()
	..()
	if(ispath(beaker_type, /obj/item))
		beaker = new beaker_type(src)
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
			else if(ispath(entry, /obj/item))
				if(istype(menu[entry],/list))
					result += new/datum/data/maker_product(src, entry, c_menu, menu[entry])
				else if(istext(menu[entry]))
					var/datum/data/maker_product/P = new(src, entry, c_menu)
					P.name += " ([menu[entry]])" // eg /obj/item/stack/cable_coil = "red" -> Cable Coil (red)
					result += P
				else
					result += new/datum/data/maker_product(src, entry, c_menu)
			else if(ispath(entry, /datum/reagent))
				// Note that a modified cost list is required here
				result += new/datum/data/maker_product/reagent_converter(src, entry, c_menu, menu[entry])
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
		if(ispath(entry,/obj/item/weapon/stock_parts) && amt > 0 && !isnull(stock_parts))
			while(amt--)
				var/obj/O = new entry(src)
				stock_parts += O
				if(!(O.type in stock_names))
					stock_names[O.type] = O.name
			continue

		if(amt == 0) amt = -100
		if(amt < 0) amt = round(rand(0, -amt),10)
		reagents.add_reagent(entry,amt)

/obj/machinery/maker/proc/default_parts()
	if(component_parts.len) return
	if(board_type)
		board = new board_type(null)
	else // if null, cannot be disassembled
		board = new /obj/item/weapon/circuitboard/maker() // needed
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
	var/resource_max = rating * 2000 * 50 * 1.5
	if(reagents)
		reagents.maximum_volume = resource_max
		if(reagents.total_volume > reagents.maximum_volume)
			reagents.remove_any(resource_max - reagents.total_volume)
	else
		create_reagents(resource_max)

	rating = 1
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		rating *= (1.1 - 0.1 * M.rating) // rating 1 -> 100%, 2->95, etc
		reliability = 100 + 5*M.rating

	component_cost_multiplier = rating
	component_time_multiplier = rating * 2 // time also goes down as component cost goes down

	if(overdrive)
		component_time_multiplier *= 0.75
		reliability -= 5
	if(junktech)
		reliability -= 25
	if(emagged)
		reliability -= 10

	board = locate() in component_parts
	for(var/entry in all_menus)
		all_menus[entry] = null

/obj/machinery/maker/proc/filter_recycling(var/obj/item/I, var/quiet = 0)
	if(!reagents || reagents.total_volume >= reagents.maximum_volume)
		return 0
	if(!istype(I))
		if(I && !quiet)
			user_announce("<span class='notice'>There is no way to recycle [I].</span>")
		return 0

	var/list/cost = I.determine_cost() // will eventually just be I.maker_cost but we need this for now
	if(!cost)
		if(!quiet)
			user_announce("<span class='notice'>There is no way to recycle [I].</span>")
		return 0

	if(istype(I,/obj/item/weapon/stock_parts) && stock_parts && !recycle_stock_parts)
		return 1 // indicates we will store this part instead of recycling it

	if(recycleable) // null -> no filter on acceptable reagents
		var/static/list/cost_modifiers = list("output","power","time")
		cost -= recycleable
		cost -= cost_modifiers
		for(var/entry in cost)
			// recycleable list is acceptable reagents, if it's not recycleable, don't accept it
			// stock parts are the exception here, if you accept any parts, accept them all
			// This is determined by whether the stock parts list exists or not
			if(ispath(entry, /obj/item/weapon/stock_parts))
				if(isnull(stock_parts) && cost[entry] > 0)
					if(!quiet)
						user_announce("<span class='warning'>[src] cannot recycle components, and so refuses [I].</span>")
					return 0
				continue
			if(cost[entry] > 0) // do not count fill reagents and build-only costs
				if(!quiet)
					user_announce("<span class='warning'>[src] cannot recycle [entry], and so refuses [I].</span>")
				return 0

	return 1

// if you want different insert anims for different objects, override this
/obj/machinery/maker/proc/insert_anim(var/obj/item/I)
	if(default_insert_anim)
		flick(default_insert_anim,src)
	sleep(10)

/obj/machinery/maker/proc/decompose(var/obj/item/I)
	if(!filter_recycling(I))
		return 0

	I.loc = src
	insert_anim(I) // you can make different insert animations if you want
	var/keep = I.maker_disassemble(src) // return 1 if the piece is kept inside, eg, stock parts
	if(!keep && I && I.loc == src) // otherwise if it still exists, eg, stacks
		I.loc = loc				// leave it out for the user
	return 1

/obj/machinery/maker/proc/drop_resource(var/type, var/amount = 0, var/delay = 1)
	if(type == null)
		for(var/datum/reagent/entry in reagents.reagent_list)
			drop_resource(entry.id, amount)
		for(var/obj/item/weapon/stock_parts/P in stock_parts)
			P.loc = loc
		stock_parts = list()
		return

	if(ispath(type, /obj/item/weapon/stock_parts))
		for(var/obj/O in stock_parts)
			if(O.type == type)
				O.loc = loc
				stock_parts -= O
				amount--
				if(amount <= 0)
					break
		return

	var/datum/reagent/R = reagents.has_reagent(type)
	if(!R) return

	if(!amount) amount = R.volume
	amount = min(amount, R.volume)

	var/junk = 0
	if(R.resource_item)
		var/amt_per_sheet = R.resource_amt

		while(amount >= amt_per_sheet)
			var/obj/item/stack/S = new R.resource_item(src)
			S.amount = min(S.max_amount, round(amount / amt_per_sheet))
			if(delay)
				if(build_anim)
					flick(build_anim,src)
				sleep(S.amount)
			var/amt_taken = S.amount * amt_per_sheet
			amount -= amt_taken
			R.volume -= amt_taken

			if(!prob(reliability))
				jammed = S
				visible_message("[S] becomes jammed in [src]!")
				junk = 1
				break
			S.loc = loc

	reagents.update_total()
	if(amount > 0 && !junk)
		if(!beaker)
			reagents.remove_reagent(type,amount)
		else
			reagents.trans_id_to(beaker,type, amount)

/obj/machinery/maker/proc/bottle_resource(var/type, var/amount = 0)
	var/datum/reagent/G = reagents.has_reagent("glass",BOTTLE_GLASS_COST)
	if(!G)
		user_announce("<span class='warning'>[src] does not have enough glass to bottle anything.</span>")
		return
	var/datum/reagent/R = reagents.has_reagent(type)
	if(!R)
		R = chemical_reagents_list[type]
		user_announce("<span class='warning'>[src] does not have any [R.name] to bottle.</span>")
		return // when the dialog updates that will be clear enough
	amount = min(round(G.volume / BOTTLE_GLASS_COST), round(R.volume / 30)+(R.volume % 30?1:0), amount)
	if(!amount)
		return

	building = 1
	updateUsrDialog() // show the busy message

	while(amount-- > 0)
		if(build_anim)
			flick(build_anim,src)
		sleep(15)
		G.volume -= BOTTLE_GLASS_COST
		var/amt = min(30, R.volume)
		R.volume -= amt
		var/obj/item/weapon/reagent_containers/glass/bottle/B = new(src)
		B.reagents.add_reagent(type, amt)
		B.name = "Bottle ([R.name] [amt]u)"
		if(!prob(reliability))
			jammed = B
			visible_message("<span class='warning'>[B] gets jammed in [src]!</span>")
			break
		B.loc = loc
	building = 0
	reagents.update_total()


/obj/machinery/maker/proc/enqueue(var/datum/data/maker_product/P)
	if(istype(P))
		if(!(P in all_menus[current_menu]))
			return
		if(!P.check_cost(src) && !length(queue)) return
		if(!queue)
			busy = 1
			busy_message = "Synthesizing, please wait..."
			updateUsrDialog()
			make(P)
			busy = 0
			return
		queue.Add(P)
	else if(istext(P) && reagents.has_reagent(P))
		if(!queue)
			busy = 1
			busy_message = "Bottling reagent, please wait..."
			updateUsrDialog()
			bottle_resource(P,1)
			busy = 0
			return
		queue.Add(P)

	if(!building && autostart_queue)
		building = 1
		spawn process_queue()

/obj/machinery/maker/proc/process_queue()
	while(queue.len && !allstop && !jammed && !stat)
		var/datum/data/maker_product/P = queue[1]
		if(istype(P))
			if(!P.check_cost(src))
				break
			building = 1
			queue.Cut(1,2)
			if(show_queue)
				updateUsrDialog()
			make(P)
		else if(istext(P))
			var/datum/reagent/R = reagents.has_reagent(P)
			if(!R) break
			building = 1
			queue.Cut(1,2)
			if(show_queue)
				updateUsrDialog()
			bottle_resource(P,1)

	busy = 0
	allstop = 0
	building = 0
	updateUsrDialog()

/obj/machinery/maker/proc/make(var/datum/data/maker_product/P)
	if(!istype(P))
		return
	var/junk = 0
	if(!prob(reliability))
		P.deduct_cost(src, (100 - reliability) / 200) // waste resources
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
	building = 1
	updateUsrDialog()
	var/obj/item/result = P.build(src)
	building = 0

	use_power = 1 + overdrive
	if(!result)
		return
	else if(junk || !prob(reliability))
		jammed = result
		jammed.loc = src
		user_announce("\A [jammed] gets stuck in [src]!")
	else if(istype(result,/list))
		user_announce("[src] produces several items at once.")
	else
		user_announce("[src] produces \a [result].")
