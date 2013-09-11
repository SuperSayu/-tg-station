//Floorbot assemblies
/obj/item/weapon/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = 0
	var/created_name = "Floorbot"

/obj/item/weapon/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = 0
	var/created_name = "Floorbot"

//Floorbot
/obj/machinery/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "floorbot0"
	layer = 5.0
	density = 0
	anchored = 0
	health = 25
	maxhealth = 25
	flags = 0
	pass_flags = PASSTABLE
	//weight = 1.0E7
	var/amount = 10
	var/repairing = 0
	var/improvefloors = 0
	var/doorwait = 0
	var/eattiles = 0
	var/maketiles = 0
	var/atom/target
	var/atom/oldtarget
	var/oldloc = null
	req_access = list(access_construction)
	var/list/path = new
	var/targetdirection
	var/global/list/floorbottargets = list()
	var/global/list/unreachable = list()


/obj/machinery/bot/floorbot/New()
	..()
	src.update_icon()

/obj/machinery/bot/floorbot/turn_on()
	. = ..()
	src.update_icon()
	src.updateUsrDialog()

/obj/machinery/bot/floorbot/turn_off()
	..()
	floorbottargets -= src.target
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.update_icon()
	src.path = new()
	src.updateUsrDialog()

/obj/machinery/bot/floorbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/bot/floorbot/interact(mob/user as mob)
	var/dat
	dat += "<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [src.open ? "opened" : "closed"]<BR>"
	dat += "Tiles left: [src.amount]<BR>"
	dat += "Behvaiour controls are [src.locked ? "locked" : "unlocked"]<BR>"
	if(!src.locked || issilicon(user))
		dat += "Improves floors: <A href='?src=\ref[src];operation=improve'>[src.improvefloors ? "Yes" : "No"]</A><BR>"
		dat += "Finds tiles: <A href='?src=\ref[src];operation=tiles'>[src.eattiles ? "Yes" : "No"]</A><BR>"
		dat += "Make singles pieces of metal into tiles when empty: <A href='?src=\ref[src];operation=make'>[src.maketiles ? "Yes" : "No"]</A><BR>"
		var/bmode
		if (src.targetdirection)
			bmode = dir2text(src.targetdirection)
		else
			bmode = "Disabled"
		dat += "<BR><BR>Bridge Mode : <A href='?src=\ref[src];operation=bridgemode'>[bmode]</A><BR>"

	user << browse("<HEAD><TITLE>Repairbot v1.0 controls</TITLE></HEAD>[dat]", "window=autorepair")
	onclose(user, "autorepair")
	return


