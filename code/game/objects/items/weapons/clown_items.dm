/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peals
 */
/obj/item/weapon/bananapeel/HasEntered(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (isobj(M:shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the [name]!"
		playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(4)
		M.Weaken(2)
		if(prob(33))
			step_rand(src)

/*
 * Soap
 */
/obj/item/weapon/soap/HasEntered(AM as mob|obj) //EXACTLY the same as bananapeel for now, so it makes sense to put it in the same dm -- Urist
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (isobj(M:shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the [name]!"
		playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(3)
		M.Weaken(2)
		uses--
		if(uses <= 0)
			del(src) // you probably didn't notice, since it was underfoot
		else if(prob(80))
			step_rand(src)

/obj/item/weapon/soap/afterattack(atom/target, mob/user as mob)
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		user << "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>"
	else if(istype(target,/obj/effect/decal/cleanable))
		user << "<span class='notice'>You scrub \the [target.name] out.</span>"
		src.uses--
		del(target)
		if(src.uses<=0)
			user << "<span class='notice'>That's the last of this bar of soap.</span>"
			del(src)
	else if(istype(target,/obj/structure) || istype(target,/obj/machinery))
		return // I'm pretty sure these never get stained so you'd waste good soap on them
	else
		user << "<span class='notice'>You clean \the [target.name].</span>"
		target.clean_blood()
		src.uses--
		if(src.uses<=0)
			user << "<span class='notice'>That's the last of this bar of soap.</span>"
			del(src)
	return

/obj/item/weapon/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("\red \the [user] washes \the [target]'s mouth out with soap!")
		src.uses--
		if(src.uses<=0)
			user << "<span class='notice'>That's the last of this bar of soap.</span>"
			del(src)
		return
	//..()
	return
/obj/item/weapon/soap/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/weapon/kitchenknife) || istype(I,/obj/item/weapon/kitchen/utensil/knife) || istype(I,/obj/item/weapon/butch))
		//Split the soap in two.  Other bladed implements could do this, but it would be pretty awkward.  That's my excuse...
		if(uses <= 5)
			user << "You try to split the soap in twain, but end up destroying it."
			del src
		else
			user << "You split the bar of soap down the middle."
			var/newuses = round(uses/2) - 1
			uses = newuses
			new type(user.loc)
		return
	..()
/obj/item/weapon/soap/examine()
	..()
	usr << "\blue It has [uses] uses left."

/*
 * Bike Horns
 */
/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return