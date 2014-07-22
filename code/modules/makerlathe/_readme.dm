/*
	Note from the coder

	Makerlathe code is more or less complete, but I am running out of time because I am going to be moving and
	starting a job right soon
*/
/*
	Makerlathes and item cost
	-------------------------

	Every item has a list called maker_cost.  To simplify matters, this may also be a params string (url encoding):
	maker_cost = list("iron" = 1,"glass" = 1) or
	maker_cost = "iron=1;glass=1"

	If that list is anything but null, it may be recycled or built by makerlathes.
	Entries in this list may be one of two types:
		/obj/item/weapon/stock_part/[subtype] = [amount required], or
		"reagent_id" = [amount_required], or in some cases,
		"special_string" = [amount] (usually "power" or "time")

	When this item is recycled, all positive amounts in the list will be added to the lathe.
	Negative, zero, or null amounts will be ignored.
	Additionally, any reagents will be sucked out.  Reagents that the maker cannot use are discarded or passed to the overflow bucket.

	When the item is constructed, all positive or negative amounts will be taken from the lathe.
	That is to say, if you specify a negative amount, it will be used in construction but not returned by being recycled.
	Zero amounts are required but not deducted from the maker's stocks.

	The special "reagents" that can be added (power and time) alter the construction of the item.
	Time cost is normally calculated based on the sum total of the resources used; more resources equals more time.
	Power cost adds extra drain to the APC network when it is constructed; this normally equals the time cost.
	Power cost is not checked beforehand, so you can create an item with enormous power drain that empties the APC battery.

	Null amounts are special, and indicate that the item has optional reagents (fire extinguisher water, etc).
	If the object is constructed and the optional reagents are missing, they will be missing from the completed item.
	Currently, stock parts cannot have null amounts, for the reason below.

	Currently, there are no item procs for handling stock parts or altering the item depending on reagents.
	The cost list is simply used to create or recycle items without any particular logic code behind it.
	It would be nice to add, for example, conversion code that makes items better when better stock parts are used,
	but I do not currently wish to spend even more time on yet another system.

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
	The two product lists allow you to specify submenus.  There is also a default menu, which can be renamed.

	Any text item in the product lists will be treated as the start of a new menu:
		list(main_item_1, main_item_2,
			"menu 1", menu1_item_1, menu1_item_2,
			"menu 2", menu2_item_1, menu2_item_2)
	where each item is a typepath.
	Items preceeding the first text string go into the default menu.  The name of this menu is determined by the main_menu_name var.
	If the main_menu_name var is null, the main menu will be hidden, making these items inaccessible.
	In the preceeding example, main_item_1 and main_item_2 go into the main menu, etc.

	You can modify these entries in two ways:
		list(item_with_name_addendum = " text to add to the name",
			item_with_modified_cost = list(reagent=value, ...)
		)
	In the first example, the given string is added to the display name in the recipes list.
	In the second example, the maker_cost list is *replaced entirely* by the given list.

	The researchable list has a different syntax:
		list(path_to_item = "menu1", path_to_item2 = "menu2")
	...where every item path has an associated menu entry.  Unlike the product lists, this is not parsed when the maker is created,
	but is instead checked when research is synched.

	When a researchable item is unlocked, it will be put into the specified menu.  If no menu is specified, the main menu is used.

	Junk items cannot be intentionally built and have no associated menu entry.
*/