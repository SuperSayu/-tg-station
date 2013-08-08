//
// Originally, and maybe again someday, I was planning on actual enchanted magic items.  You can see how this helps along that path.
// In the meantime there's no reason to tear it all down quite yet.  -Sayu
//

/obj/item/weapon/magic
	var/obj/effect/knowspell/spell = null
	var/spawn_spelltype = null
	New(L,newspell)
		..()
		if(istype(newspell,/obj/effect/knowspell))
			spell = newspell
			spell.loc = src
		else if(ispath(spawn_spelltype,/obj/effect/knowspell))
			spell = new spawn_spelltype(src)
		if(spell)
			name = spell.name
			desc = spell.desc

	attack(M,user,def_zone)
		if(spell)
			spell.attack(M,user,def_zone)
		else
			..()
	attack_self(user)
		if(spell)
			spell.attack_self(user)
	afterattack(target,user)
		if(spell)
			spell.afterattack(target,user)

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/nullrod))
			if(spell)
				user << "You banish the foul magics from [src]!"
				dispell(1)
				return
		..(W,user)

	Stat()
		if(src.spell)
			if(src.spell.rechargable)
				statpanel("Spells","[src.spell.charge/10.0]/[src.spell.chargemax/10]",src.spell)
			else
				statpanel("Spells","[src.spell.charge] left",src.spell)

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

/obj/item/weapon/magic/spell_thrower
	name = "spell thrower"
	icon = 'icons/obj/magic.dmi'
	icon_state = "3"
	flags = USEDELAY
	w_class = 10.0
	layer = 20

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
		return // you already know this spell or you can't have the item

