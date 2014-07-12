/obj/item
	var/list/maker_cost = list("iron" = 1000)

/obj/item/weapon/disk/nuclear/maker_cost = null
/obj/item/weapon/extinguisher/maker_cost = list("iron" = 1500, "water" = 0) // 0 indicates it is a fill reagent
/obj/item/weapon/weldingtool/maker_cost = list("iron" = 500, "fuel" = 0)

/obj/item/stack
	maker_cost = null

/obj/item/stack
	rods
		maker_cost = list("iron" = 300)
	cable_coil
		maker_cost = list("iron" = 250)

/obj/item/stack/medical
	bruise_pack
		maker_cost = list("bicaridine" = 50)
	ointment
		maker_cost = list("dermaline" = 50)

// these amounts should equal the reagent's resource_amt var
/obj/item/stack/sheet
	metal
		maker_cost = list("iron" = MINERAL_MATERIAL_AMOUNT)
	plasteel
		maker_cost = list("plasteel" = MINERAL_MATERIAL_AMOUNT)	// maker reagent
	glass
		maker_cost = list("glass" = MINERAL_MATERIAL_AMOUNT)
	rglass
		maker_cost = list("rglass" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	cardboard
		maker_cost = list("cardboard" = MINERAL_MATERIAL_AMOUNT)	// maker reagent
	cloth
		maker_cost = list("cloth" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	leather
		maker_cost = list("leather" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	xenochitin
		maker_cost = list("xenol" = MINERAL_MATERIAL_AMOUNT)		// maker reagent

/obj/item/stack/sheet/mineral
	clown
		maker_cost = list("bananium" = MINERAL_MATERIAL_AMOUNT)	// maker reagent
	diamond
		maker_cost = list("diamond" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	gold
		maker_cost = list("gold" = MINERAL_MATERIAL_AMOUNT)
	plasma
		maker_cost = list("splasma" = MINERAL_MATERIAL_AMOUNT)		// maker reagent
	sandstone
		maker_cost = list("sandstone" = MINERAL_MATERIAL_AMOUNT)	// maker reagent
	silver
		maker_cost = list("silver" = MINERAL_MATERIAL_AMOUNT)
	uranium
		maker_cost = list("uranium" = MINERAL_MATERIAL_AMOUNT)
	wood
		maker_cost = list("wood" = MINERAL_MATERIAL_AMOUNT)		// maker reagent

/obj/item/stack/tile
	carpet
		maker_cost = list("carpet" = 50)		// maker reagent
	grass
		maker_cost = list("grass" = 50)			// maker reagent
	light
		maker_cost = list("iron" = 150, "glass" = 250)
	plasteel
		maker_cost = list("iron" = 500)
	wood
		maker_cost = list("wood" = 250)			// maker reagent

