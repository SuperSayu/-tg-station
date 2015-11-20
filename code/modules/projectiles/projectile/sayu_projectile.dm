/obj/item/projectile/reagent
	name = "syringe dart"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringeproj"
	damage = 0
	nodamage = 1
	flag = "bullet"
	range = 8 // lower range by far
	var/obj/item/contained = null

/obj/item/projectile/reagent/New(loc,obj/item/reagent_source = null)
	if(reagent_source && reagent_source.reagents)
		contained = reagent_source
		contained.loc = src
	..()

/obj/item/projectile/reagent/on_hit(var/atom/target,var/blocked=0)
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
		qdel(contained)
	else
		contained.loc = loc
		step_rand(contained)

/obj/item/projectile/reagent/proc/splat(var/atom/A)
	A = get_turf(A)
	if(!A) return
	for(var/datum/reagent/R in contained.reagents.reagent_list)
		R.reaction_turf(A)
	/*
	/obj/item/projectile/reagent/Bump(atom/A as mob|obj|turf)
		var/turf/simulated/T = get_turf(A)
		if(contained && contained.reagents && prob(33) && istype(A))
			if(contained.reagents.has_reagent("banana") && !(locate(/obj/effect/decal/cleanable/pie_smudge) in T))
				new /obj/effect/decal/cleanable/pie_smudge(T)
			for(var/datum/reagent/R in contained.reagents.reagent_list)
				R.reaction_turf(T)

		return ..(A)
	*/

/obj/item/projectile/reagent/bananacreme
	name = "banana creme bullet"
	damage = 0
	nodamage = 1
	flag = "bullet"

/obj/item/projectile/reagent/bananacreme/New()
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