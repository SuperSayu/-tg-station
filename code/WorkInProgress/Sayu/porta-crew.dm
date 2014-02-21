/obj/item/device/portacrew
	name = "Crew Monitor"
	desc = "Monitors crew status on the go."
	icon = 'icons/obj/computer.dmi'
	icon_state = "medlaptop"

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
		crewmonitor(usr)

	process()
		updateUsrDialog()

	Topic(href, href_list)
		if( href_list["close"] )
			usr << browse(null, "window=portacrew")
			usr.unset_machine()
			return
		src.interact()
		return

/obj/item/device/portacrew/ai
	action_button_name = "show crew monitor"