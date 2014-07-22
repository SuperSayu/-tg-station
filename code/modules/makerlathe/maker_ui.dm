/obj/machinery/maker/allowed(var/mob/user)
	if(id_scrambled)
		if(junktech)
			return prob(75)
		return 1
	return ..()

// By all means add to this list
// it is currently only in the process of emagging the thing
/obj/machinery/maker/proc/technobabble()
	return text("[] detected, []...",
			pick("Spline","Power coupling polarity inversion", "Graviton flux", "Anomaly","Data breach", "Data anomaly" ,"Keyboard not", "Power loss"),
			pick("reticulating","refresh forced","recovering","recalibrating", "initalizing fallback systems", "reversing power coupling polarity","searching for host", "press any key to continue"))

/obj/machinery/maker/attackby(var/obj/item/I, var/mob/user)
	if(shorted && shock(user))
		return

	if(default_deconstruction_screwdriver(user, icon_open, icon_base, I))
		user.set_machine(src)
		update_icon()
		updateUsrDialog()
		return

	if(jammed)
		if(prob(50))
			visible_message("<span class='warning'>[user] hits [src], and [jammed] pops out of it!</span>")
			jammed.loc = loc
			jammed = null
		else
			visible_message("<span class='warning'>[user] hits [src]!</span>")
		return

	if(istype(I,/obj/item/weapon/disk/design_disk) && !stat)
		var/obj/item/weapon/disk/design_disk/D = I
		if(!board.hackable)
			user << "The dataport must be enabled to download files."
			return
		if(!board.hacked)
			user << "[src]'s extended stock chip must be enabled to download files, and you cannot reach it without taking the circuitboard out."
			return
		if(!D.blueprint)
			user << "[D] has no design on it, and you cannot find a way to upload any."
			return
		var/pth = D.blueprint.build_path

		var/datum/data/maker_product/P = new(src, pth, "Uploaded")
		if(!P)
			user << "<span class='warning'>[src] cannot create the object stored on [D].</span>"

		if(pth in researchable)
			remove_design(pth)
		researchable -= pth // a winner is you
		for(var/datum/data/maker_product/T in std_products + hack_products)
			if(T.result_typepath == pth)
				user << "[src] can already build [P.name]."
				qdel(P)
				return

		hack_products += P // extended rom chip
		all_menus["Uploaded"] = null // force rebuild cache
		user << "<span class='notice'>You successfully upload the plans for [P.name] into [src].</span>"
		return

	if(panel_open)
		if(exchange_parts(user, I))
			last_multiplier_change = world.time
			return
		else if(istype(I, /obj/item/weapon/reagent_containers/glass))
			if(beaker)
				user << "There is already a [beaker] in the overflow container slot."
				return 1
			user.drop_item()
			I.loc = src
			beaker = I
			user << "You add [I] to [src]'s overflow container slot."
			update_icon()
			updateUsrDialog()
			return 1

		else if(istype(I, /obj/item/weapon/crowbar) && !busy && !building)
			if(!board_type)
				user << "You cannot disassemble [src]."
				return 0
			busy = 1
			busy_message = "Dumping stock and shutting down..."
			drop_resource(null,delay=0) // dump all stocks
			if(beaker) beaker.loc = loc
			if(jammed) jammed.loc = loc
			user << browse(null,"window=maker")
			default_deconstruction_crowbar(I)
			return 1

		else if (stat)
			user << "[src] is offline."
			user << browse(null, "window=maker")
			return 1
		else if(busy || building)
			user << "[src] is busy."
			return 1

		else if(istype(I, /obj/item/weapon/card/emag))
			if(!board.hackable)
				user << "<span class='notice'>The dataport is disabled.</span>"
			else
				if(!id_scrambled && (req_access.len + req_one_access.len) > 0)
					id_scrambled = 1
					junktech = 1
					last_multiplier_change = world.time
					user << "<span class='warning'>[user] disables the ID checker for [src].</span>"
					busy = 1
					busy_message = technobabble()
					updateUsrDialog()
					sleep(50)
					busy = 0
				else if(!board.hacked)
					board.hacked = 1
					overdrive = 1
					last_multiplier_change = world.time
					use_power = 2
					user << "<span class='notice'>[user] forcibly enables the extended stock chip on [src]'s motherboard.</span>"
					busy = 1
					busy_message = technobabble()
					updateUsrDialog()
					sleep(50)
					for(var/entry in all_menus)
						all_menus[entry] = null // reset cache
					busy = 0
				else
					user << "Swiping [I] on the dataport seems to do nothing."
		else
			attack_hand(user)
			return 1
	else if(I.reagents && I.reagents.total_volume && I.flags&OPENCONTAINER)
		user << "You pour [I] into [src]."

		for(var/datum/reagent/R in I.reagents.reagent_list)
			if((!recycleable || (R.id in recycleable)) && reagents.total_volume < reagents.maximum_volume)
				I.reagents.trans_id_to(src,R.id,R.volume)
			else if(beaker)
				I.reagents.trans_id_to(beaker,R.id,R.volume)
			else
				I.reagents.remove_reagent(R.id)

	else if(busy || building)
		user << "[src] is busy."
	else if(stat)
		user << "[src] is offline."

	else if(istype(I,/obj/item/weapon/storage) && I.contents.len)
		var/obj/item/weapon/storage/S = I
		if((istype(S,/obj/item/weapon/storage/secure) || istype(S,/obj/item/weapon/storage/lockbox)) && S:locked)
			user << "[S] is locked, and you can't recycle it without emptying it out."
			return

		user.visible_message("<span class='notice'>[user] starts emptying [S] into [src]...</span>")
		if(do_after(user,15) && !busy)
			user.set_machine(src)
			busy = 1
			busy_message = "Dismantling, please wait..."
			updateUsrDialog()
			var/accepts = 0
			for(var/obj/item/stuff in S)
				if(!user.Adjacent(src) || stat)
					break
				if(!filter_recycling(stuff))
					continue
				S.remove_from_storage(stuff,loc)
				user_announce("<span class='notice'>[user] puts [stuff] into [src].</span>")
				decompose(stuff)
				busy = 1
				accepts++
			busy = 0
			if(accepts)
				if(S.contents.len)
					user << "<span class='notice'>You recycle some of the contents of [S].</span>"
				else
					user << "<span class='notice'>You empty [S] into [src].</span>"
				. = 1
			else
				user << "<span class='notice'>[src] rejects all of the items in [S].</span>"
		busy = 0
	else if(issilicon(user))
		user << "<span class='warning'>[src] refuses to recycle your components.</span>"
	else if(filter_recycling(I))
		user.set_machine(src)
		busy = 1
		busy_message = "Dismantling, please wait..."
		updateUsrDialog()
		user.drop_item()
		I.loc = loc
		user.visible_message("<span class='notice'>[user] puts [I] into [src].</span>")
		decompose(I)
		busy = 0
		. = 1 // prevent afterattack

	updateUsrDialog()


