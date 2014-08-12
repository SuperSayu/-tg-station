/obj/machinery/maker/examine()
	..()
	if(!stat && busy && busy_message && get_dist(usr,src) <= 1)
		usr << "The display is showing a message in large letters: <i>[busy_message]</i>"

// user_announce is like updateUsrDialog() except for visible/audible messages.
// Only those users who are both adjacent and paying attention will notice them.
//
/obj/machinery/maker/proc/user_announce(var/msg, var/blind_msg)
	for(var/mob/M in range(1,src))
		if(M.machine == src)
			M.show_message(msg,1, blind_msg, 2)

/obj/machinery/maker/proc/make_busy(var/msg, var/time, var/announce, var/blind_announce) // todo add sound maybe
	if(announce || blind_announce) user_announce(announce,blind_announce)
	if(busy || !msg)
		return
	busy = 1
	busy_message = msg
	updateUsrDialog()
	if(time)
		sleep(time)
		busy_done()

/obj/machinery/maker/proc/busy_done(var/announce, var/blind_announce)
	if(announce || blind_announce) user_announce(announce, blind_announce)
	busy = 0
	updateUsrDialog()

/obj/machinery/maker/allowed(var/mob/user)
	if(id_scrambled)
		if(junktech)
			return prob(75)
		return 1
	return ..()

/obj/machinery/maker/proc/shock(var/mob/M, var/prb = 50)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	return electrocute_mob(M, get_area(src), src, 0.7)

// By all means add to this list
// it is currently only used in the process of emagging the thing
/obj/machinery/maker/proc/technobabble()
	return text("[] detected, []...",
			pick("Spline","Power coupling polarity inversion", "Graviton flux", "Anomaly","Data breach", "Data anomaly" ,"Keyboard not", "Power loss"),
			pick("reticulating","refresh forced","recovering","recalibrating", "initalizing fallback systems", "reversing power coupling polarity","searching for host", "press any key to continue"))

/obj/machinery/maker/interact(var/mob/user)
	if( !user ) user=usr

	if( !user || !user.Adjacent(src) )
		user << browse(null, "window=maker")
		return

	if( shorted )
		shock(user)

	var/datum/browser/popup = new(user, "maker", name, 900, 450)
	popup.set_content( menu(user) )
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/*
	Stored reagents, stock parts, and links to eject/extrude/bottle them.
*/
/obj/machinery/maker/proc/resource_summary()
	var/global/list/text_cache = list()
	. = "<small>"
	if(!reagents.total_volume && !length(stock_parts))
		. += " &nbsp; <i>None.</i>"
	else
		. += "<table style='width:100%'><tr><th>Resource</th><th>Quantity</th><th>Removal Options</th></tr>"
		var/bottle = 0
		var/datum/reagent/G = reagents.has_reagent("glass",BOTTLE_GLASS_COST)
		if(G)
			bottle = round(G.volume / BOTTLE_GLASS_COST) // maximum number of bottles of this reagent to bottle
		for(var/datum/reagent/R in reagents.reagent_list)
			var/v = R.volume
			if(v >= 10000)
				v = "[round(R.volume / 1000, 0.1)]k"
			if(R.resource_item && R.volume >= R.resource_amt)
				var/ratio = round(R.volume / R.resource_amt)
				. += "<tr><td>[R.name]</td><td class='r'>[v]</td><td><a href='?\ref[src];reagent=[R.id];amt=[R.resource_amt]' title='Extrude a sheet of this material'>1</a>"
				for(var/qty in list(5,10,25,50))
					if(qty > ratio) break
					. += " <a href='?\ref[src];reagent=[R.id];amt=[R.resource_amt * qty]' title='Extrude [qty] sheets of this material'>[qty]</a>"
				. += "</td></tr>"
			else
				. += "<tr><td>[R.name]</td><td class='r'>[v]</td><td>"
				if(!R.resource_item)
					if(bottle)
						var/max_qty = round(R.volume / 30)
						if((R.volume % 30) != 0) max_qty++ // leftovers
						max_qty = min(max_qty,bottle)

						. += "<a href='?\ref[src];bottle=[R.id];amt=1' title='Fill a glass bottle with this reagent'>1</a> "
						for(var/qty in list(3,5,10))
							if(qty > max_qty) break
							. += "<a href='?\ref[src];bottle=[R.id];amt=[qty]' title='Fill [qty] glass bottles with this reagent'>[qty]</a> "
					else if(!recycleable || ("glass" in recycleable))
						. += "<span class='linkOff' title='Glass is required to bottle loose reagents'>Bottle</span> "
				if(beaker && !R.resource_item)
					. += "<a href='?\ref[src];reagent=[R.id];amt=[R.volume]' title='Transfer to [beaker]'>Drain</a> "
				else
					if(!R.resource_item)
						. += "<span class='linkOff' title='Open the panel and insert a container to drain reagents'>Drain</span> "
					. += " <a href='?\ref[src];reagent=[R.id];amt=[R.volume]' title='Discard excess material'>Dump</a></td></tr>"

		var/list/stock = list()
		for(var/obj/item/weapon/stock_parts/S in stock_parts)
			stock[S.type]++
		for(var/entry in stock)
			. += "<tr><td>[stock_names[entry]]</td><td class='r'>[stock[entry]]</td><td><a href='?\ref[src];reagent=[entry];amt=1' title='Eject one of this type of component'>Eject</a> "
			for(var/qty in list(3,5,10))
				if(qty > stock[entry]) break
				. += "<a href='?\ref[src];reagent=[entry];amt=[qty]' title='Eject [qty] of this type of component'>[qty]</a> "
			// todo recycle component button only if you can handle the resources present - too complicated of a check to do every time I think
		. += "</table>"
	. += "</small>"

