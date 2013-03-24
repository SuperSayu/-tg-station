/datum/event_control/meteor_wave
	name			= "Meteor Wave"
	typepath		= /datum/event/meteor_wave
	weight			= 2
	max_occurrences = 3
	minimumCrew		= 5

/datum/event/meteor_wave
	startWhen		= 6
	endWhen			= 66

/datum/event/meteor_wave/announce()
	command_alert("Meteors have been detected on collision course with the station.", "Meteor Alert")
	world << sound('sound/AI/meteors.ogg')


/datum/event/meteor_wave/tick()
	if(IsMultiple(activeFor, 6))
		spawn_meteors(5)