/obj/item/weapon/shield
	name = "shield"

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "riot"
	flags = FPRINT | CONDUCT
	slot_flags = SLOT_BACK
	force = 5.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	g_amt = 7500
	m_amt = 1000
	origin_tech = "materials=2"
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time

	IsShield()
		return 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/melee/baton))
			if(cooldown < world.time - 25)
				user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
				playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
				cooldown = world.time
		else
			..()

/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	flags = FPRINT | CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 1
	origin_tech = "materials=4;magnets=3;syndicate=4"
	attack_verb = list("shoved", "bashed")
	var/active = 0

/obj/item/weapon/cloaking_device
	name = "cloaking device"
	desc = "Use this to become invisible to the human eyesocket."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	var/active = 0.0
	flags = FPRINT | CONDUCT
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = 2.0
	origin_tech = "magnets=3;syndicate=4"
	var/active_power_use = 15

	var/mob/living/cloaked_user = null
	var/obj/item/weapon/cell/battery

/obj/item/weapon/cloaking_device/New()
	..()
	processing_objects.Add(src)
	battery = new

/obj/item/weapon/cloaking_device/Del()
	active=0
	if(cloaked_user)
		cloaked_user.update_icons()
	..()

/obj/item/weapon/cloaking_device/process()
	if(!active || !istype(loc,/mob/living/carbon/human))
		if(active && !battery.use(active_power_use))
			active = 0
			visible_message("[src] flickers back into view!")
		update_icon()
		return

	if(!battery || !battery.use(active_power_use))
		if(active)
			if(istype(loc,/mob))
				loc.visible_message("[loc] flickers back into view!")
			else
				visible_message("[src] flickers back into view!")
			active = 0
			update_icon()
		return

	if(cloaked_user != loc)
		if(cloaked_user)
			cloaked_user.update_icons()
		cloaked_user = loc

	var/mob/living/carbon/human/H = cloaked_user
	H.overlays = list()
	var/image/I
	if(H.lying)
		// oh hey look they #undefine the constants outside of update_icons, that's nice
		I = H.overlays_lying[2] // left hand
		if(istype(I))
			H.overlays += I

		I = H.overlays_lying[1] // right hand
		if(istype(I))
			H.overlays += I
	else
		// oh hey look they #undefine the constants outside of update_icons, that's nice
		I = H.overlays_standing[2] // left hand
		if(istype(I))
			H.overlays += I

		I = H.overlays_standing[1] // right hand
		if(istype(I))
			H.overlays += I



/obj/item/weapon/cloaking_device/dropped(mob/user as mob)
	if(active) // did you seriously just drop an invisible thing
		spawn(5)
			update_icon()
		icon_state = null
	..()

/obj/item/weapon/cloaking_device/pickup(mob/user as mob)
	if(active)
		icon = initial(icon)
		icon_state = initial(icon_state)
		spawn(5) // we are not yet inside you
			cloaked_user = user
			user.update_icons() // we want to be inside you
				// yes we do
	..()
/obj/item/weapon/cloaking_device/on_enter_storage()
	if(active)
		icon_state = initial(icon_state)// it is dropped before entering the container, it would become irretrievable
		if(cloaked_user)
			cloaked_user.update_icons()
	..()
/*
// Not really needed because it should register a pickup() if it is now in someone's possession
/obj/item/weapon/cloaking_device/on_exit_storage()
	if(active)
		if(istype(loc,/mob))
			cloaked_user = mob
			cloaked_user.update_icons()
	..()
*/
/obj/item/weapon/cloaking_device/attack_self(mob/user as mob)
	if(battery.charge < active_power_use && !active)
		user << "You flip the switch, but nothing happens!"
		return
	src.active = !( src.active )
	if (src.active)
		user << "\blue The cloaking device is now active."
		cloaked_user = user
	else
		user << "\blue The cloaking device is now inactive."
	update_icon()
	src.add_fingerprint(user)
	return

/obj/item/weapon/cloaking_device/update_icon()
	if(active)
		if(isturf(loc))
			icon_state = null
			if(cloaked_user)
				cloaked_user.update_icons()
				cloaked_user = null
		else
			icon_state = "shield1"
			if(cloaked_user && cloaked_user != loc)
				cloaked_user.update_icons()
				cloaked_user = null
			if(ismob(loc))
				loc:update_icons()
				cloaked_user = loc
	else
		icon_state = "shield0"
		if(cloaked_user)
			cloaked_user.update_icons()
			cloaked_user = null

/obj/item/weapon/cloaking_device/emp_act(severity)
	active = pick(0,1)
	update_icon()
	..()