/obj/machinery/maker/proc/list_products()
	var/list/L = all_menus[current_menu]
	. = ""
	for(var/datum/data/maker_product/P in L)
		. += "[P.build_desc(src)]<br>" // build_desc caches the description unless a value has changed (cost/time multipliers changed, overdrive, junktech, etc)

/obj/machinery/maker/proc/list_menus()
	if(queue && show_queue)
		if(building)
			. = "Build Queue - Running<br>"
			if(queue.len)
				. += " <a href='?\ref[src];allstop' title='Stop build queue'>Stop</a> <a href='?\ref[src];clearqueue' title='Remove all from queue'>Clear</a><hr>"
				. += "<ol style='text-align:left;'>"
				for(var/i = 1; i<=queue.len; i++)
					var/datum/data/maker_product/P = queue[i]
					if(istype(P))
						. += "<li style='white-space:nowrap;'><a href='?\ref[src];dequeue=[i]' title='Remove [P] from the queue'>[P]</a></li>"
					else if(istext(P))
						var/n
						var/datum/reagent/R = chemical_reagents_list[P]
						if(R)
							n = R.name
						else
							n = "unknown"
						. += "<li style='white-space:nowrap;'><a href='?\ref[src];dequeue=[i]' title='Remove [n] bottle from the queue'>Bottle ([n])</a></li>"
				. += "</ol>"
			else
				// stop button is not meaningful since we cannot cancel the running process
				. += " <span class='linkOff' title='Stop build queue'>Stop</span> <span class='linkOff' title='Remove all from queue'>Clear</span><hr>"
		else if(queue.len)
			. = "Build Queue - Stopped<br>"
			. += " <a href='?\ref[src];startqueue' title='Process build queue'>Start</a> <a href='?\ref[src];clearqueue' title='Remove all from queue'>Clear</a><hr>"
			. += "<ol style='text-align:left;'>"
			for(var/i = 1; i<=queue.len; i++)
				var/datum/data/maker_product/P = queue[i]
				if(istype(P))
					. += "<li style='white-space:nowrap;'><a href='?\ref[src];dequeue=[i]'>[P]</a></li>"
				else if(istext(P))
					var/n
					var/datum/reagent/R = chemical_reagents_list[P]
					if(R)
						n = R.name
					else
						n = "unknown"
					. += "<li style='white-space:nowrap;'><a href='?\ref[src];dequeue=[i]'>Bottle ([n])</a></li>"
			. += "</ol>"
		else
			. = "Build Queue - Empty<br><span class='linkOff' title='Process build queue'>Start</span> <span class='linkOff' title='Remove all from queue'>Clear</span><hr>"
	else
		if(main_menu_name)
			if(!current_menu)
				. = "<span class='linkOff' title='The default menu is currently selected.'>[main_menu_name]</span>"
			else
				. = "<a href='?\ref[src];menu'>[main_menu_name]</a>"
			. += "<hr>"

		for(var/entry in all_menus)
			if(!entry) continue
			if(current_menu != entry)
				. += "<a href='?\ref[src];menu=[entry]'>[entry]</a><br>"
			else
				. += "<span class='linkOff' title='This is the current menu.'>[entry]</span><br>"

