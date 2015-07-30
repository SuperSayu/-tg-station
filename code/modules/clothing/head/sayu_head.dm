/*
 * Wig (added by Collen)
 */

/obj/item/clothing/head/wig
	name = "wig"
	desc = "You can finally cover up that ugly bald spot."
	icon = 'icons/mob/human_face.dmi'
	icon_state = "hair_bigafro_s"
	alternate_worn_icon = 'icons/mob/human_face.dmi'
	//flags = BLOCKHAIR -- causes facial hair to disappear, keep this commented out

/obj/item/clothing/head/wig/New()
	..()
	var/hex = random_string(3, hex_characters)
	color = "#[hex]"

/obj/item/clothing/head/wig/attack_self(mob/user)
	if(ishuman(user))
		//var/mob/living/carbon/human/H = user
		var/new_style = input(user, "Select a hair style", "Wig")  as null|anything in hair_styles_list
		if(new_style)

			if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
				return

			var/datum/sprite_accessory/S = hair_styles_list[new_style]
			if(S != null)
				icon_state = "[S.icon_state]_s"

/obj/item/clothing/head/wig/AltClick(var/mob/user)
	..()

	if(!user.canUseTopic(user))
		user << "<span class='warning'>You can't do that right now!</span>"
		return

	if(!in_range(src, user))
		return

	var/new_color = input(usr, "Choose the wig's new color:", "Wig") as null|color
	if(new_color)

		if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			return

		var/hex = sanitize_hexcolor(new_color)
		color = "#[hex]"