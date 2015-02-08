/datum/hud/proc/ai_hud()
	adding = list()
	other = list()

	var/obj/screen/using

//AI core
	using = new /obj/screen()
	using.name = "AI Core"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_core"
	using.screen_loc = ui_ai_core
	using.layer = 20
	adding += using

//Camera list
	using = new /obj/screen()
	using.name = "Show Camera List"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera"
	using.screen_loc = ui_ai_camera_list
	using.layer = 20
	adding += using

//Track
	using = new /obj/screen()
	using.name = "Track With Camera"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "track"
	using.screen_loc = ui_ai_track_with_camera
	using.layer = 20
	adding += using

//Camera light
	using = new /obj/screen()
	using.name = "Toggle Camera Light"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera_light"
	using.screen_loc = ui_ai_camera_light
	using.layer = 20
	adding += using

//Crew Monitorting
	using = new /obj/screen()
	using.name = "Crew Monitorting"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "crew_monitor"
	using.screen_loc = ui_ai_crew_monitor
	using.layer = 20
	adding += using

//Crew Manifest
	using = new /obj/screen()
	using.name = "Show Crew Manifest"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "manifest"
	using.screen_loc = ui_ai_crew_manifest
	using.layer = 20
	adding += using

//Alerts
	using = new /obj/screen()
	using.name = "Show Alerts"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "alerts"
	using.screen_loc = ui_ai_alerts
	using.layer = 20
	adding += using

//Announcement
	using = new /obj/screen()
	using.name = "Announcement"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "announcement"
	using.screen_loc = ui_ai_announcement
	using.layer = 20
	adding += using

//Shuttle
	using = new /obj/screen()
	using.name = "Call Emergency Shuttle"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "call_shuttle"
	using.screen_loc = ui_ai_shuttle
	using.layer = 20
	adding += using

//Laws
	using = new /obj/screen()
	using.name = "State Laws"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "state_laws"
	using.screen_loc = ui_ai_state_laws
	using.layer = 20
	adding += using

//PDA message
	using = new /obj/screen()
	using.name = "PDA - Send Message"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_send"
	using.screen_loc = ui_ai_pda_send
	using.layer = 20
	adding += using

//PDA log
	using = new /obj/screen()
	using.name = "PDA - Show Message Log"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_receive"
	using.screen_loc = ui_ai_pda_log
	using.layer = 20
	adding += using

//Take image
	using = new /obj/screen()
	using.name = "Take Image"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "take_picture"
	using.screen_loc = ui_ai_take_picture
	using.layer = 20
	adding += using

//View images
	using = new /obj/screen()
	using.name = "View Images"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "view_images"
	using.screen_loc = ui_ai_view_images
	using.layer = 20
	adding += using

//Camera bug
	using = new /obj/screen()
	using.name = "Activate Camera Bug"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera_bug"
	using.screen_loc = ui_ai_camera_bug
	using.layer = 20
	adding += using

	mymob.client.screen += adding + other

	return


/*
/datum/hud/proc/ai_hud()
	return

/mob/living/silicon/ai/update_action_buttons()
	var/num = 1
	if(!hud_used) return
	if(!client) return

	client.screen -= hud_used.item_action_list

	for(var/obj/item/I in src)
		if(I.action_button_name)
			if(hud_used.item_action_list.len < num)
				var/obj/screen/item_action/N = new(hud_used)
				hud_used.item_action_list += N

			var/obj/screen/item_action/A = hud_used.item_action_list[num]

			A.icon = ui_style2icon(client.prefs.UI_style)
			A.icon_state = "template"

			A.overlays = list()
			var/image/img = image(I.icon, A, I.icon_state)
			img.pixel_x = 0
			img.pixel_y = 0
			A.overlays += img

			A.name = I.action_button_name
			A.owner = I

			client.screen += hud_used.item_action_list[num]

			switch(num)
				if(1)
					A.screen_loc = ui_action_slot1
				if(2)
					A.screen_loc = ui_action_slot2
				if(3)
					A.screen_loc = ui_action_slot3
				if(4)
					A.screen_loc = ui_action_slot4
				if(5)
					A.screen_loc = ui_action_slot5
					break //5 slots available, so no more can be added.
			num++
*/