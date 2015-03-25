var/global/datum/getrev/revdata = new()

/datum/getrev
	var/project_href
	var/revision
	var/date
	var/showinfo

/datum/getrev/New()
	if(fexists("config/git_host.txt"))
		project_href = file2text("config/git_host.txt")
	else
		project_href = "https://www.github.com/tgstation/-tg-station"
	var/list/head_log = file2list(".git/logs/HEAD", "\n")
	for(var/line=head_log.len, line>=1, line--)
		if(head_log[line])
			var/list/last_entry = text2list(head_log[line], " ")
			if(last_entry.len < 2)	continue
			revision = last_entry[2]
			// Get date/time
			if(last_entry.len >= 5)
				var/unix_time = text2num(last_entry[5])
				if(unix_time)
					date = unix2date(unix_time)
			break

	showinfo = "<b>Server Revision:</b> "
	if(revision)
		showinfo += "<A href='?src=\ref[src];project_open=1'><BR>[(date ? date : "No Date")]<BR>[revision]</A>"
	else
		showinfo += "*unknown*"
	showinfo += "<p>-<A href='?src=\ref[src];new_issue_open=1'>Report Bugs Here-</A><br><i>Please provide as much info as possible<br>Copy/paste the revision date and hash into your issue report if possible, thanks</i> :)</p>"

	world.log << "Running Sayustation revision:"
	world.log << date
	world.log << revision
	return

/datum/getrev/Topic(href, href_list)
	..()
	if(href_list["project_open"])
		if(alert(usr, "This will open the project in your browser. Are you sure?",,"Yes","No")=="No")
			return
		usr << link("[project_href]/commit/[revision]")
	else if(href_list["new_issue_open"])
		if(alert(usr, "This will open the issue tracker in your browser. Are you sure?",,"Yes","No")=="No")
			return
		usr << link("[project_href]/issues/new")


client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	set desc = "Check the current server code revision"

	if(revdata.revision)
		src << "<b>Server revision compiled on:</b> [revdata.date]"
		src << "<a href='[file2text("config/git_host.txt")]/commit/[revdata.revision]'>[revdata.revision]</a>"
	else
		src << "Revision unknown"
	src << "<b>Current Infomational Settings:</b>"
	src << "Protect Authority Roles From Traitor: [config.protect_roles_from_antagonist]"
	src << "Protect Assistant Role From Traitor: [config.protect_assistant_from_antagonist]"
	src << "Enforce Human Authority: [config.enforce_human_authority]"
	src << "Allow Latejoin Antagonists: [config.allow_latejoin_antagonists]"
	src << "Protect Assistant From Antagonist: [config.protect_assistant_from_antagonist]"

	if(config.show_game_type_odds)
		var/output  = ""
		output += "<br><b>Game Type Odds:</b><br>"
		for(var/i=1,i<=config.probabilities.len,i++)
			var/p = config.probabilities[i]
			output += "[p] [config.probabilities[p]]<br>"
		src << output
	return
