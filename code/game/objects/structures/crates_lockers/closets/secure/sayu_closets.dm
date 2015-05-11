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
	New()
		..()
		var/list/mysteryseeds = typesof(/obj/item/seeds)
		var/list/boringseeds = list(/obj/item/seeds,/obj/item/seeds/weeds, /obj/item/seeds/cornseed, /obj/item/seeds/kudzuseed, /obj/item/seeds/plumpmycelium, /obj/item/seeds/poisonedappleseed, /obj/item/seeds/deathnettleseed, /obj/item/seeds/deathberryseed)
		mysteryseeds -= boringseeds
		for(var/i in 1 to 4)
			var/typekey = pick_n_take(mysteryseeds)
			new typekey(src)