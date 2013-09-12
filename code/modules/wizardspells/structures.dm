/obj/structure/wizard/forge
	name = "wizard's forge"
	desc = "Enchants or disenchants"
	icon = 'icons/obj/cult.dmi'
	icon_state = "forge"
	density = 1
	throwpass = 1
	anchored = 1

	var/obj/item/weapon/magic/blank = null

	attackby(obj/item/I,mob/user)
		if(!istype(I,/obj/item/weapon/magic)) return
		if(istype(I,/obj/item/weapon/magic/spell_thrower)) return
		if(istype(I,/obj/item/weapon/magic/spellbook)) return

		if(istype(I,/obj/item/weapon/magic/scroll))
			if(!blank)
				user << "You need to put something in first."
				return
			var/obj/item/weapon/magic/scroll/S = I
			if(!S.spell)
				user << "[S] is blank!  You can't enchant anything with it."
				return
			if(!(blank.castingmode & S.spell.castingmode) || (blank.w_class < S.spell.complexity))
				user << "[blank] cannot be enchanted with [S.spell]."
				return
			user << "You enchant [blank] with [S.spell]."

			blank.spell = S.spell
			S.spell.loc = blank
			blank.update_icon()
			user.drop_item()
			del S

			blank.loc = loc
			blank = null
			return

		if(blank)
			user << "There is already \a [blank] in [src]."
			return
		var/obj/item/weapon/magic/M = I
		if(M.spell)
			if(alert(user,"Putting [M] in [src] will break the enchantment.  Are you sure?","Disenchant","Disenchant","Cancel") == "Cancel")
				return
			new /obj/item/weapon/magic/scroll(loc,M.spell)
			M.dispell(0)
			return
		blank = M
		user.drop_item()
		M.loc = src

	attack_hand(mob/user)
		if(blank)
			user << "You remove [blank] from [src]."
			blank.loc = loc
			blank = null

/obj/structure/wizard/namingpylon
	name = "renaming pylon"
	icon = 'icons/obj/cult.dmi'
	icon_state = "pylon"
	desc = "Gives noble status to even the most common items."

	attackby(obj/item/I,mob/user)
		var/newname = input(user,"Give [I] a new name:","Rename item",null) as text|null
		if(!newname || newname == "" || !Adjacent(user) || length(newname) > 24) return
		I.name = newname
		user << "You give [I] a new name."
