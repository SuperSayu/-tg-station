/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'


/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	var/beating = 1

/obj/item/organ/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"


/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	var/inflamed = 1

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
	else
		icon_state = "appendix"

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	var/turbo = 0

/obj/item/organ/liver/update_icon()
	if(turbo)
		icon_state = "turboliver"
	else
		icon_state = "liver"


//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm