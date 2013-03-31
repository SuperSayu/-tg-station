/*
	Computer3 portable computer

	Runs programs off a removable drive only.

	When picked up, becomes an inert item, deploys to new location.
*/


/obj/item/device/laptop
	name		= "Laptop Computer"
	desc		= "A clamshell portable computer.  It is closed."
	icon		= 'icons/obj/device.dmi'
	icon_state	=  "laptop"
	pixel_x		= 2
	pixel_y		= -3

	var/obj/machinery/computer/laptop/stored_computer = null

	verb/Open_computer()
		set name = "Open laptop"
		set category = "Object"
		set src in view(1)

		if(!istype(loc,/turf))
			usr << "[src] is too bulky!  You'll have to set it down."
			return

		if(!stored_computer)
			if(contents.len)
				for(var/obj/O in contents)
					O.loc = loc


		stored_computer.loc = loc
		stored_computer.stat &= ~MAINT
		loc = null
		usr << "You open \the [src]."

		spawn(5)
			del src

	AltClick()
		Open_computer()

/obj/machinery/computer/laptop
	name = "Laptop Computer"
	desc = "A clamshell portable computer.  It is open."
	icon_state = "laptop"
	pixel_x		= 2
	pixel_y		= -3



	verb/Close_computer()
		set name = "Close laptop"
		set category = "Object"
		set src in view(1)

		if(istype(loc,/obj/item/device/laptop))
			testing("Close closed computer")
			return

		if(stat&BROKEN)
			usr << "\The [src] is broken!  You can't quite get it closed."
			return

		var/obj/item/device/laptop/L = new(loc)
		loc = L
		L.stored_computer = src
		stat |= MAINT
		usr << "You close \the [src]."

	AltClick()
		Close_computer()


/obj/machinery/computer/laptop/testing
	spawn_files = list(/datum/file/program/aifixer,/datum/file/program/arcade,/datum/file/program/atmos_alert,/datum/file/program/security,/datum/file/program/card_comp,
						/datum/file/camnet_key,/datum/file/camnet_key/mining,/datum/file/camnet_key/entertainment)
	spawn_parts = list(/obj/item/part/computer/storage/hdd/big,/obj/item/part/computer/ai_holder,/obj/item/part/computer/networking/radio,
						/obj/item/part/computer/networking/cameras,/obj/item/part/computer/card_reader)