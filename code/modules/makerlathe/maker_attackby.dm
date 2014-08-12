/obj/machinery/maker/attack_hand(var/mob/user)
	if(jammed)
		if(shorted && shock(user))
			return
		dislodge(30, user)

	user.set_machine(src)
	interact(user)

// Un-jam
/obj/machinery/maker/proc/dislodge(var/prb, var/mob/user)
	if(!jammed) return
	if(prob(prb))
		visible_message("<span class='warning'>[user] hits [src], and [jammed] pops out of it!</span>")
		jammed.loc = loc
		jammed = null
	else
		visible_message("<span class='warning'>[user] hits [src]!</span>")

// Upload file from disk
/obj/machinery/maker/proc/upload(var/datum/design/D, var/mob/user)
	if(!board.hackable)
		user << "The dataport must be enabled to download files."
		return
	if(!board.hacked)
		user << "[src]'s extended stock chip must be enabled to download files, and you cannot reach it without taking the circuitboard out."
		return
	if(!D)
		user << "<span class='warning'>No design is present.</span>"
		return null
	var/pth = D.build_path

	var/datum/data/maker_product/P = new/datum/data/maker_product/uploaded(src, pth, "Uploaded", disk = D)
	if(!P)
		user << "<span class='warning'>[src] cannot create the object stored on [D].</span>"
		return
	if(pth in researchable)
		remove_design(pth)
	researchable -= pth // a winner is you
	for(var/datum/data/maker_product/T in std_products + hack_products)
		if(T.result_typepath == pth)
			user << "<span class='warning'>[src] can already build [P.name].</span>"
			qdel(P)
			return
	hack_products += P // extended rom chip
	all_menus["Uploaded"] = null // force rebuild cache
	user << "<span class='notice'>You successfully upload the plans for [P.name] into [src].</span>"

/obj/machinery/maker/default_deconstruction_crowbar(var/obj/item/I)
	if(!istype(I,/obj/item/weapon/crowbar))
		return 0
	if(!board_type)
		user_announce("[src] does not seem to be built to be deconstructed.")
		return 0

	make_busy("Dumping stock and shutting down...")
	use_power = 2
	drop_resource(null,delay=0) // dump all stocks
	if(beaker) beaker.loc = loc
	if(jammed) jammed.loc = loc
	for(var/mob/M in range(1))
		if(M.machine == src)
			M << browse(null,"window=maker")

	..()
	return 1

/obj/machinery/maker/proc/emag(var/obj/item/weapon/card/emag/I, var/mob/user)
	if(!board.hackable)
		user << "<span class='notice'>The dataport is disabled.</span>"
		return

	if(!id_scrambled && (req_access.len + req_one_access.len) > 0)
		id_scrambled = 1
		junktech = 1
		last_multiplier_change = world.time

		make_busy(technobabble(), 50,"<span class='warning'>[user] scrambles the ID checker for [src] with [I].</span>", "You hear a strange bleep.")
		return

	if(!board.hacked)
		board.hacked = 1
		overdrive = 1
		last_multiplier_change = world.time
		use_power = 2
		for(var/entry in all_menus)
			all_menus[entry] = null // reset cache
		make_busy(technobabble(), 50, "<span class='notice'>[user] forcibly enables the extended stock chip on [src]'s motherboard.</span>", "You hear a strange bleep.")
		return

	make_busy(technobabble(), 50,"<span class='notice'>[user] swipes [I] on [src] to no visible effect.</span>", "You hear a strange bleep.")

/obj/machinery/maker/proc/transfer_reagents(var/obj/item/source, var/amt)
	if(!source.reagents || !source.reagents.total_volume) return

	var/scalar = 1
	if(amt)
		scalar = amt / source.reagents.total_volume

	for(var/datum/reagent/R in source.reagents.reagent_list)
		// Catch excess in the overflow bucket if possible.
		// If you can't recycle a reagent, it's all excess.
		var/vol = round(R.volume * scalar, 0.1)
		var/vol_src = Clamp(vol, 0, reagents.maximum_volume - reagents.total_volume)
		var/vol_beaker = vol - vol_src

		if(!recycleable || (R.id in recycleable))
			source.reagents.trans_id_to(src,R.id, vol)
		else
			vol_beaker = vol

		if(beaker)
			source.reagents.trans_id_to(beaker,R.id, vol_beaker)
		else
			source.reagents.remove_reagent(R.id, vol_beaker)
			reliability-- // gets dumped somewhere in the machine

