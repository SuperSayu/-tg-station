/*
	Mystic Tome:  Librarian item.  Contains a number of formulae scrolls which can be copied.
	When a formulae scroll is solved and the answer entered, it can be used to cast a spell.

	Each scroll contains the following:
	* Letter soup (title): A collection of symbols and letters.  The letters get swapped for numbers for block 1.
	* Noise block (Decrypt Key #1): A skip block.  For each number from the letter soup, skip that many characters
	  then record the next.  The result should be a word spelled backwards, one of many for any given spell.
	* Key input - Decrypts block #2 with the result of Noise Block as per vigenere
	* Vigenere block (Decrypt key #2): Encrypted rail fence
	* Activation input: Original text of the encrypted rail fence

	If you submit the correct answer for both the key and activator, the scroll will be primed.  It may
	also, in some cases, require a blood sacrifice; if you do not splash some blood on the scroll, your
	health will be affected when the spell is cast.

	If you submit an incorrect answer for the activator at any time (empty strings don't count), something bad
	will happen to you.  Not disastrous, but bad.

	All scrolls are one-use.  All mystic scrolls may be photocopied.  Photocopies do not retain keys or activation.

	T
*/

/obj/item/magic/scroll/mystic
	var/title
	var/noise
	var/vigenere_key
	var/submitted_key
	var/vigenere_block
	var/railfence
	var/activation_code
	var/submitted_code

	// Note that the code should be 24 characters long (2*3*4)
	proc/generate(var/key,var/code)
		// 255 characters of nonsense.  The first is always replaced and so you might as well just remove it.
		// Although there is no reason to reuse the same block, there is also no reason to generate it
		noise = "FFKYSWSGUAACYARWUFSGHMFXJBBMPUASVQXXCHDDAZENFXYPBZMHBBVWNXKRSVJJTHEJRMRGBFFFBWSFJPCVPFZGJGVGRSRCGXMVUXMRANVUPVKDPBAVHSZFNZVMTDNPHEHUJWKQMATMEVTRWMGCJEUBTASAJSRPVBUBYPHPPNMURAJMSKTMYJNQVZTEVAHJFJTKJDYDXMNDBXVUZDNEFUZPHNXKAYTRXWFMCVHXFUDVHCHVBVXCCEFUHRQPTNC"

		var/skip_total = 256
		var/keylen = lentext(key)
		var/average_skip = min(round(skip_total / keylen),20) // not 26, because we need wiggle room so it's not all z's

		var/list/skip_constants = list()

		for(var/temp=1;temp <= keylen; temp++) // fill list with values
			skip_constants += average_skip

		for(var/temp=1;temp <= keylen * 4; temp++) // randomize them
			var/i = rand(1,keylen)
			if(skip_constants[i]==1) continue
			skip_constants[i]--
			i = rand(1,keylen)
			while(skip_constants[i]==26)
				i = rand(1,keylen)
			skip_constants[i]++

		skip_constants = shuffle(skip_constants) // jumble up

		noise = copytext(key,1,2) + noise
		var/currentpos = 2
		for(var/temp=1;temp<=keylen;temp++
			noise = copytext(noise,currentpos, currentpos+skip_constants[temp]) + copytext(key,temp,temp+1) + copytext(noise,currentpos+skip_constants[temp]+1)

		// Now, hide the key to the noise block in the title
		title = junk()
		for(var/n in skip_constants)
			title = junk() + ascii2text(n + 64)
		title += junk()

		// Create the railfence text
		var/n_fences = pick(2,3,4)
		var/list/fences = list("","","","")
		var/fenceno = 1
		for(var/temp = 1;temp<=lentext(code);temp++)
			fences[fenceno] += copytext(code,temp,temp+1)
			fenceno = (fenceno+1)%n_fences


	proc/junk()
		var/dat = ""
		while(prob(70))
			dat += pick("$","!"," ","-",".","@","5","*","%","_")
		return dat



/obj/item/magic/mystic_tome

