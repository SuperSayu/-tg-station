/obj/item/artifact/proc/set_power()
	// Called once, when the artifact is created. Used for setting prefixes and extra vars.
	switch(power)
		if(A_SHIELD)
			prefix = pick("glassy","shiny","reflective","hardened")
			extra1 = rand(5,20)*10
			max_cooldown = extra1*3
		if(A_PUSH)
			prefix = pick("swirling","humming","vibrating","breathing")
			extra1 = rand(3,9)
			if(usetype == A_CLICK)
				max_cooldown = rand(1,3)*10
		if(A_PULL)
			prefix = pick("swirling","humming","vibrating","breathing")
			extra1 = rand(3,9)
			if(usetype == A_CLICK)
				max_cooldown = rand(1,3)*10
		if(A_SLEEP)
			prefix = pick("humming","relaxing","waving","rippling","gentle")
			extra1 = rand(1,4)
			extra2 = rand(2,5)
			max_cooldown = extra2*50
		if(A_HEAL)
			prefix = pick("gentle","shiny","pulsating","quiet")
			extra1 = rand(7,15)
			extra2 = rand(1,3)
			if(usetype == A_CONSTANT)
				extra1 = extra1/10
			else
				max_cooldown = extra1*20
		if(A_SEAL)
			prefix = pick("hardened","cracked","vibrating")
			extra1 = rand(3,6)
			max_cooldown = extra1*200
		if(A_EXPLODE)
			prefix = pick("flashing","pulsating","vibrating","charged","glowing")
			extra1 = rand(1,3)
			extra2 = rand(2,5)*100
			max_cooldown = extra2*2
		if(A_SLIME)
			prefix = pick("gooey","oozing","pulsating","radioactive")
			extra1 = rand(1,3)
			max_cooldown = extra2*2
		if(A_FIRE)
			prefix = pick("flashing","waving","warm","glowing","flickering")
			extra1 = rand(4,10)
			max_cooldown = extra1*200
		if(A_PARTY)
			prefix = pick("flashing","shiny","raving")
			extra1 = rand(3,12)*100
			max_cooldown = extra1*1.5
		if(A_MONOLITH)
			prefix = pick("hardened","shiny","reflective","glowing","whispering")
			extra1 = rand(1,6)*100
			max_cooldown = extra1*2
		if(A_XTINGUISH)
			prefix = pick("cool","waving","windy","simmering","flickering")
			extra1 = rand(4,7)
			max_cooldown = extra1*100
		if(A_NIGHTMARE)
			prefix = pick("whispering","dark","shadowy","swirling","humming")
			extra1 = rand(2,5)
			extra2 = rand(10,30)
			if(usetype == A_CONSTANT)
				max_cooldown = extra2*10
			else
				max_cooldown = extra2*30
		if(A_MUTATE)
			prefix = pick("glowing","radioactive","flashing","oozing")
			extra1 = rand(2,4)
			max_cooldown = (extra1*100)/2
		if(A_ELECTRIC)
			prefix = pick("charged","vibrating","humming","sparking")
			extra1 = rand(1,2)
			extra2 = rand(10,45)
		if(A_WORMHOLE)
			prefix = pick("swirling","pulsating","whispering","flashing")
			extra1 = rand(4,8)
			extra2 = rand(15,45)
			max_cooldown = extra1*10
		if(A_DETECT)
			prefix = pick("spinning","humming","moving","sliding","crackling")
			max_cooldown = rand(1,3)*10
			sound_override = 1
		if(A_BLINK)
			prefix = pick("sparking","flickering","flashing","moving","electric","crackling")
			extra1 = rand(1,8)
			extra2 = rand(1,8)
			max_cooldown = rand(2,5)*10
			usetype = A_CLICK
		if(A_PHASE)
			prefix = pick("flickering","see-through","glassy","reflective","shiny","flashing")
			extra1 = rand(3,9)*100
			max_cooldown = extra1*1.5
		if(A_MAGIC)
			prefix = pick("breathing","glowing","whispering","swirling","shadowy","old")
			extra1 = rand(1,3)
			max_cooldown = (rand(45,75)*10)*extra1
		if(A_CLOAK)
			prefix = pick("flickering","see-through","glowing","swirling","pulsating")
			extra1 = rand(15,45)*10
			max_cooldown = extra1*2
		if(A_INJECT)
			prefix = pick("gooey","pointy","glassy","sliding","sharp")
			extra1 = rand(5,20)
			max_cooldown = (extra1*100)/4
		if(A_THERMAL)
			prefix = pick("warm","cool","glowing","pulsating")
		if(A_CLEAN)
			prefix = pick("wet","cool","reflective","smooth","rippling")
			extra1 = rand(3,7)
			max_cooldown = (extra1*10)*4
		if(A_DIRTY)
			prefix = pick("dusty","dirty","old","cracked")
			extra1 = rand(2,4)
			max_cooldown = (extra1*10)*4
		if(A_LUBE)
			prefix = pick("wet","cool","gooey","shiny")
			extra1 = rand(1,3)
			max_cooldown = (extra1*100)*2
		if(A_LIGHT)
			prefix = pick("glowing","shiny","pulsating","flickering")
			extra1 = rand(6,12)*100
			max_cooldown = extra1*1.1
		if(A_RECHARGE)
			prefix = pick("electric","crackling","sparking","flickering")
			extra1 = rand(2,6)
			extra2 = rand(2,5)
			max_cooldown = (extra1*1.25)*100
		if(A_REFLECT)
			prefix = pick("shiny","reflective","glowing","smooth")
			extra1 = rand(5,10)*10
			extra2 = rand(3,6)*100
			max_cooldown = extra2*(extra1/5)
			reverse = 1 // It will glow when it's reflective!
		if(A_LOCATE)
			prefix = pick("spinning","humming","moving","sliding","crackling")
			max_cooldown = rand(1,3)*10
			sound_override = 1
		if(A_FORCEWALL)
			prefix = pick("glassy","shiny","reflective","hardened")
			extra1 = rand(5,15)*10
			max_cooldown = (extra1*10)*0.5
		if(A_BREATH)
			prefix = pick("breathing","pulsating","rippling","glowing","old")
			extra1 = rand(6,18)*100
			max_cooldown = extra1*1.2
		if(A_PLANT)
			prefix = pick("pulsating","waving","entangled","oozing")
			extra1 = rand(3,7)
			max_cooldown = extra1*100
		if(A_ELECTRICS)
			prefix = pick("charged","vibrating","humming","sparking")
			extra1 = rand(1,3)
			max_cooldown = (extra1*100)*2
		if(A_EMPS)
			prefix = pick("glowing","shiny","flickering","sparking","flashing")
			extra1 = rand(0,2)
			extra2 = rand(3,7)
			max_cooldown = ((extra1+1)*extra2)*100
		if(A_IRRADIATE)
			prefix = pick("dissolving","glowing","radioactive","old","oozing")
			extra1 = rand(45,75)
			extra2 = rand(2,6)
			max_cooldown = extra1*10
		if(A_SURGERY)
			prefix = pick("sharp","fleshy","pointy","glassy","sliding")
		if(A_REPAIR)
			prefix = pick("sparking","charged","shiny","humming")
			extra1 = rand(10,50)
			force = 0
		if(A_DECLONE)
			prefix = pick("vampiric","dissolving","radioactive","old")
			extra1 = rand(5,25)
			max_cooldown = extra1*5
		if(A_MINING)
			prefix = pick("sharp","pointy","heavy","dirty","dusty","hardened")
			extra1 = rand(2,5)
			max_cooldown = extra1*100
		if(A_HONK)
			prefix = pick("old","shadowy","heavy","breathing","vibrating")
			max_cooldown = rand(12,30)*100
		if(A_FORCEPORT)
			prefix = pick("sparking","flickering","flashing","moving","electric","crackling")
			extra1 = rand(1,7)
			extra2 = rand(1,7)
			max_cooldown = rand(6,12)*10
		if(A_SAPLIFE)
			prefix = pick("vampiric","old","dissolving","whispering","shadowy")
			extra1 = rand(10,25)
			max_cooldown = extra1*10
			usetype = A_ATTACK
		if(A_BLOB)
			prefix = pick("oozing","gooey","breathing","pulsating","dissolving")
			extra1 = rand(12,24)*100
			max_cooldown = extra1*3
		if(A_VIRUS)
			prefix = pick("dirty","moving","cracked","quivering","vibrating")
			extra1 = rand(1,4)
			max_cooldown = extra1*200
		if(A_PINKSLIME)
			prefix = pick("gooey","oozing","moving","quivering")
			extra1 = rand(2,6)
			extra2 = rand(4,9)*100
			max_cooldown = extra2
		if(A_CLONEMKY)
			prefix = pick("gentle","breathing","quiet","vampiric")
			extra1 = rand(1,4)
			max_cooldown = extra1*300
		if(A_TELEPORT)
			prefix = pick("sparking","flickering","flashing","moving","electric","crackling")
			extra1 = rand(1,3)
			max_cooldown = (rand(2,6)*extra1)*10
		if(A_SMOKE)
			prefix = pick("swirling","rippling","waving","dusty","dirty")
			extra1 = rand(1,8)*10
			max_cooldown = extra1*10
		if(A_SHOCKER)
			prefix = pick("sparking","crackling","charged","humming","vibrating")
			extra1 = rand(5,25)
			max_cooldown = extra1*10
		if(A_DEMOLISH)
			prefix = pick("dirty","dusty","hardened","heavy","charged")
			extra1 = rand(1,3)
			max_cooldown = (extra1*50)*50
		if(A_MELEE)
			prefix = pick("sharp","heavy","hardened","cracked")
			force = 1
			extra1 = rand(4,20) // This is added to the force of the hit, for cooldown reasons
			extra2 = rand(1,4)
			max_cooldown = extra1*2
			usetype = A_ATTACK
		//if(A_GUN)
		//if(A_MAGICPROJ)
		if(A_TRAVEL)
			prefix = pick("moving","glassy","see-through","reflective","swirling")
			max_cooldown = rand(1,3)*10 // Don't screw people over too hard
			usetype = A_CLICK
		if(A_REVIVE)
			prefix = "protective"

