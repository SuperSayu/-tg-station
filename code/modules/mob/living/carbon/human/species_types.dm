/*
 HUMANS
*/

/datum/species/human
	name = "Human"
	id = "human"
	desc = "Beings of flesh and bone who have colonized the majority of Nanotrasen-owned space. \
	Surprisingly versatile."
	roundstart = 1
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	use_skintones = 1

/datum/species/human/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		H.dna.species = new /datum/species/slime()
		H.regenerate_icons()
		H.reagents.del_reagent(chem.type)
		return 1

/*
 LIZARDPEOPLE
*/

/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Kokiyg"
	id = "lizard"
	desc = "The Kokiyg are reptilian creatures known for their dexterity and perseverance. Because they are coldblooded, \
	their bodies adjust to external temperatures faster. They are not the type of being you would want to cross."
	say_mod = "hisses"
	default_color = "00FF00"
	roundstart = 1
	specflags = list(HAIR,MUTCOLORS,LAYER2,EYECOLOR,LIPS)
	spec_hair = 1 // They have crests/horns instead of hair
	hair_color = "mutcolor"
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	species_temp_coeff = 0.5
	species_temp_offset = -20
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/lizard

//NOPE
/*
	/datum/species/lizard/handle_speech(message)

		if(copytext(message, 1, 2) != "*")
			message = replacetext(message, "s", stutter("ss"))

		return message
*/

/*
 PLANTPEOPLE
*/

/datum/species/plant
	// Creatures made of leaves and plant matter.
	name = "Chlorophyte" // WIP name
	id = "plant"
	desc = "Made entirely of plant matter, the Chlorophytes can store vast quantities of nutrients within their bodies. \
	They are naturally free spirits, and do not care much for conformity."
	default_color = "59CE00"
	roundstart = 1
	specflags = list(MUTCOLORS,HAIR,FACEHAIR,EYECOLOR,NOPIXREMOVE)
	hair_color = "mutcolor"
	hair_luminosity = -115
	attack_verb = "slice"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.5
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/plant

/datum/species/plant/handle_chemicals_in_body(var/mob/living/carbon/human/H)
	if(H.reagents) H.reagents.metabolize(H)

	if(FAT in H.mutations)
		if(H.overeatduration < 200)	// Plantpeople become fit sooner...
			H << "<span class='notice'>You feel your vines loosen, and once again nutrients begin to flow within you.</span>"
			H.mutations -= FAT
			H.update_inv_w_uniform(0)
			H.update_inv_wear_suit()
	else
		if(H.overeatduration > 650)	// ...and become fat later
			H << "<span class='danger'>You feel your vines constrict tightly.</span>"
			H.mutations |= FAT
			H.update_inv_w_uniform(0)
			H.update_inv_wear_suit()

	if (H.nutrition > 0 && H.stat != 2)	// Plantpeople lose nutrition slower.
		H.nutrition = max (0, H.nutrition - (HUNGER_FACTOR*0.75))

	if (H.nutrition > 450)
		if(H.overeatduration < 600)
			H.overeatduration++
	else
		if(H.overeatduration > 1)
			H.overeatduration -= 2

	if(H.drowsyness)
		H.drowsyness--
		H.eye_blurry = max(2, H.eye_blurry)
		if (prob(5))
			H.sleeping += 1
			H.Paralyse(5)

	H.confused = max(0, H.confused - 1)
	if(H.resting)
		H.dizziness = max(0, H.dizziness - 15)
		H.jitteriness = max(0, H.jitteriness - 15)
	else
		H.dizziness = max(0, H.dizziness - 3)
		H.jitteriness = max(0, H.jitteriness - 3)

	H.updatehealth()

	return

/datum/species/plant/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plantbgone")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/plant/on_hit(proj_type, mob/living/carbon/human/H)
	switch(proj_type)
		if(/obj/item/projectile/energy/floramut)
			if(prob(15))
				H.apply_effect((rand(30,80)),IRRADIATE)
				H.Weaken(5)
				for (var/mob/V in viewers(H))
					V.show_message("<span class='danger'>[H] writhes in pain as \his vacuoles boil.</span>", 3, "<span class='danger'>You hear the crunching of leaves.</span>", 2)
				if(prob(80))
					randmutb(H)
					domutcheck(H,null)
				else
					randmutg(H)
					domutcheck(H,null)
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message("<span class='danger'>The radiation beam singes you!</span>")
		if(/obj/item/projectile/energy/florayield)
			H.nutrition = min(H.nutrition+30, 500)
	return

/*
 PODPEOPLE
*/

/datum/species/plant/pod
	// A mutation caused by a human being ressurected in a revival pod.
	// These regain health in light, and begin to wither in darkness.
	name = "Podperson"
	roundstart = 0
	//id = "pod" -- These use the same sprites now

/datum/species/plant/pod/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = min(10,T.lighting_lumcount) - 5
			else						light_amount =  5
		H.nutrition += light_amount
		if(H.nutrition > 500)
			H.nutrition = 500
		if(light_amount > 2) //if there's enough light, heal
			H.heal_overall_damage(1,1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < 200)
		H.take_overall_damage(2,0)

/*
 SHADOWPEOPLE
*/

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	id = "shadow"
	darksight = 8
	sexes = 0
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/shadow

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = T.lighting_lumcount
			else						light_amount =  10
		if(light_amount > 2) //if there's enough light, start dying
			H.take_overall_damage(1,1)
		else if (light_amount < 2) //heal in the dark
			H.heal_overall_damage(1,1)

/*
 SLIMEPEOPLE
*/

