#define EMPTY 0
#define WIRED 1
#define READY 2

/obj/item/weapon/grenade/chem_grenade
	name = "grenade"
	desc = "A do it yourself grenade casing!"
	icon_state = "chemg"
	item_state = "flashbang"
	var/bomb_state = "chembomb"
	var/payload_name = null // used for spawned grenades
	w_class = 2
	force = 2
	var/stage = EMPTY
	var/list/beakers = list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle)
	var/affected_area = 3
	var/obj/item/device/assembly_holder/nadeassembly = null
	var/assemblyattacher
	var/label = null

/obj/item/weapon/grenade/chem_grenade/New()
	create_reagents(1000)
	if(payload_name)
		payload_name += " " // formatting, ignore me
	update_icon()


/obj/item/weapon/grenade/chem_grenade/examine(mob/user)
	display_timer = (stage == READY && !nadeassembly)	//show/hide the timer based on assembly state
	..()
	if(stage >= WIRED)
		if(nadeassembly)
			usr << nadeassembly.a_left.describe()
			usr << nadeassembly.a_right.describe()


/obj/item/weapon/grenade/chem_grenade/proc/get_trigger()
	if(!nadeassembly) return null
	for(var/obj/O in list(nadeassembly.a_left, nadeassembly.a_right))
		if(!O || istype(O,/obj/item/device/assembly/igniter)) continue
		return O
	return null


/obj/item/weapon/grenade/chem_grenade/proc/update_overlays()
	underlays = list()
	if(nadeassembly)
		underlays += "[nadeassembly.a_left.icon_state]_left"
		for(var/O in nadeassembly.a_left.attached_overlays)
			underlays += "[O]_l"
		underlays += "[nadeassembly.a_right.icon_state]_right"
		for(var/O in nadeassembly.a_right.attached_overlays)
			underlays += "[O]_r"

/obj/item/weapon/grenade/chem_grenade/update_icon()
	if(nadeassembly)
		icon = 'icons/obj/assemblies/new_assemblies.dmi'
		icon_state = bomb_state
		update_overlays()
		var/obj/item/device/assembly/A = get_trigger()
		if(stage != READY)
			name = "bomb casing[label]"
		else
			if(!A)
				name = "[payload_name]de-fused bomb[label]" // this should not actually happen
			else
				name = payload_name + A.bomb_name + label // time bombs, remote mines, etc
	else
		icon = 'icons/obj/grenade.dmi'
		icon_state = initial(icon_state)
		overlays = list()
		switch(stage)
			if(EMPTY)
				name = "grenade casing[label]"
			if(WIRED)
				icon_state += "_ass"
				name = "grenade casing[label]"
			if(READY)
				if(active)
					icon_state += "_active"
				else
					icon_state += "_locked"
				name = payload_name + "grenade" + label


/obj/item/weapon/grenade/chem_grenade/attack_self(mob/user)
	if(stage == READY &&  !active)
		if(nadeassembly)
			nadeassembly.attack_self(user)
			update_icon()
		else if(clown_check(user))
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			message_admins("[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]).")
			user << "<span class='warning'>You prime the [name]! [det_time / 10] second\s!</span>"
			active = 1
			update_icon()
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			spawn(det_time)
				prime()


