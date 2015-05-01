/obj/item/weapon/reagent_containers/glass
	name = "glass"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 25, 30, 50)
	volume = 50
	flags = OPENCONTAINER

	can_be_placed_into = list(
		/obj/machinery/chem_master/,
		/obj/machinery/chem_dispenser/,
		/obj/machinery/chem_heater/,
		/obj/machinery/reagentgrinder,
		/obj/machinery/biogenerator,
		/obj/structure/table,
		/obj/structure/rack,
		/obj/structure/closet,
		/obj/structure/sink,
		/obj/item/weapon/storage,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/item/weapon/grenade/chem_grenade,
		/obj/machinery/bot/medbot,
		/obj/machinery/computer/pandemic,
		/obj/structure/safe,
		/obj/machinery/disposal,
		/obj/machinery/hydroponics,
		/obj/machinery/biogenerator,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/retaliate/goat
	)
	var/reestimate = 1
	var/identify_probability = 50
	var/list/estimate = list()

// Chemical estimation by SuperSayu
// Why is everyone on this station able to identify every damn chemical by eye?
// Use the damn PDA carts or chemmasters.

/obj/item/weapon/reagent_containers/glass/on_reagent_change()
	..()
	reestimate = 1

/obj/item/weapon/reagent_containers/glass/verb/stir()
	set name = "stir container"
	set src in usr.contents
	if(reagents && reagents.reagent_list.len)
		usr.visible_message("[usr] swishes the contents of the [src] around for a moment.","\blue You swirl the [src] and wait for the contents to settle.")
		reestimate = 1

/obj/item/weapon/reagent_containers/glass/proc/buildEstimate()
	if(!reestimate) return
	estimate = list()
	reestimate = 0

	if(!reagents || !reagents.reagent_list.len)
		estimate += "Nothing."
		return

	var/volSolid = 0
	var/volLiquid = 0
	var/volGas = 0
	var/revealSolids = 1
	var/revealLiquids = 1
	var/revealGasses = 1
	var/list/solids = list()
	var/list/liquids = list()
	var/list/gasses = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		switch(R.reagent_state)
			if(SOLID)
				volSolid += R.volume
				solids += R
				if(!prob(identify_probability)) // it becomes harder to identify a compound
					revealSolids = 0			// when there are several of the same state of matter
			if(LIQUID)							// eg picking out one solid in four solids,
				volLiquid += R.volume			// compared to one solid in one gas
				liquids+= R
				if(!prob(identify_probability))
					revealLiquids = 0
			if(GAS)
				volGas += R.volume
				gasses += R
				if(!prob(identify_probability))
					revealGasses = 0

	var/approxchems = solids.len + liquids.len + gasses.len

	var/approxvolume = round(reagents.total_volume / 5) * 5
	volSolid = round(volSolid / 5) * 5
	volLiquid = round(volLiquid / 5) * 5
	volGas = round(volGas / 5) * 5
	if((volSolid + volLiquid + volGas) == 0)
		estimate +="A tiny amount of material."
		return

	if(!solids.len) revealSolids = 0
	if(!liquids.len) revealLiquids = 0
	if(!gasses.len) revealGasses = 0

	var/list/matterStates = list("a solid", "a liquid", "a gas")

	//Only one chemical to report
	if(approxchems == 1)
		// plus here is used to combine lists / boolean expressions in a way that doesn't require advanced logic
		var/datum/reagent/R = pick(solids + liquids + gasses)
		var/reveal = revealSolids + revealLiquids + revealGasses
		if(reveal)
			estimate += "[approxvolume] units of [R.name], [matterStates[R.reagent_state]]." // Chemical X, a gas
		else
			estimate += "[approxvolume] units of [matterStates[R.reagent_state]]."
		return

	//Multiple chemicals in one beaker / bottle
	estimate += "[approxvolume] units of [approxchems] chemical\s"
	if(volSolid > 0)
		//Only one of this state of matter
		if(solids.len == 1)
			var/datum/reagent/R = solids[1]
			if(!revealSolids)
				estimate += "[volSolid] units of a solid."
			else
				estimate += "[volSolid] units of [R.name], a solid."
		else
			if(!revealSolids)
				estimate += "[solids.len] types of solids, totaling [volSolid] units."
			else
				for(var/datum/reagent/R in solids)
					estimate += "[round(R.volume)] units of [R.name], a solid."

	if(volLiquid > 0)
		if(liquids.len == 1)
			var/datum/reagent/R = liquids[1]
			if(!revealLiquids)
				estimate += "[volLiquid] units of a liquid."
			else
				estimate += "[volLiquid] units of [R.name], a liquid."
		else
			if(!revealLiquids)
				estimate += "[liquids.len] types of liquids, totaling [volLiquid] units."
			else
				for(var/datum/reagent/R in liquids)
					estimate += "[round(R.volume)] units of [R.name], a liquid."
	if(volGas > 0)
		if(gasses.len == 1)
			var/datum/reagent/R = gasses[1]
			if(!revealGasses)
				estimate += "[volGas] units of a gas."
			else
				estimate += "[volGas] units of [R.name], a gas."
		else
			if(!revealGasses)
				estimate += "[gasses.len] types of gasses, totaling [volGas] units."
			else
				for(var/datum/reagent/R in gasses)
					estimate += "[round(R.volume)]  units of [R.name], a gas."

