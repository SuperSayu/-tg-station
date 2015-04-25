/mob/living/carbon/human/movement_delay()
	if(dna)
		. += dna.species.movement_delay(src)

	return (. + config.human_delay)

/mob/living/carbon/human/var/last_break = 0
/mob/living/carbon/human/Move()

	if(prob(2) && !last_break && !buckled)
		var/list/broken_limbs = list()

		for(var/obj/item/organ/limb/L in organs)
			if(L.bone_status == BONE_BROKEN) //BONE_BROKEN is supposed to exclude nonorganic bones but have to be sure
				broken_limbs += L

		if(broken_limbs && broken_limbs.len > 0)
			var/obj/item/organ/limb/picked_bone = pick(broken_limbs)

			if(picked_bone.bone_agony())
				last_break = 1
				spawn(50)
					last_break = 0
	..()

/mob/living/carbon/human/Process_Spacemove(var/movement_dir = 0)

	if(..())
		return 1

	//Do we have a working jetpack
	if(istype(back, /obj/item/weapon/tank/jetpack) && isturf(loc)) //Second check is so you can't use a jetpack in a mech
		var/obj/item/weapon/tank/jetpack/J = back
		if((movement_dir || J.stabilization_on) && J.allow_thrust(0.01, src))
			return 1

	if(istype(back, /obj/item/wings) && isturf(loc))
		return 1

	return 0


/mob/living/carbon/human/slip(var/s_amount, var/w_amount, var/obj/O, var/lube)
	if(isobj(shoes) && (shoes.flags&NOSLIP) && !(lube&GALOSHES_DONT_HELP))
		return 0
	.=..()

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return shoes && shoes.negates_gravity()

/mob/living/carbon/human/Move(NewLoc, direct)
	..()
	if(shoes)
		if(!lying)
			if(loc == NewLoc)
				if(!has_gravity(loc))
					return
				var/obj/item/clothing/shoes/S = shoes
				S.step_action()

