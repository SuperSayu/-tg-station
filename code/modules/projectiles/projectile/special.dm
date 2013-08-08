/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"


	on_hit(var/atom/target, var/blocked = 0)
		empulse(target, 1, 1)
		return 1

/obj/item/projectile/reagent
	name = "syringe dart"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringeproj"
	damage = 0
	nodamage = 1
	flag = "bullet"
	kill_count = 8 // lower range by far
	var/obj/item/contained = null

	New(loc,obj/item/reagent_source = null)
		if(reagent_source && reagent_source.reagents)
			contained = reagent_source
			contained.loc = src
		..()

	on_hit(var/atom/target,var/blocked=0)
		var/destroy = 0
		if(prob(32))
			splat(target)
			destroy = 1
		if(istype(target,/mob))
			var/mob/M = target
			if(contained && contained.reagents && M.reagents)
				contained.reagents.trans_to(M,contained.reagents.total_volume)
			destroy = 1
		if(destroy)
			del contained
		else
			contained.loc = loc
			step_rand(contained)

	proc/splat(var/atom/A)
		A = get_turf(A)
		if(!A) return
		for(var/datum/reagent/R in contained.reagents.reagent_list)
			R.reaction_turf(A)
	/*
	Bump(atom/A as mob|obj|turf)
		var/turf/simulated/T = get_turf(A)
		if(contained && contained.reagents && prob(33) && istype(A))
			if(contained.reagents.has_reagent("banana") && !(locate(/obj/effect/decal/cleanable/pie_smudge) in T))
				new /obj/effect/decal/cleanable/pie_smudge(T)
			for(var/datum/reagent/R in contained.reagents.reagent_list)
				R.reaction_turf(T)

		return ..(A)
	*/
	log_hit(var/mob/target)
		var/R = ""
		if(contained && contained.reagents)
			for(var/datum/reagent/A in contained.reagents.reagent_list)
				R += A.id + ","
		else
			R = "no payload"
		if(istype(firer, /mob))
			target.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[target]/[target.ckey]</b> with a <b>[src]</b> ([R])"
			firer.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[target]/[target.ckey]</b> with a <b>[src]</b> ([R])"
			log_attack("<font color='red'>[firer] ([firer.ckey]) shot [target] ([target.ckey]) with a [src] ([R])</font>")
		else
			target.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[target]/[target.ckey]</b> with a <b>[src]</b> ([R])"
			log_attack("<font color='red'>UNKNOWN shot [target] ([target.ckey]) with a [src] ([R])</font>")

/obj/item/projectile/reagent/bananacreme
	name = "banana creme bullet"
	damage = 0
	nodamage = 1
	flag = "bullet"

	New()
		..()
		contained = new /obj/item/weapon/reagent_containers/food/snacks(src)
		contained.name = "banana creme bullet"
		contained.desc = "Oh god it's dripping all over your fingers and it smells SO good."
		contained.icon = 'icons/obj/items.dmi'
		contained.icon_state = "banana"
		contained.item_state = "banana"

		contained:bitecount = 1 // snack variables not in scope
		contained:bitesize = 10

		contained.reagents.add_reagent("nutriment", 3)
		contained.reagents.add_reagent("banana",3)
		contained.reagents.add_reagent("cornoil", 1)
		contained.reagents.add_reagent("sugar",1)
		if(prob(1))
			contained.reagents.add_reagent("minttoxin",1)
		return

/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	flag = "bullet"


	on_hit(var/atom/target, var/blocked = 0)
		explosion(target, -1, 0, 2)
		return 1

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/temperature = 300


	on_hit(var/atom/target, var/blocked = 0)//These two could likely check temp protection on the mob
		if(istype(target, /mob/living))
			var/mob/M = target
			M.bodytemperature = temperature
		return 1

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "smallf"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return

		sleep(-1) //Might not be important enough for a sleep(-1) but the sleep/spawn itself is necessary thanks to explosions and metoerhits

		if(src)//Do not add to this if() statement, otherwise the meteor won't delete them
			if(A)

				A.meteorhit(src)
				playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)

				for(var/mob/M in range(10, src))
					if(!M.stat && !istype(M, /mob/living/silicon/ai))\
						shake_camera(M, 3, 1)
				delete()
				return 1
		else
			return 0

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/target, var/blocked = 0)
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			if(check_dna_integrity(M) && M.dna.mutantrace == "plant") //Plantmen possibly get mutated and damaged by the rays.
				if(prob(15))
					M.apply_effect((rand(30,80)),IRRADIATE)
					M.Weaken(5)
					for (var/mob/V in viewers(src))
						V.show_message("\red [M] writhes in pain as \his vacuoles boil.", 3, "\red You hear the crunching of leaves.", 2)
				if(prob(35))
				//	for (var/mob/V in viewers(src)) //Public messages commented out to prevent possible metaish genetics experimentation and stuff. - Cheridan
				//		V.show_message("\red [M] is mutated by the radiation beam.", 3, "\red You hear the snapping of twigs.", 2)
					if(prob(80))
						randmutb(M)
						domutcheck(M,null)
					else
						randmutg(M)
						domutcheck(M,null)
				else
					M.adjustFireLoss(rand(5,15))
					M.show_message("\red The radiation beam singes you!")
				//	for (var/mob/V in viewers(src))
				//		V.show_message("\red [M] is singed by the radiation beam.", 3, "\red You hear the crackle of burning leaves.", 2)
			else
			//	for (var/mob/V in viewers(src))
			//		V.show_message("The radiation beam dissipates harmlessly through [M]", 3)
				M.show_message("\blue The radiation beam dissipates harmlessly through your body.")

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

	on_hit(mob/living/carbon/target, var/blocked = 0)
		if(iscarbon(target))
			if(ishuman(target) && target.dna && target.dna.mutantrace == "plant")	//These rays make plantmen fat.
				target.nutrition = min(target.nutrition+30, 500)
			else
				target.show_message("\blue The radiation beam dissipates harmlessly through your body.")
		else
			return 1


/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

	on_hit(var/atom/target, var/blocked = 0)
		if(ishuman(target))
			var/mob/living/carbon/human/M = target
			M.adjustBrainLoss(20)
			M.hallucination += 20
