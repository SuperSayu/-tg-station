/*
	DNA scanning computer (research type)
*/
/obj/machinery/computer/scan_consolenew
	name = "DNA Scanner Access Console"
	desc = "Scan DNA."
	icon = 'icons/obj/computer.dmi'
	icon_state = "scanner"

	default_prog = /datum/file/program/dnascanner


#define MAX_UIBLOCK 13
#define MAX_SEBLOCK 14

/datum/file/program/dnascanner
	name = "DNA Scanner and Radioisotope Enzyme Manipulator"
	var/uniblock = 1.0
	var/strucblock = 1.0
	var/subblock = 1.0
	var/unitarget = 1
	var/unitargethex = 1
	var/status = null
	var/radduration = 2.0
	var/radstrength = 1.0
	var/radacc = 1.0
	var/injectorready = 0	//Quick fix for issue 286 (screwdriver the screen twice to restore injector)	-Pete

	required_peripherals = list(/obj/item/part/computer/networking/proximity)

	var/obj/item/part/computer/networking/proximity/linker	= null
	var/obj/item/part/computer/storage/disk					= null
	var/obj/machinery/dna_scannernew/scanner				= null

	var/mode		= null
	var/present		= 0
	var/viable		= 0


	Topic(href,list/href_list)

		// current screen/function
		if("mode" in href_list)
			mode = text2num(href_list["mode"])
		// locks scanner door
		if("lock" in href_list)
			scanner.locked = !scanner.locked

		// inject good-juice
		if("rejuv" in href_list)
			rejuv()

		// expose to radiation, controlled otherwise
		if("pulse" in href_list)
			pulse(href_list["pulse"]) // ui, se, or nothing/null

		if("duration" in href_list)
			var/modifier = text2num(href_list["duration"])
			radduration	+= modifier
		if("strength" in href_list)
			var/modifier = text2num(href_list["strength"])
			radstrength += modifier

		if("uiblock" in href_list)
			uniblock	= text2num(href_list["uiblock"])
		if("seblock" in href_list)
			strucblock	= text2num(href_list["seblock"])
		if("block" in href_list)
			subblock	= text2num(href_list["block"])

		// save buffer to file
		if("save" in href_list)

		// load buffer from file
		if("load" in href_list)

		// store genetics to buffer
		if("store" in href_list)

		// inject genetics into occupant
		if("inject" in href_list)

		// generate dna injector
		if("generate" in href_list)

	return // putting this in there to visually mark the end of topic() while I do other things

	proc/menu()
		if(!present && (mode==1 || mode==2)) // require viable occupant
			mode = 0
		switch(mode)
			if(0) // MAIN MENU
				return main_menu()
			if(1)
				return ui_menu()
			if(2)
				return se_menu()
			if(3)
				return emitter_menu()
			if(4)
				return buffer_menu()
			// 5: file operations, probably

	// unified header with health data
	// option to show UI,UE,SE as plaintext
	proc/status_display(var/dna_summary = 0)
		var/mob/living/occupant = scanner.occupant
		var/status_html
		if(viable)
			status_html = "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [occupant.health]%;' class='progressFill good'></div></div><div class='statusValue'>[occupant.health]%</div></div>"
			status_html += "<div class='line'><div class='statusLabel'>Radiation Level:</div><div class='progressBar'><div style='width: [occupant.radiation]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.radiation]%</div></div>"
			if(ishuman(occupant))
				var/rejuvenators = round(occupant.reagents.get_reagent_amount("inaprovaline") / REJUVENATORS_MAX * 100)
				status_html += "<div class='line'><div class='statusLabel'>Rejuvenators:</div><div class='progressBar'><div style='width: [rejuvenators]%;' class='progressFill highlight'></div></div><div class='statusValue'>[human_occupant.reagents.get_reagent_amount("inaprovaline")] units</div></div>"

			if (dna_summary)
				status_html += "<div class='line'><div class='statusLabel'>Unique Enzymes :</div><div class='statusValue'><span class='highlight'>[uppertext(occupant.dna.unique_enzymes)]</span></div></div>"
				status_html += "<div class='line'><div class='statusLabel'>Unique Identifier:</div><div class='statusValue'><span class='highlight'>[occupant.dna.uni_identity]</span></div></div>"
				status_html += "<div class='line'><div class='statusLabel'>Structural Enzymes:</div><div class='statusValue'><span class='highlight'>[occupant.dna.struc_enzymes]</span></div></div>"

		var/occupant_status = "Scanner Unoccupied"
		if(present)
			if(!viable)
				occupant_status = "<span class='bad'>Invalid DNA structure</span>"
			else
				switch(occupant.stat) // obvious, see what their status is
					if(0)
						occupant_status = "<span class='good'>Conscious</span>"
					if(1)
						occupant_status = "<span class='average'>Unconscious</span>"
					else
						occupant_status = "<span class='bad'>DEAD</span>"

			occupant_status = "[occupant.name] => [occupant_status]<br />"
		var/dat = "<h3>Scanner Status</h3>[topic_link(src,"","Scan")]<div class='statusDisplay'>[occupant_status][status_html]</div>"
		if(present)
			dat += topic_link(src,"lock",locked?"Unlock Scanner":"Lock Scanner") + " " + topic_link(src,"rejuv","Inject Rejuvenators")
		else
			dat += "<span class='linkOff'>[locked?"Unlock Scanner":"Lock Scanner"]</span> <span class='linkOff'>Inject Rejuvenators</span>"
		return dat

	proc/main_menu()
		var/dat = status_display(dna_summary = 1)
		dat += "<br><br><h3>Main Menu</h3>"
		if(present)
			dat += topic_link(src,"mode=1","Modify Unique Identifier") + "<br>" + topic_link(src,"mode=2","Modify Structural Enzymes") + "<br><br>"
		else
			dat += "<span class='linkOff'>Modify Unique Identifier</span><br><span class='linkOff'>Modify Structural Enzymes</span><br><br>"
		dat += topic_link(src,"mode=3","Radiation Emitter Settings") + "<br><br>" + topic_link(src,"mode=4","Transfer Buffer")
		return dat

	interact()
		if(!popup)
			popup = new/datum/browser(usr, "\ref[computer]", "DNA Modifier Console", 520, 620) // Set up the popup browser window
			popup.add_stylesheet("scannernew", 'html/browser/scannernew.css')
			popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))

		// todo check everything goddamnit

		present = scanner.occupant && scanner.occupant.dna
		viable	= present && !(NOCLONE in occupant.mutations)

		popup.set_content(menu())

