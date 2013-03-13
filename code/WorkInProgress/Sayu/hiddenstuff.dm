/obj/structure/closet/New()
	if(istype(src,/obj/structure/closet/secure_closet) || istype(src,/obj/structure/closet/crate/secure) || istype(src,/obj/structure/closet/bodybag) || istype(src,/obj/structure/closet/coffin) || istype(src,/obj/structure/closet/lasertag) || istype(src,/obj/structure/closet/fireaxecabinet))
		return
	if(usr)
		return // built not spawned
	var/area/A = get_area(src)
	if(istype(A,/area/supply))
		return // no booze in supply crates

	//Can be found in any valid locker or crate
	var/list/private_stache = list(	/obj/item/weapon/reagent_containers/food/drinks/beer,
						/obj/item/weapon/reagent_containers/food/drinks/bottle/rum, // Not gone yet, captain
						/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater,
						/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink,
						/obj/item/toy/random,/obj/item/candle,/obj/item/device/camera,
						/obj/item/clothing/tie/medal/conduct,/obj/item/clothing/tie/medal/silver/valor,/obj/item/clothing/tie/medal/gold/heroism,
						/obj/item/weapon/spacecash/c10,/obj/item/weapon/spacecash/c20)

	//Maintenance and private locations
	var/list/hidden_loot = list(/obj/item/weapon/grenade/chem_grenade/dirt,/obj/item/weapon/grenade/chem_grenade/meat,
						/obj/item/weapon/grenade/clusterbuster/booze,/obj/item/weapon/grenade/clusterbuster/honk,/obj/item/weapon/reagent_containers/glass/bottle/random_reagent,
						/obj/item/device/transfer_valve,/obj/item/device/assembly/mousetrap/armed,/obj/item/weapon/soap,/obj/item/weapon/grenade/chem_grenade/lube,
						/obj/item/weapon/grenade/clusterbuster/monkey,/obj/item/weapon/grenade/clusterbuster/aviary) + private_stache
	var/list/trash = typesof(/obj/item/trash) - /obj/item/trash + list(/obj/item/weapon/bananapeel,/obj/item/weapon/corncob,/obj/item/weapon/ectoplasm)


	if(istype(A,/area/maintenance))
		while(prob(max(5,30 - src.contents.len * 2)))
			var/T = pick(trash)
			new T(src)
		while(prob(max(5,55 - src.contents.len * 5)))
			var/T = pick(hidden_loot)
			new T(src)
	else if(istype(A,/area/toxins/test_area))
		while(prob(66))
			var/T = pick(pick(hidden_loot,private_stache,trash))
			new T(src)
	else if(istype(A,/area/crew_quarters))
		if(prob(35))
			var/T = pick(trash)
			new T(src)
		while(prob(15))
			var/T = pick(hidden_loot)
			new T(src)
	else
		if(prob(15))
			var/T = pick(trash)
			new T(src)
		while(prob(10))
			//small chance of hidden booze
			var/T = pick(private_stache)
			new T(src)
	..()
