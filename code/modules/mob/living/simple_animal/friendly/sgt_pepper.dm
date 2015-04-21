/mob/living/simple_animal/corgi/puppy/smart/sgt_pepper
	name = "Sgt. Pepper"
	real_name = "Sgt. Pepper"
	desc = "The ruffest, tuffest, most vigilant puppy on the station."
	icon_state = "sgt_pepper"
	icon_living = "sgt_pepper"
	icon_dead = "sgt_pepper_dead"

/mob/living/simple_animal/corgi/puppy/smart
	gender = "female" // the smarter of the two genders
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"

	// If you give her an item to sniff, she will respond with one of these
	var/list/smell_approved_emotes = list("seems okay with it.", "looks hungry.", "seems to like it.", "'s interested!")
	var/list/smell_neutral_emotes = list("seems bemused.","seems okay with it.", "doesn't seem to care.")
	var/list/smell_offensive_emotes = list("seems bemused.","seems agitated!", "doesn't seem to like it.", "looks bothered!")

	// You have caught her attention
	var/list/friendly_emotes = list("follows _T and wags her tail hopefully.","looks at _T with bright eyes.","arfs pleasantly at _T!")
	var/list/aggressor_emotes = list("barks madly at _T!","glares stoicly at _T!","chases _T, yapping incessantly!")

	// Stores known mobs
	var/list/dislike = list()
	var/list/like = list()
	var/list/fears = list()
	var/mob/living/target = null

	var/turns_since_scan = 0

	// Passes the sniff test
	var/list/smell_approved = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat, /obj/item/weapon/reagent_containers/food/snacks/meat/monkey,
		/obj/item/weapon/reagent_containers/food/snacks/donut,
		/obj/item/weapon/reagent_containers/food/snacks/donut/jelly, /obj/item/weapon/reagent_containers/food/snacks/donut/jelly/cherryjelly,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/meat, /obj/item/weapon/reagent_containers/food/snacks/kebab/monkey,
		/obj/item/weapon/reagent_containers/food/snacks/pie/meatpie, /obj/item/weapon/reagent_containers/food/snacks/sosjerky)

	// Fails the sniff test
	var/list/smell_offensive = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human, /obj/item/weapon/reagent_containers/food/snacks/meat/corgi,
		/obj/item/weapon/reagent_containers/food/snacks/badrecipe, /obj/item/weapon/reagent_containers/food/snacks/burger/clown,
		/obj/item/weapon/reagent_containers/food/snacks/meat/xeno, /obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie,
		/obj/item/weapon/reagent_containers/food/snacks/soup/mystery, /obj/item/weapon/reagent_containers/food/snacks/carpmeat,
		/obj/item/weapon/reagent_containers/food/snacks/burger/brain,/obj/item/weapon/reagent_containers/food/snacks/spesslaw) // that's offensive to the legal system, sir

	// Also fails the sniff test
	var/list/nasty_reagents = list("mutationtoxin","amutationtoxin","toxin","amatoxin","mutagen","plasma","slimejelly",
		"carpotoxin","mindbreaker","chloralhydrate","sacid","pacid")



/mob/living/simple_animal/corgi/puppy/smart/proc/decide_interest(var/mob/M)
	if(M in like || M in dislike)
		return
	if(ishuman(M) && M.mind)
		var/mob/living/carbon/human/H = M
		if(H.mind.changeling) // sgt pepper detects changelings
			dislike += H
			return

		if(H.mind.special_role && prob(40))
			dislike += H
			return

		if((H.mind.assigned_role in security_positions) && prob(65))
			like += H
			return

		if(istype(H.l_hand,/obj/item/weapon/reagent_containers))
			switch(sniff_test(H.l_hand))
				if(1)
					like += M
					return
				if(-1)
					dislike += M
					return

		if(istype(H.r_hand,/obj/item/weapon/reagent_containers))
			switch(sniff_test(H.r_hand))
				if(1)
					like += M
					return
				if(-1)
					dislike += M
					return

	else if(istype(M,/mob/living/carbon/alien/larva))
		dislike += M
		target = M
		return

	else if(istype(M,/mob/living/simple_animal))
		if(istype(M,/mob/living/simple_animal/corgi) && prob(45))
			like += M
			return

		if(istype(M,/mob/living/simple_animal/hostile)) // this will likely make her march off to her doom
			dislike += M								// loveable dog, stupid dog...
			target = M
			return

		if(istype(M,/mob/living/simple_animal) && prob(29))
			if(prob(80))
				dislike += M
			else
				like += M

	if(prob(40)) // blind determination
		if(prob(59))
			dislike += M
			return
		like += M
		return


	//return (-1, 0, 1) based on bad, indifferent, good
/mob/living/simple_animal/corgi/puppy/smart/proc/sniff_test(var/obj/item/weapon/reagent_containers/RC)
	if((RC.type in smell_approved) && prob(95))
		return 1
	if(RC.type in smell_offensive)
		return -1

	for(var/datum/reagent/R in RC.reagents)
		if((R.id in nasty_reagents) && prob(85))
			return -1
	return 0

