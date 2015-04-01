/obj/item/artifact/proc/rand_stim()
	var/list/picklist = list(A_FORCE,A_SHOCK,A_RADS,A_HEAT,A_EMP,A_EXPLODE)
	stimulus1 = pick_n_take(picklist)
	stimulus2 = pick_n_take(picklist)
	set_stim()

obj/item/artifact/proc/set_stim()
	if(stimnum == 0)
		switch(stimulus1)
			if(A_FORCE)
				if(prob(75))
					extra3 = rand(10,20)
				else
					extra3 = rand(21,30)
			if(A_RADS)
				extra3 = rand(1,10)
			if(A_HEAT)
				extra3 = 300
			if(A_EXPLODE)
				extra3 = rand(1,3)
	else if(stimnum == 1)
		switch(stimulus2)
			if(A_FORCE)
				extra3 = rand(10,24)
			if(A_RADS)
				extra3 = rand(1,10)
			if(A_HEAT)
				extra3 = 300
			if(A_EXPLODE)
				extra3 = rand(1,3)

/obj/item/artifact/ex_act(severity,specialty)
	if(!checkfail(A_EXPLODE))
		if(severity >= extra3)
			activate()
		else
			var/turf/artloc = get_turf(src.loc)
			artloc.visible_message("<span class='notice'>\The [src] appears to react to the force of the explosion.</span>")
			damage(severity*10)
	return

/obj/item/artifact/emp_act(severity)
	if(!checkfail(A_EMP))
		if(!activated)
			activate()
	return

/obj/item/artifact/throw_impact(atom/hit_atom)
	..()
	if(!hitdelay)
		if(istype(hit_atom,/turf/simulated/wall))
			if(!checkfail(A_FORCE))
				if(extra3 > 20)
					activate()
				else
					var/turf/artloc = get_turf(src)
					artloc.visible_message("<span class='notice'>\The [src] appears to react to the force of the throw.</span>")
					playsound(artloc,'sound/machines/twobeep.ogg',70,0)
					damage(rand(5,10))
			else
				damage(rand(9,15))
			hitdelay = 1
			spawn(10)
			hitdelay = 0

/obj/item/artifact/proc/radiation_act(var/intensity)
	if(!checkfail(A_RADS))
		if(intensity == extra3)
			activate()
		else
			radfail(intensity)
			damage(intensity)
	else
		damage(intensity*2)

/obj/item/artifact/proc/check_heat() // This one doesn't reset the stimuli because that would be annoying
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		var/loc_temp = T.temperature // I'm not quite sure how to do this in a way that isn't stupid
		if(loc_temp > arttemp)
			arttemp += round(loc_temp/60)
		else if(loc_temp < arttemp)
			arttemp -= round(loc_temp/60)
		if(arttemp >= extra3)
			if(!checkfail(A_HEAT,1))
				activate()
	return

/obj/item/artifact/proc/check_power()
	if(!activated && !powerdelay)
		var/turf/simulated/floor/plating/artloc = src.loc // Only works if the artifact's on the ground.
		if(istype(artloc))
			for(var/obj/structure/cable/C in artloc.contents)
				if(C.d1 == 0) // node
					if(C.powernet && (C.powernet.avail > 0) && !checkfail(A_SHOCK))
						activate()
						artloc.visible_message("<span class='notice'>\The [src] appears to react to the electric current!</span>")
						for(var/mob/living/carbon/human/H in range(1,src))
							if(H.gloves)
								var/obj/item/clothing/gloves/G = H.gloves
								if(G.siemens_coefficient)
									H << "<span class='danger'>\The [src] shocks you!</span>"
									H.electrocute_act(extra1, src, 1.0, 0)
									var/list/throwdirections = list(NORTH,SOUTH,EAST,WEST)
									var/atom/throwtarg = get_edge_target_turf(H, pick(throwdirections))
									H.throw_at(throwtarg, 5, 2)
		powerdelay = 1
		spawn(100)
		powerdelay = 0

/obj/item/artifact/proc/activate()
	if(activated) // yet another sanity check
		return
	stimnum++
	if(stimnum >= 2)
		var/turf/artloc = get_turf(src)
		artloc.visible_message("<span class='notice'>With a flash of light, \the [src] activates!</span>")
		playsound(artloc, 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/L in viewers(artloc, null))
			if(L:eyecheck() <= 0)
				flick("e_flash", L.flash)
		activated = 1
		on = 1
		update_icons()
	else
		var/turf/artloc = get_turf(src)
		artloc.visible_message("<span class='notice'>The artifact pings pleasantly.</span>")
		playsound(artloc, 'sound/machines/ping.ogg', 100, 1)
		set_stim() // update the stimuli

/obj/item/artifact/proc/checkfail(var/stimtype = 0, var/safety = 0)
	if(integrity <= 0)
		if(!safety)
			stimfail()
		return 1
	if(!activated)
		switch(stimnum)
			if(0)
				if(stimulus1 == stimtype)
					return 0
				else
					if(!safety)
						if(stimulus2 == stimtype)
							stimfail(1)
						else
							stimfail()
					return 1
			if(1)
				if(stimulus2 == stimtype)
					return 0
				else
					if(!safety)
						stimfail()
					return 1
		return 1

/obj/item/artifact/proc/stimfail(var/extra = 0)
	var/turf/artloc = get_turf(src.loc)
	if(extra || prob(10)) // Small chance to whir anyway, to encourage testing multiple times. Can be removed if it gets annoying...
		artloc.visible_message("<span class='danger'>\The [src] buzzes and whirrs.</span>")
		playsound(artloc,'sound/machines/buzz-two.ogg',70,1)
	else
		artloc.visible_message("<span class='danger'>\The [src] buzzes and sighs.</span>")
		playsound(artloc,'sound/machines/buzz-sigh.ogg',70,1)
	stimnum = 0
	set_stim() // Reset the stimuli

/obj/item/artifact/proc/radfail(var/intensity = 0)
	var/turf/artloc = get_turf(src.loc)
	if(intensity > extra3)
		artloc.visible_message("<span class='danger'>\The [src] makes a high-pitched beeping noise.</span>")
		playsound(artloc,'sound/machines/twobeep.ogg',70,0)
	else
		artloc.visible_message("<span class='danger'>\The [src] makes a low-pitched beeping noise.</span>")
		playsound(artloc,'sound/machines/twobeeplow.ogg',70,0)

/obj/item/artifact/proc/damage(var/dforce = 0)
	if(integrity > 0)
		if(dforce)
			integrity = max(0,(integrity-dforce))
			if(integrity <= 0)
				var/turf/artloc = get_turf(src.loc)
				artloc.visible_message("<span class='danger'>\The [src] clatters to a halt and breaks.</span>")
				playsound(artloc,'sound/items/Ratchet.ogg',70,1)
				activated = 0
				update_icons()