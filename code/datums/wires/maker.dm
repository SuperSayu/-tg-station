var/const/
	MAKER_WIRE_IDSCAN = 1
	MAKER_WIRE_POWER = 2
	MAKER_WIRE_OVERDRIVE = 4
	MAKER_WIRE_JUNKER = 8
	MAKER_WIRE_HACKABLE = 16

/datum/wires/maker
	holder_type = /obj/machinery/maker
	wire_count = 5

/datum/wires/maker/GetInteractWindow()
	var/obj/machinery/maker/M = holder
	if(M.beaker)
		. = "There is <a href='?\ref[M];beaker'>\a [M.beaker]</a> in the overflow slot.<br>"
	else
		. = "The overflow slot does not have a beaker in it.<br>"
	if(M.jammed)
		. += "You can see <a href='?\ref[M];unjam'>\a [M.jammed]</a> stuck in the feed mechanism.<br>"
	. += ..()
	if(M.stat&NOPOWER)
		. += "<br>All the lights are off."
	else if(M.shorted || M.stat&BROKEN)
		. += "<br>All the lights are flickering madly."
	else
		. += {"<br>
			The authentication light is [M.id_scrambled?"flickering":"on"].<br>
			The regulator light is [M.junktech?"blinking red":(M.overdrive?"flashing orange":"green")].<br>
			The dataport light is [M.board.hackable?"on":"off"].
		"}

/datum/wires/maker/Interact()
	var/obj/machinery/maker/M = holder
	if(M)
		M.updateUsrDialog()

/datum/wires/maker/Topic()
	var/obj/machinery/maker/M = holder
	if(M.shorted)
		if(M.shock(usr,66))
			return
	..()

/datum/wires/maker/UpdatePulsed(var/index)
	var/obj/machinery/maker/M = holder
	switch(index)
		if(MAKER_WIRE_IDSCAN)
			M.id_scrambled = pick(0,1,!M.id_scrambled)
		if(MAKER_WIRE_POWER)
			M.shorted = !M.shorted
			spawn(100)
				M.shorted = IsIndexCut(MAKER_WIRE_POWER)
		if(MAKER_WIRE_OVERDRIVE)
			M.shock(usr,100)
		if(MAKER_WIRE_JUNKER)
			M.junktech = !M.junktech
			M.last_multiplier_change = world.time
		if(MAKER_WIRE_HACKABLE)
			M.board.hackable = !M.board.hackable

/datum/wires/maker/UpdateCut(var/index, var/mended)
	var/obj/machinery/maker/M = holder
	switch(index)
		if(MAKER_WIRE_IDSCAN)
			M.id_scrambled = !mended
		if(MAKER_WIRE_POWER)
			M.shorted = !mended
		if(MAKER_WIRE_OVERDRIVE)
			M.overdrive = !mended
			M.last_multiplier_change = world.time
		if(MAKER_WIRE_JUNKER)
			M.junktech = !mended
			M.last_multiplier_change = world.time
			if(!mended) M.shock(usr)
		//if(MAKER_WIRE_HACKABLE)
			// nothing - pulse only