/datum/species/slime
	// Humans mutated by slime mutagen, produced from green slimes. They are not targetted by slimes.
	name = "Slimeperson"
	id = "slime"
	default_color = "00FFFF"
	darksight = 3
	invis_sight = SEE_INVISIBLE_LEVEL_ONE
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR)
	hair_color = "mutcolor"
	hair_alpha = 165
	hair_luminosity = -75
	ignored_by = list(/mob/living/carbon/slime)
	bone_chance_adjust = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/slime

/datum/species/slime/spec_life(mob/living/carbon/human/H)
	if ((HULK in H.mutations))
		H.mutations.Remove(HULK)

/*
 JELLYPEOPLE
*/

/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "Xenoid" // WIP name
	id = "jelly"
	desc = "The three-eyed Xenoids hail from the outer reaches of the galaxy. They are perceptive beings not known \
	for being unnecessarily violent. Because their bodies are made of gel-like goo, they naturally heal from \
	genetic damage. However, they are also fragile, and take more damage from freezing."
	default_color = "00FF90"
	roundstart = 1
	eyes = "jelleyes"
	eyecount = 3
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR)
	hair_color = "mutcolor"
	hair_alpha = 195
	hair_luminosity = -75
	bone_chance_adjust = 1.2
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/slime

	// COLD DAMAGE LEVEL ONE: 0.9 (+0.4)
	// COLD DAMAGE LEVEL TWO: 2.7 (+1.2)
	// COLD DAMAGE LEVEL THREE: 5.4 (+2.4)
	coldmod = 1.8

/datum/species/jelly/before_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	if(H.job == "Quartermaster" || H.job == "Captain" || H.job == "Head of Personnel")
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sunglasses3(H), slot_glasses)
	if(H.job == "Head of Security" || H.job == "Warden")
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/sunglasses/sunglasses3(H), slot_glasses)

/datum/species/jelly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "water")	// DANGER
		if(H.reagents.has_reagent("water", 10))
			H.adjustToxLoss(1)
		H.reagents.remove_reagent(chem.id, 0.8)
		return 1

/datum/species/jelly/spec_life(mob/living/carbon/human/H)
	if ((HULK in H.mutations))
		H.mutations.Remove(HULK)
	if(H.getCloneLoss()) // clone loss is slowly regenerated
		H.adjustCloneLoss(-0.2)

/*
 AXOLOTL PEOPLE -- WIP IN PROGRESS
*/

/*/datum/species/axolotl
	// The Lotyn are a race of axolotl-like aliens who are known for being religious, although a handful of them have rejected
	// their customs.

	name = "Lotyn"
	id = "axolotl"
	roundstart = 1
	specflags = list(MUTCOLORS,EYECOLOR,LIPS,NOPIXREMOVE)
	default_color = "#EC88FF"

/datum/species/axolotl/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "holywater")	// holy water acts as ryetalyn
		H.mutations = list()
		H.disabilities = 0
		H.sdisabilities = 0
		H.update_mutations()
		H.reagents.remove_reagent(chem.id, 2) // metabolizes faster
		return 1*/

/*
 BIRD PEOPLE -- ALSO A WIP IN PROGRESS
 */

/*/datum/species/bird
	name = "Aven"
	id = "bird"
	desc = "Stuff goes here."
	specflags = list(HAIR,MUTCOLORS,LAYER2,EYECOLOR)
	say_mod = "hisses"
	spec_hair = 1
	hair_color = "mutcolor"
	speedmod = -1
	no_equip = list(slot_wear_mask, slot_shoes)
	roundstart = 1

/*/datum/species/bird/before_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	H.equip_to_slot(new /obj/item/weapon/tank/co2(H), slot_r_store)
	H.equip_to_slot(new /obj/item/clothing/mask/breath(H), slot_wear_mask)*/

/datum/species/bird/after_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	if(H.job == "Head of Security" || H.job == "Warden" || H.job == "Security Officer")
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), slot_shoes)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)*/

/*
 GOLEMS
*/

/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "golem"
	specflags = list(NOBREATH,HEATRES,COLDRES,NOGUNS,NOBLOOD,RADIMMUNE)
	sexes = 0
	speedmod = 3
	armor = 55
	punchmod = 5
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_head, slot_w_uniform)
	nojumpsuit = 1
	bone_chance_adjust = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/golem

/*
 ADAMANTINE GOLEMS
*/

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/golem/adamantine

/*
 FLIES
*/

/datum/species/fly
	// Humans turned into fly-like abominations in teleporter accidents.
	name = "Human?"
	id = "fly"
	say_mod = "buzzes"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/fly

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/fly/handle_speech(message)
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "z", stutter("zz"))

	return message

/*
 SKELETONS
*/

/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/human/mutant/skeleton

#undef SPECIES_LAYER
#undef BODY_LAYER
#undef HAIR_LAYER

#undef HUMAN_MAX_OXYLOSS
#undef HUMAN_CRIT_MAX_OXYLOSS

#undef HEAT_DAMAGE_LEVEL_1
#undef HEAT_DAMAGE_LEVEL_2
#undef HEAT_DAMAGE_LEVEL_3

#undef COLD_DAMAGE_LEVEL_1
#undef COLD_DAMAGE_LEVEL_2
#undef COLD_DAMAGE_LEVEL_3

#undef HEAT_GAS_DAMAGE_LEVEL_1
#undef HEAT_GAS_DAMAGE_LEVEL_2
#undef HEAT_GAS_DAMAGE_LEVEL_3

#undef COLD_GAS_DAMAGE_LEVEL_1
#undef COLD_GAS_DAMAGE_LEVEL_2
#undef COLD_GAS_DAMAGE_LEVEL_3

#undef TINT_IMPAIR
#undef TINT_BLIND
