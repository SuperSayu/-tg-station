/obj/item/weapon/grenade/chem_grenade/dirt
	name = "Dirty Grenade"
	desc = "From the makers of BLAM! brand foaming space cleaner, this bomb guarantees steady work for any janitor."
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/list/muck = list("blood","carbon","flour","radium")
		var/filth = pick(muck - "radium") // not usually radioactive

		B1.reagents.add_reagent(filth,25)
		if(prob(25))
			B1.reagents.add_reagent(pick(muck - filth,25)) // but sometimes...

		beakers += B1
		CreateDefaultTrigger(/obj/item/device/assembly/timer)
		icon_state = "grenade"

/obj/item/weapon/grenade/chem_grenade/meat
	name = "Meat Grenade"
	desc = "Not always as messy as the name implies."
	stage = 2


	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("blood",60)
		if(prob(5))
			B1.reagents.add_reagent("blood",1) // Quality control problems, causes a mess
		B2.reagents.add_reagent("clonexadone",30)

		beakers += B1
		beakers += B2

		CreateDefaultTrigger(/obj/item/device/assembly/timer)
		icon_state = "grenade"

/obj/item/weapon/grenade/chem_grenade/holywater
	name = "Holy Water Grenade"
	desc = "Then shalt thou count to three, no more, no less."
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B = new(src)
		B.reagents.add_reagent("holywater",100)
		beakers += B
		icon_state = "grenade"
		CreateDefaultTrigger(/obj/item/device/assembly/timer)
		var/obj/item/device/assembly/timer/T = nadeassembly.a_right
		T.time = 3

/obj/item/weapon/grenade/chem_grenade/soap
	name = "Soap Grenade"
	desc = "Not necessarily as clean as the name implies."
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("cornoil",60)
		B2.reagents.add_reagent("enzyme",5)
		B2.reagents.add_reagent("ammonia",30)

		beakers += B1
		beakers += B2
		CreateDefaultTrigger(/obj/item/device/assembly/timer)
		icon_state = "grenade"

// -------------------------------------
// Grenades using new grenade assemblies
// -------------------------------------
/obj/item/weapon/grenade/chem_grenade/lube
	name = "Lubricant Remote Mine"
	desc = "For that perfectly timed distraction.  Has a remote detonator."
	stage = 2

	icon_state = "grenade"
	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		B1.reagents.add_reagent("lube",50)
		beakers += B1

		CreateDefaultTrigger(/obj/item/device/assembly/signaler)

// Basic explosion grenade
/obj/item/weapon/grenade/chem_grenade/explosion
	name = "Grenade"
	stage = 2

	icon_state = "grenade"
	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B1.reagents.add_reagent("glycerol",30) // todo: someone says NG is overpowered, test.
		B1.reagents.add_reagent("sacid",15)
		B2.reagents.add_reagent("sacid",15)
		B2.reagents.add_reagent("pacid",30)
		beakers += B1
		beakers += B2

		CreateDefaultTrigger(/obj/item/device/assembly/timer)

// Assembly Variants
/obj/item/weapon/grenade/chem_grenade/explosion/remote
	name = "Remote Mine"
	desc = "A hand held grenade, with a remote detonator."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/signaler)

/obj/item/weapon/grenade/chem_grenade/explosion/prox
	name = "Proximity Mine"
	desc = "A hand held grenade, with a proximity sensor."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/prox_sensor)

/obj/item/weapon/grenade/chem_grenade/explosion/mine
	name = "Contact Mine"
	desc = "A hand held grenade, rigged with a pressure switch."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/mousetrap)

// Basic EMP grenade
/obj/item/weapon/grenade/chem_grenade/emp
	name = "EMP Grenade"
	stage = 2

	icon_state = "grenade"
	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B1.reagents.add_reagent("uranium",50)
		B2.reagents.add_reagent("iron",50)
		beakers += B1
		beakers += B2

		CreateDefaultTrigger(/obj/item/device/assembly/timer)

// Assembly Variants
/obj/item/weapon/grenade/chem_grenade/emp/remote
	name = "Remote EMP Grenade"
	desc = "A hand held grenade, with a remote detonator."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/signaler)

/obj/item/weapon/grenade/chem_grenade/emp/prox
	name = "Proximity EMP Mine"
	desc = "A hand held grenade, with a proximity sensor."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/prox_sensor)

/obj/item/weapon/grenade/chem_grenade/emp/mine
	name = "EMP Mine"
	desc = "A hand held grenade, rigged with a pressure switch."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/mousetrap)

// --------------------------------------
//  Dangerous slime core grenades
// --------------------------------------
/obj/item/weapon/grenade/chem_grenade/large/bluespace
	name = "Bluespace Slime Grenade"
	desc = "A standard grenade containing weaponized slime extract."
	stage = 2

	New()
		..()
		var/obj/item/slime_extract/bluespace/B1 = new(src)
		B1.Uses = rand(1,3)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B2.reagents.add_reagent("plasma",5 * B1.Uses)
		beakers += B1
		beakers += B2
		CreateDefaultTrigger(/obj/item/device/assembly/timer)
		icon_state = "large_grenade_locked"

