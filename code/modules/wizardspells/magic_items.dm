//
// Todo: Higher level enchantables that you have to get with a crafting spell and exotic materials
//


/obj/item/weapon/magic
	var/obj/effect/knowspell/spell = null
	var/spawn_spelltype = null

	var/enchanted_state = null // icon state when spell is present
	var/dormant_state = null
	var/noun = null // for renaming: [noun] of [spell]
	var/castingmode = 0 // during enchantment, only allow magic that

	New(L,newspell)
		..()
		if(istype(newspell,/obj/effect/knowspell))
			spell = newspell
			spell.loc = src
		else if(ispath(spawn_spelltype,/obj/effect/knowspell))
			spell = new spawn_spelltype(src)
		update_icon()

	attack_self(user)
		if(spell && (castingmode & CAST_SELF))
			spell.prepare(user)
	afterattack(target,user, proximity)
		if(!spell) return
		if(proximity)
			if(castingmode & spell.castingmode & CAST_MELEE)
				spell.attack(target,user)
		else
			if(castingmode & spell.castingmode & CAST_RANGED)
				spell.afterattack(target,user)

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/nullrod))
			if(spell)
				user << "You banish the foul magics from [src]!"
				dispell(1)
				return
		..(W,user)

	Stat(var/category)
		if(spell)
			statpanel("Spells",category)
			var/link = spell
			if(!(spell.castingmode&CAST_SPELL)) link = spell.name
			if(spell.rechargable)
				statpanel("Spells","[spell.charge/10.0]/[spell.chargemax/10]",link)
			else
				statpanel("Spells","[spell.charge] left",link)

	proc/dispell(var/violent = 0)
		if(spell)
			if(violent)
				del spell
			else
				spell = null
			update_icon()

	examine()
		..()
		if(spell)
			if(spell.incantation && spell.incant_volume)
				usr << "An arcane phrase is engraved in a ring of glowing letters: '[spell.incantation]'"
			else
				usr << "An arcane glyph is engraved on it."
	update_icon()
		if(spell)
			if(noun)
				name = "[noun] of [spell.name]"
			if(enchanted_state)
				icon_state = enchanted_state
		else
			name = initial(name)
			if(dormant_state)
				icon_state = dormant_state

/obj/item/weapon/magic/spell_thrower
	name = "spell thrower"
	icon = 'icons/obj/magic.dmi'
	icon_state = "3"
	flags = USEDELAY
	w_class = 10.0
	layer = 20
	castingmode = CAST_RANGED

	var/last_throw = 0

	New(var/mob/living/caster, var/obj/effect/knowspell/newmaster)
		ASSERT(newmaster)
		loc = caster // redundant, first variable is always location anyway
		spell = newmaster
		name = spell.name
		desc = spell.desc

	dropped(mob/user as mob)
		del(src)
		return

	equipped(var/mob/user, var/slot)
		if( (slot == slot_l_hand) || (slot== slot_r_hand) )	return
		del(src)
		return

	attackby()
		return 1

	examine()
		spell.examine()

	Stat()
		return // you already know this spell

/obj/item/weapon/magic/scroll
	name = "magic scroll"
	desc = "For reading spells off of."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "blank"
	w_class = 1

	noun = "scroll"
	enchanted_state = "scroll"
	dormant_state = "blank"

	castingmode = CAST_SPELL
	attack_self(mob/user)
		if(spell)
			user << browse(spell.describe(),"window=scroll")

/obj/item/weapon/magic/orb
	name = "crystal orb"
	desc = "Made of a special magical crystal"
	noun = "orb"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "orb"
	w_class = 2
	castingmode = CAST_SELF

/obj/item/weapon/magic/staff
	name = "magic staff"
	desc = "For casting spells at a distant target."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	noun = "staff"
	force = 3
	w_class = 4
	castingmode = CAST_RANGED

/obj/item/weapon/magic/staff/broom
	name = "bewitched broom"
	icon_state = "broom"
	noun = "broom"
	force = 0

/obj/item/weapon/magic/blade
	name = "sacrificial knife"
	desc = "A brutal melee weapon."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	noun = "blade"

	force = 5
	castingmode = CAST_MELEE

// doesn't get enchanted, instead gets filled with scrolls
// You cannot cast from a spellbook and you cannot remove scrolls
// You can only learn from it
/obj/item/weapon/magic/spellbook
	name = "wizard's spellbook"
	desc = "Magically delicious."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	w_class = 2.0
	flags = FPRINT
	var/const/maxscrolls = 4
	var/list/spawn_spells = list()

	New()
		for(var/typekey in spawn_spells)
			if(ispath(typekey)) new typekey(src)
		..()
	examine()
		..()
		usr << "Contains [contents.len]/[maxscrolls] scrolls."

	attack_self(mob/user as mob)
		usr = user
		interact()
	interact()
		if(!contents.len)
			usr << "[src] is blank."
			usr << browse(null,"window=spellbook")
			return
		usr << browse(list_spells(usr),"window=spellbook")

	proc/list_spells(mob/user as mob)
		var/dat = "<center><h3>[name]</h3><i>You know [user.spell_list.len]/[max_spells] spells</i></center>"
		for(var/obj/effect/knowspell/KS in src)
			dat += KS.describe(allow_cast = 0, remove_from = src)
		return dat

	attackby(obj/item/I, mob/user)
		if(istype(I,/obj/item/weapon/magic/scroll))
			if(contents.len > maxscrolls)
				user << "You cannot fit more scrolls into [src]."
				return
			var/obj/item/weapon/magic/scroll/M = I
			if(!M.spell)
				return
			user << "You insert [M] into [src]."
			M.spell.loc = src
			user.drop_item()
			del M
	Topic(href,list/href_list)
		if(!Adjacent(usr)) return
		if("remove" in href_list)
			var/obj/effect/knowspell/KS = locate(href_list["remove"])
			if(!KS || !(KS in src))
				attack_self(usr)
				return
			new /obj/item/weapon/magic/scroll(get_turf(loc),KS)
			attack_self(usr)

/obj/item/clothing/gloves/magic
	name = "enchantable gloves"
	desc = "Woven from hairs of a deceased creature of legend, and dyed the color it hated most."
	icon_state = "purple"
	item_state = "purplegloves"
	item_color="purple"
	var/obj/effect/knowspell/spell = null
	var/noun = "gloves"
	var/castingmode = CAST_MELEE|CAST_RANGED

	Touch(var/atom/A, var/proximity)
		var/mob/user = loc
		if(!spell || !spell.cast_check(user)) return 0
		if(proximity)
			if(spell.castingmode & CAST_MELEE)
				return spell.attack(A,user)

		else
			if(spell.castingmode & CAST_RANGED)
				spell.afterattack(A,user)
	Stat()
		if(spell)
			statpanel("Spells","Gloves")
			if(spell.rechargable)
				statpanel("Spells","[spell.charge/10.0]/[spell.chargemax/10]",spell.name)
			else
				statpanel("Spells","[spell.charge] left",spell.name)

	proc/dispell(var/violent = 0)
		if(spell)
			if(violent)
				del spell
			else
				spell = null
			update_icon()
	examine()
		..()
		if(spell)
			if(spell.incantation && spell.incant_volume)
				usr << "An arcane phrase is engraved in a ring of glowing letters: '[spell.incantation]'"
			else
				usr << "An arcane glyph is engraved on it."
	update_icon()
		if(spell)
			name = "[noun] of [spell.name]"
		else
			name = initial(name)

