/*
	Spellbooks

	You may know max_spells spells at once (unless granted with adminpowers).
	If you have this many already, you can forget an existing spell to learn a new one.  However it will not go back to the spellbook.

	Each spellbook has a number of spells you can only learn once.  When the spellbook has nothing more to give, it goes away.

	Specials are one-time effects as well, but you may only select so many specials out of any given spellbook, rather than being able to take your fill.
*/
/var/const/max_spells = 3 // total spells a mob may learn under the new system
/var/list/spells = typesof(/obj/effect/knowspell) // for badmin verb


/*
	Master spellbook for copying spells from
*/

/obj/structure/wizard/spellbook
	name = "wizard's spellbook"
	desc = "A spellbook on a pedestal."

	// temporary icon
	icon = 'icons/obj/cult.dmi'
	icon_state = "tomealtar"
	density = 1
	throwpass = 1
	anchored = 1

	var/decay = 0

	var/charges = 0 // maximum number of specials that can be taken from this pedestal
	var/list/spawn_spells = list()

	New()
		..()
		for(var/typekey in spawn_spells)
			if(ispath(typekey)) new typekey(src)

		while(decay > 0 && (charges || contents.len))
			if(charges && prob(50))
				charges--
				decay--
				continue

			var/obj/effect/knowspell/KS = pick(contents)
			if(KS)
				del KS
				decay--
				continue


	attack_hand(mob/user)
		if(!contents.len && charges <= 0)
			user << browse(null, "window=master_spell")
			del src
		var/html = "<i>You know [user.spell_list.len]/[max_spells] spells.</i><hr>"
		for(var/obj/effect/knowspell/ks in src)
			html += ks.describe(allow_cast = 0, remove_from = src)

		if(charges)
			html += list_specials()

		user << browse(html, "window=master_spell; size=700x500")
	interact()
		attack_hand(usr)

	proc/list_specials()
		return

	Topic(href,href_list)
		if(!Adjacent(usr)) return
		if("remove" in href_list)
			var/obj/effect/knowspell/KS = locate(href_list["remove"])
			if(!KS || !(KS in src))
				attack_hand(usr)
				return
			new /obj/item/weapon/magic/scroll(loc,KS)
			attack_hand(usr)


/obj/structure/wizard/spellbook/specials
	name = "ragged spellbook"
	desc = "This spellbook is falling apart; you may not be able to take everything."
	charges = 2
	list_specials()
		var/dat = "[charges] pages left:<br>"
		dat += "<a href='?\ref[src];armor'>Spell of Conjure Wizard Armor</a><br>"
		dat += "<a href='?\ref[src];change'>Spell of Change</a> (as Staff of Change)<br>"
		dat += "<a href='?\ref[src];animate'>Spell of Animation</a><br>"
		dat += "<a href='?\ref[src];disintegrate'>Spell of Disintegrate</a><br>"
		dat += "<a href='?\ref[src];stone'>Spell of Flesh to Stone</a><br>"
		dat += "<a href='?\ref[src];soulstone'>Spell of Artificer</a> ( Comes with a belt of soul stones )<br>"
		dat += "<a href='?\ref[src];guns'>Spell of Summon Guns</a> ( Global spell - Affects all players )<br>"
		dat += "<a href='?\ref[src];heal'>Spell of Healing</a><br>"
		return dat

	Topic(href,list/href_list)
		if(charges<=0) return
		var/obj/effect/knowspell/KS = null
		if("armor" in href_list)
			KS = new /obj/effect/knowspell/summon/here/wizard_armor(src)
		if("change" in href_list)
			KS = new /obj/effect/knowspell/projectile/throw/change(src)
		if("animate" in href_list)
			KS = new /obj/effect/knowspell/projectile/throw/animate(src)
		if("disintegrate" in href_list)
			KS = new /obj/effect/knowspell/target/disintegrate(src)
		if("stone" in href_list)
			KS = new /obj/effect/knowspell/target/flesh_to_stone(src)
		if("soulstone" in href_list)
			KS = new /obj/effect/knowspell/summon/here/artificer(src)
			new /obj/item/weapon/storage/belt/soulstone/full(get_turf(src))
		if("guns" in href_list)
			KS = new /obj/effect/knowspell/summon/world/guns(src)
		if("heal" in href_list)
			KS = new /obj/effect/knowspell/target/resurrect/heal(src)

		if(KS)
			new /obj/item/weapon/magic/scroll(loc,KS)
			charges--
		attack_hand(usr)


/obj/structure/wizard/spellbook/travel
	name = "book of Travel"
	spawn_spells = list(
		/obj/effect/knowspell/summon/here/portal,
		/obj/effect/knowspell/self/teleport,
		/obj/effect/knowspell/self/blink,
		/obj/effect/knowspell/self/jaunt,
		/obj/effect/knowspell/self/shadowstep,
		/obj/effect/knowspell/area/knock
		)

/obj/structure/wizard/spellbook/conjurations
	name = "book of Conjuration"
	desc = "Full of summoning spells of various types."
	spawn_spells = list(
		/obj/effect/knowspell/summon/target/light,
		/obj/effect/knowspell/summon/target/fire,
		/obj/effect/knowspell/summon/target/forcewall,
		/obj/effect/knowspell/summon/target/smoke,
		/obj/effect/knowspell/summon/target/banana,
		/obj/effect/knowspell/summon/nearby/carp
		)


/obj/structure/wizard/spellbook/insanity
	name = "book of Madness"
	desc = "This book is well worn; it seems to have been read by many people."
	spawn_spells = list(
		/obj/effect/knowspell/summon/world/bananas,
		/obj/effect/knowspell/summon/nearby/creature,
		/obj/effect/knowspell/target/horsemask,
		/obj/effect/knowspell/target/mutate/bad
	)
/obj/structure/wizard/spellbook/combat
	name = "book of War"
	desc = "Crush your enemies, see them driven before you, and hear the lamentations of their women."
	spawn_spells = list(
		/obj/effect/knowspell/projectile/throw/fireball,
		/obj/effect/knowspell/projectile/throw/knives,
		/obj/effect/knowspell/projectile/throw/frost,
		/obj/effect/knowspell/projectile/scatter/knives,
		/obj/effect/knowspell/target/mutate/good
	)
/obj/structure/wizard/spellbook/subterfuge
	name = "book of Peace"
	desc = "You are a little surprised this gets read at all."
	spawn_spells = list(
		/obj/effect/knowspell/target/resurrect,
		/obj/effect/knowspell/area/blind,
		/obj/effect/knowspell/area/emp,
		/obj/effect/knowspell/self/ghostize,
		/obj/effect/knowspell/projectile/scatter/magicmissile,
		/obj/effect/knowspell/projectile/scatter/forcearrow,
		/obj/effect/knowspell/summon/world/puppies,
		/obj/effect/knowspell/target/mindswap
	)
/obj/structure/wizard/spellbook/honk
	name = "book of Tricks"
	desc = "hehehe... HAHAHAHAHAHAHAHAHA"
	spawn_spells = list(
		/obj/effect/knowspell/summon/target/banana,
		/obj/effect/knowspell/summon/world/bananas,
		/obj/effect/knowspell/target/mutate/bad,
		/obj/effect/knowspell/area/blind,
		/obj/effect/knowspell/area/knock,
		/obj/effect/knowspell/projectile/throw/sweep
	)