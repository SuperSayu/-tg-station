datum/objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//currently only used for custom objectives.

	New(var/text)
		if(text)
			explanation_text = text

	proc/check_completion()
		return completed

	proc/find_target()
		var/list/possible_targets = list()
		for(var/datum/mind/possible_target in ticker.minds)
			if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != 2))
				possible_targets += possible_target

		if(owner) // avoid duplicates where possible
			for(var/datum/objective/O in owner.objectives)
				possible_targets -= O.target

		if(possible_targets.len > 0)
			target = pick(possible_targets)
		else
			target = null

	proc/find_target_by_role(role, role_type=0)//Option sets either to check assigned role or special role. Default to assigned.
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && ishuman(possible_target.current) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) )
				target = possible_target
				break



datum/objective/assassinate
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target


	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
				return 1
			return 0
		return 1



datum/objective/mutiny
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || !ishuman(target.current) || !target.current.ckey || !target.current.client)
				return 1
			var/turf/T = get_turf(target.current)
			if(T && (T.z != 1))			//If they leave the station they count as dead for this
				return 2
			return 0
		return 1


datum/objective/debrain//I want braaaainssss
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Steal the brain of [target.current.real_name]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Steal the brain of [target.current.real_name] the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(!target)//If it's a free objective.
			return 1
		if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
			return 0
		if( !target.current || !isbrain(target.current) )
			return 0
		var/atom/A = target.current
		while(A.loc)			//check to see if the brainmob is on our person
			A = A.loc
			if(A == owner.current)
				return 1
		return 0


datum/objective/protect//The opposite of killing a dude.
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Protect [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Protect [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(!target)			//If it's a free objective.
			return 1
		if(target.current)
			if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current))
				return 0
			return 1
		return 0


datum/objective/hijack
	explanation_text = "Hijack the emergency shuttle by escaping alone."

	check_completion()
		if(!owner.current || owner.current.stat)
			return 0
		if(emergency_shuttle.location<2)
			return 0
		if(issilicon(owner.current))
			return 0
		var/area/shuttle = locate(/area/shuttle/escape/centcom)
		var/list/protected_mobs = list(/mob/living/silicon/ai, /mob/living/silicon/pai)
		for(var/mob/living/player in player_list)
			if(player.type in protected_mobs)	continue
			if (player.mind && (player.mind != owner))
				if(player.stat != DEAD)			//they're not dead!
					if(get_turf(player) in shuttle)
						return 0
		return 1


datum/objective/block
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."


	check_completion()
		if(!istype(owner.current, /mob/living/silicon))
			return 0
		if(emergency_shuttle.location<2)
			return 0
		if(!owner.current)
			return 0
		var/area/shuttle = locate(/area/shuttle/escape/centcom)
		var/protected_mobs[] = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/silicon/robot)
		for(var/mob/living/player in player_list)
			if(player.type in protected_mobs)	continue
			if (player.mind)
				if (player.stat != 2)
					if (get_turf(player) in shuttle)
						return 0
		return 1

