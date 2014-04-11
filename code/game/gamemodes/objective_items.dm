//Contains the target item datums for Steal objectives.

datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/weapon/bikehorn		//typepath of the objective item
	var/difficulty = 9001							//vaguely how hard it is to do this objective
	var/list/excludefromjob = list()				//If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)
	var/list/altitems = list()				//Items which can serve as an alternative to the objective (darn you blueprints)


	var/list/antag_types = list("traitor","changeling","wizard","ninja")

datum/objective_item/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1
datum/objective_item/proc/add_objective()
	return src // some objectives need to be their own copy, some do not


datum/objective_item/steal/redphone
	name = "a red telephone"
	targetitem = /obj/item/weapon/phone
	difficulty = 1
	excludefromjob = list("Mime") // hold the phone, what's this about?
	antag_types = list("changeling","wizard","ninja")

datum/objective_item/steal/caplaser
	name = "the captain's antique laser gun"
	targetitem = /obj/item/weapon/gun/energy/laser/captain
	difficulty = 5
	excludefromjob = list("Captain")

datum/objective_item/steal/handtele
	name = "a hand teleporter"
	targetitem = /obj/item/weapon/hand_tele
	difficulty = 5
	excludefromjob = list("Captain")
	antag_types = list("traitor","changeling","wizard")

datum/objective_item/steal/rcd
	name = "a rapid-construction-device"
	targetitem = /obj/item/weapon/rcd
	difficulty = 3
	antag_types = list("traitor","changeling","ninja")

datum/objective_item/steal/jetpack
	name = "a jetpack"
	targetitem = /obj/item/weapon/tank/jetpack
	difficulty = 3
	antag_types = list("traitor","changeling","wizard")

datum/objective_item/steal/magboots
	name = "a pair of magboots"
	targetitem =  /obj/item/clothing/shoes/magboots
	difficulty = 5
	excludefromjob = list("Chief Engineer")
	antag_types = list("traitor","ninja")

datum/objective_item/steal/corgimeat
	name = "a piece of corgi meat"
	targetitem = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	difficulty = 5
	excludefromjob = list("Head of Personnel") //>hurting your little buddy ever
	antag_types = list("traitor","wizard")
/*
//	We often don't have enough for captains to be a sure thing

datum/objective_item/steal/capmedal
	name = "the medal of captaincy"
	targetitem = /obj/item/clothing/tie/medal/gold/captain
	difficulty = 5
	excludefromjob = list("Captain")
*/
datum/objective_item/steal/hypo
	name = "the hypospray"
	targetitem = /obj/item/weapon/reagent_containers/hypospray
	difficulty = 5
	excludefromjob = list("Chief Medical Officer")
	antag_types = list("traitor","wizard","ninja")

datum/objective_item/steal/nukedisc
	name = "the nuclear authentication disk"
	targetitem = /obj/item/weapon/disk/nuclear
	difficulty = 5
	excludefromjob = list("Captain")
	antag_types = list("traitor","wizard","ninja")

datum/objective_item/steal/ablative
	name = "an ablative armor vest"
	targetitem = /obj/item/clothing/suit/armor/laserproof
	difficulty = 3
	excludefromjob = list("Head of Security", "Warden")
	antag_types = list("changeling","wizard")

datum/objective_item/steal/reactive
	name = "the reactive teleport armor"
	targetitem = /obj/item/clothing/suit/armor/reactive
	difficulty = 5
	excludefromjob = list("Research Director")
	antag_types = list("traitor","changeling","ninja")

datum/objective_item/steal/dermal
	name = "the head of security's dermal armor patch"
	targetitem = /obj/item/clothing/head/helmet/HoS/dermal
	difficulty = 12
	excludefromjob = list("Head of Security")
	antag_types = list("traitor","changeling","wizard")

datum/objective_item/steal/facehugger
	name = "an alien facehugger (dead or alive)"
	targetitem = /obj/item/clothing/mask/facehugger
	difficulty = 9
	excludefromjob = list("Research Director")
	antag_types = list("changeling","wizard")

datum/objective_item/steal/ai_construct
	name = "an AI core construction circuit board"
	targetitem = /obj/item/weapon/circuitboard/aicore
	difficulty = 10
	excludefromjob = list("Research Director")
	antag_types = list("traitor","changeling","wizard")

datum/objective_item/steal/ai_upload
	name = "an AI upload circuit board"
	targetitem = /obj/item/weapon/circuitboard/aiupload
	difficulty = 8
	antag_types = list("traitor","changeling","wizard")

datum/objective_item/steal/borg_upload
	name = "a cyborg upload circuit board"
	targetitem = /obj/item/weapon/circuitboard/borgupload
	difficulty = 8
	antag_types = list("traitor","changeling","wizard")

datum/objective_item/steal/balloon
	name = "a syndicate balloon"
	targetitem = /obj/item/toy/syndicateballoon
	difficulty = 18
	antag_types = list("traitor")


