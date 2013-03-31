// I am deciding that for sayustation's purposes directories are right out,
// we can't even get backpacks to work right with recursion, and that
// actually fucking matters.  Metadata too, that can be added if ever needed.

/*
	Files are datums that can be stored in digital storage devices
*/

/datum/file
	var/name = "File"
	var/extension = "dat"
	var/volume = 10 // in KB
	var/image = 'icons/NTOS/file.png' // determines the icon to use, found in icons/NTOS
	var/obj/machinery/computer/computer // the parent computer, if fixed
	var/obj/item/part/computer/storage/device // the device that is containing this file


/datum/file/proc/execute(var/datum/file/source)
	..()

/datum/file/drive
	name = "C: Drive"
	extension = ""
	volume = 0
	image = 'icons/NTOS/drive.png'

	execute(var/datum/file/source)
		if(istype(source,/datum/file/program/NTOS))
			var/datum/file/program/NTOS/os = source
			os.current = device
			computer.interact()
			return

/datum/file/drive/up
	name = "Up"
	execute(var/datum/file/source)
		if(istype(source,/datum/file/program/NTOS))
			var/datum/file/program/NTOS/os = source
			os.current = null
			computer.interact()
			return
/*
	A file that contains information
*/

/datum/file/data

	var/content			= "content goes here"
	var/readonly		= 0
	var/file_increment	= 1
	var/binary			= 0 // determines if the file can't be opened by editor

	// Set the content to a specific amount, increase filesize appropriately.
	proc/set_content(var/text)
		content = text
		if(file_increment > 1)
			volume = round(file_increment * length(text))

	New()
		if(content)
			if(file_increment > 1)
				volume = round(file_increment * length(content))

/*
	A generic file that contains text
*/

/datum/file/data/text
	name = "Text File"
	extension = "txt"
	image = 'icons/NTOS/file.png'
	content = ""
	file_increment = 0.002 // 0.002 kilobytes per character (1024 characters per KB)

/datum/file/data/text/ClownProphecy
	name = "Clown Prophecy"
	content = "HONKhHONKeHONKlHONKpHONKHONmKHONKeHONKHONKpHONKlHONKeHONKaHONKsHONKe"


/*
	A file that contains research
*/

/datum/file/data/research
	name = "Untitled Research"
	binary = 1
	content = "Untitled Tier X Research"
	var/datum/tech/stored // the actual tech contents
	volume = 1440

/*
	A file that contains genetic information
*/

/datum/file/data/genome
	name = "Genetic Buffer"
	binary = 1
	var/label = "Poop"

/datum/file/data/genome/SE
	name = "Structural Enzymes"

/datum/file/data/genome/UE
	name = "Unique Enzymes"

/datum/file/data/genome/UE/GodEmperorOfMankind
	name = "G.E.M.K."
	content = "066000033000000000AF00330660FF4DB002690"
	label = "God Emperor of Mankind"

/datum/file/data/genome/UI
	name = "Unique Identifier"

/datum/file/data/genome/UIUE
	name = "Unique Identifier & Unique Enzymes"