/obj/machinery/computer/scan_consolenew/Topic(href, href_list)

	src.temp_html = null
	var/temp_header_html = null
	var/temp_footer_html = null

	src.scanner_status_html = null // Scanner status is reset each update
	var/mob/living/occupant = src.connected.occupant
	var/viable_occupant = (occupant && occupant.dna && !(NOCLONE in occupant.mutations))
	var/mob/living/carbon/human/human_occupant = src.connected.occupant

	if (href_list["screen"]) // Passing a screen is only a request, we set current_screen here but it can be overridden below if necessary
		src.current_screen = href_list["screen"]

	if (!viable_occupant) // If there is no viable occupant only allow certain screens
		var/allowed_no_occupant_screens = list("mainmenu", "radsetmenu", "buffermenu") //These are the screens which will be allowed if there's no occupant
		if (!(src.current_screen in allowed_no_occupant_screens))
			href_list = new /list(0) // clear list of options
			src.current_screen = "mainmenu"


	if (!src.current_screen) // If no screen is set default to mainmenu
		src.current_screen = "mainmenu"


	if (!src.connected) //Is the scanner not connected?
		src.scanner_status_html = "<span class='bad'>ERROR: No DNA Scanner connected.</span>"
		src.current_screen = null // blank does not exist in the switch below, so no screen will be outputted
		src.updateUsrDialog()
		return

	usr.set_machine(src)
	if (href_list["locked"])
		if (src.connected.occupant)
			src.connected.locked = !( src.connected.locked )
	////////////////////////////////////////////////////////
	if (href_list["genpulse"])
		if(!viable_occupant)//Makes sure someone is in there (And valid) before trying anything
			src.temp_html = text("No viable occupant detected.")//More than anything, this just acts as a sanity check in case the option DOES appear for whatever reason
			//usr << browse(temp_html, "window=scannernew;size=550x650")
			//onclose(usr, "scannernew")
			popup.set_content(src.temp_html)
			popup.open()
		else

			src.temp_html = text("Working ... Please wait ([] Seconds)", src.radduration)
			popup.set_content(src.temp_html)
			popup.open()
			var/lock_state = src.connected.locked
			src.connected.locked = 1//lock it
			sleep(10*src.radduration)
			if (!src.connected.occupant)
				src.temp_html = null
				return null
			if (prob(95))
				if(prob(75))
					randmutb(src.connected.occupant)
				else
					randmuti(src.connected.occupant)
			else
				if(prob(95))
					randmutg(src.connected.occupant)
				else
					randmuti(src.connected.occupant)
			src.connected.occupant.radiation += ((src.radstrength*3)+src.radduration*3)
			src.connected.locked = lock_state
			src.temp_html = null
			dopage(src,"screen=radsetmenu")
	if (href_list["radleplus"])
		if(!viable_occupant)
			src.temp_html = text("No viable occupant detected.")
			popup.set_content(src.temp_html)
			popup.open()
		if (src.radduration < 20)
			src.radduration++
			src.radduration++
		dopage(src,"screen=radsetmenu")
	if (href_list["radleminus"])
		if(!viable_occupant)
			src.temp_html = text("No viable occupant detected.")
			popup.set_content(src.temp_html)
			popup.open()
		if (src.radduration > 2)
			src.radduration--
			src.radduration--
		dopage(src,"screen=radsetmenu")
	if (href_list["radinplus"])
		if (src.radstrength < 10)
			src.radstrength++
		dopage(src,"screen=radsetmenu")
	if (href_list["radinminus"])
		if (src.radstrength > 1)
			src.radstrength--
		dopage(src,"screen=radsetmenu")
	////////////////////////////////////////////////////////
	if (href_list["unimenuplus"])
		if (src.uniblock < 13)
			src.uniblock++
		else
			src.uniblock = 1
		dopage(src,"screen=unimenu")
	if (href_list["unimenuminus"])
		if (src.uniblock > 1)
			src.uniblock--
		else
			src.uniblock = 13
		dopage(src,"screen=unimenu")
	if (href_list["unimenusubplus"])
		if (src.subblock < 3)
			src.subblock++
		else
			src.subblock = 1
		dopage(src,"screen=unimenu")
	if (href_list["unimenusubminus"])
		if (src.subblock > 1)
			src.subblock--
		else
			src.subblock = 3
		dopage(src,"screen=unimenu")
	if (href_list["unimenutargetplus"])
		if (src.unitarget < 15)
			src.unitarget++
			src.unitargethex = src.unitarget
			switch(unitarget)
				if(10)
					src.unitargethex = "A"
				if(11)
					src.unitargethex = "B"
				if(12)
					src.unitargethex = "C"
				if(13)
					src.unitargethex = "D"
				if(14)
					src.unitargethex = "E"
				if(15)
					src.unitargethex = "F"
		else
			src.unitarget = 0
			src.unitargethex = 0
		dopage(src,"screen=unimenu")
	if (href_list["unimenutargetminus"])
		if (src.unitarget > 0)
			src.unitarget--
			src.unitargethex = src.unitarget
			switch(unitarget)
				if(10)
					src.unitargethex = "A"
				if(11)
					src.unitargethex = "B"
				if(12)
					src.unitargethex = "C"
				if(13)
					src.unitargethex = "D"
				if(14)
					src.unitargethex = "E"
		else
			src.unitarget = 15
			src.unitargethex = "F"
		dopage(src,"screen=unimenu")
	if (href_list["uimenuset"] && href_list["uimenusubset"]) // This chunk of code updates selected block / sub-block based on click
		var/menuset = text2num(href_list["uimenuset"])
		var/menusubset = text2num(href_list["uimenusubset"])
		if ((menuset <= 13) && (menuset >= 1))
			src.uniblock = menuset
		if ((menusubset <= 3) && (menusubset >= 1))
			src.subblock = menusubset
		dopage(src, "unimenu")
	if (href_list["unipulse"])
		if(src.connected.occupant)
			var/block
			var/newblock
			var/tstructure2
			block = getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),src.subblock,1)

			src.temp_html = text("Working ... Please wait ([] Seconds)", src.radduration)
			popup.set_content(src.temp_html)
			popup.open()
			var/lock_state = src.connected.locked
			src.connected.locked = 1//lock it
			sleep(10*src.radduration)
			if (!src.connected.occupant)
				src.temp_html = null
				return null
			///
			if (prob((80 + (src.radduration / 2))))
				block = miniscrambletarget(num2text(unitarget), src.radstrength, src.radduration)
				newblock = null
				if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),2,1) + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),3,1)
				if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),1,1) + block + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),3,1)
				if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),1,1) + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),2,1) + block
				tstructure2 = setblock(src.connected.occupant.dna.uni_identity, src.uniblock, newblock,3)
				src.connected.occupant.dna.uni_identity = tstructure2
				updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
				src.connected.occupant.radiation += (src.radstrength+src.radduration)
			else
				if	(prob(20+src.radstrength))
					randmutb(src.connected.occupant)
					domutcheck(src.connected.occupant,src.connected)
				else
					randmuti(src.connected.occupant)
					updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
				src.connected.occupant.radiation += ((src.radstrength*2)+src.radduration)
			src.connected.locked = lock_state
		dopage(src,"screen=unimenu")

	////////////////////////////////////////////////////////
	if (href_list["rejuv"])
		if(!viable_occupant)
			src.temp_html = text("No viable occupant detected.")
			popup.set_content(src.temp_html)
			popup.open()
		else
			if(human_occupant)
				if (human_occupant.reagents.get_reagent_amount("inaprovaline") < REJUVENATORS_MAX)
					if (human_occupant.reagents.get_reagent_amount("inaprovaline") < (REJUVENATORS_MAX - REJUVENATORS_INJECT))
						human_occupant.reagents.add_reagent("inaprovaline", REJUVENATORS_INJECT)
					else
						human_occupant.reagents.add_reagent("inaprovaline", round(REJUVENATORS_MAX - human_occupant.reagents.get_reagent_amount("inaprovaline")))
				//usr << text("Occupant now has [] units of rejuvenation in his/her bloodstream.", human_occupant.reagents.get_reagent_amount("inaprovaline"))

	////////////////////////////////////////////////////////
	if (href_list["strucmenuplus"])
		if (src.strucblock < 14)
			src.strucblock++
		else
			src.strucblock = 1
		dopage(src,"screen=strucmenu")
	if (href_list["strucmenuminus"])
		if (src.strucblock > 1)
			src.strucblock--
		else
			src.strucblock = 14
		dopage(src,"screen=strucmenu")
	if (href_list["strucmenusubplus"])
		if (src.subblock < 3)
			src.subblock++
		else
			src.subblock = 1
		dopage(src,"screen=strucmenu")
	if (href_list["strucmenusubminus"])
		if (src.subblock > 1)
			src.subblock--
		else
			src.subblock = 3
		dopage(src,"screen=strucmenu")
	if (href_list["semenuset"] && href_list["semenusubset"]) // This chunk of code updates selected block / sub-block based on click (se stands for strutural enzymes)
		var/menuset = text2num(href_list["semenuset"])
		var/menusubset = text2num(href_list["semenusubset"])
		if ((menuset <= 14) && (menuset >= 1))
			src.strucblock = menuset
		if ((menusubset <= 3) && (menusubset >= 1))
			src.subblock = menusubset
		dopage(src, "strucmenu")
	if (href_list["strucpulse"])
		var/block
		var/newblock
		var/tstructure2
		var/oldblock
		var/lock_state = src.connected.locked
		src.connected.locked = 1//lock it
		if (viable_occupant)
			block = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),src.subblock,1)

			src.temp_html = text("Working ... Please wait ([] Seconds)", src.radduration)
			popup.set_content(src.temp_html)
			popup.open()
			sleep(10*src.radduration)
		else
			src.temp_html = null
			return null
		///
		if(viable_occupant)
			if (prob((80 + (src.radduration / 2))))
				if ((src.strucblock != 2 || src.strucblock != 12 || src.strucblock != 8 || src.strucblock || 10) && prob (20))
					oldblock = src.strucblock
					block = miniscramble(block, src.radstrength, src.radduration)
					newblock = null
					if (src.strucblock > 1 && src.strucblock < 5)
						src.strucblock++
					else if (src.strucblock > 5 && src.strucblock < 14)
						src.strucblock--
					if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
					if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
					if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + block
					tstructure2 = setblock(src.connected.occupant.dna.struc_enzymes, src.strucblock, newblock,3)
					src.connected.occupant.dna.struc_enzymes = tstructure2
					domutcheck(src.connected.occupant,src.connected)
					src.connected.occupant.radiation += (src.radstrength+src.radduration)
					src.strucblock = oldblock
				else
				//
					block = miniscramble(block, src.radstrength, src.radduration)
					newblock = null
					if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
					if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
					if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + block
					tstructure2 = setblock(src.connected.occupant.dna.struc_enzymes, src.strucblock, newblock,3)
					src.connected.occupant.dna.struc_enzymes = tstructure2
					domutcheck(src.connected.occupant,src.connected)
					src.connected.occupant.radiation += (src.radstrength+src.radduration)
			else
				if	(prob(80-src.radduration))
					randmutb(src.connected.occupant)
					domutcheck(src.connected.occupant,src.connected)
				else
					randmuti(src.connected.occupant)
					updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
				src.connected.occupant.radiation += ((src.radstrength*2)+src.radduration)
		src.connected.locked = lock_state
		///
		dopage(src,"screen=strucmenu")

	////////////////////////////////////////////////////////
	if (href_list["b1addui"])
		if(src.connected.occupant && src.connected.occupant.dna)
			src.buffer1iue = 0
			src.buffer1 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer1owner = src.connected.occupant.name
			else
				src.buffer1owner = src.connected.occupant.real_name
			src.buffer1label = "Unique Identifier"
			src.buffer1type = "ui"
			dopage(src,"screen=buffermenu")
	if (href_list["b1adduiue"])
		if(src.connected.occupant && src.connected.occupant.dna)
			src.buffer1 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer1owner = src.connected.occupant.name
			else
				src.buffer1owner = src.connected.occupant.real_name
			src.buffer1label = "Unique Identifier & Unique Enzymes"
			src.buffer1type = "ui"
			src.buffer1iue = 1
			dopage(src,"screen=buffermenu")
	if (href_list["b2adduiue"])
		if(src.connected.occupant && src.connected.occupant.dna)
			src.buffer2 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer2owner = src.connected.occupant.name
			else
				src.buffer2owner = src.connected.occupant.real_name
			src.buffer2label = "Unique Identifier & Unique Enzymes"
			src.buffer2type = "ui"
			src.buffer2iue = 1
			dopage(src,"screen=buffermenu")
	if (href_list["b3adduiue"])
		if(src.connected.occupant && src.connected.occupant.dna)
			src.buffer3 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer3owner = src.connected.occupant.name
			else
				src.buffer3owner = src.connected.occupant.real_name
			src.buffer3label = "Unique Identifier & Unique Enzymes"
			src.buffer3type = "ui"
			src.buffer3iue = 1
			dopage(src,"screen=buffermenu")
	if (href_list["b2addui"])
		if(src.connected.occupant && src.connected.occupant.dna)
			src.buffer2iue = 0
			src.buffer2 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer2owner = src.connected.occupant.name
			else
				src.buffer2owner = src.connected.occupant.real_name
			src.buffer2label = "Unique Identifier"
			src.buffer2type = "ui"
			dopage(src,"screen=buffermenu")
	if (href_list["b3addui"])
		if(src.connected.occupant && src.connected.occupant.dna)
			src.buffer3iue = 0
			src.buffer3 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer3owner = src.connected.occupant.name
			else
				src.buffer3owner = src.connected.occupant.real_name
			src.buffer3label = "Unique Identifier"
			src.buffer3type = "ui"
			dopage(src,"screen=buffermenu")
	if (href_list["b1addse"])
		if(src.connected.occupant && src.connected.occupant.dna)
			src.buffer1iue = 0
			src.buffer1 = src.connected.occupant.dna.struc_enzymes
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer1owner = src.connected.occupant.name
			else
				src.buffer1owner = src.connected.occupant.real_name
			src.buffer1label = "Structural Enzymes"
			src.buffer1type = "se"
			dopage(src,"screen=buffermenu")
	if (href_list["b2addse"])
		if(src.connected.occupant && src.connected.occupant.dna)
			src.buffer2iue = 0
			src.buffer2 = src.connected.occupant.dna.struc_enzymes
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer2owner = src.connected.occupant.name
			else
				src.buffer2owner = src.connected.occupant.real_name
			src.buffer2label = "Structural Enzymes"
			src.buffer2type = "se"
			dopage(src,"screen=buffermenu")
	if (href_list["b3addse"])
		if(src.connected.occupant && src.connected.occupant.dna)
			src.buffer3iue = 0
			src.buffer3 = src.connected.occupant.dna.struc_enzymes
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer3owner = src.connected.occupant.name
			else
				src.buffer3owner = src.connected.occupant.real_name
			src.buffer3label = "Structural Enzymes"
			src.buffer3type = "se"
			dopage(src,"screen=buffermenu")
	if (href_list["b1clear"])
		src.buffer1 = null
		src.buffer1owner = null
		src.buffer1label = null
		src.buffer1iue = null
		dopage(src,"screen=buffermenu")
	if (href_list["b2clear"])
		src.buffer2 = null
		src.buffer2owner = null
		src.buffer2label = null
		src.buffer2iue = null
		dopage(src,"screen=buffermenu")
	if (href_list["b3clear"])
		src.buffer3 = null
		src.buffer3owner = null
		src.buffer3label = null
		src.buffer3iue = null
		dopage(src,"screen=buffermenu")
	if (href_list["b1label"])
		src.buffer1label = sanitize(input("New Label:","Edit Label","Infos here"))
		dopage(src,"screen=buffermenu")
	if (href_list["b2label"])
		src.buffer2label = sanitize(input("New Label:","Edit Label","Infos here"))
		dopage(src,"screen=buffermenu")
	if (href_list["b3label"])
		src.buffer3label = sanitize(input("New Label:","Edit Label","Infos here"))
		dopage(src,"screen=buffermenu")
	if (href_list["b1transfer"])
		if (!src.connected.occupant || (NOCLONE in src.connected.occupant.mutations) || !src.connected.occupant.dna)
			return
		if (src.buffer1type == "ui")
			if (src.buffer1iue)
				src.connected.occupant.real_name = src.buffer1owner
				src.connected.occupant.name = src.buffer1owner
			src.connected.occupant.dna.uni_identity = src.buffer1
			updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
		else if (src.buffer1type == "se")
			src.connected.occupant.dna.struc_enzymes = src.buffer1
			domutcheck(src.connected.occupant,src.connected)
		src.temp_html = "Transfered."
		src.connected.occupant.radiation += rand(20,50)

	if (href_list["b2transfer"])
		if (!src.connected.occupant || (NOCLONE in src.connected.occupant.mutations) || !src.connected.occupant.dna)
			return
		if (src.buffer2type == "ui")
			if (src.buffer2iue)
				src.connected.occupant.real_name = src.buffer2owner
				src.connected.occupant.name = src.buffer2owner
			src.connected.occupant.dna.uni_identity = src.buffer2
			updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
		else if (src.buffer2type == "se")
			src.connected.occupant.dna.struc_enzymes = src.buffer2
			domutcheck(src.connected.occupant,src.connected)
		src.temp_html = "Transfered."
		src.connected.occupant.radiation += rand(20,50)

	if (href_list["b3transfer"])
		if (!src.connected.occupant || (NOCLONE in src.connected.occupant.mutations) || !src.connected.occupant.dna)
			return
		if (src.buffer3type == "ui")
			if (src.buffer3iue)
				src.connected.occupant.real_name = src.buffer3owner
				src.connected.occupant.name = src.buffer3owner
			src.connected.occupant.dna.uni_identity = src.buffer3
			updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
		else if (src.buffer3type == "se")
			src.connected.occupant.dna.struc_enzymes = src.buffer3
			domutcheck(src.connected.occupant,src.connected)
		src.temp_html = "Transfered."
		src.connected.occupant.radiation += rand(20,50)

	if (href_list["b1injector"])
		if (src.injectorready)
			var/obj/item/tool/medical/dnainjector/I = new /obj/item/tool/medical/dnainjector
			I.dna = src.buffer1
			I.dnatype = src.buffer1type
			I.loc = src.loc
			I.name += " ([src.buffer1label])"
			if (src.buffer1iue) I.ue = src.buffer1owner //lazy haw haw
			src.temp_html = "Injector created."

			src.injectorready = 0
			spawn(300)
				src.injectorready = 1
		else
			src.temp_html = "Replicator not ready yet."

	if (href_list["b2injector"])
		if (src.injectorready)
			var/obj/item/tool/medical/dnainjector/I = new /obj/item/tool/medical/dnainjector
			I.dna = src.buffer2
			I.dnatype = src.buffer2type
			I.loc = src.loc
			I.name += " ([src.buffer2label])"
			if (src.buffer2iue) I.ue = src.buffer2owner //lazy haw haw
			src.temp_html = "Injector created."

			src.injectorready = 0
			spawn(300)
				src.injectorready = 1
		else
			src.temp_html = "Replicator not ready yet."

	if (href_list["b3injector"])
		if (src.injectorready)
			var/obj/item/tool/medical/dnainjector/I = new /obj/item/tool/medical/dnainjector
			I.dna = src.buffer3
			I.dnatype = src.buffer3type
			I.loc = src.loc
			I.name += " ([src.buffer3label])"
			if (src.buffer3iue) I.ue = src.buffer3owner //lazy haw haw
			src.temp_html = "Injector created."

			src.injectorready = 0
			spawn(300)
				src.injectorready = 1
		else
			src.temp_html = "Replicator not ready yet."

	////////////////////////////////////////////////////////
	if (href_list["load_disk"])
		var/buffernum = text2num(href_list["load_disk"])
		if ((buffernum > 3) || (buffernum < 1))
			return
		if ((isnull(src.diskette)) || (!src.diskette.data) || (src.diskette.data == ""))
			return
		switch(buffernum)
			if(1)
				src.buffer1 = src.diskette.data
				src.buffer1type = src.diskette.data_type
				src.buffer1iue = src.diskette.ue
				src.buffer1owner = src.diskette.owner
			if(2)
				src.buffer2 = src.diskette.data
				src.buffer2type = src.diskette.data_type
				src.buffer2iue = src.diskette.ue
				src.buffer2owner = src.diskette.owner
			if(3)
				src.buffer3 = src.diskette.data
				src.buffer3type = src.diskette.data_type
				src.buffer3iue = src.diskette.ue
				src.buffer3owner = src.diskette.owner
		src.temp_html = "Data loaded."

	if (href_list["save_disk"])
		var/buffernum = text2num(href_list["save_disk"])
		if ((buffernum > 3) || (buffernum < 1))
			return
		if ((isnull(src.diskette)) || (src.diskette.read_only))
			return
		switch(buffernum)
			if(1)
				src.diskette.data = buffer1
				src.diskette.data_type = src.buffer1type
				src.diskette.ue = src.buffer1iue
				src.diskette.owner = src.buffer1owner
				src.diskette.name = "data disk - '[src.buffer1owner]'"
			if(2)
				src.diskette.data = buffer2
				src.diskette.data_type = src.buffer2type
				src.diskette.ue = src.buffer2iue
				src.diskette.owner = src.buffer2owner
				src.diskette.name = "data disk - '[src.buffer2owner]'"
			if(3)
				src.diskette.data = buffer3
				src.diskette.data_type = src.buffer3type
				src.diskette.ue = src.buffer3iue
				src.diskette.owner = src.buffer3owner
				src.diskette.name = "data disk - '[src.buffer3owner]'"
		src.temp_html = "Data saved."
	if (href_list["eject_disk"])
		if (!src.diskette)
			return
		src.diskette.loc = get_turf(src)
		src.diskette = null
	////////////////////////////////////////////////////////

	src.temp_html = temp_header_html
	switch(src.current_screen)
		if ("mainmenu")
			src.temp_html += "<h3>Main Menu</h3>"
			if (viable_occupant) //is there REALLY someone in there who can be modified?
				src.temp_html += text("<A href='?src=\ref[];screen=unimenu'>Modify Unique Identifier</A><br />", src)
				src.temp_html += text("<A href='?src=\ref[];screen=strucmenu'>Modify Structural Enzymes</A><br /><br />", src)
			else
				src.temp_html += "<span class='linkOff'>Modify Unique Identifier</span><br />"
				src.temp_html += "<span class='linkOff'>Modify Structural Enzymes</span><br /><br />"
			src.temp_html += text("<A href='?src=\ref[];screen=radsetmenu'>Radiation Emitter Settings</A><br /><br />", src)
			src.temp_html += text("<A href='?src=\ref[];screen=buffermenu'>Transfer Buffer</A><br /><br />", src)

		if ("unimenu")
			if(!viable_occupant)
				src.temp_html = text("No viable occupant detected.")
				popup.set_content(src.temp_html)
				popup.open()
			else
				src.temp_html = "<A href='?src=\ref[src];screen=mainmenu'><< Main Menu</A><br />"
				src.temp_html += "<h3>Modify Unique Identifier</h3>"
				src.temp_html += "<div align='center'>Unique Identifier:<br />[getblockstring(src.connected.occupant.dna.uni_identity,uniblock,subblock,3, src,1)]<br /><br />"
				src.temp_html += "Selected Block: <A href='?src=\ref[src];unimenuminus=1'><-</A> <B>[src.uniblock]</B> <A href='?src=\ref[src];unimenuplus=1'>-></A><br /><br />"
				src.temp_html += "Selected Sub-Block: <A href='?src=\ref[src];unimenusubminus=1'><-</A> <B>[src.subblock]</B> <A href='?src=\ref[src];unimenusubplus=1'>-></A><br /><br />"
				src.temp_html += "Selected Target: <A href='?src=\ref[src];unimenutargetminus=1'><-</A> <B>[src.unitargethex]</B> <A href='?src=\ref[src];unimenutargetplus=1'>-></A><br /><br />"
				src.temp_html += "<B>Modify Block</B><br />"
				src.temp_html += "<A href='?src=\ref[src];unipulse=1'>Irradiate</A></div>"

		if ("strucmenu")
			if(!viable_occupant)
				src.temp_html = text("No viable occupant detected.")
				popup.set_content(src.temp_html)
				popup.open()
			else
				src.temp_html = "<A href='?src=\ref[src];screen=mainmenu'><< Main Menu</A><br />"
				src.temp_html += "<h3>Modify Structural Enzymes</h3>"
				src.temp_html += "<div align='center'>Structural Enzymes: [getblockstring(src.connected.occupant.dna.struc_enzymes,strucblock,subblock,3,src,0)]<br /><br />"
				src.temp_html += "Selected Block: <A href='?src=\ref[src];strucmenuminus=1'><-</A> <B>[src.strucblock]</B> <A href='?src=\ref[src];strucmenuplus=1'>-></A><br /><br />"
				src.temp_html += "Selected Sub-Block: <A href='?src=\ref[src];strucmenusubminus=1'><-</A> <B>[src.subblock]</B> <A href='?src=\ref[src];strucmenusubplus=1'>-></A><br /><br />"
				src.temp_html += "<B>Modify Block</B><br />"
				src.temp_html += "<A href='?src=\ref[src];strucpulse=1'>Irradiate</A></div>"

		if ("radsetmenu")
			src.temp_html = "<A href='?src=\ref[src];screen=mainmenu'><< Main Menu</A><br />"
			src.temp_html += "<h3>Radiation Emitter Settings</h3>"
			if (viable_occupant)
				src.temp_html += text("<A href='?src=\ref[];genpulse=1'>Pulse Radiation</A>", src)
			else
				src.temp_html += "<span class='linkOff'>Pulse Radiation</span>"
			src.temp_html += "<br /><br />Radiation Duration: <A href='?src=\ref[src];radleminus=1'>-</A> <font color='green'><B>[src.radduration]</B></FONT> <A href='?src=\ref[src];radleplus=1'>+</A><br />"
			src.temp_html += "Radiation Intensity: <A href='?src=\ref[src];radinminus=1'>-</A> <font color='green'><B>[src.radstrength]</B></FONT> <A href='?src=\ref[src];radinplus=1'>+</A><br /><br />"

		if ("buffermenu")
			src.temp_html = "<A href='?src=\ref[src];screen=mainmenu'><< Main Menu</A><br />"
			src.temp_html += "<h3>Transfer Buffer</h3>"
			src.temp_html += "<h4>Buffer 1:</h4>"
			if (!(src.buffer1))
				src.temp_html += "<i>Buffer Empty</i><br />"
			else
				src.temp_html += text("Data: <font class='highlight'>[]</FONT><br />", src.buffer1)
				src.temp_html += text("By: <font class='highlight'>[]</FONT><br />", src.buffer1owner)
				src.temp_html += text("Label: <font class='highlight'>[]</FONT><br />", src.buffer1label)
			if (viable_occupant) src.temp_html += text("Save : <A href='?src=\ref[];b1addui=1'>UI</A> - <A href='?src=\ref[];b1adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b1addse=1'>SE</A><br />", src, src, src)
			if (src.buffer1) src.temp_html += text("Transfer to: <A href='?src=\ref[];b1transfer=1'>Occupant</A> - <A href='?src=\ref[];b1injector=1'>Injector</A><br />", src, src)
			//if (src.buffer1) src.temp_html += text("<A href='?src=\ref[];b1iso=1'>Isolate Block</A><br />", src)
			if (src.buffer1) src.temp_html += "Disk: <A href='?src=\ref[src];save_disk=1'>Save To</a> | <A href='?src=\ref[src];load_disk=1'>Load From</a><br />"
			if (src.buffer1) src.temp_html += text("<A href='?src=\ref[];b1label=1'>Edit Label</A><br />", src)
			if (src.buffer1) src.temp_html += text("<A href='?src=\ref[];b1clear=1'>Clear Buffer</A><br /><br />", src)
			if (!src.buffer1) src.temp_html += "<br />"
			src.temp_html += "<h4>Buffer 2:</h4>"
			if (!(src.buffer2))
				src.temp_html += "<i>Buffer Empty</i><br />"
			else
				src.temp_html += text("Data: <font class='highlight'>[]</FONT><br />", src.buffer2)
				src.temp_html += text("By: <font class='highlight'>[]</FONT><br />", src.buffer2owner)
				src.temp_html += text("Label: <font class='highlight'>[]</FONT><br />", src.buffer2label)
			if (viable_occupant) src.temp_html += text("Save : <A href='?src=\ref[];b2addui=1'>UI</A> - <A href='?src=\ref[];b2adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b2addse=1'>SE</A><br />", src, src, src)
			if (src.buffer2) src.temp_html += text("Transfer to: <A href='?src=\ref[];b2transfer=1'>Occupant</A> - <A href='?src=\ref[];b2injector=1'>Injector</A><br />", src, src)
			//if (src.buffer2) src.temp_html += text("<A href='?src=\ref[];b2iso=1'>Isolate Block</A><br />", src)
			if (src.buffer2) src.temp_html += "Disk: <A href='?src=\ref[src];save_disk=2'>Save To</a> | <A href='?src=\ref[src];load_disk=2'>Load From</a><br />"
			if (src.buffer2) src.temp_html += text("<A href='?src=\ref[];b2label=1'>Edit Label</A><br />", src)
			if (src.buffer2) src.temp_html += text("<A href='?src=\ref[];b2clear=1'>Clear Buffer</A><br /><br />", src)
			if (!src.buffer2) src.temp_html += "<br />"
			src.temp_html += "<h4>Buffer 3:</h4>"
			if (!(src.buffer3))
				src.temp_html += "<i>Buffer Empty</i><br />"
			else
				src.temp_html += text("Data: <font class='highlight'>[]</FONT><br />", src.buffer3)
				src.temp_html += text("By: <font class='highlight'>[]</FONT><br />", src.buffer3owner)
				src.temp_html += text("Label: <font class='highlight'>[]</FONT><br />", src.buffer3label)
			if (viable_occupant) src.temp_html += text("Save : <A href='?src=\ref[];b3addui=1'>UI</A> - <A href='?src=\ref[];b3adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b3addse=1'>SE</A><br />", src, src, src)
			if (src.buffer3) src.temp_html += text("Transfer to: <A href='?src=\ref[];b3transfer=1'>Occupant</A> - <A href='?src=\ref[];b3injector=1'>Injector</A><br />", src, src)
			//if (src.buffer3) src.temp_html += text("<A href='?src=\ref[];b3iso=1'>Isolate Block</A><br />", src)
			if (src.buffer3) src.temp_html += "Disk: <A href='?src=\ref[src];save_disk=3'>Save To</a> | <A href='?src=\ref[src];load_disk=3'>Load From</a><br />"
			if (src.buffer3) src.temp_html += text("<A href='?src=\ref[];b3label=1'>Edit Label</A><br />", src)
			if (src.buffer3) src.temp_html += text("<A href='?src=\ref[];b3clear=1'>Clear Buffer</A><br /><br />", src)
			if (!src.buffer3) src.temp_html += "<br />"
	src.temp_html += temp_footer_html

	if(viable_occupant && !src.scanner_status_html && occupant) //is there REALLY someone in there?
		src.scanner_status_html = "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [occupant.health]%;' class='progressFill good'></div></div><div class='statusValue'>[occupant.health]%</div></div>"
		src.scanner_status_html += "<div class='line'><div class='statusLabel'>Radiation Level:</div><div class='progressBar'><div style='width: [occupant.radiation]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.radiation]%</div></div>"
		if(human_occupant)
			var/rejuvenators = round(human_occupant.reagents.get_reagent_amount("inaprovaline") / REJUVENATORS_MAX * 100)
			src.scanner_status_html += "<div class='line'><div class='statusLabel'>Rejuvenators:</div><div class='progressBar'><div style='width: [rejuvenators]%;' class='progressFill highlight'></div></div><div class='statusValue'>[human_occupant.reagents.get_reagent_amount("inaprovaline")] units</div></div>"

		if (src.current_screen == "mainmenu")
			src.scanner_status_html += "<div class='line'><div class='statusLabel'>Unique Enzymes :</div><div class='statusValue'><span class='highlight'>[uppertext(occupant.dna.unique_enzymes)]</span></div></div>"
			src.scanner_status_html += "<div class='line'><div class='statusLabel'>Unique Identifier:</div><div class='statusValue'><span class='highlight'>[occupant.dna.uni_identity]</span></div></div>"
			src.scanner_status_html += "<div class='line'><div class='statusLabel'>Structural Enzymes:</div><div class='statusValue'><span class='highlight'>[occupant.dna.struc_enzymes]</span></div></div>"

	var/dat = "<h3>Scanner Status</h3>"

	var/occupant_status = "Scanner Unoccupied"
	if(occupant && occupant.dna) //is there REALLY someone in there?
		if (!istype(occupant,/mob/living/carbon/human))
			sleep(1)
		if(NOCLONE in occupant.mutations)
			occupant_status = "<span class='bad'>Invalid DNA structure</span>"
		else
			switch(occupant.stat) // obvious, see what their status is
				if(0)
					occupant_status = "<span class='good'>Conscious</span>"
				if(1)
					occupant_status = "<span class='average'>Unconscious</span>"
				else
					occupant_status = "<span class='bad'>DEAD</span>"

		occupant_status = "[occupant.name] => [occupant_status]<br />"

	dat += "<div class='statusDisplay'>[occupant_status][src.scanner_status_html]</div>"

	var/scanner_access_text = "Lock Scanner"
	if (src.connected.locked)
		scanner_access_text = "Unlock Scanner"

	dat += "<A href='?src=\ref[src];'>Scan</A> "

	if (occupant && occupant.dna)
		dat += "<A href='?src=\ref[src];locked=1'>[scanner_access_text]</A> "
		if (human_occupant)
			dat += "<A href='?src=\ref[src];rejuv=1'>Inject Rejuvenators</A><br />"
		else
			dat += "<span class='linkOff'>Inject Rejuvenators</span><br />"
	else
		dat += "<span class='linkOff'>[scanner_access_text]</span> "
		dat += "<span class='linkOff'>Inject Rejuvenators</span><br />"

	if (!isnull(src.diskette))
		dat += text("<A href='?src=\ref[];eject_disk=1'>Eject Disk</A><br />", src)

	dat += "<br />"

	if (src.temp_html)
		dat += src.temp_html

	popup.set_content(dat)
	popup.open()
