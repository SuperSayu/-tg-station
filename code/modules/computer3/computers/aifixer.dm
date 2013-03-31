/obj/machinery/computer/aifixer
	name = "AI System Integrity Restorer"
	default_prog = /datum/file/program/aifixer
	req_access	= list(access_captain, access_robotics, access_heads)
	spawn_parts	= list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/ai_holder)


/datum/file/program/aifixer
	name			= "AI System Integrity Restorer"
	image			= 'icons/NTOS/airestore.png'
	active_state	= "ai-fixer-empty"

	required_peripherals = list(/obj/item/part/computer/ai_holder)
	var/obj/item/part/computer/ai_holder/linked_component = null

	attackby(I as obj, user as mob)
		if(!linked_component)
			linked_component = locate() in computer.peripherals
		if(istype(I, /obj/item/device/aicard) && linked_component)
			I:transfer_ai("AIFIXER","AICARD",linked_component,user)
			update_icon()
	update_icon()
		var/global/list/possible_overlays = list(
			image('icons/obj/computer3.dmi',icon_state="ai-fixer-empty"),
			image('icons/obj/computer3.dmi',icon_state="ai-fixer-full"),
			image('icons/obj/computer3.dmi',icon_state="ai-fixer-404"))

		if(!linked_component)
			return // what

		if(!linked_component.occupant)
			overlay.icon_state = "ai-fixer-empty"
		else
			if (linked_component.occupant.health >= 0 && linked_component.occupant.stat == 2)
				overlay.icon_state = "ai-fixer-full"
			else
				overlay.icon_state = "ai-fixer-404"
		//computer.update_icon()

	attack_hand(var/mob/user as mob)
		if(computer.check_peripherals(required_peripherals))
			if(ishuman(usr))//Checks to see if they are ninja
				if(!linked_component)
					linked_component = locate() in computer.peripherals

				if(linked_component && istype(usr:gloves, /obj/item/clothing/gloves/space_ninja) && usr:gloves:candrain && !usr:gloves:draining)
					if(usr:wear_suit:s_control)
						usr:wear_suit.transfer_ai("AIFIXER","NINJASUIT",linked_component,usr)
					else
						usr << "\red <b>ERROR</b>: \black Remote access channel disabled."
					return
		..() // -> interact

	interact()
		if(!linked_component)
			linked_component = computer.get_peripheral(/obj/item/part/computer/ai_holder)
			if(!linked_component)
				computer.ProgramError(MISSING_PERIPHERAL)
				return

		if(!popup)
			popup = new(usr, "\ref[computer]", "AI System Integrity Restorer", 400, 500)
			popup.set_title_image(usr.browse_rsc_icon(computer.icon, computer.icon_state))
		popup.set_content(aifixer_menu())
		popup.open()
		return

	proc/aifixer_menu()
		var/dat = ""
		if (linked_component.occupant)
			var/laws
			dat += "<h3>Stored AI: [linked_component.occupant.name]</h3>"
			dat += "<b>System integrity:</b> [(linked_component.occupant.health+100)/2]%<br>"

			if (linked_component.occupant.laws.zeroth)
				laws += "<b>0:</b> [linked_component.occupant.laws.zeroth]<BR>"

			var/number = 1
			for (var/index = 1, index <= linked_component.occupant.laws.inherent.len, index++)
				var/law = linked_component.occupant.laws.inherent[index]
				if (length(law) > 0)
					laws += "<b>[number]:</b> [law]<BR>"
					number++

			for (var/index = 1, index <= linked_component.occupant.laws.supplied.len, index++)
				var/law = linked_component.occupant.laws.supplied[index]
				if (length(law) > 0)
					laws += "<b>[number]:</b> [law]<BR>"
					number++

			dat += "<b>Laws:</b><br>[laws]<br>"

			if (linked_component.occupant.stat == 2)
				dat += "<span class='bad'>AI non-functional</span>"
			else
				dat += "<span class='good'>AI functional</span>"
			if (!linked_component.busy)
				dat += "<br><br>[topic_link(src,"fix","Begin Reconstruction")]"
			else
				dat += "<br><br>Reconstruction in process, please wait.<br>"
		dat += "<br>[topic_link(src,"close","Close")]"
		return dat

	Topic(href, href_list)
		if(..())
			return

		if ("fix" in href_list)
			linked_component.busy = 1
			computer.overlays += image('icons/obj/computer.dmi', "ai-fixer-on")
			while (linked_component.occupant.health < 100)
				if(!computer || computer.stat)
					break

				linked_component.occupant.adjustOxyLoss(-1)
				linked_component.occupant.adjustFireLoss(-1)
				linked_component.occupant.adjustToxLoss(-1)
				linked_component.occupant.adjustBruteLoss(-1)
				linked_component.occupant.updatehealth()
				if (linked_component.occupant.health >= 0 && linked_component.occupant.stat == 2)
					linked_component.occupant.stat = 0
					linked_component.occupant.lying = 0
					dead_mob_list -= linked_component.occupant
					living_mob_list += linked_component.occupant
					update_icon()
				computer.updateUsrDialog()
				sleep(10)
			linked_component.busy = 0
			computer.overlays -= image('icons/obj/computer.dmi', "ai-fixer-on")

		if("close" in href_list)
			usr.unset_machine()
			popup.close()
			return

		computer.add_fingerprint(usr)
		computer.updateUsrDialog()
		return
