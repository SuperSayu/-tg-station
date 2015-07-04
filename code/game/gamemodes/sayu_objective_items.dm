/datum/objective_item/steal/corgimeat
	name = "a piece of corgi meat"
	targetitem = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/corgi
	difficulty = 5
	excludefromjob = list("Quartermaster","Cargo Technician","Head of Personnel") //>hurting your little buddy ever
	antag_types = list("traitor","Changeling","Wizard")


/datum/objective_item/steal/redphone
	name = "a red telephone"
	targetitem = /obj/item/weapon/phone
	difficulty = 5
	excludefromjob = list("Mime") // hold the phone, what's this about?
	antag_types = list("traitor", "Changeling","Wizard","Space Ninja")

/datum/objective_item/steal/facehugger
	name = "an alien facehugger (dead or alive)"
	targetitem = /obj/item/clothing/mask/facehugger
	difficulty = 10
	excludefromjob = list("Research Director")
	antag_types = list("Changeling","Wizard")

/datum/objective_item/steal/ai_construct
	name = "an AI core construction circuit board"
	targetitem = /obj/item/weapon/circuitboard/aicore
	difficulty = 3
	excludefromjob = list("Research Director")
	antag_types = list("traitor","Changeling","Wizard")

/datum/objective_item/steal/ai_upload
	name = "an AI upload circuit board"
	targetitem = /obj/item/weapon/circuitboard/aiupload
	difficulty = 3
	excludefromjob = list("Research Director")
	antag_types = list("traitor","Changeling","Wizard")

/datum/objective_item/steal/borg_upload
	name = "a cyborg upload circuit board"
	targetitem = /obj/item/weapon/circuitboard/borgupload
	difficulty = 3
	excludefromjob = list("Research Director")
	antag_types = list("traitor","Changeling","Wizard")


//ID theft
/datum/objective_item/steal/id_cards
	name = "four unique identification cards"
	targetitem = /obj/item/weapon/card/id
	difficulty = 10
	excludefromjob = list("Head of Personnel")
	antag_types = list("Changeling","Wizard","Space Ninja")
	var/list/found = list()
/datum/objective_item/steal/id_cards/add_objective()
	return new type() // the check completion requires its own copy
/datum/objective_item/steal/id_cards/check_special_completion(var/obj/item/weapon/card/id/id)
	for(var/obj/item/weapon/card/id/old in found)
		if(id.registered_name == old.registered_name)
			return 0
	found += id
	return (found.len >= 4)

//Reagent Objectives
/datum/objective_item/steal/reagent
	name = "50 units of unstable mutagen"
	targetitem = /obj/item/weapon/reagent_containers
	difficulty = 3
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")
	var/target_reagent = /datum/reagent/toxin/mutagen
	var/target_amount = 50
	var/found = 0
/datum/objective_item/steal/reagent/add_objective()
	return new type() // the check completion requires its own copy
/datum/objective_item/steal/reagent/check_special_completion(var/obj/item/weapon/reagent_containers/C)
	if(!C.reagents || !C.reagents.reagent_list.len)
		return 0
	for(var/datum/reagent/R in C.reagents.reagent_list)
		if(istype(R,target_reagent))
			check_reagent(R)
	return (found >= target_amount)

/datum/objective_item/steal/reagent/proc/check_reagent(var/datum/reagent/R)
	found += R.volume
/datum/objective_item/steal/reagent/compare_to(var/datum/objective_item/i)
	return i.type == type

/datum/objective_item/steal/reagent/unique
	name = "four unique blood samples"
	target_amount = 4
	target_reagent = /datum/reagent/blood
	antag_types = list("Changeling","Wizard")
	var/list/samples = list()

/datum/objective_item/steal/reagent/unique/check_special_completion()
	..()
	return samples.len >= target_amount

/datum/objective_item/steal/reagent/unique/check_reagent(var/datum/reagent/R)
	// We already know it's blood.
	if(R.data["blood_DNA"])
		samples |= R.data["blood_DNA"]

/datum/objective_item/steal/reagent/unique/booze // Beer run!
	name = "seven different types of alcohol"
	target_amount = 7
	target_reagent = /datum/reagent // not all types of booze are under ethanol for some reason...
	excludefromjob = list("Bartender", "Chef","Botanist")
	antag_types = list("Wizard","Space Ninja") // all factions respect the booze run

