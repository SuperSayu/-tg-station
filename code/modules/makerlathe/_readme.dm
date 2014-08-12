/*
	Note from the coder

	Makerlathe code is more or less complete, but I am running out of time because I am going to be moving and
	starting a job right soon.  Something like this has been a long time in coming, and I am sorry that I have
	to rush through finishing it.
*/

/*
	obj/item/maker_cost
		1) "iron=1;glass=1" - see makertext2list()
		2) list("iron"=1,"glass"=1)
		3) list(iron=1,glass=1) - special byond list() syntax

	in general, A=B where
		A:
			/obj/item/weapon/stock_part/[subtype] (typepath, not string)
			"reagent_id"
			"power"
			"time"
			"output" - for reagent conversions only
		B:
			null: fill reagent
			0: required but not used
			>0: Required in construction, regained when recycled
			<0: Required in construction, not recycled

	Note that at compile time you cannot use form 1 with defines or constants, e.g.
	/obj/item/maker_cost="iron=[NORMAL_IRON_AMT]" // compile error

	Fill reagents usually go into the reagent list.  Anything listed as a fill reagent
	will be removed from the item if present unless the maker has enough reagents to add it.
*/

/*
	Maker item procs
	----------------

	obj/item/determine_cost()
		This exists mostly to convert legacy item costs (m_amt, g_amt, or mech fab lists) to maker lists.

	obj/item/get_maker_fill(product_datum)
		For objects such as fire extinguishers, welding tools, and air tanks.
		These, when spawned, have "contents"--water, welding fuel, or various atmos gasses.
		The maker lathe defaults to spitting these out without any fill to them, but if the
		maker can handle that reagent, you can spit the item out filled.
		Even if it can't, it adds a "Fill with [name]" to the construction list, which may
		be helpful to players.

	obj/item/maker_disassemble(maker_machine)
		Handles the actual recycling of the good.
		This is important for a few items that should be handled oddly, such as air tanks and stacks.

	obj/item/maker_build(fill_list)
		Handles upgrading or filling the item based on what is actually used to construct it.
		If fill reagents are specified (Fill fire extinguisher with water), you may be passed a
		list to this function ("water" = 50), which you should use to alter the reagent level
		or other parameters of the object.

		Additionally, makerlathes can handle stock parts; if a stock part is used in the creation of
		this item, you may want to check its quality and upgrade the item appropriately.

		If you return a different item or list of items from this function, the maker will
		assume that this item / these items are the proper build result.  In general, you should
		return src from this function.
*/

/*
	Makerlathe Templates
	--------------------

	Sprites aside, creating a new makerlathe essentially requires thinking carefully about
	what you want it to do and filling out a bunch of lists appropriately.

	There are two product lists:
	*	std_products - always available (research items added here)
	*	hack_products - become available when hacked (disk items added here)

	There are two special product lists:
	*	researchable - items that can be downloaded from the R&D servers
	*	junk_recipes - items that may be created if the makerlathe malfunctions

	And perhaps most importantly, there are the two acceptable types lists.
	*	stock_parts - Either an empty list, or null.  Unless this is null, items with stock parts can be recycled and built.
	*	recycleable - Contains a list of reagents that can be built with, recycled, and stored.

	Additionally, there are a few customization options:
	*	starting_reagents - Reagent IDs in this list will be added for map items when the game loads.
	*	beaker_type - if set to a beaker path, a beaker of that type will be added to the machine in its overflow slot.
*/

/*
	Makerlathe Template Menus
	-------------------------

	/obj/machinery/maker/std_products, /obj/machinery/maker/hack_products
		list( item | menu, item | menu, ... )
	where
		item:
			/obj/item/[subtype]
			/obj/item/[subtype] = "appended text" (eg, "Red" -> Cable Coils (Red))
			/obj/item/[subtype] = modified_cost_list
			/datum/reagent/[subtype] = cost_list
		menu:
			"menu_name"

	Items that occur before the first menu are put in the default menu.

	---

	/obj/machinery/maker/researchable
		list( item | menu, ...)
	where
		item:
			/obj/item/[subtype]
		menu:
			"menu_name"

	The item subtype must be researchable through some means (a design datum must be created for it).  If no menu is specified, the default menu is used.

	---

	/obj/machinery/maker/junk_recipes
		list( item, ...)
	where
		item:
			/obj/item/[subtype]
			/obj/item/[subtype] = modified_cost_list

	Junk items cannot be intentionally built and have no associated menu entry.
*/