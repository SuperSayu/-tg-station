/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	layer = 2.1
	anchored = 1

/obj/effect/decal/cleanable/crayon/New(location,main = "#FFFFFF", var/type = "rune")
	..()
	loc = location

	name = type
	desc = "A [type] drawn in crayon."

	switch(type)
		if("rune")
			type = "rune[rand(1,6)]"
		if("graffiti")
			type = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa")
			icon_state = type
			color = main

/obj/effect/decal/cleanable/body
	name = "body marking"
	desc = "It shows the area where a body was..."
	icon = 'icons/effects/effects.dmi'
	icon_state = "body-"
	layer = 2.1
	anchored = 1

/obj/effect/decal/cleanable/body/New()
	..()
	if(src.loc && isturf(src.loc))
		for(var/obj/effect/decal/cleanable/body/B in src.loc)
			if(B != src)
				del(B)
