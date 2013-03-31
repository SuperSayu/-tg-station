
/*
	Objects used to construct computers, and objects that can be inserted into them, etc.
*/

/obj/item/part/computer
	name = "computer part"
	desc = "Holy jesus you donnit now"
	gender = PLURAL
	icon = 'icons/obj/stock_parts.dmi'
	w_class = 2.0
	var/obj/machinery/computer/computer // the computer that this device is attached to

	proc/init(var/obj/machinery/computer/target)
		computer = target
		// continue to handle all other type-specific procedures

/*
	Computer devices that can store programs, files, etc.
*/

/obj/item/part/computer/storage
	name			= "Storage Device"
	desc			= "A device used for storing and retrieving digital information."

	// storage capacity, kb
	var/volume		= 0
	var/max_volume	= 64		// should be enough for anyone

	var/list/files	= list()	// a list of files in the memory (ALL files)
	var/removeable	= 0			// determinse if the storage device is a removable hard drive (ie floppy)
	var/driveletter	= null


	// Add a file ot the hard drive, returns 0 if failed
	proc/Add_File(var/datum/file/F)
		if(!F)
			return 0
		if(volume + F.volume > max_volume)
			return 0

		files.Add(F)
		F.computer = computer
		F.device = src
		return 1

	init(var/obj/machinery/computer/target)
		computer = target
		for(var/datum/file/F in files)
			F.computer = computer

		var/list/avail_drives
		if(removeable)
			avail_drives = removeable_drives - computer.drive_list
		else
			avail_drives = computer_drives - computer.drive_list
		var/driveletter = avail_drives[1]

		var/datum/file/drive/D = new()
		D.computer	= computer
		D.device	= src
		D.name		= "[driveletter] Drive"
		computer.drive_list[driveletter] = D

//		var/datum/file/drive/up/up = locate() in files
//		if(!up)
//			up = new
//			up.computer = computer
//			files.Insert(1,up)		// mushroom noise here

/*
	Standard hard drives for computers. Used in computer construction
*/

/obj/item/part/computer/storage/hdd
	name = "Hard Drive"
	max_volume = 25000
	icon_state = "hdd1"


/obj/item/part/computer/storage/hdd/big
	name = "Big Hard Drive"
	max_volume = 50000
	icon_state = "hdd2"

/obj/item/part/computer/storage/hdd/gigantic
	name = "Gigantic Hard Drive"
	max_volume = 75000
	icon_state = "hdd3"

/*
	Removeable hard drives for portable storage
*/

/obj/item/part/computer/storage/removable
	name = "Removable Disk Drive"
	max_volume = 3000
	removeable = 1

	var/obj/item/part/disk/c_data/inserted

/*
	Removable hard drive presets
*/

/obj/item/part/disk/c_data
	parent_type = /obj/item/part/computer/storage // todon't: do this
	name = "Data Disk"
	desc = "A device that can be inserted and removed into computers easily as a form of portable data storage. This one stores 1 Megabyte"
	max_volume = 1024

	New()
		..()
		icon_state = "datadisk[rand(0,6)]"
		src.pixel_x = rand(-5, 5)
		src.pixel_y = rand(-5, 5)


/obj/item/part/computer/ai_holder
	name = "intelliCard computer module"
	desc = "Contains a specialized nacelle for dealing with highly sensitive equipment without interference."
	var/mob/living/silicon/ai/occupant	= null
	var/busy = 0


/obj/item/part/computer/networking
	name = "Computer networking component"

	/*
		Used to
	*/
	proc/connect_to(var/typekey)
		return null

/obj/item/part/computer/networking/radio
	name = "Wireless networking component"
	desc = "Radio module for computers"

	var/datum/radio_frequency/radio_connection	= null
	var/frequency = 1459
	var/filter = null
	var/range = null

	init()
		..()
		spawn(5)
			radio_connection = radio_controller.add_object(src, src.frequency, src.filter)

	proc/set_frequency(new_frequency)
		radio_controller.remove_object(src, frequency)
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, frequency, filter)

	receive_signal(var/datum/signal/signal)
		if(!signal || !computer || computer.stat) return
		if(computer.program)
			computer.program.receive_signal(signal)
		else if(computer.os)
			testing("To OS [computer.os]")
			computer.os.receive_signal(signal)

	proc/post_signal(var/datum/signal/signal)
		if(!computer || computer.stat || !computer.program) return
		if(!radio_connection) return

		radio_connection.post_signal(src,signal,filter,range)

/*
	Proximity networking: Connects to machines or computers adjacent to this device
*/
/obj/item/part/computer/networking/prox
	name = "Proximity Networking Terminal"
	desc = "Connects a computer to adjacent machines"

	proc/connectTo(var/typekey,var/range = 1)
		if(!ispath(typekey,/obj/machinery))
			testing("Strange typekey in computer/prox/connectTo: [typekey]")
		var/atom/A = locate(typekey) in orange(range)
		testing("computer/prox/connectTo: [A] [typekey]")
		return A

/*
	Cable networking: Not currently used
*/

/obj/item/part/computer/networking/cable
	name = "Cable Networking Terminal"
	desc = "Connects to other machines on the same power network."

	proc/connectTo(var/typekey)
		return null

/*
	Subspace networking: Communicates off-station.  No functionality at current.
	Todo: telecoms?!?
*/
/obj/item/part/computer/networking/subspace
	name = "Subspace Networking Terminal"
	desc = "Communicates long distances and through certain spatial anomalies."
