var/global/ankh = 0 // only one can spawn

/obj/item/artifact
	name = "artifact"
	desc = "An artifact left behind by an ancient people. It has unknown powers and an unknown method of activation, although \
	you could probably glean some information by scientific analysis."
	icon = 'icons/obj/artifact.dmi'
	icon_state = "artifact0"
	unacidable = 1
	layer = 3.1
	burn_state = -1 //Won't burn in fires
	var/title = "artifact"
	var/prefix = "ancient"
	var/integrity = 100
	// Whether or not you can use the artifact right now.
	var/activated = 0
	var/on = 0
	var/cooldown = 0
	var/max_cooldown = 0
	var/reverse = 0 // If 1, the artifact will glow when it's cooling down rather than the other way around.
	var/sound_override = 0 // If 1, the artifact will not make the usual artifact sound when it's used.
	// What the artifact is, what it does, and how it activates.
	var/atype = null
	var/power = null
	var/stimulus1 = null
	var/stimulus2 = null
	var/stimnum = 0 // which stimulus the artifact needs
	var/usetype = null
	var/powerdelay = 0 // delay for checking power
	var/hitdelay = 0 // for some reason throwing an item at a wall does throw_impact twice, so here's something to prevent that
	var/raddelay = 0 // used for the grav gen... god, this is getting stupid
	var/reflect_chance = 0
	// Extra values, their uses depend on the other artifact attributes.
	var/extra1 = 0 // Used for power
	var/extra2 = 0 // Used for power
	var/extra3 = 2 // Used for stimulus
	// Other
	var/arttemp = T20C
	//var/obj/item/ammo_casing/energy/artifact/chambered = new /obj/item/ammo_casing/energy/artifact()
	var/adminart = 0

/obj/item/artifact/New()
	..()
	SSobj.processing |= src
	if(adminart == 0)
		set_type()
		rand_stim()
		name = "[prefix] [title]"
		update_icons()
		switch(atype)
			if(0 to 5)
				w_class = 1.0
			if(6 to 12)
				w_class = 3.0
				force = 5
				hitsound = 'sound/weapons/smash.ogg'
			if(13 to 17)
				w_class = 4.0
				force = 10
				hitsound = 'sound/weapons/smash.ogg'
			if(18 to 22)
				w_class = 6.0
				density = 1
				pass_flags = 0

/obj/item/artifact/Del()
	SSobj.processing.Remove(src)
	..()

/obj/item/artifact/MouseDrop(obj/over_object)
	if(iscarbon(usr))
		var/mob/M = usr

		if(istype(M.loc,/obj/mecha))
			return

		if(!( istype(over_object, /obj/screen) ))
			return ..()

		if(!(Adjacent(usr)))
			return
		if(!( M.restrained() ) && !( M.stat ))
			if(istype(over_object,/obj/machinery/rad_machine))
				var/obj/machinery/rad_machine/RM = over_object
				RM.art = src
				src.loc = RM
				M << "<span class='notice'>You insert \the [src] into the machine.</span>"
			add_fingerprint(usr)
		return

/obj/item/artifact/process()
	if(integrity > 0)
		check_heat()
		check_power()
		integrity = min((integrity+0.5),100)
		if(usetype == A_CONSTANT && !cooldown && (prob(20) || max_cooldown > 0 || w_class >= 4.0)) // Doesn't always activate right away, to give a bit of a warning period
			use_power()
	else
		activated = 0
		on = 0

/obj/item/artifact/attack_hand(mob/user as mob)
	if(density)
		add_fingerprint(user)
		if(usetype == A_TOUCH || usetype == A_TOUCH_C || usetype == A_TOUCH_H)
			use_power(user)
	else
		..()

/obj/item/artifact/attack_self(mob/user as mob)
	if(adminart == 1) // Used for customizing artifacts as an admin.
		atype = input("Input artifact type.", name, atype) as num
		power = input("Input artifact power.", name, power) as num
		stimulus1 = input("Input artifact stimulus #1.", name, stimulus1) as num
		stimulus2 = input("Input artifact stimulus #2.", name, stimulus2) as num
		usetype = input("Input artifact use method.", name, usetype) as num
		activated = input("Is the artifact activated?", name, activated) as num
		set_title()
		set_power()
		set_stim()
		update_icons()
		name = "[prefix] [title]"
		switch(atype)
			if(0 to 5)
				w_class = 1.0
			if(6 to 12)
				w_class = 3.0
				force = 5
				hitsound = 'sound/weapons/smash.ogg'
			if(13 to 17)
				w_class = 4.0
				force = 10
				hitsound = 'sound/weapons/smash.ogg'
			if(18 to 22)
				w_class = 6.0
				density = 1
				pass_flags = 0
		adminart = 0
	else if(usetype == A_CLICK)
		use_power(user)

