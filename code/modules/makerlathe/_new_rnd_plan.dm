/*
	Once maker is committed there is little reason not to replace all of R&D.
	In particular, the R&D console is useless if you replace the protolathe and
	circuit printer in R&D.

	That said, you also do not need to replace them until you are ready.
	Makers can sync with R&D servers already, and most don't need to (yet).
	You don't need to replace the R&D machines, I just wanted to be sure that
	they were accounted for in the design so they COULD be replaced when ready.

	My thinking on its replacement would be that makers connect to servers through
	the powernet.  To do this you would need to promote maker machines to a subtype of
	/obj/machinery/power, possibly using parent_type since power/maker sounds weird.
	This allows maker machines to generate power for the station as a side effect.
	(I have often thought that the biogenerator should, you know, generate.)

	As part of this, new-R&D servers would want a second powernet that is only used
	to transfer data between servers.  You will probably want a console attached to
	that data transfer network to regulate the data transfer.  Consider this like
	the SMES: one link attached to a terminal, and a second linked under the machine.

	If you want to recreate the R&D console, I would have maker machines have a similar
	second connection on a terminal, and have the console connect to all makers on the
	powernet..  The way I designed maker machines it will actually be pretty easy to
	forward the UI to the console, while denying the interface when you interact with
	it normally, when a console is connected.  Doing it this way you could simply toggle
	between attached devices and use their native interfaces.

	As an aside, if you are going to do that, I suggest an addition to allow automated
	input and output akin to mining machines or the Sayucode programmable unloader:
	(https://github.com/SuperSayu/-tg-station/blob/sayustation/code/WorkInProgress/Sayu/programmable.dm)
	That is to say, an automation function that scans one square for recycleables and
	allows you to specify which neighboring square recieves the produced item.

	Combining automated inputs, queues, directed outputs, and stock parts as
	part of building other items allows you to make the assembly line from previous
	station versions a reality--build stock parts in a queue, ship them to a machine
	that makes the robot parts (perhaps made a subtype of stock parts, and why are they not?),
	which are then shipped to an assembler at the end of the line.  Granted, this takes
	enough of the work out of robotics that it seems silly, but only if it's properly set up,
	and you know how to use it...

	Additionally, again because stock parts can simply be required to build items,
	I suggest adding a lot more stock part types (frames, circuit boards, wires, etc).
	Adding the right infrastructure can do wonders to what becomes possible later on.
*/