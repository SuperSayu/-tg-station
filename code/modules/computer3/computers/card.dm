/obj/machinery/computer/card
	name = "Identification Console"
	desc = "You can use this to change ID's."

	default_prog = /datum/file/program/card_comp
	spawn_parts = list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/card_reader)


/obj/item/part/computer/card_reader
	name	= "Magnetic card reader"
	desc	= "Contains slots for inserting magnetic swipe cards for reading and writing."
	var/obj/item/weapon/card/id/writer	= null
	var/obj/item/weapon/card/id/reader	= null

	// todo: model with only one card insert.  This can be emulated in software, however.

	proc/insert(var/obj/item/weapon/card/id/card,var/slot = 0)
		if(!computer)
			return 0
		if(slot == 1)				// 1: writer
			if(writer != null)
				return 0
			var/mob/living/L = usr
			L.drop_item()
			card.loc = src
			writer = card
			return 1
		else if(slot == 2)			// 2: reader
			if(reader != null)
				return 0
			var/mob/living/L = usr
			L.drop_item()
			card.loc = src
			reader = card
			return 1
		else						// 0: auto
			if(reader && writer)
				return 0
			var/mob/living/L = usr
			L.drop_item()
			card.loc = src
			if(reader || (!(access_change_ids in card.access) && !writer)) // Put non-auth cards in writer if possible
				writer = card
				return 1
			if(!reader)
				reader = card
				return 1
			return 0

	proc/remove(var/obj/item/weapon/card/id/card, var/mob/user)
		if(card != reader && card != writer) return

		if(card == reader) reader = null
		if(card == writer) writer = null
		card.loc = loc

		if(ishuman(user) && !user.get_active_hand())
			user.put_in_hands(card)


