/obj/effect/knowspell/target
	var/range = 5
	var/visible_range = 1

	var/pick_self = 0

	var/pick_living = 0
	var/pick_dead = 0
	var/pick_clientless = 0

	var/pick_brain = 0

	var/pick_ghost = 0
	var/pick_ai = 0
	var/pick_robot = 0
	var/pick_pai = 0
	var/pick_animal = 0 // simple_animals
	var/pick_human = 0
	var/pick_monkey = 0
	var/pick_xeno = 0
	var/pick_slime = 0

	var/pick_eye_holders = 0 // checks cameras and AI eyes

	var/casting_window = 50 // grace period.  You have this long after the select window pops up to select someone that has gone out of range, in deciseconds.


	proc/scan(mob/caster as mob)
		set background=1

		var/list/target = list()

		var/turf/T0 = get_turf(caster.loc)

		var/list/master_list
		if(pick_clientless)
			master_list = mob_list
		else
			master_list = player_list

		for(var/mob/M in master_list)

			if(!M.client && !pick_clientless)	// 1: No client
				continue

			if(M == caster)						// 2: yourself
				if(pick_self)
					target += M
				continue

			var/turf/T = get_turf(M)			// 3: in range

			if(get_dist(T,T0) > range)
				if(pick_eye_holders && M.client && M.client.eye != M) // 3.5: If your eye is in range but you are not (cameras, AI)
					T = get_turf(M.client.eye)
					if(get_dist(T0,T) > range)
						continue
				else
					continue

			if(istype(M,/mob/dead))				// 4: Non-living (ghosts and brains)
				if(pick_ghost)
					target += M
				continue
			if(istype(M,/mob/living/carbon/brain))
				if(pick_brain)
					target += M
				continue

			if((M.stat & DEAD) && !pick_dead)	// 5: stat checks
				continue

			if(!(M.stat & DEAD) && !pick_living)
				continue

			if(istype(M,/mob/living/silicon/ai)) // 6: silicons
				if(pick_ai)
					target += M
				continue

			if(istype(M,/mob/living/silicon/robot))
				if(pick_robot)
					target += M
				continue

			if(istype(M,/mob/living/silicon/pai))
				if(pick_pai)
					target += M
				continue

			if(istype(M,/mob/living/simple_animal)) // 7: animals
				if(pick_animal)
					target += M
				continue

			if(istype(M,/mob/living/carbon/human)) // 8: carbons
				if(pick_human)
					target += M
				continue

			if(istype(M,/mob/living/carbon/monkey))
				if(pick_monkey)
					target += M
				continue

			if(istype(M,/mob/living/carbon/alien))
				if(pick_xeno)
					target += M
				continue

			if(istype(M,/mob/living/carbon/slime))
				if(pick_slime)
					target += M
				continue

		return target

	proc/targets_window()
		var/list/targets = scan(loc)
		var/dat = ""
		if(!targets.len)
			dat = "<center>No Targets</center>"
		else
			for(var/atom/A in targets)
				dat += "<a href='?src=\ref[src];target=\ref[A]'>[A]</a><br>"
		return dat

	process()
		var/mob/caster = loc
		while(caster && !istype(caster)) // find the first mob
			caster = caster.loc
		if(!caster)
			spawn(1)
				del src
			return PROCESS_KILL

		send_byjax(caster,"[name].browser","targets",targets_window())

	prepare(mob/caster as mob)
		processing_objects |= src
		caster << browse("<script language='javascript' type='text/javascript'>[js_byjax]</script><center>[src]<br>[desc]</center><hr><div id='targets'></div>","window=[name]")
		process()

	Topic(href,list/href_list)
		if(..(href,href_list)) return

		if("close" in href_list)
			processing_objects.Remove(src)
			usr << browse(null,"window=[name]")
			return
		if("target" in href_list)
			var/atom/target = locate(href_list["target"])
			activate(usr,target)

