/datum/round_event_control/falsealarm
	name 			= "False alarm"
	typepath 		= /datum/round_event/falsealarm
	weight			= 9
	max_occurrences = 5

/datum/round_event/falsealarm
	announceWhen	= 0
	endWhen			= 1
	announce()
		var/datum/round_event_control/E = pick(events.control)
		world.log << "False alarm: [E.typepath]"
		var/datum/round_event/Event = new E.typepath()
		Event.kill() 		// do not process this event - no starts, no ticks, no ends
		Event.announce() 	// just announce it like it's happening
