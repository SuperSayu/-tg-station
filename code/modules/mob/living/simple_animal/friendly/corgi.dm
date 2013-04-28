//Corgi
/mob/living/simple_animal/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 10
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	meat_amount = 3
	response_help  = "pets the"
	response_disarm = "bops the"
	response_harm   = "kicks the"
	see_in_dark = 5
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/facehugger

/mob/living/simple_animal/corgi/Life()
	..()
	regenerate_icons()

/mob/living/simple_animal/corgi/show_inv(mob/user as mob)
	user.set_machine(src)
	if(user.stat) return

	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	if(inventory_head)
		dat +=	"<br><b>Head:</b> [inventory_head] (<a href='?src=\ref[src];remove_inv=head'>Remove</a>)"
	else
		dat +=	"<br><b>Head:</b> <a href='?src=\ref[src];add_inv=head'>Nothing</a>"
	if(inventory_back)
		dat +=	"<br><b>Back:</b> [inventory_back] (<a href='?src=\ref[src];remove_inv=back'>Remove</a>)"
	else
		dat +=	"<br><b>Back:</b> <a href='?src=\ref[src];add_inv=back'>Nothing</a>"

	user << browse(dat, text("window=mob[];size=325x500", real_name))
	onclose(user, "mob[real_name]")
	return

/mob/living/simple_animal/corgi/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(inventory_head && inventory_back)
		//helmet and armor = 100% protection
		if( istype(inventory_head,/obj/item/clothing/head/helmet) && istype(inventory_back,/obj/item/clothing/suit/armor) )
			if( O.force )
				usr << "\red This animal is wearing too much armor. You can't cause /him any damage."
				for (var/mob/M in viewers(src, null))
					M.show_message("\red \b [user] hits [src] with the [O], however [src] is too armored.")
			else
				usr << "\red This animal is wearing too much armor. You can't reach its skin."
				for (var/mob/M in viewers(src, null))
					M.show_message("\red [user] gently taps [src] with the [O]. ")
			if(prob(15))
				emote("looks at [user] with [pick("an amused","an annoyed","a confused","a resentful", "a happy", "an excited")] expression on \his face")
			return
	..()

