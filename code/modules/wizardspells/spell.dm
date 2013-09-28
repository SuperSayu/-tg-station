/*
	Spell organization

	- casting methods
		Click() - when the spell is selected in the status pane
		'cast spell' verb - can be typed from the command line or selected from the IC panel.  If you have more than one spell, it will popup asking which you want to cast.
		Topic() - when called from a cast link in a spellbook or similar
		attack_self(), attack(), afterattack() - When an enchanted item / spellthrower  is used, the item's attacks translate to equivalent calls on the spell.

	- before casting
		Prepare: You have not yet begun to cast; this is the *default starting point*.  If you want to create a spellthrower, or other strange cast effect, do it here.
		Activation: Runs the casting checks, and before_cast(), then casts if they all succeed
		before_cast: You are can cast and are in the process of it but have not yet committed to it.  Returning 0 cancels the cast, 1 continues.  Incantation usually happens here.
		* cast_check() runs all the default checks.  arguably you could make them all the same function but it's more readable when they're separate.

	- casting
		cast: The actual meat of the spell happens here.  Irrespective of the return result, this is immediately followed by after_cast.
		after_cast: Begins spell recharge / decreases use counter.

*/
// castingmode - used my magic items
var/const/CAST_SPELL = 1	// Normal spell: shows up in spell tab, can be learned
var/const/CAST_SELF = 2		// Magic items: Use-self
var/const/CAST_MELEE = 4	// Magic items: Attack
var/const/CAST_RANGED = 8	// Magic items: afterattack

