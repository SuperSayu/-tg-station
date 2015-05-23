/obj/structure/target_stake
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_stake"
	flags = CONDUCT
	anchored = 0
	can_buckle = 1
	buckle_lying = 0
	var/obj/item/target/pinned_target

/obj/structure/target_stake/Destroy()
	if(pinned_target)
		pinned_target.nullPinnedLoc()
	..()

/obj/structure/target_stake/proc/nullPinnedTarget()
	pinned_target = null

/obj/structure/target_stake/Move()
	..()
	if(pinned_target)
		pinned_target.loc = loc

	if(buckled_mob) // moves the unlucky person around. wheeeeeee!
		buckled_mob.loc = loc

/obj/structure/target_stake/attackby(obj/item/target/T, mob/user)
	if(pinned_target)
		return
	if(istype(T))
		pinned_target = T
		T.pinnedLoc = src
		T.density = 1
		user.drop_item()
		T.layer = OBJ_LAYER + 0.1
		T.loc = loc
		user << "<span class='notice'>You slide the target into the stake.</span>"

/obj/structure/target_stake/attack_hand(mob/user)
	if(pinned_target)
		removeTarget(user)
	unbuckle_mob()

/obj/structure/target_stake/proc/removeTarget(mob/user)
	pinned_target.layer = OBJ_LAYER
	pinned_target.loc = user.loc
	pinned_target.nullPinnedLoc()
	nullPinnedTarget()
	if(ishuman(user))
		if(!user.get_active_hand())
			user.put_in_hands(pinned_target)
			user << "<span class='notice'>You take the target out of the stake.</span>"
	else
		pinned_target.loc = get_turf(user)
		user << "<span class='notice'>You take the target out of the stake.</span>"

/obj/structure/target_stake/post_buckle_mob(mob/M)
	if(M == buckled_mob && buckled_mob)
		buckled_mob.dir = 2
	return

/obj/structure/target_stake/bullet_act(obj/item/projectile/P)
	if(pinned_target)
		pinned_target.bullet_act(P)
	else
		..()
