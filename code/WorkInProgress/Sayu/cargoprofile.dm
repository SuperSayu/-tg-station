/datum/cargoprofile
	var/name = "All Items"
	var/id = "all" // unique ID for the UI
	var/enabled = 1
	var/eject_speed = 1 // will change when emagged
	var/const/BIG_OBJECT_WORK = 10
	var/const/MOB_WORK = 10
	var/obj/machinery/programmable/master = null
	var/universal = 0 // set when both unary and binary machines work
	var/mobcheck = 0

	var/list/whitelist = list(/obj/item,/obj/structure/closet,/obj/structure/bigDelivery,/obj/machinery/portable_atmospherics)
	var/list/blacklist = null
	var/dedicated_path = null // When constructing a new machine with this as default program, create a machine of the specified type instead.


	//contains: called to determine if an object/mob will be sorted by this profile
	//return 1 for any sortable item
	proc/contains(var/atom/A)
		if(!istype(A,/obj))
			return 0
		var/obj/O = A
		if(O.anchored)
			return 0
		//If you are using both white and blacklists, blacklists are absoulte, no matter what is whitelisted.
		//I understand this has some limitations.  You cannot whitelist all items, blacklist weapons,
		// and then whitelist a specific weapon.  Them's the breaks, kid.
		if(blacklist)
			for(var/T in blacklist)
				if(istype(A,T))
					return 0
		if(whitelist)
			for(var/T in whitelist)
				if(istype(A,T))
					return 1
			return 0
		return 1


	//inlet_reaction: called when a filtered item is chosen by this profile.
	//W: Item chosen
	//S: input turf location
	//remaining: counts down how much more work the unloader wants to do this turn.
	//return the amount of work done.
	proc/inlet_reaction(var/atom/W,var/turf/S,var/remaining)
		if(!W || !S || !master)
			return 0

		if(istype(W,/obj/item))
			var/obj/item/I = W
			if(I.w_class > remaining)
				return 0
			I.loc = master
			master.types[W.type] = src
			return I.w_class


		if(istype(W,/obj/structure) || istype(W,/obj/machinery)) // closets, big deliveries, portable atmospherics, unconnected stuff
			if(remaining < BIG_OBJECT_WORK)
				return 0
			var/obj/O = W
			O.loc = master
			master.types[O.type] = src
			return BIG_OBJECT_WORK

		//Not item, structure, machinery, or mob
		return 0

	//outlet_reaction: called when a stored object is ejected
	//W: the item in question
	//D: the destination turf
	proc/outlet_reaction(var/atom/W,var/turf/D)
		if(!W || !D || !master)
			return

		if(master.emagged)
			// emagging is not an industry-approved practice.
			// some malfunctions may occur.
			eject_speed = rand(0,4)
			D = get_step(D,master.outdir)
			while(prob(20))
				if(master.outdir == NORTH || master.outdir == SOUTH)
					D = get_step(D,pick(EAST,WEST,master.outdir))
				else
					D = get_step(D,pick(NORTH,SOUTH,master.outdir))

		if(istype(W,/obj))
			var/obj/O = W
			O.loc = master.loc
			O.dir = master.outdir
			O.throw_at(D,eject_speed,eject_speed)
			return

//----------------------------------------------------------------------------
// Profiles
//----------------------------------------------------------------------------

/datum/cargoprofile/boxes
	name = "Other Containers"
	id = "boxes"
	blacklist = null
	whitelist = list(/obj/item/weapon/storage, /obj/item/weapon/moneybag, /obj/item/weapon/evidencebag,
					/obj/item/weapon/tray, /obj/item/pizzabox, /obj/item/weapon/clipboard,
					/obj/item/smallDelivery, /obj/structure/bigDelivery)

/datum/cargoprofile/cargo
	name = "Move Cargo Boxes"
	id = "cargo"
	blacklist = null
	whitelist = list(/obj/structure/closet,/obj/structure/ore_box)

