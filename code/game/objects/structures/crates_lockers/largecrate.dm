/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "densecrate"
	density = 1
	flags = FPRINT

/obj/structure/largecrate/attack_hand(mob/user as mob)
	user << "<span class='notice'>You need a crowbar to pry this open!</span>"
	return

/obj/structure/largecrate/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/crowbar))
		new /obj/item/stack/sheet/wood(src)
		var/turf/T = get_turf(src)
		for(var/obj/O in contents)
			O.loc = T
		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='notice'>You hear splitting wood.</span>")
		del(src)
	else
		return attack_hand(user)

/obj/structure/largecrate/mule
	icon_state = "mulecrate"

/obj/structure/largecrate/cat/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/cat(loc)
		new /obj/item/weapon/pet_collar(loc)
	..()

/obj/structure/largecrate/lisa
	name = "corgi crate"
	icon_state = "lisacrate"
	var/global/lisa = 1

/obj/structure/largecrate/lisa/attackby(obj/item/weapon/W as obj, mob/user as mob)	//ugly but oh well
	if(istype(W, /obj/item/weapon/crowbar))
		if(lisa)
			new /mob/living/simple_animal/corgi/Lisa(loc)
			lisa = 0
		else
			if(prob(50)) // 50% adult corgi
				if(prob(80)) // net 40% renamable gender-ambiguous woofers
					new /mob/living/simple_animal/corgi(loc)
					new /obj/item/weapon/pet_collar(loc)
				else // net 10% dainty bow dog
					new /mob/living/simple_animal/corgi/Lisa(loc)
			else	// 50% child corgi
				if(prob(80)) // net 40% normal puppy
					new /mob/living/simple_animal/corgi/puppy(loc)
					new /obj/item/weapon/pet_collar(loc)
				else	// net 10% smart girl
					new /mob/living/simple_animal/corgi/puppy/sgt_pepper{name="corgi puppy";real_name="corgi";icon_state = "puppy";icon_living = "puppy";icon_dead = "puppy_dead";renamable=1}(loc)
					new /obj/item/weapon/pet_collar(loc)
	..()

/obj/structure/largecrate/pug
	icon_state = "lisacrate"

/obj/structure/largecrate/pug/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/pug(loc)
		new /obj/item/weapon/pet_collar(loc)
	..()

/obj/structure/largecrate/cow
	name = "cow crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/cow/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/cow(loc)
		new /obj/item/weapon/pet_collar(loc)
	..()

/obj/structure/largecrate/goat
	name = "goat crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/goat/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/hostile/retaliate/goat(loc)
		new /obj/item/weapon/pet_collar(loc)
	..()

/obj/structure/largecrate/chick
	name = "chicken crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/chick/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/crowbar))
		var/num = rand(4, 6)
		for(var/i = 0, i < num, i++)
			new /mob/living/simple_animal/chick(loc)
		new /obj/item/weapon/pet_collar(loc)
		new /obj/item/weapon/pet_collar(loc)
	..()
