
/turf/simulated/floor/plating/glass
	name = "glass plating"
	icon = 'icons/turf/sayu_floors.dmi'
	icon_state = "glassplating"
	icon_plating = "glassplating"
	floor_tile = null
	intact = 0
	lighting_lumcount = 2 // transparent floor

/turf/simulated/floor/plating/glass/New()
	..()
	underlays += image('icons/turf/space.dmi',icon_state = "[((x + y) ^ ~(x * y) + z) % 25]")

/turf/simulated/floor/plating/airless/glass
	name = "glass plating"
	icon = 'icons/turf/sayu_floors.dmi'
	icon_state = "glassplating"
	icon_plating = "glassplating"
	floor_tile = null
	intact = 0
	lighting_lumcount = 2 // transparent floor

/turf/simulated/floor/plating/airless/glass/New()
	..()
	underlays += image('icons/turf/space.dmi',icon_state = "[((x + y) ^ ~(x * y) + z) % 25]")