//Items with special checks!
datum/objective_item/steal/plasma
	name = "28 moles of plasma (full tank)"
	targetitem = /obj/item/weapon/tank
	difficulty = 3
	excludefromjob = list("Chief Engineer","Research Director","Station Engineer","Scientist","Atmospheric Technician")
	antag_types = list("traitor","ninja")

datum/objective_item/plasma/check_special_completion(var/obj/item/weapon/tank/T)
	var/target_amount = text2num(name)
	var/found_amount = 0
	found_amount += T.air_contents.toxins
	return found_amount>=target_amount


datum/objective_item/steal/functionalai
	name = "a functional AI"
	targetitem = /obj/item/device/aicard
	difficulty = 30 //beyond the impossible

datum/objective_item/functionalai/check_special_completion(var/obj/item/device/aicard/C)
	for(var/mob/living/silicon/ai/A in C)
		if(istype(A, /mob/living/silicon/ai) && A.stat != 2) //See if any AI's are alive inside that card.
			return 1
	return 0

datum/objective_item/steal/blueprints
	name = "the station blueprints"
	targetitem = /obj/item/blueprints
	difficulty = 10
	excludefromjob = list("Chief Engineer")
	antag_types = list("traitor","changeling","ninja")
	altitems = list(/obj/item/weapon/photo)

