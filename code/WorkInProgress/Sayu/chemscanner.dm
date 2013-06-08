/obj/item/device/porta_chem
	name = "portable chemmaster"
	desc = "Has a portable centrifuge for reagent separation and analysis."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer"
	flags = FPRINT | TABLEPASS | NOREACT
	var/internal_volume = 10 // not meant for mass usage

	var/obj/item/weapon/reagent_containers/B1 = null
	var/obj/item/weapon/reagent_containers/B2 = null

	attackby(var/obj/item/I as obj, var/mob/living/ML as mob)
		if(istype(I,/obj/item/weapon/reagent_containers/glass/beaker) || istype(I,/obj/item/weapon/reagent_containers/glass/bottle) || istype(I,/obj/item/weapon/reagent_containers/food/drinks) || istype(I,/obj/item/weapon/reagent_containers/spray) || istype(I,/obj/item/weapon/reagent_containers/hypospray))
			if(B1 && B2)
				ML << "\red Both slots on [src] are full!"
				return 1
			ML.drop_item()
			I.loc = src
			if(B1)
				B2 = I
			else
				B1 = I
			ML << "\blue You attach [I] to [src]."
			return 1
		if(istype(I,/obj/item/weapon/reagent_containers))
			ML << "It looks like [src] is designed to attach to bottles."
			return 0
	attack_self(var/mob/living/ML as mob)
		interact()
		return

	interact()
		usr.set_machine(src)
		var/datum/browser/popup = new(usr,"chemscanner","Chemical Analyzer", nref = src)
		popup.set_content(menu())
		popup.open()
		return

	proc/menu()
		var/left_reagents = format_bottle(B1,0)
		var/right_reagents = format_bottle(B2,1)
		var/center_reagents = format_self()

		var/dat = {"
			<TT>chemical analysis engine 1.0<br>
			<table style='width:100%'>
				<tr>
					<th style='width:25%'>[B1?"connected [round(B1.reagents.total_volume,0.1)] / [B1.reagents.maximum_volume] <a href='?src=\ref[src];eject=0'>eject</a>":"<a href='?src=\ref[src];insert=0'>NO SIGNAL</a>"]</th>
					<th style='width:50%'>INTERNAL CAPACITOR</th>
					<th style='width:25%'>[B2?"connected [round(B2.reagents.total_volume,0.1)] / [B2.reagents.maximum_volume] <a href='?src=\ref[src];eject=1'>eject</a>":"<a href='?src=\ref[src];insert=1'>NO SIGNAL</a>"]</th>
				</tr><tr>
					<td>[left_reagents]</td>
					<td>[center_reagents]</td>
					<td>[right_reagents]</td>
				</tr>
			</table>
		"}
		return dat

	proc/format_bottle(var/obj/item/weapon/reagent_containers/bottle, var/leftjustify)
		var/dat = "<div style='text-align:[leftjustify?"left":"right"]'>"
		if(!bottle)
			return dat + "container not detected<br>please connect a recepticle<br>and press any key" + "</div>"
		var/datum/reagents/R = bottle.reagents
		dat += "<hr>"
		var/found = 0
		for(var/datum/reagent/DR in R.reagent_list)
			if(istype(DR,/datum/reagent/nothing))
				continue // this will annoy mime chemists
			else
				dat += "<b>[DR.name]</b> [round(DR.volume,0.1)]mg <br>"
				found = 1
		if(!found)
			dat += "<br><br><b>Nothing</b><br><br>"
		dat += "<br><hr>load sample:<br>"
		var/T = R.total_volume
		for(var/entry in list(1,2,5,10))
			if(T > entry)
				dat += "<a href='?src=\ref[src];transfer=[leftjustify]&amount=[entry]'>[entry]mg</a> "
			else
				dat += "<a href='?src=\ref[src];transfer=[leftjustify]&amount=[T]'>all</a>"
				break
		return dat + "</div>"

	proc/format_self()
		if(!src.reagents)
			src.reagents = new /datum/reagents(internal_volume)
			src.reagents.my_atom = src
		var/dat = "<form action='' style='text-align:center'><input type='hidden' name='src' value='\ref[src]'><table>"
		for(var/datum/reagent/DR in src.reagents.reagent_list)
			dat += "<tr><td><b>[DR.name]</b> [DR.volume]</td><td><input type='checkbox' name='[DR.id]' value='1'></input></td></tr>"
		if(src.reagents.reagent_list.len == 0)
			dat += "<tr><td>No Reagents</td></tr>"
		dat += {"<tr><td colspan=2>
			<input type='submit' name='do_tleft' value='&lt;&lt; Transfer'>
			<input type='submit' name='do_dump' value='Discard'>
			<input type='submit' name='do_tright' value='Transfer &gt;&gt;'>
			</td></tr>"}
		return dat + "</table></form>"
	Topic(var/href,var/list/href_list)
		if(length(list("do_tleft","do_tright","do_dump")&href_list))
			var/obj/item/weapon/reagent_containers/dest = null

			if("do_tleft" in href_list) // if B1/B2 is null then it is dumped
				dest = B1
			else if("do_tright" in href_list)
				dest = B2
			href_list -= list("src","do_tleft","do_tright","do_dump")
			for(var/entry in href_list)
				if(!dest)
					src.reagents.del_reagent(entry)
				else
					src.reagents.trans_id_to(dest,entry,internal_volume)
			interact()
			return
		if("transfer" in href_list)
			var/which = text2num(href_list["transfer"])
			var/obj/item/weapon/reagent_containers/source = B1
			if(which)
				source = B2
			if(!source || !source.reagents || !source.reagents.total_volume)
				return
			var/amount = text2num(href_list["amount"])
			source.reagents.trans_to(src,amount)
			interact()
			return
		if("eject" in href_list)
			var/which = text2num(href_list["eject"])
			var/obj/item/weapon/reagent_containers/target
			if(which)
				target = B2
				B2 = null
			else
				target = B1
				B1 = null
			if(target)
				target.loc = get_turf(loc)
				var/mob/living/user = usr
				if(istype(user) && !user.get_inactive_hand() && get_dist(user,target) < 2)
					user.put_in_inactive_hand(target)
			interact()
			return
		if("insert" in href_list)
			var/which = locate(href_list["insert"])
			var/obj/item/weapon/reagent_containers/I = usr.get_active_hand()
			if(istype(I,/obj/item/weapon/reagent_containers/glass/beaker) || istype(I,/obj/item/weapon/reagent_containers/glass/bottle) || istype(I,/obj/item/weapon/reagent_containers/food/drinks) || istype(I,/obj/item/weapon/reagent_containers/spray) || istype(I,/obj/item/weapon/reagent_containers/hypospray))
				switch(which)
					if("0")
						if(B1)
							usr << "There is already a bottle in that slot!"
							interact()
							return
						usr.drop_item()
						B1 = I
						I.loc = src
						interact()
						return
					if("1")
						if(B2)
							usr << "There is already a bottle in that slot!"
							interact()
							return
						usr.drop_item()
						B2 = I
						I.loc = src
						interact()
						return
		if("close" in href_list)
			usr << browse(null,"window=chemscanner")