//
// Adds an extra row of buttons if this machine has special features:
// Queue, research sync, or stock parts recycling
//
/obj/machinery/maker/proc/extra_buttons()
	if(!length(researchable) && !stock_parts && !queue)
		return null // no relevant buttons
	var/queue_button = "&nbsp;"
	var/rnd_button = "&nbsp;"
	var/stock_button = "&nbsp;"
	if(queue)
		if(show_queue)
			queue_button = "<a href='?\ref[src];showqueue' title='Show menu in queue pane'>Show Menu</a>"
		else
			var/len = ""
			if(queue.len)
				len = "([queue.len])"
			queue_button = "<a href='?\ref[src];showqueue' title='Show queue in menu pane'>Show Queue [len]</a>"
		if(autostart_queue)
			queue_button += " <a href='?\ref[src];autoqueue' title='Build queue will automatically process'>Auto Build</a>"
		else
			queue_button += " <a href='?\ref[src];autoqueue' title='Build queue must be manually started'>Auto Off</a>"
	if(length(researchable))
		if(building)
			rnd_button = "Build queue is processing..."
		if(server)
			rnd_button = "<a href='?\ref[src];sync' title='Download project files from [server]'>Sync Database with [server]</a>"
		else
			rnd_button = "<a href='?\ref[src];server'>Connect to Research Server</a>"
	else if(building)
		rnd_button = "Build queue is processing..."
	if(stock_parts)
		if(recycle_stock_parts)
			stock_button = "<a href='?\ref[src];stock'>Recycling stock parts</a>"
		else
			stock_button = "<a href='?\ref[src];stock'>Storing stock parts</a>"
	return "<tr><td>[queue_button]</td><td>[rnd_button]</td><td>[stock_button]</td></tr>"