/datum/cargoprofile/supplies
	name = "Building Supplies"
	id = "supplies"
	blacklist = null
	whitelist = list(/obj/item/weapon/cable_coil,/obj/item/stack/rods,
					/obj/item/stack/sheet/metal,/obj/item/stack/sheet/plasteel,
					/obj/item/stack/sheet/glass,/obj/item/stack/sheet/rglass,
					/obj/item/stack/tile,/obj/item/weapon/light,
					/obj/item/weapon/table_parts)
	//todo: maybe stack things while we're here?

/datum/cargoprofile/exotics
	name = "Exotic materials"
	id = "exotics"
	blacklist = null
	whitelist = list(/obj/item/weapon/coin, /obj/item/weapon/spacecash, /obj/item/seeds,
					/obj/item/stack/sheet/mineral,/obj/item/stack/sheet/wood,/obj/item/stack/sheet/leather)

/datum/cargoprofile/organics
	name = "Organics, chemicals, and Paraphernalia"
	id = "organics"
	blacklist = null
	whitelist = list(/obj/item/weapon/tank,/obj/item/weapon/reagent_containers,
					/obj/item/stack/medical,/obj/item/weapon/storage/pill_bottle,/obj/item/weapon/gun/syringe,
					/obj/item/weapon/plastique,/obj/item/weapon/grenade,/obj/item/ammo_magazine,
					/obj/item/weapon/gun/grenadelauncher,/obj/item/weapon/flamethrower,	/obj/item/weapon/lighter,
					/obj/item/weapon/match,/obj/item/weapon/weldingtool)

/datum/cargoprofile/food
	name = "Food"
	id = "food"
	blacklist = null // something should probably go here
	whitelist = list(/obj/item/weapon/reagent_containers/food)

/datum/cargoprofile/chemical
	name = "Chemicals and Paraphernalia"
	id = "chemical"
	blacklist = list(/obj/item/weapon/reagent_containers/food)
	whitelist = list(/obj/item/weapon/reagent_containers,/obj/item/stack/medical,/obj/item/weapon/storage/pill_bottle,
					/obj/item/weapon/gun/syringe,/obj/item/weapon/grenade/chem_grenade,/obj/item/weapon/dnainjector,
					/obj/item/weapon/storage/belt/medical,/obj/item/weapon/storage/firstaid,/obj/item/weapon/implanter)

/datum/cargoprofile/pressure
	name = "Tanks and Pressure Vessels"
	id = "pressure"
	blacklist = null
	whitelist = list(/obj/item/weapon/tank,/obj/machinery/portable_atmospherics,
					/obj/item/weapon/flamethrower)
					//Am I missing any?
/datum/cargoprofile/pressure/empty
	name = "Empty Tanks"
	id = "pressure-low"
	var/lowpressure = ONE_ATMOSPHERE

	contains(var/atom/A)
		if(..())
			var/pressure = ONE_ATMOSPHERE * 10 // In case of fallthrough, fail test
			if(istype(A,/obj/item/weapon/tank))
				var/obj/item/weapon/tank/T = A
				pressure = T.air_contents.return_pressure()
			if(istype(A,/obj/item/weapon/flamethrower))
				var/obj/item/weapon/flamethrower/T = A
				if(!T.ptank)
					return 0
				pressure = T.ptank.air_contents.return_pressure()
			if(istype(A,/obj/machinery/portable_atmospherics))
				var/obj/machinery/portable_atmospherics/P = A
				pressure = P.air_contents.return_pressure()

			if(pressure < lowpressure)
				return 1

		return 0// Not container or failed low pressure check

/datum/cargoprofile/pressure/full
	name = "Full Tanks"
	id = "pressure-high"
	var/highpressure = ONE_ATMOSPHERE * 15 // stolen from canister.dm; Is this right?

	contains(var/atom/A)
		if(..())
			var/pressure = 0 // In case of fallthrough, fail test
			if(istype(A,/obj/item/weapon/tank))
				var/obj/item/weapon/tank/T = A
				pressure = T.air_contents.return_pressure()
			if(istype(A,/obj/item/weapon/flamethrower))
				var/obj/item/weapon/flamethrower/T = A
				if(!T.ptank)
					return 0
				pressure = T.ptank.air_contents.return_pressure()
			if(istype(A,/obj/machinery/portable_atmospherics))
				var/obj/machinery/portable_atmospherics/P = A
				pressure = P.air_contents.return_pressure()

			if(pressure > highpressure)
				return 1

		return 0// Not container or failed high pressure check

