/*
	apparently tg wanted mime powers to be spells
	this is dumb but
	okay
*/
/obj/effect/knowspell/mime
	panel = "Mime"
	require_clothing = 0
	allow_nonhuman = 0
	var/require_miming = 1
	mindswap_forget_chance = 0
/obj/effect/knowspell/mime/stat_check(var/mob/living/carbon/human/H)
	. = ..()
	if(. && require_miming)
		if(istype(H) && H.mind && H.mind.miming)
			return 1
		H << "Mime abilities require adherence to the vow of sience!"
		return 0

/obj/effect/knowspell/mime/speech
	name = "Vow of Silence"
	desc = "Make or break a vow of silence."
	cloning_forget_chance = 0

	require_miming = 0 // only exception really
	allow_stuncast = 1
	chargemax = 3000
	incant_volume = 2
	incantation = "*cough" // cough cough

/obj/effect/knowspell/mime/speech/charge_check(var/mob/living/carbon/human/caster)
	. = ..()
	if(!. && istype(caster) && caster.mind)
		if(caster.mind.miming)
			caster << "<span class='notice'>You can't break your vow of silence that fast!</span>"
		else
			caster << "<span class='notice'>You'll have to wait before you can give your vow of silence again.</span>"

/obj/effect/knowspell/mime/speech/cast(var/mob/living/carbon/human/caster)
	if(!istype(caster) || !caster.mind) return
	caster.mind.miming=!caster.mind.miming
	if(caster.mind.miming)
		caster << "<span class='notice'>You make a vow of silence.</span>"
	else
		caster << "<span class='notice'>You break your vow of silence.</span>"

/obj/effect/knowspell/mime/mimewall
	name = "Mimewall"
	chargemax = 300
	allow_stuncast = 0
	var/duration = 300

/obj/effect/knowspell/mime/mimewall/incant(var/mob/caster)
	caster.visible_message("<B>[caster.real_name]</B> looks as if a wall is in front of them.")

/obj/effect/knowspell/mime/mimewall/cast(var/mob/caster)
	new /obj/effect/spelleffect/forcewall/mime(get_step(caster,caster.dir),null,duration)

/obj/effect/knowspell/mime/beartrap
	name = "Mimetrap"
	desc = "Don't step on it!"

	chargemax = 450
	var/setup_time = 30
	var/duration = 150

/obj/effect/knowspell/mime/beartrap/incant(var/mob/caster)
	caster.visible_message("<B>[caster.real_name]</B> wrestles with a pair of invisible jaws!")

/obj/effect/knowspell/mime/beartrap/before_cast(var/mob/caster)
	incant(caster)
	return do_after(caster, setup_time)

/obj/effect/knowspell/mime/beartrap/cast(var/mob/caster)
	new /obj/item/weapon/legcuffs/beartrap/mimetrap(caster.loc,duration)
	caster.visible_message("<B>[caster.real_name]</B> sets something on the ground, looking proud!")

/obj/effect/spelleffect/forcewall/mime
	name = "mimewall"
	desc = "A space mime's magic wall."
	icon = null
	icon_state = null

/obj/item/weapon/legcuffs/beartrap/mimetrap
	name = "mimetrap"
	desc = "A beartrap catches bears, this is meant to...?"
	icon = null
	icon_state = null
	breakouttime = 50 // 5s
	slowdown = 4 // less severe than a beartrap
	anchored = 1
	armed = 1
	New(l,d = 30)
		..()
		if(d > 0)
			spawn(d)
				del(src)
	Del()
		if(ismob(loc))
			var/mob/L = loc
			L.remove_from_mob(src)
		..()