/obj/machinery/maker/attackby(var/obj/item/I, var/mob/user)
	if(shorted && shock(user))
		return

	if(default_deconstruction_screwdriver(user, icon_open, icon_base, I))
		user.set_machine(src)
		update_icon()
		updateUsrDialog()
		return

	if(jammed)
		dislodge(50, user)
		return

	if(istype(I,/obj/item/weapon/disk/design_disk) && !stat)
		var/obj/item/weapon/disk/design_disk/D = I

		upload(D.blueprint)
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

		else if(busy || building)
			user << "[src] is busy."
			return 1

		else if(default_deconstruction_crowbar(I)) // istype() handled there
			return 1

		else if (stat)
			user << "[src] is offline."
			user << browse(null, "window=maker")
			return 1

		else if(istype(I, /obj/item/weapon/card/emag))
			emag(I,user)

		else
			attack_hand(user)
			return 1

	// ------------
	// panel closed
	// ------------

	else if(I.reagents && I.reagents.total_volume && I.flags&OPENCONTAINER)
		var/obj/item/weapon/reagent_containers/R = I
		if(istype(R))
			user << "<span class='notice'>You transfer [R.amount_per_transfer_from_this] units from [R] into [src].</span>"
			transfer_reagents(R, R.amount_per_transfer_from_this) // damn whoever made that variable name

		else
			user << "You pour [I] into [src]."
			transfer_reagents(I)

	else if(busy || building)
		user << "[src] is busy."
	else if(stat)
		user << "[src] is offline."
		user << browse(null, "window=maker")
		return 1

	else if(istype(I,/obj/item/weapon/storage) && I.contents.len)

		if(istype(I,/obj/item/weapon/storage/part_replacer)) // prevent tragedy
			user << "The panel is closed."
			return ..()

		// this is essentially meta I guess
		// There is no reason it can't break the object but
		// being unable to open it, yet able to easily destroy it?
		// that's a bummer.
		var/obj/item/weapon/storage/S = I
		if((istype(S,/obj/item/weapon/storage/secure) || istype(S,/obj/item/weapon/storage/lockbox)) && S:locked)
			user << "[S] is locked, and you can't recycle it without emptying it out."
			return

		// Give the user a chance to cancel before dumping a bag full of stuff.
		// Additionally, it will empty sort of slowly because each item
		// is inserted normally, with the normal insert animation and delay.
		// Annoying if you want it to go faster, but fair.
		user.visible_message("<span class='notice'>[user] starts emptying [S] into [src]...</span>")
		if(do_after(user,15) && !busy)
			user.set_machine(src)
			make_busy(item_recycle_msg)
			var/accepts = 0
			for(var/obj/item/stuff in S)
				if(!user.Adjacent(src) || stat)
					break
				if(!filter_recycling(stuff)) // not extracted if it won't go in
					continue
				S.remove_from_storage(stuff,loc)
				user_announce("<span class='notice'>[user] puts [stuff] into [src].</span>", "You hear some thumps and some grinding noises.")
				decompose(stuff)
				busy = 1
				accepts++
			busy_done()
			if(accepts)
				if(S.contents.len)
					user << "<span class='notice'>You recycle some of the contents of [S].</span>"
				else
					user << "<span class='notice'>You empty [S] into [src].</span>"
				. = 1
			else
				user << "<span class='notice'>[src] rejects all of the items in [S].</span>"
			return // busy_done -> updateUsrDialog

	// Allow silicons to dump bags into it but not items
	else if(issilicon(user))
		user << "<span class='warning'>[src] refuses to recycle your components.</span>"
	else if(filter_recycling(I))
		user.set_machine(src)

		make_busy(item_recycle_msg)
		user.drop_item()
		I.loc = loc
		user.visible_message("<span class='notice'>[user] puts [I] into [src].</span>")
		decompose(I)
		busy_done()
		return 1 // busy_done -> updateUsrDialog

	updateUsrDialog()
