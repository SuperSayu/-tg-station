
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
			user << "The dataport on [src] is disabled, and you cannot enable it while the board is de-powered."
	return

/obj/item/weapon/circuitboard/maker/engine
	name = "circuit board (engilathe)"
	build_path = /obj/machinery/maker/engine

/obj/item/weapon/circuitboard/maker/biogen
	name = "circuit board (biolathe)"
	build_path = /obj/machinery/maker/biogen

/obj/item/weapon/circuitboard/maker/circuit
	name = "circuit board (circuit printer)"
	build_path = /obj/machinery/maker/circuit