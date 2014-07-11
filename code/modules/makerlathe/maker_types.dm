
/obj/machinery/maker/engine
	name = "engilathe"
	desc = "Produces tools for engineering staff."
	board_type = /obj/item/weapon/circuitboard/maker/engine

	std_products = list( /obj/item/device/flashlight, /obj/item/weapon/light/bulb, /obj/item/weapon/light/tube, /obj/item/weapon/table_parts, /obj/item/weapon/rack_parts, /obj/item/weapon/stock_parts/cell,
					"electronics", /obj/item/weapon/airlock_electronics, /obj/item/weapon/airalarm_electronics, /obj/item/weapon/firealarm_electronics,
					"safety", /obj/item/weapon/extinguisher, /obj/item/clothing/head/welding,
					"tools", /obj/item/weapon/crowbar, /obj/item/weapon/weldingtool, /obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters, /obj/item/weapon/wrench, /obj/item/device/multitool, /obj/item/device/t_scanner, /obj/item/device/analyzer,
					"frames", /obj/item/newscaster_frame, /obj/item/alarm_frame, /obj/item/apc_frame, /obj/item/firealarm_frame, /obj/item/weapon/storage/toolbox, /obj/item/weapon/storage/firstaid
				)
	hack_products = list(
				)
	researchable = list(/obj/item/device/aicard = "electronics", /obj/item/device/paicard = "electronics",
					/obj/item/clothing/mask/gas/welding = "safety", /obj/item/clothing/shoes/magboots = "safety",
					/obj/item/weapon/storage/part_replacer = "tools", /obj/item/device/gps = "tools", /obj/item/device/lightreplacer = "tools",
					/obj/item/weapon/stock_parts/cell/high = null, /obj/item/weapon/stock_parts/cell/super = null, /obj/item/weapon/stock_parts/cell/hyper = null)

	junk_recipes = list(/obj/item/weapon/ore = list("iron" = 200), /obj/item/weapon/shard = list("glass" = 200), /obj/item/weapon/wirerod = list("iron" = 350))
	recycleable = list("iron","glass")

/obj/machinery/maker/biogen
	name = "biogenerator"
	desc = "Recycles biological waste."

	std_products = list()
	hack_products = list()
	researchable = list()
	junk_recipes = list()
	recycleable = list()