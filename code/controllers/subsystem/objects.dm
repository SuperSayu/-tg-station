var/datum/subsystem/objects/SSobj

/datum/proc/process()
	set waitfor = 0
	SSobj.processing.Remove(src)
	return 0

/datum/subsystem/objects
	name = "Objects"
	priority = 12

	var/list/processing = list()
	var/list/burning = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize(timeofday, zlevel)

	if(!zlevel || zlevel == ZLEVEL_STATION)
		for(var/typekey in the_station_areas)
			if(ispath(typekey,/area/hallway/primary)) continue
			for(var/subtype in typesof(typekey))
				parse_area(locate(subtype))
		distribute_secrets()

	setupGenetics()
	for(var/atom/movable/AM in world)
		if (zlevel && AM.z != zlevel)
			continue
		AM.initialize()
	if (zlevel)
		return ..()
	for(var/turf/simulated/floor/F in world)
		F.MakeDirty()
	..()


/datum/subsystem/objects/stat_entry()
	..("P:[processing.len]")


/datum/subsystem/objects/fire()
	for(var/thing in SSobj.processing)
		if(thing)
			thing:process(wait)
			continue
		SSobj.processing.Remove(thing)
	for(var/obj/burningobj in SSobj.burning)
		if(burningobj && (burningobj.burn_state == 1))
			if(burningobj.burn_world_time < world.time)
				burningobj.burn()
		else
			SSobj.burning.Remove(burningobj)
