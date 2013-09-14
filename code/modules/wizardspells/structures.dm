/obj/structure/wizard/forge
	name = "wizard's forge"
	desc = "Enchants or disenchants"
	icon = 'icons/obj/cult.dmi'
	icon_state = "forge"
	density = 1
	throwpass = 1
	anchored = 1

	var/obj/item/weapon/magic/blank = null
	var/obj/item/clothing/gloves/magic/glove = null

	attackby(obj/item/I,mob/user)
		if(!istype(I,/obj/item/weapon/magic) && !istype(I,/obj/item/clothing/gloves/magic)) return
		if(istype(I,/obj/item/weapon/magic/spell_thrower)) return
		if(istype(I,/obj/item/weapon/magic/spellbook)) return

		if(istype(I,/obj/item/weapon/magic/scroll))
			if(!blank && !glove)
				user << "You need to put something in first."
				return
			var/obj/item/weapon/magic/scroll/S = I
			if(!S.spell)
				user << "[S] is blank!  You can't enchant anything with it."
				return
			if(blank)
				if(!(blank.castingmode & S.spell.castingmode) || (blank.w_class < S.spell.complexity))
					user << "[blank] cannot be enchanted with [S.spell]."
					return
				user << "You enchant [blank] with [S.spell]."

				blank.spell = S.spell
				S.spell.loc = blank
				blank.update_icon()
				blank.loc = loc
				blank = null
				user.drop_item()
				del S
			else
				if(!(glove.castingmode & S.spell.castingmode) || (glove.w_class < S.spell.complexity))
					user << "[glove] cannot be enchanted with [S.spell]."
					return
				user << "You enchant [glove] with [S.spell]."

				glove.spell = S.spell
				S.spell.loc = glove
				glove.update_icon()
				glove.loc = loc
				glove = null
				user.drop_item()
				del S
			return

		if(blank)
			user << "There is already \a [blank] in [src]."
			return
		if(glove)
			user << "There is already \a [glove] in [src]."
			return
		var/obj/item/weapon/magic/M = I
		if(istype(M))
			if(M.spell)
				if(alert(user,"Putting [M] in [src] will break the enchantment.  Are you sure?","Disenchant","Disenchant","Cancel") == "Cancel")
					return
				new /obj/item/weapon/magic/scroll(loc,M.spell)
				M.dispell(0)
				return
			blank = M
			user.drop_item()
			M.loc = src
		else
			var/obj/item/clothing/gloves/magic/PM = I
			if(!istype(PM)) return
			if(PM.spell)
				if(alert(user,"Putting [PM] in [src] will break the enchantment.  Are you sure?","Disenchant","Disenchant","Cancel") == "Cancel")
					return
				new /obj/item/weapon/magic/scroll(loc,PM.spell)
				PM.dispell(0)
				return
			blank = PM
			user.drop_item()
			PM.loc = src

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
	density = 1
	anchored = 1

	attackby(obj/item/I,mob/user)
		var/newname = input(user,"Give [I] a new name:","Rename item",null) as text|null
		if(!newname || length(newname) < 2 || !Adjacent(user) || length(newname) > 24) return
		I.name = newname
		user << "You give [I] a new name."
