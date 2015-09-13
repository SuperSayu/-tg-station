/*
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
	*/

	/*
	this was in carbon

	/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(src.nutrition && src.stat != 2)
			src.nutrition -= HUNGER_FACTOR/10
			if(src.m_intent == "run")
				src.nutrition -= HUNGER_FACTOR/10
		if((src.disabilities & FAT) && src.m_intent == "run" && src.bodytemperature <= 360)
			src.bodytemperature += 2
	if(trail > 0 && prob(40))
		var/obj/effect/decal/cleanable/trail/t
		switch(trailtype)
			if("blood")
				if(istype(src, /mob/living/carbon/human))
					t = new /obj/effect/decal/cleanable/trail/bloodtrail(src.loc)
				if(istype(src, /mob/living/carbon/monkey))
					t = new /obj/effect/decal/cleanable/trail/bloodtrail/paw(src.loc)
				if(istype(src, /mob/living/carbon/alien/humanoid))
					t = new /obj/effect/decal/cleanable/trail/bloodtrail/xeno(src.loc)
			if("oil")
				if(istype(src, /mob/living/carbon/human))
					t = new /obj/effect/decal/cleanable/trail/oiltrail(src.loc)
				if(istype(src, /mob/living/carbon/monkey))
					t = new /obj/effect/decal/cleanable/trail/oiltrail/paw(src.loc)
				if(istype(src, /mob/living/carbon/alien/humanoid))
					t = new /obj/effect/decal/cleanable/trail/oiltrail/xeno(src.loc)
			if("xeno")
				if(istype(src, /mob/living/carbon/human))
					t = new /obj/effect/decal/cleanable/trail/xenotrail(src.loc)
				if(istype(src, /mob/living/carbon/monkey))
					t = new /obj/effect/decal/cleanable/trail/xenotrail/paw(src.loc)
				if(istype(src, /mob/living/carbon/alien/humanoid))
					t = new /obj/effect/decal/cleanable/trail/xenotrail/xeno(src.loc)
		if(t)
			t.dir = src.dir
			t.alpha = min(224,trail*32 + pick(64,32,16,0,0,-16,-32,-64))
			if(t.alpha <= 0)
				t.alpha = 16
			if(t.alpha <= 64)
				spawn(300)
					if(t) t.alpha /= 2
			if(t.alpha <= 32)
				spawn(600)
					if(t) del t
			if(t.loc && isturf(t.loc))
				for(var/obj/effect/decal/cleanable/trail/T in src.loc)
					if(T.dir == t.dir && T != t)
						del(T)
		trail--
	*/