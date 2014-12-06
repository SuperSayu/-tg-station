/mob/living/carbon/human/gib_animation(var/animate)
	..(animate, "gibbed-h")

/mob/living/carbon/human/dust_animation(var/animate)
	..(animate, "dust-h")

/mob/living/carbon/human/dust(var/animation = 1)
	..()

/mob/living/carbon/human/spawn_gibs()
	hgibs(loc, viruses, dna, organs)

/mob/living/carbon/human/spawn_dust()
	new /obj/effect/decal/remains/human(loc)

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)	return

	// Ankh artifact
	if(back)
		if(istype(back,/obj/item/artifact))
			var/obj/item/artifact/A = back
			if(A.power == 56 && A.activated && A.on) // A_REVIVE
				revive()
				tod = worldtime2text()
				if(mind)
					mind.store_memory("Time of resurrection: [tod]", 0)
				unEquip(A)
				qdel(A)
				var/obj/item/wings/W = new /obj/item/wings(src.loc)
				W.wearer = src
				if(dna)
					dna.species.speedmod -= 2
					pass_flags |= PASSTABLE
					equip_to_slot_if_possible(W, slot_back, 1, 1, 1)
					W.flags |= NODROP
					// Temporary immunity to the elements
					dna.species.specflags |= NOBREATH
					dna.species.specflags |= HEATRES
					dna.species.specflags |= COLDRES
				visible_message("<span class='notice'><b>\The [A] breaks, bringing [src] back to life!</b></span>")
				src << "<span class='notice'>The energy released by \the [A] breaking has granted temporary protection against the elements.</span>"
				src << "<span class='notice'>You've gained a majestic pair of wings. Click the icon at the top to retract/extend them.</span>"
				playsound(get_turf(src), 'sound/effects/Glassbr3.ogg', 70, 1)
				playsound(get_turf(src), 'sound/effects/phasein.ogg', 100, 1)
				for(var/mob/living/carbon/human/H in viewers(src, null))
					if(H != src)
						flick("e_flash", H.flash) // So bright it doesn't even need an eyecheck
						H.Weaken(0.1)
				spawn(2400) // 4 minutes
					if(src && src.dna && src.dna.species)
						// Reset the specflags to normal
						dna.species.specflags -= NOBREATH
						dna.species.specflags -= HEATRES
						dna.species.specflags -= COLDRES
						src << "<span class='danger'>The protective aura granted by the ankh has worn off.</span>"
				return
		else if(istype(back,/obj/item/wings))
			var/obj/item/wings/W = back
			visible_message("<b><span class='danger'>Deo's Wings catch fire and burn up, leaving nothing but ash behind.</span><b>")
			if(W.state == 1)
				if(dna)
					dna.species.speedmod += 2
					pass_flags -= PASSTABLE
			W.flags -= NODROP
			unEquip(W)
			var/obj/effect/decal/cleanable/ash/A = new /obj/effect/decal/cleanable/ash(W.loc)
			A.name = "wing remains"
			A.desc = "<i>Ad majorem Deo gloriam.</i>"
			qdel(W)


	if(healths)		healths.icon_state = "dead"
	stat = DEAD
	dizziness = 0
	jitteriness = 0
	numbness = 0

	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		if(M.occupant == src)
			M.go_out()

	if(!gibbed)
		emote("deathgasp") //let the world KNOW WE ARE DEAD

		update_canmove()
		if(client) blind.layer = 0

	if(dna)
		dna.species.spec_death(gibbed,src)

	tod = worldtime2text()		//weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)
	if(ticker && ticker.mode)
//		world.log << "k"
		sql_report_death(src)
		ticker.mode.check_win()		//Calls the rounds wincheck, mainly for wizard, malf, and changeling now
	return ..(gibbed)

/mob/living/carbon/human/proc/makeSkeleton()
	if(!check_dna_integrity(src))	return
	status_flags |= DISFIGURED
	dna.species = new /datum/species/skeleton(src)
	return 1

/mob/living/carbon/proc/ChangeToHusk()
	if(HUSK in mutations)	return
	mutations.Add(HUSK)
	status_flags |= DISFIGURED	//makes them unknown without fucking up other stuff like admintools
	return 1

/mob/living/carbon/human/ChangeToHusk()
	. = ..()
	if(.)
		update_hair()
		update_body()

/mob/living/carbon/proc/Drain()
	var/drain = 1
	if(back)
		if(istype(back,/obj/item/artifact))
			var/obj/item/artifact/A = back
			if(A.power == 56 && A.activated && A.on) // A_REVIVE
				drain = 0
	if(drain)
		ChangeToHusk()
		mutations |= NOCLONE
		return 1
	else
		return 0