/datum/cargoprofile/clothing
	name = "Crew Kit"
	id = "clothing"
	blacklist = list(/obj/item/weapon/tank/plasma,/obj/item/weapon/tank/anesthetic, // the rest are air tanks
					/obj/item/clothing/mask/facehugger) // NOT CLOTHING AT ALLLLL
	whitelist = list(/obj/item/clothing,/obj/item/weapon/storage/belt,/obj/item/weapon/storage/backpack,
					/obj/item/device/radio/headset,/obj/item/device/pda,/obj/item/weapon/card/id,/obj/item/weapon/tank,
					/obj/item/weapon/handcuffs, /obj/item/weapon/legcuffs)

/datum/cargoprofile/trash
	name = "Trash"
	id = "trash"
	//Note that this filters out blueprints because they are a paper item.  Do NOT throw out the station blueprints unless you be trollin'.
	blacklist = null
	whitelist = list(/obj/item/trash,/obj/item/toy,/obj/item/weapon/ectoplasm,/obj/item/weapon/bananapeel,/obj/item/weapon/broken_bottle,/obj/item/weapon/bikehorn,
					/obj/item/weapon/cigbutt,/obj/item/weapon/contraband,/obj/item/weapon/corncob,/obj/item/weapon/paper,/obj/item/weapon/shard,
					/obj/item/weapon/sord,/obj/item/weapon/photo,/obj/item/weapon/folder,
					/obj/item/blueprints,/obj/item/weapon/contraband,/obj/item/weapon/kitchen,/obj/item/weapon/book,/obj/item/clothing/mask/facehugger)

/datum/cargoprofile/weapons
	name = "Weapons & Illegals"
	id = "weapons"
	blacklist = null
	//This one is hard since 'weapon contains a lot of things better categorized as devices
	whitelist = list(/obj/item/weapon/banhammer,/obj/item/weapon/sord,/obj/item/weapon/butch,/obj/item/weapon/claymore,/obj/item/weapon/holo/esword,
					/obj/item/weapon/flamethrower,/obj/item/weapon/grenade,/obj/item/weapon/gun,/obj/item/weapon/hatchet,/obj/item/weapon/katana,
					/obj/item/weapon/kitchenknife,/obj/item/weapon/melee,/obj/item/weapon/nullrod,/obj/item/weapon/pickaxe,/obj/item/weapon/twohanded,
					/obj/item/weapon/plastique,/obj/item/weapon/scalpel,/obj/item/weapon/shield,/obj/item/weapon/grown/deathnettle)

/datum/cargoprofile/tools
	name = "Devices & Tools"
	id = "tools"
	blacklist = null
	whitelist = list(/obj/item/device,/obj/item/weapon/card,/obj/item/weapon/cartridge,/obj/item/weapon/cautery,/obj/item/weapon/cell,/obj/item/weapon/circuitboard,
					/obj/item/weapon/aiModule,/obj/item/weapon/airalarm_electronics,/obj/item/weapon/airlock_electronics,/obj/item/weapon/circular_saw,
					/obj/item/weapon/cloaking_device,/obj/item/weapon/crowbar,/obj/item/weapon/disk,/obj/item/weapon/firealarm_electronics,/obj/item/weapon/hand_tele,
					/obj/item/weapon/hand_labeler,/obj/item/weapon/hemostat,/obj/item/weapon/mop,/obj/item/weapon/locator,/obj/item/weapon/minihoe,
					/obj/item/weapon/packageWrap,/obj/item/weapon/paint,/obj/item/weapon/pen,/obj/item/weapon/pickaxe,/obj/item/weapon/pinpointer,
					/obj/item/weapon/rcd,/obj/item/weapon/rcd_ammo,/obj/item/weapon/retractor,/obj/item/weapon/rsf,/obj/item/weapon/rsp,/obj/item/weapon/scalpel,
					/obj/item/weapon/screwdriver,/obj/item/weapon/shovel,/obj/item/weapon/soap,/obj/item/weapon/stamp,/obj/item/weapon/tray,/obj/item/weapon/weldingtool,
					/obj/item/weapon/wirecutters,/obj/item/weapon/wrench,/obj/item/weapon/extinguisher)

