
/obj/effect/knowspell/summon/castingmode = CAST_SPELL|CAST_SELF|CAST_MELEE

//
// Summon here: Drops it in the caster's square.  This is used for creating legacy enchanted items as well.
//

/obj/effect/knowspell/summon/here/artificer
	name = "artificer"
	desc = "Conjures a construct for putting souls into."
	chargemax = 600

	incantation = ""
	incant_volume = 0
	require_clothing = 0

/obj/effect/knowspell/summon/here/artificer/cast(var/mob/caster)
	var/turf/T = get_turf(caster)
	if(T)
		new /obj/structure/constructshell(T)
		return 1
	return 0

/obj/effect/knowspell/summon/here/wizard_armor
	name = "conjure wizard armor"
	desc = "One time use.  Calls forth a full set of space-worthy wizard armor."
	rechargable = 0
	chargemax = 1
	castingmode = CAST_SPELL|CAST_SELF

	incantation = ""
	incant_volume = 0
	require_clothing = 0

/obj/effect/knowspell/summon/here/wizard_armor/cast(var/mob/caster)
	var/turf/T = get_turf(caster)
	if(T)
		new /obj/item/clothing/shoes/sandal(T) //In case they've lost them.
		new /obj/item/clothing/gloves/magic(T)
		new /obj/item/clothing/suit/space/hardsuit/wizard(T)
		new /obj/item/clothing/head/helmet/space/hardsuit/wizard(T)
		return 1
	return 0

/obj/effect/knowspell/summon/here/portal
	name = "portal"
	desc = "Conjures a portal to and from a distant location."
	castingmode = CAST_SPELL|CAST_SELF

	chargemax = 600

	incantation = "Rasonicus Nai"
	incant_volume = 1
	var/turf/target_turf

/obj/effect/knowspell/summon/here/portal/prepare(mob/caster as mob)
	var/A = input(caster, "Area to teleport to", "Teleport", null) in teleportlocs
	if(A)
		activate(caster, teleportlocs[A])

/obj/effect/knowspell/summon/here/portal/before_cast(var/mob/caster, var/area/target)
	if(!istype(target))
		return 0
	..() // incantation
	var/list/possible_turfs = teleport_filter(area_contents(target))
	if(!possible_turfs.len)
		caster << "\red The magic refuses to activate!"
		return 0
	target_turf = pick(possible_turfs)
	return 1

/obj/effect/knowspell/summon/here/portal/cast(var/mob/caster)
	var/turf/source_turf = get_turf(caster)
	new /obj/effect/portal{auto_tele=0}(source_turf,target_turf, src)
	scatter_sparks(source_turf,6)
	if(source_turf.z != 2)
		new /obj/effect/portal{auto_tele=0}(target_turf,source_turf,src)
		scatter_sparks(target_turf,12) // that is intentionally a lot


//
// Summon at target: Creates a spell thrower and casts on the targeted square
//
/obj/effect/knowspell/summon/target
	castingmode = CAST_SPELL | CAST_RANGED | CAST_MELEE

/obj/effect/knowspell/summon/target/prepare(mob/user as mob)
	if(!cast_check(user))
		return
	create_spellthrower(user)

/obj/effect/knowspell/summon/target/attack(atom/target, mob/living/caster) //
	activate(caster,get_turf(target))
/obj/effect/knowspell/summon/target/afterattack(atom/target, mob/living/caster) // click map to cast
	activate(caster,get_turf(target))

/obj/effect/knowspell/summon/target/attack_self(mob/living/caster) // click self to cast (also pagedown)
	activate(caster,get_turf(caster))

/obj/effect/knowspell/summon/target/light
	name = "magical light"
	desc = "Summons a temporary magical light at the desired location."
	incantation = "DAANO FW'R"
	incant_volume = 1

	chargemax = 150
	require_clothing = 0

	cast(var/mob/caster,var/turf/target)
		new /obj/effect/spelleffect/light(target)

/obj/effect/knowspell/summon/target/fire
	name = "magical fire"
	desc = "Creates a magical field of fire."

	wand_state = "firewand"

	chargemax = 250

	incantation = "BURNUS THATUS"
	incant_volume = 2

	cast(var/mob/caster, var/turf/simulated/target)
		start_fire(target)

	attack_self()
		return // no burnus thisus

/obj/effect/knowspell/summon/target/forcewall
	name = "forcewall"
	desc = "Creates an impenetrable barrier"
	charge = 100

	wand_state = "telewand"

	incantation = "TARCOL MINTI ZHERI"
	incant_volume = 1
	require_clothing = 0
	chargemax = 70

	var/duration = 600

/obj/effect/knowspell/summon/target/forcewall/before_cast(var/mob/caster,var/atom/target)
	var/turf/T = get_turf(target)
	. = ..()
	if(T.flags&NOJAUNT || locate(/obj/effect/spelleffect/forcewall) in T)
		caster << "\red [src] refuses to activate!"
		return 0

