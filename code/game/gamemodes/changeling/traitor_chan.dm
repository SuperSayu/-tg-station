/datum/game_mode/traitor/changeling
	name = "traitor+changeling"
	config_tag = "traitorchan"
	traitors_possible = 5 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg")
	required_players = 5
	required_enemies = 2
	recommended_enemies = 3

/datum/game_mode/traitor/changeling/announce()
	world << "<B>The current game mode is - Traitor+Changeling!</B>"
	world << "<B>There is an alien creature on the station along with some syndicate operatives out for their own gain! Do not let the changeling and the traitors succeed!</B>"


/datum/game_mode/traitor/changeling/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(BE_CHANGELING)
	var/list/possible_traitors = get_players_for_role(BE_TRAITOR)

	// stop setup if no possible traitors
	if(!possible_traitors.len || !possible_changelings.len)
		return 0

	for(var/datum/mind/player in possible_changelings)
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				possible_changelings -= player
				possible_traitors -= player

	if(config.traitor_scaling)
		traitors_possible = scale_antags()

	// No more than three lings, but allow them to be a
	// greater portion of the antagonist docket if the
	// dice land like that.
	var/num_changelings = min(3,rand(1,traitors_possible-1))

	while(possible_changelings.len && (changelings.len < num_changelings))
		var/datum/mind/changeling = pick_n_take(possible_changelings)
		changelings += changeling
		modePlayer += changeling
		possible_traitors -= changeling

	while(possible_traitors.len && (modePlayer.len < traitors_possible))
		var/datum/mind/traitor = pick_n_take(possible_traitors)
		traitors += traitor
		modePlayer += traitor
		traitor.special_role = "traitor"

	if(!modePlayer.len)
		return 0
	return 1

/datum/game_mode/traitor/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		changeling.special_role = "Changeling"
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)
	..()
	return