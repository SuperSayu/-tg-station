/proc/seedify(var/obj/item/O as obj, var/t_max, var/bag_seeds = 0)
	var/t_amount = 0
	if(t_max == -1)
		t_max = rand(1,4)
	var/obj/item/weapon/storage/bag/seeds/bag = null

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
		if(bag_seeds)
			for(var/obj/item/weapon/storage/bag/seeds/S in O.loc)
				if(!istype(S) || S.contents.len >= S.storage_slots) continue
				if(S.seedtype == null || S.seedtype == F.seed)
					bag = S
					t_max = min(t_max,S.storage_slots - S.contents.len)
					break
			if(!bag)
				bag = new/obj/item/weapon/storage/bag/seeds(O.loc)
		while(t_amount < t_max)
			var/obj/item/seeds/t_prod = new F.seed(O.loc)
			t_prod.species = F.species
			t_prod.lifespan = F.lifespan
			t_prod.endurance = F.endurance
			t_prod.maturation = F.maturation
			t_prod.production = F.production
			t_prod.yield = F.yield
			t_prod.potency = F.potency
			if(bag)
				bag.handle_item_insertion(t_prod)
			t_amount++
		del(O)
		if(bag)
			bag.update_icon()
		return 1

	else if(istype(O, /obj/item/weapon/grown/))
		var/obj/item/weapon/grown/F = O
		if(bag_seeds)
			for(var/obj/item/weapon/storage/bag/seeds/S in O.loc)
				if(!istype(S) || S.contents.len >= S.storage_slots) continue
				if(S.seedtype == null || S.seedtype == F.seed)
					bag = S
					t_max = min(t_max,S.storage_slots - S.contents.len)
					break
			if(!bag)
				bag = new/obj/item/weapon/storage/bag/seeds(O.loc)
		while(t_amount < t_max)
			var/obj/item/seeds/t_prod = new F.seed(O.loc)
			t_prod.species = F.species
			t_prod.lifespan = F.lifespan
			t_prod.endurance = F.endurance
			t_prod.maturation = F.maturation
			t_prod.production = F.production
			t_prod.yield = F.yield
			t_prod.potency = F.potency
			if(bag)
				bag.handle_item_insertion(t_prod)
			t_amount++
		del(O)
		if(bag)
			bag.update_icon()
		return 1

	else
		return 0


/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1

obj/machinery/seed_extractor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(isrobot(user))
		return
	user.drop_item()
	if(O && O.loc)
		O.loc = src.loc
	if(seedify(O,-1,1))
		user << "<span class='notice'>You extract some seeds.</span>"
	else if(!istype(O,/obj/item/weapon/storage/bag/seeds)) // which silently fails
		user << "<span class='notice'>You can't extract any seeds from that!</span>"