/datum/file/program/card_comp
	name			= "ID Card Console"
	desc			= "Used to modify magnetic strip ID cards."
	image			= 'icons/NTOS/cardcomp.png'
	active_state	= "id"
	required_peripherals = list(/obj/item/part/computer/card_reader)
	var/obj/item/part/computer/card_reader/linked_reader = null
	var/obj/item/part/computer/networking/database/linked_db = null
	var/mode = 0
	var/auth = 0
	var/printing = 0

	attackby(O as obj, user as mob)
		if(!linked_reader)
			linked_reader = locate() in computer.peripherals
			if(!linked_reader)
				return 0

		if(!istype(O,/obj/item/weapon/card/id))
			return 0

		linked_reader.insert(O)


	proc/list_jobs()
		return get_all_jobs() + "Custom"

	// creates the block with the script in it
	// cache the result since it's almost constant but not quite
	// the list of jobs won't change after all...
	proc/scriptblock()
		var/global/dat = null
		if(!dat)
			var/jobs_all = ""
			for(var/job in list_jobs())
				jobs_all += topic_link(src,"assign=[job]",replacetext(job," ","&nbsp;")) + " "//make sure there isn't a line break in the middle of a job
			dat = {"<script type="text/javascript">
					function markRed(){
						var nameField = document.getElementById('namefield');
						nameField.style.backgroundColor = "#FFDDDD";
					}
					function markGreen(){
						var nameField = document.getElementById('namefield');
						nameField.style.backgroundColor = "#DDFFDD";
					}
					function showAll(){
						var allJobsSlot = document.getElementById('alljobsslot');
						allJobsSlot.innerHTML = "<a href='#' onclick='hideAll()'>hide</a><br>[jobs_all]";
					}
					function hideAll(){
						var allJobsSlot = document.getElementById('alljobsslot');
						allJobsSlot.innerHTML = "<a href='#' onclick='showAll()'>change</a>";
					}
				</script>"}
		return dat

	// creates the list of access rights on the card
	proc/accessblock()
		var/accesses = "<div align='center'><b>Access</b></div>"
		accesses += "<table style='width:100%'>"
		accesses += "<tr>"
		for(var/i = 1; i <= 7; i++)
			accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
		accesses += "</tr><tr>"
		for(var/i = 1; i <= 7; i++)
			accesses += "<td style='width:14%' valign='top'>"
			for(var/A in get_region_accesses(i))
				if(A in linked_reader.writer.access)
					accesses += topic_link(src,"access=[A]","<font color='red'>[replacetext(get_access_desc(A), " ", "&nbsp")]</font>") + " "
				else
					accesses += topic_link(src,"access=[A]",replacetext(get_access_desc(A), " ", "&nbsp")) + " "
				accesses += "<br>"
			accesses += "</td>"
		accesses += "</tr></table>"
		return accesses

	proc/card_modify_menu()
		//assume peripherals and cards, do checks for them in interact

		// Header
		var/dat = "<div align='center'><br>"
		dat += topic_link(src,"remove=writer","Remove [linked_reader.writer.name]") + " || "
		dat += topic_link(src,"remove=reader","Remove [linked_reader.reader.name]") + " <br> "
		dat += topic_link(src,"mode=1","Access Crew Manifest") + " || "
		dat += topic_link(src,"logout","Log Out") + "</div>"
		dat += "<hr>" + scriptblock()

		// form for renaming the ID
		dat += "<form name='cardcomp' action='byond://' method='get'>"
		dat += "<input type='hidden' name='src' value='\ref[src]'>"
		dat += "<b>registered_name:</b> <input type='text' id='namefield' name='reg' value='[linked_reader.writer.registered_name]' style='width:250px; background-color:white;' onchange='markRed()'>"
		dat += "<input type='submit' value='Rename' onclick='markGreen()'>"
		dat += "</form>"

		// form for changing assignment, taken care of by scriptblock() mostly
		var/assign_temp = linked_reader.writer.assignment
		if(!assign_temp || assign_temp == "") assign_temp = "Unassigned"
		dat += "<b>Assignment:</b> [assign_temp] <span id='alljobsslot'><a href='#' onclick='showAll()'>change</a></span>"

		// list of access rights
		dat += accessblock()

		return dat

	proc/login_menu()
		var/dat = "<br><i>Please insert the cards into the slots</i><br>"
		// Assume linked_reader since called by interact()
		if(linked_reader.writer)
			dat += "Target: [topic_link(src,"remove=writer",linked_reader.writer.name)]<br>"
		else
			dat += "Target: [topic_link(src,"insert=writer","--------")]<br>"

		if(linked_reader.reader)
			dat += "Confirm Identity: [topic_link(src,"remove=reader",linked_reader.reader.name)]<br>"
		else
			dat += "Confirm Identity: [topic_link(src,"insert=reader","--------")]<br>"
		dat += "[topic_link(src,"auth","{Log in}")]<br><hr>"
		dat += topic_link(src,"mode=1","Access Crew Manifest")
		return dat

	proc/show_manifest()
		// assume linked_db since called by interact()
		var/crew = ""
		var/list/L = list()
		for (var/datum/data/record/t in data_core.general)
			var/R = t.fields["name"] + " - " + t.fields["rank"]
			L += R
		for(var/R in sortList(L))
			crew += "[R]<br>"
		return "<tt><b>Crew Manifest:</b><br>Please use security record computer to modify entries.<br><br>[crew][topic_link(src,"print","Print")]<br><br>[topic_link(src,"mode=0","Access ID modification console.")]<br></tt>"

	// These are here partly in order to be overwritten by the centcom card computer code
	proc/authenticate()
		if(access_change_ids in linked_reader.reader.access)
			return 1
		if(istype(usr,/mob/living/silicon/ai))
			return 1
		return 0

	proc/set_default_access(var/jobname)
		var/datum/job/jobdatum
		for(var/jobtype in typesof(/datum/job))
			var/datum/job/J = new jobtype
			if(ckey(J.title) == ckey(jobname))
				jobdatum = J
				break
		if(jobdatum)
			linked_reader.writer.access = jobdatum.get_access() // ( istype(src,/obj/machinery/computer/card/centcom) ? get_centcom_access(t1)


	interact()
		var/dat
		if(!linked_reader)
			linked_reader = computer.get_peripheral(/obj/item/part/computer/card_reader)
		if(linked_reader)
			switch(mode)
				if(0)
					if(!linked_reader.reader || !linked_reader.writer)
						auth = 0
					if(!auth)
						dat = login_menu()
					else
						dat = card_modify_menu()
				if(1)
					dat = show_manifest()
		else
			computer.ProgramError(MISSING_PERIPHERAL)
			return

		if(!popup)
			popup = new /datum/browser(usr, "id_com", "Identification Card Modifier", 900, 520)
			popup.set_title_image(usr.browse_rsc_icon(computer.icon, computer.icon_state))

		popup.set_content(dat)
		popup.open()
		return


	Topic(href, list/href_list)
		// todo distance/disability checks

		if("mode" in href_list)
			mode = text2num(href_list["mode"])
			if(mode != 0 && mode != 1)
				mode = 0

			auth = 0 // always log out if switching modes just in case

		if("remove" in href_list)
			var/which = href_list["remove"]
			if(which == "writer")
				linked_reader.remove(linked_reader.writer,usr)
			else
				linked_reader.remove(linked_reader.reader,usr)
			auth = 0

		if("insert" in href_list)
			var/obj/item/weapon/card/id/card = usr.get_active_hand()
			if(!istype(card)) return

			var/which = href_list["insert"]
			if(which == "writer")
				linked_reader.insert(card,1)
			else
				linked_reader.insert(card,2)

		if("print" in href_list)
			if (printing)
				return

			printing = 1
			sleep(50)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( computer.loc )
			P.info = "<B>Crew Manifest:</B><BR>"
			var/list/L = list()
			for (var/datum/data/record/t in data_core.general)
				var/R = t.fields["name"] + " - " + t.fields["rank"]
				L += R
			for(var/R in sortList(L))
				P.info += "[R]<br>"
			P.name = "paper- 'Crew Manifest'"
			printing = 0

		if("auth" in href_list)
			auth = 0
			if(linked_reader.reader && linked_reader.writer && authenticate())
				auth = 1

		if("logout" in href_list)
			auth = 0

		// Actual ID changing

		if("access" in href_list)
			if(auth)
				var/access_type = text2num(href_list["access"])
				linked_reader.writer.access ^= list(access_type)		//logical xor: remove if present, add if not

		if("assign" in href_list)
			if (auth)
				var/t1 = href_list["assign"]
				if(t1 == "Custom")
					var/temp_t = copytext(sanitize(input("Enter a custom job assignment.","Assignment")),1,MAX_MESSAGE_LEN)
					if(temp_t)
						t1 = temp_t
				set_default_access(t1)

				linked_reader.writer.assignment = t1
				linked_reader.writer.name = text("[linked_reader.writer.registered_name]'s ID Card ([linked_reader.writer.assignment])")

		if("reg" in href_list)
			if(auth)
				linked_reader.writer.registered_name = href_list["reg"]
				linked_reader.writer.name = text("[linked_reader.writer.registered_name]'s ID Card ([linked_reader.writer.assignment])")

		computer.updateUsrDialog()
		return



/obj/machinery/computer/card/centcom
	name = "CentCom Identification Console"
	default_prog = /datum/file/program/card_comp/centcom


/datum/file/program/card_comp/centcom
	name = "CentCom Identification Console"
	drm = 1

	list_jobs()
		return get_all_centcom_jobs() + "Custom"

	accessblock()
		var/accesses = "<h5>Central Command:</h5>"
		for(var/A in get_all_centcom_access())
			if(A in linked_reader.writer.access)
				accesses += topic_link(src,"access=[A]","<font color='red'>[replacetext(get_centcom_access_desc(A), " ", "&nbsp")]</font>") + " "
			else
				accesses += topic_link(src,"access=[A]",replacetext(get_centcom_access_desc(A), " ", "&nbsp")) + " "
		return accesses

	authenticate()
		if(access_cent_captain in linked_reader.reader.access)
			return 1
		return 0