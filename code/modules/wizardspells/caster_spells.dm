/obj/effect/knowspell/self/teleport
	name = "teleport"
	desc = "Sends you to a random location in the target area."

	require_clothing = 1
	incantation = "SCYAR NILA"
	incant_volume = 2

	chargemax = 600
	var/turf/target_turf = null

	incant(var/mob/caster, var/area/target)
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
	chargemax = 20
	prevent_centcom = 1
	allow_stuncast = 1

	var/turf/target_turf = null

	before_cast(var/mob/caster)
		..()
		var/list/possible_turfs = teleport_filter(range(caster,6))
		if(!possible_turfs.len)
			caster << "\red The magic refuses to activate!"
			return 0
		target_turf = pick(possible_turfs)
		return 1
	cast(var/mob/caster)
		var/atom/oldloc = caster.loc
		caster.loc = target_turf
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
