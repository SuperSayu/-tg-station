/obj/structure/bookcase/random
	var/booktype = /obj/item/weapon/book/db_random
	var/book_count = 2
	anchored = 1
	state = 2
	New()
		..()
		if(type != /obj/structure/bookcase/random && prob(25))
			var/obj/structure/bookcase/random/R = new(loc)
			R.name = name
			qdel(src)
			return
		book_count = rand(book_count-2,book_count+2)
		if(book_count)
			var/list/spawned = list()
			for(var/i=1; i<=book_count; i++)
				var/obj/item/weapon/book/B = new booktype(src)
				if(B.title in spawned)
					qdel(B)
					if(prob(33)) book_count++
				spawned.Add(B.title)


		update_icon()

/obj/structure/bookcase/random/fiction
	name = "bookcase (Fiction)"
	booktype = /obj/item/weapon/book/db_random/fiction
/obj/structure/bookcase/random/nonfiction
	name = "bookcase (Non-Fiction)"
	booktype = /obj/item/weapon/book/db_random/nonfiction
/obj/structure/bookcase/random/reference
	name = "bookcase (Reference)"
	booktype = /obj/item/weapon/book/db_random/reference
/obj/structure/bookcase/random/religion
	name = "bookcase (Religion)"
	booktype = /obj/item/weapon/book/db_random/religion

/obj/item/weapon/book/db_random
	var/force_category = ""
	var/fallback_type = null
	New()
		if(ticker) // do not do this during world spawn, congestion ahead
			fulfill()
			return
		..()

	initialize()
		fulfill()

	proc/fulfill()
		establish_db_connection()
		if(!dbcon || !dbcon.IsConnected())
			if(fallback_type)
				new fallback_type(loc)
			if(prob(5))
				var/obj/item/weapon/paper/P = new(get_turf(loc))
				P.info = "There once was a book from nantucket<br>But the database failed us, so f*$! it.<br>I did something nice for you<br>So this is an I.O.U<br>If you've any objections, well, stuff it!<br><br><font color='gray'>~</font>"
			qdel(src)
			return
		if(!fallback_type || prob(95)) // sometimes replace it with the default
			var/q
			// I hope I don't need to tell you that you should never allow users to input the force_category,
			// because it is possible to inject sql.  Also, sanitize your access rights.
			if(force_category)
				q = "SELECT * FROM (SELECT * FROM erro_library WHERE isnull(deleted) AND category='[force_category]') AS r1 JOIN(SELECT (RAND() * (SELECT MAX(id) FROM erro_library)) AS id) AS r2 WHERE r1.id >= r2.id ORDER BY r1.id ASC LIMIT 1;"
			else
				q = "SELECT * FROM (SELECT * FROM erro_library WHERE isnull(deleted)) AS r1 JOIN(SELECT (RAND() * (SELECT MAX(id) FROM erro_library)) AS id) AS r2 WHERE r1.id >= r2.id ORDER BY r1.id ASC LIMIT 1;"
			var/DBQuery/query = dbcon.NewQuery(q)
			query.Execute()
			if(query.NextRow())
				author =query.item[2]
				title =	query.item[3]
				dat =	query.item[4]
				name = "Book: [title]"
				icon_state = "book[rand(1,7)]"
				return

		if(fallback_type)
			new fallback_type(loc)
		else if(prob(10))
			new /obj/item/weapon/book/manual/random(loc)

		qdel(src)
		return

/obj/item/weapon/book/db_random/fiction
	force_category = "Fiction"
/obj/item/weapon/book/db_random/reference
	force_category = "Reference"
	fallback_type = /obj/item/weapon/book/manual/random
/obj/item/weapon/book/db_random/nonfiction
	force_category = "Non-Fiction"
/obj/item/weapon/book/db_random/religion
	force_category = "Religion"
