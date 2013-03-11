//TODO: Maint / Package Extraction
//TODO: Deconstruction
//TODO: AI, Cyborg

//TODO: Find something interesting for traitors / emag
//TODO: Take care of people going out of range properly
//TODO: Improve menus
//TODO: Mail access needs its own ID.  HOP (QM access) probably doesn't need it.
//TODO: Pipes?
//TODO: Sprites

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
	var/obj/item/smallDelivery/selected_package = null
	var/obj/machinery/message_server/linkedServer = null

	var/list/cache = list() // List of remote packages to be sent here

	var/list/authtimes = list() // last use of second factor authentication

	var/const/mail_delay = 20 // Time that a mail send/recieve operation takes.
	var/global/icon/pack_in = new('icons/WIP_Sayu.dmi',"mailpackage")
	var/global/icon/mail_in = new('icons/WIP_Sayu.dmi',"mailstored")

	var/global/listchanged = 0 // Set when the list of mail stations needs to be re-sorted


	//
	//	Straightforward overridden functions
	//

	New()
		..()
		//Name mail stations after the Area they are located in
		if(istype(src,/obj/machinery/mail/))
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
		if(contents.len > 0)
			overlays += pack_in
		if(cache.len > 0)
			overlays += mail_in

	attackby(obj/item/P as obj, mob/user as mob)
		if(istype(P,/obj/item/smallDelivery))
			usr.drop_item()
			InsertPackage(P)
			update_icon()
		else
			user << "\blue The [src] refuses the unwrapped [P.name]."

	attack_hand(mob/user as mob)
		interact()

	interact()
		if(stat) return
		if(!(usr in range(1)) && !istype(usr,/mob/living/silicon))
			return
		if(istype(usr,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			var/obj/item/weapon/card/id/id = null
			if(H.wear_id)
				id = H.wear_id.GetID()

			usr << browse("<HEAD><TITLE>[name]</TITLE></HEAD>[Menu(id)]", "window=mailstation;size=450x600")
		else if(istype(usr,/mob/living/silicon))
			usr << "The [src] refuses to interact with you."
		return

	//
	//	Straightforward helper procs
	//
	proc/InsertPackage(var/obj/item/smallDelivery/package)
		if(package.sender)
			package.last_sender = package.sender
			package.sender = null
		package.loc = src


	//Returns true if target can be alerted via the messaging system
	proc/ValidSender(var/sendername)
		if(sendername in PersonnelList())
			return 1
		return 0

	//Not implemented for stations, used by hubs
	proc/MessagePersonnel(var/user,var/message = null)
		return

	//List personnel (from the computer)
	proc/PersonnelList()
		var/list/results = list()
		if(isnull(data_core.general))
			return results

		for(var/datum/data/record/R in sortRecord(data_core.general, "name", 1))
			var/name = R.fields["name"]
			var/job = R.fields["rank"]
			results[name] = job
		return results

	//Return the local mail hub (first in the list)
	proc/getHub(var/obj/item/smallDelivery/requested_package = null)
		if(requested_package != null)
			if(istype(requested_package.loc,/obj/machinery/mail/hub))
				return requested_package.loc
			return null
		for(var/obj/machinery/mail/hub/H in mailsystem)
			if(H.stat) continue
			return H
		return null

	//Packages for the recipient
	proc/RecieveList(var/obj/item/weapon/card/id/user = null)
		var/list/results = list()
		for(var/obj/machinery/mail/hub/H in mailsystem)
			for(var/obj/item/smallDelivery/MH in H.contents)
				if(MH.to_person)
					if(!user || user.registered_name != MH.dest)
						continue
					results += MH
				else
					if(MH.dest_station == src)
						results += MH
			//for mail in hub
		//for hub
		return results

	//Packages to be sent.  For mail stations, no logic is needed.
	proc/SendList()
		return contents
	proc/SendCount()
		return contents.len

	//Packages that can be altered.  For mail stations, this is not implmemented.
	proc/AdministerList()
		return list()
	proc/AdminsterCount()
		return 0

	//Chills the surrounding air due to reverse-entropy effects
	proc/ChillingEffect()
		var/turf/simulated/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			var/transfer_moles = 0.125 * env.total_moles()
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null) // Added check to avoid divide by zero (oshi-) runtime errors -- TLE
					heat_capacity = 1
				removed.temperature = max((removed.temperature*heat_capacity - 10000)/heat_capacity, 0)
			env.merge(removed)

	//
	//	Transfer logic
	//

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
			dest.Recieve(mail,vend)
			ChillingEffect()
		return

	proc/FailedSend(var/obj/item/smallDelivery/M)
		visible_message("\red The [src] failed to send package '[M]'!")
		if(M in contents)
			M.sender = ""
			update_icon()
		return
	proc/Recieve(var/obj/item/smallDelivery/M,var/vend)
		if(vend)
			cache -= M
			visible_message("A package appears out of the [src].")
			var/obj/item/smallDelivery/O = M.unwrap()
			//Unwrap moves it to the containing turf by default
			//If possible, put it in their hand instead.
			if((usr in view(1)) && !usr.get_active_hand())
				usr.put_in_hands(O)
			del M
		else
			visible_message("The [src] recieves a package.")
		update_icon()
		return

	//
	//	UI Logic
	//
	proc/Menu(var/obj/item/weapon/card/id/id)
		var/dat = ""
		var/access = 1

		if(!id)
			access = 0
		else if ((access_qm in id.access) || emagged)
			access = 2

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
			dat += "No user detected. <a href='?src=\ref[src]'>Re-scan</a><hr>"
			return dat

		dat += " <a href='?src=\ref[src]'>Re-scan</a><hr>" // No operation
		if(selected_package)
			dat += "Package: [selected_package]<br>"
		dat += "<br>"

		switch(screen)
			if(0)
				return dat + MainMenu(access)		//	Main Menu
			if(10)
				return dat + SendMenu(access) 		//	Send mail - package list
			if(11)
				return dat + PackageMenu(access)	//	Send mail - package details
			if(12)
				return dat + MachineMenu(access)	//	Send mail - set recipient - mail station
			if(13)
				return dat + PersonnelMenu(access)	//	Send mail - set recipient - person
			if(20)
				return dat + RecieveMenu(access,id)	//	Get mail - package list
			if(30)
				return dat + AdministerMenu(access)	//	Mail Adminstrator's Menu
			if(40)
				return dat + PreferenceMenu(access,id)		//	User Preference Menu
		dat += "Unimplemented feature.<br>"
		dat += "<a href='?src=\ref[src]'>Go Back</a>"
		return dat

	proc/MainMenu(var/access)
		var/dat = "<A href='?src=\ref[src];operation=sendmenu'>Send Mail</A><br>"
		dat += "<A href='?src=\ref[src];operation=getmenu'>Check Mail</A><br>"
		if(istype(src,/obj/machinery/mail/hub) && access == 2)
			dat += "<A href='?src=\ref[src];operation=managemenu'>Administration</A><br>"
		dat += "<A href='?src=\ref[src];operation=prefmenu'>Preferences</A><br>"
		if(SendCount())
			dat += "<br>There are unsent packages in this machine."
		return dat

	// Send Mail - Package List
	proc/SendMenu(var/access)
		var/dat = ""
		if(!SendCount())
			dat += "No packages loaded.  This station accepts any small item or box wrapped in package wrap."
		else
			for(var/obj/item/smallDelivery/MH in SendList())
				dat += "<A href='?src=\ref[src];operation=senddetails&object=\ref[MH]'>[MH]</A> (<a href='?src=\ref[src];operation=returnpkg&object=\ref[MH]'>Eject</a>)<br>"
		dat += "<hr><a href='?src=\ref[src];operation=mainmenu'>Go Back</a>"
		return dat

	//Send mail - Package Details
	proc/PackageMenu(var/access)
		if(!selected_package)
			screen = 0
			return MainMenu() // Reset, saving no progress

		var/dat = ""
		if(!access)
			dat += "<b>Error:</b> A valid station ID is required to access this function.<br>"
			dat += "<a href='?src=\ref[src];operation=sendmenu'>Go Back</a>"
			return dat

		dat += "Package details:<br>"
		dat += "Name: <a href='?src=\ref[src];operation=setname'>[selected_package]</a><br>"
		dat += "Destination: "
		if(!selected_package.dest)
			dat += "None"
		else
			dat += "<i>[selected_package.dest]</i>"
			if(selected_package.sender)
				dat += "<br> Sent by <i>[selected_package.sender]</i>.  (<a href='?src=\ref[src];operation=returntosender'>Return to Sender</a>) <br>"
		dat += "<br> Send to:(<a href='?src=\ref[src];operation=setperson'>one person</a>) (<a href='?src=\ref[src];operation=setstation'>a mail station</a>)<br>"
		dat += "<hr> <a href='?src=\ref[src];operation=send'>Send Package</a><br>"
		dat += "<a href='?src=\ref[src];operation=returnpkg'>Eject Package</a> | <a href='?src=\ref[src];operation=sendmenu'>Go Back</a>"
		return dat

	// Send Mail - Set Destination - Mail Station
	proc/MachineMenu(var/access)
		if(!selected_package)
			screen = 0
			return MainMenu()
		var/dat = ""
		if(!access)
			dat += "<b>Error:</b> A valid station ID is required to access this function.<br>"
			dat += "<a href='?src=\ref[src];operation=sendmenu'>Go Back</a>"
			return dat

		dat += "Current destination: "
		if(!selected_package.dest)
			dat += "None"
		else
			dat += "<i>[selected_package.dest]</i>"
		dat += "<br><br>"

		if(listchanged)
			mailsystem = sortAtom(mailsystem)
			listchanged = 0

		//List mail hubs
		for(var/obj/machinery/mail/hub/station in mailsystem)
			dat += "<a href='?src=\ref[src];operation=do_setstation&object=\ref[station]'>[station.name]</a><br>"
		//List mail stations
		for(var/obj/machinery/mail/station in mailsystem)
			if(istype(station,/obj/machinery/mail/hub)) continue
			dat += "<a href='?src=\ref[src];operation=do_setstation&object=\ref[station]'>[station.name]</a><br>"

		dat += "<br><a href='?src=\ref[src];operation=senddetails'>Return</a><hr><br>"
		return dat

	// Send Mail - Set Destination - Personnel
	proc/PersonnelMenu(var/access)
		if(!selected_package)
			screen = 10
			return MainMenu()
		var/dat = ""
		if(!access)
			dat += "<b>Error:</b> A valid station ID is required to access this function.<br>"
			dat += "<a href='?src=\ref[src];operation=sendmenu'>Go Back</a>"
			return dat

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
		return dat
	proc/RecieveMenu(var/access, var/obj/item/weapon/card/id/id)
		var/dat = ""
		if(!access)
			dat += "<b>Error:</b> A valid station ID is required to access this function.<br>"
			dat += "<a href='?src=\ref[src];operation=sendmenu'>Go Back</a>"
			return dat
		var/list/L = RecieveList(id)
		if(!L.len)
			dat += "There are no packages for pickup."
		else
			if(istype(src,/obj/machinery/mail/hub) && access == 2)
				dat += "<i>You have priviledged access to the mail system.<br>Under space law, mail fraud is a prosecutable offense.</i><br><br>"
			for(var/obj/item/smallDelivery/H in L)
				if(!H.sender)
					continue // don't list unsent packages here
				dat += "<A href='?src=\ref[src];operation=getpackage&object=\ref[H]'>[H]</a> (sent to [H.dest] by [H.sender])<br>"
		dat += "<hr><a href='?src=\ref[src];operation=mainmenu'>Go Back</a>"
		return dat
	proc/AdministerMenu(var/access)
		var/dat = "Unimplemented feature.<br>"
		dat += "<a href='?src=\ref[src];operation=mainmenu'>Go Back</a>"
		return dat
	proc/PreferenceMenu(var/access,var/obj/item/weapon/card/id/id)
		var/obj/machinery/mail/hub/H = getHub()
		if(!H)
			return "Unable to connect to MailHub.  All mail services are offline.<br><a href='?src=\ref[src];operation=mainmenu'>Go Back</a>"
		var/datum/mailprefs/pref = H.preferences[id.registered_name]
		if(pref == null)
			pref = new()
			H.preferences[id.registered_name] = pref
		var/dat = "User Preferences<br>"
		dat += "Log mail receipts as PDA messages: <a href='?src=\ref[src];operation=pref_message'>[pref.PDA_Message?"On":"Off"]</a><br>"
		dat += "Audible PDA alert on new mail: <a href='?src=\ref[src];operation=pref_alert'>[pref.PDA_Alert?"On":"Off"]</a><br>"
		dat += "<a href='?src=\ref[src];operation=mainmenu'>Go Back</a>"
		return dat

	Topic(var/href,var/list/href_list)
		if(stat) return
		if(!(usr in range(1)) && !istype(usr,/mob/living/silicon))
			return

		var/obj/item/weapon/card/id/id = null
		var/obj/machinery/mail/hub/H = getHub()
		var/datum/mailprefs/pref = null
		var/auth = 0
		if(usr && istype(usr,/mob/living/carbon/human))
			var/mob/living/carbon/human/Hu = usr
			if(Hu.wear_id)
				id = Hu.wear_id.GetID()
		if(id != null)
			pref = H.preferences[id.registered_name]
			if(isnull(pref))
				pref = new()
				H.preferences[id.registered_name] = pref
			auth = 1
		if(emagged || (auth && (access_qm in id.access))) auth = 2

		if(!auth)
			screen = 0
			interact()
			return

		switch(href_list["operation"])
			if("mainmenu")
				screen = 0
			if("sendmenu")
				screen = 10
				selected_package = null
			if("senddetails")
				selected_package = locate(href_list["object"])
				screen = 11
			if("setstation")
				screen = 12
			if("do_setstation")
				screen = 11
				selected_package.to_person = 0
				selected_package.dest_station = locate(href_list["object"])
				selected_package.dest = selected_package.dest_station.name
			if("setperson")
				screen = 13
			if("do_setperson")
				screen = 11
				selected_package.to_person = 1
				selected_package.dest = href_list["name"]
				selected_package.dest_station = null
			if("setname")
				selected_package.label = input(usr,"Enter a label for this package:","Relabel Package",selected_package.label)
				if(lentext(selected_package.label) > 20) selected_package.label = copytext(selected_package.label,1,20)
				var/obj/O = selected_package.contents[1]
				selected_package.name = "[selected_package.label] ([O.name])"
			if("send")
				if(!selected_package)
					screen = 10
					selected_package = null
					interact()
					return
				if(selected_package.dest)
					if(H != null)
						if(emagged)
							selected_package.sender = "Mailer Daemon"
						else
							selected_package.sender = "[id.registered_name] ([id.assignment])"
						Send(selected_package,H,0)
						update_icon()
						screen = 10
						selected_package = null
						if(H != src)
							sleep(mail_delay+1)
			if("returntosender")
				if(auth == 2) // emag/QM
					var/sender = selected_package.sender
					sender = copytext(sender,1,findtextEx(sender,"(")-1)
					if(!selected_package.to_person && selected_package.dest_station) // sent to a machine
						selected_package.dest_station.cache -= selected_package
						selected_package.dest_station.update_icon()

					if(ValidSender(sender))
						selected_package.dest = sender
						selected_package.to_person = 1
					else
						selected_package.dest = "Mail Hub"
						selected_package.to_person = 0
						selected_package.dest_station = getHub()

					Recieve(selected_package,0)

			if("returnpkg") // cancel send
				if(selected_package)
					if(selected_package.sender)
						if(!selected_package.to_person && selected_package.dest_station)
							selected_package.dest_station.cache -= selected_package
							selected_package.dest_station.update_icon()
					Send(selected_package,src, 1)
				else
					var/obj/item/smallDelivery/MH = locate(href_list["object"])
					if(!MH)
						interact()
						return
					Send(MH, src, 1)
				update_icon()
				selected_package = null
				screen = 10

			if("getmenu")
				screen = 20

			if("getpackage")
				var/obj/item/smallDelivery/M = locate(href_list["object"]) in SendList()
				H = getHub(M) // H is the mailhub mostly in use mailhub, probably the same but not definitely so
				if(M && H)
					H.Send(M,src,1)
					if(H != src) // no delay when retrieving from self
						sleep(mail_delay+1)
			if("managemenu")
				screen = 30
			if("prefmenu")
				screen = 40
			if("pref_message")
				if(id != null)
					pref.PDA_Message = !pref.PDA_Message
			if("pref_alert")
				if(id != null)
					pref.PDA_Alert = !pref.PDA_Alert


		interact()
		return

/datum/mailprefs
	var/PDA_Message = 1
	var/PDA_Alert = 1

/obj/machinery/mail/hub
	name = "Mail Hub"
	icon_state = "mailhub"
	var/list/waiting = list()
	var/list/preferences = list()

	update_icon()	// until there are hub sprites, this is useless
		return

	attackby(obj/item/P as obj, mob/user as mob)
		if(istype(P,/obj/item/weapon/card/emag))
			user << "The mail hub tries to reject the [P], but yields after a moment."
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 1, src)
			s.start()
			emagged = 1
			return
		..(P,user)

	InsertPackage(var/obj/item/smallDelivery/package)
		var/obj/item/smallDelivery/M = new(src)
		M.wrap(package)
		waiting += M

	// Packages to be sent.  Complimentary set to AdministerList()
	SendList()
		return waiting

	//Packages waiting to be picked up.  Complimentary set to SendList()
	AdministerList()
		return contents - waiting

	MessagePersonnel(var/user,var/message)
		if(!message)
			message = "A package has been sent to you.  You may pick it up at any mail station."
		if(!linkedServer)
			if(message_servers && message_servers.len > 0)
				linkedServer = message_servers[1]
			else
				return // No messaging server, no messages

		var/sender = "Mailer Daemon"
		var/obj/item/device/pda/reciever = null
		for (var/obj/item/device/pda/P in PDAs)
			if (!P.owner || P.toff || P.hidden)	continue
			if(P.owner == user)
				reciever = P
		if(!reciever) return
		var/datum/mailprefs/pref = null
		if(user in preferences)
			pref = preferences[user]
		else
			pref = new()
			preferences[user] = pref

		if(pref.PDA_Message) // Fill their goddamn message queue with bullshit.
			reciever.tnote += "&larr;[message]<br>"
			reciever.overlays.Cut()
			reciever.overlays += image('icons/obj/pda.dmi', "pda-r")
			log_pda("Mail Notification for [user]: \"[message]\"")
			linkedServer.send_pda_message("[user]", "[sender]","[message]")

		// The audible alarm is a separate thing.
		if (reciever.silent || !pref.PDA_Alert)
			return

		//Sound and text in the chatbox
		playsound(reciever.loc, 'sound/machines/twobeep.ogg', 50, 1)
		for (var/mob/O in hearers(3, reciever.loc))
			O.show_message(text("\icon[reciever] *[reciever.ttone]*"))
		if( reciever.loc && ishuman(reciever.loc) )
			var/mob/living/carbon/human/H = reciever.loc
			H << "\icon[reciever] \"[message]\""



	Send(var/obj/item/smallDelivery/mail, var/obj/machinery/mail/dest,var/vend)
		if(stat || !dest || dest.stat || !(mail in contents))
			FailedSend()
			return
		if(!mail.to_person)
			mail.dest_station.cache -= mail
			mail.dest_station.update_icon() // it is possible that dest_station != dest
		waiting -= mail
		if(dest == src) // happens when the hub is being used as a station
			Recieve(mail,vend)
			return
		return ..(mail,dest,vend)

	Recieve(var/obj/item/smallDelivery/MH,var/vend)
		if(!vend)
			//waiting += MH
			if(!MH.to_person && MH.dest_station != null)
				if(MH.dest_station != src)
					MH.dest_station.cache += MH
					MH.update_icon()
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)//Whiff is a nice sound for the mail system to make
					return
			if(MH.to_person && MH.dest != null)// Hub messaging service
				//cache += src
				MH.loc = src
				if(MH.label != "")
					MessagePersonnel(MH.dest, "You have recieved a package from <i>[MH.sender]</i> labelled <u>[MH.label]</u>.")
				else
					MessagePersonnel(MH.dest, "You have recieved a package from <i>[MH.sender]</i>.")

				visible_message("The [src] recieves a package.")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)//Whiff is a nice sound for the mail system to make
				return

		return ..(MH,vend)

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

/obj/machinery/vending/mail
	name = "Mail supplies"
	desc = "For all your packaging needs."
	icon = 'icons/WIP_Sayu.dmi'
	icon_state = "mailvend"
	product_ads = "The mail always delivers.;Doing our part when you're apart.;Don't forget to write home occasionally!"
	density = 0
	products = list(/obj/item/weapon/packageWrap = 2, /obj/item/stack/sheet/cardboard = 10, /obj/item/weapon/pen = 3, /obj/item/weapon/hand_labeler = 1)