/datum/cargoprofile/finished
	name = "Completed Robots"
	id = "finished"
	blacklist = null
	whitelist = list(/obj/mecha,/obj/machinery/bot,/mob/living/silicon/robot)
	mobcheck = 1
	//todo: detect and allow finished cyborg endoskeletons with no brain
	contains(var/atom/A)
		if(..())
			return 1
		if(istype(A,/mob))
			if(blacklist)
				for(var/T in blacklist)
					if(istype(A,T))
						return 0
			if(whitelist)
				for(var/T in whitelist)
					if(istype(A,T))
						return 1
				return 0
			return 1
		return 0



//----------------------------------------------------------------------------
// Overrides (Special Functions)
//----------------------------------------------------------------------------

/datum/cargoprofile/cargo/unload
	name = "Unload Cargo Boxes"
	id = "cargounload"
	enabled = 0
	dedicated_path = /obj/machinery/programmable/unloader

	//override the detection to only accept crates with something in it.
	//if it doesn't, this object may be handled by another handler.
	contains(var/atom/A)
		if(..(A))
			if(istype(A,/obj/structure/closet))
				var/obj/structure/closet/C = A
				if(!C.can_open() && !C.opened) // must be able to access the contents
					return 0
			if(A.contents.len)
				return 1
			return 0

	//instead of moving the box, strip it of its contents
	inlet_reaction(var/obj/W,var/turf/S, var/remaining)
		//W should only be crate or ore box, although this will work on anything with contents...
		var/I = 0
		if(istype(W,/obj/structure/closet))
			var/obj/structure/closet/C = W
			if(!C.can_open() && !C.opened) // must be able to access the contents
				return 0

		for(var/obj/item/O in W.contents)
			if(I > remaining)
				return
			if(O.w_class > (remaining - I))
				continue
			O.loc = master
			master.types[O.type] = src
			if(O.w_class > 0)
				I += O.w_class
			else
				I++
		if(!W.contents.len && istype(W,/obj/structure/closet))
			var/obj/structure/closet/C = W
			C.open()
		return I


//Inlet stacker: used when the output is a volatile space (conveyor or another unit's input).
//Does not output a stack until it is full.
/datum/cargoprofile/in_stacker
	name = "Hold and Stack"
	id = "instacker"
	universal = 1

	blacklist = null
	whitelist = list(/obj/item/stack,/obj/item/weapon/cable_coil)

	dedicated_path = /obj/machinery/programmable/stacker

	inlet_reaction(var/atom/W,var/turf/S,var/remaining)
		if(istype(W,/obj/item/stack))
			var/obj/item/stack/I = W
			if(!I.amount) // todo: am I making a bad assumption here?
				del I
				return
			for(var/obj/item/stack/O in master.contents)
				if(O.type == I.type && O.amount < O.max_amount)
					if(I.amount + O.amount <= O.max_amount)
						O.amount += I.amount
						del I
						return O.w_class
					var/leftover = I.amount + O.amount - O.max_amount
					O.amount = O.max_amount
					I.amount = leftover
					continue
			//end for
			I.loc = master
			master.types[I.type] = src
			return I.w_class
		if(istype(W,/obj/item/weapon/cable_coil))
			var/obj/item/weapon/cable_coil/I = W
			if(!I.amount) // todo: am I making a bad assumption here?
				del I
				return
			for(var/obj/item/weapon/cable_coil/O in master.contents)
				if(O.type == I.type && O.amount < MAXCOIL)
					if(I.amount + O.amount <= MAXCOIL)
						O.amount += I.amount
						del I
						return O.w_class
					var/leftover = I.amount + O.amount - MAXCOIL
					O.amount = MAXCOIL
					I.amount = leftover
					continue
			//end for
			I.loc = master
			master.types[I.type] = src
			return I.w_class

	//If the stack isn't finished yet, don't eject it
	//unless this profile has been disabled.
	outlet_reaction(var/atom/W,var/turf/D)
		if(istype(W,/obj/item/stack))
			var/obj/item/stack/I = W
			if(src.enabled && (I.amount < I.max_amount))
				return // Still needs to be stacked
			..(W,D)
		if(istype(W,/obj/item/weapon/cable_coil))
			var/obj/item/weapon/cable_coil/I = W
			if(src.enabled && (I.amount < MAXCOIL))
				return // Still needs to be stacked
			..(W,D)