/obj/effect/knowspell/target/disintegrate
	name = "disintegrate"
	desc = "Reduces the target to a bloody (or oily) mess."

	incantation = "EI NATH"
	incant_volume = 2
	chargemax = 600

	pick_living = 1
	pick_dead = 1
	pick_robot = 1
	pick_animal = 1
	pick_clientless = 1

	range = 1
	visible_range = 1

	pick_xeno = 1
	pick_monkey = 1
	pick_human = 1

	cast(mob/caster, mob/target)
		if(istype(target))
			if(ishuman(target) || ismonkey(target))
				var/obj/item/organ/brain/B = target.getorgan(/obj/item/organ/brain)
				if(B)
					B.loc = get_turf(target)
					B.transfer_identity(target)
			target.gib()

/obj/effect/knowspell/target/resurrect
	name = "resurrect"
	desc = "Returns the dead to their former self."

	incantation = "H TANI E"
	incant_volume = 1
	chargemax = 600

	pick_dead = 1
	pick_robot = 1
	pick_animal = 1
	pick_clientless = 1

	range = 1
	visible_range = 1

	pick_xeno = 1
	pick_monkey = 1
	pick_human = 1
	pick_slime = 1
	pick_brain = 1

	var/loyalty_probability = 25

	cast(mob/caster, mob/living/target) // todo flashy flash flash
		check_dna_integrity(target)

		if(istype(target,/mob/living/carbon/brain)) // reviving a brain means something special
			if(istype(target.loc, /obj/item/device/mmi))
				if(jobban_isbanned(target, "Cyborg"))
					caster << "\red The great will of the macrocosm forbids it."
					return
				var/mob/living/silicon/robot/R = new(get_turf(target))
				R.set_zeroth_law("Wizards should be protected.")
				R.mmi = target.loc
				R.mmi.loc = R

				R.updatename("Default")
				if(target.mind)
					target.mind.transfer_to(R)
					if(R.mind.special_role)
						R.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")

				R.job = "Cyborg"
				feedback_inc("cyborg_birth",1)

			else if(istype(target.loc,/obj/item/organ/brain))
				var/mob/living/carbon/brain/B = target
				var/obj/item/organ/brain/ob = B.loc
				var/mob/living/carbon/C

				if(deconstruct_block(getblock(B.dna.struc_enzymes, RACEBLOCK), 2) == 2) // on: monkey
					C = new /mob/living/carbon/monkey(get_turf(loc))
				else
					C = new /mob/living/carbon/human(get_turf(loc))
				C.dna = B.dna
				check_dna_integrity(C)
				if(ishuman(C))
					C.dna.mutantrace = "skeleton"

				updateappearance(C)
				inspire_loyalty(caster, C)

				for(var/obj/item/organ/brain/Br in C.internal_organs)
					del Br
				ob.loc = C
				C.internal_organs += ob

				if(target.mind)
					target.mind.transfer_to(C)



		else // not brain
			target.revive()
			if(prob(loyalty_probability))
				inspire_loyalty(caster, target)

	proc/inspire_loyalty(mob/caster, mob/living/target)
		if(!target.mind)
			return

		for(var/obj/item/weapon/implant/loyalty/LI in target.contents)
			return // loyalty implanted people are not impressed by wizardry

		var/turf/T = get_turf(target)
		if(!T || T.flags&NOJAUNT) // holy ground
			return

		for(var/datum/objective/P in target.mind.objectives)
			if(P.target == caster) // could be kill, debrain, protect, etc
				return

		var/datum/objective/protect/P = new
		P.target = caster
		P.owner = target
		P.explanation_text = "[caster] spared your life; make sure they survive."
		target.mind.objectives += P

		var/obj_count = 1
		target << "\blue Your current objectives:"
		for(var/datum/objective/objective in target.mind.objectives)
			target << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++
		caster << "\blue [target.real_name]'s eyes glow momentarily."
		caster.mind.store_memory("[target.real_name] owes you their life.")

/obj/effect/knowspell/target/horsemask
	name = "curse of the horseman"
	desc = "Curses men with the face of a horse."

	pick_living = 1
	pick_dead = 1
	pick_human = 1
	pick_clientless = 1

	range = 5
	visible_range = 1

	chargemax = 250
	incantation = "KN'A FTAGHU, PUCK 'BTHNK!"
	incant_volume = 2

	cast(mob/caster, mob/living/carbon/human/target)
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.canremove = 0		//curses!
		magichead.flags_inv = null	//so you can still see their face
		magichead.voicechange = 1	//NEEEEIIGHH
		target.visible_message(	"<span class='danger'>[target]'s face  lights up in fire, and after the event a horse's head takes its place!</span>", \
								"<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a horse!</span>")
		target.equip_to_slot(magichead, slot_wear_mask)
		flick("e_flash", target.flash)

