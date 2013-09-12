/obj/effect/knowspell/area
	var/visible_range = 0
	var/range = 6
	castingmode = CAST_SPELL|CAST_SELF

	activate(mob/caster, list/target)
		if(cast_check(caster))

			if(visible_range)
				target = view(caster,range)
			else
				target = range(caster,range)

			if(before_cast(caster,target))
				cast(caster,target)
				after_cast(caster,target)

/obj/effect/knowspell/area/emp
	name = "disable technology"
	desc = "Causes an electromagnetic wave that wreaks havoc on electronics."

	require_clothing = 0
	range = 3
	chargemax = 400

	incantation = "NEC CANTIO"
	incant_volume = 2
	complexity = 2 // cast from orb but not scroll

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
	chargemax = 450

	incantation = "FLASH A-AAAA"
	incant_volume = 2

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

	chargemax = 100
	require_clothing  = 0

	visible_range = 0
	range = 3

	incantation = "AULIE OXIN FIERA"
	incant_volume = 1

	cast(mob/caster, list/target)
		for(var/obj/machinery/door/D in target)
			if(istype(D,/obj/machinery/door/airlock))
				D:locked = 0

			spawn
				D.open()