/datum/objective_item/steal/reagent/unique/booze/check_reagent(var/datum/reagent/R)
	var/static/list/other_alcohols = list(/datum/reagent/consumable/atomicbomb,/datum/reagent/consumable/gargle_blaster,/datum/reagent/consumable/neurotoxin,/datum/reagent/consumable/hippies_delight)

	if(R.volume < 1) return

	if(istype(R,/datum/reagent/consumable/ethanol) || (R.type in other_alcohols))
		samples |= R.type

// This type will be added instead to the random pool, and the subtypes below
// will be added to the admin add objective screen.
// The random subtype is distinct because it is the only one that really needs
// to keep the excludefromjob list intact.
/datum/objective_item/cosplay/random
	name = "Station Head Equipment (Random)"
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")
	excludefromjob = list("Captain","Head of Personnel", "Head of Security","Chief Engineer","Research Director","Chief Medical Officer")

/datum/objective_item/cosplay/random/add_objective()
	return new /datum/objective_item/cosplay()

/datum/objective_item/cosplay // yeah you heard me, you know what they're doing with these things.  Mmm, yeah.  Shake it, Chief.
	excludefromjob = list("Captain","Head of Personnel", "Head of Security","Chief Engineer","Research Director","Chief Medical Officer")
	antag_types = list()
	difficulty = 9
	var/list/jumpsuit_paths = list(/obj/item/clothing/under/rank/captain,/obj/item/clothing/under/rank/head_of_personnel,/obj/item/clothing/under/rank/head_of_security,/obj/item/clothing/under/rank/chief_engineer,/obj/item/clothing/under/rank/research_director,/obj/item/clothing/under/rank/chief_medical_officer)
	var/list/pda_paths = list(/obj/item/weapon/cartridge/captain,/obj/item/weapon/cartridge/hop,/obj/item/weapon/cartridge/hos,/obj/item/weapon/cartridge/ce,/obj/item/weapon/cartridge/rd,/obj/item/weapon/cartridge/cmo)
	var/list/stamp_paths = list(/obj/item/weapon/stamp/captain,/obj/item/weapon/stamp/hop,/obj/item/weapon/stamp/hos,/obj/item/weapon/stamp/ce,/obj/item/weapon/stamp/rd,/obj/item/weapon/stamp/cmo)
	var/force_type = 0 // 1:jumpsuit; 2:pda; 3:stamp
	var/force_job = 0
/datum/objective_item/cosplay/New()
	..()
	var/index
	if(force_job)
		index = force_job
	else
		index = rand(1,excludefromjob.len)

	var/job = excludefromjob[index]
	excludefromjob = list(job)

	if(!force_type) force_type = pick(1,2,3)
	switch(force_type)
		if(1)
			targetitem = jumpsuit_paths[index]
			name = "a [job]'s jumpsuit"
		if(2)
			targetitem = pda_paths[index]
			var/obj/O = new targetitem(null)
			name = "\a [O] ([job]'s PDA cartridge)"
		if(3)
			targetitem = stamp_paths[index]
			name = "a [job]'s rubber stamp"

/datum/objective_item/cosplay/jumpsuit
	force_type = 1
	antag_types = list() // forces them to not be picked randomly

/datum/objective_item/cosplay/jumpsuit/captain/force_job = 1
/datum/objective_item/cosplay/jumpsuit/hop/force_job = 2
/datum/objective_item/cosplay/jumpsuit/hos/force_job = 3
/datum/objective_item/cosplay/jumpsuit/ce/force_job = 4
/datum/objective_item/cosplay/jumpsuit/rd/force_job = 5
/datum/objective_item/cosplay/jumpsuit/cmo/force_job = 6

/datum/objective_item/cosplay/pda
	force_type = 2
	antag_types = list()

/datum/objective_item/cosplay/pda/captain/force_job = 1
/datum/objective_item/cosplay/pda/hop/force_job = 2
/datum/objective_item/cosplay/pda/hos/force_job = 3
/datum/objective_item/cosplay/pda/ce/force_job = 4
/datum/objective_item/cosplay/pda/rd/force_job = 5
/datum/objective_item/cosplay/pda/cmo/force_job = 6

/datum/objective_item/cosplay/stamp
	force_type = 3
	antag_types = list()

/datum/objective_item/cosplay/stamp/captain/force_job = 1
/datum/objective_item/cosplay/stamp/hop/force_job = 2
/datum/objective_item/cosplay/stamp/hos/force_job = 3
/datum/objective_item/cosplay/stamp/ce/force_job = 4
/datum/objective_item/cosplay/stamp/rd/force_job = 5
/datum/objective_item/cosplay/stamp/cmo/force_job = 6