/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/obj/rune.dmi'
	layer = 2.1
	anchored = 1


	examine()
		set src in view(2)
		..()
		return


	New(location,main = "#FFFFFF",shade = "#000000",var/type = "rune")
		..()
		loc = location

		name = type
		desc = "A [type] drawn in crayon."

		switch(type)
			if("rune")
				type = "rune[rand(1,6)]"
			if("graffiti")
				type = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa")

		var/icon/mainOverlay = new/icon('icons/effects/crayondecal.dmi',"[type]",2.1)
		var/icon/shadeOverlay = new/icon('icons/effects/crayondecal.dmi',"[type]s",2.1)

		mainOverlay.Blend(main,ICON_ADD)
		shadeOverlay.Blend(shade,ICON_ADD)

		overlays += mainOverlay
		overlays += shadeOverlay

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

/obj/effect/decal/cleanable/body/proc/Color(var/bodycolor)
	icon_state += bodycolor