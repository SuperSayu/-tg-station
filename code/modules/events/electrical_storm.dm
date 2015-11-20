/datum/round_event_control/electrical_storm
	name 			= "Electrical Storm"
	typepath 		= /datum/round_event/electrical_storm
	earliest_start	= 6000
	weight 			= 40
	alertadmins = 0
	minimumCrew		= 3

/datum/round_event/electrical_storm
	var/lightsoutAmount	= 1
	var/lightsoutRange	= 25
	announceWhen	= 1

/datum/round_event/electrical_storm/announce()
	priority_announce("An electrical storm has been detected in your area, please repair potential electronic overloads.", "Electrical Storm Alert")

/datum/round_event/electrical_storm/start()
	lightsoutAmount = pick(1,2)
	var/list/epicentreList = list()
	var/list/possibleEpicentres = list()

	for(var/obj/effect/landmark/newEpicentre in landmarks_list)
		if(newEpicentre.name == "lightsout" && !(newEpicentre in epicentreList))
			possibleEpicentres += newEpicentre
	while(possibleEpicentres.len && epicentreList.len < lightsoutAmount)
		epicentreList += pick_n_take(possibleEpicentres)

	if(!epicentreList.len)
		return

	for(var/obj/effect/landmark/epicentre in epicentreList)
		for(var/obj/machinery/power/apc/apc in ultra_range(lightsoutRange, epicentre))
			apc.overload_lighting()
