/obj/machinery/door/airlock/centcom
	icon = 'icons/obj/doors/Doorele.dmi'
	opacity = 1
	doortype = 8
	req_access = list(access_cent_general)

	attackby(w,user) // no hacking centcom doors
		return ..(user,user) // door attack_hand defaults to this

	allowed(mob/user)
		if(unlock_centcom || (ismob(user) && user.client && user.client.holder)) return 1
		return ..(user)