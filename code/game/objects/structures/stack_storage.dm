/obj/structure/stack_dispenser
	name = "Materials Storage Unit"
	desc = "Also called 'shelves'."
	icon = 'icons/obj/structures.dmi'
	icon_state = "shelves0"
	density = 1
	anchored = 1
	var/max_total = 1000
	var/total = 0
	var/spawn_stacks = list() // typekey = amount

	New()
		..()
		for(var/typekey in spawn_stacks)
			if(!ispath(typekey,/obj/item/stack)) continue
			var/amount = spawn_stacks[typekey]
			var/obj/item/stack/S = new typekey(src)
			if(!amount)
				amount = S.max_amount
			S.amount = amount
			total += amount
		if(total > max_total)
			max_total = total
		update_icon()

	update_icon()
		if(!total)
			icon_state = "shelves0"
		else
			var/which = round((10*total-1)/max_total)+1
			if(which < 1) which = 1
			if(which > 9) which = 9
			icon_state = "shelves[which]"
	proc/insert(var/obj/item/stack/S)
		if(!istype(S) || S.amount < 1 || istype(S,/obj/item/stack/medical))
			return 0
		var/obj/item/stack/target = null
		for(var/obj/item/stack/test in contents)
			if(test.type == S.type)
				target = test
				break
		if(!target)
			target = new S.type(src)
			target.amount = 0
		var/insert_quantity = min(S.amount, max_total - total)
		target.amount += insert_quantity
		S.use(insert_quantity)
		total += insert_quantity
		update_icon()
		return insert_quantity

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		if(istype(user,/mob/living/silicon)) // cyborgs
			return
		if(istype(I,/obj/item/stack))
			if(total >= max_total)
				user << "\blue [src] is full."
				return
			var/temp = I.name
			var/result = insert(I)
			if(result)
				user << "You add [result] [temp] to [src]."
			return
		if(istype(I,/obj/item/weapon/storage/bag))
			var/obj/item/weapon/storage/bag/B = I
			if(!B.contents.len)
				user << "[B] is empty!"
				return
			var/oldtotal = total
			for(var/obj/item/stack/S in B)
				if(total >= max_total)
					user << "\blue [src] is full."
					return
				insert(S)
			if(!B.contents.len)
				user << "\blue You empty [B] into [src]."
			else if(total != oldtotal)
				user << "\red There is nothing in [B] to put in [src]!"
			else
				user << "You add [total-oldtotal] sheets to [src]."
			return
		..()

	attack_hand(var/mob/user as mob)
		var/dat = ""
		for(var/obj/item/stack/S in src)
			dat += "[S.amount] [S.name] - <a href='?src=\ref[src];vend=\ref[S]&amount=1'>(1)</a>"
			if(S.amount > 10)
				dat += " <a href='?src=\ref[src];vend=\ref[S]&amount=10'>(10)</a>"
				var/half = S.max_amount/2
				if(S.amount > half)
					dat += " <a href='?src=\ref[src];vend=\ref[S]&amount=[half]'>([half])</a>"
					if(S.amount >= S.max_amount)
						dat += " <a href='?src=\ref[src];vend=\ref[S]&amount=[S.max_amount]'>([S.max_amount])</a>"
			if(S.amount > 1 && S.amount < S.max_amount)
				dat += " <a href='?src=\ref[src];vend=\ref[S]&amount=[S.amount]'>(All)</a>"
			dat += "<br>"
		user << browse(dat,"window=matstorage")
	Topic(var/href, var/list/href_list)
		if(get_dist(src,usr) > 1) return
		var/obj/item/stack/stack = locate(href_list["vend"])
		var/amount = text2num(href_list["amount"])
		if(!istype(stack) || !amount) return
		amount = min(stack.amount, amount)

		var/obj/item/stack/dispensed = new stack.type(loc)
		dispensed.amount = amount
		usr.put_in_hands(dispensed)

		stack.use(amount)
		total -= amount
		update_icon()

/obj/structure/stack_dispenser/eva
	spawn_stacks = list(/obj/item/stack/sheet/plasteel = 20, /obj/item/stack/sheet/metal = 100, /obj/item/stack/rods = 50, /obj/item/stack/sheet/rglass = 100, /obj/item/stack/sheet/glass = 100, /obj/item/stack/tile/plasteel = 120)
/obj/structure/stack_dispenser/aux_storage
	spawn_stacks = list(/obj/item/stack/sheet/metal = 100, /obj/item/stack/sheet/glass = 100, /obj/item/stack/rods = 50, /obj/item/stack/tile/plasteel = 60)
