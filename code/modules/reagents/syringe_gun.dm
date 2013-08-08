


/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/max_syringes = 1
	m_amt = 2000
	fire_sound = 'sound/items/syringeproj.ogg'

	examine()
		set src in view()
		..()
		if(!(usr in view(2)) && usr != loc)
			return
		usr << "[contents.len] / [max_syringes] syringes."

	load_into_chamber()
		if(in_chamber) return in_chamber
		if(!contents.len) return 0
		var/obj/item/O = contents[1]
		in_chamber = new /obj/item/projectile/reagent(src, O)
		return in_chamber

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/weapon/reagent_containers/syringe))
			if(contents.len < max_syringes)
				user.drop_item()
				I.loc = src
				user << "<span class='notice'>You put [I] in [src].</span>"
				user << "<span class='notice'>[contents.len] / [max_syringes] syringes.</span>"
			else
				usr << "<span class='notice'>[src] cannot hold more syringes.</span>"



/obj/item/weapon/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to four syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 4


/*
	Having made syringe guns work properly now blowguns are going to work the shitty way syringe guns used to
	because they don't actually have gun code in them
*/
/*
/obj/effect/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

	New()
		create_reagents(15)
*/
/obj/item/clothing/mask/blowgun
	name = "cigar-shaped tube"
	desc = "A hollow device around the right shape and size to fire syringes if you blow hard enough."
	flags = TABLEPASS|USEDELAY|FPRINT // We have to add usedelay to get afterattack at distance for some reason
	icon_state = "cigaroff"
	item_state = "cigaroff"
	var/obj/item/weapon/reagent_containers/syringe/ammo = null

/obj/item/clothing/mask/blowgun/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		if(!ammo)
			user.drop_item()
			I.loc = src
			ammo = I
			user << "<span class='notice'>You put [I] in [src].</span>"
		else
			usr << "<span class='notice'>[src] cannot hold another syringe.</span>"


/obj/item/clothing/mask/blowgun/afterattack(atom/target, mob/living/user)
	if((!isturf(target) && !isturf(target.loc)) || target == user) return

	if(istype(user) && (CLUMSY in user.mutations) && prob(40))
		if(ammo)
			user << "<span class='danger'>You accidentally suck [ammo] out of [src] instead of blowing it out the other end!</span>"
			fire_syringe(user, user)
		else
			user << "<span class='warning'>You fumble the [src] for a moment before dropping it on the ground!</span>"
			user.drop_item()
		return

	if(ammo)
		spawn(0) fire_syringe(target,user)
	else
		usr << "<span class='notice'>[src] is empty.</span>"


/obj/item/clothing/mask/blowgun/proc/fire_syringe(atom/target, mob/user)
	if(!ammo || !target || !user) return

	var/obj/item/projectile/reagent/P = new(src,ammo)
	ammo = null
	P.kill_count = 4 // low range
	var/turf/start = get_turf(user)
	var/turf/end = get_turf(target)

	P.shot_from = src
	P.firer = usr

	playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

	if(start == end)			//Fire the projectile
		target.bullet_act(P)
		del(P)
		return

	P.original = target
	P.starting = start
	P.current = target
	P.yo = end.y - start.y
	P.xo = end.x - start.x

	user.next_move = max(world.time + 4, user.next_move + 2)

	spawn()
		P && P.process()