/datum/event_control/radiation_storm/gswap
	name 			= "Gender-swapping Radiation"
	typepath		= /datum/event/radiation_storm/gswap
	weight			= 6
	max_occurrences = 4
/datum/event_control/radiation_storm/pota
	name 			= "Planet of the Apes Radiation"
	typepath 		= /datum/event/radiation_storm/pota
	weight 			= 3
	max_occurrences = 2
/datum/event_control/radiation_storm/ffour
	name 			= "Fantastic Four Radiation"
	typepath 		= /datum/event/radiation_storm/ffour
	weight 			= 6
	max_occurrences = 1
/datum/event_control/radiation_storm/healing
	name 			= "Healing Radiation"
	typepath 		= /datum/event/radiation_storm/healing
	weight 			= 5
	max_occurrences = 10

/datum/event/radiation_storm/proc/rad_armorcheck(mob/living/M as mob,var/multiplier = 0.5)
	var/armor = M.getarmor(null,"rad")
	var/probability = (100 - armor) * multiplier
	return prob(probability)
/datum/event/radiation_storm/proc/dna_toggle_block(var/input,var/blocknum,var/blocksize)
	return setblock(input,blocknum,toggledblock(getblock(input,blocknum,blocksize)),blocksize)


/datum/event/radiation_storm/gswap
	start()
		for(var/mob/living/L in living_mob_list)
			var/turf/T = get_turf(L)
			if(!T || T.z != 1)			continue

			L.apply_effect(rand(0,75),IRRADIATE)
			if((ishuman(L) || ismonkey(L)) &&  rad_armorcheck(L))
				L.dna.uni_identity = dna_toggle_block(L.dna.uni_identity,11,3)
				var/time = rand(10,100)
				L.emote("collapse")
				L.apply_effect(time/10,WEAKEN)
				spawn(time)
					if(L != null)
						updateappearance(L,L.dna.uni_identity)
						L << "You feel different."
						L.emote("whimper")

/datum/event/radiation_storm/pota
	start()
		for(var/mob/living/C in living_mob_list)
			var/turf/T = get_turf(C)
			if(!T || T.z != 1)			continue

			C.apply_effect(rand(25,125),IRRADIATE)
			if((ishuman(C) || ismonkey(C)) &&  rad_armorcheck(C))
				C.dna.struc_enzymes = dna_toggle_block(C.dna.struc_enzymes,14,3)
				var/time = rand(10,100)
				C.emote("collapse")
				C.apply_effect(time/10,WEAKEN)
				spawn(time)
					if(C != null)
						domutcheck(C,null,1)

/datum/event/radiation_storm/ffour
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

			powerblocks	-= block
			candidates	-= H

			H.dna.struc_enzymes = setblock(H.dna.struc_enzymes,block,"FFF",3)
			spawn(rand(10,100))
				if(H != null)
					H.apply_damages(-200,-200,-200,-200,-200)
					domutcheck(H,null,1)

/datum/event/radiation_storm/healing
	start()
		for(var/mob/living/L in living_mob_list)
			var/turf/T = get_turf(L)
			if(!T || T.z != 1)			continue

			if(rad_armorcheck(L,0.66))
				L.apply_damages(-100,-100,-100,-100,-100)