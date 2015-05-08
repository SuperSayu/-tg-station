/obj/item/weapon/grown/bananapeel/wizard
	name = "magical banana peel"
	desc = "Far superior to the genetically enhanced version"
	var/walk_delay = 2
	potency = 10

/obj/item/weapon/grown/bananapeel/wizard/New()
	..()
	walk_delay = rand(0,5)
	walk_rand(src,walk_delay)
	spawn(rand(3,6)*100)
		if(src)
			qdel(src)

/obj/item/weapon/grown/bananapeel/specialpeel/wizard/Crossed(AM)
	if(..())
		var/turf/T = get_turf(src.loc)
		T.visible_message("<span class='notice'>The [name] disintegrates with a \i [magic_soundfx()]</span>")
		qdel(src)