//
// The actual interact menu
//
/obj/machinery/maker/proc/menu(var/mob/user)
	var/dat
	if(busy)
		dat = "<br><center><h3>[busy_message]</h3></center>"
	else if(jammed)
		dat = "<br><center><h3>Jam detected, please dislodge to continue</h3></center>"
	else if(!allowed(user))
		dat = "<br><center><h3 style='color:red'>ACCESS DENIED</h3></center>"
	else
		build_menu_cache()
		if(panel_open)
			dat = wires.GetInteractWindow()
		else
			if(stat&(BROKEN|NOPOWER))
				user << "[src] is offline."
				user << browse(null, "window=maker")
				return
			else
				var/add_all_button = ""
				if(queue)
					add_all_button = " <a href='?\ref[src];add_all' title='Add all items in this menu to the queue'>Add All</a>"
				dat = {"
				<style>td { border:1px solid #000; vertical-align:top;} td.r { text-align:right; } th.main { border:1px solid #000; }</style>
				<table style='width:100%;'>
					[extra_buttons()]
					<tr><td style='text-align:center;' width='200' rowspan='2'>[list_menus()]</td><th class='main'>Recipes [add_all_button]</th><th class='main' width='375'>Loaded Resources</th></tr>
					<tr><td>[list_products()]&nbsp;</td><td>[resource_summary()]</td></tr>
				</table> "}
	return dat

/obj/machinery/maker/Topic(href, list/href_list)
	if(!usr.TurfAdjacent(src))
		usr << browse(null,"window=maker")
		return
	usr.set_machine(src)
	if(!allowed(usr))
		make_busy("ACCESS DENIED", 30, "[src] beeps and flashes red lights at [usr].","You hear a beep.")
		return

	if("menu" in href_list)
		if(stat || busy) return
		if(panel_open)
			usr << "Close the panel first."
			updateUsrDialog()
			return
		current_menu = href_list["menu"]
		if(current_menu == "") current_menu = null // I don't know why it is doing this

	if("reagent" in href_list)
		if(busy || building || stat) return

		make_busy(sheet_out_msg)
		var/r = href_list["reagent"]
		var/p = text2path(r) // we may be dealing with stock parts here
		if(p) r = p
		drop_resource(r, text2num(href_list["amt"]))
		busy_done()

	if("bottle" in href_list)
		if(busy || building || stat) return
		if(!queue)
			make_busy(bottle_out_msg)
			bottle_resource(href_list["bottle"], text2num(href_list["amt"]))
			busy_done()
		else
			var/rid = href_list["bottle"]
			for(var/i in 1 to text2num(href_list["amt"]))
				enqueue(rid) // add reagent id to queue and it will spit out bottles

	if("build" in href_list)
		if(stat || busy) return
		if(panel_open)
			usr << "Close the panel first."
			updateUsrDialog()
			return
		if(jammed)
			usr << "<span class='warning'>[jammed] is stuck in [src]!  You will have to get it out before you can build anything.</span>"
		else
			enqueue( locate(href_list["build"]) )

	if("add_all" in href_list)
		if(stat || busy) return
		build_menu_cache() // just in case
		for(var/datum/data/maker_product/P in all_menus[current_menu])
			enqueue(P)

	if("showqueue" in href_list)
		show_queue = !show_queue

	if("autoqueue" in href_list)
		autostart_queue = !autostart_queue

	if("startqueue" in href_list)
		if(!building && queue.len)
			spawn process_queue()
			return

	if("clearqueue" in href_list)
		if(stat || busy) return
		queue = list()

	if("dequeue" in href_list)
		var/n = text2num(href_list["dequeue"])
		if(n <= queue.len && n > 0)
			queue.Cut(n,n+1)

	if("allstop" in href_list)
		if(building)
			allstop = 1
			autostart_queue = 0
			make_busy("User aborted build queue, please wait...") // cannot actually stop the build process currently

	if("beaker" in href_list)
		if(panel_open && beaker)
			beaker.loc = loc
			usr.put_in_hands(beaker)
			beaker = null

	if("unjam" in href_list)
		if(panel_open && jammed)
			jammed.loc = loc
			usr.put_in_hands(jammed)
			visible_message("[usr] successfully removes [jammed] from [src]!")
			jammed = null

	if("server" in href_list)
		if(stat ) usr << "[src] is offline."
		else if(busy || building) usr << "[src] is busy."

		else
			server_connect()
			return // uses make_busy which updates the dialog

	if("sync" in href_list)
		if(stat) usr << "[src] is offline."
		else if(busy || building) usr << "[src] is busy."

		else
			research_sync()
			return // uses make_busy which updates the dialog

	if("stock" in href_list)
		recycle_stock_parts = !recycle_stock_parts
	updateUsrDialog()