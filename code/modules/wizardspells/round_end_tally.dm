/var/list/artifacts_used = list()

/area/wizard_station/Exited(atom/movable/AM)
	var/list/total_contents = AM.GetAllContents() + AM
	if(!locate(/obj/effect/knowspell) in total_contents)
		return
	for(var/obj/item/weapon/magic/M in total_contents) // carried or in bags
		artifacts_used[M.describe()] = M
	for(var/obj/item/clothing/gloves/magic/M in total_contents)
		artifacts_used[M.describe()] = M
	for(var/obj/item/clothing/gloves/white/tkglove/T in total_contents)
		if(T.magic_name)
			artifacts_used["\icon[T] [T.magic_name] (astral gloves)"] = T
		else
			artifacts_used["\icon[T] [T.name]"] = T
	artifacts_used -= null // M.describe() will return null if the item has no spell in it
	..()