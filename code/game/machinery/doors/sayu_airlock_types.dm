/obj/machinery/door/airlock/centcom/allowed(mob/user)
	if(unlock_centcom || (ismob(user) && user.client && user.client.holder)) return 1
	return ..(user)