/obj/item/artifact/attackby(obj/item/W, mob/user, params)
	var/turf/artloc = get_turf(src)
	if(istype(W, /obj/item/device/mining_scanner) ||istype(W,/obj/item/device/t_scanner/adv_mining_scanner) || istype(W,/obj/item/device/analyzer))
		if(integrity > 0)
			if(activated)
				on = !on
				visible_message("<span class='notice'>\The [src] flickers [on ? "on" : "off"].</span>")
				playsound(get_turf(src), 'sound/machines/click.ogg', 60, 1)
				update_icons()
			else
				user << "<span class='danger'>\The [src] does not respond to the analyzer.</span>"
		else
			user << "<span class='danger'>\The [src] appears to be broken.</span>"
	else if(istype(W,/obj/item/weapon/weldingtool))
		if(!activated)
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.welding && WT.max_fuel >= 40)
				if(!checkfail(A_HEAT,1))
					user << "<span class='notice'>\The [src] appears to react to the heat of \the [WT].</span>"
					playsound(get_turf(src),'sound/items/welder.ogg',70,1)
	else if(istype(W,/obj/item/device/activator))
		if(!activated)
			stimnum = 1
			activate()
	else
		if(!activated)
			if(W.force)
				if(!checkfail(A_FORCE))
					if(W.force >= extra3)
						activate()
					else
						artloc.visible_message("<span class='notice'>\The [src] appears to react to the force of \the [W].</span>")
						playsound(artloc,'sound/machines/twobeep.ogg',70,0)
						damage(W.force/2)
				else
					damage(W.force)
				if(W.hitsound)
					playsound(artloc, W.hitsound, 50, 1)

/obj/item/artifact/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj)
	if(usetype == A_TILE || usetype == A_TILE_A)
		var/doable = 1
		if(usetype == A_TILE_A)
			if(!Adjacent(user) || !target.Adjacent(user))
				doable = 0
		if(doable)
			if(istype(target,/mob))
				target.add_fingerprint(user)
				var/turf/targtile = get_turf(target)
				use_power(user,target,null,targtile,null)
			else if(istype(target,/obj))
				target.add_fingerprint(user)
				var/turf/targtile = get_turf(target)
				use_power(user,null,null,targtile,target)
			else
				use_power(user,null,null,target,null)

/obj/item/artifact/attack(mob/M, mob/living/user)
	if(usetype == A_ATTACK)
		M.add_fingerprint(user)
		var/turf/targtile = get_turf(M)
		use_power(user,M,null,targtile,null)
	else
		..()


/obj/item/artifact/pickup(mob/living/carbon/human/user as mob)
	if(on && !cooldown)
		if(power == A_SHOCKER)
			if(user.gloves)
				var/obj/item/clothing/gloves/G = user.gloves
				if(!G.siemens_coefficient) // insulated
					..()
					return
			user << "<span class='danger'>\The [src] shocks you!</span>"
			user.electrocute_act(extra1, src, 1.0, 0)
			var/list/throwdirections = list(NORTH,SOUTH,EAST,WEST)
			var/atom/throwtarg = get_edge_target_turf(user, pick(throwdirections))
			user.throw_at(throwtarg, 5, 2)
	..()

