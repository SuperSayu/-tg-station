/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

/** Fax machine functionality */

var/req_console_assistance = list()
var/req_console_supplies = list()
var/req_console_information = list()
var/list/obj/machinery/requests_console/allConsoles = list()

/obj/machinery/requests_console
	name = "requests console"
	desc = "A console intended to send requests to different departments on the station."
	anchored = 1
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp0"
	var/department = "Unknown" //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/messages = list() //List of all messages
	var/departmentType = 0
		// 0 = none (not listed, can only replied to)
		// 1 = assistance
		// 2 = supplies
		// 3 = info
		// 4 = ass + sup //Erro goddamn you just HAD to shorten "assistance" down to "ass"
		// 5 = ass + info
		// 6 = sup + info
		// 7 = ass + sup + info
	var/newmessagepriority = 0
		// 0 = no new message
		// 1 = normal priority
		// 2 = high priority
		// 3 = extreme priority - not implemented, will probably require some hacking... everything needs to have a hidden feature in this game.
	var/screen = 0
		// 0 = main menu,
		// 1 = req. assistance,
		// 2 = req. supplies
		// 3 = relay information
		// 4 = write msg - not used
		// 5 = choose priority - not used
		// 6 = sent successfully
		// 7 = sent unsuccessfully
		// 8 = view messages
		// 9 = authentication before sending
		// 10 = send announcement
		// 11 = send fax		{FAX}
	var/silent = 0 // set to 1 for it not to beep all the time
	var/hackState = 0
		// 0 = not hacked
		// 1 = hacked
	var/announcementConsole = 0
		// 0 = This console cannot be used to send department announcements
		// 1 = This console can send department announcements
	var/open = 0 // 1 if open
	var/announceAuth = 0 //Will be set to 1 when you authenticate yourself for announcements
	var/msgVerified = "" //Will contain the name of the person who verified it
	var/msgStamped = "" //If a message is stamped, this will contain the stamp name
	var/message = "";
	var/dpt = ""; //the department which will be receiving the message
	var/priority = -1 ; //Priority of the message being sent
	luminosity = 0

	var/obj/item/weapon/paper/copy = null			// {FAX} Enable it to hold a paper object to be faxed. Code borrowed from photocopier.dm
	var/obj/item/weapon/photo/photocopy = null		// {FAX} Enable it to hold a photo object to be faxed. Code borrowed from photocopier.dm


/obj/machinery/requests_console/power_change()
	..()
	update_icon()

/obj/machinery/requests_console/update_icon()
	if(open)
		if(hackState == 0)
			icon_state="req_comp_open"
		else
			icon_state="req_comp_rewired"
	else if(stat & NOPOWER)
		if(icon_state != "req_comp_off")
			icon_state = "req_comp_off"
	else
		if(newmessagepriority == 1)
			icon_state = "req_comp1"
		else if(newmessagepriority == 2)
			icon_state = "req_comp2"
		else if(newmessagepriority == 3)
			icon_state = "req_comp3"
		else
			icon_state = "req_comp0"

/obj/machinery/requests_console/New()
	name = "\improper [department] requests console"
	allConsoles += src
	//req_console_departments += department
	switch(departmentType)
		if(1)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
		if(2)
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
		if(3)
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(4)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
		if(5)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(6)
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(7)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
			if(!("[department]" in req_console_information))
				req_console_information += department