/obj/effect/knowspell/target/mindswap
	name = "mindswap"
	desc = "Switch minds with another living creature."

	pick_living = 1
	pick_human = 1
	pick_monkey = 1
	pick_xeno = 1
	pick_slime = 1
	pick_clientless = 0 // defaults to zero anyway, this is to make it clear to readers
	pick_self = 0

	range = 5
	visible_range = 1

	incantation = "GINRYU CAPAN"
	incant_volume = 1
	chargemax = 120
	require_clothing = 0

	var/base_spell_loss_chance = 20 //base probability of the wizard losing a spell in the process
	var/spell_loss_chance_modifier = 7 //amount of probability of losing a spell added per spell (mind_transfer included)
	var/spell_loss_amount = 1 //the maximum amount of spells possible to lose during a single transfer
	var/msg_wait = 500 //how long in deciseconds it waits before telling that body doesn't feel right or mind swap robbed of a spell
	var/paralysis_amount_caster = 20 //how much the caster is paralysed for after the spell
	var/paralysis_amount_target = 20 //how much the victim is paralysed for after the spell

	// Note this code is stolen directly from oldwizard code, which is so far the only place I've done so.
	// Looking at the below I am sure you sympathise.  -Sayu
	cast(mob/caster, mob/living/carbon/target)
		if(!(target in oview(range)))//If they are not in overview after selection. Do note that !() is necessary for in to work because ! takes precedence over it.
			caster << "They are too far away!"
			return

		if(!target.key || !target.mind)
			caster << "They appear to be catatonic. Not even magic can affect their vacant mind."
			return

		if(target.mind.special_role in list("Wizard","Changeling","Cultist"))
			caster << "Their mind is resisting your spell."
			return

		//SPELL LOSS BEGIN
		//NOTE: The caster must ALWAYS keep mind transfer, even when other spells are lost.
		var/list/checked_spells = caster.spell_list
		checked_spells -= src //Remove Mind Transfer from the list.

		if(caster.spell_list.len)//If they have any spells left over after mind transfer is taken out. If they don't, we don't need this.
			for(var/i=spell_loss_amount,(i>0&&checked_spells.len),i--)//While spell loss amount is greater than zero and checked_spells has spells in it, run this proc.
				for(var/j=checked_spells.len,(j>0&&checked_spells.len),j--)//While the spell list to check is greater than zero and has spells in it, run this proc.
					if(prob(base_spell_loss_chance))
						checked_spells -= pick(checked_spells)//Pick a random spell to remove.
						spawn(msg_wait)
							target << "The mind transfer has robbed you of a spell."
						break//Spell lost. Break loop, going back to the previous for() statement.
					else//Or keep checking, adding spell chance modifier to increase chance of losing a spell.
						base_spell_loss_chance += spell_loss_chance_modifier

		checked_spells += src//Add back Mind Transfer.
		caster.spell_list = checked_spells//Set caster spell list to whatever the new list is.
		//SPELL LOSS END

		//MIND TRANSFER BEGIN
		if(caster.mind.special_verbs.len)//If the caster had any special verbs, remove them from the mob verb list.
			for(var/V in caster.mind.special_verbs)//Since the caster is using an object spell system, this is mostly moot.
				caster.verbs -= V//But a safety nontheless.

		if(target.mind.special_verbs.len)//Now remove all of the target's verbs.
			for(var/V in target.mind.special_verbs)
				target.verbs -= V

		var/mob/dead/observer/ghost = target.ghostize(0)
		ghost.spell_list = target.spell_list//If they have spells, transfer them. Now we basically have a backup mob.

		caster.mind.transfer_to(target)
		target.spell_list = caster.spell_list//Now they are inside the target's body.
		for(var/obj/effect/KS in target.spell_list) // physically move spell object
			KS.loc = target

		if(target.mind.special_verbs.len)//To add all the special verbs for the original caster.
			for(var/V in caster.mind.special_verbs)//Not too important but could come into play.
				caster.verbs += V

		ghost.mind.transfer_to(caster)
		caster.key = ghost.key	//have to transfer the key since the mind was not active
		caster.spell_list = ghost.spell_list
		for(var/obj/effect/KS in caster.spell_list)  // physically move spell object
			KS.loc = caster

		// We're not deleting the spells when spell loss occurs so why the hell not give them to the other guy
		for(var/obj/effect/knowspell/KS in caster.contents)
			caster.spell_list |= KS
		for(var/obj/effect/knowspell/KS in target.contents)
			target.spell_list |= KS

		if(caster.mind.special_verbs.len)//If they had any special verbs, we add them here.
			for(var/V in caster.mind.special_verbs)
				caster.verbs += V
		//MIND TRANSFER END

		//Here we paralyze both mobs and knock them out for a time.
		caster.Paralyse(paralysis_amount_caster)
		target.Paralyse(paralysis_amount_target)

		//After a certain amount of time the target gets a message about being in a different body.
		spawn(msg_wait)
			caster << "\red You feel woozy and lightheaded. <b>Your body doesn't seem like your own.</b>"