/obj/machinery/maker/attack_hand(var/mob/user)
	if(jammed)
		if(shorted && shock(user))
			return
		if(prob(30))
			visible_message("<span class='warning'>[user] hits [src], and [jammed] pops out of it!</span>")
			jammed.loc = loc
			jammed = null
		else
			visible_message("<span class='warning'>[user] hits [src]!</span>")
	user.set_machine(src)
	interact(user)

/obj/machinery/maker/interact(var/mob/user)
	if( !user ) user=usr

	if( !user || !user.Adjacent(src) )
		user << browse(null, "window=maker")
		return

	if( shorted )
		shock(user)

	menu(user)

/obj/machinery/maker/proc/shock(var/mob/M, var/prb = 50)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	return electrocute_mob(M, get_area(src), src, 0.7)

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
				if(beaker)
					. += "<a href='?\ref[src];reagent=[R.id];amt=[R.volume]' title='Transfer to [beaker]'>Drain</a> "
				else
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

/obj/machinery/maker/proc/menu(var/mob/user)
	if(!allowed(user))
		user << browse(null,"window=maker")
		return
	var/dat
	if(busy)
		dat = "<br><center><h3>[busy_message]</h3></center>"
	else if(jammed)
		dat = "<br><center><h3>Jam detected, please dislodge to continue</h3></center>"
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
				dat = {"
				<style>td { border:1px solid #000; vertical-align:top;} td.r { text-align:right; } th.main { border:1px solid #000; }</style>
				<table style='width:100%;'>
					[extra_buttons()]
					<tr><td style='text-align:center;' width='200' rowspan='2'>[list_menus()]</td><th class='main'>Recipes</th><th class='main' width='375'>Loaded Resources</th></tr>
					<tr><td>[list_products()]&nbsp;</td><td>[resource_summary()]</td></tr>
				</table> "}
	var/datum/browser/popup = new(user, "maker", name, 900, 450)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/maker/proc/user_announce(var/msg)
	for(var/mob/M in range(1,src))
		if(M.machine == src)
			M << msg

/obj/machinery/maker/Topic(href, list/href_list)
	if(!usr.TurfAdjacent(src))
		usr << browse(null,"window=maker")
		return
	usr.set_machine(src)

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
		busy = 1
		busy_message = "Dumping..."
		updateUsrDialog()
		var/r = href_list["reagent"]
		var/p = text2path(r) // we may be dealing with stock parts here
		if(p) r = p
		drop_resource(r, text2num(href_list["amt"]))
		busy = 0

	if("bottle" in href_list)
		if(busy || building || stat) return
		if(!queue)
			busy = 1
			busy_message = "Bottling reagent, please wait..."
			bottle_resource(href_list["bottle"], text2num(href_list["amt"]))
			busy = 0
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
			busy = 1
			allstop = 1
			autostart_queue = 0
			busy_message = "User aborted build queue, please wait..." // cannot actually stop the build process currently

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

		else server_connect()

	if("sync" in href_list)
		if(stat) usr << "[src] is offline."
		else if(busy || building) usr << "[src] is busy."

		else research_sync()

	if("stock" in href_list)
		recycle_stock_parts = !recycle_stock_parts
	updateUsrDialog()