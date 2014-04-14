// Basically they are for the firing range
/obj/structure/stool/bed/chair/target_stake // it's a bed now shut up
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_stake"
	flags = CONDUCT
	anchored = 0
	var/obj/item/target/pinned_target // the current pinned target

	Move()
		..()
		// Move the pinned target along with the stake
		if(pinned_target in view(3, src))
			pinned_target.loc = loc

		else // Sanity check: if the pinned target can't be found in immediate view
			pinned_target = null

		if(buckled_mob) // moves the unlucky person around. wheeeeeee!
			buckled_mob.loc = loc

	attackby(obj/item/W as obj, mob/user as mob)
		// Putting objects on the stake. Most importantly, targets
		if(pinned_target)
			return // get rid of that pinned target first!

		if(istype(W, /obj/item/target))
			density = 0
			W.density = 1
			user.drop_item()
			W.loc = loc
			W.layer = 3.1
			pinned_target = W
			user << "You slide the target into the stake."
		return

	attack_hand(mob/user as mob)
		// taking pinned targets off!
		if(pinned_target)
			density = 1
			pinned_target.density = 0
			pinned_target.layer = OBJ_LAYER

			pinned_target.loc = user.loc
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(pinned_target)
					user << "You take the target out of the stake."
			else
				pinned_target.loc = get_turf(user)
				user << "You take the target out of the stake."

			pinned_target = null
		..()

/obj/structure/stool/bed/chair/target_stake/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(!istype(M)) return
	buckle_mob(M, user)
	buckled_mob.dir = 2
	return

/obj/structure/stool/bed/chair/target_stake/rotate()
	return