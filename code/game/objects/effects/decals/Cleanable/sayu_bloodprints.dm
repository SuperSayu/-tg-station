/obj/effect/decal/cleanable/trail
	icon = 'icons/effects/footprints.dmi'
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	alpha = 192

/obj/effect/decal/cleanable/trail/bloodtrail
	name = "bloody footprints"
	desc = "Look, Pheonix, they're leading away from the crime scene!"
	icon_state = "blood2"

/obj/effect/decal/cleanable/trail/bloodtrail/paw
	name = "bloody pawprints"
	desc = "Perhaps it's a miniature Bigfoot?"
	icon_state = "bloodpaw2"

/obj/effect/decal/cleanable/trail/bloodtrail/xeno
	name = "bloody clawprints"
	desc = "The hunt is on!"
	icon_state = "bloodclaw2"

/obj/effect/decal/cleanable/trail/oiltrail
	name = "oily footprints"
	desc = "Look at what pollution has wrought."
	icon_state = "oil2"

/obj/effect/decal/cleanable/trail/oiltrail/paw
	name = "oily pawprints"
	desc = "Somewhere, Space PETA is having a fit."
	icon_state = "oilpaw2"

/obj/effect/decal/cleanable/trail/oiltrail/xeno
	name = "oily clawprints"
	desc = "Quick, set it on fire!"
	icon_state = "oilclaw2"

/obj/effect/decal/cleanable/trail/xenotrail
	name = "green bloody footprints"
	desc = "A satisfying end to the xeno menace."
	icon_state = "xeno2"

/obj/effect/decal/cleanable/trail/xenotrail/paw
	name = "green bloody pawprints"
	desc = "Maybe they're in cahoots?"
	icon_state = "xenopaw2"

/obj/effect/decal/cleanable/trail/xenotrail/xeno
	name = "green bloody clawprints"
	desc = "Somewhere out there is one pissed off xeno."
	icon_state = "xenoclaw2"

/obj/effect/decal/cleanable/blood/Crossed(var/atom/movable/AM)  //why is blood not OOP
	if(printamount <= 0)
		return
	var/amount = min(rand(4,8), printamount)

	if(iscarbon(AM))
		if(sayu_footprint_helper(AM, amount, "blood"))
			printamount -= amount

/obj/effect/decal/cleanable/xenoblood/Crossed(var/atom/movable/AM)
	if(printamount <= 0)
		return
	var/amount = min(rand(4,8), printamount)

	if(iscarbon(AM))
		if(sayu_footprint_helper(AM, amount, "xeno"))
			printamount -= amount

/obj/effect/decal/cleanable/oil/Crossed(var/atom/movable/AM)
	if(printamount <= 0)
		return
	var/amount = min(rand(4,8), printamount)

	if(iscarbon(AM))
		if(sayu_footprint_helper(AM, amount, "oil"))
			printamount -= amount

/proc/sayu_footprint_helper(var/mob/living/carbon/C, var/amount, var/type)
	if(isslime(C))
		return 0

	switch(type)
		if("xeno")
			C.trail = amount
			C.trailtype = "xeno"
			return 1

		if("blood")
			C.trail = amount
			C.trailtype = "blood"
			return 1

		if("oil")
			C.trail = amount
			C.trailtype = "oil"
			return 1

	return 0