/obj/effect/knowspell
	name = "bullshit spell effect"
	desc = "incredibly shitty spell"
	unacidable = 1


	var/require_clothing = 1	// 1: requires garb
	var/prevent_centcom = 0	// 1: prevent cast on Centcom level
	var/incant_volume = 0	// 0: silent; 1: whisper; 2: shout
	var/incantation = "HERPUS DERPUS" // this is totes legit magical latin, no hating

	var/rechargable = 1		// 1: casting drops charge to zero, and it then recharges; 0: casting decreases charges
	var/charge = 0
	var/chargemax = 10

	var/allow_stuncast = 0 // Cast when stunned/weakened
	var/allow_nonhuman = 1
	var/castingmode = CAST_SPELL	// enchantment: what kind of item it can take
	var/complexity = 1				// enchantment: serious spells require serious items

	New()
		..()
		charge = chargemax

	proc/describe(var/allow_cast = 1, var/allow_learn = 1, var/add_description = 1, var/remove_from = null)
		var/castblock = ""
		var/learnblock = ""
		var/removeblock = ""
		if(allow_cast)
			castblock = "<a href='?\ref[src];cast'>\[Cast\]</a>"
		if(allow_learn && castingmode&CAST_SPELL)
			learnblock = "<a href='?\ref[src];learn'>\[Learn\]</a>"
		if(isobj(remove_from))
			removeblock = "<a href='?\ref[remove_from];remove=\ref[src]'>\[Remove Scroll\]</a>"

		var/uses = (rechargable?"[charge/10] second\s":"[charge] uses")
		var/descblock = ""
		if(add_description)
			if(incant_volume)
				descblock += "Verbal component.  "
			if(require_clothing)
				descblock += "Requires wizard garb.  "
			else
				descblock += "Robeless spell.  "
			if(!allow_stuncast)
				descblock += "Cannot cast while stunned.  "
			if(prevent_centcom)
				descblock += "Cannot cast on the wizard sanctuary / in hyperspace."
			descblock += "<br><i>[desc]</i><br>"

		return "<h4>[name] [castblock]([uses]) [learnblock] [removeblock]</h4>[descblock]"

	Topic(href,list/href_list)
		if(usr.stat) return
		..()

		if("cast" in href_list)
			prepare(usr,null)
			return 1

		if("learn" in href_list)
			if(src in usr.spell_list) return

			usr.spell_list -= null // just in case something was deleted

			if(usr.spell_list.len >= max_spells)
				var/choice = input(usr,"You have reached your limit; forget which spell?","Forget spell",null) as null|anything in usr.spell_list
				if(choice)
					usr.spell_list -= choice
					del choice
			if(usr.spell_list.len >= max_spells || (src in usr.spell_list))
				return
			var/obj/oldloc = loc
			loc = usr
			usr.spell_list += src
			//usr.spell_list = sortAtom(usr.spell_list)
			if(isobj(oldloc))
				oldloc.interact()
			return 1

	proc/cast_check(var/mob/caster)
		return charge_check() && stat_check(caster) && centcom_check(caster) && clothing_check(caster)

	proc/clothing_check(var/mob/living/carbon/human/H)
		if(istype(loc,/obj))
			return 1
		if(!istype(H))
			if(require_clothing)
				H << "<span class='notice'>You don't feel human enough!</span>"
				return 0
			return 1

		if(incant_volume > 0 && istype(H.wear_mask, /obj/item/clothing/mask/muzzle))
			H << "<span class='notice'>You can't get the words out!</span>"
			return 0

		if(!require_clothing)
			return 1

		if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe) && !istype(H.wear_suit, /obj/item/clothing/suit/space/rig/wizard))
			H << "<span class='notice'>I don't feel strong enough without my robe.</span>"
			return 0
		if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
			H << "<span class='notice'>I don't feel strong enough without my sandals.</span>"
			return 0
		if(!istype(H.head, /obj/item/clothing/head/wizard) && !istype(H.head, /obj/item/clothing/head/helmet/space/rig/wizard))
			H << "<span class='notice'>I don't feel strong enough without my hat.</span>"
			return 0

		return 1

	proc/charge_check()
		if(rechargable)
			return charge >= chargemax
		else
			return charge > 0

	proc/stat_check(var/mob/living/caster)
		if(!caster || caster.stat) return 0

		if(istype(loc,/obj/item/weapon/magic)) // magic items: must be held
			if(loc.loc != caster) return 0
			if(caster.get_active_hand() != loc && caster.get_inactive_hand() != loc)
				var/mob/living/carbon/human/H = caster
				if(!istype(H) || H.gloves != loc) // magic gloves
					return 0 // hands only
			return 1 // no other checks

		if(!allow_nonhuman)
			if(!istype(caster,/mob/living/carbon/human))
				caster << "<span class='notice'>You don't feel human enough!</span>"
				return 0
		if(!allow_stuncast)
			if(caster.stunned || caster.weakened || caster.paralysis)
				return 0
		if(incant_volume > 0)
			if(caster.sdisabilities&MUTE)
				caster << "<span class='notice'>Your tongue refuses to form the words!</span>"
				return 0
			if(caster.stuttering || caster.disabilities&(COUGHING|TOURETTES))
				if(prob(20))
					caster << "<span class='notice'>You fumble over the words and lose the spell!</span>"
					caster.visible_message("<span class='notice'>[caster] stammers out half a magic phrase before being forced to stop.</span>")
					after_cast(caster,caster) // discharge/recharge
					return 0
		return 1

	proc/centcom_check(var/mob/caster)
		var/turf/T = get_turf(caster)
		. = (!prevent_centcom || !T || T.z != 2)
		if(!.)
			caster << "Powerful energies prevent you from using that here."
		return .



	proc/prepare(mob/user = usr)// distinct from casting, used when clicked on
		activate(user,null)

	proc/activate(mob/user,atom/target = null)
		if(cast_check(user) && before_cast(user,target))
			cast(user,target)
			after_cast(user,target)
		return

	proc/before_cast(var/mob/caster, target = null)
		incant(caster, target)
		return 1

	proc/cast(var/mob/caster, target = null)
		return 1

	proc/after_cast(var/mob/caster, target = null)
		if(rechargable)
			charge = 0
			start_recharge()
		else
			charge = max(charge-1, 0)
			if(charge <= 0)
				if(istype(loc,/obj/item/weapon/magic))
					var/obj/item/weapon/magic/M = loc
					M.dispell(1) // will delete us
				else
					spawn()
						del src
		return 1

	proc/start_recharge()
		spawn()
			while(charge < chargemax)
				sleep(1)
				charge++

