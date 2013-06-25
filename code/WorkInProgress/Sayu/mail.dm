//TODO: Maint / Package Extraction
//TODO: Deconstruction
//TODO: AI, Cyborg

//TODO: Find something interesting for traitors / emag
//TODO: Take care of people going out of range properly
//TODO: Improve menus
//TODO: Mail administration needs its own access.
//TODO: Mail tubes/network: Pipes?  Cables?  Radio?  Magic?
//TODO: Improved sprites

//TODO: Mail networks?
//TODO: Wall mini-mail?

/var/list/mailsystem = list()

/obj/item/smallDelivery
	var/mailLabel = ""
	var/to_person = 1
	var/dest = null
	var/obj/machinery/mail/dest_station
	var/sender = null
	var/last_sender = null
	examine()
		..()
		if(dest)
			if(sender)
				usr << "According to the label, [sender] sent it to [dest]."
			else if (last_sender)
				usr << "According to the label, [last_sender] sent it to [dest]."
			else
				usr << "According to the label, it is intended for [dest]."

/obj/machinery/mail
	name = "Mail Station"
	icon = 'icons/WIP_Sayu.dmi'
	icon_state = "mailstation"
	anchored = 1
	density = 1
	use_power = 1

	var/screen = 0
	var/list/packages = list() // To be sent
	var/list/cache = list()    // To be retrieved
	var/obj/item/smallDelivery/selected_package = null
	var/obj/machinery/message_server/linkedServer = null
	var/const/mail_delay = 25
	var/global/icon/pack_in = new('icons/WIP_Sayu.dmi',"mailpackage")
	var/global/icon/mail_in = new('icons/WIP_Sayu.dmi',"mailstored")
	var/global/listchanged = 0

	New()
		..()
		var/area/A = get_area(src)
		if(A)
			name = "[A.name] [name]"
		mailsystem += src
		listchanged = 1

	Del()
		mailsystem -= src
		listchanged = 1
		..()

	update_icon()
		overlays.Cut()
		if(packages.len > 0)
			overlays += pack_in
		if(cache.len > 0)
			overlays += mail_in

	proc/Send(var/obj/item/smallDelivery/mail, var/obj/machinery/mail/dest,var/vend)
		if(stat || !dest || dest.stat || !(mail in contents))
			FailedSend()
			return

		visible_message("A package disappears into the [src].")
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		spawn(mail_delay)
			if(stat || !dest || dest.stat || !(mail in contents))
				FailedSend(mail)
				return
			mail.loc = dest
			cache -= mail
			dest.cache += mail
			dest.Recieve(mail,vend)
		return

	proc/FailedSend(var/obj/item/smallDelivery/M)
		visible_message("\red The [src] failed to send package '[M]'!")
		if(M in contents)
			M.sender = ""
			packages += M
			update_icon()
		return

	proc/Recieve(var/obj/item/smallDelivery/M,var/vend)
		if(vend)
			cache -= M
			visible_message("A package appears out of the [src].")
			M.last_sender = M.sender
			M.sender = null
			if((usr in view(1)) && !usr.get_active_hand())
				usr.put_in_hands(M)
		else
			visible_message("The [src] recieves a package.")
		update_icon()

	proc/PackageList(var/obj/item/weapon/card/id/user = null)
		var/list/results = list()
		for(var/obj/machinery/mail/hub/H in mailsystem)
			if(!istype(H) || H.stat) continue
			results += H.contents
		for(var/obj/item/smallDelivery/H in results)
			if(!istype(H))
				results -= H
				continue
			if(!user || (((access_qm in user.access) || emagged) && H in contents))
				continue // Quartermaster access can see and recieve all packages, emags can too
			if(!H.dest)
				results -= H
			else if(H.to_person && H.dest != user.registered_name)
				results -= H
			else if(!H.to_person && H.dest_station != src)
				results -= H
		for(var/obj/item/smallDelivery/H in cache)
			if(!H.to_person && (H.dest_station == src) && !(H in results)) // mail sent to this machine
				results += H

		return results
	proc/LocalPackages(var/auth)
		if(auth)
			return packages + cache
		else
			return packages

	proc/PersonnelList()
		var/list/results = list()
		if(isnull(data_core.general))
			return results

		for(var/datum/data/record/R in sortRecord(data_core.general, "name", 1))
			var/name = R.fields["name"]
			var/job = R.fields["rank"]
			results[name] = job
		return results

	proc/MessagePersonnel(var/user,var/message = null)
		if(!message)
			message = "A package has been sent to you.  You may pick it up at any mail station."
		if(!linkedServer)
			if(message_servers && message_servers.len > 0)
				linkedServer = message_servers[1]
		var/sender = "Mailer Daemon"
		linkedServer.send_pda_message("[user]", "[sender]","[message]")
		var/obj/item/device/pda/reciever = null
		for (var/obj/item/device/pda/P in PDAs)
			if (!P.owner || P.toff || P.hidden)	continue
			if(P.owner == user)
				reciever = P
		if(!reciever) return

		reciever.tnote += "<i><b>&larr; From [sender]:</b></i><br>[message]<br>"
		if (!reciever.silent)
			playsound(reciever.loc, 'sound/machines/twobeep.ogg', 50, 1)
			for (var/mob/O in hearers(3, reciever.loc))
				O.show_message(text("\icon[reciever] *[reciever.ttone]*"))
			if( reciever.loc && ishuman(reciever.loc) )
				var/mob/living/carbon/human/H = reciever.loc
				H << "\icon[reciever] <b>Message from [sender], </b>\"[message]\""
			log_pda("[usr] (PDA: [sender]) sent \"[message]\" to [reciever.owner]")
			reciever.overlays = null
			reciever.overlays += image('icons/obj/pda.dmi', "pda-r")

	proc/buildMenu(var/obj/item/weapon/card/id/id)
		var/dat = ""
		if(emagged)
			var/junk = ""
			while(lentext(junk) < 16)
				junk += pick("$","!",","," ","#","-","_","*","/","|")
			dat += "User: [junk] (Mail Admin)"
		else if(id)
			var/quickicon = ""
			if(istype(src,/obj/machinery/mail/hub) && (emagged || (access_qm in id.access))) quickicon = "(Mail Admin)"
			dat += "User: [id.registered_name] ([id.assignment]) [quickicon]"

		else
			dat += "No user detected."
		dat += " <a href='?src=\ref[src]'>Re-scan</a><hr>" // No operation
		if(selected_package)
			dat += "Package: [selected_package]<br>"
		dat += "<br>"
		switch(screen)
			if(0)	// Main menu
				dat += "<A href='?src=\ref[src];operation=sendmenu'>Send Mail</A><br>"
				dat += "<A href='?src=\ref[src];operation=getmenu'>Check Mail</A><br>"
				if(packages.len)
					dat += "There are unsent packages in this machine."
				return dat
			if(10)	// Send mail
				if(istype(src,/obj/machinery/mail/hub) && (emagged || (access_qm in id.access)))
					dat += "<i>You have priviledged access to the mail system.<br>Under space law, mail fraud is a prosecutable offense.</i><br><br>"
				if(!packages.len)
					dat += "No packages loaded.  This station accepts any small item or box wrapped in package wrap."
				else
					for(var/obj/item/smallDelivery/MH in LocalPackages(id || emagged))
						if(!istype(MH)) continue
						if(MH.sender)
							if(!emagged && !(access_qm in id.access))
								continue // The hub contents includes sent packages, don't include them normally
							else
								dat += "<A href='?src=\ref[src];operation=senddetails&object=\ref[MH]'>[MH]</A> (Waiting for retrieval: <i>[MH.dest]</i>) (<a href='?src=\ref[src];operation=returnpkg&object=\ref[MH]'>Eject</a>)<br>"
						else
							dat += "<A href='?src=\ref[src];operation=senddetails&object=\ref[MH]'>[MH]</A> (<a href='?src=\ref[src];operation=returnpkg&object=\ref[MH]'>Eject</a>)<br>"
				dat += "<hr><a href='?src=\ref[src];operation=mainmenu'>Go Back</a>"
				return dat
			if(11) // Send mail - package menu
				if(!id && !emagged)
					dat += "<b>Error:</b> A valid station ID is required to access this function.<br>"
					dat += "<a href='?src=\ref[src];operation=sendmenu'>Go Back</a>"
					return dat
				if(!selected_package)
					screen = 10
					return buildMenu()
				dat += "Package details:<br>"
				if(selected_package.mailLabel)
					dat += "Label: <a href='?src=\ref[src];operation=setname'>[selected_package.mailLabel]</a><br>"
				else
					dat += "Label: <a href='?src=\ref[src];operation=setname'>None</a><br>"
				dat += "Destination: "
				if(!selected_package.dest)
					dat += "None"
				else
					dat += "<i>[selected_package.dest]</i>"

				if(selected_package.sender)
					dat += "<br> Sent by <i>[selected_package.sender]</i>.  (<a href='?src=\ref[src];operation=returntosender'>Return to Sender</a>) <br>"
				else
					dat += "<br> Send to:(<a href='?src=\ref[src];operation=setperson'>one person</a>) (<a href='?src=\ref[src];operation=setstation'>a mail station</a>)<br>"
				dat += "<hr> <a href='?src=\ref[src];operation=send'>Send Package</a><br>"
				dat += "<a href='?src=\ref[src];operation=returnpkg'>Eject Package</a> | <a href='?src=\ref[src];operation=sendmenu'>Go Back</a>"

			if(12) // Send - set recipient - mail station
				if(!id && !emagged)
					dat += "<b>Error:</b> A valid station ID is required to access this function.<br>"
					dat += "<a href='?src=\ref[src];operation=sendmenu'>Go Back</a>"
					return dat
				if(!selected_package)
					screen = 10
					return buildMenu()
				dat += "Current destination: "
				if(!selected_package.dest)
					dat += "None"
				else
					dat += "<i>[selected_package.dest]</i>"
				dat += "<br><br>"

				if(listchanged)
					mailsystem = sortAtom(mailsystem)

				for(var/obj/machinery/mail/hub/station in mailsystem)
					dat += "<a href='?src=\ref[src];operation=do_setstation&object=\ref[station]'>[station.name]</a><br>"
				for(var/obj/machinery/mail/station in mailsystem)
					if(istype(station,/obj/machinery/mail/hub)) continue
					dat += "<a href='?src=\ref[src];operation=do_setstation&object=\ref[station]'>[station.name]</a><br>"
				dat += "<br><a href='?src=\ref[src];operation=senddetails'>Return</a><hr><br>"

			if(13) // Send - set recipient - person
				if(!id && !emagged)
					dat += "<b>Error:</b> A valid station ID is required to access this function.<br>"
					dat += "<a href='?src=\ref[src];operation=sendmenu'>Go Back</a>"
					return dat
				if(!selected_package)
					screen = 10
					return buildMenu()
				dat += "Current destination: "
				if(!selected_package.dest)
					dat += "None"
				else
					dat += "<i>[selected_package.dest]</i>"
				dat += "<br><br>"
				var/list/L = PersonnelList()
				for(var/person in L)
					dat += "<a href='?src=\ref[src];operation=do_setperson&name=[person]'>[person] ([L[person]])</a><br>"
				dat += "<br><a href='?src=\ref[src];operation=senddetails'>Return</a><hr>"

			if(20) // Get mail
				if(!id && !emagged)
					dat += "<b>Error:</b> A valid station ID is required to access this function.<br>"
					dat += "<a href='?src=\ref[src];operation=sendmenu'>Go Back</a>"
					return dat
				var/list/L = PackageList(id)
				if(!L.len)
					dat += "There are no packages for pickup."
				else
					if(istype(src,/obj/machinery/mail/hub) && (emagged || (access_qm in id.access)))
						dat += "<i>You have priviledged access to the mail system.<br>Under space law, mail fraud is a prosecutable offense.</i><br><br>"
					for(var/obj/item/smallDelivery/H in L)
						if(!H.sender)
							continue // don't list unsent packages here
						dat += "<A href='?src=\ref[src];operation=getpackage&object=\ref[H]'>[H]</a> (sent to [H.dest] by [H.sender])<br>"
				dat += "<hr><a href='?src=\ref[src];operation=mainmenu'>Go Back</a>"
		return dat

	proc/getHub(var/obj/item/smallDelivery/requested_package = null)
		if(requested_package != null)
			return requested_package.loc
		for(var/obj/machinery/mail/hub/H in mailsystem)
			if(!istype(H)) continue
			if(H.stat) continue
			return H
		return null

	Topic(var/href,var/list/href_list)
		if(stat) return
		if(!(usr in range(1)) && !istype(usr,/mob/living/silicon))
			return

		var/obj/item/weapon/card/id/id = null
