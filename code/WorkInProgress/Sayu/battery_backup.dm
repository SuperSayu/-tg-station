// -------------------------------------
//    Power machinery - Normal cell
// -------------------------------------

/obj/machinery/power/backup
	name		= "Battery Backup"
	desc		= "Move power from the power network to a power cell, and back again."
	anchored	= 0
	density		= 1

	var/on			= 0 // in use
	var/charging	= 1 // 1: network to cell; 0: cell to network
	var/rate		= 5000
	var/obj/item/weapon/cell/battery = null

	attack_hand(mob/user as mob)
		charging = !charging
		user << "The device is now set to [charging?"charge from":"power"] the connected power cable."

	attackby(obj/item/I as obj,mob/user as mob)
		if(istype(I,/obj/item/weapon/crowbar) && battery)
			battery.loc = loc
			user << "You remove \the [battery]."
			battery = null
			return
		if(istype(I,/obj/item/weapon/wrench))
			anchored = !anchored
			user << "You [anchored?"secure":"unsecure"] \the [src] from the floor."
			return
		if(istype(I,/obj/item/weapon/cell) && !battery)
			battery = I
			user << "You insert [battery] into [src]."
			battery.loc = src
			return
		..()