//Outlet stacker: used when the output square can be trusted.
//Outputs immediately, adding to stacks in the outlet.
/datum/cargoprofile/unary/stacker
	name = "Stack Items"
	id = "ustacker"
	blacklist = null
	whitelist = list(/obj/item/stack,/obj/item/weapon/cable_coil)

	dedicated_path = /obj/machinery/programmable/unary/stacker

	inlet_reaction(var/atom/W,var/turf/S,var/remaining)

		//Only pick it up if you are going to stack it

		if(istype(W,/obj/item/stack))
			var/obj/item/stack/I = W
			if(I.amount >= I.max_amount)
				return 0
			for(var/obj/item/stack/other in S.contents)
				if(other.type == I.type && other != I && other.amount < other.max_amount)
					return ..(W,S,remaining)
			return 0

		if(istype(W,/obj/item/weapon/cable_coil))
			var/obj/item/weapon/cable_coil/I = W
			if(I.amount >= MAXCOIL)
				return 0
			for(var/obj/item/weapon/cable_coil/other in S.contents)
				if(other != I && other.amount < MAXCOIL)
					return ..(W,S,remaining)
			return 0

	outlet_reaction(var/atom/W,var/turf/D)
		if(istype(W,/obj/item/stack))
			var/obj/item/stack/I = W
			for(var/obj/item/stack/O in D.contents)
				if(O.type == I.type && O.amount < O.max_amount)
					if(I.amount + O.amount <= O.max_amount)
						O.amount += I.amount
						del I
						return
					var/leftover = I.amount + O.amount - O.max_amount
					O.amount = O.max_amount
					I.amount = leftover
					continue
			//end for
			I.loc = D
			return
		if(istype(W,/obj/item/weapon/cable_coil))
			var/obj/item/weapon/cable_coil/I = W
			for(var/obj/item/weapon/cable_coil/O in D.contents)
				if(O.type == I.type && O.amount < MAXCOIL)
					if(I.amount + O.amount <= MAXCOIL) // Why did they make it a #define.
						O.amount += I.amount
						O.update_icon()
						del I
						return
					var/leftover = I.amount + O.amount - MAXCOIL // That wasn't a question
					O.amount = MAXCOIL // It was a complaint
					I.amount = leftover
					continue
			//end for
			I.loc = D
			return



/*
/datum/cargoprofile/seedboxer
	name = "Box Seeds"
	id = "seedboxer"
	blacklist = null
	whitelist = list(/obj/item/seeds)

	dedicated_path = /obj/machinery/programmable/seedboxer
	universal = 1

	outlet_reaction(var/atom/W,var/turf/D)
		var/obj/item/seeds/S = W
		var/obj/machinery/vending/hydroseeds/M = (locate(/obj/machinery/vending/hydroseeds) in D.contents)
		if(M != null)
			//Restock machine instead of dispensing boxes
			//CAUTION: if you do this, you will lose any genetic modification to the seeds.
			//The seeds that come out of the vending machine will be stock.
			for(var/datum/data/vending_product/P in M.product_records + M.hidden_records)
				if(P.product_path == "[S.type]") // It's a string for some reason
					P.amount++
					del S
					return
			//Didn't find it. Drop a box on top anyway.
		//Or maybe there just was no machine.  Well, either way...
		for(var/obj/item/weapon/storage/box/seedbox/B in D.contents)
			if(B.seedtype == S.type && B.contents.len < B.storage_slots)
				S.loc = B
				return
		//No such box or all boxes full
		var/obj/item/weapon/storage/box/seedbox/B = new(D)
		S.loc = B
		B.update_icon()
*/

