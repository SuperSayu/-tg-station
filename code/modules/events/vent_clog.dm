/datum/event_control/vent_clog
	name = "Clogged Vents"
	typepath = /datum/event/vent_clog
	weight = 40
	max_occurrences = 50

/datum/event/vent_clog
	announceWhen	= 0
	startWhen		= 5
	endWhen			= 30
	var/interval 	= 2
	var/list/vents  = null

/datum/event/vent_clog/announce()
	command_alert("The scrubbers network is experiencing a backpressure surge.  Some ejection of contents may occur.", "Atmospherics alert")


/datum/event/vent_clog/setup()
	endWhen = rand(25,100)
	vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/temp_vent in world)
		if(temp_vent.loc.z == 1 && temp_vent.network)
			if(temp_vent.network.normal_members.len > 50)
				vents += temp_vent

/datum/event/vent_clog/tick()
	if((activeFor%interval)==0 && prob(95))
		var/obj/vent = pick_n_take(vents)

		var/global/list/gunk = list("water","carbon","flour","radium","toxin","cleaner","nutriment","condensedcapsaicin","psilocybin","plantbgone",
									"banana","nothing","anti_toxin","space_drugs","adminordrazine","hyperzine","holywater","ethanol","hot_coco")
		var/datum/reagents/R = new/datum/reagents(50)
		R.my_atom = vent
		R.add_reagent(pick(gunk),50)

		var/datum/effect/effect/system/chem_smoke_spread/smoke = new
		smoke.set_up(R,rand(1,2),0,vent,0,silent=1)
		playsound(vent.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		smoke.start()
		del R
