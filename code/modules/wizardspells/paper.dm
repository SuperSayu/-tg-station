/obj/item/weapon/book/manual/wizard
	name = "Grand Theft Magic"
	icon_state ="bookHacking"
	author = "Deadly Sandals"
	title = "Grand Theft Magic"
	dat = {"
		<center><h3>Grand Theft Magic</h3>A guide to high magic</center><hr>

		<p>I know it's you that's been stealing my spellbooks, apprentice.  I slipped this in among them, and if you're reading this, then
		I'll be coming to get you, soon.  I know you're doing mercenary work, and you may think yourself powerful, but rest assured, I WILL
		get my revenge. and SOON.</p>

		<p>If my guess is right you've fled to an area of low magic density, so your ability to memorize spells will be lower than before.
		Only an enchanter's forge could save you, and--well, if you've stolen that from me, you'll be begging for death by the end.</p>

		<p>If I find you've torn even one more page out of my spellbooks I'm going to be quite cross.  You might think that putting them
		into items or your own spellbooks will hide the evidence, but my forge WILL rip the magic right back out, so there is NO hiding them.
		And no matter what you do, there's going to be NO getting away with them all.  I don't know how you've been getting the tomes out of
		my sanctum, but I made sure they'll be fixed in place by POWERFUL magic.</p>

		<p>And for the love of magery stop putting my spells into unfitting magic items, you know I hate it when you waste them like that.
		My forge will not let you put them in the wrong type, but who knows what fly-by-night operation you're running, my FORMER apprentice.</p>

		<p>Rest assured I'm coming for you.  Even if your syndicate contacts will keep you safe, but I doubt they'll do it for free, not knowing
		the cost of going up against me.  Whatever deal you've made with them, your best bet is to beg their mercy and hope they pull through.</p>

		<p>Also, stay away from my daughter.  You're a bad influence on her.</p>

		<p><i>Grand Wizard Deadly Sandals</i></p>
		"}

/obj/item/weapon/magic/contract
	name = "contract"
	desc = "Summons a magically bound ally to your service"
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	flags = FPRINT
	castingmode = 0

/obj/item/weapon/magic/contract/attack_self(mob/user as mob)
	summon(user)
	return

/obj/item/weapon/magic/contract/proc/summon(mob/user)
	var/list/candidates = get_candidates(BE_WIZARD)
	if(candidates.len)
		var/client/C = pick(candidates)
		new /obj/effect/effect/harmless_smoke(user.loc)
		var/mob/living/carbon/human/M = new/mob/living/carbon/human(user.loc)
		M.key = C.key
		M << "<B>You are the [user.real_name]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals."
		M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
		M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), slot_w_uniform)
		M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
		M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(M), slot_wear_suit)
		M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(M), slot_head)
		M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
		M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)
		var/wizard_name_first = pick(wizard_first)
		var/wizard_name_second = pick(wizard_second)
		var/randomname = "[wizard_name_first] [wizard_name_second]"
		var/newname = copytext(sanitize(input(M, "You are the wizard's apprentice. Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = randomname
		M.mind.name = newname
		M.real_name = newname
		M.name = newname
		var/datum/objective/protect/new_objective = new /datum/objective/protect
		new_objective.owner = M.mind
		new_objective:target = user.mind
		new_objective.explanation_text = "Protect [user.real_name], the wizard."
		M.mind.objectives += new_objective
		ticker.mode.traitors += M.mind
		M.mind.special_role = "apprentice"
