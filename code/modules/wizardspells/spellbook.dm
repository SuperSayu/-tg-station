/*
	Spellbooks

	You may know max_spells spells at once (unless granted with adminpowers).
	If you have this many already, you can forget an existing spell to learn a new one.  However it will not go back to the spellbook.

	Each spellbook has a number of spells you can only learn once.  When the spellbook has nothing more to give, it goes away.

	Specials are one-time effects as well, but you may only select so many specials out of any given spellbook, rather than being able to take your fill.

	By default you can conjure three spellbooks from the main book.  Whatever you get out of those spellbooks is all you've got.
*/
/var/const/max_spells = 5 // total spells a mob may learn under the new system
/var/list/spells = typesof(/obj/effect/knowspell) // for badmin verb


/obj/item/weapon/magic/spellbook
	name = "wizard's spellbook"
	desc = "Magically delicious."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	w_class = 2.0
	flags = FPRINT | TABLEPASS

	var/list/spawn_spells = list()
	var/specials_left = 0

	New()
		..()
		for(var/typekey in spawn_spells)
			if(ispath(typekey)) new typekey(src)

	attack_self(mob/user as mob)
		if(!contents.len && !specials_left)
			usr << "[src] crumbles to dust."
			usr << browse(null,"window=spellbook")
			del src
			return
		user << browse(list_spells(usr),"window=spellbook")
	interact()
		if(!contents.len && !specials_left)
			usr << "[src] crumbles to dust."
			usr << browse(null,"window=spellbook")
			del src
			return
		usr << browse(list_spells(usr),"window=spellbook")

	proc/list_spells(mob/user as mob)
		var/dat = "<center><h3>[name]</h3><i>You know [user.spell_list.len]/[max_spells] spells</i></center>"
		for(var/obj/effect/knowspell/KS in src)
			dat += KS.describe(allow_cast = 0)
		if(specials_left)
			dat += list_specials()
		return dat

	proc/list_specials()
		return

/obj/item/weapon/magic/spellbook/basic
	specials_left = 3
	list_specials()
		var/dat = "You may select up to [specials_left]:<br>"
		dat += "<a href='?\ref[src];travel'>Conjure Book of Travel</a><br>"
		dat += "<a href='?\ref[src];summon'>Conjure Book of Conjuration</a><br>"
		dat += "<a href='?\ref[src];insanity'>Conjure Book of Madness</a><br>"
		dat += "<a href='?\ref[src];combat'>Conjure Book of War</a><br>"
		dat += "<a href='?\ref[src];subterfuge'>Conjure Book of Peace</a><br>"
		dat += "<a href='?\ref[src];honk'>Conjure Book of Tricks</a> (best gifted to a mutual enemy)<br>"
		dat += "<a href='?\ref[src];equip'>Conjure Equipment Handbook</a><br>"
		return dat

	Topic(href,list/href_list)
		if(!specials_left)
			return

		if("travel" in href_list)
			specials_left--
			usr.put_in_hands(new /obj/item/weapon/magic/spellbook/travel(get_turf(src)))
			return
		if("summon" in href_list)
			specials_left--
			usr.put_in_hands(new /obj/item/weapon/magic/spellbook/conjurations(get_turf(src)))
			return
		if("insanity" in href_list)
			specials_left--
			usr.put_in_hands(new /obj/item/weapon/magic/spellbook/insanity(get_turf(src)))
			return
		if("combat" in href_list)
			specials_left--
			usr.put_in_hands(new /obj/item/weapon/magic/spellbook/combat(get_turf(src)))
			return
		if("subterfuge" in href_list)
			specials_left--
			usr.put_in_hands(new /obj/item/weapon/magic/spellbook/subterfuge(get_turf(src)))
			return
		if("honk" in href_list)
			specials_left--
			usr.put_in_hands(new /obj/item/weapon/magic/spellbook/honk(get_turf(src)))
			return
		if("equip" in href_list)
			specials_left--
			usr.put_in_hands(new /obj/item/weapon/magic/spellbook/equip(get_turf(src)))
			return

