/*
CONTAINS:
RSF

*/
/obj/item/weapon/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/matter_max = 20
	var/mode = 1
	flags = TABLEPASS
	w_class = 3.0

	var/list/mode_names = list("Dosh","Drinking glass", "Paper","Pen","Dice Pack", "Cigarette")
	var/list/mode_paths = list(/obj/item/weapon/spacecash/c10, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass,/obj/item/weapon/paper,
							/obj/item/weapon/pen, /obj/item/weapon/storage/pill_bottle/dice, /obj/item/clothing/mask/cigarette)
	var/list/energy_cost = list(200,50,10,50,200,10)
	var/list/matter_cost = list(1,1,1,1,1,1)

/obj/item/weapon/rsf/New()
	matter = matter_max
	return

/obj/item/weapon/rsf/examine()
	..()
	usr << "It currently holds [matter]/[matter_max] fabrication-units."

/obj/item/weapon/rsf/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/rcd_ammo))
		if ((matter + 10) > 30)
			user << "The RSF cant hold any more matter."
			return
		del(W)
		matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		user << "The RSF now holds [matter]/[matter_max] fabrication-units."
		return

/obj/item/weapon/rsf/attack_self(mob/user as mob)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	mode++
	if(mode > mode_names.len)
		mode = 1
	user << "\blue Changing dispensing mode to '[mode_names[mode]]'."

/obj/item/weapon/rsf/afterattack(atom/A, mob/user as mob)
	if (!(istype(A, /obj/structure/table) || istype(A, /turf/simulated/floor)))
		return
	if(matter <= 0)
		return

	user << "Dispensing [mode_names[mode]]..."
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)

	var/typepath = mode_paths[mode]
	new typepath(get_turf(A))

	if(isrobot(user))
		var/mob/living/silicon/robot/engy = user
		engy.cell.use(energy_cost[mode])
	else
		matter -= matter_cost[mode]
		user << "[src] now holds [matter]/[matter_max] fabrication-units."
