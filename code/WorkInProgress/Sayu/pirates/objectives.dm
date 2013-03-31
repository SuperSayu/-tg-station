datum/objective/loot
	explanation_text = "Plunder th' station!  Fill yer holds with whatever ye can get."

/obj/item/weapon/storage/bag/loot
	name = "Loot Bag"


/datum/game_mode/proc/equip_pirate(mob/living/carbon/human/pirate_mob)
	if (!istype(pirate_mob))
		return

	//So zards properly get their items when they are admin-made.
	del(pirate_mob.wear_suit)
	del(pirate_mob.head)
	del(pirate_mob.shoes)
	del(pirate_mob.r_hand)
	del(pirate_mob.r_store)
	del(pirate_mob.l_store)

	//pirate_mob.equip_to_slot_or_del(new /obj/item/device/radio/headset(wizard_mob), slot_ears)


	//wizard_mob.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	wizard_mob.update_icons()
	return 1