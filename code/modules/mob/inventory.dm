//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting l_hand = ...etc
//as they handle all relevant stuff like adding it to the player's screen and updating their overlays.

//Returns the thing in our active hand
/mob/proc/get_active_hand()
	if(hand)	return l_hand
	else		return r_hand


//Returns the thing in our inactive hand
/mob/proc/get_inactive_hand()
	if(hand)	return r_hand
	else		return l_hand


//Returns if a certain item can be equipped to a certain slot.
// Currently invalid for two-handed items - call obj/item/mob_can_equip() instead.
/mob/proc/can_equip(obj/item/I, slot, disable_warning = 0)
	return 0

//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(obj/item/W)
	if(!put_in_hand_check(W))
		return 0
	if(!l_hand)
		W.loc = src		//TODO: move to equipped?
		l_hand = W
		W.layer = 20	//TODO: move to equipped?
//		l_hand.screen_loc = ui_lhand
		W.equipped(src,slot_l_hand)
		if(client)	client.screen |= W
		if(pulling == W) stop_pulling()
		update_inv_l_hand()
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
		return 1
	return 0


//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(obj/item/W)
	if(!put_in_hand_check(W))
		return 0
	if(!r_hand)
		W.loc = src
		r_hand = W
		W.layer = 20
		W.equipped(src,slot_r_hand)
		if(client)	client.screen |= W
		if(pulling == W) stop_pulling()
		update_inv_r_hand()
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
		return 1
	return 0

/mob/proc/put_in_hand_check(obj/item/W)
	if(lying && !(W.flags&ABSTRACT))	return 0
	if(!istype(W))	return 0
	return 1

//Puts the item into our active hand if possible. returns 1 on success.
/mob/proc/put_in_active_hand(obj/item/W)
	if(hand)	return put_in_l_hand(W)
	else		return put_in_r_hand(W)


//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/proc/put_in_inactive_hand(obj/item/W)
	if(hand)	return put_in_r_hand(W)
	else		return put_in_l_hand(W)


//Puts the item our active hand if possible. Failing that it tries our inactive hand. Returns 1 on success.
//If both fail it drops it on the floor and returns 0.
//This is probably the main one you need to know :)
/mob/proc/put_in_hands(obj/item/W)
	if(!W)		return 0
	if(put_in_active_hand(W))			return 1
	else if(put_in_inactive_hand(W))	return 1
	else
		W.loc = get_turf(src)
		W.layer = initial(W.layer)
		W.dropped(src)
		return 0


/mob/proc/drop_item_v()		//this is dumb.
	if(stat == CONSCIOUS && isturf(loc))
		return drop_item()
	return 0


//Drops the item in our left hand
/mob/proc/drop_l_hand()
	if(!loc.allow_drop())
		return
	return unEquip(l_hand) //All needed checks are in unEquip


//Drops the item in our right hand
/mob/proc/drop_r_hand()
	if(!loc.allow_drop())
		return
	return unEquip(r_hand)


//Drops the item in our active hand.
/mob/proc/drop_item()
	if(hand)	return drop_l_hand()
	else		return drop_r_hand()


//Here lie drop_from_inventory and before_item_take, already forgotten and not missed.


/mob/proc/canUnEquip(obj/item/I, force)
	if(!I)
		return 1
	if((I.flags & NODROP) && !force)
		return 0
	return 1

/mob/proc/unEquip(obj/item/I, force) //Force overrides NODROP for things like wizarditis and admin undress.
	if(!I) //If there's nothing to drop, the drop is automatically succesfull. If(unEquip) should generally be used to check for NODROP.
		return 1

	if((I.flags & NODROP) && !force)
		return 0

	if(I == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if(I == l_hand)
		l_hand = null
		update_inv_l_hand()

	if(I)
		if(client)
			client.screen -= I
		I.loc = loc
		I.dropped(src)
		if(I)
			I.layer = initial(I.layer)
	return 1


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(var/obj/O)
	unEquip(O)
	O.screen_loc = null
	return 1


// I'mma be honest with you, I should probably remove null entries here.  However,
// in general, you are probably going to for(type in list) this, and that skips nulls.
/mob/proc/get_equipped_items()
	return list()
/mob/living/carbon/get_equipped_items()
	return list(back, wear_mask)
/mob/living/carbon/human/get_equipped_items()
	return list(back, wear_mask, wear_suit, w_uniform, shoes, belt, gloves, glasses, head, ears, wear_id)

