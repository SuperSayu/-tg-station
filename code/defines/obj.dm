/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		switch(alert("Travel back to ss13?",,"Yes","No"))
			if("Yes")
				if(user.z != src.z)	return
				user.forceMove(pick(latejoin))
			if("No")
				return

/obj/structure/signpost/antag
	name = "Directions to Evil"
	attack_hand(mob/user as mob)
		switch(input("Pick destination") as null|anything in list("Wizard","Syndicate","Space Station"))
			if(null) return
			if("Space Station")
				user.forceMove(pick(latejoin))
				return
			if("Wizard")
				if(wizardstart.len)
					user.forceMove(pick(wizardstart))
					new /obj/effect/knowspell/self/teleport/limited{chargemax = 1}(user.loc) // spawns a teleport scroll with limited uses
					return
			if("Syndicate")
				// this is complicated by the fact that other sandbox users may have moved the shuttle,
				// so I cannot use syndicate start locations (off the shuttle).
				for(var/obj/effect/landmark/L in landmarks_list)
					if(L.name == "syndicate teleporter")
						user.forceMove(L.loc)
						new /obj/item/weapon/card/id/syndicate(user.loc)
						return
		var/static/c = pick("yellow","salmon","frost white","forest green","sky blue","rose pink","diamond","translucent mauve", "effervescent brown")
		visible_message("The [c] 'map error' light on the wooden signpost blinks mysteriously.") // have fun kids

/*
/obj/effect/mark
	var/mark = ""
	icon = 'icons/misc/mark.dmi'
	icon_state = "blank"
	anchored = 1
	layer = 99
	mouse_opacity = 0
	unacidable = 1//Just to be sure.
*/
/obj/effect/beam
	name = "beam"
	unacidable = 1//Just to be sure.
	var/def_zone
	pass_flags = PASSTABLE

/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/structure/showcase
	name = "showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1
	unacidable = 1//temporary until I decide whether the borg can be removed. -veyveyr

/obj/structure/showcase/fakeid
	name = "Centcom Identification Console"
	desc = "You can use this to change ID's."
	icon = 'icons/obj/computer.dmi'
	icon_state = "id"

/obj/structure/showcase/fakesec
	name = "Centcom Security Records"
	desc = "Used to view and edit personnel's security records"
	icon = 'icons/obj/computer.dmi'
	icon_state = "security"

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/item/weapon/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = 0
	anchored = 0
	w_class = 1.0
	force = 0.0
	throwforce = 0.0
	throw_speed = 2
	throw_range = 7
	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		user.drop_item()
		src.throw_at(target, throw_range, throw_speed)

/obj/effect/spawner
	name = "object spawner"
