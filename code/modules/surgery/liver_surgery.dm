/datum/surgery/liver_surgery
	name = "liver surgery"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/incise, /datum/surgery_step/extract_liver, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "groin"


//extract liver
/datum/surgery_step/extract_liver
	implements = list(/obj/item/weapon/surgicaldrill = 100)
	accept_hand = 1
	time = 64
	var/obj/item/organ/liver/L = null

/datum/surgery_step/extract_liver/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = locate() in target.internal_organs


	if(L)
		if(!tool)
			user.visible_message("<span class='notice'>[user] begins to extract [target]'s liver.</span>")
		else
			user.visible_message("<span class='notice'>[user] begins to upgrade [target]'s liver.</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for the liver in [target].</span>")

/datum/surgery_step/extract_liver/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(!tool)
			user.visible_message("<span class='notice'>[user] successfully removes [target]'s liver!</span>")
			L.loc = get_turf(target)
			target.internal_organs -= L
		else
			user.visible_message("<span class='notice'>[user] successfully upgrades [target]'s liver!</span>")
			L.turbo = 1
			L.update_icon()
	else
		user.visible_message("<span class='notice'>[user] can't find a liver in [target]!</span>")
	return 1