/obj/item/weapon/magic/spellbook/equip
	name = "seer's catalogue" // with apologies to everyone except Dominic Deegan
	desc = "Guaranteed to have everything you need."
	specials_left = 2
	list_specials()
		var/dat = "You may select up to [specials_left]:<br>"
		dat += "<a href='?\ref[src];armor'>Spell of Conjure Wizard Armor</a><br>"
		dat += "<a href='?\ref[src];change'>Spell of Conjure Staff of Change</a><br>"
		dat += "<a href='?\ref[src];animate'>Spell of Conjure Staff of Animation</a><br>"
		dat += "<a href='?\ref[src];scry'>Spell of Conjure Orb of Scrying</a><br>"
		dat += "<a href='?\ref[src];soulstone'>Spell of Artificer</a> ( Comes with a belt of soul stones )<br>"
		dat += "<a href='?\ref[src];guns'>Spell of Summon Guns</a> ( Global spell - Affects all players )<br>"
		return dat

	// The difference from the normal version is that you can cast spells from this.
	// Note that the only case where a spell will sit in this book is if you are full of spells and choose not to forget any.
	// But you didn't waste the special in that case...
	list_spells(mob/user as mob)
		var/dat = "<center><h3>[name]</h3><i>You know [user.spell_list.len]/[max_spells] spells</i></center>"
		for(var/obj/effect/knowspell/KS in src)
			dat += KS.describe()
		if(specials_left)
			dat += list_specials()
		return dat

	Topic(href,list/href_list)
		if(!specials_left) return
		var/obj/effect/knowspell/KS = null
		if("armor" in href_list)
			KS = new /obj/effect/knowspell/summon/here/wizard_armor(src)
		if("change" in href_list)
			KS = new /obj/effect/knowspell/summon/here/staff_change(src)
		if("animate" in href_list)
			KS = new /obj/effect/knowspell/summon/here/staff_animation(src)
		if("scry" in href_list)
			KS = new /obj/effect/knowspell/summon/here/orb_scrying(src)
		if("soulstone" in href_list)
			KS = new /obj/effect/knowspell/summon/here/artificer(src)
			new /obj/item/weapon/storage/belt/soulstone/full(get_turf(src))
		if("guns" in href_list)
			KS = new /obj/effect/knowspell/summon/world/guns(src)

		if(KS)
			KS.Topic("learn",list("learn"))
			specials_left--


/obj/item/weapon/magic/spellbook/travel
	name = "book of Travel"
	spawn_spells = list(
		/obj/effect/knowspell/summon/here/portal,
		/obj/effect/knowspell/self/teleport,
		/obj/effect/knowspell/self/blink,
		/obj/effect/knowspell/self/jaunt,
		/obj/effect/knowspell/area/knock
		)

/obj/item/weapon/magic/spellbook/conjurations
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


/obj/item/weapon/magic/spellbook/insanity
	name = "book of Madness"
	desc = "This book is well worn; it seems to have been read by many people."
	spawn_spells = list(
		/obj/effect/knowspell/summon/world/bananas,
		/obj/effect/knowspell/summon/nearby/creature,
		/obj/effect/knowspell/target/horsemask,
		/obj/effect/knowspell/target/mutate/bad
	)
/obj/item/weapon/magic/spellbook/combat
	name = "book of War"
	desc = "Crush your enemies, see them driven before you, and hear the lamentations of their women."
	spawn_spells = list(
		/obj/effect/knowspell/projectile/throw/fireball,
		/obj/effect/knowspell/projectile/throw/knives,
		/obj/effect/knowspell/projectile/scatter/knives,
		/obj/effect/knowspell/target/disintegrate,
		/obj/effect/knowspell/target/mutate/good
	)
/obj/item/weapon/magic/spellbook/subterfuge
	name = "book of Peace"
	desc = "You are a little surprised this gets read at all."
	spawn_spells = list(
		/obj/effect/knowspell/target/resurrect,
		/obj/effect/knowspell/area/blind,
		/obj/effect/knowspell/area/emp,
		/obj/effect/knowspell/projectile/scatter/magicmissile,
		/obj/effect/knowspell/projectile/scatter/forcearrow,
		/obj/effect/knowspell/summon/world/puppies,
		/obj/effect/knowspell/target/mindswap
	)
/obj/item/weapon/magic/spellbook/honk
	name = "book of Tricks"
	desc = "hehehe... HAHAHAHAHAHAHAHAHA"
	spawn_spells = list(
		/obj/effect/knowspell/summon/target/banana,
		/obj/effect/knowspell/summon/world/bananas,
		/obj/effect/knowspell/summon/world/puppies,
		/obj/effect/knowspell/target/mutate/bad,
		/obj/effect/knowspell/area/blind,
		/obj/effect/knowspell/area/knock
	)
