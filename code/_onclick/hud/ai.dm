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