
/obj/machinery/maker/engine
	name = "engilathe"
	desc = "Produces tools for engineering staff."
	board_type = /obj/item/weapon/circuitboard/maker/engine

	main_menu_name = "Utility"
	std_products = list( /obj/item/device/flashlight, /obj/item/weapon/light/bulb, /obj/item/weapon/light/tube, /obj/item/weapon/table_parts, /obj/item/weapon/rack_parts, /obj/item/weapon/stock_parts/cell, /obj/item/weapon/rcd_ammo,
					"Cables", /obj/item/stack/cable_coil = "Red", /obj/item/stack/cable_coil/blue = "Blue", /obj/item/stack/cable_coil/cyan = "Cyan", /obj/item/stack/cable_coil/green = "Green", /obj/item/stack/cable_coil/orange = "Orange", /obj/item/stack/cable_coil/pink = "Pink", /obj/item/stack/cable_coil/white = "White", /obj/item/stack/cable_coil/yellow = "Yellow",
					"Electronics", /obj/item/weapon/airlock_electronics, /obj/item/weapon/airalarm_electronics, /obj/item/weapon/firealarm_electronics, /obj/item/weapon/module/power_control,
					"Frames", /obj/item/newscaster_frame, /obj/item/alarm_frame, /obj/item/apc_frame, /obj/item/firealarm_frame, /obj/item/weapon/camera_assembly, /obj/item/light_fixture_frame, /obj/item/light_fixture_frame/small, /obj/item/weapon/storage/toolbox, /obj/item/weapon/storage/firstaid,
					"Safety", /obj/item/weapon/extinguisher, /obj/item/clothing/head/welding, /obj/item/clothing/suit/hazardvest,
					"Tanks", /obj/item/weapon/tank/oxygen = "Blue",/obj/item/weapon/tank/oxygen/red = "Red", /obj/item/weapon/tank/oxygen/yellow = "Yellow", /obj/item/weapon/tank/emergency_oxygen, /obj/item/weapon/tank/plasma,
					"Tools", /obj/item/weapon/crowbar, /obj/item/weapon/weldingtool, /obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters, /obj/item/weapon/wrench, /obj/item/device/multitool, /obj/item/device/t_scanner, /obj/item/device/analyzer,
					"Uniforms", /obj/item/clothing/under/rank/engineer, /obj/item/clothing/under/rank/atmospheric_technician
				)
	hack_products = list( /obj/item/toy/spinningtoy,
					"Safety", /obj/item/clothing/glasses/welding, /obj/item/bodybag,
					"Tanks", /obj/item/weapon/tank/emergency_oxygen/engi, /obj/item/weapon/tank/jetpack/carbondioxide,
					"Tools", /obj/item/weapon/rcd,
					"Uniforms", /obj/item/clothing/under/sundress, /obj/item/clothing/under/shorts/black
				)
	researchable = list(/obj/item/device/aicard = "Electronics", /obj/item/device/paicard = "Electronics",
					/obj/item/clothing/mask/gas/welding = "Safety", /obj/item/clothing/shoes/magboots = "Safety",
					/obj/item/weapon/storage/part_replacer = "Tools", /obj/item/device/gps = "Tools", /obj/item/device/lightreplacer = "Tools",
					/obj/item/weapon/stock_parts/cell/high = null, /obj/item/weapon/stock_parts/cell/super = null, /obj/item/weapon/stock_parts/cell/hyper = null)

	junk_recipes = list(/obj/item/weapon/ore = list("iron" = 200), /obj/item/weapon/shard = list("glass" = 200), /obj/item/weapon/wirerod = list("iron" = 350), /obj/item/weapon/kitchen/utensil/fork = list("iron" = 600))
	recycleable = list("iron","glass","water","fuel","cloth","oxygen","n2o","co2")