/*
// This will require a unary machine
/datum/cargoprofile/botassembler
	name = "Robot Assembler (Alpha)"
	blacklist = list(/obj/item/mecha_parts/chassis,/obj/item/robot_parts/robot_suit)
	whitelist = list(/obj/item/mecha_parts,/obj/item/robot_parts)

	contains(var/atom/A)
		if(..())
			if(istype(A,/obj/item/robot_parts/chest))
				var/obj/item/robot_parts/chest/O = A
				if(!O.wires || !O.contents.len) // only accept prepared items
					return 0
				return 1
			if(istype(A,/obj/item/robot_parts/head))
				var/obj/item/robot_parts/head/O = A
				if(O.contents.len != 2) //Two flashes
					return 0
				return 1
			return 1

	outlet_reaction(var/atom/W,var/turf/D)
		if(istype(W,/obj/item/robot_parts))
			var/obj/item/robot_parts/R = W
			var/obj/item/robot_parts/robot_suit/S = locate(/obj/item/robot_parts/robot_suit/) in D.contents
			if(!S || (locate(R.type) in S.contents) )
				master.visible_message("\The [master.name] refuses \the [R.name] with a sigh.")
				playsound(master.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
				master.sleep = 2
				return
			S.attackby(R,null) // I expect that this will cause some null value runtimes
			return
		if(istype(W,/obj/item/mecha_parts))
			var/obj/item/mecha_parts/M = W
			var/list/L
			//They don't make typechecking easy for us here

			for(var/obj/item/mecha_parts/chassis/C in D.contents)
				switch(C.type)
				//Not here: firefighter
					if(/obj/item/mecha_parts/chassis/ripley)
						L = list(/obj/item/mecha_parts/part/ripley_torso,/obj/item/mecha_parts/part/ripley_left_arm,/obj/item/mecha_parts/part/ripley_right_arm,/obj/item/mecha_parts/part/ripley_left_leg,/obj/item/mecha_parts/part/ripley_right_leg)
					if(/obj/item/mecha_parts/chassis/durand)
						L = list(/obj/item/mecha_parts/part/durand_torso,/obj/item/mecha_parts/part/durand_left_arm,/obj/item/mecha_parts/part/durand_right_arm,/obj/item/mecha_parts/part/durand_left_leg,/obj/item/mecha_parts/part/durand_right_leg)
					if(/obj/item/mecha_parts/chassis/gygax)
						L = list(/obj/item/mecha_parts/part/gygax_torso,/obj/item/mecha_parts/part/gygax_left_arm,/obj/item/mecha_parts/part/gygax_right_arm,/obj/item/mecha_parts/part/gygax_left_leg,/obj/item/mecha_parts/part/gygax_right_leg)
					if(/obj/item/mecha_parts/chassis/honker)
						L = list(/obj/item/mecha_parts/part/honker_torso,/obj/item/mecha_parts/part/honker_left_arm,/obj/item/mecha_parts/part/honker_right_arm,/obj/item/mecha_parts/part/honker_left_leg,/obj/item/mecha_parts/part/honker_right_leg)
					if(/obj/item/mecha_parts/chassis/odysseus)
						L = list(/obj/item/mecha_parts/part/odysseus_torso,/obj/item/mecha_parts/part/odysseus_left_arm,/obj/item/mecha_parts/part/odysseus_right_arm,/obj/item/mecha_parts/part/odysseus_left_leg,/obj/item/mecha_parts/part/odysseus_right_leg)
					if(/obj/item/mecha_parts/chassis/phazon)
						L = list(/obj/item/mecha_parts/part/phazon_torso,/obj/item/mecha_parts/part/phazon_left_arm,/obj/item/mecha_parts/part/phazon_right_arm,/obj/item/mecha_parts/part/phazon_left_leg,/obj/item/mecha_parts/part/phazon_right_leg)
				if(locate(M.type) in L)
					C.attackby(M,null) // probably also null value runtimes
					if(M.loc == master) // didn't take for whatever reason
						M.loc = output
						master.visible_message("\The [master.name] refuses \the [M.name] with a sigh.")
						playsound(master.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
						master.sleep = 2
					return
			//end for: no acceptable chassis
			master.visible_message("\The [master.name] refuses \the [M.name] with a sigh.")
			playsound(master.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			master.sleep = 2
			return
*/



//----------------------------------------------------------------------------
// Dubious Overrides (For emag use)
//----------------------------------------------------------------------------


