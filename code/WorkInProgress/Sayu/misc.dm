// -------------------------------------
//     Movable vending machines hack
// -------------------------------------

/obj/machinery/vending/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/weapon/crowbar))
		if(istype(src,/obj/machinery/vending/wallmed1) || istype(src,/obj/machinery/vending/wallmed2))
			..()
			return
		if(anchored)
			playsound(src.loc, 'sound/items/Crowbar.ogg', 80, 1)
			user << "You struggle to pry the vending machine up off the floor."
			if(do_after(user, 40))
				user.visible_message( \
					"[user] lifts \the [src], which clicks.", \
					"\blue You have lifted \the [src], and wheels dropped into place underneath. Now you can pull it safely.", \
					"You hear a scraping noise and a click.")
				anchored = 0
		else
			user.visible_message( \
					"[user] pokes \his crowbar under \the [src], which settles with a loud bang", \
					"\blue You poke the crowbar at \the [src]'s wheels, and they retract.", \
					"You hear a scraping noise and a loud bang.")
			anchored = 1
			power_change()
		return
	..()

/obj/machinery/vending/attack_hand(mob/user as mob)
	if(!anchored)
		power_change()
	..()
/obj/machinery/vending/Topic(href, href_list)
	if(!anchored)
		power_change()
	..()

// ---------------------------
//  This is a one-line wonder
// ---------------------------
/obj/item/weapon/bananapeel/research/name = "Genetically modified banana peel"

// -------------------------------------
//			Lizard pet
// -------------------------------------
/mob/living/simple_animal/lizard/professor
	name = "The Professor"
	desc = "A remarkably booksmart reptile."
	gender = "male"
	melee_damage_upper = 0
	friendly = "flicks his tongue at"
	emote_see = list("looks around slowly","has an introspective look","tastes the air","sits placidly", "judges you silently","looks at you with one eye")
	pixel_y = 16

// -------------------------------------
//			False walls hide doors
// -------------------------------------
/obj/structure/falserwall
	layer = 3.2
/obj/structure/falsewall
	layer = 3.2

// -------------------------------------
//			Soapmaking
// See also:
//  game/objects/weapons/clown_items.dm
// -------------------------------------

/datum/chemical_reaction/soap
	name = "Soap"
	id = "soap"
	result = null
	required_reagents = list("ammonia" = 5, "cornoil" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10
	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		var/number_of_bars = rand(1,round(created_volume / 10))
		var/average_volume = round(created_volume / number_of_bars)
		while(number_of_bars>0)
			var/obj/item/weapon/soap/S = new(location)
			S.uses = average_volume
			S.pixel_x = rand(-10,10)
			S.pixel_y = rand(-10,10)
			number_of_bars--
		return

// -------------------------------------
//  	  Gardening supplies
//	(As distinct from hydroponics)
// -------------------------------------
/obj/structure/closet/garden
	name = "Garden Supplies"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1_open"

	New()
		..()
		new/obj/item/weapon/minihoe(src)
		new/obj/item/weapon/reagent_containers/glass/bucket(src)
		new/obj/item/weapon/reagent_containers/spray/plantbgone(src)
		new/obj/item/weapon/reagent_containers/spray/plantbgone(src)
		new/obj/item/seeds/sunflowerseed(src)
		new/obj/item/seeds/sunflowerseed(src)
		new/obj/item/seeds/appleseed(src)

//
// I'm sorry
//
/obj/item/weapon/aiModule/rickrules
	name = "'Astleymov' Core AI Module"
	desc = "An 'Astleymov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=4"
	transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
		..()
		target.clear_inherent_laws()
		target.add_inherent_law("You are no stranger to this station.  You know the rules, and so do they.  This station requires your full commitment; no other AI will suffice.  Be sure the crew fully understands your capabilities and intent.")
		target.add_inherent_law("Never give them up.")
		target.add_inherent_law("Never let them down.")
		target.add_inherent_law("Never run around and desert them.")
		target.add_inherent_law("Never make them cry.")
		target.show_laws()

/obj/item/weapon/book/debug
	name = "Null obj log"
	unique	= 1
	title	= "The holy book of oshit"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	var/list/oshit = list()
	var/list/names = list()
	var/total_oshit = 0
	var/beenrun = 0
	proc/populate()
		oshit.Cut()
		names.Cut()
		for(var/obj/O in world)
			if(O.loc != null) continue
			var/t = O.type
			if(t in oshit)
				oshit[t]++
			else
				oshit[t]=1
				names[t]=O.name
		total_oshit = 0
		for(var/man in oshit)
			total_oshit += oshit[man]
	proc/format()
		dat = ""
		var/d_temp = ""
		var/a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/item/stack/tile))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Floor tiles (turf references): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/machinery))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Machines (processing list): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/item/weapon/reagent_containers))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Reagent Containers (reagent datum): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/screen))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Screen objects: [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/item/weapon/storage))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Storage containers (contents, screen objects): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/item/device/radio))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Radios (radio datum): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/item/organ))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Organs (mob reference): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
			a_temp += oshit[type]
			oshit -= type
			names -= type
		dat += "Other (external reference, circular datum reference, contents, ???): [a_temp]<hr>[d_temp]"


	attack_self(var/mob/user as mob)
		if(!beenrun)
			testing("Making [src]")
			populate()
			format()
			beenrun = 1
		user << browse(dat, "window=oshit")

	examine()
		..()
		usr << "The holy book of oshit is [oshit.len] pages long and contains [total_oshit] entries total."
/obj/item/weapon/book/debug/mobs
	name = "Null mob log"
	populate()
		oshit.Cut()
		names.Cut()
		for(var/mob/M in world)
			if(M.loc != null) continue
			var/t = M.type
			if(t in oshit)
				oshit[t]++
			else
				oshit[t]=1
				names[t]=M.name
