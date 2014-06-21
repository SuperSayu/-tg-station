/obj/item/device/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which has to count down. Tick tock."
	icon_state = "timer"
	m_amt = 500
	g_amt = 50
	origin_tech = "magnets=1"

	secured = 0

	bomb_name = "time bomb"

	var/timing = 0
	var/time = 10
	var/repeat = 0
	var/set_time = 10


/obj/item/device/assembly/timer/describe()
	if(timing)
		return "The timer is counting down from [time]!"
	return "The timer is set for [time] seconds."


/obj/item/device/assembly/timer/activate()
	if(!..())	return 0//Cooldown check
	timing = !timing
	update_icon()
	return 0


/obj/item/device/assembly/timer/toggle_secure()
	secured = !secured
	if(secured)
		processing_objects.Add(src)
	else
		timing = 0
		processing_objects.Remove(src)
	update_icon()
	return secured


/obj/item/device/assembly/timer/proc/timer_end()
	if((!secured)||(cooldown > 0))	return 0
	pulse(0)
	loc.visible_message("\icon[src] *beep* *beep*", "*beep* *beep*")
	cooldown = 2
	spawn(10)
		process_cooldown()
	return


/obj/item/device/assembly/timer/process()
	if(timing && (time > 0))
		time--
	if(timing && time <= 0)
		timing = repeat
		timer_end()
		time = set_time
	return


/obj/item/device/assembly/timer/update_icon()
	overlays.Cut()
	attached_overlays = list()
	if(timing)
		overlays += "timer_timing"
		attached_overlays += "timer_timing"
	if(holder)
		holder.update_icon()
	return


/obj/item/device/assembly/timer/interact(mob/user as mob)//TODO: Have this use the wires
	if(!secured)
		user.show_message("\red The [name] is unsecured!")
		return 0
	var/second = time % 60
	var/minute = (time - second) / 60
	var/set_second = set_time % 60
	var/set_minute = (set_time - set_second) / 60
	if(second < 10) second = "0[second]"
	if(set_second < 10) set_second = "0[set_second]"
	var/dat = {"
	<TT>
		<center><h2>Timing Unit</h2>
		[minute]:[second] <a href='?src=\ref[src];time=1'>[timing?"Stop":"Start"]</a> <a href='?src=\ref[src];reset=1'>Reset</a><br>
		Repeat: <a href='?src=\ref[src];repeat=1'>[repeat?"On":"Off"]</a><br>
		Timer set for
		<A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> [set_minute]:[set_second] <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>
		</center>
	</TT>
	<BR><BR>
	<A href='?src=\ref[src];refresh=1'>Refresh</A>
	<BR><BR>
	<A href='?src=\ref[src];close=1'>Close</A>"}
	var/datum/browser/popup = new(user, "timer", name)
	popup.set_content(dat)
	popup.open()
	return


/obj/item/device/assembly/timer/Topic(href, href_list)
	..()
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=timer")
		onclose(usr, "timer")
		return
		if(href_list["reset"])
			time = set_time

	if(href_list["time"])
		timing = text2num(href_list["time"])
		if(timing && istype(holder, /obj/item/device/transfer_valve))
			var/timer_message = "[key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) activated [src] attachment on [holder]."
			message_admins(timer_message)
			bombers += timer_message
			log_game("[key_name(usr)] activated [src] attachment for [loc]")
		update_icon()
	if(href_list["repeat"])
		repeat = !repeat

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 1), 600)

	if(href_list["close"])
		usr << browse(null, "window=timer")
		return

	if(usr)
		attack_self(usr)

	return
