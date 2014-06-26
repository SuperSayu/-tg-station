/*
	Station secrets randomizer
*/
/obj/effect/landmark/secrets
	name = "secret loot spawnpoint"

/proc/distribute_secrets()
	var/list/secret_points = list()
	for(var/obj/effect/landmark/secrets/S)
		secret_points += S.loc
		del S

	var/turf/T = pick_n_take(secret_points)
	new /obj/effect/decal/remains/human(T)
	new /obj/item/clothing/under/rank/det(T)
	new /obj/item/clothing/tie/medal/silver/valor(T)
	new /obj/item/device/detective_scanner(T)
	new /obj/item/weapon/butch{name = "rusty cleaver"}(T)

	T = pick_n_take(secret_points)
	new /obj/structure/closet/crate/secure/chemicals{locked=0}(T)

	T = pick_n_take(secret_points)
	new /obj/item/robot_parts/robot_suit(T)

	if(prob(25))
		T = pick_n_take(secret_points)
		new /obj/item/weapon/storage/belt/bluespace(T)