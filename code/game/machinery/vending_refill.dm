// Refillable vending machines (finally) by Sayu

/obj/machinery/vending/refillable
	var/scan_id_insert = 0 // by default you can only fill it with what it already has, which is safe-ish
	var/list/inserted = list()

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/weapon/card/emag))
			emagged = 1
			extended_inventory = !extended_inventory
			if(coin_records.len)
				hidden_records += coin_records
				coin_records.Cut()
				contraband += premium
				premium.Cut()
			user << "You short out the product lock on [src]"
			if(coin)
				coin.loc = loc
				user << "\blue[coin] pops out!"
				coin = null
			updateUsrDialog()
			return 1
		else if(istype(W, /obj/item/weapon/screwdriver))
			panel_open = !panel_open
			user << "You [panel_open ? "open" : "close"] the maintenance panel."
			overlays.Cut()
			if(panel_open)
				overlays += image(icon, "[initial(icon_state)]-panel")
			updateUsrDialog()
			return 1
		else if(istype(W, /obj/item/device/multitool)||istype(W, /obj/item/weapon/wirecutters))
			if(panel_open)
				attack_hand(user)
				return 1
		else if(istype(W, /obj/item/weapon/coin) && premium.len > 0)
			user.drop_item()
			W.loc = src
			coin = W
			user << "<span class='notice'>You insert [W] into [src].</span>"
			return 1
		else
			if(allow_insert(W, user))
				insert(W, user)
				updateUsrDialog()
				return 1
			else
				..()
				return 1

	proc/allow_insert(var/obj/item/I, var/mob/user)
		if(scan_id_insert && !allowed(user))
			return 0
		var/searchlist = products
		if(extended_inventory)
			searchlist += contraband
		return (I.type in searchlist)

	proc/insert(var/obj/item/I, var/mob/user)
		var/datum/data/vending_product/target_vend = null
		for(var/datum/data/vending_product/VP in product_records + hidden_records)
			if(VP.product_path == I.type)
				target_vend = VP
				break
		if(!target_vend)
			target_vend = new(I,0)
			target_vend.artificial = 1
			product_records += target_vend
			products += I.type // for allow_insert checks

		target_vend.amount++

		if(user)
			user.drop_item()

			if((target_vend in hidden_records) && !extended_inventory)	// This won't usually come up
				user << "\blue You insert [I] into [src], but it doesn't show up on the list."
			else
				user << "\blue You insert [I] into [src]."
			I.add_fingerprint(user)
			add_fingerprint(user)

		inserted += I
		I.loc = src

	vend(var/typepath, var/atom/newloc = loc)
		var/obj/O = locate(typepath) in inserted
		if(O)
			O.loc = newloc
			inserted -= O
			return O
		else
			return new typepath(loc)

/obj/machinery/vending/refillable/generic
	name = "Do-it-yourself Vend-o-mat"
	desc = "Filled with dreams--YOUR dreams.  Which is to say, empty."
	allow_insert(var/obj/item/I)
		if(istype(I))
			return 1
		return 0
	New()
		..()
		if(!istype(loc,/turf))
			anchored = 0


/obj/machinery/vending/refillable/theatre
	name = "\improper Prop Storage"
	desc = "Contains various props and toys; access to some has been restricted."
	req_access_txt = "46" // access_theatre
	products = list(/obj/item/weapon/lipstick = 1, /obj/item/weapon/lipstick/black = 1, /obj/item/weapon/lipstick/jade = 1, /obj/item/weapon/lipstick/purple = 1,
					/obj/item/weapon/razor = 1, /obj/item/toy/gun = 2, /obj/item/toy/ammo/gun = 4,/obj/item/weapon/gun/energy/laser/practice = 2,
					/obj/item/toy/snappop = 10)
	premium = list(/obj/item/clothing/under/actorsuit = 2)
	contraband = list( /obj/item/toy/sword = 3, /obj/item/toy/crossbow = 2, /obj/item/toy/blink, /obj/item/toy/spinningtoy)

