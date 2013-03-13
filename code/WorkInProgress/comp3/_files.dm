/*
Files are datums that can be stored in digital storage devices
*/

/datum/file

	var/name = "File"
	var/extension = "txt"
	var/volume = 10 // in KB
	var/image = 'icons/NTOS/file.png' // determines the icon to use, found in icons/NTOS
	var/invisible = 0 // the program or file is completely invisible
	var/obj/machinery/computer/computer // the parent computer
	var/obj/item/weapon/computer_part/storage/device // the device that is containing this file
	var/datum/file/directory/container // the directory directly containing this file. if none, the directory is /root
	var/metafile = 0 // a "file" manifested by the operating system. doesn't actually exist

/datum/file/proc/execute(var/datum/file/source)
	..()

/*
A file that contains information
*/

/datum/file/container

	var/content = "content goes here"
	var/nonmodifiable = 0
	var/file_increment = 1
	var/binary = 0 // determines if the file can't be opened by editor

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

/datum/file/container/text
	name = "Text File"
	extension = "txt"
	image = 'icons/NTOS/file.png'
	content = ""
	file_increment = 0.002 // 0.002 kilobytes per character (1024 characters per KB)

/datum/file/container/text/ClownProphecy
	name = "Clown Prophecy"
	content = "HONKhHONKeHONKlHONKpHONKHONmKHONKeHONKHONKpHONKlHONKeHONKaHONKsHONKe"


/*
A file that contains research
*/

/datum/file/container/research
	name = "Untitled Research"
	binary = 1
	content = "Untitled Tier X Research"
	var/datum/tech/stored // the actual tech contents
	volume = 1440

/*
A file that contains genetic information
*/

/datum/file/container/genome
	name = "Genetic Buffer"
	nonmodifiable = 1
	binary = 1
	var/owner

/datum/file/container/genome/SE
	name = "Structural Enzymes"

/datum/file/container/genome/UE
	name = "Unique Enzymes"

/datum/file/container/genome/UE/GodEmperorOfMankind
	name = "G.E.M.K."
	content = "066000033000000000AF00330660FF4DB002690"
	owner = "God Emperor of Mankind"

/datum/file/container/genome/UI
	name = "Unique Identifier"

/datum/file/container/genome/UIUE
	name = "Unique Identifier & Unique Enzymes"

/*
A pseudo-file that is used to organize files into categories
*/

/datum/file/directory
	name = "Directory"
	extension = "dir"
	volume = 0 // the actual directory itself takes no volume
	image = 'icons/NTOS/folder.png'
	var/list/files = list() // the files inside this directory (doesn't include files inside folders inside this directory!)

/datum/file/directory/metadata
	name = "Meta Folder"
	metafile = 1 // a manifestation of the OS itself
	image = 'icons/NTOS/foldermeta.png'

/datum/file/directory/metadata/drive
	name = "C:"
	image = 'icons/NTOS/drive.png'