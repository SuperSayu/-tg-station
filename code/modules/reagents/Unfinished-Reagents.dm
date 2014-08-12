/*
	I am sorry to do this to you, but these reagents are added by the
	maker commit and are not finished.  When they are finished,
	move them back to the main reagents file.  When this file is empty,
	remove it.
*/

/datum/reagent
	iron/plasteel
		name = "Plasteel"
		id = "plasteel"
		resource_item = /obj/item/stack/sheet/plasteel
	carbon/diamond
		name = "Diamond"
		id = "diamond"
		resource_item = /obj/item/stack/sheet/mineral/diamond

	nutriment/cardboard
		name = "Cardboard"
		id = "cardboard"
		nutriment_factor = 0.25 * REAGENTS_METABOLISM // yuck
		resource_item = /obj/item/stack/sheet/cardboard

	uranium/enriched
		name = "Enriched Uranium"
		id = "enruranium"
		resource_item = /obj/item/stack/sheet/mineral/enruranium

	banana/bananium
		name = "Bananium"
		id = "bananium"
		reagent_state = SOLID
		resource_item = /obj/item/stack/sheet/mineral/clown
	silicon/glass
		name = "Glass"
		id = "glass"
		resource_item = /obj/item/stack/sheet/glass
	silicon/glass/rglass
		name = "Reinforced glass"
		id = "rglass"
		resource_item = /obj/item/stack/sheet/rglass
	silicon/sandstone
		name = "Sandstone"
		id = "sandstone"
		resource_item = /obj/item/stack/sheet/mineral/sandstone
	leather
		name = "Leather"
		id = "leather"
		reagent_state = SOLID
		resource_item = /obj/item/stack/sheet/leather
	leather/xeno
		name = "Xeno chitin"
		id = "xenoleather"
		resource_item = /obj/item/stack/sheet/xenochitin
	cloth
		name = "Cloth"
		id = "cloth"
		reagent_state = SOLID
		resource_item = /obj/item/stack/sheet/cloth
	cloth/carpet
		name = "Carpet"
		id = "carpet"
		resource_item = /obj/item/stack/tile/carpet
	grass
		name = "Grass"
		id = "grass"
		resource_item = /obj/item/stack/tile/grass

	// todo: turf reaction to create gas
	carbon_dioxide
		name = "Carbon dioxide"
		id = "co2"
	nitrous_oxide
		name = "Nitrous Oxide"
		id = "n2o"

// Added because why did they not exist
/*
	carbon/plastic
		name = "Plastic"
		id = "plastic"
		resource_item = /obj/item/stack/sheet/mineral/plastic

	silicon/rubber
		name = "Silicone rubber"
		id = "rubber"
		resource_item = /obj/item/stack/sheet/mineral/rubber

	titanium
		name = "Titanium"
		id = "titanium"
		resource_item = /obj/item/stack/sheet/mineral/titanium

	titanium/adamantine
		name = "Adamantine"
		id = "adamantine"
		resource_item = /obj/item/stack/sheet/mineral/adamantine

	aluminum
		resource_item = /obj/item/stack/sheet/mineral/aluminum

	aluminum/mythril
		name = "Mythril"
		id = "mythril"
		resource_item = /obj/item/stack/sheet/mineral/mythril

	lead
		name = "Lead"
		id = "lead"
		resource_item = /obj/item/stack/sheet/mineral/lead
*/