/obj/machinery/maker/biolathe
	name = "biogenerator"
	desc = "Recycles biological waste."
	icon = 'icons/obj/biogenerator.dmi'
	icon_state = "biogen-empty"
	icon_base = "biogen-empty"
	icon_open = "biogen-empty"
	build_anim = "biogen-work"
	board_type = null

	main_menu_name = "Convert"

	// For reagent conversion, the cost list is mandatory.
	//If you add a null= or output=, you can set the output quantity, default 50
	std_products = list( /datum/reagent/plantnutriment/eznutriment = list("nutriment" = 50, "output" = 60), /datum/reagent/plantnutriment/left4zednutriment = list("nutriment" = 40, "milk" = 10, "output" = 60), /datum/reagent/plantnutriment/robustharvestnutriment = list("nutriment" = 30, "cream" = 20, "output" = 60),
					"Tools", /obj/item/weapon/minihoe, /obj/item/weapon/hatchet, /obj/item/weapon/shovel,
					"Cardboard", /datum/reagent/nutriment/cardboard = list("nutriment" = 50, "output" = 2000), /obj/item/weapon/storage/box, /obj/item/weapon/storage/fancy/rollingpapers, /obj/item/weapon/paper, /obj/item/weapon/folder, /obj/item/weapon/packageWrap, /obj/item/weapon/storage/photo_album,
					"Food", /datum/reagent/milk = list("nutriment" = 100), /datum/reagent/cream = list("milk" = 50, "output" = 25), /obj/item/weapon/reagent_containers/food/snacks/meat,
					"Leather", /datum/reagent/leather = list("nutriment" = 500, "output"=1000), /obj/item/clothing/gloves/botanic_leather, /obj/item/weapon/storage/belt/utility, /obj/item/weapon/storage/belt/medical, /obj/item/weapon/storage/belt/janitor, /obj/item/weapon/storage/bag/books, /obj/item/weapon/storage/bag/ore, /obj/item/weapon/storage/bag/plants, /obj/item/weapon/storage/backpack/satchel, /obj/item/weapon/storage/wallet,
					"Cloth", /datum/reagent/cloth = list("nutriment" = 500, "output" = 1000), /datum/reagent/cloth/carpet = list("cloth" = 1000, "output" = 2000), /obj/item/weapon/storage/backpack, /obj/item/clothing/under/rank/hydroponics, /obj/item/clothing/under/rank/chef, /obj/item/clothing/under/rank/bartender, /obj/item/clothing/under/rank/librarian, /obj/item/clothing/under/rank/chaplain
				)
	hack_products = list(
					/datum/reagent/toxin/mutagen = list("nutriment" = 90, "radium" = 10, "output" = 10),
					"Tools", /obj/item/weapon/scythe, /obj/item/weapon/stock_parts/cell/potato, /obj/item/weapon/soap,
					"Leather", /obj/item/clothing/glasses/eyepatch
				)
	researchable = list(/obj/item/weapon/gun/energy/floragun = null, /obj/item/device/lightreplacer = "Tools")
	junk_recipes = list(/obj/item/weapon/reagent_containers/food/snacks/badrecipe, /obj/item/weapon/reagent_containers/food/snacks/candy_corn)
	recycleable = list("iron", "glass", "radium", "nutriment", "cardboard", "milk", "cream", "leather", "cloth", "eznutriment", "left4zednutriment", "robustharvestnutriment")


/obj/machinery/maker/medilathe
	name = "medilathe" // I am sorry
	desc = "Creates and recycles various medical tools and supplies."
	icon = 'icons/obj/biogenerator.dmi'
	icon_state = "biogen-empty"
	icon_base = "biogen-empty"
	icon_open = "biogen-empty"
	build_anim = "biogen-work"
	board_type = null

	std_products = list(
					"chemistry", /obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/beaker/large,/obj/item/weapon/reagent_containers/syringe,
								/obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/reagent_containers/dropper, /obj/item/weapon/reagent_containers/spray,
					"surgery", /obj/item/weapon/scalpel, /obj/item/weapon/circular_saw, /obj/item/weapon/surgicaldrill, /obj/item/weapon/retractor, /obj/item/weapon/cautery, /obj/item/weapon/hemostat,
					"clothing", /obj/item/clothing/under/rank/medical, /obj/item/clothing/under/rank/nursesuit,
								/obj/item/clothing/under/rank/medical/blue = "Blue", /obj/item/clothing/under/rank/medical/green = "Green",/obj/item/clothing/under/rank/medical/purple = "Purple",
								/obj/item/clothing/under/rank/chemist,/obj/item/clothing/under/rank/geneticist,/obj/item/clothing/under/rank/virologist,
								/obj/item/clothing/head/bio_hood/general,/obj/item/clothing/suit/bio_suit/general,
					"convert", /datum/reagent/sterilizine = list("cleaner" = 50, "output" = 25)
					)
	hack_products = list()
	researchable = list()
	junk_recipes = list()
	recycleable = list("iron","glass","cloth","plastic","cleaner","sterilizine")