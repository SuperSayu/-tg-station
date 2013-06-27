/obj/effect/spawner/lootdrop
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	var/lootcount = 1		//how many items will be spawned
	var/lootdoubles = 0		//if the same item can be spawned twice
	var/list/loot			//a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)

/obj/effect/spawner/lootdrop/initialize()
	if(!istype(loot))
		var/list/temp = params2list(loot)
		loot = list()
		for(var/entry in temp)
			loot += text2path(entry)
	if(istype(loot) && loot.len && lootcount >= 1)
		for(lootcount--)
			if(!loot.len) return
			var/lootspawn = pick(loot)
			if(!lootdoubles)
				loot.Remove(lootspawn)
			if(ispath(lootspawn))
				new lootspawn(get_turf(src))
	del(src)