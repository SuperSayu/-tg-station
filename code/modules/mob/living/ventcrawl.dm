/mob/living/proc/handle_ventcrawl()
	if(stat || !ventcrawler) return
	for(var/obj/machinery/atmospherics/unary/vent_pump/V in range(src,1))
		if(V.welded || !Adjacent(V)) continue
		src.Move(V)
		return
	src << "You can only enter an unwelded vent!"


/obj/machinery/atmospherics/unary/vent_pump/Enter(mob/living/ML)
	if(isturf(ML.loc)) // allow enter from within pipe
		if(!ML.ventcrawler || welded || ML.stat)
			return 0
		if(iscarbon(ML) && ML.ventcrawler == 1)
			for(var/obj/item/carried_item in ML)
				if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant
					ML << "<span class='warning'> You can't be carrying items or have items equipped when vent crawling!</span>"
					return 0
	return 1

/obj/machinery/atmospherics/Enter(mob/living/ML)
	if(istype(ML.loc, /obj/machinery/atmospherics/unary/cryo_cell))
		if(!istype(ML) || !ML.ventcrawler || ML.stat) return 0
		if(iscarbon(ML) && ML.ventcrawler == 1)
			for(var/obj/item/carried_item in ML)
				if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant
					ML << "<span class='warning'> You can't be carrying items or have items equipped when vent crawling!</span>"
					return 0
	return 1

/obj/machinery/atmospherics/var/clong = 0
/obj/machinery/atmospherics/relaymove(mob/user as mob,var/mdir)
	if(!anchored)
		user.Move(loc)
		return
	if(user.stat || !isturf(src.loc))
		return
	if(!(mdir&initialize_directions))
		if(!clong)
			playsound(loc, 'sound/effects/clang.ogg', 45,1, -1)
			clong = 1
			spawn(30) clong = 0
		if(prob(25))
			user.Stun(1)
			user << "<span class='notice'>You hit your head on [src].</span>"
		return
	var/turf/T = get_step(loc,mdir)
	var/fromdir = turn(mdir,180)
	for(var/obj/machinery/atmospherics/OMA in T)
		if(!(OMA.initialize_directions&fromdir))
			continue
		user.Move(OMA)
		return
	user.Move(T) // broken pipe

/obj/machinery/atmospherics/unary/cryo_cell/Enter(mob/living/ML)
	if(occupant && occupant != ML)
		ML << "[src] is already occupied."
		return 0
	return ..()
/obj/machinery/atmospherics/unary/cryo_cell/Entered(mob/living/ML, atom/oldLoc)
	if(istype(oldLoc,/obj/machinery/atmospherics))
		if(state_open)
			ML.Move(loc)
		else
			occupant = ML
	..()

/obj/machinery/atmospherics/var/image/visage = null
/obj/machinery/atmospherics/Entered(mob/M)
	if(istype(M) && M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = loc
		if(!visage)
			visage = image(icon,src,icon_state,LIGHTING_LAYER+1,dir)
		else
			visage.icon_state = icon_state
			visage.dir = dir
		M.client.images += visage
/obj/machinery/atmospherics/Exited(mob/M)
	if(istype(M) && M.client)
		M.client.images -= visage
	if(isturf(M.loc))
		M.client.perspective = MOB_PERSPECTIVE
		M.client.eye = M

/obj/machinery/atmospherics/unary/vent_pump/AltClick(mob/living/ML)
	if(ML.Adjacent(src) && !ML.stat && ML.ventcrawler && !welded)
		ML.Move(src)

/obj/machinery/atmospherics/unary/vent_pump/Entered(mob/user, atom/oldloc)
	if(istype(oldloc, /obj/machinery/atmospherics)) // this is a unary device, came from a pipe rather than the world
		if(welded)
			user << "\red [src] is welded shut!"
			return ..()
		user.Move(loc)
		if(user.loc == loc)
			user.visible_message("\blue [user] scrambles out of [src].")
			if(user.client)
				user.client.perspective = MOB_PERSPECTIVE
				user.client.eye = user
			return
		else
			user << "You can't get out here"
	else
		relaymove(user,dir)
		if(istype(user.loc, /obj/machinery/atmospherics))
			user << "You are in a maze of twisty passages, all alike.  It is pitch black here."

/obj/machinery/atmospherics/binary/pump/Enter(mob/M,atom/oldloc)
	if(stat || !on) return 1
	if(get_dir(src,oldloc) == dir) // output
		M << "You can't move against the flow of [src]!"
		return 0
	return 1
/obj/machinery/atmospherics/binary/pump/Entered(mob/living/M as mob)
	if(on)
		M << "[src] spits you violently out the other side!"
		M.apply_damage(5)
		src.relaymove(M,dir)
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/Enter(mob/M,atom/oldloc)
	if(stat || !on) return 1
	if(get_dir(src,oldloc) == dir) // output
		M << "You can't move against the flow of [src]!"
		return 0
	return 1
/obj/machinery/atmospherics/binary/volume_pump/Entered(mob/living/M as mob)
	if(on)
		M << "[src] spits you violently out the other side!"
		M.apply_damage(5)
		src.relaymove(M,dir)
	return ..()

/obj/machinery/atmospherics/valve/Enter(mob/M,atom/oldloc)
	if(!stat && !open)
		M << "You can't get past [src]."
		return 0
	return 1


/obj/machinery/atmospherics/Destroy()
	for(var/atom/movable/AM in src)
		AM.loc = loc
	..()
