/*
	Magic items will rename themselves based on the formula:
	[item noun] of [spell name]
	unless the "magic name" variable is set; in which case,
	it will always be named that.

	Scrolls have a rolled_name which can be set for when it
	is rolled up.
*/
/obj/item/weapon/magic/orb/scrying
	spawn_spelltype = /obj/effect/knowspell/self/ghostize

/obj/item/weapon/magic/orb/portal
	spawn_spelltype = /obj/effect/knowspell/summon/here/portal


/obj/item/weapon/magic/wand/boost
	magic_name = "wand of enhancement"
	spawn_spelltype = /obj/effect/knowspell/target/mutate/good

/obj/item/weapon/magic/wand/prank
	magic_name = "wand of tricks"
	spawn_spelltype = /obj/effect/knowspell/target/prank

/obj/item/weapon/magic/wand/frost
	spawn_spelltype = /obj/effect/knowspell/projectile/throw/frost

/obj/item/weapon/magic/wand/light
	spawn_spelltype = /obj/effect/knowspell/summon/target/light

/obj/item/weapon/magic/wand/fire
	spawn_spelltype = /obj/effect/knowspell/summon/target/fire

/obj/item/weapon/magic/staff/force
	spawn_spelltype = /obj/effect/knowspell/summon/target/forcewall

/obj/item/weapon/magic/staff/broom/sweep
	spawn_spelltype = /obj/effect/knowspell/projectile/throw/sweep


/obj/item/weapon/magic/spellbook/mime
	name = "book of miming"
	desc = "A cursory inspection shows this book is blank, and yet...?"
	spawn_spells = list(/obj/effect/knowspell/mime/speech, /obj/effect/knowspell/mime/mimewall, /obj/effect/knowspell/mime/beartrap)


/obj/item/clothing/gloves/magic/shadow
	name = "gloves of shadow step"
	desc = "If you stare too long at these gloves, they start to stare back."
	color = "black"
	icon_state = "black"
	item_state = "blackgloves"
	spawn_spelltype = /obj/effect/knowspell/self/shadowstep