/obj/machinery/bot/floorbot/attackby(var/obj/item/W , mob/user as mob)
	if(istype(W, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/T = W
		if(src.amount >= 50)
			return
		var/loaded = min(50-src.amount, T.amount)
		T.use(loaded)
		src.amount += loaded
		user << "<span class='notice'>You load [loaded] tiles into the floorbot. He now contains [src.amount] tiles.</span>"
		src.update_icon()
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(src.allowed(usr) && !open && !emagged)
			src.locked = !src.locked
			user << "<span class='notice'>You [src.locked ? "lock" : "unlock"] the [src] behaviour controls.</span>"
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='warning'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='warning'>Access denied.</span>"
		src.updateUsrDialog()
	else
		..()

/obj/machinery/bot/floorbot/Emag(mob/user as mob)
	..()
	if(open && !locked)
		if(user) user << "<span class='notice'>The [src] buzzes and beeps.</span>"

/obj/machinery/bot/floorbot/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	switch(href_list["operation"])
		if("start")
			if (src.on)
				turn_off()
			else
				turn_on()
		if("improve")
			src.improvefloors = !src.improvefloors
			src.updateUsrDialog()
		if("tiles")
			src.eattiles = !src.eattiles
			src.updateUsrDialog()
		if("make")
			src.maketiles = !src.maketiles
			src.updateUsrDialog()
		if("bridgemode")
			switch(src.targetdirection)
				if(null)
					targetdirection = 1
				if(1)
					targetdirection = 2
				if(2)
					targetdirection = 4
				if(4)
					targetdirection = 8
				if(8)
					targetdirection = null
				else
					targetdirection = null
			src.updateUsrDialog()


// Reject any turf that you naturally cannot reach.
/obj/machinery/bot/floorbot/proc/consider(var/atom/A)
	set background = 1
	if(!A || A.density || A == src.oldtarget || (A in floorbottargets))
		return 0
	var/turf/T = get_turf(A)
	if(T.density)
		return 0
	for(var/obj/O in T)
		if(O.density && !istype(O,/obj/machinery/door) && !istype(O,/obj/structure/table)) // tablepass flag
			return 0
		if(istype(O,/obj/machinery/bot/floorbot) && O != src)
			return 0
	return 1

/obj/machinery/bot/floorbot/process()
	set background = 1

	if(!src.on || src.repairing || !loc)
		return
	if(target && doorwait)
		return

	doorwait = 0 // if not target
	floorbottargets -= null // this is a little pointless but I might as well

	for(var/entry in unreachable)
		var/timer = unreachable[entry]
		if(get_dist(entry,src) == 0 || world.time > (timer + 300))
			unreachable -= entry
			floorbottargets -= entry

	if(src.amount <= 0 && !src.target)
		if(src.eattiles)
			for(var/obj/item/stack/tile/plasteel/T in view(7, src))
				if(consider(T))
					src.oldtarget = T
					src.target = T
					break

		if(!src.target && src.maketiles)
			for(var/obj/item/stack/sheet/metal/M in view(7, src))
				if(consider(M) && M.amount == 1)
					src.oldtarget = M
					src.target = M
					break
		else
			if(prob(5))
				visible_message("[src] makes a despondant booping sound.")
			return
	if(prob(5))
		visible_message("[src] makes an excited booping beeping sound!")

	if(!src.target && emagged < 2)
		if(src.amount && istype(loc,/turf/space) && consider(loc) && (loc.loc.type != /area))
			oldtarget = loc
			target = loc

		if(!target && targetdirection != null)
			var/turf/T = get_step(src, targetdirection)
			if(istype(T, /turf/space))
				src.oldtarget = T
				src.target = T


		var/list/nearby = view(7,src) // Caching this, previously at worst it would run this three times

		if(!src.target && src.amount)
			for (var/turf/space/D in nearby)
				if(consider(D) && (D.loc.type != /area))
					src.oldtarget = D
					src.target = D
					break
		if(!src.target)
			var/turf/simulated/floor/Floc = loc
			if( istype(Floc) && (Floc.broken || Floc.burnt || (!Floc.intact && src.amount && src.improvefloors) ) ) // consider(Floc) &&
				src.oldtarget = loc
				src.target = loc
			else
				for (var/turf/simulated/floor/F in nearby)
					if( consider(F) && (F.broken || F.burnt || (!Floc.intact && src.amount && src.improvefloors) ) )
						src.oldtarget = F
						src.target = F
						break
		if(!src.target && src.eattiles)
			for(var/obj/item/stack/tile/plasteel/T in nearby)
				if(consider(T))
					src.oldtarget = T
					src.target = T
					break

	if(!src.target && emagged == 2)
		if(istype(loc,/turf/simulated/floor) && consider(loc))
			src.oldtarget = loc
			src.target = loc
		else
			for (var/turf/simulated/floor/D in view(7,src))
				if(consider(D) && D.intact)
					src.oldtarget = D
					src.target = D
					break
	if(!src.target)
		if(src.loc != src.oldloc)
			src.oldtarget = null
		if(emagged == 2)
			step_rand(src)
		return
	floorbottargets |= src.target
	unreachable -= src.target

	if(get_dist(src,src.target) > 0)
		if(istype(src.target) && src.path.len == 0)
			spawn(0)
				if(!istype(src.target, /turf/))
					src.path = AStar(src.loc, src.target.loc, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30)
				else
					src.path = AStar(src.loc, src.target, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30)
				if(!src.path)
					src.path = list()
				if(src.path.len == 0)
					src.oldtarget = src.target
					src.target = null
					unreachable += list(src.oldtarget = world.time)
			return
		if(src.path.len > 0 && istype(src.target))
			step_to(src, src.path[1])
			if(src.path.len) // Bump()
				src.path -= src.path[1]
		else if(src.path.len == 1)
			step_to(src, target)
			src.path = new()

	if(!target) // Bump()
		return

	if(src.loc == src.target || src.loc == src.target.loc)
		if(istype(src.target, /obj/item/stack/tile/plasteel))
			src.eattile(src.target)
		else if(istype(src.target, /obj/item/stack/sheet/metal))
			src.maketile(src.target)
		else if(istype(src.target, /turf/) && emagged < 2)
			repair(src.target)
		else if(emagged == 2 && istype(src.target,/turf/simulated/floor))
			floorbottargets -= src.target
			var/turf/simulated/floor/F = src.target
			src.anchored = 1
			src.repairing = 1
			src.icon_state = "floorbot-c"
			if(!F.is_plating())
				F.break_tile_to_plating()
				visible_message("\red [src] makes an excited booping sound.")
				src.oldtarget = null // special case here because we want to put holes in the floor
				src.amount ++
			else if(prob(30))
				F.ReplaceWithLattice()
				visible_message("\red [src] makes an excited booping sound.")
				src.amount ++

			spawn(150)
				src.anchored = 0
				src.repairing = 0
				src.target = null
				src.update_icon()

		src.path = new()
		return

	src.oldloc = src.loc

/obj/machinery/bot/floorbot/Bump(var/atom/A)
	if(doorwait)
		if(target)
			unreachable |= list(src.target = world.time)
			src.target = null
			src.path = list()
		return
	if(istype(A,/obj/machinery/door))
		doorwait = 1
		A.Bumped(src)
		spawn(35)
			doorwait = 0
			if(!A.density)
				step_to(src,A)
				return
			else if(target)
				unreachable |= list(src.target = world.time)
				src.target = null
				src.path = list()
	else if(istype(A,/atom/movable))
		var/atom/movable/AM = A
		var/turf/T = AM.loc
		if(!AM.anchored)
			doorwait = 1
			var/t = get_dir(src, AM)
			if (istype(AM, /obj/structure/window))
				if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
					for(var/obj/structure/window/win in get_step(AM,t))
						doorwait = 0
						return
			step(AM, t)
			if(AM.loc != T)
				step_to(src,T)
			doorwait = 0
	if(target)
		unreachable |= list(src.target = world.time)
		src.target = null
		src.path = list()

/obj/machinery/bot/floorbot/proc/repair(var/turf/target)
	set background = 1
	floorbottargets -= src.target

	if(istype(target, /turf/space/))
		if(target.loc.name == "Space" && !targetdirection)
			return
	else if(!istype(target, /turf/simulated/floor))
		return
	if(src.amount <= 0)
		target = null
		return
	src.anchored = 1
	src.icon_state = "floorbot-c"

	if(istype(target, /turf/space/))
		visible_message("\red [src] begins to build a floor")
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		src.repairing = 1
		spawn(50)
			T.build(src.loc)
			src.repairing = 0
			src.amount -= 1
			src.update_icon()
			src.anchored = 0
			src.target = null
		return
	var/turf/simulated/floor/F = target
	if(F.burnt || F.broken)
		visible_message("\red [src] begins to repair the floor.")
		src.repairing = 1
		spawn(50)
			F.burnt = 0
			F.broken = 0
			F.update_icon()
			src.repairing = 0
			src.anchored = 0
			src.update_icon()
			src.target = null
		return
	else if(!F.intact)
		visible_message("\red [src] begins to improve the floor.")
		src.repairing = 1
		spawn(50)
			F.floor_tile = new /obj/item/stack/tile/plasteel(null)
			F.intact = 1
			F.update_icon()
			F.levelupdate()
			src.repairing = 0
			src.amount -= 1
			src.update_icon()
			src.anchored = 0
			src.target = null
		return
	src.target = null
	src.anchored = 0
	src.repairing = 0
	src.doorwait = 0
	src.update_icon()

/obj/machinery/bot/floorbot/proc/eattile(var/obj/item/stack/tile/plasteel/T)
	floorbottargets -= src.target
	if(!istype(T, /obj/item/stack/tile/plasteel))
		return
	visible_message("\red [src] begins to collect tiles.")
	src.repairing = 1
	spawn(20)
		if(isnull(T))
			src.target = null
			src.repairing = 0
			return
		if(src.amount + T.amount > 50)
			var/i = 50 - src.amount
			src.amount += i
			T.amount -= i
		else
			src.amount += T.amount
			del(T)
		src.update_icon()
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/maketile(var/obj/item/stack/sheet/metal/M)
	floorbottargets -= src.target
	if(!istype(M, /obj/item/stack/sheet/metal))
		return
	if(M.amount > 1)
		return
	visible_message("\red [src] begins to create tiles.")
	src.repairing = 1
	spawn(20)
		if(isnull(M))
			src.target = null
			src.repairing = 0
			return
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		T.amount = 4
		T.loc = M.loc
		del(M)
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/update_icon()
	if(src.amount > 0)
		src.icon_state = "floorbot[src.on]"
	else
		src.icon_state = "floorbot[src.on]e"

/obj/machinery/bot/floorbot/explode()
	src.on = 0
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/storage/toolbox/mechanical/N = new /obj/item/weapon/storage/toolbox/mechanical(Tsec)
	N.contents = list()

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	while (amount)//Dumps the tiles into the appropriate sized stacks
		var/stacksize = min(amount,rand(4,20))
		if(amount >= stacksize)
			var/obj/item/stack/tile/plasteel/T = new (Tsec)
			T.amount = stacksize
			amount -= stacksize
			spawn(1)
				step_rand(T)
		else
			var/obj/item/stack/tile/plasteel/T = new (Tsec)
			T.amount = src.amount
			amount = 0

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	del(src)
	return


/obj/item/weapon/storage/toolbox/mechanical/attackby(var/obj/item/stack/tile/plasteel/T, mob/user as mob)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		..()
		return
	if(src.contents.len >= 1)
		user << "<span class='notice'>They wont fit in as there is already stuff inside.</span>"
		return
	if(user.s_active)
		user.s_active.close(user)
	del(T)
	var/obj/item/weapon/toolbox_tiles/B = new /obj/item/weapon/toolbox_tiles
	user.put_in_hands(B)
	user << "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>"
	user.drop_from_inventory(src)
	del(src)

/obj/item/weapon/toolbox_tiles/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(isprox(W))
		del(W)
		var/obj/item/weapon/toolbox_tiles_sensor/B = new /obj/item/weapon/toolbox_tiles_sensor()
		B.created_name = src.created_name
		user.put_in_hands(B)
		user << "<span class='notice'>You add the sensor to the toolbox and tiles!</span>"
		user.drop_from_inventory(src)
		del(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t

/obj/item/weapon/toolbox_tiles_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		del(W)
		var/turf/T = get_turf(user.loc)
		var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot(T)
		A.name = src.created_name
		user << "<span class='notice'>You add the robot arm to the odd looking toolbox assembly! Boop beep!</span>"
		user.drop_from_inventory(src)
		del(src)
	else if (istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter new robot name", src.name, src.created_name)

		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t