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