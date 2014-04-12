/*
	Area spells

	Special: When cast as a melee action, target only things in that square.
*/

/obj/effect/knowspell/area
	var/visible_range = 0
	var/range = 6
	var/directcast_charge = 0 // charge lost when casting on something
	castingmode = CAST_SPELL|CAST_SELF|CAST_MELEE

	attack(atom/target, mob/caster)
		activate(caster, target) // always returns 0
	afterattack(atom/target, mob/caster)
		activate(caster, target)

	cast_check(caster,lesser)
		return charge_check(caster,lesser) && stat_check(caster) && centcom_check(caster) && clothing_check(caster)

	charge_check(caster,lesser)
		if(rechargable)
			if(lesser && directcast_charge)
				return charge >= directcast_charge
			else
				return charge >= chargemax
		else
			return charge > 0


	activate(mob/caster, list/target = null)
		var/lesser = 0
		if(isloc(target))
			var/atom/A = get_turf(target)
			target = A.contents + A
			lesser = 1 // targetting only one square
		if(cast_check(caster,lesser))
			if(!target)
				if(visible_range)
					target = view(caster,range)
				else
					target = range(caster,range)
			else if(isloc(target))
				var/atom/A = get_turf(target)
				target = A.contents
				lesser = 1 // targetting only one square

			if(before_cast(caster,target))
				cast(caster,target)
				after_cast(caster,target,lesser)
				return 1
	after_cast(caster,target,lesser)
		if(rechargable && lesser)
			charge -= directcast_charge
			start_recharge()
			return
		..()

/obj/effect/knowspell/area/emp
	name = "disable technology"
	desc = "Causes an electromagnetic wave that wreaks havoc on electronics."

	wand_state = "revivewand"

	require_clothing = 0
	range = 3
	chargemax = 400
	directcast_charge = 100

	incantation = "NEC CANTIO"
	incant_volume = 2

	cast(mob/caster, list/target)
		for(var/atom/movable/AM in target)
			if(AM == caster && prob(66)) continue
			if(prob(50))
				AM.emp_act(1)
			else
				AM.emp_act(2)

/obj/effect/knowspell/area/blind
	name = "blinding flash"
	desc = "A bright light blinds everyone in the area."

	require_clothing = 0
	allow_stuncast = 1
	visible_range  = 1
	range = 5
	chargemax = 300
	directcast_charge = 75 // you are likely to miss anyway

	incantation = "FLASH A-AAAA"
	incant_volume = 2

	before_cast(mob/caster, list/target)
		for(var/mob/living/ML in target)
			if(ML.stat) continue
			if(ML == caster) continue
			..()
			return 1
		return 0

	cast(mob/caster, list/target)
		for(var/mob/living/LM in target)
			if(LM.stat) continue
			if(LM == caster) continue
			// Values taken from old spell
			LM.eye_blind += 5
			LM.eye_blurry += 20
			LM.Stun(1)

/obj/effect/knowspell/area/knock
	name = "knock"
	desc = "An old wizard trick for opening doors."

	wand_state = "doorwand"

	chargemax = 200
	directcast_charge = 100
	require_clothing  = 0

	visible_range = 0
	range = 3

	allow_stuncast = 1
	incantation = "AULIE OXIN FIERA"
	incant_volume = 1
	castingmode = CAST_SPELL|CAST_SELF|CAST_MELEE

	before_cast(mob/caster, list/target)
		for(var/obj/machinery/door/D in target)
			..()
			return 1
		return 0

	cast(mob/caster, list/target)
		for(var/obj/machinery/door/D in target)
			if(!unlock_centcom && !(caster.client && caster.client.holder) && istype(D,/obj/machinery/door/airlock/centcom))
				continue
			if(istype(D,/obj/machinery/door/airlock))
				D:locked = 0

			spawn
				D.open()

/obj/effect/knowspell/area/lock
	name = "hold portal"
	desc = "An old wizard trick for closing doors."

	wand_state = "doorwand"

	chargemax = 300
	directcast_charge = 150
	require_clothing = 0

	visible_range = 1
	range = 4

	allow_stuncast = 1
	incantation = "TERA LOCHA"
	incant_volume =  1
	castingmode = CAST_SPELL|CAST_SELF|CAST_MELEE

	attack(atom/target, mob/caster)
		return activate(caster, target) // return yes if cast


	before_cast(mob/caster, list/target)
		for(var/obj/machinery/door/D in target)
			..()
			return 1
		return 0

	cast(mob/caster, list/target)
		for(var/obj/machinery/door/D in target)
			if(!unlock_centcom && !(caster.client && caster.client.holder) && istype(D,/obj/machinery/door/airlock/centcom))
				continue
			spawn
				D.close()
				if(istype(D,/obj/machinery/door/airlock))
					D:locked = 1
					D.update_icon()

/obj/effect/knowspell/area/grease
	name = "grease"
	desc = "An old wizard trick for slipping up foes."

	chargemax = 550
	require_clothing = 1

	visible_range = 1
	range = 3
	allow_stuncast = 1
	incantation = "WOT SEA FLOOR"
	castingmode = CAST_SPELL | CAST_SELF | CAST_RANGED
	afterattack(atom/A, mob/caster)
		var/turf/T = get_turf(A)
		activate(caster,view(T,range))

	cast(mob/caster, list/target)
		for(var/turf/simulated/T in target)
			T.MakeSlippery(pick(1,2,2,2))
