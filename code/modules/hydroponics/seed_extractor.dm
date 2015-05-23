/proc/seedify(var/obj/item/O as obj, var/t_max)
	var/t_amount = 0
	if(t_max == -1)
		t_max = rand(1,4)

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
		while(t_amount < t_max)
			var/obj/item/seeds/t_prod = new F.seed(O.loc, O)
			t_prod.lifespan = F.lifespan
			t_prod.endurance = F.endurance
			t_prod.maturation = F.maturation
			t_prod.production = F.production
			t_prod.yield = F.yield
			t_prod.potency = F.potency
			t_amount++
		qdel(O)
		return 1

	else if(istype(O, /obj/item/weapon/grown/))
		var/obj/item/weapon/grown/F = O
		if(F.seed)
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = new F.seed(O.loc, O)
				t_prod.lifespan = F.lifespan
				t_prod.endurance = F.endurance
				t_prod.maturation = F.maturation
				t_prod.production = F.production
				t_prod.yield = F.yield
				t_prod.potency = F.potency
				t_amount++
			qdel(O)
			return 1
		else return 0

	/*else if(istype(O, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = O
		new /obj/item/seeds/grassseed(O.loc)
		S.use(1)
		return 1*/

	else
		return 0


/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1
	var/piles = list()

obj/machinery/seed_extractor/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(isrobot(user))
		return

	if (istype(O,/obj/item/weapon/storage/bag))
		if(O.contents.len)
			var/obj/item/weapon/storage/P = O
			var/loaded = 0
			for(var/obj/item/seeds/G in P.contents)
				if(contents.len >= 999)
					break
				++loaded
				add(G)
			if (loaded)
				user << "<span class='notice'>You put the seeds from [O] into [src].</span>"
			else
				loaded = 0
				for(var/obj/item/I in P.contents)
					if(contents.len >= 999)
						break
					P.remove_from_storage(I,loc)
					if(seedify(I,-1))
						++loaded
					else
						P.handle_item_insertion(I)
				if(loaded)
					user << "<span class='notice'>You extract some seeds from plants in [O].</span>"
				else
					user << "<span class='notice'>There are no seeds or plants in [O].</span>"
			return
		if(istype(O,/obj/item/weapon/storage/bag/seeds))
			if(user.drop_item())
				user << "You recycle [O]."
				qdel(O)
			else
				user << "[O] is stuck to your hand!"
			return
		user << "[O] is empty."

	if(!user.drop_item()) //couldn't drop the item
		user << "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the seed extractor!</span>"
		return

	if(O && O.loc)
		O.loc = src.loc

	if(seedify(O,-1))
		user << "<span class='notice'>You extract some seeds.</span>"
		return
	else if (istype(O,/obj/item/seeds))
		add(O)
		user << "<span class='notice'>You add [O] to [src.name].</span>"
		updateUsrDialog()
		return
	else
		user << "<span class='warning'>You can't extract any seeds from \the [O.name]!</span>"

datum/seed_pile
	var/obj/item/seeds/template = null
	var/list/seeds = list()

datum/seed_pile/New(var/obj/item/seeds/master)
	template = master
	seeds += master

datum/seed_pile/proc/compare(var/obj/item/seeds/candidate)
	if(candidate.type != template.type) return 0
	if(candidate.lifespan != template.lifespan) return 0
	if(candidate.endurance != template.endurance) return 0
	if(candidate.maturation != template.maturation) return 0
	if(candidate.production != template.production) return 0
	if(candidate.yield != template.yield) return 0
	if(candidate.potency != template.potency) return 0
	return 1

datum/seed_pile/proc/pop()
	. = seeds[seeds.len]
	seeds.len--

/obj/machinery/seed_extractor/proc/desc_table()
	. = "<table cellpadding='3'>"
	. += "<tr><td>Amt</td><td>Name</td><td>Lifespan</td><td>Endurance</td><td>Maturation</td><td>Potency</td><td>Production</td><td>Yield</td><td>Stock</td></tr>"
	for(var/datum/seed_pile/P in piles)
		. += desc_row(P,1)
	. += "</table>"
	return .

/obj/machinery/seed_extractor/proc/desc_row(var/datum/seed_pile/P)
	var/obj/item/seeds/O = P.template
	. = "<tr><td>[P.seeds.len]</td><td>[O.plantname]</td><td>[O.lifespan]</td><td>[O.endurance]</td><td>[O.maturation]</td>"
	. += "<td>[O.potency]</td><td>[O.production]</td><td>[O.yield]</td>"
	. += "<td><a href='?\ref[src];vend=\ref[P]'>Vend</a>"
	if(P.seeds.len > 1)
		. += " <a href='?\ref[src];bag=\ref[P]'>Bag</a>"
	. +="</td></tr>"

/obj/machinery/seed_extractor/proc/desc_bag(var/datum/seed_pile/P)
	var/obj/item/seeds/O = P.template
	return "<i>[O.plantname] L([O.lifespan]) E([O.endurance]) M([O.maturation]) Po([O.potency]) Pr([O.production]) Y([O.yield])</i>"


/obj/machinery/seed_extractor/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

obj/machinery/seed_extractor/interact(mob/user as mob)
	if (stat)
		return 0

	var/dat = "<b>Stored seeds:</b><br>"

	if (contents.len == 0)
		dat += "<font color='red'>No seeds</font>"
	else
		dat += desc_table()
	var/datum/browser/popup = new(user, "seed_ext", name, 700, 400)
	popup.set_content(dat)
	popup.open()
	return

obj/machinery/seed_extractor/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)

	// handle_item_insertion does a senseless usr check
	var/u = usr
	usr = null
	if("vend" in href_list)
		var/datum/seed_pile/P = locate(href_list["vend"])
		if(P && (P in piles))
			var/obj/item/seeds/S = P.pop()
			if(S)
				S.loc = loc
			if(!P.seeds.len)
				piles -= P
				qdel(P)
	else if("bag" in href_list)
		var/datum/seed_pile/P = locate(href_list["bag"])
		if(P && (P in piles))
			var/obj/item/weapon/storage/bag/seeds/B = new(loc)
			var/to_bag = min(P.seeds.len, B.storage_slots)
			while(to_bag--)
				B.handle_item_insertion(P.pop())
			B.desc += "<br>It is labelled [desc_bag(P)]"
			if(!P.seeds.len)
				piles -= P
				qdel(P)
	usr = u
	src.updateUsrDialog()
	return

obj/machinery/seed_extractor/proc/add(var/obj/item/seeds/O as obj)
	if(contents.len >= 999)
		usr << "<span class='notice'>\The [src] is full.</span>"
		return 0

	if(istype(O.loc,/mob))
		var/mob/M = O.loc
		if(!M.unEquip(O))
			usr << "<span class='warning'>\the [O] is stuck to your hand, you cannot put it in \the [src]!</span>"
			return
	else if(istype(O.loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = O.loc
		S.remove_from_storage(O,src)

	O.loc = src

	for (var/datum/seed_pile/N in piles)
		if (N.compare(O))
			N.seeds += O
			return

	piles += new /datum/seed_pile(O)
	return