datum/objective/silence
	explanation_text = "Do not allow anyone to escape the station.  Only allow the shuttle to be called when everyone is dead and your story is the only one left."

	check_completion()
		if(emergency_shuttle.location<2)
			return 0

		for(var/mob/living/player in player_list)
			if(player == owner.current)
				continue
			if(player.mind)
				if(player.stat != DEAD)
					var/turf/T = get_turf(player)
					if(!T)	continue
					switch(T.loc.type)
						if(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
							return 0
		return 1


datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive."


	check_completion()
		if(issilicon(owner.current))
			return 0
		if(isbrain(owner.current))
			return 0
		if(emergency_shuttle.location<2)
			return 0
		if(!owner.current || owner.current.stat ==2)
			return 0
		var/turf/location = get_turf(owner.current.loc)
		if(!location)
			return 0

		if(istype(location, /turf/simulated/shuttle/floor4)) // Fails traitors if they are in the shuttle brig -- Polymorph
			return 0

		var/area/check_area = location.loc
		if(istype(check_area, /area/shuttle/escape/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod1/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod2/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod3/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod5/centcom))
			return 1
		else
			return 0



datum/objective/survive
	explanation_text = "Stay alive until the end."

	check_completion()
		if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
			return 0		//Brains no longer win survive objectives. --NEO
		if(!is_special_character(owner.current)) //This fails borg'd traitors
			return 0
		return 1


datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."



datum/objective/steal
	var/obj/item/steal_target
	var/target_name

	var/global/possible_items[] = list(
		"the captain's antique laser gun" = /obj/item/weapon/gun/energy/laser/captain,
		"a hand teleporter" = /obj/item/weapon/hand_tele,
		"an RCD" = /obj/item/weapon/rcd,
		"a jetpack" = /obj/item/weapon/tank/jetpack,
		"a functional AI" = /obj/item/device/aicard,
//		"a functional personal AI" = /obj/item/device/paicard, // potentially impossible, must think on this
		"a pair of magboots" = /obj/item/clothing/shoes/magboots,
		"the station blueprints" = /obj/item/blueprints,
		"28 moles of plasma (full tank)" = /obj/item/weapon/tank,
		"an unused sample of slime extract" = /obj/item/slime_extract,
		"a piece of corgi meat" = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi,
//		"the medal of captaincy" = /obj/item/clothing/tie/medal/gold/captain, // not on the map = sometimes impossible
		"the hypospray" = /obj/item/weapon/reagent_containers/hypospray,
		"the nuclear authentication disk" = /obj/item/weapon/disk/nuclear,
		"an ablative armor vest" = /obj/item/clothing/suit/armor/laserproof,
		"the reactive teleport armor" = /obj/item/clothing/suit/armor/reactive,
		"a laser pointer" = /obj/item/device/laser_pointer,

// If you want to remove these this is the place to do it
// I don't, though. -Sayu

		"a captain's jumpsuit" = /obj/item/clothing/under/rank/captain,
		"a research director's jumpsuit" = /obj/item/clothing/under/rank/research_director,
		"a chief engineer's jumpsuit" = /obj/item/clothing/under/rank/chief_engineer,
		"a chief medical officer's jumpsuit" = /obj/item/clothing/under/rank/chief_medical_officer,
		"a head of security's jumpsuit" = /obj/item/clothing/under/rank/head_of_security,
		"a head of personnel's jumpsuit" = /obj/item/clothing/under/rank/head_of_personnel,

        "the captain's PDA cartridge" = /obj/item/weapon/cartridge/captain,
        "the head of personnel's PDA cartridge" = /obj/item/weapon/cartridge/hop,
        "the chief engineer's PDA cartridge" = /obj/item/weapon/cartridge/ce,
        "the head of security's PDA cartridge" = /obj/item/weapon/cartridge/hos,
//        "the chief medical officer's PDA cartridge" = /obj/item/weapon/cartridge/cmo,
//        "the research director's PDA cartridge" = /obj/item/weapon/cartridge/rd,

		"the detective's scanner" = /obj/item/device/detective_scanner,
		"a fire axe" = /obj/item/weapon/twohanded/fireaxe,
        "the chain of command" = /obj/item/weapon/melee/chainofcommand,
        "the captain's rubber stamp" = /obj/item/weapon/stamp/captain,
        "the reactive teleport armor" = /obj/item/clothing/suit/armor/reactive,
//        "the captain's gloves" = /obj/item/clothing/gloves/captain,
        "a live facehugger" = /obj/item/clothing/mask/facehugger,
        "the monitor decryption key" = /obj/item/weapon/paper/monitorkey,
        "a 'Freeform' core AI module" = /obj/item/weapon/aiModule/freeformcore,
        "an 'Astleymov' core AI module" = /obj/item/weapon/aiModule/rickrules,
		"a dermal armor patch" = /obj/item/clothing/head/helmet/HoS/dermal,
		"an AI upload construction circuit board" = /obj/item/weapon/circuitboard/aiupload,
		"a cyborg upload construction circuit board" = /obj/item/weapon/circuitboard/borgupload,
		"an AI core construction circuit board" = /obj/item/weapon/circuitboard/aicore,

//		"a syndicate balloon" = /obj/item/toy/syndicateballoon, // fuck you you don't get to buy anything else with telecrystals today
		"four unique blood samples" = /obj/item/weapon/reagent_containers,
		"four unique identification cards" = /obj/item/weapon/card/id,
		"50 units of unstable mutagen" = /obj/item/weapon/reagent_containers,
		"50 units of chloral hydrate" = /obj/item/weapon/reagent_containers,
		"50 units polytrinic acid" = /obj/item/weapon/reagent_containers,
		"50 units of thermite" = /obj/item/weapon/reagent_containers,
		"7 different kinds of alcohol" = /obj/item/weapon/reagent_containers, // can you get some beer while you're there, we seem to be out
	//	"a telecomms hub circuit board" = /obj/item/weapon/circuitboard/telecomms/hub // this might be difficult to steal, if you are not R&D
		"a red telephone" = /obj/item/weapon/phone
	)

	var/global/possible_items_special[] = list(
		"the captain's pinpointer" = /obj/item/weapon/pinpointer,
		"an advanced energy gun" = /obj/item/weapon/gun/energy/gun/nuclear,
		"a diamond drill" = /obj/item/weapon/pickaxe/diamonddrill,
		"a bag of holding" = /obj/item/weapon/storage/backpack/holding,
		"a hyper-capacity cell" = /obj/item/weapon/cell/hyper,
		"10 diamonds" = /obj/item/stack/sheet/mineral/diamond,
		"50 gold bars" = /obj/item/stack/sheet/mineral/gold,
		"25 refined uranium bars" = /obj/item/stack/sheet/mineral/uranium,

	)

	// These lists forbid antagonist types from getting certain steal requests
	// that are either thematically unsuited or impossible (balloon)

	var/global/changeling_restricted[] = list(
		"a syndicate balloon",
		"an 'Astleymov' core AI module", // no sense of humor
		"7 different kinds of alcohol",  // REALLY no sense of humor
		"a piece of corgi meat",
		"the captain's pinpointer", // don't care about nukes
		"the monitor decryption key", // don't care about comms
		"a telecomms hub circuit board", // don't care about comms
		"an AI core construction circuit board" // better uses for your juices
		)

	var/global/traitor_restricted[] = list(
		"a live facehugger", // syndies too creeped out to assign you to steal Lamarr
		"four unique blood samples", // not useful to the syndicate
		"50 units of unstable mutagen"
		)

	var/global/wizard_restricted[] = list(
		"a syndicate balloon",
		"a research director's jumpsuit", // captain and CMO not on this list due to wizard cosplay "Oh, captain~"
		"a chief engineer's jumpsuit",
		"a head of security's jumpsuit",
		"a head of personnel's jumpsuit",
		"the captain's rubber stamp",
		"50 units polytrinic acid",
		"an AI core construction circuit board"
		)



	proc/set_target(item_name)
		if(!item_name)
			steal_target = null
			target_name = "Free Objective"
			explanation_text = "Free Objective"
			return null
		target_name = item_name
		steal_target = possible_items[target_name]
		if (!steal_target )
			steal_target = possible_items_special[target_name]
		explanation_text = "Steal [target_name]."
		return steal_target


	proc/validate(var/typekey)
		for(var/datum/objective/steal/S in owner.objectives)
			if(S == src) continue
			if(S.target_name == typekey)
				return 0
		if(owner)
			switch(owner.special_role)
				if("Changeling")
					if(typekey in changeling_restricted)
						return 0
				if("traitor")
					if(typekey in traitor_restricted)
						return 0
				if("Wizard")
					if(typekey in wizard_restricted)
						return 0
		return 1

	find_target()
		if(!owner)
			return set_target(pick(possible_items))
		var/temp
		var/i = 0
		while(i < 10 && !temp)
			i++
			temp = pick(possible_items)
			if(!validate(temp))
				temp = null
		if(temp)
			return set_target(temp)
		explanation_text = "Free Objective"
		return null


	proc/select_target()
		var/list/possible_items_all = possible_items+possible_items_special+"custom"
		var/new_target = input("Select target:", "Objective target", steal_target) as null|anything in possible_items_all
		if (!new_target) return
		if (new_target == "custom")
			var/obj/item/custom_target = input("Select type:","Type") as null|anything in typesof(/obj/item)
			if (!custom_target) return
			var/tmp_obj = new custom_target
			var/custom_name = tmp_obj:name
			del(tmp_obj)
			custom_name = copytext(sanitize(input("Enter target name:", "Objective target", custom_name) as text|null),1,MAX_MESSAGE_LEN)
			if (!custom_name) return
			target_name = custom_name
			steal_target = custom_target
			explanation_text = "Steal [target_name]."
		else
			set_target(new_target)
		return steal_target

	check_completion()
		if(!steal_target) return 1
		if(!owner.current || !isliving(owner.current))	return 0
		var/list/all_items = owner.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
		switch(target_name)
			if("28 moles of plasma (full tank)","10 diamonds","50 gold bars","25 refined uranium bars")
				var/target_amount = text2num(target_name)//Non-numbers are ignored.
				var/found_amount = 0.0//Always starts as zero.

				for(var/obj/item/I in all_items) //Check for plasma tanks
					if(istype(I, steal_target))
						found_amount += (target_name=="28 moles of plasma (full tank)" ? (I:air_contents:toxins) : (I:amount))
				return found_amount>=target_amount

			if("a functional AI")
				for(var/obj/item/device/aicard/C in all_items) //Check for ai card
					for(var/mob/living/silicon/ai/M in C)
						if(istype(M, /mob/living/silicon/ai) && M.stat != 2) //See if any AI's are alive inside that card.
							return 1

			if("a live facehugger")
				for(var/obj/item/clothing/mask/facehugger/F in all_items)
					if(!(F.stat&DEAD))
						return 1

			if("a functional personal AI")
				for(var/obj/item/device/paicard/P in all_items)
					if(P.pai && P.pai.stat != 2)
						return 1

			if("the station blueprints")
				for(var/obj/item/I in all_items)	//the actual blueprints are good too!
					if(istype(I, /obj/item/blueprints))
						return 1
					if(istype(I, /obj/item/weapon/photo))
						var/obj/item/weapon/photo/P = I
						if(P.blueprints)	//if the blueprints are in frame
							return 1

			if("an unused sample of slime extract")
				for(var/obj/item/slime_extract/E in all_items)
					if(E.Uses > 0)
						return 1

			if("four unique blood samples")
				var/list/dna_samples = list()
				for(var/obj/item/weapon/reagent_containers/R in all_items)
					if(!R.reagents) continue
					for(var/datum/reagent/blood/B in R.reagents.reagent_list)
						dna_samples |= B.data["blood_DNA"] // null will work too, but only once
						if(dna_samples.len >= 4)
							return 1
			if("four unique identification cards")
				var/list/card_names = list()
				var/list/card_jobs = list()
				for(var/obj/item/weapon/card/id/ID in all_items)
					card_names |= ID.registered_name
					card_jobs |= ID.assignment
					if(card_names.len >= 4 && card_jobs.len >= 4)
						return 1
			if("50 units of unstable mutagen")
				var/amount = 0
				for(var/obj/item/weapon/reagent_containers/R in all_items)
					if(!R.reagents) continue
					for(var/datum/reagent/toxin/mutagen/M in R.reagents.reagent_list)
						amount += M.volume
						if(amount >= 50)
							return 1
			if("50 units of chloral hydrate")
				var/amount = 0
				for(var/obj/item/weapon/reagent_containers/R in all_items)
					if(!R.reagents) continue
					for(var/datum/reagent/toxin/chloralhydrate/C in R.reagents.reagent_list)
						amount += C.volume
						if(amount >= 50)
							return 1
			if("50 units polytrinic acid")
				var/amount = 0
				for(var/obj/item/weapon/reagent_containers/R in all_items)
					if(!R.reagents) continue
					for(var/datum/reagent/toxin/acid/polyacid/P in R.reagents.reagent_list)
						amount += P.volume
						if(amount >= 50)
							return 1
			if("50 units of thermite")
				var/amount = 0
				for(var/obj/item/weapon/reagent_containers/R in all_items)
					if(!R.reagents) continue
					for(var/datum/reagent/thermite/T in R.reagents.reagent_list)
						amount += T.volume
						if(amount >= 50)
							return 1
			if("7 different kinds of alcohol")
				var/list/samples = list()
				var/static/list/other_alcohols = list(/datum/reagent/atomicbomb,/datum/reagent/gargle_blaster,/datum/reagent/neurotoxin,/datum/reagent/hippies_delight)
				for(var/obj/item/weapon/reagent_containers/R in all_items)
					if(!R.reagents) continue
					for(var/datum/reagent/ER in R.reagents.reagent_list)
						if(istype(ER,/datum/reagent/ethanol) || (ER.type in other_alcohols))
							samples |= ER.type // all booze are now subtypes of ethanol, this should work
							if(samples.len >= 7)
								return 1

			else
				for(var/obj/I in all_items) //Check for items
					if(istype(I, steal_target))
						return 1
		return 0



datum/objective/download
	proc/gen_amount_goal()
		target_amount = rand(10,20)
		explanation_text = "Download [target_amount] research level\s."
		return target_amount


	check_completion()
		if(!ishuman(owner.current))
			return 0
		if(!owner.current || owner.current.stat == 2)
			return 0
		if(!(istype(owner.current:wear_suit, /obj/item/clothing/suit/space/space_ninja)&&owner.current:wear_suit:s_initialized))
			return 0
		var/current_amount
		var/obj/item/clothing/suit/space/space_ninja/S = owner.current:wear_suit
		if(!S.stored_research.len)
			return 0
		else
			for(var/datum/tech/current_data in S.stored_research)
				if(current_data.level>1)	current_amount+=(current_data.level-1)
		if(current_amount<target_amount)	return 0
		return 1



datum/objective/capture
	proc/gen_amount_goal()
		target_amount = rand(5,10)
		explanation_text = "Accumulate [target_amount] capture point\s. It is better if they remain relatively unharmed."
		return target_amount


	check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
		var/captured_amount = 0
		var/area/centcom/holding/A = locate()
		for(var/mob/living/carbon/human/M in A)//Humans.
			if(M.stat==2)//Dead folks are worth less.
				captured_amount+=0.5
				continue
			captured_amount+=1
		for(var/mob/living/carbon/monkey/M in A)//Monkeys are almost worthless, you failure.
			captured_amount+=0.1
		for(var/mob/living/carbon/alien/larva/M in A)//Larva are important for research.
			if(M.stat==2)
				captured_amount+=0.5
				continue
			captured_amount+=1
		for(var/mob/living/carbon/alien/humanoid/M in A)//Aliens are worth twice as much as humans.
			if(istype(M, /mob/living/carbon/alien/humanoid/queen))//Queens are worth three times as much as humans.
				if(M.stat==2)
					captured_amount+=1.5
				else
					captured_amount+=3
				continue
			if(M.stat==2)
				captured_amount+=1
				continue
			captured_amount+=2
		if(captured_amount<target_amount)
			return 0
		return 1



datum/objective/absorb
	proc/gen_amount_goal(var/lowbound = 4, var/highbound = 6)
		target_amount = rand (lowbound,highbound)
		if (ticker)
			var/n_p = 1 //autowin
			if (ticker.current_state == GAME_STATE_SETTING_UP)
				for(var/mob/new_player/P in player_list)
					if(P.client && P.ready && P.mind!=owner)
						n_p ++
			else if (ticker.current_state == GAME_STATE_PLAYING)
				for(var/mob/living/carbon/human/P in player_list)
					if(P.client && !(P.mind in ticker.mode.changelings) && P.mind!=owner)
						n_p ++
			target_amount = min(target_amount, n_p)

		explanation_text = "Extract [target_amount] compatible genome\s."
		return target_amount

	check_completion()
		if(owner && owner.changeling && owner.changeling.absorbed_dna && (owner.changeling.absorbedcount >= target_amount))
			return 1
		else
			return 0



/* Isn't suited for global objectives
/*---------CULTIST----------*/

		eldergod
			explanation_text = "Summon Nar-Sie via the use of an appropriate rune. It will only work if nine cultists stand on and around it."

			check_completion()
				if(eldergod) //global var, defined in rune4.dm
					return 1
				return 0

		survivecult
			var/num_cult

			explanation_text = "Our knowledge must live on. Make sure at least 5 acolytes escape on the shuttle to spread their work on an another station."

			check_completion()
				if(emergency_shuttle.location<2)
					return 0

				var/cultists_escaped = 0

				var/area/shuttle/escape/centcom/C = /area/shuttle/escape/centcom
				for(var/turf/T in	get_area_turfs(C.type))
					for(var/mob/living/carbon/H in T)
						if(iscultist(H))
							cultists_escaped++

				if(cultists_escaped>=5)
					return 1

				return 0

		sacrifice //stolen from traitor target objective

			proc/find_target() //I don't know how to make it work with the rune otherwise, so I'll do it via a global var, sacrifice_target, defined in rune15.dm
				var/list/possible_targets = call(/datum/game_mode/cult/proc/get_unconvertables)()

				if(possible_targets.len > 0)
					sacrifice_target = pick(possible_targets)

				if(sacrifice_target && sacrifice_target.current)
					explanation_text = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune (Hell join blood) and three acolytes to do so."
				else
					explanation_text = "Free Objective"

				return sacrifice_target

			check_completion() //again, calling on a global list defined in rune15.dm
				if(sacrifice_target.current in sacrificed)
					return 1
				else
					return 0

/*-------ENDOF CULTIST------*/
*/
