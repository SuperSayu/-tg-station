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