/*
	Special effects, helpers, & fluff
*/

	proc/incant(var/mob/caster, var/target = null)
		if(!incant_volume) return
		if(istype(loc,/obj/item/weapon/magic))
			return

		var/text = incantation
		if(prob(50)) //Auto-mute? Fuck that noise
			text = replacetext(text," ",pick("`","'","-","~"))

		switch(incant_volume)
			if(2)
				spawn
					caster.say(text)
			if(1)
				caster.whisper(text)

	proc/create_spellthrower(var/mob/caster)
		var/obj/item/I = caster.get_active_hand()
		if(I)
			if(istype(I,/obj/item/weapon/magic/spell_thrower))
				caster << "\blue You switch spells.  You are now casting [src]."
				I:spell = src
				I.name = name
				I.desc = desc
				return
			else if(istype(I,/obj/item/weapon/magic) && I == loc)
				if(I:castingmode&CAST_RANGED)
					caster << "\blue You can cast through [I] by pointing it at the target."
					return
			caster << "\blue You need an empty hand to cast [src] properly."
			return
		caster.put_in_active_hand(new /obj/item/weapon/magic/spell_thrower(caster,src))

	proc/smoke_cloud(var/atom/target, var/smoke_amt = 2, var/badsmoke = 0)
		target = get_turf(target)
		if(!target) return

		if(!badsmoke)
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new
			smoke.set_up(smoke_amt, 0, target)
			smoke.start()
		else
			var/datum/effect/effect/system/bad_smoke_spread/smoke = new
			smoke.set_up(smoke_amt, 0, target)
			smoke.start()

	proc/scatter_sparks(var/atom/target, var/sparks_amt = 3)
		target = get_turf(target)
		if(!target) return
		var/datum/effect/effect/system/spark_spread/sparks = new
		sparks.set_up(sparks_amt, 0, target)
		sparks.start()

	proc/scatter_lightning(var/atom/target,var/lightning_amt =3)
		target = get_turf(target)
		if(!target) return
		var/datum/effect/effect/system/lightning_spread/sparky = new
		sparky.set_up(lightning_amt, 0, target)
		sparky.start()

	proc/scatter_steam(var/atom/target,var/steam_amt = 10)
		target = get_turf(target)
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(steam_amt, 0, target)
		steam.start()

	proc/teleport_filter(var/list/possible_turfs)
		var/list/result = list()
		turf_search:
			for(var/turf/simulated/T in possible_turfs)
				if(T.density) continue
				if(T.flags&NOJAUNT) continue
				for(var/atom/A in T)
					if(A.density  && !(A.flags&ON_BORDER))
						continue turf_search
				result += T
		return result

	proc/start_fire(var/turf/simulated/floor/TSF)
		if(!istype(TSF)) return
		var/datum/gas_mixture/napalm = new

		napalm.toxins = 20
		napalm.oxygen = 10
		napalm.temperature = 2400

		TSF.assume_air(napalm)
		spawn(0)
			TSF.hotspot_expose(700, 400)


	// These are ways in which the spell can be cast.
	// Click is used when you click the name in the spell pane, because you are technically clicking on the actual object.  Don't ask.
	Click()
		if(!(castingmode&CAST_SPELL))
			usr << "You can't cast this spell without help."
			return
		prepare(usr)
		return 1

	verb/manual_cast()
		set name = "cast spell"
		set category = "IC"
		set src in usr

		if(!(castingmode&CAST_SPELL))
			usr << "You can't cast this spell without help."
			return
		prepare(usr)

	// These are for enchanted items.  Whatever you do with the enchanted item, it should call the same proc here.
	// The spell thrower also uses the same system.
	proc/attack(atom/target as mob, mob/living/caster as mob, def_zone) // note for my purposes attack here does not just mean mobs, be advised
		return
	proc/attack_self(mob/living/caster as mob)
		prepare(caster)
		return
	proc/afterattack(atom/target, mob/living/caster as mob)
		return

/proc/magic_soundfx()
	return pick("poof","pak","pik","pok","doof","dop","dap","dwip","swhop","spoik","twaaa","flip","foip","frap","zuu","zaa",
						"chinp","choo","flok","zip","shaa","moo","chirp","chwap","snik","snap","snorp","fizzle","shaz","shazbot",
						"dlop","plop","oink","zing","zang","zoom","bing","boop","flap","choink","snizzle","sizzle","fart")


// used in mob/stat()
/mob/proc/list_wizspells()
/*
	if(spell_list.len)
		for(var/obj/effect/proc_holder/spell/S in spell_list)
			switch(S.charge_type)
				if("recharge")
					statpanel("Spells","[S.charge_counter/10.0]/[S.charge_max/10]",S)
				if("charges")
					statpanel("Spells","[S.charge_counter]/[S.charge_max]",S)
				if("holdervar")
					statpanel("Spells","[S.holder_var_type] [S.holder_var_amount]",S)
*/
	for(var/obj/effect/knowspell/KS in src.contents)
		if(KS.rechargable)
			statpanel("Spells","[KS.charge/10.0]/[KS.chargemax/10]",KS)
		else
			statpanel("Spells","[KS.charge] left",KS)
	if(l_hand) l_hand.Stat("Left hand")
	if(r_hand) r_hand.Stat("Right hand")
/mob/living/carbon/human/list_wizspells()
	..()
	if(gloves) gloves.Stat()