/mob/living/simple_animal/corgi/Topic(href, href_list)
	if(usr.stat) return

	//Removing from inventory
	if(href_list["remove_inv"])
		if(get_dist(src,usr) > 1 || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				if(inventory_head)
					name = real_name
					desc = initial(desc)
					speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
					speak_emote = list("barks", "woofs")
					emote_hear = list("barks", "woofs", "yaps","pants")
					emote_see = list("shakes its head", "shivers")
					desc = "It's a corgi."
					SetLuminosity(0)
					inventory_head.loc = src.loc
					inventory_head = null
				else
					usr << "\red There is nothing to remove from its [remove_from]."
					return
			if("back")
				if(inventory_back)
					inventory_back.loc = src.loc
					inventory_back = null
				else
					usr << "\red There is nothing to remove from its [remove_from]."
					return

		//show_inv(usr) //Commented out because changing Ian's  name and then calling up his inventory opens a new inventory...which is annoying.

	//Adding things to inventory
	else if(href_list["add_inv"])
		if(get_dist(src,usr) > 1 || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return
		var/add_to = href_list["add_inv"]
		if(!usr.get_active_hand())
			usr << "\red You have nothing in your hand to put on its [add_to]."
			return
		switch(add_to)
			if("head")
				if(inventory_head)
					usr << "\red It's is already wearing something."
					return
				else
					place_on_head(usr.get_active_hand())

					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return

					//Corgis are supposed to be simpler, so only a select few objects can actually be put
					//to be compatible with them. The objects are below.
					//Many  hats added, Some will probably be removed, just want to see which ones are popular.

					var/list/allowed_types = list(
						/obj/item/clothing/head/helmet,
						/obj/item/clothing/glasses/sunglasses,
						/obj/item/clothing/head/caphat,
						/obj/item/clothing/head/collectable/captain,
						/obj/item/clothing/head/that,
						/obj/item/clothing/head/that,
						/obj/item/clothing/head/kitty,
						/obj/item/clothing/head/collectable/kitty,
						/obj/item/clothing/head/rabbitears,
						/obj/item/clothing/head/collectable/rabbitears,
						/obj/item/clothing/head/beret,
						/obj/item/clothing/head/collectable/beret,
						/obj/item/clothing/head/det_hat,
						/obj/item/clothing/head/nursehat,
						/obj/item/clothing/head/pirate,
						/obj/item/clothing/head/collectable/pirate,
						/obj/item/clothing/head/ushanka,
						/obj/item/clothing/head/chefhat,
						/obj/item/clothing/head/collectable/chef,
						/obj/item/clothing/head/collectable/police,
						/obj/item/clothing/head/wizard/fake,
						/obj/item/clothing/head/wizard,
						/obj/item/clothing/head/collectable/wizard,
						/obj/item/clothing/head/hardhat,
						/obj/item/clothing/head/collectable/hardhat,
						/obj/item/clothing/head/hardhat/white,
						/obj/item/weapon/bedsheet,
						/obj/item/clothing/head/helmet/space/santahat,
						/obj/item/clothing/head/collectable/paper,
						/obj/item/clothing/head/soft
					)

					if( ! ( item_to_add.type in allowed_types ) )
						usr << "\red It doesn't seem too keen on wearing that item."
						return

					usr.drop_item()

					place_on_head(item_to_add)

			if("back")
				if(inventory_back)
					usr << "\red It's already wearing something."
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return

					//Corgis are supposed to be simpler, so only a select few objects can actually be put
					//to be compatible with them. The objects are below.

					var/list/allowed_types = list(
						/obj/item/clothing/suit/armor/vest,
						/obj/item/device/radio
					)

					if( ! ( item_to_add.type in allowed_types ) )
						usr << "\red This object won't fit."
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_back = item_to_add
					regenerate_icons()

		show_inv(usr)
	else
		..()

/mob/living/simple_animal/corgi/proc/place_on_head(obj/item/item_to_add)
	item_to_add.loc = src
	src.inventory_head = item_to_add
	regenerate_icons()

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a HAT is removed.
	switch(inventory_head && inventory_head.type)
		if(/obj/item/clothing/head/caphat, /obj/item/clothing/head/collectable/captain)
			name = "Captain [real_name]"
			desc = "Probably better than the last captain."
		if(/obj/item/clothing/head/kitty, /obj/item/clothing/head/collectable/kitty)
			name = "Runtime"
			emote_see = list("coughs up a furball", "stretches")
			emote_hear = list("purrs")
			speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS", "MEEEEEEW")
			desc = "It's a cute little kitty-cat! ... wait ... what the hell?"
		if(/obj/item/clothing/head/rabbitears, /obj/item/clothing/head/collectable/rabbitears)
			name = "Hoppy"
			emote_see = list("twitches its nose", "hops around a bit")
			desc = "This is hoppy. It's a corgi-...urmm... bunny rabbit"
		if(/obj/item/clothing/head/beret, /obj/item/clothing/head/collectable/beret)
			name = "Yann"
			desc = "Mon dieu! C'est un chien!"
			speak = list("le woof!", "le bark!", "JAPPE!!")
			emote_see = list("cowers in fear", "surrenders", "plays dead","looks as though there is a wall in front of him")
		if(/obj/item/clothing/head/det_hat)
			name = "Detective [real_name]"
			desc = "[name] sees through your lies..."
			emote_see = list("investigates the area","sniffs around for clues","searches for scooby snacks")
		if(/obj/item/clothing/head/nursehat)
			name = "Nurse [real_name]"
			desc = "[name] needs 100cc of beef jerky...STAT!"
		if(/obj/item/clothing/head/pirate, /obj/item/clothing/head/collectable/pirate)
			name = "[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibble","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]"
			desc = "Yaarghh!! Thar' be a scurvy dog!"
			emote_see = list("hunts for treasure","stares coldly...","gnashes his tiny corgi teeth")
			emote_hear = list("growls ferociously", "snarls")
			speak = list("Arrrrgh!!","Grrrrrr!")
		if(/obj/item/clothing/head/ushanka)
			name = "[pick("Comrade","Commissar","Glorious Leader")] [real_name]"
			desc = "A follower of Karl Barx."
			emote_see = list("contemplates the failings of the capitalist economic model", "ponders the pros and cons of vangaurdism")
		if(/obj/item/clothing/head/collectable/police)
			name = "Officer [real_name]"
			emote_see = list("drools","looks for donuts")
			desc = "Stop right there criminal scum!"
		if(/obj/item/clothing/head/wizard/fake,	/obj/item/clothing/head/wizard,	/obj/item/clothing/head/collectable/wizard)
			name = "Grandwizard [real_name]"
			speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "EI  NATH!")
		if(/obj/item/weapon/bedsheet)
			name = "\improper Ghost"
			speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
			emote_see = list("stumbles around", "shivers")
			emote_hear = list("howls","groans")
			desc = "Spooky!"
		if(/obj/item/clothing/head/helmet/space/santahat)
			name = "Rudolph the Red-Nosed Corgi"
			emote_hear = list("barks christmas songs", "yaps")
			desc = "He has a very shiny nose."
			SetLuminosity(4)
		if(/obj/item/clothing/head/soft)
			name = "Corgi Tech [real_name]"
			desc = "The reason your yellow gloves have chew-marks."


//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's a corgi."
	var/turns_since_scan = 0
	var/obj/movement_target
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"

/mob/living/simple_animal/corgi/Ian/Life()
	..()

	//Feeding, chasing food, FOOOOODDDD
	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/weapon/reagent_containers/food/snacks/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				stop_automated_movement = 1
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)

				if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
					if (movement_target.loc.x < src.x)
						dir = WEST
					else if (movement_target.loc.x > src.x)
						dir = EAST
					else if (movement_target.loc.y < src.y)
						dir = SOUTH
					else if (movement_target.loc.y > src.y)
						dir = NORTH
					else
						dir = SOUTH

					if(isturf(movement_target.loc) )
						movement_target.attack_animal(src)
					else if(ishuman(movement_target.loc) )
						if(prob(20))
							emote("stares at the [movement_target] that [movement_target.loc] has with a sad puppy-face")

		if(prob(1))
			emote(pick("dances around","chases its tail"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)

/mob/living/simple_animal/corgi/Ian/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && (FAT in tmob.mutations))
				if(prob(70))
					src << "\red <B>You fail to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
			if(!(tmob.status_flags & CANPUSH))
				now_pushing = 0
				return

			tmob.LAssailant = src
		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = null
		return
	return
