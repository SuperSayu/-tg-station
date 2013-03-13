
/*
Objects used to construct computers, and objects that can be inserted into them, etc.
*/

/obj/item/weapon/computer_part
	name = "computer part"
	desc = "Holy jesus you donnit now"
	gender = PLURAL
	icon = 'stock_parts.dmi'
	w_class = 2.0
	var/obj/machinery/computer/computer // the computer that this device is attached to

	proc/init(var/obj/machinery/computer/target)
		computer = target
		// continue to handle all other type-specific procedures

/*
Computer devices that can store programs, files, etc.
*/

/obj/item/weapon/computer_part/storage
	name = "Storage Device"
	desc = "A device used for storing and retrieving digital information."
	var/volume = 0 // in KB
	var/max_volume = 8 // in KB
	var/list/files = list() // a list of files in the memory (ALL files)
	var/list/subroot = list() // a list of files in the subroot drive directory
	var/readonly = 0 // determines if the storage device is ROM
	var/removeable = 0 // determinse if the storage device is a removable hard drive (ie floppy)
	var/drive = "" // determines which drive the device is located in the computer (ie A:)
	//var/files = list()
	var/datum/file/container = list()
	var/datum/file/container/metadata = list()
	var/extension = null

	// Add a file ot the hard drive, returns 0 if failed
	proc/Add_File(var/datum/file/F, var/datum/file/directory/container, var/override)
		if(!F) return 0

		if(readonly && !override)
			return 0
		else
			files.Add(F)
			if(!container)
				subroot.Add(F)
			else
				container.files.Add(F)
			F.computer = computer
			F.device = src
			return 1

	init()
		// update computer target
		..()
		for(var/datum/file/F in files)
			F.computer = computer

/*
Standard hard drives for computers. Used in computer construction
*/

/obj/item/weapon/computer_part/storage/harddrive
	name = "Hard Drive"
	max_volume = 25000
	icon_state = "hdd1"

	// Assign the harddrive its specific drive
	init(var/obj/machinery/computer/target)
		..()
		var/drivenum = 0
		for(var/obj/item/weapon/computer_part/storage/harddrive/S in target.peripherals)
			drivenum++

		drive = drives[drivenum+1]

/obj/item/weapon/computer_part/storage/harddrive/big
	name = "Big Hard Drive"
	max_volume = 50000
	icon_state = "hdd2"

/obj/item/weapon/computer_part/storage/harddrive/gigantic
	name = "Gigantic Hard Drive"
	max_volume = 75000
	icon_state = "hdd3"

/*
Read-only drive containing usually pre-packaged software or the NT OS
*/

/obj/item/weapon/computer_part/storage/rom
	name = "Read-Only Drive"
	desc = "A device used for storing digital information. It is designed to lack input firmware."
	max_volume = 13000
	readonly = 1

	New()
		..()
		icon_state = "romos1"

	/*
	ROM presets
	*/

/obj/item/weapon/computer_part/storage/rom/OS
	name = "Read-Only Drive (NT OS)"
	desc = "A device used for storing digital information. It is designed to lack input firmware. This ROM contains software required to run the NanoTrasen Operating System."
	max_volume = 25000

	New()
		..()
		icon_state = "romos2"
		Add_File(new /datum/file/program/NTOS, null, 1)

/*
Removeable hard drives for portable storage
*/

/obj/item/weapon/computer_part/storage/removable
	name = "Removable Disk Drive"
	max_volume = 3000
	removeable = 1

/*
Removable hard drive presets
*/

/obj/item/weapon/computer_part/storage/removable/datadisk
	name = "Data Disk"
	desc = "A device that can be inserted and removed into computers easily as a form of portable data storage. This one stores 1 Megabyte"
	max_volume = 1024

	New()
		..()
		icon_state = "datadisk[rand(0,6)]"
		src.pixel_x = rand(-5, 5)
		src.pixel_y = rand(-5, 5)

	attack_self(mob/user as mob)
		readonly = !readonly
		user << "You flip the write-protect tab to [readonly ? "protected" : "unprotected"]."

	examine()
		set src in oview(5)
		..()
		usr << text("The write-protect tab is set to [readonly ? "protected" : "unprotected"].")
		return

	init()
		..()
		drive = removeable_drive




