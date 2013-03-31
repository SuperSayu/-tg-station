var/list/computer_drives = list("C:", "D:", "E:", "F:", "G:")
var/list/removeable_drives = list("A:","B:","D:","E:","F:","G:")

// Error codes, todo: move
#define PROG_CRASH			1
#define MISSING_PERIPHERAL	2
#define BUSTED_ASS_COMPUTER	4
#define MISSING_PROGRAM		8



/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer3.dmi'
	icon_state = "frame"
	density = 1
	anchored = 1.0

	// Kept because it holds a copy of the OS
	var/obj/item/weapon/circuitboard/computer/circuit

	// These are necessary in order to consolidate all computer types into one
	var/datum/wires/wires				= null
	// camera networking - overview (???)
	var/mapping = 0
	var/last_pic = 1.0

	// Computer3 components
	var/list/peripherals				= list()
	var/max_peripherals					= 3		// ROMs, Harddrives, etc

	var/list/drive_list					= list()
	var/datum/file/program/program		= null	// the active program (null if defaulting to os)
	var/datum/file/program/os			= null	// the base code of the machine (os or hardcoded program)

	// Purely graphical effect
	var/icon/kb							= null


	// These is all you should need to change when creating a new computer.
	// If there is no default program, the OS will run instead.
	// If there is no hard drive, but there is a default program, the OS rom on
	// the circuitboard will be overridden.

	// In all cases, typepaths are used, NOT objects

	var/default_prog					= null										// the program running when spawned
	var/list/spawn_parts				= list(/obj/item/part/computer/storage/hdd)	// parts added when spawned
	var/list/spawn_files				= list()									// files added when spawned

	// If you want the computer to have a UPS, add a battery.  This is useful for things like
	// the comms computer, solar trackers, etc, that should function when all else is off.
	// Laptops will require batteries and have no mains power.
	// These do not last forever!  But they are better than nothing.

	// Not currently finished

	var/obj/item/weapon/cell/battery	= null // uninterruptible power supply aka battery


	verb/ResetComputer()
		set name = "Reset Computer"
		set category = "Object"
		set src in view(1)
		Reset()

	New()
		..()
		spawn(2)
			power_change()
		var/kb_state = "kb[rand(1,15)]"
		kb = image('icons/obj/computer3.dmi',icon_state=kb_state)
		overlays += kb

		for(var/typekey in spawn_parts)	// Spawn parts
			if(ispath(typekey,/obj/item/part/computer))
				var/obj/item/part/computer/part = new typekey(src)
				part.init(src)
				peripherals.Add(part)
			if(ispath(typekey,/obj/item/weapon/cell))
				var/obj/item/weapon/cell/C = new typekey(src)
				battery = C

		if(!circuit || !istype(circuit))
			circuit = new(src)

		var/datum/file/drive/c_drive = drive_list["C:"]
		var/obj/item/part/computer/storage/hdd/drive = null
		if(c_drive)
			drive = c_drive.device

		if(default_prog) // Add the default software if applicable
			var/datum/file/program/P = new default_prog
			if(drive)
				drive.Add_File(P)
				program = P
				if(circuit.OS)
					os = circuit.OS
					circuit.OS.computer = src
				else
					os = P
					program = null
			else
				circuit.OS = P
				circuit.OS.computer = src
				os = circuit.OS
		else
			if(circuit.OS)
				os = circuit.OS
				circuit.OS.computer = src
			else
				os = null


		if(drive)		// Spawn files
			for(var/typekey in spawn_files)
				drive.Add_File(new typekey)

		if(program)
			program.Reset()
		update_icon()


	proc/Reset(var/error = 0)
		for(var/mob/living/M in range(1))
			M << browse(null,"window=\ref[src]")
		if(program)
			program.Reset()
			program		= null
		req_access	= os.req_access
		update_icon()

		// todo does this do enough

	proc/ProgramError(var/errorcode) // todo BSOD
		switch(errorcode)
			if(PROG_CRASH)
				if(usr)
					usr << "\red The program crashed!"
					usr << browse(null,"\ref[src]")
					Reset()
			if(MISSING_PERIPHERAL)
				Reset()
				if(usr)
					usr << browse("<h2>ERROR: Missing or disabled component</h2><b>A hardware failure has occured.  Please insert or replace the missing or damaged component and restart the computer.</b>","window=\ref[src]")
			if(BUSTED_ASS_COMPUTER)
				Reset()
				os.error = BUSTED_ASS_COMPUTER
				if(usr)
					usr << browse("<h2>ERROR: Missing or disabled component</h2><b>A hardware failure has occured.  Please insert or replace the missing or damaged component and restart the computer.</b>","window=\ref[src]")
			if(MISSING_PROGRAM)
				Reset()
				if(usr)
					usr << browse("<h2>ERROR: No associated program</h2><b>This file requires a specific program to open, which cannot be located.  Please install the related program and try again.</b>","window=\ref[src]")
		return

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
			set_broken()
			density = 0

	auto_use_power()
		if(!powered(power_channel))
			if(battery && battery.charge > 0)
				if(use_power == 1)
					battery.use(idle_power_usage)
				else
					battery.use(active_power_usage)
			return 0
		if(src.use_power == 1)
			use_power(idle_power_usage,power_channel)
		else if(src.use_power >= 2)
			use_power(active_power_usage,power_channel)
		return 1


	process()
		if(stat & (NOPOWER|BROKEN))
			return
		use_power(250)

		if(program)
			program.process()
			return

		if(os)
			program = os
			os.process()
			return


	proc/set_broken()
		icon_state = "computer_b"
		stat |= BROKEN
		crit_fail = 1
		if(program)
			program.error = BUSTED_ASS_COMPUTER
		if(os)
			os.error = BUSTED_ASS_COMPUTER


	proc/disassemble(mob/user as mob)
		return

	attackby(I as obj, mob/user as mob)
		if(istype(I, /obj/item/weapon/screwdriver) && circuit)
			disassemble(user)
			return

		if(stat&NOPOWER)
			user << "It's off."
			return

		if(!stat && istype(I, /obj/item/weapon/card) || istype(I,/obj/item/weapon/disk) || istype(I,/obj/item/device/aicard))
			if(!allowed(user))
				return
			if(program)
				program.attackby(I, user)
				return
			if(os)
				os.attackby(I,user)
				return
		if(program.error)
			ProgramError(program.error)
			return
		..()

	attack_hand(var/mob/user as mob)
		if(stat)
			Reset()
			return
		if(!allowed(user))
			return

		if(program)
			if(program.error)
				ProgramError(program.error)
				return
			user.set_machine(src)
			program.attack_hand(user) // will normally translate to program/interact()
			return

		if(os)
			program = os
			user.set_machine(src)
			os.attack_hand(user)
			return

		user << "\The [src] won't boot!"

	interact()
		if(stat)
			Reset()
			return
		if(!allowed(usr) || !usr in view(1))
			usr.unset_machine()
			return

		if(program)
			program.interact()
			return

		if(os)
			program = os
			os.interact()
			return

	proc/check_peripherals(var/list/required)
		for(var/typekey in required)
			var/found = 0
			for(var/obj/item/part/computer/PC in peripherals)
				if(PC.crit_fail)
					continue
				if(istype(PC,typekey))
					found = 1
					break
			if(!found)
				return 0
		return 1

	proc/get_peripheral(var/typekey,var/required = 1)
		for(var/obj/item/part/computer/PC in peripherals)
			if(PC.crit_fail)
				continue
			if(istype(PC, typekey))
				return PC
		if(required)
			ProgramError(MISSING_PERIPHERAL)
		return null

	update_icon()
		overlays.Cut()
		if(stat) return
		if(program)
			overlays = list(kb,program.overlay)
		else if(os)
			overlays = list(kb,os.overlay)
		else
			var/global/image/generic = image('icons/obj/computer3.dmi',icon_state="osod") // orange screen of death
			overlays = list(kb,generic)

/obj/machinery/computer/wall_comp
	icon			= 'icons/obj/computer3.dmi'
	icon_state		= "wallframe"
	max_peripherals	= 2
	density			= 0
	pixel_y			= -3

	update_icon()
		overlays.Cut()
		if(stat) return
		if(program)
			overlays = list(program.overlay)
		else if(os)
			overlays = list(os.overlay)
		else
			var/global/image/generic = image('icons/obj/computer3.dmi',icon_state="osod") // orange screen of death
			overlays = list(generic)