/obj/item/artifact/proc/set_type()
	var/size = rand(1,4)
	if(global.ankh == 0)
		if((z == 5 && prob(5)) || (z == 1 && prob(2)) || ((z == 3 || z == 4) && prob(3)))
			atype = A_ANKH
			message_admins("Ankh generated at [x],[y],[z]")
			global.ankh = 1
		else
			switch(size)
				if(1)
					atype = rand(0,5)
				if(2)
					atype = rand(6,11)
				if(3)
					atype = rand(13,17)
				if(4)
					atype = rand(18,22)
	else
		 // to make the rng less shit
		switch(size)
			if(1)
				atype = rand(0,5)
			if(2)
				atype = rand(6,11)
			if(3)
				atype = rand(13,17)
			if(4)
				atype = rand(18,22)
	//atype = rand(FIRST,LAST)
	switch(atype)
		// TINY
		if(A_GIZMO)
			title = "gizmo"
			power = pick(A_BLINK,A_RECHARGE,A_PHASE,A_ELECTRICS,A_INJECT)
			usetype = pick(A_CLICK,A_CONSTANT)
		if(A_GPS)
			title = "locator"
			power = pick(A_DETECT,A_LOCATE)
			usetype = A_CLICK
		if(A_TSPORTER)
			title = "transporter"
			power = pick(A_LIGHT,A_BLINK,A_MAGIC,A_CLEAN,A_CLOAK)
			usetype = A_TILE
		if(A_SPHERE)
			title = "sphere"
			power = pick(A_CLEAN,A_LUBE,A_MAGIC,A_FORCEWALL,A_BREATH,A_CLOAK)
			usetype = pick(A_CLICK,A_CONSTANT)
		if(A_DEVICE)
			title = "device"
			power = pick(A_DIRTY,A_LIGHT,A_RECHARGE,A_EMPS,A_THERMAL)
			usetype = pick(A_CLICK,A_CONSTANT,A_TILE)
		if(A_RING)
			title = "ring"
			power = pick(A_REFLECT,A_CLOAK,A_PHASE,A_BLINK,A_DIRTY,A_THERMAL)
			usetype = pick(A_CONSTANT)
			body_parts_covered = HANDS
			slot_flags = SLOT_GLOVES
		// MEDIUM
		if(A_ROD)
			title = "rod"
			power = pick(A_SHOCKER,A_PINKSLIME,A_HONK,A_FORCEPORT,A_LIGHT)
			usetype = pick(A_ATTACK,A_TILE,A_CONSTANT)
		if(A_BOX)
			title = "box"
			power = pick(A_REPAIR,A_RECHARGE,A_EMPS,A_BLOB,A_IRRADIATE)
			usetype = pick(A_CLICK,A_CONSTANT)
			item_state = "box"
		if(A_TOME)
			title = "tome"
			power = pick(A_SLEEP,A_NIGHTMARE,A_FORCEWALL,A_TRAVEL,A_WORMHOLE)
			usetype = A_CLICK
			item_state = "bible"
		if(A_TOTEM)
			title = "totem"
			power = pick(A_HEAL,A_SAPLIFE,A_TELEPORT,A_FORCEPORT,A_SHOCKER)
			usetype = pick(A_ATTACK,A_TILE)
		if(A_GUN)
			title = "gun"
			power = pick(A_SHOCKER,A_TELEPORT,A_FORCEPORT,A_EMPS,A_LUBE)
			usetype = A_TILE
			item_state = "disabler"
		if(A_INJECTOR)
			title = "injector"
			power = pick(A_INJECT,A_SURGERY,A_SMOKE,A_VIRUS,A_CLONEMKY)
			usetype = A_ATTACK
			item_state = "hypo"
		if(A_ANKH)
			title = "ankh"
			power = A_REVIVE
			slot_flags = SLOT_BACK
		// HUGE
		if(A_STAFF)
			title = "staff"
			power = pick(A_MAGIC,A_DECLONE,A_HEAL,A_HONK,A_PINKSLIME,A_SHIELD)
			usetype = A_TILE
			item_state = "staffofchaos"
		if(A_CUTTER)
			title = "cutter"
			power = pick(A_MINING,A_DEMOLISH,A_SURGERY,A_SEAL)
			usetype = A_TILE_A
			item_state = "gun"
		if(A_RENDER)
			title = "sickle"
			power = pick(A_PUSH,A_PULL,A_MELEE,A_WORMHOLE,A_SAPLIFE,A_TRAVEL)
			usetype = pick(A_CLICK,A_TILE)
			item_state = "render"
		if(A_ARMOR)
			title = "armor"
			power = pick(A_REFLECT,A_EMPS,A_ELECTRICS,A_IRRADIATE,A_SHIELD)
			usetype = A_RETALIATE
			item_state = "armor_reflec"
			alternate_worn_icon = 'icons/mob/sayu_onmob.dmi'
			body_parts_covered = CHEST
			slot_flags = SLOT_OCLOTHING
		if(A_HAMMER)
			title = "hammer"
			power = pick(A_MELEE,A_DEMOLISH,A_REPAIR,A_SMOKE,A_ELECTRIC)
			usetype = A_ATTACK
			item_state = "mjollnir"
		// STATIONARY
		if(A_PROBE)
			title = "probe"
			power = pick(A_PUSH,A_PULL,A_SLEEP,A_SEAL,A_XTINGUISH)
			usetype = A_CONSTANT
		if(A_PYRAMID)
			title = "pyramid"
			power = pick(A_MONOLITH,A_NIGHTMARE,A_EXPLODE,A_WORMHOLE,A_MUTATE)
			usetype = A_TOUCH_C
		if(A_MACHINE)
			title = "machine"
			power = pick(A_SLEEP,A_FIRE,A_ELECTRIC,A_EMPS,A_RECHARGE,A_REPAIR)
			usetype = pick(A_TOUCH_C,A_CONSTANT)
		if(A_CRYSTAL)
			title = "crystal"
			power = pick(A_SHIELD,A_HEAL,A_MUTATE,A_SLIME,A_PULL)
			usetype = A_CONSTANT
		if(A_CELL)
			title = "cell"
			power = pick(A_EXPLODE,A_HEAL,A_SHIELD,A_SEAL,A_FIRE)
			usetype = pick(A_CONSTANT,A_TOUCH_C)
	set_power()

