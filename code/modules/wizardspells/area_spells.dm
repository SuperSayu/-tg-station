/*
	Area spells

	Special: When cast as a melee action, target only things in that square.
*/

/obj/effect/knowspell/area
	var/visible_range = 0
	var/range = 6
	castingmode = CAST_SPELL|CAST_SELF|CAST_MELEE

	attack(atom/target, mob/caster)
		activate(caster, target) // always returns 0

	activate(mob/caster, list/target = null)
		var/lesser = 0
		if(cast_check(caster))
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
			charge = chargemax / 2
			start_recharge()
			return
		..()

/obj/effect/knowspell/area/emp
	name = "disable technology"
	desc = "Causes an electromagnetic wave that wreaks havoc on electronics."

	require_clothing = 0
	range = 3
	chargemax = 400

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

	chargemax = 200
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
			if(istype(D,/obj/machinery/door/airlock))
				D:locked = 0

			spawn
				D.open()

/obj/effect/knowspell/area/lock
	name = "hold portal"
	desc = "An old wizard trick for closing doors."

	chargemax = 300
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
			spawn
				D.close()
				if(istype(D,/obj/machinery/door/airlock))
					D:locked = 1
					D.update_icon()