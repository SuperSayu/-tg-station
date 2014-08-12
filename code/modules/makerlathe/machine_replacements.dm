/*
	These are drop-in replacements for the existing devices.
	They are meant to ease the transition but honestly, you should
	consider changing things around.
*/

/obj/item/weapon/circuitboard/maker/autolathe
	name = "circuit board (autolathe)"
	build_path = /obj/machinery/maker/autolathe

/obj/machinery/maker/autolathe
	name = "autolathe"
	board_type = /obj/item/weapon/circuitboard/maker/autolathe // allows disassembly
	// Fortunately the standard icons for the makerlathe are autolathe icons
	insert_anim(var/obj/item/I)
		var/anim = "autolathe_o"
		switch(I.type) // this could be done better
			if(/obj/item/stack/sheet/glass, /obj/item/stack/sheet/rglass)
				anim = "autolathe_r"
		flick(anim,src)
		sleep(10)

	main_menu_name = "Common"
	std_products = list(
		/obj/item/stack/rods,/obj/item/weapon/light/tube, /obj/item/weapon/light/bulb, /obj/item/weapon/rcd_ammo,
		"tools", /obj/item/weapon/crowbar, /obj/item/device/multitool, /obj/item/weapon/weldingtool, /obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters, /obj/item/weapon/wrench,
		"utilities", /obj/item/weapon/reagent_containers/glass/bucket, /obj/item/device/flashlight, /obj/item/device/analyzer, /obj/item/device/t_scanner, /obj/item/device/taperecorder/empty, /obj/item/device/tape, /obj/item/weapon/kitchenknife,
		"safety", /obj/item/weapon/extinguisher, /obj/item/clothing/head/welding, /obj/item/device/radio/headset, /obj/item/device/radio/off, /obj/item/weapon/camera_assembly,
		"parts", /obj/item/newscaster_frame, /obj/item/weapon/stock_parts/console_screen, /obj/item/weapon/airlock_electronics, /obj/item/weapon/airalarm_electronics, /obj/item/weapon/firealarm_electronics,
				/obj/item/device/assembly/igniter, /obj/item/device/assembly/signaler, /obj/item/device/assembly/infra, /obj/item/device/assembly/timer, /obj/item/device/assembly/voice, /obj/item/device/assembly/prox_sensor,
		"medical", /obj/item/weapon/scalpel, /obj/item/weapon/circular_saw, /obj/item/weapon/surgicaldrill, /obj/item/weapon/retractor, /obj/item/weapon/cautery, /obj/item/weapon/hemostat,
					/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/beaker/large,/obj/item/weapon/reagent_containers/syringe,
		"ammunition", /obj/item/ammo_casing/shotgun/beanbag, /obj/item/ammo_box/c38
		)
	hack_products = list(
		"tools", /obj/item/weapon/rcd, /obj/item/weapon/weldingtool/largetank,
		"safety", /obj/item/weapon/flamethrower/full, /obj/item/device/radio/electropack, /obj/item/weapon/handcuffs,
		"ammunition",  /obj/item/ammo_box/a357, /obj/item/ammo_casing/shotgun, /obj/item/ammo_casing/shotgun/buckshot, /obj/item/ammo_casing/shotgun/dart, /obj/item/ammo_casing/shotgun/incendiary
		)

	stock_parts = list() // enabled but not used
	researchable = null // disabled
	queue = null // disabled
	junk_recipes = list(/obj/item/weapon/ore = list("iron" = 200), /obj/item/weapon/shard = list("glass" = 200), /obj/item/weapon/wirerod = list("iron" = 350), /obj/item/weapon/kitchen/utensil/fork = list("iron" = 600))
	recycleable = list("iron","glass","water","fuel","cardboard")

// -----------------------------------------------------------------------------------

/obj/item/weapon/circuitboard/maker/biogenerator
	name = "circuit board (biogenerator)"
	build_path = /obj/machinery/maker/biogenerator