//		var/robot = 0
		var/auth = 0
		if(usr && istype(usr,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			if(H.wear_id)
				id = H.wear_id.GetID()
//		if(usr && istype(usr,/mob/living/silicon))
//			robot = 1
		if(id != null) auth = 1
		if(emagged || (auth && (access_qm in id.access))) auth = 2

		switch(href_list["operation"])
			if("mainmenu")
				screen = 0
			if("sendmenu")
				screen = 10
				selected_package = null
			if("senddetails")
				if(auth)
					selected_package = locate(href_list["object"])
					screen = 11
			if("setstation")
				if(auth)
					screen = 12
			if("do_setstation")
				if(auth)
					screen = 11
					selected_package.to_person = 0
					selected_package.dest_station = locate(href_list["object"])
					selected_package.dest = selected_package.dest_station.name
			if("setperson")
				if(auth)
					screen = 13
			if("do_setperson")
				if(auth)
					screen = 11
					selected_package.to_person = 1
					selected_package.dest = href_list["name"]
					selected_package.dest_station = null
			if("setname")
				if(auth)
					var/label = input(usr,"Enter a label for this package:","Relabel Package",selected_package.mailLabel)
					if(lentext(label) > 20) label = copytext(label,1,20)
					selected_package.mailLabel = label
					selected_package.name = "small parcel ([selected_package.mailLabel])"
			if("send")
				if(!selected_package || !auth)
					screen = 10
					selected_package = null
				else
					if(selected_package.dest)
						var/obj/machinery/mail/hub/H = getHub()
						if(H != null)
							if(emagged)
								selected_package.sender = "Mailer Daemon"
							else
								selected_package.sender = "[id.registered_name] ([id.assignment])"
							Send(selected_package,H,0)
							packages-= selected_package
							update_icon()
							screen = 10
							selected_package = null
							if(H != src)
								sleep(mail_delay+1)
			if("returntosender")
				if(auth == 2) // emag/QM
					var/sender = selected_package.sender
					sender = copytext(sender,1,findtextEx(sender,"(")-1)
					if(sender == "Mailer Daemon")
						selected_package.dest = "Mail Hub"
						selected_package.to_person = 0
						selected_package.dest_station = getHub()
					else
						selected_package.dest = sender
						selected_package.to_person = 1
					Recieve(selected_package,0)

			if("returnpkg") // cancel send
				if(selected_package)
					Recieve(selected_package, 1)
					packages -= selected_package
				else
					var/obj/item/smallDelivery/H = locate(href_list["object"])
					if(!H)
						interact()
						return
					Recieve(H, 1)
					packages -= H
				update_icon()
				selected_package = null
				screen = 10

			if("getmenu")
				if(auth)
					screen = 20

			if("getpackage")
				if(auth)
					var/obj/item/smallDelivery/M = locate(href_list["object"]) in PackageList()
					var/obj/machinery/mail/hub/H = getHub(M)
					if(M && H)
						H.Send(M,src,1)
						if(H != src) // no delay when retrieving from self
							sleep(mail_delay+1)

		interact()
		return


	interact()
		if(stat) return
		if(!(usr in range(1)))
			return
		if(istype(usr,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			var/obj/item/weapon/card/id/id = null
			if(H.wear_id)
				id = H.wear_id.GetID()
			usr << browse("<HEAD><TITLE>[name]</TITLE></HEAD>[buildMenu(id)]", "window=mailstat;size=450x600")
		else if(istype(usr,/mob/living/silicon))
			usr << "The [src] refuses to interact with you."
			//usr << browse("<HEAD><TITLE>[name]</TITLE></HEAD>[RobotMenu()]", "window=mailstat;size=450x600")
		return

	attack_hand(mob/user as mob)
		interact()

	proc/RobotMenu() // Robots are verboden from accessing the mail network.
		var/dat = ""
		dat += "<i>Mail network access forbidden.  Restricted to local operation.</i><hr>"
		dat += "Locally stored packages:<br>"
		if(packages)
			for(var/obj/item/smallDelivery/H in packages)
				if(!istype(H)) continue
				dat += "[H], unsent."
				if(H.dest)
					dat += " Marked for <i>[H.dest]</i>."
				dat += "(<a href='?src=\ref[src];operation=returnpkg&object=\ref[H]'>Eject</a>)<br>"
			for(var/obj/item/smallDelivery/H in cache)
				if(H.dest && H.dest == name)
					dat += "[H], sent to this station."
					dat += "(<a href='?src=\ref[src];operation=returnpkg&object=\ref[H]'>Eject</a>)<br>"
				else if(emagged)
					dat += "[H], sent to <i>[H.dest]</i>.(<a href='?src=\ref[src];operation=returnpkg&object=\ref[H]'>Eject</a>)<br>"
		return dat


	attackby(obj/item/P as obj, mob/user as mob)
		if(istype(P,/obj/item/smallDelivery))
			usr.drop_item()
			P.loc = src
			packages+= P
			update_icon()
		else
			user << "\blue The [src] refuses the unwrapped [P.name]."


/obj/machinery/mail/hub
	name = "Mail Hub"
	icon_state = "mailhub"

	New()
		..()
		name = initial(name) // No area code for the hub

	update_icon()
		return
	attackby(obj/item/P as obj, mob/user as mob)
		if(istype(P,/obj/item/weapon/card/emag)) // mail stations cannot be emagged, but the hub can
			user << "The mail hub doesn't seem to like the [P], but yields after a moment."
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 1, src)
			s.start()
			emagged = 1
			return
		..(P,user)

	Recieve(var/obj/item/smallDelivery/MH,var/vend)
		ChillingEffect()
		if(!vend)
			if(!MH.to_person && MH.dest_station != null) // Package forwarding
				if(MH.dest_station != src)
					Send(MH,MH.dest_station,0)
					visible_message("The [src] relays a package to another station.")
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)//Whiff is a nice sound for the mail system to make
					return
			if(MH.to_person && MH.dest != null)// Hub messaging service
				cache += src
				MH.loc = src
				if(MH.mailLabel != "")
					MessagePersonnel(MH.dest, "You have recieved a package from <i>[MH.sender]</i> labelled <i>[MH.mailLabel]</i>.")
				else
					MessagePersonnel(MH.dest, "You have recieved a package from <i>[MH.sender]</i>.")

				visible_message("The [src] recieves a package.")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)//Whiff is a nice sound for the mail system to make
				return

		..(MH,vend)

	Send(var/obj/item/smallDelivery/mail, var/obj/machinery/mail/dest,var/vend)
		ChillingEffect()
		if(stat || !dest || dest.stat || !(mail in contents))
			FailedSend()
			return
		if(vend)
			cache -= mail
		else
			packages -= mail
		if(dest == src) // happens when the hub is being used as a mail
			Recieve(mail,vend)
			return
		..(mail,dest,vend)

	//Bluespace has a negative-entropy effect
	proc/ChillingEffect()
		var/turf/simulated/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			var/transfer_moles = 0.25 * env.total_moles()
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null) // Added check to avoid divide by zero (oshi-) runtime errors -- TLE
					heat_capacity = 1
				removed.temperature = max((removed.temperature*heat_capacity - 10000)/heat_capacity, 0)
			env.merge(removed)



