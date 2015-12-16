
/obj/item/weapon/cloaking_device
	name = "cloaking device"
	desc = "Use this to become invisible to the human eyesocket."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	var/active = 0.0
	flags = CONDUCT
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = 2.0
	origin_tech = "magnets=3;syndicate=4"
	var/active_power_use = 15
	var/mob/living/cloaked_user = null
	var/obj/item/weapon/stock_parts/cell/bcell

	action_button_name = "Activate Cloak"

/obj/item/weapon/cloaking_device/New()
	..()
	SSobj.processing |= src
	bcell = new

/obj/item/weapon/cloaking_device/Del()
	active=0
	if(cloaked_user)
		cloaked_user.update_icons()
	SSobj.processing.Remove(src)
	..()

/obj/item/weapon/cloaking_device/process()
	if(!active || !istype(loc,/mob/living/carbon/human))
		if(active && !bcell.use(active_power_use))
			active = 0
			visible_message("[src] flickers back into view!")
		update_icon()
		return

	if(!bcell || !bcell.use(active_power_use))
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
		if(ismob(loc))
			cloaked_user = loc
		else
			cloaked_user = null

	if(cloaked_user && (cloaked_user.alpha > 20 || prob(42)))
		var/old_alpha = min(cloaked_user.alpha,64) // this was making us not cloak sometimes, better bring it down
		var/new_alpha = pick(0,old_alpha,10,10,20)
		if(cloaked_user.luminosity) new_alpha *= 2
		if(cloaked_user.alpha != new_alpha)
			animate(cloaked_user,alpha=new_alpha,time=5,loop=0,easing=BOUNCE_EASING)


/obj/item/weapon/cloaking_device/dropped(mob/user as mob)
	if(active) // did you seriously just drop an invisible thing
		spawn(5)
			update_icon()
		icon_state = null
	..()

/obj/item/weapon/cloaking_device/pickup(mob/user as mob)
	if(active)
		icon_state = initial(icon_state)
		spawn(5) // we are not yet inside you
			cloaked_user = user
			user.update_icons() // we want to be inside you
			update_icon()// yes we do
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
	if(bcell.charge < active_power_use && !active)
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