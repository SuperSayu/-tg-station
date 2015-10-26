/obj/structure/closet/secure_closet/mime
	name = "Mime's Closet"
	req_access = list(access_theatre)

/obj/structure/closet/secure_closet/mime/New()
	..()
	if(prob(35))
		new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing( src )
	new /obj/item/clothing/under/actorsuit/mime( src )
	new /obj/item/clothing/mask/gas/mime( src )
	new /obj/item/clothing/shoes/sneakers/mime( src )
	new /obj/item/weapon/bedsheet/mime( src )

/obj/structure/closet/secure_closet/clown
	name = "Clown's Closet"
	req_access = list(access_theatre)

/obj/structure/closet/secure_closet/clown/New()
	..()
	new /obj/item/weapon/grown/bananapeel/research( src )
	new /obj/item/weapon/storage/backpack/clown(src)
	new /obj/item/clothing/under/actorsuit/clown( src )
	new /obj/item/clothing/mask/gas/clown_hat( src )
	new /obj/item/clothing/shoes/clown_shoes( src )
	new /obj/item/weapon/bedsheet/clown( src )

/obj/structure/closet/secure_closet/medical_wall
	name = "first aid closet"
	desc = "It's a secure wall-mounted storage unit for first aid supplies."
	icon_state = "medical_wall"
	anchored = 1
	density = 0
	wall_mounted = 1
	req_access = list(access_medical)

/obj/structure/closet/secure_closet/medical_wall/hop

/obj/structure/closet/secure_closet/medical_wall/hop/New()
	..()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen
	new /obj/item/weapon/reagent_containers/pill/antihol(src)
	new /obj/item/weapon/reagent_containers/pill/antihol(src)

/obj/structure/closet/crate/hydroponics/mystery

/obj/structure/closet/crate/hydroponics/mystery/New()
	..()
	var/list/mysteryseeds = typesof(/obj/item/seeds)
	var/list/boringseeds = list(/obj/item/seeds,/obj/item/seeds/weeds, /obj/item/seeds/cornseed, /obj/item/seeds/kudzuseed, /obj/item/seeds/plumpmycelium, /obj/item/seeds/poisonedappleseed, /obj/item/seeds/deathnettleseed, /obj/item/seeds/deathberryseed)
	mysteryseeds -= boringseeds
	for(var/i in 1 to 4)
		var/typekey = pick_n_take(mysteryseeds)
		new typekey(src)

//RCS sending code
/obj/structure/closet/proc/use_rcs(var/obj/item/weapon/rcs/E, mob/user as mob)
	if(E.rcharges != 0)
		if(E.mode == 0)
			if(!E.teleporting)
				var/list/L = list()
				var/list/areaindex = list()
				for(var/obj/machinery/telepad_cargo/R in world)
					if(R.stage == 0)
						var/turf/T = get_turf(R)
						var/tmpname = T.loc.name
						if(areaindex[tmpname])
							tmpname = "[tmpname] ([++areaindex[tmpname]])"
						else
							areaindex[tmpname] = 1
						L[tmpname] = R
				var/desc = input("Please select a telepad.", "RCS") in L
				E.pad = L[desc]
				playsound(E.loc, 'sound/machines/click.ogg', 50, 1)
				user << "\blue Teleporting [src.name]..."
				E.teleporting = 1
				sleep(50)
				E.teleporting = 0
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				do_teleport(src, E.pad, 0)
				E.rcharges--
				if(E.rcharges != 1)
					user << "\blue Teleport successful. [E.rcharges] charges left."
					E.desc = "Use this to send crates and closets to cargo telepads. There are [E.rcharges] charges left."
					return
				else
					user << "\blue Teleport successful. [E.rcharges] charge left."
					E.desc = "Use this to send crates and closets to cargo telepads. There is [E.rcharges] charge left."
				return
		else
			E.rand_x = rand(50,200)
			E.rand_y = rand(50,200)
			var/L = locate(E.rand_x, E.rand_y, 6)
			playsound(E.loc, 'sound/machines/click.ogg', 50, 1)
			user << "\blue Teleporting [src.name]..."
			E.teleporting = 1
			sleep(50)
			E.teleporting = 0
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, src)
			s.start()
			do_teleport(src, L)
			E.rcharges--
			if(E.rcharges != 1)
				user << "\blue Teleport successful. [E.rcharges] charges left."
				E.desc = "Use this to send crates and closets to cargo telepads. There are [E.rcharges] charges left."
				return
			else
				user << "\blue Teleport successful. [E.rcharges] charge left."
				E.desc = "Use this to send crates and closets to cargo telepads. There is [E.rcharges] charge left."
				return
	else
		user << "\red Out of charges."
		return

/obj/structure/closet/proc/attempt_hack(var/obj/item/weapon/multitool, mob/user as mob)
	src.add_fingerprint(user)
	if(!broken)
		playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 150, 1)
		user << "<span class='danger'>You begin hacking the locker open. (This action will take 20 seconds to complete.)</span>"
		if(do_after(user,200, target = src) && hacking_panel_uncovered) // makes sure that the user stays in place and does not close the panel
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, src)
			s.start()
			broken = 1
			locked = 0
			desc = "It appears to be broken."
			visible_message("<span class='warning'>The locker has been broken by [user] with a multitool!</span>")
			update_icon()
	else
		playsound(src.loc, 'sound/machines/twobeep.ogg', 150, 1)
		user << "<span class='danger'>You begin repairing the broken locker. (This action will take 30 seconds to complete.)</span>"
		if(do_after(user,300, target = src) && hacking_panel_uncovered) // longer than hacking it open for reasons
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, src)
			s.start()
			broken = 0
			locked = 0
			desc = initial(desc)
			visible_message("<span class='warning'>The locker has been repaired by [user] with a multitool!</span>")
			update_icon()