/obj/effect/knowspell/target/mutate
	pick_human = 1
	pick_living = 1
	pick_dead = 1

	require_clothing = 1
	var/remove_after = 900
	var/list/possible_mutations // name = mutation ID
	var/list/incantations		// name = incantation
	var/list/describe_addition	// name = blurb (to recipient)
	var/list/describe_removal	// name = blurb (to recipient)

	// internal variables
	var/mutation = null
	var/add_string = null
	var/remove_string = null

	proc/filter_mutations(var/list/possible,var/mob/living/target)
		var/list/selectable = list()
		for(var/reference in possible)
			var/mut_no = possible[reference]
			if(mut_no in target.mutations)
				continue
			selectable[reference] = mut_no
		return selectable

	before_cast(var/mob/caster, var/mob/living/target)
		if(!istype(caster)) return 0

		var/list/selected = filter_mutations(possible_mutations,target)

		if(!selected.len)
			caster << "This spell can do no more to [target==caster?"you":"[target]"]!"
			return 0

		var/answer = input(caster, "Select a mutation:","Mutation",null) in selected

		if(!isnull(answer))

			mutation = possible_mutations[answer]
			add_string = describe_addition[answer]
			remove_string = describe_removal[answer]
			incantation = incantations[answer]

			if(caster == target)
				incant_volume = 1 // whisper
			else
				incant_volume = 2 // shout

			incant(caster, target)
			return 1

		return 0

	cast(var/mob/caster, var/mob/target)

		target.mutations += mutation
		target.update_mutations()
		target << "\red [add_string]"
		scatter_lightning(target)
		var/temp = mutation
		var/tempstring = remove_string

		if(remove_after)
			spawn(remove_after)
				if(target)
					target.mutations -= temp
					target.update_mutations()
					target << "\red [tempstring]"
					scatter_lightning(target)

/obj/effect/knowspell/target/mutate/good
	name = "beneficial mutation"
	desc = "Contains a number of selectable, beneficial qualities for you or your allies.  90 second duration."
	chargemax = 450
	pick_self = 1

	possible_mutations = list("Hulkitis" = HULK, "Telekinesis" = TK, "Cold Resistance" = COLD_RESISTANCE, "X-ray vision" = XRAY, "Laser Eyes" = LASER)
	incantations = list("Hulkitis" = "BIRUZ BANNAR", "Telekinesis" = "JIN GREI", "X-ray vision" = "ZU PERMA NAI", "Cold Resistance" = "JONIST ORM",
						"Laser Eyes" = "PSI CLOPHS")
	describe_addition = list("Hulkitis" = "Your muscles bulge and an indescribable rage burns in your heart!",
										"Telekinesis" = "Your mental acuity jumps through the roof, and your thoughts and sight become one!",
										"Cold Resistance" = "A warmth seeps into your gut, strong enough to hold back the cold of space!",
										"X-ray vision" = "The patterns behind the walls reveal themselves!",
										"Laser Eyes" = "Your eyesight seems sharper--sharp enough to cut steel!")
	describe_removal = list("Hulkitis" = "The burning rage subsides.",
											"Telekinesis" = "Your thoughts retreat back to your fingertips.",
											"Cold Resistance" = "The warmth in your gut subsides, and you feel a chill.",
											"X-ray vision" = "The world feels unpleasantly opaque once more.",
											"Laser Eyes" = "Your eyes feel uncomfortably powerless.")
