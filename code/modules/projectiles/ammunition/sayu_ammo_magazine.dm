/obj/item/ammo_box/magazine/bananacreme
	name = "magazine (banana creme)"
	icon_state = "clown"
	ammo_type = /obj/item/ammo_casing/shotgun/dart/bananacreme
	caliber = "honk"
	max_ammo = 20
	origin_tech = null
	icon = 'icons/obj/sayu_ammo.dmi'

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

		M.slip(1, 1, src)

		if(prob(20))
			step_rand(src)