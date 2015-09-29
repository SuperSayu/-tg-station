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

	var/casting_window = 40 // grace period.  You have this long after the select window pops up to select someone that has gone out of range, in deciseconds.
	castingmode = CAST_SPELL|CAST_MELEE|CAST_RANGED


	proc/accept(var/mob/M, var/mob/caster)
		if(istype(M,/obj/item/organ/internal/brain) || istype(M,/obj/item/device/soulstone))
			M = locate(/mob/living) in M
		if(!ismob(M)) return 0
		if(!M.client && !pick_clientless)	// 1: No client
			return 0
		if(M == caster)						// 2: yourself
			return pick_self

		var/turf/T = get_turf(M)			// 3: in range

		if(get_dist(T,caster) > range)
			if(pick_eye_holders && M.client && M.client.eye != M) // 3.5: If your eye is in range but you are not (cameras, AI)
				T = get_turf(M.client.eye)
				if(get_dist(caster,T) > range)
					return 0
			else
				return 0

		if(istype(M,/mob/dead))				// 4: Non-living (ghosts and brains)
			return pick_ghost

		if(istype(M,/mob/living/carbon/brain) || istype(M,/mob/living/simple_animal/shade))
			return pick_brain

		if((M.stat & DEAD) && !pick_dead)	// 5: stat checks
			return 0

		if(!(M.stat & DEAD) && !pick_living)
			return 0

		if(istype(M,/mob/living/silicon/ai)) // 6: silicons
			return pick_ai

		if(istype(M,/mob/living/silicon/robot))
			return pick_robot

		if(istype(M,/mob/living/silicon/pai))
			return pick_pai

		if(istype(M,/mob/living/simple_animal)) // 7: animals
			return pick_animal

		if(istype(M,/mob/living/carbon/human)) // 8: carbons
			return pick_human

		if(istype(M,/mob/living/carbon/monkey))
			return pick_monkey

		if(istype(M,/mob/living/carbon/alien))
			return pick_xeno

		if(istype(M,/mob/living/simple_animal/slime))
			return pick_slime

	proc/scan(mob/caster as mob)
		set background=1

		var/list/target = list()

		var/list/master_list
		if(pick_clientless)
			master_list = mob_list
		else
			master_list = player_list

		for(var/mob/M in master_list)
			if(accept(M,caster))
				target |= M

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
			return PROCESS_KILL

		send_byjax(caster,"[name].browser","targets",targets_window())


	proc/describe_range()
		var/list/categories = list("living","dead","ghostly","braindead", "observing")
		var/list/cat_select = list(pick_living,pick_dead,pick_ghost,pick_clientless, pick_eye_holders)
		var/list/target_types = list("disembodied brains","AI","cyborgs","personal AI", "animals", "monkeys", "humans", "aliens", "slimes")
		var/list/selected = list(pick_brain,pick_ai,pick_robot,pick_pai, pick_animal,pick_monkey,pick_human,pick_xeno,pick_slime)
		var/i = 1
		while(i<=cat_select.len)
			if(!cat_select[i])
				cat_select.Cut(i,i+1)
				categories.Cut(i,i+1)
				continue
			i++
		i=1
		while(i<=selected.len)
			if(!selected[i])
				selected.Cut(i,i+1)
				target_types.Cut(i,i+1)
				continue
			i++

		// living, dead, or braindead animals, monkeys, and humans
		return "Targets [english_list(categories, final_comma_text = ",", and_text = " or ")] [english_list(target_types)] within [range] squares."

	prepare(mob/caster as mob)
		SSobj.processing.Add(src)
		caster << browse("<script language='javascript' type='text/javascript'>[js_byjax]</script><center>[src]<br>[desc]<br>[describe_range()]</center><hr><div id='targets'></div>","window=[name]")
		process()

	Topic(href,list/href_list)
		if(..(href,href_list)) return

		if("close" in href_list)
			SSobj.processing.Remove(src)
			usr << browse(null,"window=[name]")
			return
		if("target" in href_list)
			var/atom/target = locate(href_list["target"])
			activate(usr,target)

	attack(mob/victim, mob/caster)
		if(accept(victim,caster))
			activate(caster,victim)
	afterattack(mob/victim, mob/caster)
		if(!istype(victim) || !accept(victim,caster)) return // accept also range checks
		activate(caster,victim)

