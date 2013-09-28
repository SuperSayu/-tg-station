/obj/effect/knowspell/self/castingmode = CAST_SPELL|CAST_SELF

/obj/effect/knowspell/self/teleport
	name = "teleport"
	desc = "Sends you to a random location in the target area."

	require_clothing = 1
	incantation = "SCYAR NILA"
	incant_volume = 2
	allow_stuncast = 1

	chargemax = 600
	var/turf/target_turf = null

	incant(var/mob/caster, var/area/target)
		var/level = incant_volume
		if(istype(loc,/obj/item))
			level--
		if(level < 1) return
		var/speech = incantation
		if(prob(50))//Auto-mute? Fuck that noise
			speech = replacetext(incantation," ","`")
		speech += " [uppertext(target.name)]"
		switch(incant_volume)
			if(2)
				caster.say(speech)
			if(1)
				caster.whisper(speech)

	prepare(var/mob/caster)
		var/A = input(caster, "Area to teleport to", "Teleport", null) in teleportlocs
		if(A)
			activate(caster, teleportlocs[A])
			// magic items note: activate() checks to make sure the item is still in hand
			// you cannot put an enchanted item in your pocket after getting the select popup

	before_cast(var/mob/caster, var/area/target)
		if(!istype(target))
			return 0
		..() // incantation
		var/list/possible_turfs = teleport_filter(area_contents(target))
		if(!possible_turfs.len)
			caster << "\red The magic refuses to activate!"
			return 0
		target_turf = pick(possible_turfs)
		return 1

	cast(var/mob/caster)
		caster.loc = target_turf
		smoke_cloud(caster)
		return 1


/obj/effect/knowspell/self/blink
	name = "blink"
	desc = "Sends you a short distance."

	require_clothing = 0
	incant_volume = 0
	chargemax = 35
	prevent_centcom = 1
	allow_stuncast = 1
	castingmode = CAST_SPELL|CAST_SELF|CAST_MELEE

	var/turf/target_turf = null

	prepare(mob/caster)
		activate(caster,caster)

	attack(atom/target,mob/caster)
		if(ismob(target))
			activate(caster,target)

	before_cast(var/mob/caster,var/mob/target)
		..()
		var/list/possible_turfs = teleport_filter(range(caster,6) - range(caster,1))
		if(!possible_turfs.len)
			caster << "\red The magic refuses to activate!"
			return 0
		target_turf = pick(possible_turfs)
		return 1
	cast(var/mob/caster,var/mob/target)
		var/atom/oldloc = target.loc
		target.loc = target_turf
		smoke_cloud(oldloc, get_dist(oldloc,target_turf),pick(0,0,0,1))
		return 1

/obj/effect/knowspell/self/jaunt
	name = "ethereal jaunt"
	desc = "Carries you as an ethereal wisp through the world.  Beware, it's still not safe to expose yourself to hostile environments."

	chargemax = 300
	incant_volume = 0
	prevent_centcom = 1
	allow_nonhuman = 0

	before_cast(var/mob/caster)
		if(!isturf(caster.loc))
			return 0
		if(caster.buckled)
			caster.buckled.unbuckle()
		..()
		return 1

	cast(var/mob/caster)
		var/obj/effect/spelleffect/jaunt/J = new(caster.loc)
		J.start(caster)

/obj/effect/knowspell/self/ghostize
	name = "astral projection"
	desc = "Detaches your mind and sends it to the world of the dead, where you can learn their secrets."

	chargemax = 400
	incant_volume = 1
	allow_nonhuman = 1
	incantation = "AD ASTRA" // wait hang on that's actual latin, foul, foul

	cast(var/mob/caster)
		caster << "\blue You can see...everything!"
		caster.ghostize(1)

/obj/effect/knowspell/self/shadowstep
	name = "shadow step"
	desc = "Jumps from one shadow to another."

	chargemax = 50
	incant_volume = 0
	incantation = "NINJA"
	allow_stuncast = 1 // although you can't actually do this with a targetted spell
	allow_nonhuman = 1
	require_clothing = 0
	prevent_centcom = 1
	castingmode = CAST_SPELL|CAST_RANGED

	prepare(mob/caster)
		if(!cast_check(caster))
			return
		create_spellthrower(caster)
	afterattack(atom/target, mob/living/caster) // click map to cast
		activate(caster,get_turf(target))
	before_cast(var/mob/caster, var/turf/target)
		var/turf/T = get_turf(caster)
		if(!T || T.lighting_lumcount > 2)
			caster << "\red The shadows aren't dark enough here!"
			return 0
		if(!target || target.lighting_lumcount > 2)
			caster << "\red The shadows aren't dark enough there!"
			return 0
		if(target.density)
			caster << "\red That's obstructed."
			return 0
		for(var/obj/O in target)
			if(O.density && !(O.flags&ON_BORDER))
				caster << "\red That's obstructed."
				return 0
		return ..()
	cast(var/mob/caster, var/turf/target)
		caster.loc = target
