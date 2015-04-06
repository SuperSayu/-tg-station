/obj/item/ammo_box/magazine/bananacreme
	name = "magazine (banana creme)"
	icon_state = "clown"
	ammo_type = /obj/item/ammo_casing/shotgun/dart/bananacreme
	caliber = "honk"
	max_ammo = 20
	origin_tech = null

/obj/item/ammo_casing/shotgun/dart/bananacreme
	name = "banana creme bullet casing"
	desc = "Isn't this just... a banana?"
	caliber = "honk"
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	projectile_type = /obj/item/projectile/reagent/bananacreme

/obj/item/ammo_casing/shotgun/dart/bananacreme/Crossed(AM as mob|obj)
	if(BB)
		return // not really a peel if it's full
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (isobj(M:shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the [name]!"
		playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(1)
		M.Weaken(1)
		if(prob(20))
			step_rand(src)