/obj/item/weapon/circuitboard/mailstation
	name = "Circuit board (Mail Station)"
	build_path = "/obj/machinery/mail"
	origin_tech = "programming=2;bluespace=1"

/obj/item/weapon/circuitboard/mailhub
	name = "Circuit board (Mail Hub)"
	build_path = "/obj/machinery/mail/hub"
	board_type = "machine"
	origin_tech = "programming=2;bluespace=4"
	frame_desc = "Requires 1 ansible, 1 amplifier, and 1 transmitter."
	req_components = list(	"/obj/item/weapon/stock_parts/subspace/ansible" = 1,
							"/obj/item/weapon/stock_parts/subspace/amplifier" = 1,
							"/obj/item/weapon/stock_parts/subspace/transmitter" = 1)

datum/design/mail
	name = "Circuit Design (Mail Station)"
	desc = "Allows for the construction of circuit boards used to build a Mail Station."
	id = "mail"
	req_tech = list("programming" = 2,"bluespace"=2)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = "/obj/item/weapon/circuitboard/mailstation"

datum/design/mailhub
	name = "Circuit Design (Mail Hub)"
	desc = "Allows for the construction of circuit boards used to build a Mail Hub."
	id = "mailhub"
	req_tech = list("programming" = 2,"bluespace"=5)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20)
	build_path = "/obj/item/weapon/circuitboard/mailhub"

/obj/machinery/vending/refillable/mail
	name = "Mail supplies"
	desc = "For all your packaging needs."
	icon = 'icons/WIP_Sayu.dmi'
	icon_state = "mailvend"
	product_ads = "The mail always delivers.;Doing our part when you're apart.;Don't forget to write home occasionally!"
	density = 0
	wheeled = 0
	products = list(/obj/item/weapon/packageWrap = 2, /obj/item/stack/sheet/cardboard = 10, /obj/item/weapon/pen = 3, /obj/item/weapon/hand_labeler = 1)

	north
		pixel_y = 27
	south
		pixel_y = -28
	east
		pixel_x = 24
	west
		pixel_x = -24