//Clogs up the unloader.  And, there may be devious uses for it...
/datum/cargoprofile/slow
	name = "Slow unloader"
	id = "slow"
	whitelist = list(/obj/item,/obj/structure/closet,/obj/structure/bigDelivery,/obj/machinery/portable_atmospherics)
	blacklist = list()

	inlet_reaction(var/atom/W,var/turf/S,var/remaining)
		if(..())
			return remaining

/datum/cargoprofile/unary/shredder
	name = "Paper Shredder"
	id = "shredder"
	blacklist = null
	whitelist = list(/obj/item/weapon/paper,/obj/item/weapon/book,/obj/item/weapon/clipboard,/obj/item/weapon/folder,/obj/item/weapon/photo)
	universal = 1

	dedicated_path = /obj/machinery/programmable/unary/shredder



	proc/cliptags(var/Text)
		//Removes all html tags
		var/index
		var/index2
		index = findtextEx(Text,"<")
		while(index)
			index2 = findtextEx(Text,">",index)
			if(!index2)
				return copytext(Text,1,index)
			Text = "[copytext(Text,1,index)][copytext(Text,index2+1,0)]"
			index = findtextEx(Text,"<")
		//should have trimmed that text there pretty good
		return Text


	//Recurses through the text, removing large chunks
	proc/garbletext(var/Text)
		var/l = length(Text)
		if(l <= 3)
			if(prob(20))
				return pick("#","|","/","*",".","."," ","."," "," ")
			return Text
		if(prob(50))
			return "[garbletext(copytext(Text,1,l/2))][garbletext(copytext(Text,l/2,0))]"
		if(prob(50))
			return "[pick("#","|","/","*",".","."," ","."," "," ")][garbletext(copytext(Text,1,l/2))]"
		return "[garbletext(copytext(Text,l/2,0))][pick("#","|","/","*",".","."," ","."," "," ")]"

	proc/garble_keeptags(var/Text)
		var/list/L = stringsplit(Text,">")
		var/result = ""
		for(var/string in L)
			var/index = findtextEx(string,"<")
			if(index!=1)
				result += "[garbletext(copytext(string,1,index))][copytext(string,index)]>"
			else
				result += "[string]>"
		return copytext(result,1,lentext(result))




	outlet_reaction(var/atom/W,var/turf/D)
		if(istype(W,/obj/item/weapon/paper/crumpled))
			del W
			return
		if(istype(W,/obj/item/weapon/clipboard) || istype(W,/obj/item/weapon/folder))
			// destroy folder, various effects on contents
			for(var/obj/item/I in W.contents)
				if(prob(25))//JUNK IT
					del I
				else if(prob(50))  //We've been over this.  I can't just take it apart with a crowbar.
					var/obj/item/weapon/paper/crumpled/P = new(master.loc)
					if(I.name)
						P.name = garbletext(I.name)
					if(prob(66))
						P.fingerprints = I.fingerprints
						P.fingerprintshidden = I.fingerprintshidden
					if(istype(I,/obj/item/weapon/paper))
						var/obj/item/weapon/paper/O = I
						P.info = garble_keeptags(O.info)
					del I
					..(P,D)
				else
					..(I,D) // Eject
			del W //destroy container
			return
		if(prob(50)) //JUNK IT NOW!
			var/obj/item/weapon/paper/crumpled/P = new(master.loc)
			P.name = W.name
			var/obj/item/I = W
			if(prob(66))
				P.fingerprints = I.fingerprints
				P.fingerprintshidden = I.fingerprintshidden
			if(istype(I,/obj/item/weapon/paper))
				var/obj/item/weapon/paper/O = I
				if(O.info)
					P.info = garble_keeptags(O.info)
			if(istype(I,/obj/item/weapon/book))
				var/obj/item/weapon/book/B = I
				if(B.dat)
					P.info = garble_keeptags(B.dat)
				if(B.carved && B.store)
					..(B.store,D)
			del W
			..(P,D)
		else //I want it junked
			del W
		return

