// ARTIFACT METEORS -- Collen

/datum/round_event_control/meteor_wave/artifact
	name = "Artifact Meteor"
	typepath = /datum/round_event/meteor_wave/artifact
	weight = 50 // This value needs some tweaking, not really sure what to put it at.
	max_occurrences = 5
	earliest_start = 0
	alertadmins = 1

/datum/round_event/meteor_wave/artifact
	startWhen		= 1
	endWhen			= 2
	announceWhen	= 0

/datum/round_event/meteor_wave/artifact/announce()
	return

/datum/round_event/meteor_wave/artifact/start()
	spawn_meteors(1, artifactMeteor)

/datum/round_event/meteor_wave/artifact/tick()
	return