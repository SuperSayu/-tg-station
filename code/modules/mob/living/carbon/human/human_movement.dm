/mob/living/carbon/human/movement_delay()
	if(!has_gravity(src))
		return -1	//It's hard to be slowed down in space by... anything
	else if(status_flags & GOTTAGOFAST)
		return -1

	. = 0
	var/health_deficiency = (100 - health + staminaloss)
	if(health_deficiency >= 40 && !reagents.has_reagent("morphine"))
		. += (health_deficiency / 25)

	var/hungry = (500 - nutrition) / 5	//So overeat would be 100 and default level would be 80
	if(hungry >= 70)
		. += hungry / 50

	if(wear_suit)
		. += wear_suit.slowdown
	if(shoes)
		. += shoes.slowdown
	if(back)
		. += back.slowdown
	if(legcuffed)
		. += legcuffed.slowdown

	if(FAT in mutations)
		. += 1.5
	if(bodytemperature < 283.222)
		. += (283.222 - bodytemperature) / 10 * 1.75

	if(("left leg" in broken) && ("right leg" in broken) && !reagents.has_reagent("morphine"))
		. += 1

	return (. +config.human_delay)

/mob/living/carbon/human/Move()
	// ugh this looks so ugly
	var/last_break = 0
	if(prob(2) && !reagents.has_reagent("morphine") && !last_break)
		if("left leg" in broken)
			src << "\red Pain shoots up your left leg!"
			var/obj/item/organ/limb/affecting = get_organ("l_leg")
			apply_damage(rand(0,2), STAMINA, affecting)
		//	Stun(2)
			playsound(src, 'sound/weapons/pierce.ogg', 25)
			last_break = 1
			spawn(50)
				last_break = 0
			return
		if("right leg" in broken)
			src << "\red Pain shoots up your right leg!"
			var/obj/item/organ/limb/affecting = get_organ("r_leg")
			apply_damage(rand(0,2), STAMINA, affecting)
		//	Stun(2)
			playsound(src, 'sound/weapons/pierce.ogg', 25)
			last_break = 1
			spawn(50)
				last_break = 0

	..()

/mob/living/carbon/human/Process_Spacemove(var/check_drift = 0)
	//Can we act
	if(restrained())	return 0

	//Do we have a working jetpack
	if(istype(back, /obj/item/weapon/tank/jetpack))
		var/obj/item/weapon/tank/jetpack/J = back
		if(((!check_drift) || (check_drift && J.stabilization_on)) && (!lying) && (J.allow_thrust(0.01, src)))
			inertia_dir = 0
			return 1
//		if(!check_drift && J.allow_thrust(0.01, src))
//			return 1

	//If no working jetpack then use the other checks
	if(..())	return 1
	return 0


/mob/living/carbon/human/Process_Spaceslipping(var/prob_slip = 5)
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		prob_slip = 0 // Changing this to zero to make it line up with the comment, and also, make more sense.

	//Do we have magboots or such on if so no slip
	if(istype(shoes, /obj/item/clothing/shoes/magboots) && (shoes.flags & NOSLIP))
		prob_slip = 0

	//Check hands and mod slip
	if(!l_hand)	prob_slip -= 2
	else if(l_hand.w_class <= 2)	prob_slip -= 1
	if (!r_hand)	prob_slip -= 2
	else if(r_hand.w_class <= 2)	prob_slip -= 1

	prob_slip = round(prob_slip)
	return(prob_slip)


/mob/living/carbon/human/slip(var/s_amount, var/w_amount, var/obj/O, var/lube)
	if(isobj(shoes) && (shoes.flags&NOSLIP) && !(lube&GALOSHES_DONT_HELP))
		return 0
	.=..()