/obj/effect/knowspell/target/disintegrate
	name = "disintegrate"
	desc = "Reduces the target to a bloody (or oily) mess."

	wand_state = "deathwand"

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
	castingmode = CAST_MELEE

	cast(mob/caster, mob/target)
		if(istype(target))
			if(ishuman(target) || ismonkey(target))
				var/obj/item/organ/internal/brain/B = target.getorgan(/obj/item/organ/internal/brain)
				if(B)
					B.loc = get_turf(target)
					B.transfer_identity(target)
			target.gib()

/obj/effect/knowspell/target/resurrect
	name = "resurrect"
	desc = "Returns the dead to their former self."

	wand_state = "revivewand"
	staff_state = "healing"

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

	castingmode = CAST_SPELL|CAST_MELEE //  too powerful for ranged casting

	cast(mob/caster, mob/living/target) // todo flashy flash flash
		target.has_dna()
		if(target.stat == 2)
			if(istype(target,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = target
				H.set_species(/datum/species/skeleton, icon_update=0)
				H.updateappearance()
			inspire_loyalty(caster, target)

		target.revive()


//No rewards for EI NATing people! And WizardBorg should be a spell of its own*/

	proc/inspire_loyalty(mob/caster, mob/living/target)
		if(!target.mind || !caster.mind)
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
		P.target = caster.mind
		P.owner = target.mind
		P.explanation_text = "[caster] spared your life; make sure they survive."
		target.mind.objectives += P

		var/obj_count = 1
		target << "\blue Your current objectives:"
		for(var/datum/objective/objective in target.mind.objectives)
			target << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++
		caster << "\blue [target.real_name]'s eyes glow momentarily."
		caster.mind.store_memory("[target.real_name] owes you their life.")

/obj/effect/knowspell/target/resurrect/heal
	name = "heal"
	desc = "Rejuvenates the living."

	wand_state = "revivewand"
	staff_state = "healing"

	incantation = "FIR STAID"
	incant_volume = 1
	chargemax = 1200

	pick_self = 1
	pick_living = 1
	pick_dead = 0
	pick_robot = 1
	pick_animal = 1
	pick_clientless = 1

	range = 1
	visible_range = 1

	pick_xeno = 1
	pick_monkey = 1
	pick_human = 1
	pick_slime = 1
	pick_brain = 0
	castingmode = CAST_MELEE|CAST_RANGED

	inspire_loyalty()
		return


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
	castingmode = CAST_SPELL|CAST_MELEE
	var/duration = 1200

	cast(mob/caster, mob/living/carbon/human/target)
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.flags |= NODROP		//curses!
		magichead.flags_inv = null	//so you can still see their face
		magichead.voicechange = 1	//NEEEEIIGHH
		target.visible_message(	"<span class='danger'>[target]'s face  lights up in fire, and after the event a horse's head takes its place!</span>", \
								"<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a horse!</span>")
		target.equip_to_slot(magichead, slot_wear_mask)
		flick("e_flash", target.flash)
		spawn(duration)
			if(magichead)
				magichead.flags &= ~NODROP
				magichead.voicechange = 0
				var/mob/M = magichead.loc
				if(istype(M))
					M << "Your face feels a little better now."

/obj/effect/knowspell/target/flesh_to_stone
	name = "flesh to stone"
	desc = "Turns a target into a statue for a little while.  They can break out, but destroying the statue kills them."

	wand_state = "polywand"

	pick_living = 1
	pick_human = 1
	pick_monkey = 1
	pick_clientless = 1
	pick_self = 0
	range = 1
	visible_range = 1

	chargemax = 600
	incantation = "STAUN EI"
	incant_volume = 2

	cast(var/mob/caster,var/mob/target)
		target.Stun(2)
		new /obj/structure/closet/statue(get_turf(target),target)


/obj/effect/knowspell/target/mindswap
	name = "mindswap"
	desc = "Switch minds with another living creature."

	mindswap_forget_chance = 0
	cloning_forget_chance = 100 // NOOOOOOO wait who am I kidding that means they killed the wizard

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
		var/list/checked_spells = caster.mind.spell_list
		checked_spells -= src //Remove Mind Transfer from the list.

		if(caster.mind.spell_list.len)//If they have any spells left over after mind transfer is taken out. If they don't, we don't need this.
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
		caster.mind.spell_list = checked_spells//Set caster spell list to whatever the new list is.
		//SPELL LOSS END

		//MIND TRANSFER BEGIN
		if(caster.mind.special_verbs.len)//If the caster had any special verbs, remove them from the mob verb list.
			for(var/V in caster.mind.special_verbs)//Since the caster is using an object spell system, this is mostly moot.
				caster.verbs -= V//But a safety nontheless.

		if(target.mind.special_verbs.len)//Now remove all of the target's verbs.
			for(var/V in target.mind.special_verbs)
				target.verbs -= V

		var/mob/dead/observer/ghost = target.ghostize(0)

		caster.mind.transfer_to(target)
		for(var/obj/effect/KS in target.mind.spell_list) // physically move spell object
			KS.loc = target
		if(target.mind.special_verbs.len)//To add all the special verbs for the original caster.
			for(var/V in caster.mind.special_verbs)//Not too important but could come into play.
				caster.verbs += V

		ghost.mind.transfer_to(caster)
		caster.key = ghost.key	//have to transfer the key since the mind was not active
		for(var/obj/effect/KS in caster.mind.spell_list)  // physically move spell object
			KS.loc = caster

		// We're not deleting the spells when spell loss occurs so why the hell not give them to the other guy
		for(var/obj/effect/knowspell/KS in caster.contents)
			caster.mind.spell_list |= KS
		for(var/obj/effect/knowspell/KS in target.contents)
			target.mind.spell_list |= KS

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
	pick_clientless = 1

	wand_state = "polywand"
	staff_state = "animation"

	require_clothing = 1
	var/remove_after = 900
	var/allow_choice = 1 // if 0, a possible mutation is chosen randomly

	var/list/possible_mutations // name = mutation ID
	var/list/incantations		// name = incantation
	var/list/describe_addition	// name = blurb (to recipient)
	var/list/describe_removal	// name = blurb (to recipient)

	// internal variables
	var/mutation = null
	var/add_string = null
	var/remove_string = null

/obj/effect/knowspell/target/mutate/proc/filter_mutations(var/list/possible,var/mob/living/target)
	var/list/selectable = list()

	if(ishuman(target))
		var/mob/living/carbon/human/H = target

		for(var/reference in possible)
			var/mut_no = possible[reference]

			if(H.dna.check_mutation(mut_no))
				continue

			selectable[reference]=mut_no
	return selectable

/obj/effect/knowspell/target/mutate/before_cast(var/mob/caster, var/mob/living/target)
	if(!istype(caster)) return 0

	var/list/selected = filter_mutations(possible_mutations,target)

	if(!selected.len)
		caster << "This spell can do no more to [target==caster?"you":"[target]"]!"
		return 0
	var/answer
	if(allow_choice)
		answer = input(caster, "Select a mutation:","Mutation",null) in selected
	else
		answer = pick(selected)

	if(!isnull(answer) && cast_check(caster))

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

/obj/effect/knowspell/target/mutate/cast(var/mob/caster, var/mob/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.dna.add_mutation(mutation)
		H << "\red [add_string]"
		scatter_lightning(H)
		var/temp = mutation
		var/tempstring = remove_string

		if(remove_after)
			spawn(remove_after)
				if(ishuman(H)) //maybe it got turned into a monkey
					H.dna.remove_mutation(temp)
					H << "\red [tempstring]"
					scatter_lightning(H)

/obj/effect/knowspell/target/mutate/good
	name = "beneficial mutation"
	desc = "Contains a number of selectable, beneficial qualities for you or your allies.  90 second duration."
	chargemax = 450
	pick_self = 1

	staff_state = "healing"

	possible_mutations = list("Hulkitis" = HULK, "Telekinesis" = TK, "Cold Resistance" = COLDRES, "X-ray vision" = XRAY, "Laser Eyes" = LASEREYES)
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
	remove_after = 1200

	possible_mutations = list("Clumsiness" = CLOWNMUT, "Epileptic Siezures" = EPILEPSY, "Coughing fits" = COUGH, "Beguiled Tongue" = TOURETTES, "Blindness" = BLIND, "Muteness" = MUTE, "Deafness" = DEAF,  "Nearsightedness" = BADSIGHT)
	incantations = list("Clumsiness" = "DRO PSI DESI", "Epileptic Siezures" = "NURV USDIS", "Coughing fits" = "BAHD JOHK", "Beguiled Tongue" = "FUCK SHIT", "Blindness" = "HELL UNKELL", "Muteness" = "SI LENDED", "Deafness" = "HEER NO",  "Nearsightedness" = "KLO PSI")
	describe_addition = list("Clumsiness" = "Your fingers suddenly twist uncontrollably!",
							"Epileptic Siezures" = "Your entire nervous system lights up with pain and agony!", "Coughing fits" = "Something's stabbing at your lungs!",
							"Beguiled Tongue" = "Some curse falls over your mind!", "Blindness" = "Darkness falls over you!", "Muteness" = "Your tongue falls unnaturally still.",
							"Deafness" = "The world goes still.",  "Nearsightedness" = "Everything's gotten blurry!")
	describe_removal = list("Clumsiness" = "Your fingers feel better.", "Fatness" = "Your gut shrinks down a bit.", "Epileptic Siezures" = "Your body stops hurting quite so much.",
							"Coughing fits" = "Your chest feels better.", "Beguiled Tongue" = "Your lips stop flapping of their own accord.",
							"Blindness" = "The world doesn't seem quite as dark.", "Muteness" = "Your tongue feels lighter.", "Deafness" = "Your hearing slowly returns.",  "Nearsightedness" = "The blurriness subsides.")

/obj/effect/knowspell/target/gender_swap
	name = "Swap Gender"
	desc = "A routine prank at wizard school."
	pick_self = 1
	pick_living = 1
	pick_dead = 1
	pick_clientless = 1
	pick_human = 1
	pick_animal = 1
	pick_monkey = 1
	chargemax = 400

	cast(var/mob/caster, var/mob/target)
		if(prob(9))
			target.gender = "NEUTER"
		else
			switch(target.gender)
				if("MALE")
					target.gender = "FEMALE"
				if("FEMALE")
					target.gender = "MALE"
				if("NEUTER","PLURAL")
					target.gender = pick("MALE","FEMALE","NEUTER","PLURAL")
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.updateappearance()

/obj/effect/knowspell/target/make_bald
	name = "Embalden"
	desc = "Removes a person's hair and beard all at once."
	before_cast(var/mob/caster, var/mob/target)
	pick_self = 1
	pick_living = 1
	pick_dead = 1
	pick_clientless = 1
	pick_human = 1

	before_cast(var/mob/caster, var/mob/living/carbon/human/target)
		if(!istype(target)) return 0
		if(target.hair_style && target.hair_style != "shaved" && target.get_organ(/obj/item/organ/internal/brain)) // debrained = no hair
			return 1
		if(target.facial_hair_style && target.facial_hair_style != "shaved")
			return 1
		caster << "[target] is already as bald as \he can be!"
		return 0

	cast(var/mob/caster, var/mob/living/carbon/human/target)
		if(!istype(target)) return
		target.hair_style = "shaved"
		target.facial_hair_style = "shaved"
		target.update_hair()

// this is for the wand of pranks
/obj/effect/knowspell/target/prank
	name = "Prank"
	desc = "One of several magical effects will happen.  Gosh!"
	pick_living = 1
	pick_dead = 1
	pick_clientless = 1
	pick_human = 1
	chargemax = 100
	New()
		new/obj/effect/knowspell/target/make_bald(src)
		new/obj/effect/knowspell/target/gender_swap(src)
		new/obj/effect/knowspell/target/mutate/bad{allow_choice = 0}(src)
		new/obj/effect/knowspell/summon/target/banana(src)
		new/obj/effect/knowspell/target/horsemask{duration=200;incantation="PUCK BTHNK"}(src) // minor version
		..()

	activate(var/mob/caster, var/mob/target)
		var/list/candidates = contents.Copy()
		while(candidates.len)
			var/obj/effect/knowspell/selected = pick_n_take(candidates)
			if(selected.activate(caster,target))
				after_cast(caster) // recharge here too
				return 1
