// Refillable vending machines (finally) by Sayu

/obj/machinery/vending/refillable
	var/scan_id_insert = 0 // by default you can only fill it with what it already has, which is safe-ish
	var/renamable = 0	// set true for do-it-yourself venders
	var/list/inserted = list()

/obj/machinery/vending/refillable/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(istype(W,/obj/item/weapon/grab) || istype(W,/obj/item/tk_grab) || istype(W,/obj/item/weapon/crowbar) || istype(W,/obj/item/weapon/screwdriver) || istype(W,/obj/item/weapon/coin) || istype(W, /obj/item/device/multitool)||istype(W, /obj/item/weapon/wirecutters))
		return ..(W,user)
	if(panel_open)
		if(istype(W,refill_canister))
			return ..(W,user)
		if(istype(W,/obj/item/weapon/hand_labeler) && renamable)
			var/obj/item/weapon/hand_labeler/HL = W
			if(HL.mode)
				if(HL.labels_left)
					name = HL.label
					user << "You label [src]."
					return 1
				return 0 // no labels message
	else
		if(allow_insert(W, user))
			var/result = insert(W, user)
			updateUsrDialog()
			return result
		else
			..()
			return 0

/obj/machinery/vending/refillable/proc/allow_insert(var/obj/item/I, var/mob/user)
	if(!emagged && scan_id_insert && !allowed(user))
		return 0
	var/searchlist = products
	if(extended_inventory)
		searchlist += contraband

	return (I.type in searchlist)

/obj/machinery/vending/refillable/proc/insert(var/obj/item/I, var/mob/user)

	if(user)
		if(!user.drop_item())
			user << "<span class='notice'> The [I] is stuck to your hand!</span>"
			return 0


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
		if((target_vend in hidden_records) && !extended_inventory)	// This won't usually come up
			user << "<span class='notice'> You insert [I] into [src], but it doesn't show up on the list.</span>"
		else
			user << "<span class='notice'> You insert [I] into [src]. </span>"
		I.add_fingerprint(user)
		add_fingerprint(user)

	inserted += I
	I.loc = src

/obj/machinery/vending/refillable/vend(var/typepath, var/atom/newloc = loc)
	var/obj/O = locate(typepath) in inserted
	if(O)
		O.loc = newloc
		inserted -= O
		return O
	else
		return new typepath(loc)

/obj/machinery/vending/refillable/generic
	name = "do-it-yourself vend-o-mat"
	desc = "Filled with dreams--YOUR dreams.  Which is to say, empty."


/obj/machinery/vending/refillable/generic/allow_insert(var/obj/item/I)
	if(istype(I) && !(I.flags&ABSTRACT))
		return 1
	return 0

/obj/machinery/vending/refillable/New()
	..()
	if(!istype(loc,/turf))
		anchored = 0


/obj/machinery/vending/refillable/drink
	name = "mixed drink vender"
	desc = "Full of the bartender's leftovers."

/obj/machinery/vending/refillable/drink/allow_insert(var/obj/item/weapon/reagent_containers/W as obj, var/mob/user as mob)
	if(!istype(W,/obj/item/weapon/reagent_containers/food/drinks) || !W.reagents)
		return 0
	if(istype(W,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass) && W.reagents.reagent_list.len) // no full glasses
		return 0
	if(!W.reagents.reagent_list.len) // no empty bottles
		return 0

	return (emagged || !scan_id_insert || allowed(user))

