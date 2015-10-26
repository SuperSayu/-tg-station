/*
 HUMANS
*/

/datum/species/human
	name = "Human"
	id = "human"
	desc = "Beings of flesh and bone who have colonized the majority of Nanotrasen-owned space. \
	Surprisingly versatile."
	default_color = "FFFFFF"
	roundstart = 1
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	mutant_bodyparts = list("tail_human", "ears")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None")
	use_skintones = 1

/datum/species/human/qualifies_for_rank(rank, list/features)
	if((!features["tail_human"] || features["tail_human"] == "None") && (!features["ears"] || features["ears"] == "None"))
		return 1	//Pure humans are always allowed in all roles.

	//Mutants are not allowed in most roles.
	if(rank in command_positions)
		return 0
	if(rank in security_positions) //This list does not include lawyers.
		return 0
	if(rank in science_positions)
		return 0
	if(rank in medical_positions)
		return 0
	if(rank in engineering_positions)
		return 0
	if(rank == "Quartermaster") //QM is not contained in command_positions but we still want to bar mutants from it.
		return 0
	return 1


/datum/species/human/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		H.set_species(/datum/species/jelly/slime)
		H.reagents.del_reagent(chem.type)
		H.faction |= "slime"
		return 1

//Curiosity killed the cat's wagging tail.
datum/species/human/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		H.endTailWag()

/*
 LIZARDPEOPLE
*/

/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Kokiyg"
	id = "lizard"
	desc = "The Kokiyg are coldblooded reptilian creatures known for their dexterity and perseverance."
	say_mod = "hisses"
	default_color = "00FF00"
	roundstart = 1
	specflags = list(MUTCOLORS,EYECOLOR,LIPS)
	mutant_bodyparts = list("tail_lizard", "snout", "spines", "horns", "frills", "body_markings")
	default_features = list("mcolor" = "0F0", "tail" = "Smooth", "snout" = "Round", "horns" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	species_temp_coeff = 0.5
	species_temp_offset = -20
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/lizard

/datum/species/lizard/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_lizard_name(gender)

	var/randname = lizard_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/lizard/qualifies_for_rank(rank, list/features)
	if(rank in command_positions)
		return 0
	return 1

/*
/datum/species/lizard/handle_speech(message)
	// jesus christ why
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "s", "sss")
		return message
*/

//I wag in death
/datum/species/lizard/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		H.endTailWag()

/*
 PLANTPEOPLE
*/

/datum/species/plant
	// Creatures made of leaves and plant matter.
	name = "Chlorophyte"
	id = "plant"
	desc = "Made entirely of plant matter, the Chlorophytes are naturally free spirits, and do not care much for conformity."
	default_color = "59CE00"
	roundstart = 1
	specflags = list(MUTCOLORS,HAIR,FACEHAIR,EYECOLOR,NOPIXREMOVE)
	hair_luminosity = -115
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/plant

/datum/species/plant/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plantbgone")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/plant/on_hit(proj_type, mob/living/carbon/human/H)
	switch(proj_type)
		if(/obj/item/projectile/energy/floramut)
			if(prob(15))
				H.rad_act(rand(30,80))
				H.Weaken(5)
				H.visible_message("<span class='warning'>[H] writhes in pain as \his vacuoles boil.</span>", "<span class='userdanger'>You writhe in pain as your vacuoles boil!</span>", "<span class='italics'>You hear the crunching of leaves.</span>")
				if(prob(80))
					randmutb(H)
				else
					randmutg(H)
				H.domutcheck()
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message("<span class='userdanger'>The radiation beam singes you!</span>")
		if(/obj/item/projectile/energy/florayield)
			H.nutrition = min(H.nutrition+30, NUTRITION_LEVEL_FULL)
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
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = min(10,T.lighting_lumcount) - 5
			else						light_amount =  5
		H.nutrition += light_amount
		if(H.nutrition > NUTRITION_LEVEL_FULL)
			H.nutrition = NUTRITION_LEVEL_FULL
		if(light_amount > 2) //if there's enough light, heal
			H.heal_overall_damage(1,1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
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
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	specflags = list(NOBREATH,NOBLOOD,RADIMMUNE)
	dangerous_existence = 1

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
 JELLYPEOPLE
*/

/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "Xenobiological Jelly Entity"
	id = "jelly"
	default_color = "00FF90"
	say_mod = "chirps"
	eyes = "jelleyes"
	specflags = list(MUTCOLORS,EYECOLOR,NOBLOOD)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	var/recently_changed = 1

/datum/species/jelly/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD) //can't farm slime jelly from a dead slime/jelly person indefinitely
		return
	if(!H.reagents.get_reagent_amount("slimejelly"))
		if(recently_changed)
			H.reagents.add_reagent("slimejelly", 80)
			recently_changed = 0
		else
			H.reagents.add_reagent("slimejelly", 5)
			H.adjustBruteLoss(5)
			H << "<span class='danger'>You feel empty!</span>"

	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume < 100)
			if(H.nutrition >= NUTRITION_LEVEL_STARVING)
				H.reagents.add_reagent("slimejelly", 0.5)
				H.nutrition -= 5
		if(S.volume < 50)
			if(prob(5))
				H << "<span class='danger'>You feel drained!</span>"
		if(S.volume < 10)
			H.losebreath++