/obj/machinery/maker/biogenerator
	name = "biogenerator"
	board_type = /obj/item/weapon/circuitboard/maker/biogenerator

	icon = 'icons/obj/biogenerator.dmi'
	icon_state = "biogen-stand"
	icon_base = "biogen-stand"
	icon_open = "biogen-stand" // no open sprite
	build_anim = "biogen-work"
	default_insert_anim = null // no insert sprite

	starting_reagents = list("glass" = 2000) // for bottling things

	main_menu_name = null // flat list
	std_products = list(
		"Nutrients", /datum/reagent/plantnutriment/eznutriment = list("nutriment" = 50, "output" = 60), /datum/reagent/plantnutriment/left4zednutriment = list("nutriment" = 40, "milk" = 10, "output" = 60), /datum/reagent/plantnutriment/robustharvestnutriment = list("nutriment" = 30, "cream" = 20, "output" = 60),
		"Food", /datum/reagent/milk = list("nutriment" = 50, "output" = 25), /datum/reagent/cream = list("milk" = 50, "output" = 25), /obj/item/weapon/reagent_containers/food/snacks/monkeycube,
		"Leather", /datum/reagent/leather = list("nutriment" = 100, "output"=1000), /obj/item/clothing/gloves/botanic_leather, /obj/item/weapon/storage/wallet, /obj/item/weapon/storage/bag/plants, /obj/item/weapon/storage/bag/books, /obj/item/weapon/storage/bag/ore, /obj/item/weapon/storage/belt, /obj/item/weapon/storage/backpack/satchel
		)
	hack_products = list() // old biogen has no hacked list, this is a replacement without upgrades
	researchable = null // disabled
	queue = null		// disabled
	stock_parts = null	// disabled - should be unneeded here
	junk_recipes = list(/obj/item/weapon/reagent_containers/food/snacks/badrecipe = list("nutriment" = 100))
	recycleable = list("glass","nutriment","leather","eznutriment", "left4zednutriment", "robustharvestnutriment","milk","cream", "radium","sacid") // glass to bottle reagents

// -----------------------------------------------------------------------------------

/obj/item/weapon/circuitboard/maker/circuit
	name = "circuit board (circuit printer)"
	build_path = /obj/machinery/maker/circuit