/*
/obj/item/weapon/reagent_containers/glass/examine(mob/user)
	..()
	var/list/matterStates = list("a solid", "a liquid", "a gas")

	//Robots: Awesome (also ghosts)
	if(istype(user,/mob/living/silicon/robot) || istype(user,/mob/dead/observer))
		user << "\blue It contains:"
		if(reagents && reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				user << "\blue [R.volume] units of [R.name], [matterStates[R.reagent_state]]."
		else
			user << "\blue Nothing."

	//Humans: Fallible eyes
	else if(istype(user,/mob/living/carbon/human) && ((user in view(1)) || user==src.loc))
		if(reestimate)
			buildEstimate()

		var/mob/living/carbon/human/H = user
		var/guessword = pick("estimate","think","believe","guess","guesstimate")

		if(H.confused > 5 || H.hallucination || prob(1)) // why am I doing this
			var/nonsense = pick("evil", "ponies", "justice", "God", "bananas", "spiders", "owls", "Pun-Pun", "the finest wine imaginable", "love", "a singularity", "farts","time","space","bananium ore")
			user << "\blue You [guessword] it contains [rand(-5,reagents.maximum_volume * 2)] units of [nonsense]."
			return

		if(identify_probability >= 50 && H.glasses && (istype(H.glasses,/obj/item/clothing/glasses/science) || istype(H.glasses,/obj/item/clothing/glasses/hud/health)))
			user << "\blue It contains:"
			if(reagents && reagents.reagent_list.len)
				for(var/datum/reagent/R in reagents.reagent_list)
					user << "\blue [R.volume] units of [R.name], [matterStates[R.reagent_state]]."
			else
				user << "\blue Nothing."
		else
			user << "\blue You [guessword] it contains:"
			for(var/str in estimate)
				user << "\blue [str]"

	//Other creatures, estimates from far away, etc
	else
		if(!reagents || reagents.total_volume==0)
			user << "\blue \The [src] is empty!"
		else if (reagents.total_volume<=src.volume/4)
			user << "\blue \The [src] is almost empty!"
		else if (reagents.total_volume<=src.volume*0.66)
			user << "\blue \The [src] is half full!"
		else if (reagents.total_volume<=src.volume*0.90)
			user << "\blue \The [src] is almost full!"
		else
			user << "\blue \The [src] is full!"
*/

