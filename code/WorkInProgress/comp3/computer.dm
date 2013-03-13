var/list/drives = list("C:", "D:", "E:", "F:", "G:", "H:", "I:", "J:", "K:", "L:", "M:")
var/removeable_drive = "A:"


/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = 1
	anchored = 1.0
	var/obj/item/weapon/circuitboard/circuit = /obj/item/weapon/circuitboard/computer //if circuit==null, computer can't disassemble

	var/list/peripherals = list()
	var/max_peripherals = 4 // ROMs, Harddrives, etc
	var/obj/item/weapon/card/id/slotA = null
	var/obj/item/weapon/card/id/slotB = null
	var/datum/file/container/metadata = null
	var/datum/file/program/program = null // the active program (null if defaulting to underlay)
	var/datum/file/program/underlay = null // the underlaying root software to default to (ie the Operating System). If null, the computer is considered inoperative.
		// Note: underlay software dictated by the very first ROM inserted.

	var/spawned = 1 // if the computer was spawned and should start with the preset hardware
	var/default_prog = null // the default program to add as a separate rom

	New()
		..()
		spawn(2)
			power_change()

		if(spawned)
			// Prepare the NT OS RAM
			var/obj/item/weapon/computer_part/storage/rom/OS/osrom = new(src)

			// Prepare the hard drive
			var/obj/item/weapon/computer_part/storage/harddrive/hdd = new(src)

			// Attach the peripherals
			osrom.computer = src
			osrom.init(src)
			hdd.computer = src
			hdd.init(src)
			src.peripherals.Add(osrom)
			src.peripherals.Add(hdd)

			// Add a default software rom if necessary
			if(default_prog)

				var/obj/item/weapon/computer_part/storage/rom/progrom = new()
				progrom.init(src)
				progrom.Add_File(new default_prog, 1) // override parameter because normally roms are read-only
				peripherals.Add(progrom)

			// Locate the OS software and assign it to underlay

			if(underlay)
				underlay.computer = src
			else
				for(var/datum/file/program/NTOS/N in osrom.files)
					src.underlay = N
					N.computer = src
					icon_state = N.active_state
					break


	meteorhit(var/obj/O as obj)
		for(var/x in verbs)
			verbs -= x
		set_broken()
		var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
		smoke.set_up(5, 0, src)
		smoke.start()
		return


	emp_act(severity)
		if(prob(20/severity)) set_broken()
		..()


	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(25))
					del(src)
					return
				if (prob(50))
					for(var/x in verbs)
						verbs -= x
					set_broken()
			if(3.0)
				if (prob(25))
					for(var/x in verbs)
						verbs -= x
					set_broken()
			else
		return


	blob_act()
		if (prob(75))
			for(var/x in verbs)
				verbs -= x
			set_broken()
			density = 0


	power_change()
		if(!istype(src,/obj/machinery/computer/security/telescreen))
			if(stat & BROKEN)
				icon_state = "computer_b"
				if (istype(src,/obj/machinery/computer/aifixer))
					overlays = null

			else if(powered())
				icon_state = initial(icon_state)
				stat &= ~NOPOWER
				if (istype(src,/obj/machinery/computer/aifixer))
					var/obj/machinery/computer/aifixer/O = src
					if (O.occupant)
						switch (O.occupant.stat)
							if (0)
								overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
							if (2)
								overlays += image('icons/obj/computer.dmi', "ai-fixer-404")
					else
						overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")
			else
				spawn(rand(0, 15))
					//icon_state = "c_unpowered"
					icon_state = "computer_off"
					stat |= NOPOWER
					if (istype(src,/obj/machinery/computer/aifixer))
						overlays = null


	process()
		if(stat & (NOPOWER|BROKEN))
			return
		use_power(250)

		if(program)
			program.process()
		else
			if(underlay)
				underlay.process()


	proc/set_broken()
		icon_state = "computer_b"
		stat |= BROKEN


	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/screwdriver) && circuit)
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/M = new circuit( A )
				A.circuit = M
				A.anchored = 1
				for (var/obj/C in src)
					C.loc = src.loc
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					new /obj/item/weapon/shard( src.loc )
					A.state = 3
					A.icon_state = "3"
				else
					user << "\blue You disconnect the monitor."
					A.state = 4
					A.icon_state = "4"
				del(src)
		else
			if(program)
				program.attackby(I, user)
			else
				if(underlay)
					underlay.attackby(I, user)

			//src.attack_hand(user)
		return

/obj/machinery/computer/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	interact(user)

/obj/machinery/computer/interact(var/mob/user as mob)
	if(program)
		program.interact(user)
	else
		if(underlay)
			underlay.interact(user)

/obj/machinery/computer/nt_generic
	name = "nanotrasen computer"
	desc = "This is a standard NanoTrasen brand Operating Computer."