/obj/machinery/maker/circuit
	name = "circuit printer"
	desc = "Builds complicated electronic circuits."
	board_type = /obj/item/weapon/circuitboard/maker/circuit

	icon = 'icons/obj/machines/research.dmi'
	icon_state = "circuit_imprinter"
	icon_base = "circuit_imprinter"
	icon_open = "circuit_imprinter" // no open sprite
	build_anim = null				// no build sprite
	default_insert_anim = null		// no insert sprite

	main_menu_name = null
	std_products = list(
					"Games", /obj/item/weapon/circuitboard/arcade/battle, /obj/item/weapon/circuitboard/arcade/orion_trail, /obj/item/weapon/circuitboard/slot_machine,
					"Domestic", /obj/item/weapon/circuitboard/hydroponics, /obj/item/weapon/circuitboard/microwave
				)

	hack_products = list()
	researchable = list(
					"Domestic",
					/obj/item/weapon/circuitboard/communications, /obj/item/weapon/circuitboard/card,
					/obj/item/weapon/circuitboard/ordercomp, /obj/item/weapon/circuitboard/supplycomp, /obj/item/weapon/circuitboard/mining,
					/obj/item/weapon/circuitboard/vendor, /obj/item/weapon/circuitboard/maker/biogenerator, /obj/item/weapon/circuitboard/maker/autolathe,

					"Telecomms",
					/obj/item/weapon/circuitboard/comm_monitor, /obj/item/weapon/circuitboard/comm_server, /obj/item/weapon/circuitboard/message_monitor,
					/obj/item/weapon/circuitboard/comm_traffic, /obj/item/weapon/circuitboard/telecomms/receiver, /obj/item/weapon/circuitboard/telecomms/bus,
					/obj/item/weapon/circuitboard/telecomms/hub, /obj/item/weapon/circuitboard/telecomms/relay, /obj/item/weapon/circuitboard/telecomms/processor,
					/obj/item/weapon/circuitboard/telecomms/server, /obj/item/weapon/circuitboard/telecomms/broadcaster,

					"Security",
					/obj/item/weapon/circuitboard/security, /obj/item/weapon/circuitboard/secure_data, /obj/item/weapon/circuitboard/prisoner,

					"AI",
					/obj/item/weapon/circuitboard/aicore, /obj/item/weapon/circuitboard/aiupload, /obj/item/weapon/circuitboard/aifixer,
					/obj/item/weapon/circuitboard/cyborgrecharger, /obj/item/weapon/circuitboard/borgupload, /obj/item/weapon/circuitboard/robotics,
					/obj/item/weapon/aiModule/supplied/safeguard, /obj/item/weapon/aiModule/zeroth/oneHuman, /obj/item/weapon/aiModule/supplied/protectStation,
					/obj/item/weapon/aiModule/supplied/quarantine, /obj/item/weapon/aiModule/supplied/oxygen, /obj/item/weapon/aiModule/supplied/freeform,
					/obj/item/weapon/aiModule/reset, /obj/item/weapon/aiModule/reset/purge,
					/obj/item/weapon/aiModule/core/freeformcore, /obj/item/weapon/aiModule/core/full/asimov, /obj/item/weapon/aiModule/core/full/paladin,
					/obj/item/weapon/aiModule/core/full/tyrant, /obj/item/weapon/aiModule/core/full/corp, /obj/item/weapon/aiModule/core/full/custom,

					"Robotics",
					/obj/item/weapon/circuitboard/mech_bay_power_console, /obj/item/weapon/circuitboard/mecha_control, /obj/item/weapon/circuitboard/mech_recharger,
					/obj/item/weapon/circuitboard/mecha/ripley/main, /obj/item/weapon/circuitboard/mecha/ripley/peripherals,
					/obj/item/weapon/circuitboard/mecha/odysseus/main, /obj/item/weapon/circuitboard/mecha/odysseus/peripherals,
					/obj/item/weapon/circuitboard/mecha/gygax/main, /obj/item/weapon/circuitboard/mecha/gygax/peripherals, /obj/item/weapon/circuitboard/mecha/gygax/targeting,
					/obj/item/weapon/circuitboard/mecha/durand/main, /obj/item/weapon/circuitboard/mecha/durand/peripherals, /obj/item/weapon/circuitboard/mecha/durand/targeting,
					/obj/item/weapon/circuitboard/mecha/honker/main, /obj/item/weapon/circuitboard/mecha/honker/peripherals, /obj/item/weapon/circuitboard/mecha/honker/targeting,

					"Medical",
					/obj/item/weapon/circuitboard/med_data, /obj/item/weapon/circuitboard/operating, /obj/item/weapon/circuitboard/pandemic, /obj/item/weapon/circuitboard/crew,
					/obj/item/weapon/circuitboard/sleeper, /obj/item/weapon/circuitboard/cryo_tube, /obj/item/weapon/circuitboard/chem_dispenser,
					/obj/item/weapon/circuitboard/cloning, /obj/item/weapon/circuitboard/clonescanner, /obj/item/weapon/circuitboard/clonepod,/obj/item/weapon/circuitboard/scan_consolenew,

					"Research",
					/obj/item/weapon/circuitboard/teleporter, /obj/item/weapon/circuitboard/rdconsole, /obj/item/weapon/circuitboard/telesci_console, /obj/item/weapon/circuitboard/teleporter_station,
					/obj/item/weapon/circuitboard/teleporter_hub, /obj/item/weapon/circuitboard/telesci_pad, /obj/item/weapon/circuitboard/rdservercontrol, /obj/item/weapon/circuitboard/rdserver,
					/obj/item/weapon/circuitboard/destructive_analyzer, /obj/item/weapon/circuitboard/maker/circuit, /obj/item/weapon/circuitboard/maker/mech_fab,
					/obj/item/weapon/circuitboard/protolathe,  // <-- todo

					"Atmospherics",
					/obj/item/weapon/circuitboard/thermomachine, /obj/item/weapon/circuitboard/atmos_alert, /obj/item/weapon/circuitboard/air_management,

					"Power",
					/obj/item/weapon/circuitboard/pacman, /obj/item/weapon/circuitboard/pacman/super, /obj/item/weapon/circuitboard/pacman/mrs,
					/obj/item/weapon/circuitboard/powermonitor, /obj/item/weapon/circuitboard/solar_control, /obj/item/weapon/circuitboard/smes,
					/obj/item/weapon/circuitboard/turbine_computer, /obj/item/weapon/circuitboard/power_compressor, /obj/item/weapon/circuitboard/power_turbine
				) // you shoulda seen the other guy

	queue = null
	stock_parts = null
	junk_recipes = list( /obj/item/weapon/shard = list("glass" = 750, "sacid" = 150), /obj/item/weapon/ore = list("glass" = 1000, "sacid" = 150))
	recycleable = list("glass","sacid","diamond","gold") // apparently diamond and gold are used in AI upload boards

