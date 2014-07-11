/obj/item
	var/list/maker_cost = list("iron" = 1000) // "time": build time

/obj/item/weapon/disk/nuclear/maker_cost = null

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

/obj/item/stack/sheet
	metal
		maker_cost = list("iron" = 2000)
	plasteel
		maker_cost = list("plasteel" = 2000)	// maker reagent
	glass
		maker_cost = list("glass" = 2000)
	rglass
		maker_cost = list("rglass" = 2000)		// maker reagent
	cardboard
		maker_cost = list("cardboard" = 1000)	// maker reagent
	cloth
		maker_cost = list("cloth" = 1000)		// maker reagent
	leather
		maker_cost = list("leather" = 1000)		// maker reagent
	xenochitin
		maker_cost = list("xenol" = 1000)		// maker reagent

/obj/item/stack/sheet/mineral
	clown
		maker_cost = list("bananium" = 2000)	// maker reagent
	diamond
		maker_cost = list("diamond" = 1000)		// maker reagent
	gold
		maker_cost = list("gold" = 1000)
	plasma
		maker_cost = list("splasma" = 2000)		// maker reagent
	sandstone
		maker_cost = list("sandstone" = 1500)	// maker reagent
	silver
		maker_cost = list("silver" = 1000)
	uranium
		maker_cost = list("uranium" = 500)
	wood
		maker_cost = list("wood" = 1000)		// maker reagent

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