/obj/item/weapon/reagent_containers/glass/afterattack(obj/target, mob/user, proximity)
	if((!proximity) || !check_allowed_items(target)) return

	if(istype(target,/mob/living/simple_animal/corgi/puppy/smart) && user.a_intent == "help")
		return //sgt. pepper can do a sniff test on reagent containers

	if(ismob(target) && target.reagents && reagents.total_volume)
		var/mob/M = target
		var/R
		target.visible_message("<span class='danger'>[user] has splashed [target] with something!</span>", \
						"<span class='userdanger'>[user] has splashed [target] with something!</span>")
		if(reagents)
			for(var/datum/reagent/A in reagents.reagent_list)
				R += A.id + " ("
				R += num2text(A.volume) + "),"
		add_logs(user, M, "splashed", object="[R]")
		reagents.reaction(target, TOUCH)
		reagents.clear_reagents()
		return

	else if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(target.reagents && !target.reagents.total_volume)
			user << "<span class='notice'>[target] is empty and can't be refilled.</span>"
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			user << "<span class='notice'>[src] is full.</span>"
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		user << "<span class='notice'>You fill [src] with [trans] unit\s of the contents of [target].</span>"

	else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			user << "<span class='notice'>[src] is empty.</span>"
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			user << "<span class='notice'>[target] is full.</span>"
			return


		if(istype(target, /obj/item/weapon/reagent_containers))
			var/obj/item/weapon/reagent_containers/RC = target
			for(var/bad_reg in RC.banned_reagents)
				if(reagents.has_reagent(bad_reg, 1)) //Message is a bit "Game-y" but I can't think up a better one.
					user << "<span class='warning'>A chemical in [src] is far too dangerous to transfer to [RC]!</span>"
					return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		user << "<span class='notice'>You transfer [trans] unit\s of the solution to [target].</span>"

	//Safety for dumping stuff into a ninja suit. It handles everything through attackby() and this is unnecessary.	//gee thanks noize
	else if(istype(target, /obj/item/clothing/suit/space/space_ninja))
		return

	else if(reagents.total_volume)
		user << "<span class='notice'>You splash the solution onto [target].</span>"
		reagents.reaction(target, TOUCH)
		reagents.clear_reagents()

/obj/item/weapon/reagent_containers/glass/attackby(var/obj/item/I, mob/user as mob, params)
	if(istype(I, /obj/item/clothing/mask/cigarette)) //ciggies are weird
		return
	var/hotness = is_hot(I)
	if(hotness)
		var/added_heat = (hotness / 100) //ishot returns a temperature
		if(reagents)
			if(reagents.chem_temp < hotness) //can't be heated to be hotter than the source
				reagents.chem_temp += added_heat
				user << "<span class='notice'>You heat [src] with [I].</span>"
				reagents.handle_reactions()
			else
				user << "<span class='warning'>[src] is already hotter than [I].</span>"
	..()


/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. It can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	m_amt = 0
	g_amt = 500
	identify_probability = 90

/obj/item/weapon/reagent_containers/glass/beaker/New()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "[icon_state]-10"
			if(10 to 24) 	filling.icon_state = "[icon_state]10"
			if(25 to 49)	filling.icon_state = "[icon_state]25"
			if(50 to 74)	filling.icon_state = "[icon_state]50"
			if(75 to 79)	filling.icon_state = "[icon_state]75"
			if(80 to 90)	filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)	filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	g_amt = 2500
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	icon_state = "beakernoreact"
	g_amt = 500
	volume = 50
	amount_per_transfer_from_this = 10
	flags = OPENCONTAINER | NOREACT

/obj/item/weapon/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	icon_state = "beakerbluespace"
	g_amt = 5000
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100,300)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone
	list_reagents = list("cryoxadone" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/sulphuric
	list_reagents = list("sacid" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/slime
	list_reagents = list("slimejelly" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/large/styptic
	name = "styptic reserve tank"
	list_reagents = list("styptic_powder" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/large/silver_sulfadiazine
	name = "silver sulfadiazine reserve tank"
	list_reagents = list("silver_sulfadiazine" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/large/charcoal
	name = "antitoxin reserve tank"
	list_reagents = list("charcoal" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/large/epinephrine
	name = "epinephrine reserve tank"
	list_reagents = list("epinephrine" = 50)

/obj/item/weapon/reagent_containers/glass/bucket
	name = "bucket"
	desc = "It's a bucket."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	m_amt = 200
	g_amt = 0
	w_class = 3.0
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,50,70)
	volume = 70
	flags = OPENCONTAINER
	identify_probability = 30

/obj/item/weapon/reagent_containers/glass/bucket/attackby(var/obj/D, mob/user as mob, params)
	if(isprox(D))
		user << "<span class='notice'>You add [D] to [src].</span>"
		qdel(D)
		user.put_in_hands(new /obj/item/weapon/bucket_sensor)
		user.unEquip(src)
		qdel(src)
	else
		..()
