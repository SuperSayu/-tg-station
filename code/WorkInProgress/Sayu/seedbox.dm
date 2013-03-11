/*
 *	Seed bags: Produced automatically by the seed extractor to reduce seedspam.
 *	Accept only one type of seed at a time, normal storage limit.
 *	Biodegrades into dirt when empty and used on a hydroponics machine or attack_self'd
 */

/obj/item/weapon/storage/bag/seeds
	name = "Seed bag"
	desc = "A biodegradable seed bag."
	var/obj/item/seeds/seedtype = null
//	foldable = /obj/effect/decal/cleanable/dirt // wait what?
	can_hold = list("/obj/item/seeds") //When the bag has a kind of seed, this gets narrowed down to only that.
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidence"

	New()
		..()
		pixel_x = rand(-10,10)
		pixel_y = rand(-10,0)

	update_icon()
		// Although it's improper, handle internal variables here,
		// since it gets called at the end of handle_item_insertion
		if(contents.len > 0 && !seedtype)
			overlays.Cut()
			var/obj/item/seeds/S = contents[1]
			icon_state = "evidenceobj"
			overlays += image('icons/obj/seeds.dmi', icon_state=S.icon_state)
			seedtype = S.type
			can_hold = list("[S.type]")
			name = "Seed Bag ([S.plantname])"
			allow_quick_gather = 1

		if(contents.len == 0 && seedtype != null)
			overlays.Cut()
			icon_state = "evidence"
			name = "Seed Bag (Empty)"
			seedtype = null
			can_hold = list("/obj/item/seeds")
			allow_quick_gather = 0
