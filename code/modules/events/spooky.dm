/datum/round_event_control/ghosts
	name				= "Ghost Migration"
	typepath			= /datum/round_event/ghosts
	weight				= 10
	earliest_start		= 6000
	max_occurrences		= 6
	minimumCrew			= 4

/datum/round_event/ghosts
	announceWhen	= 70

/datum/round_event/ghosts/setup()
	announceWhen = rand(60, 180)

/datum/round_event/ghosts/announce()
	command_alert("Unknown quasi-aetheric entities have been detected near [station_name()], please stand-by.", "Lifesign Alert?")


/datum/round_event/ghosts/start()
	var/p = 100
	if(player_list.len <= 3)
		p = 25
	else if(player_list.len <= 6)
		p = 50
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn" && prob(p))
			new /mob/living/simple_animal/hostile/retaliate/ghost(C.loc)

/datum/round_event_control/undead
	name = "Undead rising"
	typepath = /datum/round_event/undead
	weight = 5
	max_occurrences = 4
	earliest_start = 300

/datum/round_event/undead
	announceWhen = 25
	var/spawn_prob = 19

/datum/round_event/undead/setup()
	if(events.holiday == "Halloween") // Hi
		startWhen = 200		// Have a happy halloween
		announceWhen = 225		// <3
		var/datum/round_event/electrical_storm/ES = new()
		ES.lightsoutAmount = 3

		spawn_prob = 45

/datum/round_event/undead/announce()
	for(var/mob/M in player_list)
		M << "You feel [pick("a chill","uneasy","disturbed","afraid","confused")]!"

/datum/round_event/undead/start()
	for(var/area/A)
		if(!A.luminosity && !A.space_lighting) // only set to zero on unlit subareas
			var/list/turfs = list()
			for(var/turf/T in A)
				if(locate(/mob/living) in T) continue
				var/nope = 0
				for(var/obj/O in T)
					if(O.density)
						nope = 1
						break
				if(nope)
					continue
				turfs += T
			if(!turfs.len)
				continue
			do
				var/turf/T = pick_n_take(turfs)

				var/kind = pick(/mob/living/simple_animal/hostile/retaliate/skeleton,80;/mob/living/simple_animal/hostile/retaliate/zombie,60;/mob/living/simple_animal/hostile/retaliate/ghost)
				new kind(T)
			while(prob(spawn_prob) && turfs.len)
