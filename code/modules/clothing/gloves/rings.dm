/obj/item/clothing/gloves/ring
	name = "iron ring"
	desc = "A band that goes around your finger.  It's considered gauche to wear more than one."
	gender = "neuter" // not plural anymore
	print_clarity = 95
	icon_state = "ironring"
	item_state = ""
	var/material = "iron"
	var/stud = 0
	New()
		..()
		update_icon()

	update_icon()
		if(stud)
			icon_state = "d_[initial(icon_state)]"
		else
			icon_state = initial(icon_state)
	examine()
		..()
		usr << "This one is made of [material]."
		if(stud)
			usr << "It is adorned with a single gem."

// s'pensive
/obj/item/clothing/gloves/ring/silver
	name =  "silver ring"
	icon_state = "silverring"
	material = "silver"
/obj/item/clothing/gloves/ring/silver/blessed // todo
	name = "blessed silver ring"

/obj/item/clothing/gloves/ring/gold
	name =  "gold ring"
	icon_state = "goldring"
	material = "gold"
/obj/item/clothing/gloves/ring/gold/blessed
	name = "wedding band"

// cheap
/obj/item/clothing/gloves/ring/plastic
	name =  "white plastic ring"
	icon_state = "whitering"
	material = "plastic"
/obj/item/clothing/gloves/ring/plastic/blue
	name =  "blue plastic ring"
	icon_state = "bluering"
/obj/item/clothing/gloves/ring/plastic/red
	name =  "red plastic ring"
	icon_state = "redring"
/obj/item/clothing/gloves/ring/plastic/random
	New()
		var/c = pick("white","blue","red")
		name = "[c] plastic ring"
		icon_state = "[c]ring"

// weird
/obj/item/clothing/gloves/ring/glass
	name = "glass ring"
	icon_state = "whitering"
	material = "glass"
/obj/item/clothing/gloves/ring/plasma
	name = "plasma ring"
	icon_state = "plasmaring"
	material = "plasma"
/obj/item/clothing/gloves/ring/uranium
	name = "uranium ring"
	icon_state = "uraniumring"
	material = "uranium"

// cultish
/obj/item/clothing/gloves/ring/shadow
	name = "shadow ring"
	icon_state = "shadowring"
	material = "shadows"
