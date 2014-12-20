

//extract appendix
/datum/surgery_step/mend_bone
	accept_hand = 1
	time = 100
	var/obj/item/organ/limb/L = null
	allowed_organs = list("r_arm","l_arm","r_leg","l_leg","chest","head")

/datum/surgery_step/mend_bone/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = new_organ
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to set the bones in [target]'s [parse_zone(user.zone_sel.selecting)]. This will take a long time.</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].</span>")


/datum/surgery_step/mend_bone/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L && L.bone_status == BONE_BROKEN)
		L.bone_status = BONE_INTACT
		user.visible_message("<span class='notice'>[user] successfully mends the bones in [target]'s [parse_zone(user.zone_sel.selecting)]!</span>")
	else
		user.visible_message("<span class='notice'>[user] can't find any broken bones!</span>")
	return 1


/datum/surgery/bonesetting
	name = "bone setting"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/mend_bone, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human)
	location = "anywhere" //Check attempt_initate_surgery() (in code/modules/surgery/helpers) to see what this does if you can't tell
	has_multi_loc = 1 //Multi location stuff, See multiple_location_example.dm