/obj/item/artifact/proc/use_power(var/mob/user, var/mob/target, var/turf/artloc, var/turf/targtile, var/obj/targobj)
	if(!on || cooldown > 0)
		return
	if(max_cooldown && !cooldown)
		cooldown = 1
		update_icons()
	// This first part here is a little sloppy, but it's necessary to detect if someone's holding the artifact in their inventory.
	if(!user)
		if(istype(loc,/mob/living/carbon/human))
			user = loc
		else if(istype(loc,/obj/item/weapon/storage))
			if(istype(loc.loc,/mob/living/carbon/human))
				user = loc.loc
	artloc = get_turf(src.loc)
	if(!targtile)
		targtile = artloc
	if(!target)
		target = user
	if(!sound_override)
		playsound(artloc,'sound/effects/EMPulse.ogg',50,1)
	switch(power)
		// BULKY POWER
		if(A_SHIELD)
			// EXTRA 1: Length of forcewall
			for(var/turf/T in orange(1,targtile))
				new /obj/effect/spelleffect/forcewall(T,null,extra1)
			artloc.visible_message("<span class='notice'>\The [src] generates a forcefield!</span>")
		if(A_PUSH)
			// EXTRA 1: Max distance between artifact and objects for grav effect
			for(var/obj/O in orange(extra1,targtile))
				if(!O.anchored)
					step_away(O,extra1)
			for(var/mob/living/M in orange(extra1,targtile))
				step_away(M,src,extra1)
		if(A_PULL)
			// EXTRA 1: Max distance between artifact and objects for grav effect
			for(var/obj/O in orange(extra1,targtile))
				if(!O.anchored)
					step_towards(O,targtile)
			for(var/mob/living/M in orange(extra1,targtile))
				step_towards(M,targtile)
		if(A_SLEEP)
			// EXTRA 1: Effect range
			// EXTRA 2: Power of the sleep effect
			for(var/mob/living/carbon/human/H in orange(extra1,targtile))
				H << "<span class='danger'>You suddenly feel very sleepy...</span>"
				spawn(extra2*10)
					H.Paralyse(extra2)
					H.sleeping = max(H.sleeping+extra2, 10)
		if(A_HEAL)
			// EXTRA 1: Amount of healing
			// EXTRA 2: Damage type that is healed
			var/msg_chance = 100
			if(usetype == A_CONSTANT)
				msg_chance = 10
			if(usetype != A_ATTACK)
				for(var/mob/living/carbon/human/H in range(3,targtile))
					switch(extra2)
						if(1)
							H.adjustBruteLoss(-extra1)
							if(prob(msg_chance))
								H << "<span class='notice'>You feel soothed and refreshed.</span>"
						if(2)
							H.adjustFireLoss(-extra1)
							if(prob(msg_chance))
								H << "<span class='notice'>You feel cool to the touch.</span>"
						if(3)
							H.adjustToxLoss(-extra1)
							if(prob(msg_chance))
								H << "<span class='notice'>You feel your stomach settle.</span>"
			else
				var/mob/living/carbon/human/H = target
				switch(extra2)
					if(1)
						H.adjustBruteLoss(-extra1)
						if(prob(msg_chance))
							H << "<span class='notice'>You feel soothed and refreshed.</span>"
					if(2)
						H.adjustFireLoss(-extra1)
						if(prob(msg_chance))
							H << "<span class='notice'>You feel cool to the touch.</span>"
					if(3)
						H.adjustToxLoss(-extra1)
						if(prob(msg_chance))
							H << "<span class='notice'>You feel your stomach settle.</span>"
		if(A_SEAL)
			// EXTRA 1: Effect range
			var/num = 0
			for(var/turf/T in range(extra1,targtile))
				if(istype(T,/turf/space))
					new /turf/simulated/floor/plating(T)
					num++
			for(var/turf/T in range(extra1*1.5,targtile))
				T.oxygen = 22
			if(num > 0)
				visible_message("<span class='notice'>The floor under \the [src] suddenly expands!</span>")
		if(A_EXPLODE)
			// EXTRA 1: Explosion multiplier
			// EXTRA 2: Explosion timer
			visible_message("<span class='danger'><b>\The [src] begins to catastrophically overload!</b></span>")
			spawn(extra2)
				if(on)
					visible_message("<span class='danger'><b>\The [src] explodes violently!</b></span>")
					explosion(loc, 1*extra1, 3*extra1, 4*extra1, 5*extra1)
					qdel(src)
		if(A_SLIME)
			// EXTRA 1: Effect range
			for(var/mob/living/carbon/human/H in orange(extra1,targtile))
				H.ContractDisease(new /datum/disease/transformation/slime(0))
		if(A_FIRE)
			// EXTRA 1: Fire power
			if(istype(targtile,/turf/simulated))
				var/turf/simulated/S = targtile
				S.atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, extra1*10)
		if(A_PARTY) // Doesn't work for some reason?
			// EXTRA 1: Party length
			var/area/A = get_area(artloc)
			A = A.loc
			if(!(istype(A, /area)))
				return
			A.partyalert()
			for(var/area/RA in A.related)
				RA.partyalert()
			spawn(extra1)
				for(var/area/RA in A.related)
					RA.partyreset()
		if(A_MONOLITH)
			// EXTRA 1: Time until monolith spawns
			artloc.visible_message("<span class='notice'>\The [src] shimmers slightly in the light.</span>")
			spawn(extra1)
				if(activated)
					artloc.visible_message("<span class='notice'><b>\The [src] turns into a monolith!</span>")
					playsound(artloc, 'sound/effects/phasein.ogg', 100, 1)
					new /obj/structure/monolith(artloc)
					qdel(src)
		if(A_XTINGUISH)
			// EXTRA 1: Effect range
			for(var/obj/effect/hotspot/H in range(extra1,targtile))
				var/turf/T = get_turf(H)
				qdel(H)
				T.temperature = T20C
			for(var/mob/living/carbon/C in range(extra1,targtile))
				C.fire_stacks = 0
				C.ExtinguishMob()
				C.bodytemperature = T20C
		if(A_NIGHTMARE)
			// EXTRA 1: Effect range
			// EXTRA 2: Effect power
			for(var/mob/living/carbon/human/H in range(extra1,artloc))
				if(usetype == A_CONSTANT)
					H.hallucination += extra2
					if(prob(50))
						H << "<span class='warning'>You feel a trickle of insanity...</span>"
				else
					H.hallucination += extra2*2
					if(prob(85))
						H << "<span class='warning'>You feel a trickle of insanity...</span>"
			var/snum = 0
			while(snum != extra1)
				var/list/postiles = list()
				for(var/turf/simulated/floor/S in orange(extra1,targtile))
					postiles += S
				if(postiles.len > 0)
					targtile = pick(postiles)
				var/mob/living/simple_animal/hostile/retaliate/shadow/S = new /mob/living/simple_animal/hostile/retaliate/shadow(targtile)
				S.creation(max_cooldown*0.75)
				snum++
		if(A_MUTATE)
			// EXTRA 1: Effect range
			for(var/mob/living/carbon/human/H in range(extra1,artloc))
				// Clean the person's DNA first
				var/good = rand(0,1)
				clean_randmut(H, good == 1 ? (good_se_blocks | op_se_blocks) : bad_se_blocks, 20) // copypasta from dnaide
				domutcheck(H, 1)
		if(A_ELECTRIC)
			// EXTRA 1: Effect range
			// EXTRA 2: Effect power
			for(var/mob/living/carbon/human/H in range(extra1,artloc))
				var/insulated = 0
				if(H.gloves)
					var/obj/item/clothing/gloves/G = H.gloves
					if(!G.siemens_coefficient) // insulated
						insulated = 1
				if(!insulated)
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(5, 1, H.loc)
					s.start()
					H.Stun(round(min((extra2/4),10)))
					H.Weaken(round(min((extra2/4),10)))
					H.adjustFireLoss(extra2)
					H.visible_message("<span class='danger'>[H.name] was shocked by the [src.name]!</span>", \
					"<span class='danger'><B>You feel a powerful shock course through your body sending you flying!</B></span>", \
					"<span class='danger'>You hear a heavy electrical crack</span>")
					H.updatehealth()
					var/list/throwdirections = list(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
					var/atom/throwtarg = get_edge_target_turf(H, pick(throwdirections))
					H.throw_at(throwtarg, 200, 4)
		if(A_WORMHOLE)
			// EXTRA 1: Range of potential wormholes
			// EXTRA 2: Number of wormholes
			var/list/pick_turfs = list()
			for(var/turf/simulated/floor/T in range(extra1,targtile))
				pick_turfs += T
			while(portals.len < extra2)
				if(pick_turfs.len > 0)
					var/turf/T = pick(pick_turfs)
					new /obj/effect/portal/wormhole(T, null, null, -1)
				else
					break
			spawn(max_cooldown / 1.20)
				for(var/obj/effect/portal/wormhole/W in portals)
					portals -= W
					qdel(W)
		// TINY POWERS
		if(A_DETECT)
			var/detected = 0
			for(var/obj/item/artifact/A in orange(15,artloc))
				if(!detected)
					detected = 1
					var/x_dif = (A.x - artloc.x)
					var/y_dif = (A.y - artloc.y)
					if((x_dif <= 5 && x_dif >= -5) && (y_dif <= 5 && y_dif >= -5))
						playsound(artloc, 'sound/machines/chime.ogg', 100, 0)
					else if((x_dif <= 10 && x_dif >= -10) && (y_dif <= 10 && y_dif >= -10))
						playsound(artloc, 'sound/machines/ping.ogg', 100, 0)
					else if((x_dif <= 15 && x_dif >= -15) && (y_dif <= 15 && y_dif >= -15))
						playsound(artloc, 'sound/machines/ping.ogg', 50, 0)
					else
						playsound(artloc, 'sound/machines/ping.ogg', 10, 0)
			if(!detected)
				visible_message("<span class='danger'>\The [src] is silent. It doesn't seem to detect anything nearby.</span>")
		if(A_BLINK)
			// EXTRA 1: Max X distance
			// EXTRA 2: Max Y distance
			if(istype(target,/mob/living)) // Hack for blinking other people
				user = target
			if(user)
				var/new_x = ((rand(-extra1,extra1))+user.x)
				var/new_y = ((rand(-extra2,extra2))+user.y)
				var/destination = locate(new_x,new_y,user.z)
				do_teleport(user,destination)
		if(A_PHASE)
			// EXTRA 1: Phase length
			if(istype(target,/mob/living)) // Hack for phasing somebody else
				user = target
			if(user)
				user << "<span class='notice'>Your body becomes see-through.</span>"
				user.alpha = 155
				user.pass_flags |= PASSGLASS | PASSGRILLE
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					if(H.dna && H.dna.species)
						H.dna.species.speedmod -= 3
				spawn(extra1)
					if(user)
						user.alpha = 255
						user.pass_flags = 0
						user << "<span class='notice'>Your body becomes solid again.</span>"
						if(ishuman(user))
							var/mob/living/carbon/human/H = user
							if(H.dna && H.dna.species)
								H.dna.species.speedmod += 3
		if(A_MAGIC)
			// EXTRA 1: Number of shadows
			var/snum = 0
			while(snum != extra1)
				var/list/postiles = list()
				for(var/turf/simulated/S in range(extra1,targtile))
					postiles += S
				if(postiles.len > 0)
					targtile = pick(postiles)
				var/mob/living/simple_animal/hostile/retaliate/shadow/S = new /mob/living/simple_animal/hostile/retaliate/shadow(targtile)
				S.creation(max_cooldown*0.5)
				snum++
		if(A_CLOAK)
			// EXTRA 1: Cloak length
			if(istype(target,/mob/living)) // Hack for cloaking somebody else
				user = target
			if(user)
				user << "<span class='notice'>You feel light and transparent.</span>"
				user.alpha = 0 // Completely transparent
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					if(H.dna && H.dna.species)
						H.dna.species.speedmod -= 5
				spawn(extra1)
					if(user)
						user.alpha = 255
						user << "<span class='notice'>Your body becomes visible again.</span>"
						if(ishuman(user))
							var/mob/living/carbon/human/H = user
							if(H.dna && H.dna.species)
								H.dna.species.speedmod += 5
		if(A_INJECT)
			// EXTRA 1: Amount of reagents injected
			var/datum/reagent/R = pick("bicaridine","kelotane","anti_toxin","morphine","mutagen","lexorin", \
			"stoxin","synaptizine","cryptobiolin","ethanol","uranium","space_drugs","frostoil","gargleblaster", \
			"hyperzine","lithium","ryetalyn","nanites","xenomicrobes","nutriment","lipozine")
			var/list/postargs = list()
			for(var/mob/living/carbon/human/H in range(2,targtile))
				postargs += H
			if(postargs.len > 0)
				target = pick(postargs)
			if(target && target.reagents)
				target.reagents.add_reagent(R,extra1)
				target << "<span class='warning'>You feel a tiny prick!</span>"
		if(A_THERMAL)
			if(user)
				if(arttemp > user.bodytemperature) // If the artifact's temperature is greater than your body temperature...
					user.bodytemperature -= round((arttemp/30)) // Heat up.
				else if(user.bodytemperature > arttemp) // If the artifact's temperature is less than your body temperature...
					user.bodytemperature += round((arttemp/30)) // Cool down.
		if(A_CLEAN)
			// EXTRA 1: Effect range
			for(var/obj/effect/decal/cleanable/C in range(extra1,targtile))
				qdel(C)
			playsound(targtile, 'sound/effects/bamf.ogg', 50, 1)
			var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
			steam.set_up(10, 0, targtile)
			steam.attach(targtile)
			steam.start()
		if(A_DIRTY)
			// EXTRA 1: Effect range
			for(var/turf/T in range(extra1,targtile))
				if(!istype(T, /turf/space))
					if(prob(60))
						if(prob(25))
							new /obj/effect/decal/cleanable/xenoblood(T)
						else
							new /obj/effect/decal/cleanable/dirt(T)
			playsound(targtile, 'sound/effects/bamf.ogg', 50, 1)
		if(A_LUBE)
			// EXTRA 1: Effect range
			for(var/turf/simulated/T in range(extra1,targtile))
				if(prob(60))
					T.MakeSlippery(2)
			playsound(targtile, 'sound/effects/bamf.ogg', 50, 1)
			var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
			steam.set_up(10, 0, targtile)
			steam.attach(targtile)
			steam.start()
		if(A_LIGHT)
			// EXTRA 1: Light duration
			targtile.visible_message("<span class='notice'>An orb of light appears.</span>")
			var/obj/effect/artlight/A
			if(usetype != A_CLICK && usetype != A_CONSTANT)
				A = new /obj/effect/artlight(targtile,extra1)
				if(target)
					A.target = target
				else
					A.target = targtile
			else
				A = new /obj/effect/artlight(targtile,extra1)
				if(user)
					A.target = user
		if(A_RECHARGE)
			// EXTRA 1: Effect range
			// EXTRA 2: Amount of charge gained back, lower numbers are better
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, targtile)
			s.start()
			for(var/obj/machinery/power/apc/O in range(extra1,targtile))
				if(O.cell)
					O.cell.charge += (O.cell.maxcharge/extra2)
			for(var/mob/living/silicon/robot/R in range(extra1,targtile))
				if(R.cell)
					R.cell.charge += (R.cell.maxcharge/extra2)
		if(A_LOCATE) // Lol copypasta
			var/detected = 0
			for(var/mob/living/carbon/human/H in orange(15,artloc))
				if(!detected)
					detected = 1
					var/x_dif = (H.x - artloc.x)
					var/y_dif = (H.y - artloc.y)
					if((x_dif <= 5 && x_dif >= -5) && (y_dif <= 5 && y_dif >= -5))
						playsound(artloc, 'sound/machines/chime.ogg', 100, 0)
					else if((x_dif <= 10 && x_dif >= -10) && (y_dif <= 10 && y_dif >= -10))
						playsound(artloc, 'sound/machines/ping.ogg', 100, 0)
					else if((x_dif <= 15 && x_dif >= -15) && (y_dif <= 15 && y_dif >= -15))
						playsound(artloc, 'sound/machines/ping.ogg', 50, 0)
					else
						playsound(artloc, 'sound/machines/ping.ogg', 10, 0)
			if(!detected)
				visible_message("<span class='danger'>\The [src] is silent. It doesn't seem to detect anything nearby.</span>")
		if(A_FORCEWALL)
			// EXTRA 1: Length of forcewall
			new /obj/effect/spelleffect/forcewall(targtile,null,extra1)
			targtile.visible_message("<span class='notice'>\The [src] generates a forcewall!</span>")
		if(A_BREATH)
			// EXTRA 1: Breath length
			if(user && ishuman(user))
				var/mob/living/carbon/human/H = user
				if(H.dna && H.dna.species && !(NOBREATH in H.dna.species.specflags))
					H << "<span class='notice'>You are now breathing manually.</span>"
					H.dna.species.specflags += NOBREATH
					spawn(extra1)
						if(H)
							H << "<span class='danger'>You exhale quickly, your lungs sore and tired.</span>"
							H.dna.species.specflags -= NOBREATH
		//if(A_PLANT) -- TODO
		if(A_ELECTRICS)
			// EXTRA 1: Effect range
			for(var/mob/living/carbon/human/H in range(extra1,targtile))
				var/insulated = 0
				if(H.gloves)
					var/obj/item/clothing/gloves/G = H.gloves
					if(!G.siemens_coefficient) // insulated
						insulated = 1
				if(!insulated)
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(5, 1, H.loc)
					s.start()
					H.Stun(extra1*2)
					H.Weaken(extra1*2)
					H.visible_message("<span class='danger'>[H.name] was shocked by the [src.name]!</span>", \
					"<span class='danger'><B>You feel a weak shock course through your body sending you flying!</B></span>", \
					"<span class='danger'>You hear a weak electrical crack!</span>")
					var/list/throwdirections = list(NORTH,SOUTH,EAST,WEST)
					var/atom/throwtarg = get_edge_target_turf(H, pick(throwdirections))
					H.throw_at(throwtarg, 10, 2)
		if(A_EMPS)
			// EXTRA 1: Heavy range
			// EXTRA 2: Light range
			empulse(targtile,extra1,extra2,0)
		if(A_REFLECT)
			// EXTRA 1: Reflect chance
			// EXTRA 2: Reflect duration
			reflect_chance = extra1
			artloc.visible_message("<span class='notice'>\The [src] begins to refract light.</span>")
			spawn(extra2)
				reflect_chance = 0
				artloc = get_turf(src.loc)
				artloc.visible_message("<span class='danger'>\The [src] becomes dull, and the light around it fades.</span>")
		if(A_IRRADIATE)
			// EXTRA 1: Radiation strength, chance of mutation, chance of good mutation
			// EXTRA 2: Range of effect
			if(!target || target == user)
				for(var/mob/living/carbon/human/H in orange(extra2,src))
					H.apply_effect(extra1, IRRADIATE, 0)
					if(prob(extra1)) // Mutation
						if(prob(extra1)) // Good mutation
							randmutg(H)
							domutcheck(H, null, 1)
						else // Bad mutation
							randmutb(H)
							domutcheck(H, null, 1)
			else
				if(istype(target,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = target
					H.apply_effect(extra1, IRRADIATE, 0)
					if(prob(extra1)) // Mutation
						if(prob(extra1)) // Good mutation
							randmutg(H)
							domutcheck(H, null, 1)
						else // Bad mutation
							randmutb(H)
							domutcheck(H, null, 1)
		if(A_REPAIR)
			// EXTRA 1: Repair strength
			if(target == user)
				for(var/mob/living/carbon/human/H in range(3,targtile))
					var/obj/item/organ/limb/affecting = H.get_organ(check_zone(user.zone_sel.selecting))
					if(affecting.status == ORGAN_ROBOTIC)
						item_heal_robotic(H, user, extra1/2, 0)
				for(var/mob/living/silicon/robot/R in range(3,targtile))
					R.adjustBruteLoss(-(extra1/2))
					R.updatehealth()
			else
				if(istype(target,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = target
					var/obj/item/organ/limb/affecting = H.get_organ(check_zone(user.zone_sel.selecting))
					if(affecting.status == ORGAN_ROBOTIC)
						item_heal_robotic(H, user, extra1, 0)
				else if(istype(target,/mob/living/silicon/robot))
					var/mob/living/silicon/robot/R = target
					R.adjustBruteLoss(-extra1)
					R.updatehealth()
		if(A_SURGERY)
			if(istype(target,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = target
				H.restore_blood()
				var/obj/item/organ/limb/affecting = H.get_organ(check_zone(user.zone_sel.selecting))
				if(affecting)
					affecting.bone_mend(1)
					for(var/obj/item/I in affecting.embedded_objects)
						I.loc = get_turf(H)
						affecting.embedded_objects -= I
		if(A_DECLONE)
			// EXTRA 1: Clone damage
			if(target)
				//target.visible_message("<span class='danger'>[target] has been attacked with [src] by [user]!</span>", \
								//"<span class='userdanger'>[target] has been attacked with [src] by [user]!</span>")
				if(istype(target,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = target
					H.adjustCloneLoss(extra1)
					H << "<span class='danger'><b>You feel your body weakening!</b></span>"
					if(prob(extra1)) // Oh no
						clean_randmut(H, bad_se_blocks, 20)
						domutcheck(H, 1)
		if(A_MINING)
			// EXTRA 1: Mining range
			if(targtile)
				for(var/turf/simulated/mineral/M in range(extra1,targtile))
					M.gets_drilled()
		if(A_HONK) // Forgive me father for I have sinned
			// EXTRA 1: No. This one doesn't even get varied stats. like, forreal. NO.
			playsound(targtile, 'sound/items/AirHorn.ogg', 100, 1)
			for(var/mob/living/carbon/M in ohearers(5, artloc))
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = M
					if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
						continue
				M << "<font color='red' size='5'>HONK</font>"
				M.sleeping = 0
				M.stuttering += 10
				M.ear_deaf += 15
				M.Weaken(3)
				M.Jitter(100)
		if(A_FORCEPORT)
			// EXTRA 1: Max X distance
			// EXTRA 2: Max Y distance
			if(targtile) // Scatters everything all over the place
				for(var/atom/movable/M in targtile.contents)
					if(!M.anchored)
						var/new_x = ((rand(-extra1,extra1))+M.x)
						var/new_y = ((rand(-extra2,extra2))+M.y)
						var/destination = locate(new_x,new_y,M.z)
						do_teleport(M,destination)
		if(A_SAPLIFE)
			// EXTRA 1: Attack power
			if(target == user)
				var/list/postargs = list()
				for(var/mob/living/carbon/human/C in orange(targtile,3))
					if(C == user)
						continue
					postargs += C
				if(postargs.len > 0)
					target = pick(postargs)
				else
					target = null
			if(target)
				if(ishuman(target) && ishuman(user))
					var/mob/living/carbon/human/H = target
					var/mob/living/carbon/human/user2 = user
					H.visible_message("<span class='danger'>[H] has been drained with [src] by [user2]!</span>", \
										"<span class='userdanger'>[H] has been drained with [src] by [user2]!</span>")
					H << "<span class='danger'><b>You feel your body weakening!</b></span>"
					user << "<span class='notice'><b>You feel reinvigorated!</b></span>"
					var/final_damage = max(0,(extra1-H.getarmor(user.zone_sel.selecting,"melee")))
					var/final_health = min((-extra1)+(H.getarmor(user.zone_sel.selecting,"melee")),0)
					H.apply_damage(final_damage,BRUTE)
					if(prob(final_damage*2))
						var/turf/location = target.loc
						if(istype(location, /turf/simulated))
							location.add_blood_floor(target)
					if(user2.getBruteLoss() && user2.getFireLoss())
						user2.adjustBruteLoss(final_health/2)
						user2.adjustFireLoss(final_health/2)
					else if(user2.getBruteLoss())
						user2.adjustBruteLoss(final_health)
					else if(user2.getFireLoss())
						user2.adjustFireLoss(final_health)
		if(A_BLOB)
			// EXTRA 1: Time it takes for the blob node to grow
			new /obj/effect/blobgoo(targtile,extra1)
		if(A_VIRUS)
			// EXTRA 1: Range of effect
			if(target == user)
				target = artloc
			for(var/mob/living/carbon/human/H in range(extra1,target))
				if(H.stat == DEAD)
					continue
				if(user == H)
					continue
				if(prob(rand(10,35)))
					var/datum/disease/virus_type = pick(/datum/disease/fluspanish, /datum/disease/advance/flu, \
					/datum/disease/advance/cold, /datum/disease/brainrot, /datum/disease/magnitis, /datum/disease/pierrot_throat, \
					/datum/disease/cold9)
					var/datum/disease/D = new virus_type()
					D.carrier = 1
					D.holder = H
					D.affected_mob = H
					H.viruses += D
					H << pick("<span class='danger'>You don't feel too good...</span>","<span class='danger'>You feel sick to your stomach.</span>", \
					"<span class='danger'>You suddenly feel woozy.</span>")
		if(A_PINKSLIME)
			// EXTRA 1: Range of effect
			// EXTRA 2: Nutrition level
			for(var/mob/living/carbon/slime/S in range(extra1,artloc))
				S.nutrition = max(extra2,S.nutrition)
				S.rabid = 0
				S.holding_still += 5
				flick_overlay(image('icons/mob/animal.dmi',src,"heart-ani2",MOB_LAYER+1), list(S.client), 20)
		if(A_CLONEMKY)
			// EXTRA 1: Range of effect
			for(var/mob/living/carbon/monkey/M in range(extra1,artloc))
				M.revive()
				M.visible_message("<span class='notice'>\The [M] returns to life!</span>")
		if(A_TELEPORT)
			// EXTRA 1: Range of teleport
			if(targtile)
				for(var/atom/movable/M in range(extra1,artloc))
					if(!M.anchored)
						var/new_x = ((rand(-extra1,extra1))+M.x)
						var/new_y = ((rand(-extra1,extra1))+M.y)
						var/destination = locate(new_x,new_y,M.z)
						do_teleport(M,destination)
		if(A_SMOKE)
			// EXTRA 1: Amount of reagents in the smoke
			var/list/reagent = list("water","carbon","flour","radium","toxin","cleaner","nutriment","condensedcapsaicin",
									"mushroomhallucinogen","lube","plantbgone","lipozine","charcoal","space_drugs",
									"morphine","holywater","ethanol","chloralhydrate","facid","zombiepowder","mindbreaker","spore")
			var/datum/reagents/R = new/datum/reagents(extra1)
			R.my_atom = artloc
			R.add_reagent(pick(reagent), extra1)
			var/datum/effect/effect/system/chem_smoke_spread/smoke = new
			smoke.set_up(R, rand(1, 2), 0, artloc, 0, silent = 1)
			playsound(artloc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(R)
		if(A_SHOCKER) // A lot of repeat code here, couldn't quite get it to be in a way where I'd be able to avoid it
			// EXTRA 1: Shock power
			if(target == user)
				var/list/possibilities = list()
				for(var/mob/living/carbon/human/H in range(extra2,targtile))
					if(H.gloves)
						var/obj/item/clothing/gloves/G = H.gloves
						if(!G.siemens_coefficient)
							continue
					possibilities += H
				if(possibilities.len)
					target = pick(possibilities)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if(H)
					if(H.gloves)
						var/obj/item/clothing/gloves/G = H.gloves
						if(G.siemens_coefficient > 0) // insulated
							H << "<span class='danger'>\The [src] shocks you!</span>"
							H.electrocute_act(extra1, src, 1.0, 0)
							var/list/throwdirections = list(NORTH,SOUTH,EAST,WEST)
							var/atom/throwtarg = get_edge_target_turf(H, pick(throwdirections))
							H.throw_at(throwtarg, 5, 2)
					else
						H << "<span class='danger'>\The [src] shocks you!</span>"
						H.electrocute_act(extra1, src, 1.0, 0)
						var/list/throwdirections = list(NORTH,SOUTH,EAST,WEST)
						var/atom/throwtarg = get_edge_target_turf(H, pick(throwdirections))
						H.throw_at(throwtarg, 5, 2)
		if(A_DEMOLISH)
			// EXTRA 1: Destruction range

			for(var/atom/A in range(extra1,targtile))
				if(!ishuman(A)) // don't explode humans
					A.ex_act(2)
			playsound(artloc, 'sound/effects/explosionfar.ogg', 100, 1)
		if(A_MELEE)
			// EXTRA 1: Damage
			// EXTRA 2: Type of damage
			target.visible_message("<span class='danger'>[target] has been attacked with [src] by [user]!</span>", \
								 "<span class='userdanger'>[target] has been attacked with [src] by [user]!</span>")
			if(target)
				if(istype(target,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = target
					switch(extra2)
						if(1)
							H.adjustBruteLoss(extra1)
						if(2)
							H.adjustFireLoss(extra1)
						if(3)
							H.adjustToxLoss(extra1)
						if(4)
							H.adjustOxyLoss(extra1)
		/*if(A_GUN) -- TODO
			var/atom/fire_targ
			if(target)
				fire_targ = target
			else if(targobj)
				fire_targ = targobj
			else
				fire_targ = targtile
			chambered.fire(fire_targ, user, null, 0, 0)
			playsound(user, 'sound/weapons/Laser.ogg', 50, 1)
			user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear a burst of energy!")*/
		//if(A_MAGICPROJ) -- TODO
		if(A_TRAVEL)
			var/list/pos_levels = list(1,1,1,3,4,5,6) // Travels to the station the majority of the time.
			for(var/num in pos_levels) // Don't travel to the same z-level
				if(target.z == num)
					pos_levels -= num
			var/new_z = pick(pos_levels)
			var/turf/destination = locate(target.x,target.y,new_z)
			do_teleport(target,destination)
			playsound(artloc, 'sound/effects/phasein.ogg', 100, 1)
			playsound(destination, 'sound/effects/phasein.ogg', 100, 1)
	if(max_cooldown > 0 && src)
		spawn(max_cooldown)
			cooldown = 0
			artloc = get_turf(src.loc)
			if(usetype != A_CONSTANT || prob(20)) // Constant artifacts only do the thing sometimes to avoid being annoying
				var/noise = pick("ping","pong","ding","clong","pop","sproing","click","clack","tick")
				artloc.visible_message("<span class='notice'>\The [src] [noise]s.</span>")
			update_icons()
	return

/obj/item/artifact/proc/check_retaliate()
	if(on == 1 && usetype == A_RETALIATE)
		use_power()

/obj/item/artifact/IsShield()
	check_retaliate()
	return 0

/obj/item/artifact/IsReflect()
	check_retaliate()
	return prob(reflect_chance)