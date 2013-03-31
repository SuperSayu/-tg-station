
/*
Programs are a file that can be executed
*/

/datum/file/program
	name				= "Untitled"
	extension			= "prog"
	image				= 'icons/NTOS/program.png'
	var/desc			= "An unidentifiable program."

	var/image/overlay	= null							// Icon to be put on top of the computer frame.

	var/active_state	= "generic"						// the icon_state that the computer goes to when the program is active
	var/list/req_access = list()						// required access to perform computer functions

	var/drm				= 0								// prevents a program from being copied
	var/gui				= 1								// it the program doesn't have a gui (ie is a one-use program) set this to 0
	var/refresh			= 0								// if true, refreshes during process()
	var/error			= 0

	var/datum/browser/popup				= null

	// if set to a list this will be used when spawning computers.
	// this list should be /type/paths.  Keep in mind computers have
	// a limit on peripherals.
	var/list/required_peripherals = null


/datum/file/program/New()
	..()
	if(!active_state)
		active_state = "generic"
	overlay = image('icons/obj/computer3.dmi',icon_state = active_state)

/datum/file/program/execute(var/datum/file/source)
	if(computer && gui)
		computer.program = src
		computer.req_access = req_access
		update_icon()
		computer.update_icon()
		Reset()
		if(usr)
			usr << browse(null, "window=\ref[computer]")
			computer.attack_hand(usr)

	..()

/*
	Standard Topic() for links
*/

/datum/file/program/Topic(href, href_list)
	return

/*
	The computer object will transfer all empty-hand calls to the program (this includes AIs, Cyborgs, and Monkies)
*/
/datum/file/program/proc/interact()
	return

/*
	Standard receive_signal()
*/

/datum/file/program/proc/receive_signal(var/datum/signal/signal)
	return
/*
	The computer object will transfer all attackby() calls to the program
		If the item is a valid interactable object, return 1. Else, return 0.
		This helps identify what to use to actually hit the computer with, and
		what can be used to interact with it.

		Screwdrivers will, by default, never call program/attackby(). That's used
		for deconstruction instead.
*/


/datum/file/program/proc/attackby(O as obj, user as mob)
	return

/*
	Try not to overwrite this proc, I'd prefer we stayed
	with interact() as the main proc
*/
/datum/file/program/proc/attack_hand(mob/user as mob)
	if(required_peripherals)
		for(var/typekey in required_peripherals)
			if(!computer.get_peripheral(typekey))
				computer.ProgramError(MISSING_PERIPHERAL)
				return
	usr = user
	interact()

/*
	Called when the computer is rebooted or the program exits/restarts.
	Be sure not to save any work.  Do NOT start the program again.
	If it is the os, the computer will run it again automatically.
*/
/datum/file/program/proc/Reset()
	error = 0
	update_icon()
	return

/*
	The computer object will transfer process() calls to the program.
*/
/datum/file/program/proc/process()
	if(refresh && computer && !computer.stat)
		computer.updateDialog()
		update_icon()

/datum/file/program/proc/update_icon()
	return


/datum/file/program/RD
	name = "R&D Manager"
	image = 'icons/NTOS/research.png'
	desc = "A software suit for generic research and development machinery interaction. Comes pre-packaged with extensive cryptographic databanks for secure connections with external devices."
	active_state = "rdcomp"
	volume = 11000

/datum/file/program/RDserv
	name = "R&D Server"
	image = 'icons/NTOS/server.png'
	active_state = "rdcomp"
	volume = 9000

/datum/file/program/SuitSensors
	name = "Crew Monitoring"
	image = 'icons/NTOS/monitoring.png'
	active_state = "crew"
	volume = 3400

/datum/file/program/Genetics
	name = "Genetics Suite"
	image = 'icons/NTOS/genetics.png'
	desc = "A sophisticated software suite containing read-only genetics hardware specifications and a highly compressed genome databank."
	active_state = "dna"
	volume = 8000

/datum/file/program/Cloning
	name = "Cloning Platform"
	image = 'icons/NTOS/cloning.png'
	desc = "A software platform for accessing external cloning apparatus."
	active_state = "dna"
	volume = 7000

/datum/file/program/TCOMmonitor
	name = "TComm Monitor"
	image = 'icons/NTOS/tcomms.png'
	active_state = "comm_monitor"
	volume = 5500

/datum/file/program/TCOMlogs
	name = "TComm Log View"
	image = 'icons/NTOS/tcomms.png'
	active_state = "comm_logs"
	volume = 5230

/datum/file/program/TCOMtraffic
	name = "TComm Traffic"
	image = 'icons/NTOS/tcomms.png'
	active_state = "generic"
	volume = 8080

/datum/file/program/securitycam
	name = "Sec-Cam Viewport"
	image = 'icons/NTOS/camera.png'
	drm = 1
	active_state = "cameras"
	volume = 2190

/datum/file/program/securityrecords
	name = "Security Records"
	image = 'icons/NTOS/records.png'
	drm = 1
	active_state = "security"
	volume = 2520

/datum/file/program/medicalrecords
	name = "Medical Records"
	image = 'icons/NTOS/medical.png'
	drm = 1
	active_state = "medcomp"
	volume = 5000

/datum/file/program/SMSmonitor
	name = "Messaging Monitor"
	image = 'icons/NTOS/pda.png'
	active_state = "comm_monitor"
	volume = 3070

/datum/file/program/OperationMonitor
	name = "OR Monitor"
	image = 'icons/NTOS/operating.png'
	active_state = "operating"
	volume = 4750

/datum/file/program/PodLaunch
	name = "Pod Launch"
	active_state = "computer_generic"
	volume = 520

/datum/file/program/PowerMonitor
	name = "Power Grid"
	image = 'icons/NTOS/power.png'
	active_state = "power"
	volume = 7200

/datum/file/program/PrisonerManagement
	name = "Prisoner Control"
	image = 'icons/NTOS/prison.png'
	drm = 1
	active_state = "power"
	volume = 5000

/datum/file/program/Roboticscontrol
	name = "Cyborg Maint"
	image = 'icons/NTOS/borgcontrol.png'
	active_state = "robot"
	volume = 9050

/datum/file/program/AIupload
	name = "AI Upload"
	image = 'icons/NTOS/aiupload.png'
	active_state = "command"
	volume = 5000

/datum/file/program/Cyborgupload
	name = "Cyborg Upload"
	image = 'icons/NTOS/borgupload.png'
	active_state = "command"
	volume = 5000

/datum/file/program/Exosuit
	name = "Exosuit Monitor"
	image = 'icons/NTOS/exocontrol.png'
	active_state = "mecha"
	volume = 7000

/datum/file/program/EmergencyShuttle
	name = "Shuttle Console"
	active_state = "shuttle"
	volume = 10000

/datum/file/program/Stationalert
	name = "Alert Monitor"
	image = 'icons/NTOS/alerts.png'
	active_state = "computer_generic"
	volume = 10150