/obj/item/weapon/grenade/chem_grenade/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/weapon/hand_labeler))
		var/obj/item/weapon/hand_labeler/HL = I
		if(length(HL.label))
			label = " ([HL.label])"
			return 0
		else
			if(label)
				label = null
				update_icon()
				user << "You remove the label from [src]."
				return 1
	if(istype(I, /obj/item/weapon/screwdriver))
		if(stage == WIRED)
			if(beakers.len)
				stage_change(READY)
				user << "<span class='notice'>You lock the [initial(name)] assembly.</span>"
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, -3)
				update_icon()
				var/contained = ""
				var/cores = ""
				for(var/obj/O in beakers)
					if(!O.reagents) continue
					if(istype(O,/obj/item/slime_extract))
						cores += " [O]"
					for(var/reagent in O.reagents.reagent_list)
						contained += " [reagent] "
				if(contained)
					if(cores)
						contained = "\[[cores];[contained]\]"
					else
						contained = "\[[contained]\]"
				var/turf/bombturf = get_turf(loc)
				var/area/A = bombturf.loc
				var/log_str = "[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has completed [name] at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a> [contained]."
				message_admins(log_str)
				log_game(log_str)
			else
				user << "<span class='notice'>You need to add at least one beaker before locking the [initial(name)] assembly.</span>"
		else if(stage == READY && !nadeassembly)
			det_time = det_time == 50 ? 30 : 50	//toggle between 30 and 50
			user << "<span class='notice'>You modify the time delay. It's set for [det_time / 10] second\s.</span>"
		else if(stage == EMPTY)
			user << "<span class='notice'>You need to add an activation mechanism.</span>"

	else if(stage == WIRED && is_type_in_list(I, allowed_containers))
		if(beakers.len == 2)
			user << "<span class='notice'>[src] can not hold more containers.</span>"
			return
		else
			if(I.reagents.total_volume)
				user << "<span class='notice'>You add [I] to the [initial(name)] assembly.</span>"
				user.drop_item()
				I.loc = src
				beakers += I
			else
				user << "<span class='notice'>[I] is empty.</span>"

	else if(stage == EMPTY && istype(I, /obj/item/device/assembly_holder))
		var/obj/item/device/assembly_holder/A = I
		if(!A.secured)
			return
		if(isigniter(A.a_left) == isigniter(A.a_right))	//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
			return

		user.drop_item()
		nadeassembly = A
		A.master = src
		A.loc = src
		assemblyattacher = user.ckey

		stage_change(WIRED)
		user << "<span class='notice'>You add [A] to [src]!</span>"
		update_icon()

	else if(stage == EMPTY && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if (C.use(1))
			det_time = 50 // In case the cable_coil was removed and readded.
			stage_change(WIRED)
			user << "<span class='notice'>You rig the [initial(name)] assembly.</span>"
		else
			user << "<span class='warning'>You need one length of coil to wire the assembly.</span>"
			return

		update_icon()
	else if(stage == READY && istype(I, /obj/item/weapon/wirecutters))
		user << "<span class='notice'>You unlock the assembly.</span>"
		stage_change(WIRED)
		update_icon()

	else if(stage == WIRED && istype(I, /obj/item/weapon/wrench))

		payload_name = null
		label = null
		if(nadeassembly)
			nadeassembly.loc = get_turf(src)
			nadeassembly.master = null
			nadeassembly = null
		else // If "nadeassembly = null && stage == WIRED", then it most have been cable_coil that was used.
			new /obj/item/stack/cable_coil(get_turf(src),1)
		stage_change(EMPTY)
		user << "<span class='notice'>You remove the activation mechanism from the [initial(name)] assembly.</span>"
		update_icon()


/obj/item/weapon/grenade/chem_grenade/proc/stage_change(var/N)
	stage = N
	if (stage == EMPTY)
		name = "[initial(name)] casing"
		desc = initial(desc)
		icon_state = initial(icon_state)
	else if (stage == WIRED)
		name = "unsecured [initial(name)]"
		desc = "An unsecured [initial(name)] assembly."
		icon_state = "[initial(icon_state)]_ass"
	else if (stage == READY)
		name = initial(name)
		desc = "A custom made [initial(name)]."
		icon_state = "[initial(icon_state)]_locked"


//assembly stuff
/obj/item/weapon/grenade/chem_grenade/receive_signal()
	prime()

/obj/item/weapon/grenade/chem_grenade/HasProximity(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.HasProximity(AM)

/obj/item/weapon/grenade/chem_grenade/prime()
	if(stage != READY)
		return

	var/has_reagents
	for(var/obj/item/I in beakers)
		if(I.reagents.total_volume)
			has_reagents = 1

	if(!has_reagents)
		playsound(loc, 'sound/items/Screwdriver2.ogg', 50, 1)
		return

	if(nadeassembly)
		var/mob/M = get_mob_by_ckey(assemblyattacher)
		var/mob/last = get_mob_by_ckey(nadeassembly.fingerprintslast)
		var/turf/T = get_turf(src)
		var/area/A = get_area(T)
		var/attacher_spiel = " (spawned)"
		var/attacher_admin_spiel = ""
		var/last_spiel = " (none)"
		var/last_admin_spiel = ""
		if(M)
			attacher_spiel = ", attached by [M.key]/[M]"
			attacher_admin_spiel = "<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>(?)</A>"
		if(last)
			last_spiel = "[last.key]/[last]"
			last_admin_spiel = "<A HREF='?_src_=holder;adminmoreinfo=\ref[last]'>(?)</A>"
		message_admins("grenade primed by an assembly[attacher_spiel][attacher_admin_spiel] and last touched by [last_spiel][last_admin_spiel] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[A.name] (JMP)</a>.")
		log_game("grenade primed by an assembly[attacher_spiel] and last touched by [last_spiel] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at [A.name] ([T.x], [T.y], [T.z])")

	playsound(loc, 'sound/effects/bamf.ogg', 50, 1)

	update_mob()

	mix_reagents()
	del(nadeassembly) // do this now to stop infrared beams

	if(reagents.total_volume)	//The possible reactions didnt use up all reagents.
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

	var/list/viewable = view(affected_area, loc)
	var/list/accessible = can_flood_from(loc, affected_area)
	var/list/reactable = accessible
	var/mycontents = GetAllContents()
	for(var/turf/T in accessible)
		for(var/atom/A in T.GetAllContents())
			if(A in mycontents) continue
			if(!(A in viewable)) continue
			reactable |= A
	var/fraction = (reagents.total_volume/reactable.len) - reagents.total_volume
	for(var/atom/A in reactable)
		reagents.reaction(A, TOUCH, fraction)


	spawn(15)		   //Making sure all reagents can work
		qdel(src)	   //correctly before deleting the grenade.

/obj/item/weapon/grenade/chem_grenade/proc/mix_reagents()
	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		G.reagents.trans_to(src, G.reagents.total_volume)
/obj/item/weapon/grenade/chem_grenade/proc/CreateDefaultTrigger(var/typekey)
	if(ispath(typekey,/obj/item/device/assembly))
		nadeassembly = new(src)
		nadeassembly.a_left = new /obj/item/device/assembly/igniter(nadeassembly)
		nadeassembly.a_left.holder = nadeassembly
		nadeassembly.a_left.secured = 1
		nadeassembly.a_right = new typekey(nadeassembly)
		if(!nadeassembly.a_right.secured)
			nadeassembly.a_right.toggle_secure() // necessary because fuxing prock_sensors
		nadeassembly.a_right.holder = nadeassembly
		nadeassembly.secured = 1
		nadeassembly.master = src
		nadeassembly.update_icon()
		stage = READY
		update_icon()
	else
		CRASH("chem grenade CreateDefaultTrigger(): not an assembly: [typekey]")

/obj/item/weapon/grenade/chem_grenade/proc/can_flood_from(myloc, maxrange)
	var/list/reachable = list(myloc)
	for(var/i=1; i<=maxrange; i++)
		for(var/turf/T in (orange(i, myloc) - orange(i-1, myloc)))
			if(T in reachable) continue
			for(var/turf/NT in orange(1, T))
				if(!(NT in reachable)) continue
				if(!(get_dir(T,NT) in cardinal)) continue
				if(!NT.CanAtmosPass(T)) continue
				reachable |= T
				break
	return reachable

//Large chem grenades accept slime cores and use the appropriately.
/obj/item/weapon/grenade/chem_grenade/large
	name = "large grenade casing"
	desc = "An oversized grenade casing."
	icon_state = "large_grenade"
	bomb_state = "largebomb"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass,/obj/item/weapon/reagent_containers/food/condiment,
								/obj/item/weapon/reagent_containers/food/drinks)
	origin_tech = "combat=3;materials=3"
	affected_area = 4

/obj/item/weapon/grenade/chem_grenade/large/mix_reagents()
	for(var/obj/item/slime_extract/S in beakers)
		if(S.Uses)
			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				G.reagents.trans_to(S, G.reagents.total_volume)

			//If there is still a core (sometimes it's used up)
			//and there are reagents left, behave normally

			if(S && S.reagents && S.reagents.total_volume)
				S.reagents.trans_to(src,S.reagents.total_volume)
			return
	..()

	//I tried to just put it in the allowed_containers list but
	//if you do that it must have reagents.  If you're going to
	//make a special case you might as well do it explicitly. -Sayu
/obj/item/weapon/grenade/chem_grenade/large/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/slime_extract) && stage == WIRED)
		user << "<span class='notice'>You add [I] to the [initial(name)] assembly.</span>"
		user.drop_item()
		I.loc = src
		beakers += I
	else
		return ..()


