/obj/item/weapon/gun/projectile/automatic/clown
	name = "\improper clown machine gun"
	desc = "A lightweight, fast firing gun, for when you REALLY need someone honked.  Idiot-proofed to prevent malfunctions."
	icon_state = "clown"
	item_state = "clowngun"
	w_class = 3.0
	mag_type = /obj/item/ammo_box/magazine/bananacreme
	fire_sound = 'sound/items/bikehorn.ogg'
	clumsy_check = 0
	origin_tech = null
	icon = 'icons/obj/sayu_gun.dmi'
	pin = /obj/item/device/firing_pin


	New()
		..()
		update_icon()
		return

	update_icon()
		..()
		if(magazine)
			icon_state = "clown-[round(get_ammo(0),4)]"
		else
			icon_state = "clown"
		return