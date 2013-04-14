/datum/event_control/dust/meaty
	name = "Meaty Space Dust"
	typepath = /datum/event/dust/meaty
	weight = 10
	max_occurrences = 100
	earliest_start = 0

/datum/event/dust/meaty/announce()
	if(prob(33))
		command_alert("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")
	else
		command_alert("Meaty ores have been detected on collision course with the station.", "Meaty Ore Alert")
		world << sound('sound/AI/meteors.ogg')

/datum/event/dust/meaty/setup()
	qnty = rand(5,15)

/datum/event/dust/meaty/start()
	while(qnty-- > 0)
		new /obj/effect/space_dust/meaty()

/obj/effect/space_dust/meaty
	icon = 'icons/mob/animal.dmi'
	icon_state = "cow"

	strength = 1
	life = 1

	Bump(atom/A)
		if(prob(20))
			spawn(1)
				for(var/mob/M in range(10, src))
					if(!M.stat && !istype(M, /mob/living/silicon/ai))
						shake_camera(M, 3, 1)
		if (A)
			playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)
			walk(src,0)
			invisibility = 101
			if(isturf(A))
				new /obj/effect/decal/cleanable/blood(A)

			if(prob(80))
				if(prob(33))
					new /obj/item/weapon/reagent_containers/food/snacks/meat(loc)
				else
					new /obj/effect/decal/cleanable/blood/gibs(loc)
			else
				new /mob/living/simple_animal/cow(loc)

			if(ismob(A))
				A.meteorhit(src)
			else
				var/s = strength
				spawn(1)
					A.ex_act(s)

			del(src)
