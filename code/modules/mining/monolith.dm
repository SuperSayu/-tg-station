var/global/list/monolith_names = list("Alpha","Beta","Gamma","Delta","Epsilon","Iota","Sigma","Phi","Omega")
var/global/list/monoliths = list()

/obj/structure/monolith
	name = "Monolith"
	desc = "A strange structure made of adamantine."
	icon = 'icons/obj/mining2.dmi'
	icon_state = "monolith0"
	density = 1
	anchored = 1.0
	luminosity = 2
	layer = 5
	var/activated = 0
	var/letter
	var/makeart = 1

/obj/structure/monolith/New()
	letter = pick_n_take(monolith_names)
	name += " [letter]"
	monoliths += src
	for(var/turf/simulated/wall/W in range(1,src))
		new /turf/simulated/floor/engine/cult(W)
	for(var/turf/simulated/mineral/M in range(1,src))
		new /turf/simulated/floor/engine/cult(M)
	SetLuminosity(2)

/obj/structure/monolith/proc/make_artifact()
	var/turf/artloc = get_turf(src)
	var/obj/item/artifact/art = new /obj/item/artifact(artloc)
	art.x += pick(-1,1)
	art.y += pick(-1,1)
	//world << "<b>[name] SPAWNED [x],[y],[z]</b>"

/obj/structure/monolith/attackby(obj/item/I, mob/user as mob)
	if(istype(I, /obj/item/device/mining_scanner) ||istype(I,/obj/item/device/t_scanner/adv_mining_scanner) || istype(I,/obj/item/device/analyzer))
		if(!activated)
			user << "<span class='notice'><b>With a flash of light, the Monolith springs to life at your touch, humming gently.</b></span>"
			activated = 1
			icon_state = "monolith1"
			playsound(get_turf(src), 'sound/effects/phasein.ogg', 100, 1)
			for(var/mob/living/carbon/human/H in viewers(src, null))
				H.flash_eyes()
			SetLuminosity(4)
		else
			var/list/selection = list()
			for(var/obj/structure/monolith/M in monoliths)
				if(M.activated)
					selection += M
			if(selection.len < 2)
				user << "<span class='danger'>There aren't any other active monoliths to travel to!</span>"
				return
			var/obj/structure/target = input("Please select a monolith to travel to.", "Monolith") in selection
			playsound(get_turf(src), 'sound/effects/phasein.ogg', 100, 1)
			for(var/obj/O in range(1,src))
				if(!O.anchored)
					var/offset_x = (src.x - O.x)
					var/offset_y = (src.y - O.y)
					do_teleport(O,get_turf(locate((target.x-offset_x),(target.y-offset_y),target.z)))
			for(var/mob/M in range(1,src))
				if(!M.anchored)
					var/offset_x = (src.x - M.x)
					var/offset_y = (src.y - M.y)
					do_teleport(M,get_turf(locate((target.x-offset_x),(target.y-offset_y),target.z)))
	else
		..()