datum/objective_item/blueprints/check_special_completion(var/obj/item/I)
	if(istype(I, /obj/item/blueprints))
		return 1
	if(istype(I, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/P = I
		if(P.blueprints)	//if the blueprints are in frame
			return 1
	return 0

datum/objective_item/steal/slime
	name = "an unused sample of slime extract"
	targetitem = /obj/item/slime_extract
	difficulty = 3
	excludefromjob = list("Research Director","Scientist")
	antag_types = list("changeling","wizard","ninja")

datum/objective_item/slime/check_special_completion(var/obj/item/slime_extract/E)
	if(E.Uses > 0)
		return 1
	return 0

datum/objective_item/steal/id_cards
	name = "four unique identification cards"
	targetitem = /obj/item/weapon/card/id
	difficulty = 8
	excludefromjob = list("Head of Personnel")
	antag_types = list("changeling","wizard","ninja")
	var/list/found = list()
datum/objective_item/steal/id_cards/add_objective()
	return new type() // the check completion requires its own copy
datum/objective_item/steal/id_cards/check_special_completion(var/obj/item/weapon/card/id/id)
	for(var/obj/item/weapon/card/id/old in found)
		if(id.registered_name == old.registered_name)
			return 0
	found += id
	return (found.len >= 4)

datum/objective_item/steal/reagent
	name = "50 units of unstable mutagen"
	targetitem = /obj/item/weapon/reagent_containers
	difficulty = 8
	var/target_reagent = /datum/reagent/toxin/mutagen
	var/target_amount = 50
	var/found = 0
datum/objective_item/steal/reagent/add_objective()
	return new type() // the check completion requires its own copy
datum/objective_item/steal/reagent/check_special_completion(var/obj/item/weapon/reagent_containers/C)
	if(!C.reagents || !C.reagents.reagent_list.len)
		return 0
	for(var/datum/reagent/R in C.reagents.reagent_list)
		if(istype(R,target_reagent))
			check_reagent(R)
	return (found >= target_amount)

datum/objective_item/steal/reagent/proc/check_reagent(var/datum/reagent/R)
	found += R.volume

datum/objective_item/steal/reagent/polyacid
	name = "50 units of polytrinic acid"
	target_reagent = /datum/reagent/toxin/acid/polyacid

/*
	These were taken out because too many reagent steal types -> too many reagent steal missions

datum/objective_item/steal/reagent/chloral
	name = "50 units of chloral hydrate"
	target_reagent = /datum/reagent/toxin/chloralhydrate
datum/objective_item/steal/reagent/thermite
	name = "50 units of thermite"
	target_reagent = /datum/reagent/thermite
*/

datum/objective_item/steal/reagent/unique
	name = "four unique blood samples"
	target_amount = 4
	target_reagent = /datum/reagent/blood
	antag_types = list("changeling","wizard")
	var/list/samples = list()
datum/objective_item/steal/reagent/unique/check_special_completion()
	..()
	return samples.len >= target_amount

datum/objective_item/steal/reagent/unique/check_reagent(var/datum/reagent/R)
	// We already know it's blood.
	if(R.data["blood_DNA"])
		samples |= R.data["blood_DNA"]

datum/objective_item/steal/reagent/unique/booze // Beer run!
	name = "seven different types of alcohol"
	target_amount = 7
	target_reagent = /datum/reagent // not all types of booze are under ethanol for some reason...
	excludefromjob = list("Bartender", "Chef","Botanist")
	antag_types = list("traitor","changeling","wizard","ninja") // all factions respect the booze run

datum/objective_item/steal/reagent/unique/booze/check_reagent(var/datum/reagent/R)
	var/static/list/other_alcohols = list(/datum/reagent/atomicbomb,/datum/reagent/gargle_blaster,/datum/reagent/neurotoxin,/datum/reagent/hippies_delight)

	if(R.volume < 1) return

	if(istype(R,/datum/reagent/ethanol) || (R.type in other_alcohols))
		samples |= R.type

// This type will be added instead to the random pool, and the subtypes below
// will be added to the admin add objective screen.
// The random subtype is distinct because it is the only one that really needs
// to keep the excludefromjob list intact.
datum/objective_item/cosplay/random
	name = "Station Head Equipment (Random)"
datum/objective_item/cosplay/random
	add_objective()
		return new /datum/objective_item/cosplay()

datum/objective_item/cosplay // yeah you heard me, you know what they're doing with these things.  Mmm, yeah.  Shake it, Chief.
	excludefromjob = list("Captain","Head of Personnel", "Head of Security","Chief Engineer","Research Director","Chief Medical Officer")
	antag_types = list("traitor","changeling","wizard") // ninjas practice panty raids so often it's not even worth sending someone
	difficulty = 9
	var/list/jumpsuit_paths = list(/obj/item/clothing/under/rank/captain,/obj/item/clothing/under/rank/head_of_personnel,/obj/item/clothing/under/rank/head_of_security,/obj/item/clothing/under/rank/chief_engineer,/obj/item/clothing/under/rank/research_director,/obj/item/clothing/under/rank/chief_medical_officer)
	var/list/pda_paths = list(/obj/item/weapon/cartridge/captain,/obj/item/weapon/cartridge/hop,/obj/item/weapon/cartridge/hos,/obj/item/weapon/cartridge/ce,/obj/item/weapon/cartridge/rd,/obj/item/weapon/cartridge/cmo)
	var/list/stamp_paths = list(/obj/item/weapon/stamp/captain,/obj/item/weapon/stamp/hop,/obj/item/weapon/stamp/hos,/obj/item/weapon/stamp/ce,/obj/item/weapon/stamp/rd,/obj/item/weapon/stamp/cmo)
	var/force_type = 0 // 1:jumpsuit; 2:pda; 3:stamp
	var/force_job = 0
	New()
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

datum/objective_item/cosplay/jumpsuit
	force_type = 1
	antag_types = list() // forces them to not be picked randomly
datum/objective_item/cosplay/jumpsuit/captain/force_job = 1
datum/objective_item/cosplay/jumpsuit/hop/force_job = 2
datum/objective_item/cosplay/jumpsuit/hos/force_job = 3
datum/objective_item/cosplay/jumpsuit/ce/force_job = 4
datum/objective_item/cosplay/jumpsuit/rd/force_job = 5
datum/objective_item/cosplay/jumpsuit/cmo/force_job = 6

datum/objective_item/cosplay/pda
	force_type = 2
	antag_types = list()
datum/objective_item/cosplay/pda/captain/force_job = 1
datum/objective_item/cosplay/pda/hop/force_job = 2
datum/objective_item/cosplay/pda/hos/force_job = 3
datum/objective_item/cosplay/pda/ce/force_job = 4
datum/objective_item/cosplay/pda/rd/force_job = 5
datum/objective_item/cosplay/pda/cmo/force_job = 6

//Old ninja objectives.
datum/objective_item/special
	antag_types = list("ninja")
datum/objective_item/special/pinpointer
	name = "the captain's pinpointer"
	targetitem = /obj/item/weapon/pinpointer
	difficulty = 10
	antag_types = list("traitor","changeling","wizard","ninja")

datum/objective_item/special/aegun
	name = "an advanced energy gun"
	targetitem = /obj/item/weapon/gun/energy/gun/nuclear
	difficulty = 10

datum/objective_item/special/ddrill
	name = "a diamond drill"
	targetitem = /obj/item/weapon/pickaxe/diamonddrill
	difficulty = 10

datum/objective_item/special/boh
	name = "a bag of holding"
	targetitem = /obj/item/weapon/storage/backpack/holding
	difficulty = 10

datum/objective_item/special/hypercell
	name = "a hyper-capacity cell"
	targetitem = /obj/item/weapon/cell/hyper
	difficulty = 5

datum/objective_item/special/laserpointer
	name = "a laser pointer"
	targetitem = /obj/item/device/laser_pointer
	difficulty = 5

datum/objective_item/special/telecomhub
	name =  "a telecom hub circuit board"
	targetitem = /obj/item/weapon/circuitboard/telecomms/hub
	difficulty = 15

//Stack objectives get their own subtype
datum/objective_item/stack
	name = "5 cardboards"
	targetitem = /obj/item/stack/sheet/cardboard
	difficulty = 9001

datum/objective_item/stack/check_special_completion(var/obj/item/stack/S)
	var/target_amount = text2num(name)
	var/found_amount = 0

	if(istype(S, targetitem))
		found_amount = S.amount
	return found_amount>=target_amount

datum/objective_item/stack/diamond
	name = "10 diamonds"
	targetitem = /obj/item/stack/sheet/mineral/diamond
	difficulty = 10

datum/objective_item/stack/gold
	name = "50 gold bars"
	targetitem = /obj/item/stack/sheet/mineral/gold
	difficulty = 15

datum/objective_item/stack/uranium
	name = "25 refined uranium bars"
	targetitem = /obj/item/stack/sheet/mineral/uranium
	difficulty = 10