/obj/item/artifact/proc/set_title() // Used for admin artifacts
	switch(atype)
		// TINY
		if(A_GIZMO)
			title = "gizmo"
		if(A_GPS)
			title = "locator"
		if(A_TSPORTER)
			title = "transporter"
		if(A_SPHERE)
			title = "sphere"
		if(A_DEVICE)
			title = "device"
		if(A_RING)
			title = "ring"
			body_parts_covered = HANDS
			slot_flags = SLOT_GLOVES
		// MEDIUM
		if(A_ROD)
			title = "rod"
		if(A_BOX)
			title = "box"
		if(A_TOME)
			title = "tome"
		if(A_TOTEM)
			title = "totem"
		if(A_GUN)
			title = "gun"
		if(A_INJECTOR)
			title = "injector"
		if(A_ANKH)
			title = "ankh"
			slot_flags = SLOT_BACK
		// HUGE
		if(A_STAFF)
			title = "staff"
		if(A_CUTTER)
			title = "cutter"
		if(A_RENDER)
			title = "sickle"
		if(A_ARMOR)
			title = "armor"
			body_parts_covered = CHEST
			slot_flags = SLOT_OCLOTHING
		if(A_HAMMER)
			title = "hammer"
		// STATIONARY
		if(A_PROBE)
			title = "probe"
		if(A_PYRAMID)
			title = "pyramid"
		if(A_MACHINE)
			title = "machine"
		if(A_CRYSTAL)
			title = "crystal"
		if(A_CELL)
			title = "cell"

/obj/item/artifact/proc/update_icons()
	if(!reverse && usetype == A_CONSTANT)
		icon_state = "[title][on]"
	else if(!reverse)
		if(cooldown == 1)
			icon_state = "[title]0"
		else
			icon_state = "[title][on]"
	else
		if(cooldown == 1 && on)
			icon_state = "[title]1"
		else
			icon_state = "[title]0"

/obj/item/artifact/examine()
	set src in usr
	..()
	if(integrity >= 30)
		usr << "<span class='notice'>A meter on the artifact reads: <b>[round(max(0,integrity))]% INTEGRITY</b></span>"
	else
		usr << "<span class='notice'>A meter on the artifact reads:</span> <b><span class='danger'>[round(max(0,integrity))]% INTEGRITY</b></span>"
	usr << "<span class='notice'>It appears to have a temperature of around [round(arttemp)].</span>"
	if(!activated)
		switch(stimnum)
			if(0)
				usr << "<span class='notice'>Its first mechanism is inactive. Its second mechanism is inactive.</span>"
			if(1)
				usr << "<span class='notice'>Its first mechanism is active. Its second mechanism is inactive.</span>"
	else
		usr << "<span class='notice'>It appears to be active.</span>"

/obj/item/artifact/admin
	adminart = 1

/obj/item/artifact/ankh
	name = "protective ankh"
	desc = "A gift from the gods."
	adminart = 2 // doesn't randomize, but can't be modified either
	atype = A_ANKH
	power = A_REVIVE
	title = "ankh"
	prefix = "protective"
	activated = 1
	on = 1
	alternate_worn_icon = 'icons/mob/sayu_onmob.dmi'

/obj/item/artifact/ankh/New()
	..()
	item_state = "ankh1"
	slot_flags = SLOT_BACK
	alternate_worn_icon = 'icons/mob/sayu_onmob.dmi'
	update_icons()
