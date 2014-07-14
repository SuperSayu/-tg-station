
/obj/machinery/maker/engine
	name = "engilathe"
	desc = "Produces tools for engineering staff."
	board_type = /obj/item/weapon/circuitboard/maker/engine

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
					"Tanks", /obj/item/weapon/tank/emergency_oxygen/engi,
					"Tools", /obj/item/weapon/rcd,
					"Uniforms", /obj/item/clothing/under/sundress, /obj/item/clothing/under/shorts/black
				)
	researchable = list(/obj/item/device/aicard = "Electronics", /obj/item/device/paicard = "Electronics",
					/obj/item/clothing/mask/gas/welding = "Safety", /obj/item/clothing/shoes/magboots = "Safety",
					/obj/item/weapon/storage/part_replacer = "Tools", /obj/item/device/gps = "Tools", /obj/item/device/lightreplacer = "Tools",
					/obj/item/weapon/stock_parts/cell/high = null, /obj/item/weapon/stock_parts/cell/super = null, /obj/item/weapon/stock_parts/cell/hyper = null)

	junk_recipes = list(/obj/item/weapon/ore = list("iron" = 200), /obj/item/weapon/shard = list("glass" = 200), /obj/item/weapon/wirerod = list("iron" = 350), /obj/item/weapon/kitchen/utensil/fork = list("iron" = 600))
	recycleable = list("iron","glass","water","fuel","cloth","oxygen")

/obj/machinery/maker/biogen
	name = "biogenerator"
	desc = "Recycles biological waste."

	std_products = list()
	hack_products = list()
	researchable = list()
	junk_recipes = list()
	recycleable = list()