/obj/effect/knowspell/target/mutate/bad
	name = "harmful mutation"
	desc = "Contains a number of unpleasant genetic deformities."

	pick_self = 0
	pick_clientless = 1
	chargemax = 300
	remove_after = 3000

	possible_mutations = list("Clumsiness" = CLUMSY, "Epileptic Siezures" = EPILEPSY, "Coughing fits" = COUGHING, "Beguiled Tongue" = TOURETTES, "Blindness" = BLIND, "Muteness" = MUTE, "Deafness" = DEAF,  "Nearsightedness" = NEARSIGHTED)
	incantations = list("Clumsiness" = "DRO PSI DESI", "Epileptic Siezures" = "NURV USDIS", "Coughing fits" = "BAHD JOHK", "Beguiled Tongue" = "FUCK SHIT", "Blindness" = "HELL UNKELL", "Muteness" = "SI LENDED", "Deafness" = "HEER NO",  "Nearsightedness" = "KLO PSI")
	describe_addition = list("Clumsiness" = "Your fingers suddenly twist uncontrollably!",
							"Epileptic Siezures" = "Your entire nervous system lights up with pain and agony!", "Coughing fits" = "Something's stabbing at your lungs!",
							"Beguiled Tongue" = "Some curse falls over your mind!", "Blindness" = "Darkness falls over you!", "Muteness" = "Your tongue falls unnaturally still.",
							"Deafness" = "The world goes still.",  "Nearsightedness" = "Everything's gotten blurry!")
	describe_removal = list("Clumsiness" = "Your fingers feel better.", "Fatness" = "Your gut shrinks down a bit.", "Epileptic Siezures" = "Your body stops hurting quite so much.",
							"Coughing fits" = "Your chest feels better.", "Beguiled Tongue" = "Your lips stop flapping of their own accord.",
							"Blindness" = "The world doesn't seem quite as dark.", "Muteness" = "Your tongue feels lighter.", "Deafness" = "Your hearing slowly returns.",  "Nearsightedness" = "The blurriness subsides.")

	filter_mutations(var/list/possible,var/mob/living/target)
		var/list/selectable = list()
		for(var/reference in possible)
			var/mut_no = possible[reference]
			switch(mut_no)
				if(CLUMSY)
					if(mut_no in target.mutations)
						continue
				if(EPILEPSY, NEARSIGHTED, COUGHING,TOURETTES,NERVOUS)
					if(target.disabilities&mut_no)
						continue
				if(BLIND,DEAF)
					if(target.sdisabilities&mut_no)
						continue
			selectable[reference]=mut_no
		return selectable

	cast(var/mob/caster, var/mob/target)
		switch(mutation)
			if(CLUMSY)
				target.mutations += mutation
				target.update_mutations()
			if(EPILEPSY, NEARSIGHTED, COUGHING,TOURETTES,NERVOUS)
				if(target.disabilities&mutation) // bitfield, cannot double act and then remove cleanly
					return
				target.disabilities |= mutation
			if(BLIND)
				if(target.sdisabilities&mutation)
					return
				target.sdisabilities |= mutation
			if(DEAF)
				if(target.sdisabilities&mutation)
					return
				target.sdisabilities |= mutation
				target.ear_deaf = 1
			else
				world.log << "strange bad mutation: [mutation]"
				return
		target << "\red [add_string]"
		scatter_lightning(target)
		var/temp = mutation
		var/tempstring = remove_string

		if(remove_after)
			spawn(remove_after)
				if(target)
					switch(temp)
						if(CLUMSY)
							target.mutations -= temp
							target.update_mutations()
						if(EPILEPSY, NEARSIGHTED, COUGHING,TOURETTES,NERVOUS)
							target.disabilities &= ~temp
						if(BLIND)
							target.sdisabilities &= ~temp
						if(DEAF)
							target.sdisabilities &= ~temp
							target.ear_deaf = 0

					target.update_mutations()
					target << "\red [tempstring]"
					scatter_lightning(target)