/area/holodeck
	name = "Holodeck"
	icon_state = "Holodeck"
	luminosity = 1
	lighting_use_dynamic = 0

	var/obj/machinery/computer/holodeck/linked
	var/restricted = 0 // if true, program goes on emag list

/*
	Power tracking: Use the holodeck computer's power grid
	Asserts are to avoid the inevitable infinite loops
*/

/area/holodeck/powered(var/chan)
	if(!master.requires_power)
		return 1
	if(master.always_unpowered)
		return 0
	if(!linked)
		return 0
	var/area/A = get_area(linked)
	ASSERT(!istype(A,/area/holodeck))
	return A.powered(chan)

/area/holodeck/usage(var/chan)
	if(!linked)
		return 0
	var/area/A = get_area(linked)
	ASSERT(!istype(A,/area/holodeck))
	return A.usage(chan)

/area/holodeck/addStaticPower(value, powerchannel)
	if(!linked)
		return
	var/area/A = get_area(linked)
	ASSERT(!istype(A,/area/holodeck))
	return A.addStaticPower(value,powerchannel)

/area/holodeck/use_power(var/amount, var/chan)
	if(!linked)
		return 0
	var/area/A = get_area(linked)
	ASSERT(!istype(A,/area/holodeck))
	return A.use_power(amount,chan)


/*
	This is the standard holodeck.  It is intended to allow you to
	blow off steam by doing stupid things like laying down, throwing
	spheres at holes, or bludgeoning people.
*/
/area/holodeck/rec_center
	name = "\improper Recreational Holodeck"

/area/holodeck/rec_center/offline
	name = "Holodeck - Offline"

/area/holodeck/rec_center/court
	name = "Holodeck - Empty Court"

/area/holodeck/rec_center/dodgeball
	name = "Holodeck - Dodgeball Court"

/area/holodeck/rec_center/basketball
	name = "Holodeck - Basketball Court"

/area/holodeck/rec_center/thunderdome
	name = "Holodeck - Thunderdome Court"

/area/holodeck/rec_center/beach
	name = "Holodeck - Beach"

/area/holodeck/rec_center/lounge
	name = "Holodeck - Lounge"

/area/holodeck/rec_center/medical
	name = "Holodeck - Emergency Medical"

/area/holodeck/rec_center/pet_lounge
	name = "Holodeck - Pet Playground"


// Bad programs

/area/holodeck/rec_center/burn
	name = "Holodeck - Atmospheric Burn Test"
	restricted = 1

/area/holodeck/rec_center/wildlife
	name = "Holodeck - Wildlife Simulation"
	restricted = 1

/area/holodeck/rec_center/bunker
	name = "Holodeck - Holdout Bunker"
	restricted = 1

//
// Theater holodeck
//

/area/holodeck/theater
	name = "\improper Holodeck Beta"

/area/holodeck/theater/base
	name = "Theater - Off"

/area/holodeck/theater/beach
	name = "Theater -  Beach"

/area/holodeck/theater/grass
	name = "Theater - Grass"

/area/holodeck/theater/lava
	name = "Theater - Lava"

/area/holodeck/theater/alien
	name = "Theater - Alien"

/area/holodeck/theater/asteroid
	name = "Theater - Asteroid"

/area/holodeck/theater/plate_stairs
	name = "Theater - Plating Stairs"

/area/holodeck/theater/caution
	name = "Theater - Caution Stripes"

/area/holodeck/theater/ai
	name = "Theater - AI"

/area/holodeck/theater/malfai
	name = "Theater - Malfunctioning AI"

/area/holodeck/theater/bluecheckers
	name = "Theater - Blue Checker Tile"

/area/holodeck/theater/greycheckers
	name = "Theater - Grey Checker Tile"

/area/holodeck/theater/redcheckers
	name = "Theater - Red Checker Tile"

/area/holodeck/theater/carpet
	name = "Theater - Carpet"

/area/holodeck/theater/sslogo
	name = "Theater - Station Logo"

/area/holodeck/theater/sovietlogo
	name = "Theater - Derelict Logo"

/area/holodeck/theater/sovietstairs
	name = "Theater - Syndicate Stairway"

/area/holodeck/theater/cargo
	name = "Theater - Cargo Loading"

/area/holodeck/theater/burnt
	name = "Theater - Burnt Tile"

/area/holodeck/theater/wood
	name = "Theater - Wood Floor"

/area/holodeck/theater/solars
	name = "Theater - Solars"

/area/holodeck/theater/space
	name = "Theater - Space"

/area/holodeck/theater/party
	name = "Theater - Dance Party"
	party = 1

/area/holodeck/theater/hyperspace
	name = "Theater - Hyperspace"