// -----------------------------------------------------------------------------------

/obj/item/weapon/circuitboard/maker/mech_fab
	name = "circuit board (exosuit fabricator)"
	build_path = /obj/machinery/maker/mech_fab

/obj/machinery/maker/mech_fab
	name = "exosuit fabricator"

	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	icon_base = "fab-idle"
	icon_open = "fab-o"
	build_anim = null // special
	default_insert_anim = null // special

	insert_anim(var/obj/item/S)
		var/anim = "fab-load-metal"
		switch(S.type)
			if(/obj/item/stack/sheet/glass, /obj/item/stack/sheet/rglass)
				anim = "fab-load-glass"
			if(/obj/item/stack/sheet/mineral/gold)
				anim = "fab-load-gold"
			if(/obj/item/stack/sheet/mineral/silver)
				anim = "fab-load-silver"
			if(/obj/item/stack/sheet/mineral/uranium)
				anim = "fab-load-uranium"
			if(/obj/item/stack/sheet/mineral/plasma)
				anim = "fab-load-plasma"
			if(/obj/item/stack/sheet/mineral/clown)
				anim = "fab-load-bananium"
			if(/obj/item/stack/sheet/mineral/diamond)
				anim = "fab-load-diamond"
		overlays += anim
		sleep(10)
		update_icon()

	update_icon()
		overlays.len = 0
		if((building || busy) && !stat)
			overlays += "fab-active"
	main_menu_name = "Robotics Equipment"
	std_products = list(
			// default menu
			/obj/item/weapon/stock_parts/cell, /obj/item/mecha_parts/mecha_tracking, /obj/item/borg/upgrade/reset, /obj/item/borg/upgrade/rename, /obj/item/borg/upgrade/restart,
			/obj/item/borg/upgrade/vtec, /obj/item/borg/upgrade/tasercooler, /obj/item/borg/upgrade/jetpack,

			"Cyborg",
			/obj/item/robot_parts/robot_suit, /obj/item/robot_parts/chest, /obj/item/robot_parts/head, /obj/item/robot_parts/l_arm,
			/obj/item/robot_parts/r_arm, /obj/item/robot_parts/l_leg, /obj/item/robot_parts/r_leg,

			"Ripley",
			/obj/item/mecha_parts/chassis/ripley, /obj/item/mecha_parts/part/ripley_torso, /obj/item/mecha_parts/part/ripley_left_arm,
			/obj/item/mecha_parts/part/ripley_right_arm, /obj/item/mecha_parts/part/ripley_left_leg, /obj/item/mecha_parts/part/ripley_right_leg,

			"Odysseus",
			/obj/item/mecha_parts/chassis/odysseus, /obj/item/mecha_parts/part/odysseus_torso, /obj/item/mecha_parts/part/odysseus_head,
			/obj/item/mecha_parts/part/odysseus_left_arm, /obj/item/mecha_parts/part/odysseus_right_arm, /obj/item/mecha_parts/part/odysseus_left_leg, /obj/item/mecha_parts/part/odysseus_right_leg,

			"Gygax",
			/obj/item/mecha_parts/chassis/gygax, /obj/item/mecha_parts/part/gygax_torso, /obj/item/mecha_parts/part/gygax_head, /obj/item/mecha_parts/part/gygax_left_arm,
			/obj/item/mecha_parts/part/gygax_right_arm, /obj/item/mecha_parts/part/gygax_left_leg, /obj/item/mecha_parts/part/gygax_right_leg, /obj/item/mecha_parts/part/gygax_armour,

			"Durand",
			/obj/item/mecha_parts/chassis/durand, /obj/item/mecha_parts/part/durand_torso, /obj/item/mecha_parts/part/durand_head, /obj/item/mecha_parts/part/durand_left_arm,
			/obj/item/mecha_parts/part/durand_right_arm, /obj/item/mecha_parts/part/durand_left_leg, /obj/item/mecha_parts/part/durand_right_leg, /obj/item/mecha_parts/part/durand_armour,

			"H.O.N.K.",
			/obj/item/mecha_parts/chassis/honker, /obj/item/mecha_parts/part/honker_torso, /obj/item/mecha_parts/part/honker_head, /obj/item/mecha_parts/part/honker_left_arm,
			/obj/item/mecha_parts/part/honker_right_arm, /obj/item/mecha_parts/part/honker_left_leg, /obj/item/mecha_parts/part/honker_right_leg,

			"Mech Equipment",
			/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp, /obj/item/mecha_parts/mecha_equipment/tool/drill, /obj/item/mecha_parts/mecha_equipment/tool/extinguisher,
			/obj/item/mecha_parts/mecha_equipment/tool/cable_layer, /obj/item/mecha_parts/mecha_equipment/tool/sleeper, /obj/item/mecha_parts/mecha_equipment/tool/syringe_gun,
			/obj/item/mecha_parts/chassis/firefighter, /obj/item/mecha_parts/mecha_equipment/generator, /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar,/obj/item/mecha_parts/mecha_equipment/weapon/honker
			// /obj/item/mecha_parts/mecha_equipment/jetpack, //TODO MECHA JETPACK SPRITE MISSING
		)
	hack_products = list() // todo probably move honkmech at least to the hacked list
	researchable = list(
			/obj/item/device/flash/synthetic, /obj/item/weapon/stock_parts/cell/high, /obj/item/weapon/stock_parts/cell/super, /obj/item/weapon/stock_parts/cell/hyper,
			"Cyborg",
			/obj/item/device/mmi, /obj/item/device/mmi/radio_enabled, /obj/item/borg/upgrade/syndicate,
			"Mech Equipment",
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine,
			/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion, /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
			/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang,
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang,
			/obj/item/mecha_parts/mecha_equipment/wormhole_generator, /obj/item/mecha_parts/mecha_equipment/teleporter, /obj/item/mecha_parts/mecha_equipment/tool/rcd, // 3 to a line!
			/obj/item/mecha_parts/mecha_equipment/gravcatapult, /obj/item/mecha_parts/mecha_equipment/repair_droid, /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay, // wow again
			/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster, /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster,
			/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill, /obj/item/mecha_parts/mecha_equipment/generator/nuclear,
		)
	junk_recipes = list(/obj/item/weapon/ore = list("iron" = 20000), /obj/item/weapon/shard = list("glass" = 2000), /obj/item/weapon/wirerod = list("iron" = 3500), /obj/item/weapon/kitchen/utensil/fork = list("iron" = 6000))

	queue = list() // enabled
	stock_parts = null // disabled - but you should add stock parts to the recipes for the various parts, this is a perfect place for it

	recycleable = list("iron","glass","gold","silver","bananium","diamond","plasma","uranium")

// -----------------------------------------------------------------------------------
/* incomplete
/obj/item/weapon/circuitboard/maker/protolathe
	name = "circuit board (protolathe)"
	build_path = /obj/machinery/maker/protolathe

/obj/machinery/maker/protolathe
	name = "protolathe"
	board_type = /obj/item/weapon/circuitboard/maker/protolathe
*/