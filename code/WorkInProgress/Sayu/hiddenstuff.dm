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


/obj/machinery/vending/sayu/innocuous
	name = "Admin-o-vend"
	desc = "This is what we play with when you aren't around."

	product_ads = "Hahahahaha.;You didn't need a soul anyway.;Trust me, they'll love it!;Mwahahahahahaha"
	products = list(/obj/item/weapon/storage/belt/utility/bluespace = 5, /obj/item/weapon/cell/infinite = 5,/obj/item/weapon/circuitboard/programmable = 5,
					/obj/item/weapon/circuitboard/mailstation = 5, /obj/item/weapon/circuitboard/mailhub = 2,
					/obj/item/toy/random = 10, /obj/item/weapon/spellbook = 5, /obj/item/weapon/reagent_containers/glass/bottle/random_chem = 10,
					/obj/item/weapon/storage/pill_bottle/random_meds = 10, /obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink = 10,
					/obj/item/weapon/grenade/chem_grenade/meat = 10, /obj/item/weapon/grenade/chem_grenade/dirt = 10, /obj/item/weapon/grenade/chem_grenade/soap = 10,
					/obj/item/weapon/grenade/clusterbuster/meat = 5, /obj/item/weapon/grenade/clusterbuster/booze = 5, /obj/item/weapon/grenade/clusterbuster/honk = 5,
					/obj/item/weapon/grenade/clusterbuster/xmas = 5, /obj/item/weapon/grenade/clusterbuster/aviary = 5, /obj/item/weapon/grenade/clusterbuster/fluffy = 5,
					/obj/item/weapon/grenade/clusterbuster/monkey = 5, /obj/item/weapon/grenade/clusterbuster/soap = 5, /obj/item/weapon/grenade/clusterbuster/dirt = 5,
					/obj/structure/largecrate/schrodinger = 1, /obj/structure/closet/syndicate/resources/everything = 1,/obj/item/weapon/research = 1)

/obj/machinery/vending/sayu/admin
	name = "Admin-o-vend"
	desc = "If you're seeing this, I should probably gib you.  Probably."
	product_ads = "Hahahahaha.;You didn't need a soul anyway.;Trust me, they'll love it!;Mwahahahahahaha"
	products = list(/obj/item/toy/random = 10, /obj/structure/largecrate/schrodinger = 5,
					/obj/item/weapon/reagent_containers/glass/bottle/random_reagent = 10, /obj/item/weapon/reagent_containers/glass/bottle/random_chem = 10, /obj/item/weapon/storage/pill_bottle/random_meds = 10,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink = 10, /obj/item/weapon/reagent_containers/food/drinks/bottle/random_reagent = 10,
					/obj/item/weapon/grenade/chem_grenade/meat = 10,/obj/item/weapon/grenade/chem_grenade/dirt = 10,/obj/item/weapon/grenade/chem_grenade/soap = 10,
					/obj/item/weapon/grenade/clusterbuster/meat = 5,/obj/item/weapon/grenade/clusterbuster/booze = 5,/obj/item/weapon/grenade/clusterbuster/honk = 5,
					/obj/item/weapon/grenade/clusterbuster/xmas = 5,/obj/item/weapon/grenade/clusterbuster/soap = 5,/obj/item/weapon/grenade/clusterbuster/dirt = 5,
					/obj/item/weapon/grenade/clusterbuster/aviary = 5, /obj/item/weapon/grenade/clusterbuster/fluffy = 5, /obj/item/weapon/grenade/clusterbuster/monkey = 5,
					/obj/item/weapon/grenade/clusterbuster/megadirt = 5,/obj/item/weapon/grenade/clusterbuster/inferno = 2,/obj/item/weapon/grenade/clusterbuster/apocalypse = 1,/obj/item/weapon/grenade/clusterbuster/apocalypse/fake = 2,
					/obj/item/weapon/storage/belt/utility/bluespace = 5, /obj/item/weapon/storage/belt/utility/bluespace/owlman = 1, /obj/item/weapon/storage/belt/utility/bluespace/admin = 5)