/obj/machinery/vending/refillable/theatre
	name = "prop storage"
	desc = "Contains various props and toys; access to some has been restricted."
	req_access_txt = "46" // access_theatre
	products = list(/obj/item/weapon/lipstick = 1, /obj/item/weapon/lipstick/black = 1, /obj/item/weapon/lipstick/jade = 1, /obj/item/weapon/lipstick/purple = 1,
					/obj/item/weapon/razor = 1, /obj/item/toy/gun = 2, /obj/item/toy/ammo/gun = 4,/obj/item/weapon/gun/energy/laser/practice = 2,
					/obj/item/toy/snappop = 10, /obj/item/device/instrument/violin = 1, /obj/item/clothing/gloves/ring/plastic/random = 3)
	premium = list(/obj/item/clothing/under/actorsuit = 2,/obj/item/clothing/gloves/ring/gold = 2, /obj/item/clothing/gloves/ring/silver = 1)
	contraband = list( /obj/item/toy/sword = 3, /obj/item/weapon/gun/projectile/shotgun/toy/crossbow = 2, /obj/item/toy/AI = 1, /obj/item/toy/spinningtoy = 1)

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
		if(!emagged && scan_id_insert && !allowed(user))
			return 0
		if(istype(I,/obj/item/weapon/cartridge))
			return 1
		if(istype(I,/obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/id = I
			if(id.registered_name || id.assignment) // already taken
				return 0
			return 1
		if(istype(I,/obj/item/device/pda))
			var/obj/item/device/pda/pda = I
			if(pda.owner || pda.id || pda.pai || pda.cartridge)
				return 0
			return 1

/obj/machinery/vending/refillable/wardrobe
	name = "clothing vendor"
	desc = "Clean, pressed, and dressed to robust."
	icon_state = "robotics"
	icon_deny = "robotics_deny"
	wheeled = 0

	// took out orange clothing because it's dedicated prisonwear
	products = list(/obj/item/clothing/under/color/white = 5, /obj/item/clothing/under/color/grey = 5, /obj/item/clothing/under/color/black = 5, /obj/item/clothing/under/color/brown = 5,
					/obj/item/clothing/under/color/red = 3, /obj/item/clothing/under/color/yellow = 3,
					/obj/item/clothing/under/color/green = 3,/obj/item/clothing/under/color/blue = 3, /obj/item/clothing/under/color/purple = 3,
					/obj/item/clothing/under/color/pink = 3,

					/obj/item/clothing/shoes/sneakers/black = 5, /obj/item/clothing/shoes/sneakers/brown = 5, /obj/item/clothing/shoes/sneakers/white = 5,
					/obj/item/clothing/shoes/sneakers/red = 2, /obj/item/clothing/shoes/sneakers/yellow = 2,
					/obj/item/clothing/shoes/sneakers/green = 2,/obj/item/clothing/shoes/sneakers/blue = 2,/obj/item/clothing/shoes/sneakers/purple=2,

					/obj/item/clothing/glasses/regular = 5, /obj/item/clothing/glasses/regular/regular3 = 5, /obj/item/clothing/glasses/eyepatch = 2,
					/obj/item/clothing/tie/blue = 10, /obj/item/clothing/tie/red = 10)
	premium = list(/obj/item/clothing/head/beret = 2, /obj/item/clothing/head/cakehat = 0, /obj/item/clothing/head/flatcap = 2, /obj/item/clothing/head/that = 2,
					/obj/item/clothing/under/suit_jacket = 1,/obj/item/clothing/under/suit_jacket/female = 1,/obj/item/clothing/under/suit_jacket/really_black = 1, /obj/item/clothing/under/sundress = 1, /obj/item/clothing/shoes/sandal = 1,
					/obj/item/clothing/glasses/monocle = 1)
	contraband = list(/obj/item/clothing/under/color/rainbow = 1, /obj/item/clothing/head/soft/rainbow = 1, /obj/item/clothing/gloves/color/rainbow = 1, /obj/item/clothing/shoes/sneakers/rainbow = 1, /obj/item/clothing/under/blackskirt = 2, /obj/item/clothing/shoes/clown_shoes = 1, /obj/item/clothing/shoes/laceup = 3)


/obj/machinery/vending/refillable/food
	name = "fresh food vendor"
	desc = "Straight from the cook's hands to your mouth.  Mmm, MMM!"
	icon_state = "nutrimat" // could use smartfridge but I want it visually distinct
	icon = 'icons/obj/sayu_vending.dmi'

	product_slogans = "Kiss the cook!;Please don't harrass the cook.;Have a snack.;Don't forget to eat!"
	product_ads = "Don't forget to say thank you.;Please, have something to eat.;The management is not responsible for the quality of these meals."
	products = list()
	premium = list()
	contraband = list()

	scan_id = 0 // removing
	scan_id_insert = 1 // inserting
	req_access_txt = "28" // kitchen

/obj/machinery/vending/refillable/food/allow_insert(var/obj/item/W, var/mob/user)
	if(!istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		return 0

	return emagged || !scan_id_insert || allowed(user)

/obj/machinery/vending/refillable/food/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(istype(W,/obj/item/weapon/storage/bag))
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
	name = "chemistry supplies"
	desc = "The third hand you need to give the station what it needs."
	products = list(/obj/item/weapon/reagent_containers/glass/beaker/large = 5, /obj/item/weapon/reagent_containers/glass/beaker = 12,
					/obj/item/weapon/storage/pill_bottle = 10, /obj/item/weapon/reagent_containers/syringe = 18,
					/obj/item/weapon/reagent_containers/dropper = 4, /obj/item/weapon/reagent_containers/spray = 2,
					/obj/item/weapon/storage/pill_bottle = 10, /obj/item/clothing/gloves/color/latex = 4, /obj/item/clothing/glasses/science = 4, /obj/item/clothing/glasses/science/science3 = 4)
	premium = list(/obj/item/weapon/cartridge/chemistry = 2, /obj/item/weapon/storage/belt/medical = 4, /obj/item/weapon/gun/syringe = 1)
	contraband = list(/obj/item/weapon/grenade/chem_grenade = 10, /obj/item/device/assembly/igniter = 4, /obj/item/device/assembly/timer = 6)
	req_one_access_txt = "33;39"

/obj/machinery/vending/refillable/chemistry/allow_insert(var/obj/item/W as obj, var/mob/user as mob)
	if(!emagged && scan_id_insert && !allowed(user))
		return 0
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
		return 1
	if(istype(W,/obj/item/weapon/storage) && W.contents.len)
		user << "\red [src] refuses [W]."
		return 0
	return 1

/obj/machinery/vending/refillable/food/plant
	name = "farmer's market"
	desc = "Straight from the botanist's dirty, grubby hands to your stomach."
	product_slogans = "Eat fresh!;You didn't really want meat anyway.;Caution: May contain essential vitamins and nutrients."
	req_access_txt = "0"

/obj/machinery/vending/refillable/food/plant/allow_insert(var/obj/item/W, var/mob/user)
	if(!istype(W,/obj/item/weapon/grown) && !istype(W,/obj/item/weapon/reagent_containers/food/snacks/grown) && !istype(W,/obj/item/stack/sheet/mineral/wood))
		return 0
	return emagged || !scan_id_insert || allowed(user)
