//Janitors!  Janitors, janitors, janitors!


// Conspicuously not-recent versions of suspicious cleanables

/obj/effect/decal/cleanable/blood/old
	name = "dried blood"
	desc = "Looks like it's been here a while.  Eew."
	New()
		..()
		icon *= "#505050"

/obj/effect/decal/cleanable/blood/gibs/old
	name = "old rotting gibs"
	desc = "Oh god, why didn't anyone clean this up?  It smells terrible."
	New()
		..()
		icon *= "#90a060"

/obj/effect/decal/cleanable/vomit/old
	name = "crusty dried vomit"
	desc = "You try not to look at the chunks, and fail."
	New()
		..()
		icon *= "#90a060"

/obj/effect/decal/cleanable/robot_debris/old
	name = "dusty robot debris"
	desc = "The untouched remains of technophobia from long ago."
	New()
		..()
		icon *= "#808080"


// If my understanding of functions defined in several places is correct, this will run after (or before) the similar function
// located in code/game/turfs/simulated/floor.dm

/turf/simulated/floor/New()
	..()
	MakeDirty()


// This code should do all the station-dirtying

/turf/simulated/floor/proc/MakeDirty()
	//..()
	if(prob(66) || usr) //usr check to prevent manually created floors from having dirt
		return			//prob() to keep the rate of creation down and do a fast exit

	// These look weird if you make them dirty
	if(istype(src,/turf/simulated/floor/carpet) || istype(src,/turf/simulated/floor/grass) || istype(src,/turf/simulated/floor/beach) || istype(src,/turf/simulated/floor/holofloor))
		return

	var/A = loc

				// zero dirt
	if(istype(A,/area/centcom) || istype(A,/area/holodeck) || istype(A,/area/library) || istype(A,/area/janitor) || istype(A,/area/chapel) || istype(A,/area/mine/explored) || istype(A,/area/mine/unexplored) || istype(A,/area/solar) || istype(A,/area/atmos))
		return

				// high dirt - 1/3
	if(istype(A,/area/toxins/test_area) || istype(A,/area/mine/production) || istype(A,/area/mine/living_quarters) || istype(A,/area/mine/north_outpost) || istype(A,/area/mine/west_outpost) || istype(A,/area/wreck) || istype(A,/area/derelict) || istype(A,/area/djstation))
		new/obj/effect/decal/cleanable/dirt(src) // vanilla, but it works
		return


	if(prob(80))// mid dirt  - 1/15
		return


	if(istype(A,/area/engine) || istype(A,/area/assembly) || istype(A,/area/maintenance) || istype(A,/area/construction))
	 	// Blood, sweat, and oil.  Oh, and dirt.
		if(prob(5))
			new/obj/effect/decal/cleanable/blood/old(src)
		else
			if(prob(55))
				if(prob(5))
					new/obj/effect/decal/cleanable/robot_debris/old(src)
				else
					new/obj/effect/decal/cleanable/oil(src)
			else
				new/obj/effect/decal/cleanable/dirt(src)
		return

	if(istype(A,/area/crew_quarters/toilet) || istype(A,/area/crew_quarters/locker/locker_toilet) || istype(A,/area/crew_quarters/bar))
		if(prob(60))
			if(prob(70))
				new/obj/effect/decal/cleanable/vomit/old(src)
			else
				new/obj/effect/decal/cleanable/blood/old(src)
		else
			new/obj/effect/decal/cleanable/dirt(src)
		return

	if(istype(A,/area/quartermaster))
		if(prob(75))
			new/obj/effect/decal/cleanable/dirt(src)
		else
			new/obj/effect/decal/cleanable/oil(src)
		return



	if(prob(75))// low dirt  - 1/60
		return



	if(istype(A,/area/turret_protected) || istype(A,/area/security)) // chance of incident
		if(prob(25))
			if(prob(10))
				new/obj/effect/decal/cleanable/blood/gibs/old(src)
			else
				new/obj/effect/decal/cleanable/blood/old(src)
		else
			new/obj/effect/decal/cleanable/dirt(src)
		return


	if(istype(A,/area/crew_quarters/kitchen)) // Kitchen messes
		if(prob(60))
			if(prob(50))
				new/obj/effect/decal/cleanable/egg_smudge(src)
			else
				new/obj/effect/decal/cleanable/flour(src)
		else
			if(prob(33))
				new/obj/effect/decal/cleanable/dirt(src)
			else
				new/obj/effect/decal/cleanable/blood/old(src)
		return

	if(istype(A,/area/medical)) // Kept clean, but chance of blood
		if(prob(66))
			if(prob(10))
				new/obj/effect/decal/cleanable/blood/gibs/old(src)
			else
				new/obj/effect/decal/cleanable/blood/old(src)
		else
			if(prob(40))
				if(istype(A,/area/medical/morgue))
					new/obj/item/weapon/ectoplasm(src)
				else
					new/obj/effect/decal/cleanable/vomit/old(src)
			else
				new/obj/effect/decal/cleanable/dirt(src)
		return
	if(istype(A,/area/toxins))
		if(prob(80))
			new/obj/effect/decal/cleanable/dirt(src)
		else
			new/obj/effect/decal/cleanable/greenglow(src) // this cleans itself up but it might startle you when you see it.
		return

	//default
	new/obj/effect/decal/cleanable/dirt(src)
	return

