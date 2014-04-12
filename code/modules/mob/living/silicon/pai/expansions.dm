/obj/item/device/paicard/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/device/camera_bug))
		if(!pai)
			user << "There is no pAI in [src]."
			return
		if("camera jack" in pai.software)
			user << "[src] has already activated its camera bug software, and would get no benefit from connecting the external device."
			return
		pai.software += "camera jack"
		user << "You connect [I] to [pai], allowing it to supplement its internal software with [I]'s internal ROM."
		pai << "[user] connects you to \a [I], supplementing your internal software."
		user.drop_item()
		del I
		return
	..()