/datum/species/jelly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "slimejelly")
		return 1

/*
 SLIMEPEOPLE
*/

/datum/species/jelly/slime
	// Humans mutated by slime mutagen, produced from green slimes. They are not targetted by slimes.
	name = "Slimeperson"
	id = "slime"
	default_color = "00FFFF"
	darksight = 3
	invis_sight = SEE_INVISIBLE_LEVEL_ONE
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,NOBLOOD)
	say_mod = "says"
	eyes = "eyes"
	hair_color = "mutcolor"
	hair_alpha = 150
	ignored_by = list(/mob/living/simple_animal/slime)


/datum/species/jelly_sayu
	name = "Xenoid"
	id = "jelly"
	desc = "The three-eyed Xenoids hail from the outer reaches of the galaxy. They are vulnerable to water, but are also resistant to cellular damage."
	default_color = "00FF90"
	roundstart = 1
	eyes = "jelleyes"
	eyecount = 3
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR)
	hair_color = "mutcolor"
	hair_alpha = 195
	hair_luminosity = -75
	bone_chance_adjust = 1.2
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime

/datum/species/jelly_sayu/before_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	if(H.job == "Quartermaster" || H.job == "Captain" || H.job == "Head of Personnel")
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sunglasses3(H), slot_glasses)
	if(H.job == "Head of Security" || H.job == "Warden")
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/sunglasses/sunglasses3(H), slot_glasses)

/datum/species/jelly_sayu/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "water")	// DANGER
		if(H.reagents.has_reagent("water", 10))
			H.adjustToxLoss(1)
		H.reagents.remove_reagent(chem.id, 0.8)
		return 1

/datum/species/jelly_sayu/spec_life(mob/living/carbon/human/H)
	if(H.getCloneLoss()) // clone loss is slowly regenerated
		H.adjustCloneLoss(-0.2)

/*
 GOLEMS
*/

/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "golem"
	sexes = 0
	specflags = list(NOBREATH,HEATRES,COLDRES,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE)
	speedmod = 3
	armor = 55
	punchmod = 5
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_head, slot_w_uniform)
	nojumpsuit = 1
	bone_chance_adjust = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem

/*
 ADAMANTINE GOLEMS
*/

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine

/*
 FLIES
*/

/datum/species/fly
	// Humans turned into fly-like abominations in teleporter accidents.
	name = "Human?"
	id = "fly"
	say_mod = "buzzes"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/fly

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/fly/handle_speech(message)
	return replacetext(message, "z", stutter("zz"))

