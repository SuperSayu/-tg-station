/obj/item/organ/limb/proc/bone_break(var/break_chance = 0)
	if(!owner || status != ORGAN_ORGANIC || bone_status != BONE_INTACT || !prob(break_chance * break_chance_multiplier))
		return 0

	playsound(owner.loc, 'sound/weapons/pierce.ogg', 50)
	var/breaknoise = pick("snap","crack","pop","crick","snick","click","crock","clack","crunch","snak")
	owner.visible_message("<span class='danger'>[owner]'s [bone_name] breaks with a [breaknoise]!</span>", "<span class='userdanger'>Your [bone_name] breaks with a [breaknoise]!</span>")
	bone_status = BONE_BROKEN
	return 1

/obj/item/organ/limb/proc/bone_mend(var/show_message = 0)
	if(!owner || status != ORGAN_ORGANIC || bone_status != BONE_BROKEN)
		return 0

	if(show_message) //to avoid spam during very rapid healing
		var/display = getDisplayName()
		owner << "<span class='notice'>You feel your broken [display] mend...</span>"
	bone_status = BONE_INTACT
	return 1

/obj/item/organ/limb/proc/bone_agony()
	if(!owner || status != ORGAN_ORGANIC || bone_status != BONE_BROKEN)
		return 0

	var/display = getDisplayName()
	owner << "<span class='userdanger'>Pain shoots up your [display]!</span>"

	if(ishuman(owner)) //isType ;-;
		var/mob/living/carbon/human/M = owner
		M.adjustStaminaLoss(15)

	playsound(owner.loc, 'sound/weapons/pierce.ogg', 25)

	return 1

/obj/item/organ/limb/chest/bone_agony()
	if(!owner || status != ORGAN_ORGANIC || bone_status != BONE_BROKEN)
		return 0

	owner << "<span class='userdanger'>Your lungs hurt.</span>"

	if(ishuman(owner)) //isType ;-;
		var/mob/living/carbon/human/M = owner
		M.adjustStaminaLoss(15)
		M.adjustOxyLoss(15)

	playsound(owner.loc, 'sound/weapons/pierce.ogg', 25)

	return 1

/obj/item/organ/limb/head/bone_agony()
	if(!owner || status != ORGAN_ORGANIC || bone_status != BONE_BROKEN)
		return 0

	owner << "<span class='userdanger'>Your feel concussed.</span>"

	if(ishuman(owner)) //isType ;-;
		var/mob/living/carbon/human/M = owner
		M.adjustStaminaLoss(15)
		M.adjustBrainLoss(1)

	playsound(owner.loc, 'sound/weapons/pierce.ogg', 25)
	return 1