// Modified version of previous
/obj/machinery/vending/refillable/cart
	name = "\improper PTech"
	desc = "PTech: Personal Technology for Personnel & Transients"
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	wheeled = 0
	req_access_txt = "15" // access_change_id
	scan_id_insert = 1

	products = list(/obj/item/device/pda = 10,
					/obj/item/weapon/card/id = 10, /obj/item/weapon/card/id/silver = 5,

					/obj/item/weapon/cartridge/medical = 5,/obj/item/weapon/cartridge/chemistry = 5,/obj/item/weapon/cartridge/engineering = 5,/obj/item/weapon/cartridge/security = 5,
					/obj/item/weapon/cartridge/janitor = 2,/obj/item/weapon/cartridge/signal = 5,/obj/item/weapon/cartridge/atmos = 3,
					/obj/item/weapon/cartridge/quartermaster = 5)
	premium = list(/obj/item/weapon/card/id/gold = 1)

	allow_insert(var/obj/item/I, var/mob/user)
		if(istype(I,/obj/item/weapon/cartridge))
			return 1
		if(istype(I,/obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/id = I
			if(id.registered_name || id.assignment)
				return 0
		if(..(I))
			return 1


/obj/machinery/vending/refillable/wardrobe
	name = "\improper clothing vendor"
	desc = "Clean, pressed, and dressed to robust."
	icon_state = "robotics"
	icon_deny = "robotics_deny"
	wheeled = 0

	products = list(/obj/item/clothing/under/color/white = 5, /obj/item/clothing/under/color/grey = 5, /obj/item/clothing/under/color/black = 5, /obj/item/clothing/under/color/brown = 5,
					/obj/item/clothing/under/color/red = 3,/obj/item/clothing/under/color/orange = 3,/obj/item/clothing/under/color/yellow = 3,
					/obj/item/clothing/under/color/green = 3,/obj/item/clothing/under/color/blue = 3, /obj/item/clothing/under/color/purple = 3,
					/obj/item/clothing/under/color/pink = 3,

					/obj/item/clothing/shoes/black = 5, /obj/item/clothing/shoes/brown = 5, /obj/item/clothing/shoes/white = 5,
					/obj/item/clothing/shoes/red = 2, /obj/item/clothing/shoes/orange = 2, /obj/item/clothing/shoes/yellow = 2,
					/obj/item/clothing/shoes/green = 2,/obj/item/clothing/shoes/blue = 2,/obj/item/clothing/shoes/purple=2,

					/obj/item/clothing/glasses/regular = 5, /obj/item/clothing/glasses/eyepatch = 2,
					/obj/item/clothing/tie/blue = 10, /obj/item/clothing/tie/red = 10)
	premium = list(/obj/item/clothing/head/beret = 2, /obj/item/clothing/head/cakehat = 0, /obj/item/clothing/head/flatcap = 1, /obj/item/clothing/head/that = 2,
					/obj/item/clothing/under/suit_jacket = 1, /obj/item/clothing/under/sundress = 1, /obj/item/clothing/shoes/sandal = 1,
					/obj/item/clothing/glasses/monocle = 1)
	contraband = list(/obj/item/clothing/under/color/rainbow = 1, /obj/item/clothing/under/blackskirt = 1, /obj/item/clothing/shoes/clown_shoes = 1)


/obj/machinery/vending/refillable/food
	name = "Fresh Food Vendor"
	desc = "Straight from the cook's hands to your mouth.  Mmm, MMM!"
	icon_state = "nutrimat" // could use smartfridge but I want it visually distinct
	wheeled = 0 // used as a barrier, don't allow it to move

	product_slogans = "Kiss the cook!;Please don't harrass the cook.;Have a snack.;Don't forget to eat!"
	product_ads = "Don't forget to say thank you.;Please, have something to eat.;The management is not responsible for the quality of these meals."
	products = list()
	premium = list()
	contraband = list()

	scan_id = 0 // removing
	scan_id_insert = 1 // inserting
	req_access_txt = "28" // kitchen

	allow_insert(var/obj/item/W, var/mob/user)
		if(!istype(W,/obj/item/weapon/reagent_containers/food/snacks))
			return 0

		if(emagged) // anyone inserts food
			return 1
		return allowed(user)

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if(istype(W,/obj/item/weapon/tray))
			var/obj/item/weapon/tray/T = W
			var/loaded = 0
			for(var/obj/item/snack in T)
				if(allow_insert(snack,user))
					T.carrying -= snack
					snack.loc = loc
					insert(snack,null) // prevent messages
					loaded = 1
			if(loaded)
				T.update_icon()
				user << "You load [src] from [W]."
			else
				user << "There's nothing on [W] to put in [src]!"
			return
		else if(istype(W,/obj/item/weapon/storage/bag/plants))
			var/obj/item/weapon/storage/SB = W
			var/loaded = 0
			for(var/obj/item/snack in SB)
				if(allow_insert(snack,user))
					SB.remove_from_storage(snack,loc)
					insert(snack,null) // prevent messages
					loaded = 1
			if(loaded)
				user << "You load [src] from [W]."
			else
				user << "There's nothing in [W] to put in [src]!"
			return
		..()

/obj/machinery/vending/refillable/chemistry
	name = "Chemistry Supplies"
	desc = "The third hand you need to give the station what it needs."
	products = list(/obj/item/weapon/reagent_containers/glass/beaker/large = 5, /obj/item/weapon/reagent_containers/glass/beaker = 12,
					/obj/item/weapon/reagent_containers/syringe = 18, /obj/item/weapon/reagent_containers/dropper = 4, /obj/item/weapon/reagent_containers/spray = 2,
					/obj/item/weapon/storage/pill_bottle = 10, /obj/item/clothing/glasses/science = 4)
	premium = list(/obj/item/weapon/cartridge/chemistry = 2, /obj/item/weapon/storage/belt/medical = 4, /obj/item/weapon/gun/syringe = 1)
	contraband = list(/obj/item/weapon/grenade/chem_grenade = 10, /obj/item/device/assembly/igniter = 4, /obj/item/device/assembly/timer = 6)

	allow_insert(var/obj/item/W as obj, var/mob/user as mob)
		// things it doesn't start with
		if(istype(W,/obj/item/device/assembly) && extended_inventory)
			return 1
		if(istype(W,/obj/item/device/healthanalyzer) || istype(W,/obj/item/clothing/glasses/hud/health))
			return 1
		// otherwise
		if(!..(W,user))
			user << "\red [src] refuses [W]."
			return 0
		if(W.reagents && W.reagents.reagent_list.len) // nothing full of reagents
			user << "\red [src] refuses [W]."
			return 0
		if(istype(W,/obj/item/weapon/grenade/chem_grenade))
			var/obj/item/weapon/grenade/chem_grenade/CG = W
			if(CG.beakers.len || CG.stage)
				user << "\red [src] refuses [W]."
				return 0
		if(istype(W,/obj/item/weapon/storage) && W.contents.len)
			user << "\red [src] refuses [W]."
			return 0
		return 1

/obj/machinery/vending/refillable/food/plant
	name = "Farmer's Market"
	desc = "Straight from the botanist's dirty, grubby hands to your stomach."
	product_slogans = "Eat fresh!;You didn't really want meat anyway.;Caution: May contain essential vitamins and nutrients."

	allow_insert(var/obj/item/W, var/mob/user)
		if(!istype(W,/obj/item/weapon/grown) && !istype(W,/obj/item/weapon/reagent_containers/food/snacks/grown) && !istype(W,/obj/item/stack/sheet/wood))
			return 0
		if(emagged)
			return 1
		return allowed(user)
