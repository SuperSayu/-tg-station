/datum/round_event_control/undead
	name = "Undead rising"
	typepath = /datum/round_event/undead
	max_occurrences = 1

/datum/round_event/undead
	var/spawn_prob = 8
	startWhen = 2
	announceWhen = 3
	var/selected_z = 1
	setup()
		selected_z = pick(1,3,4,5)
		if(selected_z == 1)
			var/datum/round_event/electrical_storm/RS = new
			RS.lightsoutAmount = pick(2,2,3)
			RS.start()
			RS.kill()
	start()
		for(var/area/A)
			if(A.luminosity) continue // prevents all tiles that have any light in them
			if(A.lighting_space) continue // should prevent all space tiles--they are space-lit
			if(A.type == /area) continue
			var/list/turflist = list()
			for(var/turf/T in A)
				if(T.z != selected_z) continue
				if(istype(T,/turf/space) || T.density) continue
				if(locate(/mob/living) in T) continue
				var/okay = 1
				for(var/obj/O in T)
					if(O.density)
						okay = 0
						break
				if(okay)
					turflist += T

			if(!turflist.len) continue
			var/turfs = round(turflist.len * spawn_prob/100,1)
			while(turfs > 0 && turflist.len) // safety
				turfs--
				var/turf/T = pick_n_take(turflist)
				var/undeadtype = pick(/mob/living/simple_animal/hostile/retaliate/skeleton,
									80;/mob/living/simple_animal/hostile/retaliate/zombie,
									60;/mob/living/simple_animal/hostile/retaliate/ghost)
				new undeadtype(T)
	announce()
		for(var/mob/living/carbon/M in player_list)
			if(M.z == selected_z)
				M << "You feel [pick("a chill","a deathly chill","the undead","dirty", "creeped out","afraid","fear")]!"
		for(var/mob/dead/D in player_list)
			D << "You feel dark energies pull back towards the living world, but it quickly fades."
