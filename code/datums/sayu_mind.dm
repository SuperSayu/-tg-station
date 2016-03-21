/datum/mind/proc/clone_to(mob/living/new_character) // this should only be used with in-character cloning, as it carries gameplay effects
	if(current)
		for(var/obj/effect/knowspell/mime/M in current)
			qdel(M)
		for(var/obj/effect/knowspell/KS in current.contents)
			var/allowed = 1
			if(prob(KS.cloning_forget_chance))
				allowed = 0
			if(!KS.allow_nonhuman && !ishuman(new_character))
				allowed = 0
			if(!KS.allow_cyborg && issilicon(new_character))
				allowed = 0
			if(!allowed)
				current << "You forgot \i[KS]."
			else
				KS.loc = new_character
	if(assigned_role == "Mime" && ishuman(new_character))
		new /obj/effect/knowspell/mime/speech(new_character)
		new /obj/effect/knowspell/mime/mimewall(new_character)
		new /obj/effect/knowspell/mime/beartrap(new_character)
	transfer_to(new_character)