/obj/item/weapon/grenade/chem_grenade/large/bluespace/prox
	name = "Bluespace Slime Proximity Mine"
	desc = "A grenade containing weaponized slime extract, with an attached proximity sensor."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/prox_sensor)

/obj/item/weapon/grenade/chem_grenade/large/bluespace/mine
	name = "Bluespace Slime Mine"
	desc = "A grenade containing weaponized slime extract, with an attached pressure switch."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/mousetrap)

/obj/item/weapon/grenade/chem_grenade/large/bluespace/remote
	name = "Remote Bluespace Slime Grenade"
	desc = "A grenade containing weaponized slime extract, with an attached remote detonator."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/signaler)

/obj/item/weapon/grenade/chem_grenade/large/monster
	name = "Gold Slime Grenade"
	desc = "A standard grenade containing weaponized slime extract."
	stage = 2

	New()
		..()
		var/obj/item/slime_extract/gold/B1 = new(src)
		B1.Uses = rand(1,3)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B2.reagents.add_reagent("plasma",5 * B1.Uses)
		beakers += B1
		beakers += B2
		CreateDefaultTrigger(/obj/item/device/assembly/timer)
		icon_state = "large_grenade_locked"

/obj/item/weapon/grenade/chem_grenade/large/monster/prox
	name = "Gold Slime Proximity Mine"
	desc = "A grenade containing weaponized slime extract, with an attached proximity sensor."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/prox_sensor)

/obj/item/weapon/grenade/chem_grenade/large/monster/mine
	name = "Gold Slime Mine"
	desc = "A grenade containing weaponized slime extract, with an attached pressure switch."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/mousetrap)

/obj/item/weapon/grenade/chem_grenade/large/monster/remote
	name = "Remote Gold Slime Grenade"
	desc = "A grenade containing weaponized slime extract, with an attached remote detonator."
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/signaler)

/obj/item/weapon/grenade/chem_grenade/large/feast
	name = "Silver Slime Grenade"
	desc = "A standard grenade containing weaponized slime extract."
	stage = 2

	New()
		..()
		var/obj/item/slime_extract/silver/B1 = new(src)
		B1.Uses = rand(1,3)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B2.reagents.add_reagent("plasma",5 * B1.Uses)
		beakers += B1
		beakers += B2
		CreateDefaultTrigger(/obj/item/device/assembly/timer)
		icon_state = "large_grenade_locked"

/obj/item/weapon/grenade/clusterbuster/bluespace
	name = "Bluespace Megabomb"
	desc = "Widely regarded as proof that while there is a God, He is Insane."
	payload = /obj/item/weapon/grenade/chem_grenade/large/bluespace
/obj/item/weapon/grenade/clusterbuster/monster
	name = "Monster Megabomb"
	desc = "Widely regarded as proof that there is no God."
	payload = /obj/item/weapon/grenade/chem_grenade/large/monster

// --------------------------------------
//  Syndie Kits
// --------------------------------------

/obj/item/weapon/storage/box/syndie_kit/remotegrenade
	name = "Remote Grenade Kit"
	New()
		..()
		new /obj/item/weapon/grenade/chem_grenade/explosion/remote(src)
		new /obj/item/device/multitool(src) // used to adjust the chemgrenade's signaller
		new /obj/item/device/assembly/signaler(src)
		return
/obj/item/weapon/storage/box/syndie_kit/remoteemp
	name = "Remote EMP Kit"
	New()
		..()
		new /obj/item/weapon/grenade/chem_grenade/emp/remote(src)
		new /obj/item/device/multitool(src) // used to adjust the chemgrenade's signaller
		new /obj/item/device/assembly/signaler(src)
		return
/obj/item/weapon/storage/box/syndie_kit/remotelube
	name = "Remote Lube Kit"
	New()
		..()
		new /obj/item/weapon/grenade/chem_grenade/lube(src)
		new /obj/item/device/multitool(src) // used to adjust the chemgrenade's signaller
		new /obj/item/device/assembly/signaler(src)
		return
// --------------------------------------
// Clusterbuster Variable Payload Grenade
//   Adapted from flashbang/clusterbang
// --------------------------------------

/obj/item/weapon/grenade/clusterbuster
	desc = "This highly intimidating bunch of hardware seems eager to be let loose."
	name = "Clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"
	var/payload = /obj/item/weapon/grenade/flashbang


// Subtypes

// Serious grenades
/obj/item/weapon/grenade/clusterbuster/explosion
	name = "Cluster Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/explosion
/obj/item/weapon/grenade/clusterbuster/emp
	name = "Electromagnetic Storm"
	payload = /obj/item/weapon/grenade/chem_grenade/emp
/obj/item/weapon/grenade/clusterbuster/smoke
	name = "Ninja Vanish"
	payload = /obj/item/weapon/grenade/smokebomb

// Not serious grenades
/obj/item/weapon/grenade/clusterbuster/meat
	name = "Mega Meat Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/meat
/obj/item/weapon/grenade/clusterbuster/booze
	name = "Booze Grenade"
	payload = /obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink
