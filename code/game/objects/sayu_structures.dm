/obj/structure/signpost/antag
	name = "Directions to Evil"

/obj/structure/signpost/antag/attack_hand(mob/user as mob)
	switch(input("Pick destination") as null|anything in list("Wizard","Syndicate","Space Station"))
		if(null) return
		if("Space Station")
			if(user.z != src.z)	return
			user.loc.loc.Exited(user)
			user.forceMove(pick(latejoin))
			return
		if("Wizard")
			if(wizardstart.len)
				if(user.z != src.z)	return
				user.loc.loc.Exited(user)
				user.forceMove(pick(wizardstart))
				new /obj/effect/knowspell/self/teleport/limited{chargemax = 1}(user.loc) // spawns a teleport scroll with limited uses
				return
		if("Syndicate")
			// this is complicated by the fact that other sandbox users may have moved the shuttle,
			// so I cannot use syndicate start locations (off the shuttle).
			for(var/obj/effect/landmark/L in landmarks_list)
				if(L.name == "Syndicate-Teleporter")
					if(user.z != src.z)	return
					user.loc.loc.Exited(user)
					user.forceMove(L.loc)
					new /obj/item/weapon/card/id/syndicate(user.loc)
					return
	var/static/c = pick("yellow","salmon","frost white","forest green","sky blue","rose pink","diamond","translucent mauve", "effervescent brown")
	visible_message("The [c] 'map error' light on the wooden signpost blinks mysteriously.") // have fun kids