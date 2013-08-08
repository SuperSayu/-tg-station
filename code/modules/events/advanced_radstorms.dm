/datum/round_event_control/radiation_storm/gswap
	name 			= "Gender-swapping Radiation"
	typepath		= /datum/round_event/radiation_storm/gswap
	weight			= 6
	max_occurrences = 4
/datum/round_event_control/radiation_storm/pota
	name 			= "Planet of the Apes Radiation"
	typepath 		= /datum/round_event/radiation_storm/pota
	weight 			= 1
	max_occurrences = 2
	minimumCrew		= 12
/datum/round_event_control/radiation_storm/ffour
	name 			= "Fantastic Four Radiation"
	typepath 		= /datum/round_event/radiation_storm/ffour
	weight 			= 2
	max_occurrences = 1
	minimumCrew		= 6
/datum/round_event_control/radiation_storm/healing
	name 			= "Healing Radiation"
	typepath 		= /datum/round_event/radiation_storm/healing
	weight 			= 5
	max_occurrences = 10

/datum/round_event/radiation_storm/proc/rad_armorcheck(mob/living/M as mob,var/multiplier = 0.5)
	var/armor = M.getarmor(null,"rad")
	var/probability = (100 - armor) * multiplier
	return prob(probability)
/datum/round_event/radiation_storm/proc/dna_toggle_block(var/input,var/blocknum)
	// get only the first character of the selected block
	var/subblock = copytext(input, 1 + (blocknum-1) * DNA_BLOCK_SIZE, (blocknum-1) * DNA_BLOCK_SIZE + 2)
	// invert the activation status
	switch(subblock)
		if("0","1","2","3","4","5","6","7")
			subblock = pick("8","9","A","B","C","D","E","F")
		if("8","9","A","B","C","D","E","F")
			subblock = pick("0","1","2","3","4","5","6","7")
	// Copy back into place - I hope
	return copytext(input,1,1 + (blocknum-1) * DNA_BLOCK_SIZE) + subblock + copytext(input,(blocknum-1) * DNA_BLOCK_SIZE + 2,0)


/datum/round_event/radiation_storm/gswap
	start()
		for(var/mob/living/L in living_mob_list)
			var/turf/T = get_turf(L)
			if(!T || T.z != 1)			continue

			L.apply_effect(rand(0,75),IRRADIATE)
			if((ishuman(L) || ismonkey(L)) &&  rad_armorcheck(L))
				var/mob/living/carbon/C = L
				if(!C.dna) continue
				//C.dna.uni_identity = dna_toggle_block(C.dna.uni_identity,11)

				switch(C.gender)
					if(MALE)
						C.gender = FEMALE
					if(FEMALE)
						C.gender = MALE
					else
						C.gender = pick(MALE,FEMALE)
				C.dna.uni_identity = setblock(C.dna.uni_identity, DNA_GENDER_BLOCK, construct_block((C.gender!=MALE)+1, 2))

				var/time = rand(10,100)
				C.emote("collapse")
				C.apply_effect(round(time/10),WEAKEN)

				spawn(time)
					if(C != null)
						updateappearance(C)

						var/adverb = pick("suddenly","pleasantly","unpleasantly","strangely","oddly")
						var/gender = "masculine"
						if(L.gender == "female")
							gender = "feminine"

						C << "You feel [adverb] [gender]."
						C.emote("whimper")

/datum/round_event/radiation_storm/pota
	start()
		for(var/mob/living/C in living_mob_list)
			var/turf/T = get_turf(C)
			if(!T || T.z != 1)			continue

			C.apply_effect(rand(25,125),IRRADIATE)
			if((ishuman(C) || ismonkey(C)) &&  rad_armorcheck(C,0.33))
				var/mob/living/carbon/L = C // fuck you, anyone else who's reading this
				if(!L.dna) continue
				L.dna.struc_enzymes = dna_toggle_block(L.dna.struc_enzymes,RACEBLOCK,3)
				var/time = rand(10,100)
				L.emote("collapse")
				L.apply_effect(time/10,WEAKEN)
				spawn(time)
					if(L != null)
						domutcheck(L,null,1)

/datum/round_event/radiation_storm/ffour
	start()
		var/list/candidates = list()
		for(var/mob/living/C in living_mob_list)
			var/turf/T = get_turf(C)
			if(!T || T.z != 1)			continue

			C.apply_effect(rand(0,75),IRRADIATE)
			if(ishuman(C) &&  rad_armorcheck(C,1))
				candidates += C

		var/list/powerblocks = list(FIREBLOCK,TELEBLOCK,HULKBLOCK,XRAYBLOCK)
		while(powerblocks.len && candidates.len)
			var/block = pick(powerblocks)
			var/mob/living/carbon/human/H = pick(candidates)
			if(!H.dna) continue

			powerblocks	-= block
			candidates	-= H

			H.dna.struc_enzymes = setblock(H.dna.struc_enzymes,block,"FFF",3)
			spawn(rand(10,100))
				if(H != null)
					H.apply_damages(-200,-200,-200,-200,-200)
					domutcheck(H,null,1)

/datum/round_event/radiation_storm/healing
	start()
		for(var/mob/living/L in living_mob_list)
			var/turf/T = get_turf(L)
			if(!T || T.z != 1)			continue

			if(L.stat != 2 && rad_armorcheck(L,0.33))
				L.revive() // miraculous