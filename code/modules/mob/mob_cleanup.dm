//Methods that need to be cleaned.
/* INFORMATION
Put (mob/proc)s here that are in dire need of a code cleanup.
*/

/mob/proc/has_disease(var/datum/disease/virus)
	for(var/datum/disease/D in viruses)
		if(D.IsSame(virus))
			//error("[D.name]/[D.type] is the same as [virus.name]/[virus.type]")
			return 1
	return 0

// This proc has some procs that should be extracted from it. I believe we can develop some helper procs from it - Rockdtben
/mob/proc/contract_disease(var/datum/disease/virus, var/force_infect = 0, var/force_species_check=1, var/spread_type = -5)
	if(stat&2)
		return

	if(istype(virus, /datum/disease/advance))
		var/datum/disease/advance/A = virus
		if(A.GetDiseaseID() in resistances)
			return
		if(count_by_type(viruses, /datum/disease/advance) >= 3)
			return

		if(has_disease(virus)) // only need the D.IsSame() when working with advanced diseases
			return
	else
		if(src.resistances.Find(virus.type))
			return

		if(locate(virus.type) in src.viruses) // for normal diseases a simple Locate() will do
			return

	if(force_species_check)
		var/fail = 1
		for(var/name in virus.affected_species)
			var/mob_type = text2path("/mob/living/carbon/[lowertext(name)]")
			if(mob_type && istype(src, mob_type))
				fail = 0
				break
		if(fail) return

	var/passed = 1

	if(!force_infect)
		if(prob(15/virus.permeability_mod))
			return

		//chances to target this zone
		var/head_ch
		var/body_ch
		var/hands_ch
		var/feet_ch

		if(spread_type == -5)
			spread_type = virus.spread_type

		switch(spread_type)
			if(CONTACT_HANDS)
				head_ch = 0
				body_ch = 0
				hands_ch = 100
				feet_ch = 0
			if(CONTACT_FEET)
				head_ch = 0
				body_ch = 0
				hands_ch = 0
				feet_ch = 100
			else
				head_ch = 100
				body_ch = 100
				hands_ch = 25
				feet_ch = 25

		//1: head, 2: body, 3: hands, 4: feet
		var/target_zone = pick(head_ch;1,body_ch;2,hands_ch;3,feet_ch;4)

		var/obj/item/clothing/Cl = null // temporary variable

		if(istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src

			switch(target_zone)
				if(1)
					Cl = H.head
					if(istype(Cl)) // if something non-clothing is on the head (paper) it won't save you anyway
						passed = prob((Cl.permeability_coefficient*100) - 1)

					Cl = H.wear_mask
					if(passed && istype(Cl))
						passed = prob((Cl.permeability_coefficient*100) - 1)

				if(2)//arms and legs included
					Cl = H.wear_suit
					if(istype(Cl))
						passed = prob((Cl.permeability_coefficient*100) - 1)

					Cl = slot_w_uniform
					if(passed && istype(Cl))
						passed = prob((Cl.permeability_coefficient*100) - 1)

				if(3)
					Cl = H.wear_suit
					if(istype(H.wear_suit) && Cl.body_parts_covered&HANDS)
						passed = prob((Cl.permeability_coefficient*100) - 1)

					Cl = H.gloves
					if(passed && istype(Cl))
						passed = prob((Cl.permeability_coefficient*100) - 1)

				if(4)
					Cl = H.wear_suit
					if(istype(Cl) && Cl.body_parts_covered&FEET)
						passed = prob((Cl.permeability_coefficient*100) - 1)

					Cl = H.shoes
					if(passed && istype(Cl))
						passed = prob((Cl.permeability_coefficient*100) - 1)

				else
					src << "Something strange's going on, something's wrong."


		else if(istype(src, /mob/living/carbon/monkey))
			var/mob/living/carbon/monkey/M = src
			if(target_zone == 1) // head
				Cl = M.wear_mask
				if(istype(Cl))
					passed = prob((Cl.permeability_coefficient*100) - 1)


		if(!passed && spread_type == AIRBORNE && !internals)
			passed = (prob((50*virus.permeability_mod) - 1))

	if(passed)
		var/datum/disease/v = new virus.type(1, virus, 0)
		src.viruses += v
		v.affected_mob = src
		v.strain_data = v.strain_data.Copy()
		v.holder = src
		if(v.can_carry && prob(5))
			v.carrier = 1
		return
	return
