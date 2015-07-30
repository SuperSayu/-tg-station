// This file is used for other things related to the powers.

////////////////
// SHADOW MOB //
////////////////

/mob/living/simple_animal/hostile/retaliate/shadow
	name = "shadow"
	desc = "It flickers in and out of reality, warping the mind."
	icon = 'icons/mob/animal.dmi'
	icon_state = "forgotten"
	alpha = 30
	maxHealth = 20
	health = 20
	emote_hear = list("moans","wails","whispers")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "drains the life from"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	faction = "cult"

/mob/living/simple_animal/hostile/retaliate/shadow/proc/creation(var/lifespan = 1500)
	visible_message("<span class='warning'>A shadow appears.</span>")
	spawn(lifespan)
		visible_message("<span class='warning'>The shadow fades away.</span>")
		qdel(src)

/mob/living/simple_animal/hostile/retaliate/shadow/Life()
	..()
	for(var/mob/living/carbon/human/H in range(2,src))
		if(prob(20))
			H.hallucination += rand(10,20)
			if(prob(55))
				H << "<span class='warning'>You feel a trickle of insanity...</span>"

///////////
// LIGHT //
///////////

/obj/effect/artlight
	name = "dancing lights"
	desc = "So bright, so ethereal."
	density = 0
	layer = 5 // Over everything
	alpha = 125 // Semi-transparent
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="ice_1"
	pass_flags = PASSGLASS | PASSGRILLE
	var/mob/target = null

/obj/effect/artlight/New(l,var/duration = 450)
	..()
	SetLuminosity(8)
	SSobj.processing |= src
	spawn(duration)
		if(src)
			qdel(src)

/obj/effect/artlight/process()
	if(!target)
		qdel(src)
	else
		walk_towards(src, target, 0)

/obj/effect/artlight/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

//////////////
// BLOB GOO //
//////////////

/obj/effect/blobgoo
	name = "oozing goo"
	desc = "Something's growing in the goo..."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

/obj/effect/blobgoo/New(l,var/duration = 1200)
	..()
	SetLuminosity(2)
	playsound(src.loc, 'sound/effects/splat.ogg', 100, 1)
	spawn(duration)
		if(src)
			new /obj/effect/blob/node(src.loc)
			qdel(src)

///////////////////////
// RADIATION MACHINE //
///////////////////////

/obj/machinery/rad_machine
	name = "radiation machine"
	desc = "Used for the irradiation of artifacts. Remember to wear a radsuit while using it."
	icon = 'icons/obj/artifact.dmi'
	icon_state = "pod_0"
	anchored = 1
	density = 1
	var/active = 0
	var/intensity = 5
	var/obj/item/artifact/art = null

/obj/machinery/rad_machine/New()
	..()
	update_icons()

/obj/machinery/rad_machine/attack_hand(mob/user as mob)
	// Todo: Make this upgradeable?
	user.set_machine(src)

	var/datum/browser/popup = new(user, "radiation", "Radiation Machine", 300, 250)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))

	var/dat = ""
	if(active)
		dat += "Working, please wait... ([intensity] seconds remaining.)"
	else
		dat += "<b>Loaded artifact</b>: [art ? "[art.name]" : "Null"]<br>"
		if(art)
			dat += "<A HREF='?src=\ref[src];eject=1'>Eject Artifact</A><br><br>"
			dat += "<A HREF='?src=\ref[src];radiate=1'>Pulse Radiation</A><br>"
		else
			dat += "<span class='linkOff'>Eject Artifact</span><br><br>"
			dat += "<span class='linkOff'>Pulse Radiation</span><br>"
		dat += "<b>Radiation Intensity:</b> <A HREF='?src=\ref[src];decrease=1'>-</A> [intensity] <A HREF='?src=\ref[src];increase=1'>+</A><br><br>"

	dat += "<br><A HREF='?src=\ref[user];mach_close=radiation'>Close Console</A>"

	popup.set_content(dat)
	popup.open()

/obj/machinery/rad_machine/attackby(var/obj/item/artifact/A, var/mob/user, params)
	if(istype(A))
		if(!art)
			user.drop_item()
			art = A
			A.loc = src
			user << "<span class='notice'>You insert \the [A] into the machine.</span>"
		else
			user << "<span class='danger'>There's already an artifact in the machine.</span>"
	else
		user << "<span class='danger'>\The [src] rejects \the [A]!</span>"

/obj/machinery/rad_machine/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)

	if(href_list["eject"])
		for(var/obj/item/artifact/A in contents)
			A.loc = src.loc
			art = null
			updateUsrDialog()
			usr << "<span class='notice'>You eject \the [A].</span>"
	else if(href_list["radiate"])
		active = 1
		updateUsrDialog()
		update_icons()
		if(prob(intensity*10))
			for(var/mob/living/L in view(intensity, src))
				L.apply_effect(20, IRRADIATE)
			playsound(src.loc, 'sound/effects/EMPulse.ogg', 60, 1)
		var/duration = intensity*10
		spawn(duration)
			active = 0
			updateUsrDialog()
			update_icons()
			art.radiation_act(intensity)
	else if(href_list["increase"])
		if(intensity+1 < 11)
			intensity++
			updateUsrDialog()
	else if(href_list["decrease"])
		if(intensity-1 > 0)
			intensity--
			updateUsrDialog()

