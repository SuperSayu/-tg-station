/obj/machinery/maker/allowed(var/mob/user)
	if(id_scrambled)
		if(junktech)
			return prob(75)
		return 1
	return ..()

/obj/machinery/maker/attackby(var/obj/item/I, var/mob/user)
	if(shorted && shock(user))
		return

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", I))
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
		if(!D.blueprint)
			user << "[D] has no design on it, and you cannot find a way to upload any."
			return
		var/pth = D.blueprint.build_path
		if(!(pth in researchable))
			user << "It looks like the blueprint is not compatable with this machine."
			return
		var/res = researchable[pth] // if null or text, no designs yet exist
		if(!res || istext(res))
			var/datum/data/maker_product/P = new(src, pth, res)
			std_products += P
			researchable[pth] = P
			all_menus[res] = null // force rebuild cache
		return

	if(panel_open)
		if(exchange_parts(user, I))
			return
		else if(istype(I, /obj/item/weapon/reagent_containers/glass))
			if(beaker)
				user << "There is already a [beaker] in the overflow container slot."
				return
			user.drop_item()
			I.loc = src
			beaker = I
			user << "You add [I] to [src]'s overflow container slot."
			return

		else if(istype(I, /obj/item/weapon/crowbar))
			drop_resource(null) // dump all stocks
			if(beaker) beaker.loc = loc
			if(jammed) jammed.loc = loc
			default_deconstruction_crowbar(I)
			return 1

		else if (stat || busy)
			return 1

		else if(istype(I, /obj/item/weapon/card/emag))
			if(!board.hackable)
				user << "<span class='notice'>The dataport is disabled.</span>"
			else
				if(!id_scrambled && (req_access.len + req_one_access.len) > 0)
					id_scrambled = 1
					junktech = 1
					user << "<span class='warning'>[user] disables the ID checker for [src].</span>"
					busy = 1
					spawn(50)
						busy = 0
				else if(!board.hacked)
					board.hacked = 1
					overdrive = 1
					use_power = 2
					user << "<span class='notice'>[user] forcibly enables the extended stock chip on [src]'s motherboard.</span>"
					busy = 1
					spawn(50)
						busy = 0
				else
					user << "Swiping [I] on the dataport seems to do nothing."
		else
			attack_hand(user)
			return 1

	else if(busy)
		user << "[src] is busy."
	else if(istype(I,/obj/item/weapon/storage) && I.contents.len)
		var/obj/item/weapon/storage/S = I
		if((istype(S,/obj/item/weapon/storage/secure) || istype(S,/obj/item/weapon/storage/lockbox)) && S:locked)
			user << "[S] is locked, and you can't recycle it without emptying it out."
			return
		user.visible_message("<span class='notice'>[user] starts emptying [S] into [src]...</span>")
		if(do_after(user,10))
			busy = 1
			var/rejects = 0
			var/accepts = 0
			for(var/obj/item/stuff in S)
				if(!user.Adjacent(src))
					break
				if(!filter_recycling(stuff))
					rejects++
					continue
				S.remove_from_storage(stuff,loc)
				user.visible_message("<span class='notice'>[user] puts [stuff] into [src].</span>")
				decompose(stuff)
				busy = 1
				accepts++
			busy = 0
			if(accepts)
				if(rejects)
					user << "<span class='notice'>You recycle some of the contents of [S].</span>"
				else
					user << "<span class='notice'>You empty [S] into [src].</span>"
				. = 1
			else
				user << "<span class='notice'>[src] rejects all of the items in [S].</span>"
	else if(issilicon(user))
		user << "<span class='warning'>[src] refuses to recycle your components.</span>"
	else if(filter_recycling(I))
		user.drop_item()
		I.loc = loc
		user.visible_message("<span class='notice'>[user] puts [I] into [src].</span>")
		decompose(I)
		. = 1 // prevent afterattack
	else
		user << "<span class='warning'>[src] refuses to recycle [I].</span>"
	src.updateUsrDialog()

/obj/machinery/maker/attack_hand(var/mob/user)
	if(jammed)
		if(shorted && shock(user))
			return
		if(prob(50))
			visible_message("<span class='warning'>[user] hits [src], and [jammed] pops out of it!</span>")
			jammed.loc = loc
			jammed = null
		else
			visible_message("<span class='warning'>[user] hits [src]!</span>")
	if(..())
		return
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
	. = ""
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.resource_item && R.volume >= MINERAL_MATERIAL_AMOUNT)
			var/ratio = round(R.volume / MINERAL_MATERIAL_AMOUNT)
			. += "[R.name] - [R.volume] <a href='?\ref[src];reagent=[R.id];amt=[MINERAL_MATERIAL_AMOUNT]'>Eject</a>"
			for(var/qty in list(5,10,25,50))
				if(qty > ratio) break
				. += " <a href='?\ref[src];reagent=[R.id];amt=[MINERAL_MATERIAL_AMOUNT * qty]'>([qty])</a>"
		else
			if(beaker)
				. += "[R.name] - [R.volume] <a href='?\ref[src];reagent=[R.id];amt=[R.volume]'>Drain</a>"
			else
				. += "[R.name] - [R.volume]"
		. += "<br>"
	if(!length(.))
		. = "No resources loaded."

/obj/machinery/maker/proc/list_products()
	var/list/L = all_menus[current_menu]
	. = ""
	for(var/datum/data/maker_product/P in L)
		. += "<a href='?\ref[src];build=\ref[P]'>[P.name]</a> [P.time_cost/10]s<br> <i>"
		for(var/entry in P.cost)
			. += " &nbsp; [P.cost[entry]] [entry]"
		. += "</i><br>"

/obj/machinery/maker/proc/list_menus()
	. = "<a href='?\ref[src];menu'>Main Menu</a> <br>"
	for(var/entry in all_menus)
		if(entry)
			. += "<a href='?\ref[src];menu=[entry]'>[entry]</a> <br>"

/obj/machinery/maker/proc/menu(var/mob/user)
	if(!allowed(user))
		user << browse(null,"window=maker")
		return
	build_menu_cache()
	var/dat
	if(panel_open)
		dat = wires.GetInteractWindow()
	else
		if(stat&(BROKEN|NOPOWER))
			usr << "[src] is offline."
			return
		else
			dat = {"
			<style>td { border:1px solid #000; }</style>
			<table style='width:100%;'>
				<tr><td width='240'>[resource_summary()]</td><td rowspan='2'>[list_products()]</td></tr>
				<tr><td>[list_menus()]</td></tr>
			</table> "}
	var/datum/browser/popup = new(user, "maker", name, nwidth=640)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/maker/Topic(href, list/href_list)
	if(!usr.TurfAdjacent(src))
		return
	usr.set_machine(src)
	if("menu" in href_list)
		if(stat) return
		if(panel_open)
			usr << "Close the panel first."
			updateUsrDialog()
			return
		current_menu = href_list["menu"]
		if(current_menu == "") current_menu = null // I don't know why it is doing this
	if("reagent" in href_list)
		drop_resource(href_list["reagent"], text2num(href_list["amt"]))
	if("build" in href_list)
		if(stat) return
		if(panel_open)
			usr << "Close the panel first."
			updateUsrDialog()
			return
		if(jammed)
			usr << "<span class='warning'>[jammed] is stuck in [src]!  You will have to get it out before you can build anything.</span>"
		else
			var/datum/data/maker_product/P = locate(href_list["build"])
			if(!P || !(P in all_menus[current_menu]))
				return
			make(P)
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
	updateUsrDialog()