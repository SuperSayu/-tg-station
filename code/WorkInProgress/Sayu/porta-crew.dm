/obj/item/device/portacrew
	name = "Crew Monitor"
	desc = "Monitors crew status on the go."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_off"

	var/list/tracked = list()

	New()
		..()
		processing_objects.Add(src)

	attack_self()
		interact()
	attack_ai()
		interact()

	interact()
		if(!loc)
			usr << browse(null, "window=portacrew")
			return
		if(istype(loc,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = loc
			if(!R.activated(src))
				usr << browse(null, "window=portacrew")
				return
		usr.set_machine(src)
		src.scan()
		var/t = ""
		t += "<BR><A href='?src=\ref[src];update=1'>Refresh</A> "
		t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		t += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='30%'><h3>Vitals</h3></td><td width='30%'><h3>Position</h3></td></tr>"
		var/list/logs = list()
		var/turf/T = get_turf(loc)
		for(var/obj/item/clothing/under/C in src.tracked)
			var/log = ""
			var/turf/pos = get_turf(C)
			if((C) && (C.has_sensor) && (pos) && (pos.z == T.z) && C.sensor_mode)
				if(istype(C.loc, /mob/living/carbon/human))

					var/mob/living/carbon/human/H = C.loc
					var/obj/item/weapon/card/id/ID = null

					if(H.wear_id)
						ID = H.wear_id.GetID()

					var/dam1 = round(H.getOxyLoss(),1)
					var/dam2 = round(H.getToxLoss(),1)
					var/dam3 = round(H.getFireLoss(),1)
					var/dam4 = round(H.getBruteLoss(),1)

					var/life_status = "[H.stat > 1 ? "<span class='bad'>Deceased</span>" : "<span class='good'>Living</span>"]"
					var/damage_report = "(<font color='teal'>[dam1]</font>/<font color='green'>[dam2]</font>/<font color='orange'>[dam3]</font>/<font color='red'>[dam4]</font>)"

					if(ID)
						log += "<tr><td width='40%'>[ID.registered_name] ([ID.assignment])</td>"
					else
						log += "<tr><td width='40%'>Unknown</td>"

					switch(C.sensor_mode)
						if(1)
							log += "<td width='20%'>[life_status]</td><td width='30%'>Not Available</td></tr>"
						if(2)
							log += "<td width='20%'>[life_status] [damage_report]</td><td width='30%'>Not Available</td></tr>"
						if(3)
							var/area/player_area = get_area(H)
							var/dist = round(get_dist(pos,T),5)
							var/direct = dir2text(get_dir(T,pos))
							log += "<td width='40%'>[life_status] [damage_report]</td><td width='30%'>[format_text(player_area.name)] ([dist] [direct])</td></tr>"
			logs += log
		logs = sortList(logs)
		for(var/log in logs)
			t += log
		t += "</table>"
		var/datum/browser/popup = new(usr, "portacrew", name, 800, 500)
		popup.set_content(t)
		popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()

	proc/scan()
		for(var/obj/item/clothing/under/C in world)
			if((C.has_sensor) && (istype(C.loc, /mob/living/carbon/human)))
				src.tracked |= C
			else
				src.tracked -= C
		return 1

	process()
		updateUsrDialog()

	Topic(href, href_list)
		if( href_list["close"] )
			usr << browse(null, "window=portacrew")
			usr.unset_machine()
			return
		src.interact()
		return