/mob/living/simple_animal/corgi/puppy/smart/Life()
	..()
	if(stat != CONSCIOUS || prob(21))
		return // distractable

	// --------------------------------------------
	//  Deal with a creature we noticed previously
	// --------------------------------------------
	if(target)

		// Flee until no longer in sight
		if(target in fears)
			if(get_dist(src,target) < 7)
				var/atom/oldloc = loc
				step_away(src,target)
				sleep(1)
				step_away(src,target)
				while(prob(15))
					sleep(1)
					step_away(src,target)
				if(loc == oldloc && prob(30))
					emote("me", 1, "cowers from [target]!")
				if(loc != oldloc && prob(40))
					emote("me", 1, "flees, yipping in a panic!")
				return

			// Done fleeing, shift in attention
			else
				if(prob(90))
					fears -= target // multiple violent actions mean multiple instances in fears,
				target = null		// you may have to approach peacefully several times then leave

		// Approach and beg
		else if(target in like)
			if(prob(60) && (target in oview(2,src)))
				step_towards(src,target)
				if(prob(32))
					var/cheery_message = pick(friendly_emotes)
					cheery_message = replacetext(cheery_message,"_T",target.name)
					emote("me", 1, "[cheery_message]")
					visible_message("[src] [cheery_message]")
				return

			// Shift in attention
			if(prob(10))
				like -= target
				decide_interest(target)
				target = null
				return
			target = null // didn't chase, lost interest

		// Approach and harrass
		else if(target in dislike)
			if(prob(55) && (target in oview(4,src)))
				step_towards(src,target)
				while(prob(20))
					sleep(1)
					step_towards(src,target)
				if(prob(68))
					var/angry_message = pick(aggressor_emotes)
					angry_message = replacetext(angry_message,"_T",target.name)
					emote("me", 1, "[angry_message]")
				return

			// Shift in attention
			if(prob(3) && sniff_test(target) >= 0)
				dislike -= target
			target = null
		else
			target = null
		return

	// No current target, bored doggy
	if(prob(42))
		return

	// Item interactions
	if(prob(50))
		for(var/obj/item/weapon/reagent_containers/RD in loc)
			switch(sniff_test(RD))
				if(1)
					emote("me", 1, " sniffs [RD]")
					spawn(20)
						RD.attack_animal(src)
					return
				if(-1)
					if(prob(45))
						emote("me", 1, " sniffs [RD]")
						spawn(12)
							emote("me", 1, " recoils from [RD], and barks angrily!")
							step_away(src,RD)
						return

	// Find a new attention focus
	var/list/nearby = viewers(6,src) - src

	// OSHIT THAT DOES NOT LOOK FRIENDLY
	for(var/mob/living/carbon/alien/humanoid/AH in nearby)
		if(AH.stat & DEAD)	// WAIT HE IS DEAD YEAH I AM THE BEST DOG *EVER*
			fears -= AH		// ARF ARF ARF ARF ARF ARF ARF
			dislike |= AH	// ARF ARF ARF ARF
			if(prob(66))	// ARF ARF ARF ARF ARF ARF
				target = AH	// ARF ARF ARF ARF ARF
		else
			fears |= AH		// WAAAAAH SOMEONE HEEEEEEELP

	//Anyone to be afraid of?
	var/list/temp = nearby & fears
	if(temp.len)
		target = pick(temp)
		return

	// Anyone to aggress?
	temp = nearby & dislike
	for(var/mob/living/ML in temp)
		if(prob(45))
			target = ML
			return
		nearby -= ML

	// Anyone to snuggle?
	temp = nearby & like
	for(var/mob/living/ML in temp)
		if(prob(50))
			target = ML
			return
		nearby -= ML

	// Any new people?
	for(var/mob/living/ML in nearby)
		emote("me", 1, "sniffs warily at [ML].")
		decide_interest(ML)
		return

/mob/living/simple_animal/corgi/puppy/smart/attack_animal(mob/living/simple_animal/M as mob)
	like -= M
	fears += M
	target = M
	..()

/mob/living/simple_animal/corgi/puppy/smart/attackby(var/obj/item/W as obj,var/mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers) && !(user in fears))
		emote("me", 1, " sniffs at [W].")
		sleep(30)
		var/r =sniff_test(W)
		testing(r)
		switch(r)
			if(1)
				var/result = pick(smell_approved_emotes)
				emote("me", 1, "[result]")
				if(prob(89))
					W.attack_animal(src)
					if(user in dislike)
						dislike -= user
					else if (!(user in like) && prob(45))
						like += user
			if(0)
				emote("me", 1, "[pick(smell_neutral_emotes)]")
			if(-1)
				emote("me", 1, "[pick(smell_offensive_emotes)]")
		return


	// this will become a normal attack
	like -= user
	fears += user
	..(W,user)

/mob/living/simple_animal/corgi/puppy/smart/attack_hand(var/mob/user as mob)
	if(iscarbon(user))
		switch(user.a_intent)
			if("grab")
				if(!(user in like)) // HEY WHOA NO WAY MAN
					dislike |= user

					var/atom/oldloc = loc
					step_away(src,user)
					if(loc != oldloc)
						emote("me", 1, "leaps back from [user], barking angrily!")
					else
						emote("me", 1, "snaps at [user]'s hand!")


			if("harm","disarm")
				like -= user
				dislike |= user
				fears += user
	..(user)
