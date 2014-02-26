//
// Todo: Higher level enchantables that you have to get with a crafting spell and exotic materials
//


/obj/item/weapon/magic
	var/obj/effect/knowspell/spell = null
	var/spawn_spelltype = null

	var/enchanted_state = null // icon state when spell is present
	var/dormant_state = null
	var/noun = null // for renaming: [noun] of [spell]
	var/castingmode = 0 // during enchantment, only allow magic
	var/magic_name = null // the renaming pylon should take priority here
	slot_flags = SLOT_BELT

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
	afterattack(target,mob/user, proximity)
		if(!spell) return
		if(proximity)
			if(target in user.contents)
				return // should prevent you from casting on your backpack if the item cannot fit, among other undesirable effects
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
		if(magic_name)
			name = magic_name // renaming pylon
	// creates a descriptive string for round-end accounting
	proc/describe()
		if(!spell) return null
		if(magic_name)
			return "\icon[src] [magic_name] ([noun] of [spell.name])"
		else
			return "\icon[src] [noun] of [spell.name]"

/obj/item/weapon/magic/spell_thrower
	name = "spell thrower"
	icon = 'icons/obj/magic.dmi'
	icon_state = "3"
	flags = USEDELAY
	w_class = 10.0
	layer = 20
	castingmode = CAST_RANGED
	slot_flags = 0

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
	describe()
		return null

/obj/item/weapon/magic/scroll
	name = "magic scroll"
	desc = "For reading spells off of."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "blank"
	w_class = 1

	noun = "scroll"
	enchanted_state = "scroll"
	dormant_state = "blank"
	var/rolled = 0
	var/rolled_name = "scroll of paper"

	New()
		..()
		if(rolled) roll_scroll() // just in case

	castingmode = CAST_SPELL
	attack_self(mob/user)
		if(rolled)
			rolled = 0
			pixel_x = rand(-2,2)
			pixel_y = rand(-1,1)
			verbs |= /obj/item/weapon/magic/scroll/verb/roll_scroll
			update_icon()
			return
		if(spell)
			user << browse(spell.describe(),"window=scroll")
	update_icon()
		if(rolled)
			name = rolled_name // overwritten by naming pylon
			desc = "Who rolls up paper nowadays?"
			if(spell)
				icon_state = "scroll_sealed"
			else
				icon_state = "scroll_rolled"
			return
		else
			desc = initial(desc)
			..()
	examine()
		if(spell && rolled) // prevent the glyph from being read until it is opened
			var/o = spell.incant_volume
			spell.incant_volume = 0
			..()
			spell.incant_volume = o
		else
			..()
	describe()
		if(!spell) return null
		if(rolled_name)
			var/or = rolled
			rolled = 1
			update_icon()
			. = "\icon[src] [rolled_name]: "
			rolled = 0
			update_icon()
			. += ..() // funname (scroll of wabberjack)
			rolled = or
			update_icon()
			return .
		if(rolled)
			. = "\icon[src] [name]: "
			rolled = 0
			update_icon()
			. += ..()
			rolled = 1
			update_icon()
			return .
		return ..()



	verb/roll_scroll()
		set category="Object"
		set name="Roll Scroll"
		set desc="Rolls up a magic scroll to hide its identity."
		rolled = 1
		pixel_x = rand(-5,5)
		pixel_y = rand(-10,10)
		update_icon()
		verbs -= /obj/item/weapon/magic/scroll/verb/roll_scroll

/obj/item/weapon/magic/orb
	name = "crystal orb"
	desc = "Made of a special magical crystal"
	noun = "orb"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "orb"
	w_class = 2
	castingmode = CAST_SELF
	slot_flags = 0

/obj/item/weapon/magic/staff
	name = "magic staff"
	desc = "For casting spells at a distant target."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	noun = "staff"
	force = 3
	w_class = 4
	castingmode = CAST_RANGED
	slot_flags = SLOT_BACK

	update_icon()
		if(spell && spell.staff_state)
			enchanted_state = "[noun]_[spell.staff_state]"
			dormant_state = "[noun]"
		else
			enchanted_state = null
			dormant_state = null

		..()

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
	slot_flags = SLOT_BACK | SLOT_BELT

/obj/item/weapon/magic/wand
	name = "magician's enchantable wand"
	desc = "Not to be confused with a magician's OTHER wand."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "nothingwand"
	noun = "wand"
	force = 0
	w_class = 2
	castingmode = CAST_RANGED|CAST_MELEE
	slot_flags = SLOT_BELT|SLOT_POCKET

	update_icon()
		if(spell && spell.wand_state)
			enchanted_state = spell.wand_state
			dormant_state = "[enchanted_state]-drained"
		else
			enchanted_state = null
			dormant_state = null

		..()

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
	var/maxscrolls = 5
	var/list/spawn_spells = list()

	New()
		for(var/typekey in spawn_spells)
			if(ispath(typekey)) new typekey(src)
		..()
	examine()
		..()
		usr << "Contains [contents.len]/[maxscrolls] scrolls."

	update_icon()
		if(magic_name) name = magic_name
		return

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
	describe()
		if(!contents.len)
			return null
		if(magic_name)
			. = "\icon[src] [magic_name] (spellbook):<br>"
		for(var/obj/effect/knowspell/KS in src)
			. += "\t * [KS]<br>"
		return

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
	slot_flags = SLOT_GLOVES|SLOT_POCKET|SLOT_BELT
	var/obj/effect/knowspell/spell = null
	var/noun = "gloves"
	var/castingmode = CAST_MELEE|CAST_RANGED
	action_button_name = "Toggle Casting"
	var/casting = 1
	var/spawn_spelltype = null
	var/magic_name = null

	New()
		if(ispath(spawn_spelltype,/obj/effect/knowspell))
			spell = new spawn_spelltype(src)
			update_icon()
		..()

	ui_action_click()
		casting = !casting
		usr << "[src] is [casting?"now":"no longer"] casting on everything you touch or gesture at."

	Touch(var/atom/A, var/proximity)
		if(!casting || !spell || !ismob(loc)) return
		var/mob/user = loc
		if(proximity)
			if(spell.castingmode & CAST_MELEE)
				if(spell.cast_check(user))
					spell.attack(A,user)
					return 1
				return 0

		else
			if(spell.castingmode & CAST_RANGED)
				if(spell.cast_check(user))
					spell.afterattack(A,user)
					return 1
				return 0
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
		if(magic_name)
			name = magic_name
		else if(spell)
			name = "[noun] of [spell.name]"
		else
			name = initial(name)
	proc/describe()
		if(!spell) return null
		if(magic_name)
			return "\icon[src] [magic_name] ([noun] of [spell.name])"
		else
			return "\icon[src] [noun] of [spell.name]"

/obj/item/weapon/storage/belt/bluespace/wizard
	name = "wizard's belt of holding"
	desc = "Comfortable, adequate support, and it fits just right... this is TRUE magic."
	reliability = 100
	max_combined_w_class = 16 // not as good as technology