/obj/item/weapon/grenade/clusterbuster/honk
	name = "Mega Honk Grenade"
	payload = /obj/item/weapon/bananapeel
/obj/item/weapon/grenade/clusterbuster/xmas
	name = "Christmas Miracle"
	payload = /obj/item/weapon/a_gift
/obj/item/weapon/grenade/clusterbuster/soap
	name = "Megamaid's Passive-Aggressive Soap-creation Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/soap
/obj/item/weapon/grenade/clusterbuster/dirt
	name = "Megamaid's Job Security Grenade"
	payload = /obj/effect/decal/cleanable/random
/obj/item/weapon/grenade/clusterbuster/megadirt
	name = "Megamaid's Revenge Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/dirt
/obj/item/weapon/grenade/clusterbuster/inferno
	name = "Little Boy"
	payload = /obj/item/weapon/grenade/chem_grenade/incendiary

// Grenades that should never see the light of day
/obj/item/weapon/grenade/clusterbuster/apocalypse
	name = "Apocalypse Bomb"
	desc = "No matter what, do not EVER use this."
	payload = /obj/machinery/singularity
/obj/item/weapon/grenade/clusterbuster/apocalypse/fake
	payload = /obj/item/toy/spinningtoy

/obj/item/weapon/grenade/clusterbuster/ultima
	name = "The Final Boss"
	desc = "For when you really, truly need to kill people."
	payload = /obj/item/weapon/grenade/chem_grenade/explosion

/obj/item/weapon/grenade/clusterbuster/lube
	name = "Newton's First Law"
	desc = "An object in motion remains in motion."
	payload = /obj/item/weapon/grenade/chem_grenade/lube


/obj/item/weapon/grenade/clusterbuster/bluespace
	name = "Maximum Warp"
	desc = "Spacetime: Nice job breaking it, hero."
	payload = /obj/item/weapon/grenade/chem_grenade/large/bluespace
/obj/item/weapon/grenade/clusterbuster/monster
	name = "The Monster Mash"
	desc = "It's a graveyeard smash."
	payload = /obj/item/weapon/grenade/chem_grenade/large/monster
/obj/item/weapon/grenade/clusterbuster/banquet
	name = "Bork Bork Bonanza"
	desc = "Bork bork bork."
	payload = /obj/item/weapon/grenade/clusterbuster/banquet/child
	child
		payload = /obj/item/weapon/grenade/chem_grenade/large/feast

// Mob spawning grenades
/obj/item/weapon/grenade/clusterbuster/aviary
	name = "Poly-Poly Grenade"
	desc = "That's an uncomfortable number of birds."
	payload = /mob/living/simple_animal/parrot
/obj/item/weapon/grenade/clusterbuster/monkey
	name = "Barrel of Monkeys"
	desc = "Not really that much fun."
	payload = /mob/living/carbon/monkey
/obj/item/weapon/grenade/clusterbuster/fluffy
	name = "Fluffy Love Bomb"
	desc = "Exactly as snuggly as it sounds."
	payload = /mob/living/simple_animal/corgi/puppy

/obj/item/weapon/grenade/clusterbuster/prime()
	var/numspawned = rand(4,8)
	var/again = 0
	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			again++
			numspawned --

	for(,numspawned > 0, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/clusterbuster/node(src.loc,payload,name)//Launches payload
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	for(,again > 0, again--)
		spawn(0)
			new /obj/item/weapon/grenade/clusterbuster/segment(src.loc,payload,name)//Creates a 'segment' that launches more payloads
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	spawn(0)
		del(src)
		return

/obj/item/weapon/grenade/clusterbuster/segment
	desc = "What's happening? Aaah!"
	name = "clusterbuster segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"

/obj/item/weapon/grenade/clusterbuster/segment/New(var/turf/newloc,var/T,var/N)//Segments should never exist except part of the clusterbang, since these immediately 'do their thing' and asplode
	icon_state = "clusterbang_segment_active"
	active = 1
	//banglet = 1
	payload = T
	name = N
	var/stepdist = rand(1,5)		//How far to step
	var/temploc = src.loc			//Saves the current location to know where to step away from
	walk_away(src,temploc,stepdist)	//I must go, my people need me
	var/dettime = rand(15,60)
	spawn(dettime)
		prime()
	..()

/obj/item/weapon/grenade/clusterbuster/segment/prime()
	var/numspawned = rand(4,8)
	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			numspawned --

	for(,numspawned > 0, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/clusterbuster/node(src.loc,payload)
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	spawn(0)
		del(src)
		return

/obj/item/weapon/grenade/clusterbuster/node/New(var/turf/newloc,var/T,var/N)
	spawn(0)
		icon_state = "flashbang_active"
		active = 1
//		banglet = 1
		payload = T
		name = N
		var/stepdist = rand(1,4)
		var/temploc = src.loc
		walk_away(src,temploc,stepdist)
		var/dettime = rand(15,60)
		spawn(dettime)
			var/atom/A = new payload(loc)
			if(istype(A,/obj/item/weapon/grenade))
				A:prime()
			if(istype(A,/obj/machinery/singularity)) // I can't emphasize enough how much you should never use this grenade
				A:energy = 200
			del src
	..()