/obj/machinery/rad_machine/proc/update_icons()
	icon_state = "pod_[active]"

///////////
// WINGS //
///////////

// Granted by resurrecting with the ankh

/obj/item/wings
	name = "Deo's Wings"
	desc = "An angelic pair of wings that appeared after resurrecting. They grant extra speed and the ability to fly."
	icon = 'icons/obj/artifact.dmi'
	icon_state = "wings"
	slot_flags = SLOT_BACK
	action_button_name = "Toggle Wings"
	burn_state = -1 //Won't burn in fires
	var/state = 1 // 0 = retracted, 1 = extended
	var/datum/effect/effect/system/wing_trail_follow/wing_trail
	var/mob/living/carbon/human/wearer = null
	alternate_worn_icon = 'icons/mob/sayu_onmob.dmi'

/obj/item/wings/New()
	..()
	wing_trail = new /datum/effect/effect/system/wing_trail_follow()
	wing_trail.set_up(src)
	wing_trail.start()

/obj/item/wings/ui_action_click()
	if(src in usr)
		toggle()

/obj/item/wings/proc/toggle()
	if(wearer)
		playsound(get_turf(wearer), 'sound/weapons/thudswoosh.ogg', 150, 1)
		if(state == 0)
			wearer << "<span class='notice'>You unfold your wings, granting the power of flight.</span>"
			wing_trail.on = 1
			wing_trail.processing = 1
			wing_trail.start()
			extend()
		else
			wearer << "<span class='notice'>You fold your wings, landing softly on the ground.</span>"
			wing_trail.on = 0
			wing_trail.processing = 0
			retract()

/obj/item/wings/proc/extend()
	if(wearer)
		wearer.unEquip(wearer.back)
		if(wearer.dna)
			wearer.dna.species.speedmod -= 2
		wearer.pass_flags |= PASSTABLE
		wearer.equip_to_slot_if_possible(src, slot_back, 1, 1, 1)
		flags |= NODROP
		state = 1

/obj/item/wings/proc/retract()
	if(wearer)
		flags &= ~NODROP
		if(wearer.dna)
			wearer.dna.species.speedmod += 2
		wearer.pass_flags -= PASSTABLE
		wearer.unEquip(wearer.back)
		wearer.contents += src
		state = 0

/////////////////
// WING TRAILS //
////////////////

/obj/effect/effect/wing_trails
	name = "wing trails"
	icon_state = "wingtrails"
	icon = 'icons/effects/sayu_effects.dmi'
	anchored = 1.0

/datum/effect/effect/system/wing_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

/datum/effect/effect/system/wing_trail_follow/set_up(atom/atom)
	attach(atom)
	oldposition = get_turf(atom)

/datum/effect/effect/system/wing_trail_follow/start()
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		var/turf/T = get_turf(src.holder)
		if(T != src.oldposition)
			if(!has_gravity(T))
				var/obj/effect/effect/wing_trails/W = new /obj/effect/effect/wing_trails(src.oldposition)
				src.oldposition = T
				W.dir = src.holder.dir
				spawn( 4 )
					if(W)
						W && qdel(W)
			spawn(2)
				if(src.on)
					src.processing = 1
					src.start()
		else
			spawn(2)
				if(src.on)
					src.processing = 1
					src.start()

//////////////////
// ADMIN REROLL //
//////////////////

/client/proc/cmd_admin_artreroll()
	set category = "Fun"
	set name = "Reroll Artifacts"

	if (!holder)
		src << "Only administrators may use this command."
		return

	global.ankh = 0
	for(var/obj/item/artifact/A in world)
		if(A.z <= 6)
			var/obj/item/artifact/AN = new /obj/item/artifact(get_turf(A))
			AN.activated = A.activated
			AN.on = A.on
			AN.update_icons()
			qdel(A)

	log_admin("[key_name(usr)] rerolled all artifacts.")
	message_admins("[key_name_admin(usr)] rerolled all artifacts.)", 1)

///////////////
// ACTIVATOR //
///////////////

// For admin purposes

/obj/item/device/activator
	name = "activator"
	desc = "It broadcasts a frequency that activates artifacts."
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = 2.0
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=500,MAT_GLASS=500)
	origin_tech = "magnets=1;engineering=1"

///////////////
// GUN STUFF //
///////////////

// TODO

/*/obj/item/ammo_casing/energy/artifact
	e_cost = 0
	projectile_type = /obj/item/projectile/artifact

/obj/item/projectile/artifact
	name = "artifact projectile"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

/obj/item/projectile/artifact/New()
	..()
	damage = rand(5,30)
	damage_type = pick(BRUTE,BURN,TOX,OXY,CLONE,STAMINA)
	flag = pick("bullet","laser","energy","bomb")
	projectile_type = "/obj/item/projectile"
	kill_count = rand(3,10)*10
	// effects
	if(prob(20))
		stun = rand(1,5)
		weaken = rand(1,5)
	if(prob(10))
		paralyze = rand(1,4)
	if(prob(30))
		irradiate = rand(1,5)*10
	if(prob(40))
		stutter = rand(1,5)
	if(prob(50))
		eyeblur = rand(1,3)
	if(prob(25))
		drowsy = rand(1,5)
	if(prob(10))
		forcedodge = 1*/