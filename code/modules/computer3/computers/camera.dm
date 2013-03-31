/*
	Camera monitoring computers
*/

/obj/machinery/computer/security
	name = "Security Cameras"
	desc = "Used to access the various cameras on the station."

	default_prog		= /datum/file/program/security
	spawn_parts			= list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/cameras)
	spawn_files 		= list(/datum/file/camnet_key)


/* doesn't work, either a full computer or it can't get to the key file, I would have to cheat
/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	desc = "An old TV hooked into the stations camera network."
	icon = 'icons/obj/computer.dmi'
	icon_state = "security_det"

	circuit_type	= null	// prevent disassembly
	spawn_parts		= list()// force default program as OS

	update_icon()			// don't show program overlay
		return
*/


/obj/machinery/computer/security/mining
	name = "Outpost Cameras"
	desc = "Used to access the various cameras on the outpost."
	spawn_files 		= list(/datum/file/camnet_key/mining)

/*
	Camera monitoring computers, wall-mounted
*/
/obj/machinery/computer/wall_comp/telescreen
	name = "Security Viewscreen"
	desc = "Used to access the various cameras on the station."

	default_prog		= /datum/file/program/security
	spawn_parts			= list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/cameras)
	spawn_files 		= list(/datum/file/camnet_key)

/obj/machinery/computer/wall_comp/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have /tg/thechannel on these things."
	spawn_files 		= list(/datum/file/camnet_key/entertainment)


/*
	File containing an encrypted camera network key.

	(Where by encrypted I don't actually mean encrypted at all)
*/
/datum/file/camnet_key
	name = "Camera Network Encryption Key"
	var/list/networks = list("SS13")
	var/screen = "cameras"

	execute(var/datum/file/source)
		if(istype(source,/datum/file/program/security))
			var/datum/file/program/security/prog = source
			prog.key = src
			return
		if(istype(source,/datum/file/program/NTOS))
			for(var/obj/item/part/computer/storage/S in computer.peripherals)
				for(var/datum/file/F in S.files)
					if(istype(F,/datum/file/program/security))
						var/datum/file/program/security/Sec = F
						Sec.key = src
						Sec.execute(source)
						return
		computer.ProgramError(MISSING_PROGRAM)

/datum/file/camnet_key/mining
	name = "Mining Camera Network Key"
	networks = list("MINE")
	screen = "miningcameras"

/datum/file/camnet_key/research
	name = "Research Camera Network Key"
	networks = list("RD")

/datum/file/camnet_key/bombrange
	name = "R&D Bomb Range Camera Network Key"
	networks = list("Toxins")

/datum/file/camnet_key/xeno
	name = "R&D Misc. Research Camera Network Key"
	networks = list("Misc")

/datum/file/camnet_key/singulo
	name = "Singularity Camera Network Key"
	networks = list("Singularity")

/datum/file/camnet_key/entertainment
	name = "Entertainment Channel Encryption Key"
	networks = list("thunder")
	screen = "entertainment"

/datum/file/camnet_key/creed
	name = "Special Ops Camera Encryption Key"
	networks = list("CREED")

/datum/file/camnet_key/prison
	name = "Prison Camera Network Key"
	networks = list("Prison")



/*
	Computer part needed to connect to cameras
*/

/obj/item/part/computer/networking/cameras
	name = "Camera network access module"
	desc = "Connects a computer to the camera network."

	var/obj/machinery/camera/current = null

	// I have no idea what the following does
	var/mapping = 0//For the overview file, interesting bit of code.

	proc/camera_list(var/datum/file/camnet_key/key)
		if (computer.z > 6)
			return null
		var/list/L = list()
		for (var/obj/machinery/camera/C in cameranet.cameras)
			var/list/temp = C.network & key.networks
			if(temp.len)
				L.Add(C)
		camera_sort(L)

		return L

	proc/show_camera(var/mob/user)
		if(isAI(user) && current && current.can_use())
			var/mob/living/silicon/ai/A = user
			A.eyeobj.setLoc(get_turf(current))
			A.client.eye = A.eyeobj
			return

		if(!current || get_dist(user, computer) > 1 || usr.blinded || !usr.canmove || !current.can_use())
			user.reset_view(null)
		else
			user.reset_view(current)

/*
	Camera monitoring program
*/

/datum/file/program/security
	name			= "Camera Monitor"
	desc			= "Connets to the Nanotrasen Camera Network"
	image			= 'icons/NTOS/camera.png'
	active_state	= "cameras"
	required_peripherals = list(/obj/item/part/computer/networking/cameras)

	var/obj/item/part/computer/networking/cameras/linked_component = null
	var/datum/file/camnet_key/key = null
	var/last_pic = 1.0
	var/last_camera_refresh = 0
	var/camera_list = null

	Reset()
		if(!key)
			for(var/obj/item/part/computer/storage/S in computer.peripherals)
				for(var/datum/file/F in S.files)
					if(istype(F,/datum/file/camnet_key))
						F.execute(src)
						break
			if(!key)
				computer.ProgramError(PROG_CRASH) // todo: missing file or something
				return
		..()

	interact()
		if(!computer || computer.stat)	return 0

		if(!linked_component)
			linked_component = computer.get_peripheral(/obj/item/part/computer/networking/cameras)

			if(!linked_component) // no module installed
				computer.ProgramError(MISSING_PERIPHERAL)
				return
		if(!key)
			Reset()
		linked_component.show_camera(usr)

		if(world.time - last_camera_refresh > 50 || !camera_list)
			last_camera_refresh = world.time

			var/list/temp_list = linked_component.camera_list(key)

			camera_list = topic_link(src,"close","Close") + "<br><br>"
			for(var/obj/machinery/camera/C in temp_list)
				if(C.status)
					camera_list += "[C.c_tag] - [topic_link(src,"show=\ref[C]","Show")]<br>"
				else
					camera_list += "[C.c_tag] - <b>DEACTIVATED</b><br>"
			camera_list += "<br>" + topic_link(src,"close","Close")

		if(!popup)
			popup = new(usr, "\ref[computer]", name)
			popup.set_title_image(usr.browse_rsc_icon(computer.icon, computer.icon_state))

		popup.set_content(camera_list)
		popup.open()
		linked_component.show_camera(usr)

	update_icon()
		if(key)
			overlay.icon_state = key.screen
		else
			overlay.icon_state = "cameras"

	Topic(var/href,var/list/href_list)
		if(!linked_component)
			linked_component = locate() in computer.peripherals
			if(!linked_component) return

		if("show" in href_list)
			var/obj/machinery/camera/C = locate(href_list["show"])
			linked_component.current = C
			linked_component.show_camera(usr)
			interact()
			return

		if("close" in href_list)

			popup.close()
			return

