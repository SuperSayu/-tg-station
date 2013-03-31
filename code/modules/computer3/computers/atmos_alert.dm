/obj/machinery/computer/atmos_alert
	name = "Atmospheric Alert Console"
	desc = "Used to access the station's atmospheric sensors."
	default_prog = /datum/file/program/atmos_alert
	spawn_parts = list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/radio)

/datum/file/program/atmos_alert
	name = "Atmospheric Alert Console"
	active_state = "alert:2"
	refresh = 1
	required_peripherals = list(/obj/item/part/computer/networking/radio)
	var/obj/item/part/computer/networking/radio/linked_component
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()

	Reset()
		..()
		if(!linked_component)
			linked_component = computer.get_peripheral(/obj/item/part/computer/networking/radio)
			if(!linked_component)
				computer.ProgramError(MISSING_PERIPHERAL)
		linked_component.filter = RADIO_ATMOSIA
		if(linked_component.radio_connection)
			linked_component.set_frequency(1437)
		else
			linked_component.frequency = 1437

		// Never save your work
		priority_alarms.Cut()
		minor_alarms.Cut()



	// This will be called as long as the program is running on the parent computer
	// and the computer has the radio peripheral
	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		var/zone = signal.data["zone"]
		var/severity = signal.data["alert"]
		if(!zone || !severity) return

		minor_alarms -= zone
		priority_alarms -= zone
		if(severity=="severe")
			priority_alarms += zone
		else if (severity=="minor")
			minor_alarms += zone
		update_icon()
		return


	interact()
		if(!computer || computer.stat) return
		if(!linked_component)
			linked_component = computer.get_peripheral(/obj/item/part/computer/networking/radio)
			if(!linked_component)
				computer.ProgramError(MISSING_PERIPHERAL)

		if(!popup)
			popup = new(usr, "atmos_alert", name)
			popup.set_title_image(usr.browse_rsc_icon(computer.icon, computer.icon_state))

		popup.set_content(return_text())
		popup.open()


	update_icon()
		..()
		computer.overlays -= overlay
		if(priority_alarms.len > 0)
			overlay.icon_state = "alert:2"
		else if(minor_alarms.len > 0)
			overlay.icon_state = "alert:1"
		else
			overlay.icon_state = "alert:0"
		computer.overlays |= overlay
		//computer.update_icon()


	proc/return_text()
		var/priority_text = "<h2>Priority Alerts:</h2>"
		var/minor_text = "<h2>Minor Alerts:</h2>"

		if(priority_alarms.len)
			for(var/zone in priority_alarms)
				priority_text += "<FONT color='red'><B>[format_text(zone)]</B></FONT> [topic_link(src,"priority_clear=[ckey(zone)]","X")]<BR>"
		else
			priority_text += "No priority alerts detected.<BR>"

		if(minor_alarms.len)
			for(var/zone in minor_alarms)
				minor_text += "<B>[format_text(zone)]</B> [topic_link(src,"minor_clear=[ckey(zone)]","X")]<BR>"
		else
			minor_text += "No minor alerts detected.<BR>"

		return "[priority_text]<BR><HR>[minor_text]<BR>[topic_link(src,"close","Close")]"


	Topic(href, href_list)
		if(href_list["priority_clear"])
			var/removing_zone = href_list["priority_clear"]
			for(var/zone in priority_alarms)
				if(ckey(zone) == removing_zone)
					usr << "\green Priority Alert for area [zone] cleared."
					priority_alarms -= zone

		if(href_list["minor_clear"])
			var/removing_zone = href_list["minor_clear"]
			for(var/zone in minor_alarms)
				if(ckey(zone) == removing_zone)
					usr << "\green Minor Alert for area [zone] cleared."
					minor_alarms -= zone

		if("close" in href_list)
			usr.unset_machine()
			popup.close()
			return

		//computer.add_fingerprint(usr) // seems unnecessary, it is not likely to be a crimescene piece
		computer.updateUsrDialog()
