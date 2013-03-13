/*
The Big Bad NT Operating System
*/

#define MAX_ROWS 20
#define MAX_COLUMNS 10

/datum/file/program/NTOS
	name = "Nanotrasen Operating System"
	extension = "!$" // .!$ extension used for metafiles
	invisible = 1
	active_state = "computer_os"
	var/datum/file/directory/scope // the directory currently being viewed. if none, /root
	var/list/root = list() // files in the root directory (the only files that should be here are metadata folders)


/*
Generate a basic list of files in the selected scope
*/

/datum/file/program/NTOS/proc/list_files()

	var/list/files = list()
	if(computer)

		if(!scope)

			for(var/obj/item/weapon/computer_part/storage/S in computer.peripherals)
				var/foundroot = 0
				for(var/datum/file/directory/metadata/F in root)
					if(F.device == S)
						foundroot = 1
						break
				if(!foundroot)
					var/datum/file/directory/metadata/drive/D = new()
					D.name = S.name
					D.extension = "dir"
					D.computer = computer
					D.device = S
					root.Add(D)

			for(var/datum/file/directory/metadata/F in root)
				var/foundobj = 0
				for(var/obj/item/weapon/computer_part/storage/S in computer.peripherals)
					if(F.device == S)
						foundobj = 1
						break

				if(!foundobj)
					del(F)
				else
					files.Add(F)
//		else

	//		for

		return files // return all found files

	return null // no computer was located

/*
Return a datum file from a string path. (not case sensitive)

	FORMAT:
		root/ : jump to the root directory
		[dir]/: jump to a new directory
		../	  : jump back a directory
		(example: root/c:/porno/wgw/file.txt)
*/
/datum/file/program/NTOS/proc/get_file(var/path, var/datum/file/directory/default_scope = null)

	if(!istext(path)) return

	var/MAX_LOOP = 50 // this is to prevent chucklefucks from trying to crash the game somehow
	var/LOOP_CUR = 0
	//var/list/path = text2list(path, "/")
	var/datum/file/directory/path_scope = default_scope

	for(var/x in path)

		LOOP_CUR++
		if(LOOP_CUR >= MAX_LOOP)
			break

		if(lowertext(x) == "root")
			path_scope = null

		else if(x == "..")
			path_scope = path_scope.container

		else
			// We're expecting to find the actual file now
			if(LOOP_CUR)
				if(path_scope)
					for(var/datum/file/F in path_scope.files)
						if(F.extension == "dir")
							if(lowertext(F.name) == lowertext(x))
								return F
						else
							if(lowertext(F.name + ".[F.extension]") == lowertext(x))
								return F
				else
					for(var/datum/file/F in list_files())
						if(F.extension == "dir")
							if(lowertext(F.name) == lowertext(x))
								return F
						else
							if(lowertext(F.name + ".[F.extension]") == lowertext(x))
								return F
			// We're navigating to another directory
			else
				if(path_scope)
					for(var/datum/file/directory/F in path_scope.files)
						if(lowertext(F.name) == lowertext(x))
							path_scope = F
				else
					for(var/datum/file/F in list_files())
						if(lowertext(F.name) == lowertext(x))
							path_scope = F

	return null // file not found!

/*
Place a file in the specific directory (must be a directory file!)
*/
/datum/file/program/NTOS/proc/place_file(var/path, var/datum/file/F, var/datum/file/directory/default_scope = null)

	if(!istext(path)) return

	var/MAX_LOOP = 50 // this is to prevent chucklefucks from trying to crash the game somehow
	var/LOOP_CUR = 0
	//var/list/path = text2list(path, "/")
	var/datum/file/directory/path_scope = default_scope

	for(var/x in path)

		LOOP_CUR++
		if(LOOP_CUR >= MAX_LOOP)
			break

		if(lowertext(x) == "root")
			path_scope = null

		else if(x == "..")
			path_scope = path_scope.container

		// Navigating to directory
//		else
	//		if(path_scope)
	//			for(var/datum/file/directory/F in path_scope.files)
		//			if(lowertext(F.name) == lowertext(x))
			//			path_scope = F
		//	else
		//		for(var/datum/file/F in list_files())
			//		if(lowertext(F.name) == lowertext(x))
				//		path_scope = F

	if(path_scope) // can't add files to root! we need to have a directory
		var/predictedvolume = path_scope.device.volume + F.volume
		if(predictedvolume > path_scope.device.max_volume)
			return 0 // no space for this file!
		else
			if(F.container) // if the file is in an existing directory, simulate movement
				F.container.files.Remove(F)
		//	if(F.device && (F in device.files))
		//		F.device.files.Del(F)

			F.container = path_scope
			F.device = path_scope.device
			F.computer = path_scope.computer
			path_scope.files.Add(F)

/datum/file/program/NTOS/interact(var/mob/user as mob)
	var/dat = {"
	<html>
	<head>
	<title>Nanotrasen Operating System</title>
	<style>
		a.fill-div {
		    display: block;
		    height: 100%;
		    width: 100%;
		    text-decoration: none;
			color: black;
			text-align:center;
		}
		td {
			width: 64;
			height: 64;
			overflow: hidden;
			valign: "top";
		}
		.iconname {
			background-color: #E0E0E0;
			font-family: verdana;
			font-size: 12px;
		}
	</style>
	</head>

	<body>
	<div style = "width:640px;height:480px;border:2px solid black;background-image:url(\ref['icons/NTOS/ntos.png'])">
	"}

	//var/columns = 0 // maximum 10
	var/list/files = list_files()
	if(files)

		dat += "<table border=\"0\" align=\"left\">"
		var/i = 0
		for(var/datum/file/F in files)
			if(F.invisible) continue
			i++
			if(i==1)
				dat += "<tr>"
			if(i>= (MAX_ROWS + 1))
				i = 0
				//columns++
				dat += "</tr>"
				continue

			dat += "<td>"
			dat += "<a href='?src=\ref[src];execute=\ref[F]' class=\"fill-div\">"

			// Display the file's image and name
			var/displayname = F.name
			dat += "\icon[F.image]<br><span class=\"iconname\">[displayname]</span>"

			dat += "</a>"
			dat += "</td>"

		dat += "</tr>"
		dat += "</table>"

	dat += "</div>"
	dat += "</body></html>"


	user << browse(dat, "window=nt_os;size=670x510")
	onclose(user, "nt_os")


/datum/file/program/NTOS/Topic(href, list/href_list)

	if("execute" in href_list) // execute a program based on datum reference identifier

		var/list/files = list_files()
		var/identifier = href_list["execute"]
		for(var/datum/file/F in files)
			if("\ref[F]" == identifier)
				F.execute(src)
				break


#undef MAX_ROWS
#undef MAX_COLUMNS