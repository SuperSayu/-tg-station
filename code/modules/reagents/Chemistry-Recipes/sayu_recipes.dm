//Bluespace
/datum/chemical_reaction/slimeteleport
	name = "Slime Teleport"
	id = "m_tele"
	result = null
	required_reagents = list("mutagen" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slimeteleport/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/y_distance = rand(-10,10) * created_volume
	var/x_distance = rand(-10,10) * created_volume
	var/turf/FROM = get_turf(holder.my_atom) // the turf of origin we're travelling FROM
	var/turf/TO = locate(FROM.x + x_distance,FROM.y + y_distance,FROM.z)          // the turf of origin we're travelling TO
	playsound(TO, 'sound/effects/phasein.ogg', 100, 1)

	var/list/flashers = list()
	for(var/mob/living/carbon/human/H in viewers(TO, null))
		if(H.flash_eyes())
			flashers += H


	var/t_range = rand(0,2) * created_volume
	for (var/atom/movable/A in range(t_range, FROM )) // iterate thru list of mobs in the area
		if( A.anchored ) continue
		if(istype(A, /obj/item/device/radio/beacon)) continue // don't teleport beacons because that's just insanely stupid
		if(istype(A, /obj/effect/portal)) continue

		var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place

		if(!newloc || prob(10)) // If it goes off the edge of the map / is in any way invalid, or with some probability
			var/obj/effect/portal/P = new /obj/effect/portal( A.loc )
			P.target = newloc
			P.creator = null
			P.icon = 'icons/obj/objects.dmi'
			P.icon_state = "anom"
			P.name = "wormhole"
			walk_rand(P,rand(150,450)) // values larger than 300 mean it won't walk at all before it deletes itself

		if(!A.Move(newloc)) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
			A.loc = newloc

		spawn()
			if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
				var/mob/M = A
				if(M.client)
					var/obj/blueeffect = new /obj(src)
					blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
					blueeffect.icon = 'icons/effects/effects.dmi'
					blueeffect.icon_state = "shieldsparkles"
					blueeffect.layer = 17
					blueeffect.mouse_opacity = 0
					M.client.screen += blueeffect
					sleep(50)
					M.client.screen -= blueeffect
					blueeffect.loc = null