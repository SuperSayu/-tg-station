
/*
Programs are a file that can be executed
*/

/datum/file/program
	name = "Untitled"
	extension = "prog"
	image = 'icons/NTOS/program.png'
	var/desc = "An unidentifiable program."
	var/drm = 0 // prevents a program from being copied
	var/active_state = "computer_generic" // the icon_state that the computer goes to when the program is active
	var/list/req_access = list() // required access to perform computer functions
	var/gui = 1 // it the program doesn't have a gui (ie is a one-use program) set this to 0

/datum/file/program/execute(var/datum/file/source)

	if(computer && gui && !computer.program)
		computer.program = src
		computer.icon_state = src.active_state
		computer.req_access = req_access
		usr << browse(null, "window=nt_os")
		computer.attack_hand(usr)
		computer.updateUsrDialog()

	..()
/*
	The computer object will transfer all Topic() calls to the program
*/
/datum/file/program/Topic(href, href_list)
	..()

/*
	The computer object will transfer all empty-hand calls to the program (this includes AIs, Cyborgs, and Monkies)
*/
/datum/file/program/proc/interact(var/mob/user as mob)
	..()

/*
	The computer object will transfer all attackby() calls to the program
		If the item is a valid interactable object, return 1. Else, return 0.
		This helps identify what to use to actually hit the computer with, and
		what can be used to interact with it.

		Screwdrivers will, by default, never call program/attackby(). That's used
		for deconstruction instead.
*/

/datum/file/program/proc/attackby(O as obj, user as mob)
	..()


/*
	The computer object will transfer process() calls to the program.
*/
/datum/file/program/proc/process()
	..()


// ID prog done (card.dm)

/datum/file/program/RD
	name = "R&D Manager"
	image = 'icons/NTOS/rd console.png'
	desc = "A software suit for generic research and development machinery interaction. Comes pre-packaged with extensive cryptographic databanks for secure connections with external devices."
	active_state = "rdcomp"
	volume = 11000

/datum/file/program/RDserv
	name = "R&D Server"
	image = 'icons/NTOS/rd server controller.png'
	active_state = "rdcomp"
	volume = 9000

/datum/file/program/SuitSensors
	name = "Crew Monitoring"
	image = 'icons/NTOS/medical suit sensors.png'
	active_state = "crew"
	volume = 3400

/datum/file/program/Genetics
	name = "Genetics Suite"
	image = 'icons/NTOS/medical genetics editing.png'
	desc = "A sophisticated software suite containing read-only genetics hardware specifications and a highly compressed genome databank."
	active_state = "dna"
	volume = 8000

/datum/file/program/Cloning
	name = "Cloning Platform"
	image = 'icons/NTOS/genetics cloning.png'
	desc = "A software platform for accessing external cloning apparatus."
	active_state = "dna"
	volume = 7000

// CommUplink prog done (communications.dm)

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

/datum/file/program/arcade
	name = "Space Fantasy II"
	active_state = "command"
	volume = 170

/datum/file/program/securitycam
	name = "Sec-Cam Viewport"
	image = 'icons/NTOS/sec camera wm.png'
	drm = 1
	active_state = "cameras"
	volume = 2190

/datum/file/program/securityrecords
	name = "Security Records"
	image = 'icons/NTOS/sec records wm.png'
	drm = 1
	active_state = "security"
	volume = 2520

/datum/file/program/securityserver
	name = "Sec Server"
	image = 'icons/NTOS/sec records wm.png'
	drm = 1
	active_state = "security"
	volume = 6000

/datum/file/program/medicalrecords
	name = "Medical Records"
	image = 'icons/NTOS/medical records wm.png'
	drm = 1
	active_state = "medcomp"
	volume = 5000

/datum/file/program/medicalserver
	name = "Med Server"
	image = 'icons/NTOS/medical records wm.png'
	drm = 1
	active_state = "medcomp"
	volume = 6005

/datum/file/program/airecover
	name = "AI Recovery"
	image = 'icons/NTOS/ai restorer.png'
	active_state = "ai-fixer"
	volume = 15500

/datum/file/program/atmospherealert
	name = "Atmos Alerts"
	image = 'icons/NTOS/station alerts.png'
	active_state = "atmos"
	volume = 12000

/datum/file/program/SMSmonitor
	name = "Messaging Monitor"
	image = 'icons/NTOS/pda monitor.png'
	active_state = "comm_monitor"
	volume = 3070

/datum/file/program/OperationMonitor
	name = "OR Monitor"
	image = 'icons/NTOS/medical operations console.png'
	active_state = "operating"
	volume = 4750

/datum/file/program/PodLaunch
	name = "Pod Launch"
	active_state = "computer_generic"
	volume = 520

/datum/file/program/PowerMonitor
	name = "Power Grid"
	image = 'icons/NTOS/engineering power alerts.png'
	active_state = "power"
	volume = 7200

/datum/file/program/PrisonerManagement
	name = "Prisoner Control"
	image = 'icons/NTOS/sec prison management.png'
	drm = 1
	active_state = "power"
	volume = 5000

/datum/file/program/Roboticscontrol
	name = "Cyborg Maint"
	image = 'icons/NTOS/cyborg control.png'
	active_state = "robot"
	volume = 9050

/datum/file/program/AIupload
	name = "AI Upload"
	image = 'icons/NTOS/ai upload.png'
	active_state = "command"
	volume = 5000

/datum/file/program/Cyborgupload
	name = "Cyborg Upload"
	image = 'icons/NTOS/cyborg upload.png'
	active_state = "command"
	volume = 5000

/datum/file/program/Exosuit
	name = "Exosuit Monitor"
	image = 'icons/NTOS/exosuit control.png'
	active_state = "mecha"
	volume = 7000

/datum/file/program/EmergencyShuttle
	name = "Shuttle Console"
	active_state = "shuttle"
	volume = 10000

/datum/file/program/Stationalert
	name = "Alert Monitor"
	image = 'icons/NTOS/station alerts.png'
	active_state = "computer_generic"
	volume = 10150






