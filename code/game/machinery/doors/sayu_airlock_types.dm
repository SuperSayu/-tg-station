/obj/machinery/door/airlock/centcom/allowed(mob/user)
	if(unlock_centcom || (ismob(user) && user.client && user.client.holder)) return 1
	return ..(user)

/obj/machinery/door/airlock/uranium/proc/artifact_radiate()
	for(var/obj/item/artifact/A in range(2,src)) // This is terrible
		if(!A.raddelay)
			A.raddelay = 1
			if(!A.checkfail(2))
				A.activate()
			spawn(50)
				A.raddelay = 0