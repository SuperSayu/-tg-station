/datum/round_event_control/energetic_flux
	name 			= "Radiation Flux"
	typepath 		= /datum/round_event/radiation_flux
	max_occurrences = 2
	weight 			= 5
	minimumCrew		= 5

/datum/round_event_control/energetic_flux/pota
	name 			= "Planet of the Apes Radiation Flux"
	typepath 		= /datum/round_event/radiation_flux/pota
	max_occurrences = 2
	weight 			= 5
	minimumCrew		= 5

/datum/round_event_control/energetic_flux/ffour
	name 			= "Fantastic Four Radiation Flux"
	typepath 		= /datum/round_event/radiation_flux/ffour
	max_occurrences = 2
	weight 			= 5
	minimumCrew		= 5


/datum/round_event/radiation_flux
	announceWhen	= 7
	startWhen		= 21
	var/area/impact_area
	var/max_range = 10
	var/min_rad = 25
	var/max_rad = 125

/datum/round_event/radiation_flux/setup()
	var/list/safe_areas = list(
	/area/turret_protected/ai,
	/area/turret_protected/ai_upload,
	/area/engine,
	/area/solar,
	/area/holodeck,
	/area/shuttle/arrival,
	/area/shuttle/escape/station,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/shuttle/mining/station,
	/area/shuttle/transport1/station,
	/area/shuttle/prison/station,
	/area/shuttle/specops/station)

	impact_area = locate(pick(the_station_areas - safe_areas))	//need to locate() as it's just a list of paths.
	startWhen = rand(14,35)

/datum/round_event/radiation_flux/announce()
	command_alert("Warning! Abnormal radiation detected on long range scanners.  Likely affected area: [impact_area.name]. Vacate [impact_area.name].", "Anomaly Alert")


/datum/round_event/radiation_flux/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	var/list/region = range(max_range,T)
	var/list/candidates = list()
	for(var/mob/living/M in region)
		candidates += M
	while(candidates.len)
		var/mob/M = pick(candidates)
		candidates -= M
		if(irradiate(M))
			break
	for(var/obj/machinery/M in region)
		if(prob(15))
			M.emp_act(1) // light emp

/datum/round_event/radiation_flux/proc/irradiate(var/mob/living/M)
	M.apply_effect(rand(min_rad,max_rad),IRRADIATE)
	return 0

/datum/round_event/radiation_flux/proc/rad_armorcheck(var/mob/living/M, var/multiplier = 0.5)
	var/armor = M.getarmor(null,"rad")
	var/probability = (100 - armor) * multiplier
	return prob(probability)

/datum/round_event/radiation_flux/pota
	max_range = 8
	min_rad = 50
	max_rad = 100

/datum/round_event/radiation_flux/pota/irradiate(var/mob/M)
	..()
	if(!M.stat && (istype(M,/mob/living/carbon/human) || istype(M,/mob/living/carbon/monkey)) && !rad_armorcheck(M))
		var/mob/living/carbon/C = M
		if(!C.dna) return

		C.dna.struc_enzymes = setblock(C.dna.struc_enzymes, RACEBLOCK, construct_block(!istype(C,/mob/living/carbon/monkey)+1, 2))
		var/time = rand(1,10)
		C.emote("collapse")
		C.apply_effect(time,WEAKEN)
		spawn(time)
			if(C != null)
				domutcheck(C,null,1)
	return 0

/datum/round_event/radiation_flux/ffour
	max_range = 8
	var/list/powers

/datum/round_event/radiation_flux/ffour
	start()
		powers = list(FIREBLOCK,TELEBLOCK,HULKBLOCK,XRAYBLOCK)
		..()

/datum/round_event/radiation_flux/ffour/irradiate(var/mob/M)
	..()
	if(powers.len && (istype(M,/mob/living/carbon/human) || istype(M,/mob/living/carbon/monkey)) && !rad_armorcheck(M))
		var/mob/living/carbon/C = M
		if(!C.dna) return
		var/powerblock = pick(powers)
		powers -= powerblock

		C.dna.struc_enzymes = setblock(C.dna.struc_enzymes, powerblock, "FFF")
		var/time = rand(1,10)
		C.emote("collapse")
		C.apply_effect(time,WEAKEN)
		spawn(time)
			if(C != null)
				domutcheck(C,null,1)