/obj/effect/knowspell/summon/target/forcewall/cast(var/mob/caster, var/atom/target)
	var/turf/T = get_turf(target)
	if(T)
		new /obj/effect/spelleffect/forcewall(T,caster,duration)
		scatter_sparks(T)
		return 1
	return 0

/obj/effect/knowspell/summon/target/banana
	name = "magical banana peel"
	desc = "Creates an infinitely replicating, time-limited magical slipping tool"
	charge = 35
	incantation = "BANAN HOK"
	incant_volume = 2
	require_clothing = 0
	allow_stuncast = 1

/obj/effect/knowspell/summon/target/banana/cast(var/mob/caster, var/atom/target)
	var/turf/T = get_turf(target)
	if(T)
		new /obj/item/weapon/grown/bananapeel/wizard(T)
		scatter_sparks(T)
		return 1
	return 0

/obj/effect/knowspell/summon/target/smoke
	name = "smoke cloud"
	desc = "Creates a cloud of thick choking smoke."
	chargemax = 115

	incantation = ""
	incant_volume = 0
	require_clothing = 0

/obj/effect/knowspell/summon/target/smoke/cast(var/mob/caster, var/atom/target)
	var/turf/T = get_turf(target)
	if(T)
		smoke_cloud(T,4,1)
		return 1
	return 0

//
// Summon nearby: Summons in a number of nearby squares.
//
/obj/effect/knowspell/summon/nearby
	var/spawn_count = 1
	var/spawn_radius = 4
	var/spawn_time_min = 40
	var/spawn_time_max = 60

/obj/effect/knowspell/summon/nearby/proc/open_rifts(var/mob/caster)
	var/turf/center = get_turf(caster)
	if(!center)
		return 0

	var/list/turfs = list()
	for(var/turf/T in range(center,spawn_radius))
		if(T.flags&NOJAUNT)
			continue
		if(get_dist(T,center) < 2) // elbow room
			continue
		turfs += T

	var/sc = spawn_count
	if(!turfs.len)
		loc << "The gateway refuses to open!"
		return 0

	while(sc-- && turfs.len)
		var/turf/T = pick(turfs)
		new /obj/effect/spelleffect/summon(T, caster, rand(spawn_time_min,spawn_time_max),src)
	return 1

// The casting step is done by the gateway effects, jump from before cast to after cast
/obj/effect/knowspell/summon/nearby/activate(var/mob/caster)
	if(cast_check(caster) && before_cast(caster))
		after_cast(caster)
	return

/obj/effect/knowspell/summon/nearby/before_cast(var/mob/caster)
	var/turf/T = get_turf(caster)
	if(!T)
		return 0
	caster.Stun(spawn_time_min/20)
	if(open_rifts(caster))
		incant(caster)
		return 1
	return 0
/obj/effect/knowspell/summon/nearby/after_cast()
	if(rechargable)
		charge = 0
		spawn(spawn_time_min)
			start_recharge()
	else
		charge = max(0,charge-1)
		spawn(spawn_time_max * 2)
			if(src && charge <= 0)
				del src


/obj/effect/knowspell/summon/nearby/carp
	name = "summon bigger fish"
	desc = "Calls forth monstrous biting baddies."

	prevent_centcom = 1 // why would you...
	rechargable = 0
	chargemax = 2

	incantation = "DAR TZAN DROD"
	incant_volume = 2
	require_clothing = 1

	spawn_count = 4
	spawn_time_min = 30
	spawn_time_max = 90

	cast(mob/caster, turf/target)
		new /mob/living/simple_animal/hostile/carp(target)


/obj/effect/knowspell/summon/nearby/creature
	name = "summon gnashing evil"
	desc = "Calls forth monstrous biting baddies."

	prevent_centcom = 1 // no
	rechargable = 0
	chargemax = 1

	incantation = "SOLIT KI SHIN"

	spawn_count = 8
	spawn_radius = 12
	spawn_time_min = 10
	spawn_time_max = 150

	cast(mob/caster, turf/target)
		new /mob/living/simple_animal/hostile/creature(target)


//
// Global summon: Affects every living human in play, caster included.
//
/obj/effect/knowspell/summon/world
	var/list/targets
	var/list/spawns_possible = list(/obj/item/weapon/reagent_containers/spray/waterflower = list("name" = "evil flower"))		 // path = list(variable changes)
	castingmode = CAST_SPELL

/obj/effect/knowspell/summon/world/proc/summon_effect(var/atom/target)
	return 1
/obj/effect/knowspell/summon/world/proc/target_effect(var/atom/target) //
	return 1

/obj/effect/knowspell/summon/world/before_cast(var/mob/caster)
	if(!(src in caster.contents))
		caster << "<span class='danger'>You must learn this spell before casting it!</span>"
		return 0
	else
		targets = list()
		for(var/mob/living/carbon/human/H in living_mob_list)
			if(H.stat & DEAD)
				continue
			targets += H
		incant(caster)
		return 1

