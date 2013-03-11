/datum/event_control/falsealarm
	name 			= "False alarm"
	typepath 		= /datum/event/falsealarm
	weight			= 9
	max_occurrences = 5

/datum/event/falsealarm
	announceWhen	= 0
	endWhen			= 1
	announce()
		var/datum/event_control/E = pick(events.control)
		world.log << "False alarm: [E.typepath]"
		var/datum/event/Event = new E.typepath()
		Event.kill() 		// do not process this event - no starts, no ticks, no ends
		Event.announce() 	// just announce it like it's happening