/*
 SKELETONS
*/

/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	specflags = list(NOBREATH,HEATRES,COLDRES,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE)
	var/list/myspan = null


/datum/species/skeleton/New()
	..()
	myspan = list(pick(SPAN_SANS,SPAN_PAPYRUS)) //pick a span and stick with it for the round


/datum/species/skeleton/get_spans()
	return myspan


/*
 ZOMBIES
*/

/datum/species/zombie
	// 1spooky
	name = "Brain-Munching Zombie"
	id = "zombie"
	say_mod = "moans"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	specflags = list(NOBREATH,HEATRES,COLDRES,NOBLOOD,RADIMMUNE)

/datum/species/zombie/handle_speech(message)
	var/list/message_list = text2list(message, " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len - 1)
		var/inserttext = message_list[insertpos]

		if(!(copytext(inserttext, length(inserttext) - 2) == "..."))
			message_list[insertpos] = inserttext + "..."

		if(prob(20) && message_list.len > 3)
			message_list.Insert(insertpos, "[pick("BRAINS", "Brains", "Braaaiinnnsss", "BRAAAIIINNSSS")]...")

	return list2text(message_list, " ")

/datum/species/cosmetic_zombie
	name = "Human"
	id = "zombie"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie

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
	specflags = list(HAIR,MUTCOLORS,EYECOLOR)
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

/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	darksight = 3
	say_mod = "gibbers"
	sexes = 0
	invis_sight = SEE_INVISIBLE_LEVEL_ONE
	specflags = list(NOBLOOD,NOBREATH,VIRUSIMMUNE)
	var/scientist = 0 // vars to not pollute spieces list with castes
	var/agent = 0
	var/team = 1

/datum/species/abductor/handle_speech(message)
	//Hacks
	var/mob/living/carbon/human/user = usr
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.dna.species.id != "abductor")
			continue
		else
			var/datum/species/abductor/target_spec = H.dna.species
			if(target_spec.team == team)
				H << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
				//return - technically you can add more aliens to a team
	for(var/mob/M in dead_mob_list)
		M << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
	return ""


var/global/image/plasmaman_on_fire = image("icon"='icons/mob/OnFire.dmi', "icon_state"="plasmaman")

/datum/species/plasmaman
	name = "Plasbone"
	id = "plasmaman"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	specflags = list(NOBLOOD,RADIMMUNE)
	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breath THIS!
	safe_toxins_max = 0
	dangerous_existence = 1 //So so much
	var/skin = 0

/datum/species/plasmaman/skin
	name = "Skinbone"
	skin = 1

/datum/species/plasmaman/update_base_icon_state(mob/living/carbon/human/H)
	var/base = ..()
	if(base == id)
		base = "[base][skin]"
	return base

/datum/species/plasmaman/spec_life(mob/living/carbon/human/H)
	var/datum/gas_mixture/environment = H.loc.return_air()

	if(!istype(H.wear_suit, /obj/item/clothing/suit/space/eva/plasmaman) || !istype(H.head, /obj/item/clothing/head/helmet/space/hardsuit/plasmaman))
		if(environment)
			var/total_moles = environment.total_moles()
			if(total_moles)
				if((environment.oxygen /total_moles) >= 0.01)
					if(!H.on_fire)
						H.visible_message("<span class='danger'>[H]'s body reacts with the atmosphere and bursts into flames!</span>","<span class='userdanger'>Your body reacts with the atmosphere and bursts into flame!</span>")
					H.adjust_fire_stacks(0.5)
					H.IgniteMob()
	else
		if(H.fire_stacks)
			var/obj/item/clothing/suit/space/eva/plasmaman/P = H.wear_suit
			if(istype(P))
				P.Extinguish(H)
	H.update_fire()

//Heal from plasma
/datum/species/plasmaman/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plasma")
		H.adjustBruteLoss(-5)
		H.adjustFireLoss(-5)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1