/obj/item/weapon/grenade/chem_grenade/metalfoam
	payload_name = "metal foam"
	desc = "Used for emergency sealing of air breaches."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/metalfoam/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("aluminium", 30)
	B2.reagents.add_reagent("foaming_agent", 10)
	B2.reagents.add_reagent("pacid", 10)

	beakers += B1
	beakers += B2
	update_icon()


/obj/item/weapon/grenade/chem_grenade/incendiary
	payload_name = "incendiary"
	desc = "Used for clearing rooms of living things."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/incendiary/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("aluminium", 25)
	B2.reagents.add_reagent("plasma", 25)
	B2.reagents.add_reagent("sacid", 25)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/weapon/grenade/chem_grenade/antiweed
	payload_name = "weed killer"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/antiweed/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("plantbgone", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/weapon/grenade/chem_grenade/cleaner
	payload_name = "cleaner"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/cleaner/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 40)
	B2.reagents.add_reagent("water", 40)
	B2.reagents.add_reagent("cleaner", 10)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/weapon/grenade/chem_grenade/teargas
	payload_name = "teargas"
	desc = "Used for nonlethal riot control. Contents under pressure. Do not directly inhale contents."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/teargas/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("condensedcapsaicin", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2
	update_icon()


/obj/item/weapon/grenade/chem_grenade/pacid
	name = "acid grenade"
	desc = "Used for melting armoured opponents."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/pacid/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("pacid", 100)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2
	icon_state = "grenade"

#undef EMPTY
#undef WIRED
#undef READY
