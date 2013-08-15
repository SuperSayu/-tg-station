/datum/surgery/omnitalk
	name = "translator implant surgery"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/implant)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey, /mob/living/carbon/alien/humanoid)
	location = "head"

/datum/surgery_step/implant
	implements = list(/obj/item/device/translator = 100, /obj/item/device/taperecorder = 25)
	time = 64

/datum/surgery_step/implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to implant [target]!</span>")

/datum/surgery_step/implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] implants [target]!</span>")
	target.universal_speak = 1
	user.drop_item()
	tool.loc = target
	return 1

/obj/item/device/translator
	name = "Translator Implant Cypher Key"
	desc = "Used for translator implant surgery."
	icon = 'icons/obj/radio.dmi'
	icon_state = "bin_cypherkey"
	w_class = 1

/datum/design/translator
	name = "Translator Implant Cypher Key"
	desc = "Used for translator implant surgery."
	id = "trans_implant"
	req_tech = list("programming" = 4, "biotech" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000, "$glass" = 2000, "$silver" = 100)
	build_path = "/obj/item/device/translator"