/obj/machinery/requests_console/attack_hand(var/mob/user)
	if(..(user))
		return
	var/dat = ""
	if(!open)
		switch(screen)
			if(1)	//req. assistance
				dat += "Which department do you need assistance from?<BR><BR>"
				dat += "<table width='100%'>"
				for(var/dpt in req_console_assistance)
					if (dpt != department)
						dat += "<tr>"
						dat += "<td width='55%'>[dpt]</td>"
						dat += "<td width='45%'><A href='?src=\ref[src];write=[ckey(dpt)]'>Normal</A> <A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High</A>"
						if (hackState == 1)
							dat += "<A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>"
						dat += "</td>"
						dat += "</tr>"
				dat += "</table>"
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back</A><BR>"

			if(2)	//req. supplies
				dat += "Which department do you need supplies from?<BR><BR>"
				dat += "<table width='100%'>"
				for(var/dpt in req_console_supplies)
					if (dpt != department)
						dat += "<tr>"
						dat += "<td width='55%'>[dpt]</td>"
						dat += "<td width='45%'><A href='?src=\ref[src];write=[ckey(dpt)]'>Normal</A> <A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High</A>"
						if (hackState == 1)
							dat += "<A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>"
						dat += "</td>"
						dat += "</tr>"
				dat += "</table>"
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back</A><BR>"

			if(3)	//relay information
				dat += "Which department would you like to send information to?<BR><BR>"
				dat += "<table width='100%'>"
				for(var/dpt in req_console_information)
					if (dpt != department)
						dat += "<tr>"
						dat += "<td width='55%'>[dpt]</td>"
						dat += "<td width='45%'><A href='?src=\ref[src];write=[ckey(dpt)]'>Normal</A> <A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High</A>"
						if (hackState == 1)
							dat += "<A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>"
						dat += "</td>"
						dat += "</tr>"
				dat += "</table>"
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back</A><BR>"

			if(6)	//sent successfully
				dat += "<span class='good'>Message sent.</span><BR><BR>"
				dat += "<A href='?src=\ref[src];setScreen=0'>Continue</A><BR>"

			if(7)	//unsuccessful; not sent
				dat += "<span class='bad'>An error occurred.</span><BR><BR>"
				dat += "<A href='?src=\ref[src];setScreen=0'>Continue</A><BR>"

			if(8)	//view messages
				for (var/obj/machinery/requests_console/Console in allConsoles)
					if (Console.department == department)
						Console.newmessagepriority = 0
						Console.update_icon()
						Console.luminosity = 1
				newmessagepriority = 0
				update_icon()
				var/messageComposite = ""
				for(var/msg in messages) // This puts more recent messages at the *top*, where they belong.
					messageComposite = "<div class='block'>[msg]</div>" + messageComposite
				dat += messageComposite
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back to Main Menu</A><BR>"

			if(9)	//authentication before sending
				dat += "<B>Message Authentication</B><BR><BR>"
				dat += "<b>Message for [dpt]: </b>[message]<BR><BR>"
				dat += "<div class='notice'>You may authenticate your message now by scanning your ID or your stamp</div><BR>"
				dat += "<b>Validated by:</b> [msgVerified ? msgVerified : "<i>Not Validated</i>"]<br>"
				dat += "<b>Stamped by:</b> [msgStamped ? msgStamped : "<i>Not Stamped</i>"]<br><br>"
				dat += "<A href='?src=\ref[src];department=[dpt]'>Send Message</A><BR>"
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Discard Message</A><BR>"

			if(10)	//send announcement
				dat += "<h3>Station-wide Announcement</h3>"
				if(announceAuth)
					dat += "<div class='notice'>Authentication accepted</div><BR>"
				else
					dat += "<div class='notice'>Swipe your card to authenticate yourself</div><BR>"
				dat += "<b>Message: </b>[message ? message : "<i>No Message</i>"]<BR>"
				dat += "<A href='?src=\ref[src];writeAnnouncement=1'>[message ? "Edit" : "Write"] Message</A><BR><BR>"
				if (announceAuth && message)
					dat += "<A href='?src=\ref[src];sendAnnouncement=1'>Announce Message</A><BR>"
				else
					dat += "<span class='linkOff'>Announce Message</span><BR>"
				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back</A><BR>"

			if(11)	//send Fax {FAX}

				//Check for source document
				if(copy || photocopy)
					dat += "Fax to which department?<BR><BR>"
					dat += "<table width='100%'>"
					for(var/dpt in req_console_information)		//We're piggybacking on this list because implementing a separate list of faxable consoles would require a lot of refactoring
						if (dpt != department)
							dat += "<tr>"
							dat += "<td width='55%'>[dpt]</td>"
							dat += "<td width='45%'><A href='?src=\ref[src];sendFax=[ckey(dpt)]'>Send</A>"
							dat += "</td>"
							dat += "</tr>"
					dat += "</table>"
					dat += "<BR><a href='byond://?src=\ref[src];remove=1'>Remove Document</a><BR>"		//Adapted from photocopier.dm
				else
					dat += "You must insert a source document before you can fax it."

				dat += "<BR><A href='?src=\ref[src];setScreen=0'><< Back</A><BR>"

			else	//main menu
				screen = 0
				announceAuth = 0
				if (newmessagepriority == 1)
					dat += "<div class='notice'>There are new messages</div><BR>"
				if (newmessagepriority == 2)
					dat += "<div class='notice'>There are new <b>PRIORITY</b> messages</div><BR>"
				if (newmessagepriority == 3)
					dat += "<div class='notice'>There are new <b>EXTREME PRIORITY</b> messages</div><BR>"
				dat += "<A href='?src=\ref[src];setScreen=8'>View Messages</A><BR><BR>"

				dat += "<A href='?src=\ref[src];setScreen=1'>Request Assistance</A><BR>"
				dat += "<A href='?src=\ref[src];setScreen=2'>Request Supplies</A><BR>"
				dat += "<A href='?src=\ref[src];setScreen=11'>Send Fax Transmission</A><BR><BR>"		//{FAX}
				dat += "<A href='?src=\ref[src];setScreen=3'>Relay Anonymous Information</A><BR><BR>"
				if(announcementConsole)
					dat += "<A href='?src=\ref[src];setScreen=10'>Send Station-wide Announcement</A><BR><BR>"
				if (silent)
					dat += "Speaker <A href='?src=\ref[src];setSilent=0'>OFF</A>"
				else
					dat += "Speaker <A href='?src=\ref[src];setSilent=1'>ON</A>"

		//user << browse("[dat]", "window=request_console")
		//onclose(user, "req_console")
		var/datum/browser/popup = new(user, "req_console", "[department] Requests Console", 450, 440)
		popup.set_content(dat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
	return

/obj/machinery/requests_console/Topic(href, href_list)
	if(..())	return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(reject_bad_text(href_list["write"]))
		dpt = ckey(href_list["write"]) //write contains the string of the receiving department's name

		var/new_message = copytext(reject_bad_text(input(usr, "Write your message:", "Awaiting Input", "")),1,MAX_MESSAGE_LEN)
		if(new_message)
			message = new_message
			screen = 9
			if (text2num(href_list["priority"]) < 2)
				priority = -1
			else
				priority = text2num(href_list["priority"])
		else
			dpt = "";
			msgVerified = ""
			msgStamped = ""
			screen = 0
			priority = -1

	if(href_list["writeAnnouncement"])
		var/new_message = copytext(reject_bad_text(input(usr, "Write your message:", "Awaiting Input", "")),1,MAX_MESSAGE_LEN)
		if(new_message)
			message = new_message
			if (text2num(href_list["priority"]) < 2)
				priority = -1
			else
				priority = text2num(href_list["priority"])
		else
			message = ""
			announceAuth = 0
			screen = 0

	if(href_list["sendAnnouncement"])
		if(!announcementConsole)	return
		minor_announce(message, "[department] Announcement:")
		news_network.SubmitArticle(message, department, "Station Announcements", null)
		announceAuth = 0
		message = ""
		screen = 0

	if( href_list["department"] && message )
		var/log_msg = message
		var/sending = message
		sending += "<br>"
		if (msgVerified)
			sending += msgVerified
			sending += "<br>"
		if (msgStamped)
			sending += msgStamped
			sending += "<br>"
		screen = 7 //if it's successful, this will get overrwritten (7 = unsufccessfull, 6 = successfull)
		if (sending)
			var/pass = 0
			for (var/obj/machinery/message_server/MS in world)
				if(!MS.active) continue
				MS.send_rc_message(href_list["department"],department,log_msg,msgStamped,msgVerified,priority)
				pass = 1

			if(pass)

				for (var/obj/machinery/requests_console/Console in allConsoles)
					if (ckey(Console.department) == ckey(href_list["department"]))
						switch(priority)
							if(2)		//High priority
								Console.createmessage(src, "PRIORITY Alert in [department]", sending, 2, 1)
							if(3)		// Extreme Priority
								Console.createmessage(src, "EXTREME PRIORITY Alert in [department]", sending, 3, 1)
							else		// Normal priority
								Console.createmessage(src, "Message from [department]", sending, 1, 1)

						screen = 6
						Console.luminosity = 2

				switch(priority)
					if(2)
						messages += "<span class='bad'>High Priority</span><BR><b>To:</b> [dpt]<BR>[sending]"
					else
						messages += "<b>To: [dpt]</b><BR>[sending]"
			else
				for (var/mob/O in hearers(4, src.loc))
					O.show_message("\icon[src] *The Requests Console beeps: 'NOTICE: No server detected!'")


	if(href_list["remove"])			//{FAX} Yet another chunk copied from photocopier.dm
		if(copy)
			if(!istype(usr,/mob/living/silicon/ai)) //ai cannot eject
				copy.loc = usr.loc
				usr.put_in_hands(copy)
			else
				copy.loc = src.loc
			usr << "<span class='notice'>You eject [copy] from of [src].</span>"
			copy = null
			updateUsrDialog()
		else if(photocopy)
			if(!istype(usr,/mob/living/silicon/ai)) //ai cannot eject
				photocopy.loc = usr.loc
				usr.put_in_hands(photocopy)
			else
				photocopy.loc = src.loc
			usr << "<span class='notice'>You eject [photocopy] from [src].</span>"
			photocopy = null
			updateUsrDialog()


	if(href_list["sendFax"])		//{FAX} obviously, handles sending faxes. Based on "write" handler. Includes watered down photocopier copy code.
		dpt = ckey(href_list["sendFax"]) //sendFax contains the string of the receiving department's name

		//Figure out what to log
		var/loggable = "Fax transmission"
		if (copy)
			var/stripped = replacetext(strip_tags(replacetext(copy.info, "<br>", "&lt;br&gt;")), "&lt;br&gt;", "<br>") // This should remove the tags entirely with adminscrub or strip_html but neither seem to work.
			loggable = "Faxed document: [stripped]"
		if (photocopy)
			loggable = "Faxed photograph: [photocopy.desc]"		//Log server needs modification to properly log images, so log descriptions instead.

		//Confirm a server can relay the request (borrowed from "department" above)
		var/pass = 0
		for (var/obj/machinery/message_server/MS in world)
			if(!MS.active) continue
			//{FAX} Message server can only log strings, so log faxes as strings
			MS.send_rc_message(href_list["sendFax"],department,loggable,0,0,1)
			pass = 1
		if(pass)

			//Play the fax sound locally
			if(!silent)
				playsound(loc, 'sound/machines/56k.ogg', 50, 0)

			//Find every receiving requests_console and create a copy on them.
			for (var/obj/machinery/requests_console/Console in allConsoles)
				if (ckey(Console.department) == ckey(href_list["sendFax"]))

					//Play the fax sound remotely
					if(!Console.silent)
						playsound(Console.loc, 'sound/machines/56k.ogg', 50, 0)
						for (var/mob/O in hearers(5, Console.loc))
							O.show_message("\icon[Console] *The Requests Console beeps: 'New Fax in [department]'")

					if(copy)
						//{FAX} Only ever make one copy, no delays to worry about
						var/obj/item/weapon/paper/c = new /obj/item/weapon/paper (Console.loc)
						if(length(copy.info) > 0)	//Only print and add content if the copied doc has words on it
							//{FAX} Removed toner shenanigans
							//TODO: Cover letter on faxes?
							var/copied = copy.info
							copied = replacetext(copied, "<font face=\"[c.deffont]\" color=", "<font face=\"[c.deffont]\" nocolor=")	//state of the art techniques in action
							copied = replacetext(copied, "<font face=\"[c.crayonfont]\" color=", "<font face=\"[c.crayonfont]\" nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
							c.info += copied
							c.info += "</font>"
							c.name = copy.name
							c.fields = copy.fields
							c.updateinfolinks()
						updateUsrDialog()
					else if(photocopy)
						//{FAX} Again, number of copies to make
						var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (Console.loc)
						var/icon/I = icon(photocopy.icon, photocopy.icon_state)
						var/icon/img = icon(photocopy.img)
						I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0)) //I'm not sure how expensive this is, but given the many limitations of photocopying, it shouldn't be an issue.
						img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
						p.icon = I
						p.img = img
						p.name = photocopy.name
						p.desc = photocopy.desc
						p.scribble = photocopy.scribble
						p.pixel_x = rand(-10, 10)
						p.pixel_y = rand(-10, 10)
						p.blueprints = photocopy.blueprints //a copy of a picture is still good enough for the syndicate
			//Success, go to sent screen and eject the paperwork
			screen = 6
			if(copy)
				if(!istype(usr,/mob/living/silicon/ai)) //ai cannot eject
					copy.loc = usr.loc
					usr.put_in_hands(copy)
				else
					copy.loc = src.loc
				usr << "<span class='notice'>You eject [copy] from of [src].</span>"
				copy = null
				updateUsrDialog()
			else if(photocopy)
				if(!istype(usr,/mob/living/silicon/ai)) //ai cannot eject
					photocopy.loc = usr.loc
					usr.put_in_hands(photocopy)
				else
					photocopy.loc = src.loc
				usr << "<span class='notice'>You eject [photocopy] from [src].</span>"
				photocopy = null
				updateUsrDialog()
		else
			screen = 7
			for (var/mob/O in hearers(4, src.loc))
				O.show_message("\icon[src] *The Requests Console beeps: 'NOTICE: No server detected!'")



	//Handle screen switching
	switch(text2num(href_list["setScreen"]))
		if(null)	//skip
		if(1)		//req. assistance
			screen = 1
		if(2)		//req. supplies
			screen = 2
		if(3)		//relay information
			screen = 3
