#define REM REAGENTS_EFFECT_MULTIPLIER

datum/reagent/medicine/morphine
	name = "Morphine"
	id = "morphine"
	description = "A drug that relieves pain but does not heal any damage. It will prevent limping and adverse effects caused by the pain of having a broken bone."
	reagent_state = LIQUID
	color = "#EEEEEE"

datum/reagent/medicine/morphine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustStaminaLoss(-1*REM)
	..()
	return

// Undefine the alias for REAGENTS_EFFECT_MULTIPLER
#undef REM