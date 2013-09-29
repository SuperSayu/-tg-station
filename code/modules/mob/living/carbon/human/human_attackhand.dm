/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M)
	if(..())	//to allow surgery to return properly.
		return

	if((M != src) && check_shields(0, M.name))
		visible_message("<span class='warning'>[M] attempted to touch [src]!</span>")
		return 0

	switch(M.a_intent)
		if("help")
			if(health >= 0)
				help_shake_act(M)
				return 1

			//CPR
			if((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH)))
				M << "<span class='notice'>Remove your mask!</span>"
				return 0
			if((head && (head.flags & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags & MASKCOVERSMOUTH)))
				M << "<span class='notice'>Remove their mask!</span>"
				return 0

			if(cpr_time < world.time + 30)
				visible_message("<span class='notice'>[M] is trying to perform CPR on [src]!</span>")
				if(!do_mob(M, src))
					return 0
				if((health >= -99 && health <= 0))
					cpr_time = world.time
					var/suff = min(getOxyLoss(), 7)
					adjustOxyLoss(-suff)
					updatehealth()
					M.visible_message("[M] performs CPR on [src]!")
					src << "<span class='unconscious'>You feel a breath of fresh air enter your lungs. It feels good.</span>"

		if("grab")
			if(M == src || anchored)
				return 0
			if(w_uniform)
				w_uniform.add_fingerprint(M)

			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)
			if(buckled)
				M << "<span class='notice'>You cannot grab [src], \he is buckled in!</span>"
			if(!G)	//the grab will delete itself in New if affecting is anchored
				return
			M.put_in_active_hand(G)
			grabbed_by += G
			G.synch()
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[M] has grabbed [src] passively!</span>")
			return 1

		if("harm")
			var/can_break = 0
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Punched [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been punched by [M.name] ([M.ckey])</font>")

			log_attack("<font color='red'>[M.name] ([M.ckey]) punched [src.name] ([src.ckey])</font>")

			var/attack_verb = "punch"
			if(lying)
				attack_verb = "kick"
			else if(M.dna)
				switch(M.dna.mutantrace)
					if("lizard")
						attack_verb = "scratch"
					if("plant")
						attack_verb = "slash"
					if("skeleton")
						attack_verb = "scares"

			var/damage = rand(0, 9)
			if(!damage)
				switch(attack_verb)
					if("slash")
						playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
					else
						playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

				visible_message("<span class='warning'>[M] has attempted to [attack_verb] [src]!</span>")
				return 0

			if(!M.reagents.has_reagent("morphine") && prob(65))
				if(!lying)
					if("left arm" in M.broken || "right arm" in M.broken)
						M << "\red You painfully dislodge your broken arm!"
						M.emote("scream")
						//M.Stun(2)
						playsound(M.loc, 'sound/weapons/pierce.ogg', 25)
						visible_message("<span class='warning'>[M] has attempted to [attack_verb] [src]!</span>")
						return 0
				else if("left leg" in M.broken || "right leg" in M.broken)
					M << "\red You painfully dislodge your broken leg!"
					M.emote("scream")
				//	M.Stun(2)
					playsound(M.loc, 'sound/weapons/pierce.ogg', 25)
					visible_message("<span class='warning'>[M] has attempted to [attack_verb] [src]!</span>")
					return 0

			var/datum/limb/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			if(HULK in M.mutations)
				damage += 5
				can_break = 1

			switch(attack_verb)
				if("slash")
					playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				else
					playsound(loc, "punch", 25, 1, -1)

			visible_message("<span class='danger'>[M] has [attack_verb]ed [src]!</span>", \
							"<span class='userdanger'>[M] has [attack_verb]ed [src]!</span>")

			apply_damage(damage, BRUTE, affecting, armor_block)
			if((stat != DEAD) && damage >= 9)
				visible_message("<span class='danger'>[M] has weakened [src]!</span>", \
								"<span class='userdanger'>[M] has weakened [src]!</span>")
				apply_effect(4, WEAKEN, armor_block)
				forcesay(hit_appends)
			else if(lying)
				forcesay(hit_appends)

			if(can_break && prob(10))
				// HULK SMASH
				var/hit_area = parse_zone(affecting.name)
				if(hit_area in broken)
					return
				var/hit_name
				if(hit_area == "head")
					hit_name = "skull"
				else if(hit_area == "chest")
					hit_name = "ribs"
				else
					hit_name = hit_area
				broken += hit_area
				playsound(src, 'sound/weapons/pierce.ogg', 50)
				var/breaknoise = pick("snap","crack","pop","crick","snick","click","crock","clack","crunch","snak")
				if(affecting != "chest")
					visible_message("<span class='danger'>[src]'s [hit_name] breaks with a [breaknoise]!</span>", \
									"<span class='userdanger'>Your [hit_name] breaks with a [breaknoise]!</span>")
				else
					visible_message("<span class='danger'>[src]'s [hit_name] break with a [breaknoise]!</span>", \
									"<span class='userdanger'>Your [hit_name] break with a [breaknoise]!</span>")

		if("disarm")
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [M.name] ([M.ckey])</font>")
			log_attack("<font color='red'>[M.name] ([M.ckey]) disarmed [src.name] ([src.ckey])</font>")

			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/datum/limb/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/randn = rand(1, 100)
			if(randn <= 25)
				apply_effect(2, WEAKEN, run_armor_check(affecting, "melee"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has pushed [src]!</span>",
								"<span class='userdanger'>[M] has pushed [src]!</span>")
				forcesay(hit_appends)
				return

			if(randn <= 45)
				if(head)
					var/obj/item/clothing/head/H = head
					if(!istype(H) || prob(H.loose))
						drop_from_inventory(H)
						if(prob(60))
							step_rand(H)
						if(stat == CONSCIOUS)
							src.visible_message("<span class='warning'>[M] has knocked [src]'s [H] off!</span>",
											 "<span class='warning'>[M] knocked the [H] clean off your head!</span>")
			var/talked = 0	// BubbleWrap

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(pulling)
					visible_message("<span class='warning'>[M] has broken [src]'s grip on [pulling]!</span>")
					talked = 1
					stop_pulling()

				//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
				if(istype(l_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/lgrab = l_hand
					if(lgrab.affecting)
						visible_message("<span class='warning'>[M] has broken [src]'s grip on [lgrab.affecting]!</span>")
						talked = 1
					spawn(1)
						del(lgrab)
				if(istype(r_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/rgrab = r_hand
					if(rgrab.affecting)
						visible_message("<span class='warning'>[M] has broken [src]'s grip on [rgrab.affecting]!</span>")
						talked = 1
					spawn(1)
						del(rgrab)
				//End BubbleWrap

				if(!talked)	//BubbleWrap
					drop_item()
					visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
									"<span class='userdanger'>[M] has disarmed [src]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] attempted to disarm [src]!</span>", \
							"<span class='userdanger'>[M] attemped to disarm [src]!</span>")
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return