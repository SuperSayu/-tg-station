/*
	Short circuits: Produce heat, drain electricity.

	While this is a nice idea, at the moment it's too underdeveloped to include.
	It makes sense for there to be such a thing as power shorts,
	1) there's no consistent way to find/track them for repairs
	2) the method to create them is silly (glass shard + cable)

	It's basically too easy to create them and not easy to repair them.  An event that created them
	for the purposes of being repaired might be nice, but I want to think on that a bit more
	before giving in
*/

/obj/structure/cable
	var/obj/machinery/power/cable_short/short = null

/obj/machinery/power/cable_short
	name = "short-circuit"
	desc = "Looks like the wire was cut."
	var/datum/effect/effect/system/lightning/spreader = null
	use_power = 0

	process()
		var/obj/structure/cable/affected = loc
		var/turf/simulated/T = get_turf(affected)
		if(!istype(affected) || isnull(T) || affected.short != src)
			spawn(1)
				del src
			return
		var/datum/powernet/PN = affected.get_powernet()

		if(PN && PN.avail > 0)
			if(!spreader)
				spreader = new
				spreader.set_up(pick(1,1,2),T)

			if(prob(95) || PN.avail < 1000)
				use_power(pick(10,50,100,200,400,100,150,50,25,100),pick(0,2,3))
				return

			var/power_used = min(PN.avail,pick(1000,1000,2000,5000,7500,2500))
			use_power(power_used,pick(0,2,3))
			spawn(0)
				spreader.start()

			// stolen from spaceheater code again -Sayu
			if(istype(T))
				var/datum/gas_mixture/env = T.return_air()
				var/transfer_moles = 0.20 * env.total_moles()

				var/datum/gas_mixture/removed = env.remove(transfer_moles)

				if(removed)
					var/heat_capacity = removed.heat_capacity()
					if(!heat_capacity) // Added check to avoid divide by zero (oshi-) runtime errors -- TLE
						heat_capacity = 1
					removed.temperature = min((removed.temperature*heat_capacity + power_used*1250)/heat_capacity, 1000) // Added min() check to try and avoid wacky superheating issues in low gas scenarios -- TLE
					env.merge(removed)