/obj/effect/knowspell/summon/world/cast(var/mob/caster)
	for(var/atom/A in targets)
		var/turf/T = get_turf(A)

		if(T.flags&NOJAUNT)
			continue

		var/spawntype = pick(spawns_possible)
		var/list/changed_vars = spawns_possible[spawntype]

		var/atom/S = new spawntype(T)

		if(istype(changed_vars))
			for(var/entry in S.vars & changed_vars)
				S.vars[entry] = changed_vars[entry]

		summon_effect(S)
		target_effect(A)

	return 1

/obj/effect/knowspell/summon/world/guns
	name = "summon guns"
	desc = "Arms your enemies against each other.  And, as a side effect, against you.  Caster discretion advised."

	rechargable = 0
	chargemax = 1

	prevent_centcom = 0
	require_clothing = 0

	incantation = "FAUSTN BARGN"
	incant_volume = 2

	spawns_possible = list(
		/obj/item/weapon/gun/energy/taser, /obj/item/weapon/gun/energy/gun, /obj/item/weapon/gun/energy/laser,/obj/item/weapon/gun/projectile,
		/obj/item/weapon/gun/projectile/revolver/detective,/obj/item/weapon/gun/projectile/automatic/c20r,/obj/item/weapon/gun/energy/gun/nuclear,
		/obj/item/weapon/gun/projectile/automatic/pistol/deagle/camo,/obj/item/weapon/gun/projectile/automatic/gyropistol,/obj/item/weapon/gun/energy/pulse,
		/obj/item/weapon/gun/projectile/automatic/pistol,/obj/item/weapon/gun/energy/lasercannon,/obj/item/weapon/gun/projectile/shotgun,
		/obj/item/weapon/gun/projectile/shotgun/combat,/obj/item/weapon/gun/projectile/revolver/mateba,/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow,
		/obj/item/weapon/gun/projectile/automatic/l6_saw)

/obj/effect/knowspell/summon/world/guns/summon_effect(var/atom/A)

	if(istype(A,/obj/item/weapon/gun))
		var/obj/item/weapon/gun/gat = A
		gat.pin = /obj/item/device/firing_pin

	if(istype(A,/obj/item/weapon/gun/projectile/automatic/pistol))
		new /obj/item/weapon/suppressor(A.loc)
	return 1

/obj/effect/knowspell/summon/world/guns/target_effect(var/mob/living/carbon/human/H)
	H.loc.visible_message("\i[magic_soundfx()]")
	if(!istype(H) || H.stat == 2 || !(H.client) || is_special_character(H)) return 1
	if(prob(25))
		ticker.mode.traitors += H.mind
		H.mind.special_role = "traitor"
		var/datum/objective/survive/survive = new
		survive.owner = H.mind
		H.mind.objectives += survive
		H.attack_log += "\[[time_stamp()]\] <font color='red'>Was made into a survivor, and trusts no one!</font>"
		H << "<B>You are the survivor! Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...</B>"
		var/obj_count = 1
		for(var/datum/objective/OBJ in H.mind.objectives)
			H << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
			obj_count++


/obj/effect/knowspell/summon/world/puppies
	name = "summon pets"
	desc = "Puts adorable animals at the feet of all living humans.  Maybe this will soothe the savage beasts?"

	rechargable = 0
	chargemax = 1

	prevent_centcom = 1
	require_clothing = 0

	incantation = "DORBL PUPIIZ"
	incant_volume = 1 // sssh

	spawns_possible = list(
		/mob/living/simple_animal/corgi, /mob/living/simple_animal/corgi/puppy, /mob/living/simple_animal/cat, /mob/living/simple_animal/chicken,
		/obj/item/weapon/ore = list("name" = "pet rock"),
		/mob/living/simple_animal/corgi/puppy/smart
		)

/obj/effect/knowspell/summon/world/puppies/summon_effect(var/atom/movable/AM)
	step_rand(AM)
	return 1

/obj/effect/knowspell/summon/world/puppies/target_effect(var/mob/living/ML)
	if(istype(ML))
		ML.Stun(2) // IS THAT A PUPPY
	return 1

/obj/effect/knowspell/summon/world/bananas
	name = "summon bananas"
	desc = "A slip hazard for everyone.  Honk."

	rechargable = 1
	chargemax = 450

	prevent_centcom = 0
	require_clothing = 0

	incantation = "EI HONK"
	incant_volume = 2

	spawns_possible = list(/obj/item/weapon/grown/bananapeel/wizard, /obj/item/weapon/grown/bananapeel/wizard, /obj/item/weapon/grown/bananapeel/wizard, /obj/item/weapon/grown/bananapeel, /obj/item/weapon/soap)

/obj/effect/knowspell/summon/world/bananas/summon_effect(var/obj/item/I)
	for(var/mob/living/M in I.loc)
		if(M.stat) continue
		I.loc = get_step(M,M.dir) // put in front of them
		return