//		if(4)		//write message
//			screen = 4
		if(5)		//choose priority
			screen = 5
		if(6)		//sent successfully
			screen = 6
		if(7)		//unsuccessfull; not sent
			screen = 7
		if(8)		//view messages
			screen = 8
		if(9)		//authentication
			screen = 9
		if(10)		//send announcement
			if(!announcementConsole)	return
			screen = 10
		if(11)		//{FAX}
			screen = 11
		else		//main menu
			dpt = ""
			msgVerified = ""
			msgStamped = ""
			message = ""
			priority = -1
			screen = 0

	//Handle silencing the console
	switch( href_list["setSilent"] )
		if(null)	//skip
		if("1")	silent = 1
		else	silent = 0

	updateUsrDialog()
	return

/obj/machinery/requests_console/proc/createmessage(source, title, message, priority, paper)
	var/linkedsender
	var/unlinkedsender
	if(istype(source, /obj/machinery/requests_console))
		var/obj/machinery/requests_console/sender = source
		linkedsender = "<a href='?src=\ref[src];write=[ckey(sender.department)]'>[sender.department]</a>"
		unlinkedsender = sender.department
	else
		capitalize(source)
		linkedsender = source
		unlinkedsender = source
	capitalize(title)
	switch(priority)
		if(2)		//High priority
			if(src.newmessagepriority < 2)
				src.newmessagepriority = 2
				src.update_icon()
			if(!src.silent)
				playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
				for (var/mob/O in hearers(5, src.loc))
					O.show_message("\icon[src] *The Requests Console beeps: '[title]'")
				src.messages += "<span class='bad'>High Priority</span><BR><b>From:</b> [linkedsender]<BR>[message]"
			if(paper)
				var/obj/item/weapon/paper/slip = new /obj/item/weapon/paper(src.loc)
				slip.info = "<span class='bad'>High Priority</span><BR><b>From:</b> [unlinkedsender]<BR>[message]"
				slip.name = "Important Message - [source]"

		if(3)		// Extreme Priority
			if(src.newmessagepriority < 3)
				src.newmessagepriority = 3
				src.update_icon()
			if(1)
				playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
				for (var/mob/O in hearers(7, src.loc))
					O.show_message("\icon[src] *The Requests Console yells: '[title]'")
			src.messages += "<span class='bad'>!!!Extreme Priority!!!</span><BR><b>From:</b> [linkedsender]<BR>[message]"
			var/obj/item/weapon/paper/slip = new /obj/item/weapon/paper(src.loc)
			if(paper)
				slip.info = "<span class='bad'>!!!Extreme Priority!!!</span><BR><b>From:</b> [unlinkedsender]<BR>[message]"
				slip.name = "URGENT message - [unlinkedsender]"
				var/mob/living/target = locate() in view(7,src)
				if(target)
					src.visible_message("<span class='danger'>[src] launches [slip] at [target]!</span>")
					slip.throw_at(target, 16, 3)

		else		// Normal priority
			if(src.newmessagepriority < 1)
				src.newmessagepriority = 1
				src.update_icon()
			if(!src.silent)
				playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
				for (var/mob/O in hearers(4, src.loc))
					O.show_message("\icon[src] *The Requests Console beeps: '[title]'")
			src.messages += "<b>From:</b> [linkedsender]<BR>[message]"
			if(paper)
				var/obj/item/weapon/paper/slip = new /obj/item/weapon/paper(src.loc)
				slip.info = "<b>From:</b> [unlinkedsender]<BR>[message]"
				slip.name = "Message - [unlinkedsender]"
	src.luminosity = 2

