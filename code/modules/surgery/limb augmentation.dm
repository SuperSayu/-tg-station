
/////AUGMENTATION SURGERIES//////


//SURGERY STEPS

/datum/surgery_step/replace
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32


/datum/surgery_step/replace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] begins to sever the muscles on [target]'s [parse_zone(user.zone_sel.selecting)]!</span>")


/datum/surgery_step/add_limb
	implements = list(/obj/item/robot_parts = 100)
	time = 32
	var/obj/item/organ/limb/L = null // L because "limb"
	allowed_organs = list("r_arm","l_arm","r_leg","l_leg","chest","head")



/datum/surgery_step/add_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = new_organ
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to augment [target]'s [parse_zone(user.zone_sel.selecting)].</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].</span>")

/datum/surgery_step/add_limb/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	// So you can't augment someone with a surgery artifact.
	var/success = 0
	if(accept_hand)
		if(!tool)
			success = 1
	if(accept_any_item)
		if(tool && tool_check(user, tool))
			success = 1
	else
		for(var/path in implements)
			if(istype(tool, path))
				implement_type = path
				if(tool_check(user, tool))
					success = 1

	if(success)
		if(target_zone == surgery.location)
			if(get_location_accessible(target, target_zone))
				initiate(user, target, target_zone, tool, surgery)
				return 1
			else
				user << "<span class='notice'>You need to expose [target]'s [target_zone] to perform surgery on it!</span>"
				return 1
	return 0

//ACTUAL SURGERIES

/datum/surgery/augmentation
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_limb)
	species = list(/mob/living/carbon/human)
	location = "anywhere" //Check attempt_initate_surgery() (in code/modules/surgery/helpers) to see what this does if you can't tell
	has_multi_loc = 1 //Multi location stuff, See multiple_location_example.dm


//SURGERY STEP SUCCESSES

/datum/surgery_step/add_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully augments [target]'s [parse_zone(user.zone_sel.selecting)]!</span>")
			L.loc = get_turf(target)
			H.organs -= L
			switch(user.zone_sel.selecting)  //for the surgery to progress this MUST still be the original "location" so it's safe to do this.
				if("r_leg")
					H.organs += new /obj/item/organ/limb/robot/r_leg(src)
				if("l_leg")
					H.organs += new /obj/item/organ/limb/robot/l_leg(src)
				if("r_arm")
					H.organs += new /obj/item/organ/limb/robot/r_arm(src)
				if("l_arm")
					H.organs += new /obj/item/organ/limb/robot/l_arm(src)
				if("head")
					H.organs += new /obj/item/organ/limb/robot/head(src)
				if("chest")
					var/datum/surgery_step/xenomorph_removal/xeno_removal = new
					xeno_removal.remove_xeno(user, target) // remove an alien if there is one
					H.organs += new /obj/item/organ/limb/robot/chest(src)
					for(var/datum/disease/appendicitis/A in H.viruses) //If they already have Appendicitis, Remove it
						A.cure(1)
			user.drop_item()
			qdel(tool)
			H.update_damage_overlays(0)
			H.update_augments() //Gives them the Cyber limb overlay
			add_logs(user, target, "augmented", addition="by giving him new [parse_zone(user.zone_sel.selecting)] INTENT: [uppertext(user.a_intent)]")
	else
		user.visible_message("<span class='notice'>[user] [target] has no organic [parse_zone(user.zone_sel.selecting)] there!</span>")
	return 1