//PC stuff-Sieve

/mob/living/simple_animal/corgi/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/weapon/newspaper))
		if(!stat)
			for(var/mob/M in viewers(user, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\blue [user] baps [name] on the nose with the rolled up [O]")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					dir = i
					sleep(1)
	else
		..()

/mob/living/simple_animal/corgi/regenerate_icons()
	overlays = list()

	if(inventory_head)
		var/head_icon_state = inventory_head.icon_state
		if(health <= 0)
			head_icon_state += "2"

		var/icon/head_icon = image('icons/mob/corgi_head.dmi',head_icon_state)
		if(head_icon)
			overlays += head_icon

	if(inventory_back)
		var/back_icon_state = inventory_back.icon_state
		if(health <= 0)
			back_icon_state += "2"

		var/icon/back_icon = image('icons/mob/corgi_back.dmi',back_icon_state)
		if(back_icon)
			overlays += back_icon

	if(facehugger)
		if(istype(src, /mob/living/simple_animal/corgi/puppy))
			overlays += image('icons/mob/mask.dmi',"facehugger_corgipuppy")
		else
			overlays += image('icons/mob/mask.dmi',"facehugger_corgi")

	return



/mob/living/simple_animal/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy."
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"


//puppies cannot wear anything.
/mob/living/simple_animal/corgi/puppy/Topic(href, href_list)
	if(href_list["add_inv"])
		usr << "\red You can't fit this on [src]"
		return
	if(href_list["remove_inv"])
		usr << "\red You can't take it off!"
	..()

mob/living/simple_animal/corgi/puppy/sgt_pepper
	name = "Sgt. Pepper"
	real_name = "Sgt. Pepper"
	gender = "female"
	desc = "She's the ruffest, tuffest little doggy in all the station."
	icon_state = "sgt_pepper"
	icon_living = "sgt_pepper"
	icon_dead = "sgt_pepper_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	var/list/dislike = list()
	var/list/like = list()
	var/list/fears = list()
	var/turns_since_scan = 0
	var/mob/target = null

	proc/decide_interest(var/mob/M)
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

		if(prob(40)) // blind determination
			if(prob(59))
				dislike += M
				return
			like += M
			return


	//return (-1, 0, 1) based on bad, indifferent, good
	proc/sniff_test(var/obj/item/weapon/reagent_containers/RC)
		var/list/approved = list(
			/obj/item/weapon/reagent_containers/food/snacks/meat,
			/obj/item/weapon/reagent_containers/food/snacks/meat/monkey,
			/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh,
			/obj/item/weapon/reagent_containers/food/snacks/donut,
			/obj/item/weapon/reagent_containers/food/snacks/donut/normal,
			/obj/item/weapon/reagent_containers/food/snacks/donut/jelly,
			/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly,
			/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice,
			/obj/item/weapon/reagent_containers/food/snacks/monkeykabob,
			/obj/item/weapon/reagent_containers/food/snacks/meatpie,
			/obj/item/weapon/reagent_containers/food/snacks/sosjerky)
		var/list/offensive = list(
			/obj/item/weapon/reagent_containers/food/snacks/meat/human,
			/obj/item/weapon/reagent_containers/food/snacks/meat/corgi,
			/obj/item/weapon/reagent_containers/food/snacks/badrecipe,
			/obj/item/weapon/reagent_containers/food/snacks/clownburger,
			/obj/item/weapon/reagent_containers/food/snacks/spesslaw, // that's offensive to the legal system, sir
			/obj/item/weapon/reagent_containers/food/snacks/xenomeat,
			/obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice,
			/obj/item/weapon/reagent_containers/food/snacks/mysterysoup,
			/obj/item/weapon/reagent_containers/food/snacks/carpmeat,
			/obj/item/weapon/reagent_containers/food/snacks/brainburger)

		var/list/nasty = list(
			"mutationtoxin","amutationtoxin","toxin","amatoxin","mutagen","plasma","slimejelly","carpotoxin","mindbreaker",
			"chloralhydrate","sacid","pacid")

		if((RC.type in approved) && prob(95))
			return 1
		if(RC.type in offensive)
			return -1

		for(var/datum/reagent/R in RC.reagents)
			if((R.id in nasty) && prob(85))
				return -1
		return 0

	Life()
		..()
		if(stat != CONSCIOUS || prob(21))
			return // distractable

		if(target)
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
						visible_message("[src] cowers from [target]!")
					if(loc != oldloc && prob(40))
						visible_message("\red [src] flees, yipping in a panic!")
					return
				else
					if(prob(90))
						fears -= target
					target = null


			else if(target in like)
				if(prob(60) && (target in oview(2,src)))
					step_towards(src,target)
					if(prob(32))
						var/cheery_message = pick(
							"[src] follows [target] and wags her tail hopefully.",
							"[src] looks at [target] with bright eyes.",
							"[src] arfs pleasantly at [target]!")

						visible_message(cheery_message)
					return

				if(prob(10))
					like -= target
					decide_interest(target)
					target = null
					return
				target = null // didn't chase, lost interest

			else if(target in dislike)
				if(prob(55) && (target in oview(4,src)))
					step_towards(src,target)
					while(prob(20))
						sleep(1)
						step_towards(src,target)
					if(prob(68))
						var/angry_message = pick(
							"\red [src] barks madly at [target]!",
							"[src] glares stoicly at [target]!",
							"\red [src] chases [target], yapping incessantly!")
						visible_message(angry_message)
					return

				if(prob(2) && sniff_test(target) >= 0)
					dislike -= target
				target = null
			else
				target = null
			return

		if(prob(42))
			return

		if(prob(50))
			for(var/obj/item/weapon/reagent_containers/RD in loc)
				switch(sniff_test(RD))
					if(1)
						visible_message("\blue [src] sniffs [RD]")
						sleep(20)
						RD.attack_animal(src)
						return
					if(-1)
						if(prob(45))
							visible_message("\blue [src] sniffs [RD]")
							sleep(12)
							visible_message("\red [src] recoils from [RD], and barks angrily!")
							step_away(src,RD)
							return


		for(var/mob/living/M in viewers(6,src))
			if(M == src)
				continue
			if(M in fears)
				target = M
				return

			if(M in like)
				if(prob(35)) // you got my attention
					target = M
					return
				continue
			if(M in dislike)
				if(prob(55))
					target = M
					return
				continue


			if(istype(M,/mob/living/carbon/alien/humanoid)) // yes even dogs get oshit reactions
				fears += M
				target = M
				return

			visible_message("[src] sniffs warily at [M].")
			if(istype(M,/mob/living/simple_animal))
				if(istype(M,/mob/living/simple_animal/corgi) && prob(40))
					like += M
					continue
				if(istype(M,/mob/living/simple_animal/hostile)) // this will likely make her march off to her doom
					dislike += M								// love dogs, but they are loyal to a fault
					target = M
					return
				if(istype(M,/mob/living/simple_animal) && prob(29))
					if(prob(80))
						dislike += M
					else
						like += M

			if(istype(M,/mob/living/carbon/alien/larva))
				dislike += M
				target = M
				return

			decide_interest(M)

	attack_animal(mob/living/simple_animal/M as mob)
		like -= M
		fears += M
		target = M
		..()

	attackby(var/obj/item/W as obj,var/mob/user as mob)
		if(istype(W,/obj/item/weapon/reagent_containers) && !(user in fears))
			visible_message("\blue [src] sniffs [W]")
			sleep(30)
			var/r =sniff_test(W)
			testing(r)
			switch(r)
				if(1)
					var/result = pick("She seems okay with it.", "She looks hungry.", "She seems to like it.", "She's interested!")
					visible_message("\blue [result]")
					if(prob(59))
						W.attack_animal(src)
						if(user in dislike)
							dislike -= user
						else if (!(user in like) && prob(45))
							like += user
				if(0)
					var/result = pick("She seems bemused.","She seems okay with it.", "She doesn't seem to care.")
					visible_message("\blue [result]")
				if(-1)
					var/result = pick("She seems bemused.","She seems agitated!", "She doesn't seem to like it.", "She looks bothered!")
					visible_message("\blue [result]")
			return


		// this will become a normal attack
		like -= user
		fears += user
		..(W,user)

	attack_hand(var/mob/user as mob)
		if(iscarbon(user))
			switch(user.a_intent)
				if("grab")
					var/atom/oldloc = loc
					step_away(src,user)
					if(loc != oldloc)
						visible_message("\red [src] is trying not to get grabbed!")
					else
						visible_message("\red [src] cowers helplessly!")
					fears |= user
				if("harm","disarm")
					fears += user
		..(user)




//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/puppies = 0

//Lisa already has a cute bow!
/mob/living/simple_animal/corgi/Lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		usr << "\red [src] already has a cute bow!"
		return
	..()

/mob/living/simple_animal/corgi/Lisa/Life()
	..()

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 15 && !client)
			turns_since_scan = 0
			var/alone = 1
			var/ian = 0
			for(var/mob/M in oviewers(7, src))
				if(istype(M, /mob/living/simple_animal/corgi/Ian))
					if(M.client)
						alone = 0
						break
					else
						ian = M
				else
					alone = 0
					break
			if(alone && ian && puppies < 4)
				if(near_camera(src) || near_camera(ian))
					return
				new /mob/living/simple_animal/corgi/puppy(loc)


		if(prob(1))
			emote(pick("dances around","chases her tail"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)