/datum/cargoprofile/people
	name = "Manhandling"
	id = "people"

	whitelist = null
	blacklist = list(/mob/aiEye,/mob/new_player,/mob/living/blob,/mob/living/simple_animal/hostile/blobspore,/mob/living/simple_animal/hostile/creature,
					/mob/living/simple_animal/space_worm,/mob/living/simple_animal/shade,/mob/living/simple_animal/hostile/faithless,/mob/dead)
	universal = 1
	mobcheck = 1


	contains(var/atom/A)
		if(!istype(A,/mob))
			return
		if(blacklist)
			for(var/T in blacklist)
				if(istype(A,T))
					return 0
		if(whitelist)
			for(var/T in whitelist)
				if(istype(A,T))
					return 1
			return 0
		return 1

	inlet_reaction(var/atom/W,var/turf/S,var/remaining)
		var/mob/living/M = W
		if(remaining > MOB_WORK)
			//this is necessarily damaging
			var/damage = rand(1,5)
			M << "\red <B>The unloading machine grabs you with a hard metallic claw!</B>"
			if(M.client)
				M.client.eye = master
				M.client.perspective = EYE_PERSPECTIVE
			M.loc = master
			master.types[M.type] = src
			M.apply_damage(damage) // todo: ugly
			M.visible_message("\red [M.name] gets pulled into the machine!")
			return MOB_WORK

	outlet_reaction(var/atom/W,var/turf/D)
		world.log << "Mob ejection"
		var/mob/living/M = W
		M.loc = master.loc
		M.dir = master.outdir
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

		D = get_step(D,master.outdir) // throw attempt
		eject_speed = rand(0,4)

		M.visible_message("\blue [M.name] is ejected from the unloader.")
		M.throw_at(D,eject_speed,eject_speed)
		return

/datum/cargoprofile/unary/trainer
	name = "Boxing Trainer"
	id = "trainer"
	blacklist = list()
	whitelist = list(/mob/living/carbon/human)
	mobcheck = 1

	var/const/PUNCH_WORK = 6

	dedicated_path = /obj/machinery/programmable/unary/trainer

	contains(var/atom/A)
		if(!istype(A,/mob))
			return 0
		if(blacklist)
			for(var/T in blacklist)
				if(istype(A,T))
					return 0
		if(whitelist)
			for(var/T in whitelist)
				if(istype(A,T))
					return 1
			return 0
		return 1

	proc/punch(var/mob/living/carbon/human/M,var/maxpunches)
		//stolen from holographic boxing gloves code
		//This should probably be done BY the mob, however, the attack code will be expecting a source mob.

		var/damage
		if(prob(75))
			damage = rand(0, 6) // pap
		else
			damage = rand(0, 12) // thwack

		if(!damage)
			playsound(master.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			master.visible_message("\red \The [src] punched at [M], but whiffed!")

			if(maxpunches > 1 && prob(50)) // Follow through on a miss, 50% chance
				return punch(M,maxpunches - 1) + 1
			return 1
		var/datum/limb/affecting = M.get_organ(ran_zone("chest",50))
		var/armor_block = M.run_armor_check(affecting, "melee")

		playsound(master.loc, "punch", 25, 1, -1)
		master.visible_message("\red <B>\The [src] has punched [M]!</B>")
		if(!master.emagged)
			M.apply_damage(damage, HALLOSS, affecting, armor_block) // Clean fight
		else
			M.apply_damage(damage, BRUTE,   affecting, armor_block) // Foul!  Foooul!

		if(damage >= 9)
			master.visible_message("\red <B>\The [src] has weakened [M]!</B>")
			M.apply_effect(4, WEAKEN, armor_block)
			if(!master.emagged)
				master.sleep = 1
			return maxpunches // The machine is not so sophisticated as to not gloat
		else
			if(prob(25)) // Follow through on a hit, 25% chance.  Pause after.
				return punch(M,maxpunches-1) + 1
		return 1

	inlet_reaction(var/atom/W,var/turf/S,var/remaining)
		//stolen from boxing gloves code
		var/mob/living/carbon/human/M = W
		if((M.lying || (M.health - M.halloss < 25))&& !master.emagged)
			M << "\The [src] gives you a break."
			master.sleep+=5
			return 0 // Be polite
		var/punches = punch(M,remaining / PUNCH_WORK)
		if(punches>1)master.sleep++
		return punches * PUNCH_WORK