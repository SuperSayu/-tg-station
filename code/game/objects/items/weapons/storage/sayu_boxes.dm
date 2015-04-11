// Welcome to spaceburger home of the spaceburger
/obj/item/weapon/storage/box/spacemeal
	name = "Burgerspace Spaceymeal"
	desc = "Filled with... well, pretty much the opposite of nutrition.  Comes with a toy!"
	icon_state = "giftbag2"
	storage_slots = 4
	foldable = /obj/item/weapon/paper/crumpled

/obj/item/weapon/storage/box/spacemeal/New()
	..()
	if(prob(80)) // Regular
		new /obj/item/weapon/reagent_containers/food/snacks/burger(src)

	else if(prob(80)) // Large (20%)
		new /obj/item/weapon/reagent_containers/food/snacks/burger/bigbite(src)

	else if(prob(80)) // Extra large (4%)
		new /obj/item/weapon/reagent_containers/food/snacks/burger/superbite(src)

	else // why would you buy a salad at a fast food joint? (0.8%)
		new /obj/item/weapon/reagent_containers/food/snacks/validsalad(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/apple(src)
		new /obj/item/weapon/reagent_containers/food/drinks/tea(src)
		new /obj/item/toy/random(src)
		return

	// Side and a drink:
	var/side = pick(/obj/item/weapon/reagent_containers/food/snacks/fries,/obj/item/weapon/reagent_containers/food/snacks/cheesyfries,
					/obj/item/weapon/reagent_containers/food/snacks/hotchili)
	var/drink = pick(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist)
	new side(src)
	new drink(src)
	new /obj/item/toy/random(src)