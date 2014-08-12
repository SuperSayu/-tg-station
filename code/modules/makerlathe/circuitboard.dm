
/obj/item/weapon/circuitboard/maker
	name = "circuit board (Makerlathe)"
	var/hacked = 0
	var/hackable = 0 // board must be tweaked while installed
	build_path = /obj/machinery/maker
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 3,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)
/obj/item/weapon/circuitboard/maker/attackby(var/obj/item/device/multitool/M, var/mob/user)
	if(istype(M))
		if(hackable)
			hacked = !hacked
			user << "<span class='notice'>You toggle the extended programmable stock chip on [src].  It will [hacked?"now":"no longer"] provide extra recipes.</span>"
		else
			user << "<span class='notice'>The dataport on [src] is disabled, and you cannot enable it while the board is de-powered.</span>"
	return

/obj/item/weapon/circuitboard/maker/examine()
	..()
	if(hackable)
		usr << "The dataport is open; a multitool might connect to it."
	else
		usr << "The dataport is disabled, and you cannot enable it while the board is de-powered."
	var/l = "off"
	if(hacked)
		l = "on"
	usr << "The light next to the extended stock chip is [l]."

/obj/item/weapon/circuitboard/maker/engine
	name = "circuit board (engilathe)"
	build_path = /obj/machinery/maker/engine

/obj/item/weapon/circuitboard/maker/biolathe
	name = "circuit board (biolathe)"
	build_path = /obj/machinery/maker/biolathe
