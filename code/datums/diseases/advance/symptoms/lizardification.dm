/*
//////////////////////////////////////

Lizardification

	Very noticable.
	Lowers resistance considerably.
	Considerably Decreases stage speed.
	Barely transmittable.
	Critical Level.

Bonus
	Makes the affected mob be hallucinated for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/lizardification

	name = "Reptilian Transformation"
	stealth = -3
	resistance = -2
	stage_speed = -3
	transmittable = -5
	level = 5

/datum/symptom/lizardification/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))

		var/mob/living/M = A.affected_mob

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M

			switch(A.stage)
				if(1, 2)
					H << "<span class='notice'>[pick("Your skin itches.", "You feel a tingling underneath your skin.", "You feel goosebumps on your skin.")]</span>"
				if(3, 4)
					H << "<span class='notice'>[pick("Your nose seems to elongate.", "Scales start pushing out of your skin.", "Your teeth feel sharper.")]</span>"
				if(5)
					if(H.dna && !H.dna.mutantrace)
						H  << "<span class='danger'>You feel coldblooded.</span>"
						H.dna.mutantrace = "lizard"
						H.update_body()
						H.update_hair()
	return


/datum/symptom/lizardification/End(var/datum/disease/advance/A)
	..()

	var/mob/living/M = A.affected_mob

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.dna && H.dna.mutantrace=="lizard")
			H  << "<span class='danger'>You feel warmblooded.</span>"
			H.dna.mutantrace = null
			H.update_body()
			H.update_hair()
	return
