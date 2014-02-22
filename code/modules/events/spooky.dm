/datum/round_event_control/ghosts
	name				= "Ghost Migration"
	typepath			= /datum/round_event/ghosts
	weight				= 10
	earliest_start		= 6000
	max_occurrences		= 2
	minimumCrew			= 4

/datum/round_event/ghosts
	announceWhen	= 40

/datum/round_event/ghosts/setup()
	announceWhen = rand(30, 90)

/datum/round_event/ghosts/announce()
	command_alert("Unknown quasi-aetheric entities have been detected near [station_name()], please stand-by.", "Lifesign Alert?")


/datum/round_event/ghosts/start()
	for(var/obj/effect/landmark/C in landmarks_list)
		if((C.name == "blobstart" || C.name == "xeno_spawn"))
			var/mob/living/simple_animal/hostile/M = new /mob/living/simple_animal/hostile/retaliate/ghost(C.loc)
			spawn()
				for(var/i in 1 to 20)
					if(M.target) break
					step_rand(M)
					var/mob/P = pick(player_list)
					if(P.z == M.z)
						step_towards(M,P) // spooky... sorta
					sleep(10)