/obj/machinery/requests_console/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/weapon/crowbar))
		if(open)
			user << "You close the maintenance panel."
			open = 0
			icon_state="req_comp0"
		else
			user << "You open the maintenance panel."
			open = 1
			if(hackState == 0)
				icon_state="req_comp_open"
			else if(hackState == 1)
				icon_state="req_comp_rewired"
	if (istype(O, /obj/item/weapon/screwdriver))
		if(open)
			if(hackState == 0)
				user << "You modify the wiring."
				hackState = 1
				icon_state="req_comp_rewired"
			else if(hackState == 1)
				user << "You reset the wiring."
				hackState = 0
				icon_state="req_comp_open"
		else
			user << "You can't do much with that."
	update_icon()

	var/obj/item/weapon/card/id/ID = O.GetID()
	if (ID)
		if(screen == 9)
			msgVerified = "<font color='green'><b>Verified by [ID.registered_name] ([ID.assignment])</b></font>"
			updateUsrDialog()
		if(screen == 10)
			if (access_RC_announce in ID.access)
				announceAuth = 1
			else
				announceAuth = 0
				user << "<span class='danger'>You are not authorized to send announcements.</span>"
			updateUsrDialog()
	if (istype(O, /obj/item/weapon/stamp))
		if(screen == 9)
			var/obj/item/weapon/stamp/T = O
			msgStamped = "<span class='boldnotice'>Stamped with the [T.name]</span>"
			updateUsrDialog()


	//{FAX} Code ported over from photocopier.dm to allow insertion and removal of documents
	if(istype(O, /obj/item/weapon/paper))
		if(copier_empty())
			user.drop_item()
			copy = O
			O.loc = src
			user << "<span class='notice'>You insert [O] into [src].</span>"
			updateUsrDialog()
		else
			user << "<span class='notice'>There is already something in [src].</span>"
	else if(istype(O, /obj/item/weapon/photo))
		if(copier_empty())
			user.drop_item()
			photocopy = O
			O.loc = src
			user << "<span class='notice'>You insert [O] into [src].</span>"
			updateUsrDialog()
		else
			user << "<span class='notice'>There is already something in [src].</span>"


	return





/obj/machinery/requests_console/proc/copier_empty()
	if(copy || photocopy)
		return 0
	else
		return 1
