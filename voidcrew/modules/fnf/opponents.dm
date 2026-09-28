/**
 * Who turns up to sing against a lone challenger: the song's own opponent, as near as the station's
 * species and wardrobe get. Unknown characters (and the song that ships with the game) get
 * Experiment Dearest.
 *
 * Everyone summoned holds a battle microphone (Pico and Tankman a gun as well), moves in their
 * own style (see fnf_apply_style) and is rigged like a roundstart species even if they aren't one.
 */
/proc/fnf_summon_opponent(character, turf/spot)
	var/mob/living/carbon/human/npc = new(spot)
	var/name = "Experiment Dearest"
	var/species = /datum/species/experiment
	var/hairstyle
	var/hair_colour
	switch(character)
		if("gf")
			name = "Girlfriend"
			species = /datum/species/human
			npc.gender = FEMALE
			npc.physique = FEMALE
			hairstyle = "Very Long Hair"
			hair_colour = "#6b2c1c"
		if("dad", "parents")
			name = "Daddy Dearest"
			species = /datum/species/human
			hairstyle = "Long Hair 2"
			hair_colour = "#1a1420"
		if("mom")
			name = "Mommy Mearest"
			species = /datum/species/human
			npc.gender = FEMALE
			npc.physique = FEMALE
			hairstyle = "Very Long Hair"
			hair_colour = "#15101a"
		if("spooky")
			name = "Skid & Pump"
			species = /datum/species/skeleton
		if("monster")
			name = "Monster"
			species = /datum/species/lizard
			npc.dna.features[FEATURE_MUTANT_COLOR] = "#e8d23a"
		if("pico")
			name = "Pico"
			species = /datum/species/human
			hairstyle = "Spiky"
			hair_colour = "#e8742a"
		if("senpai")
			name = "Senpai"
			species = /datum/species/human
			hairstyle = "Bedhead"
			hair_colour = "#f5d86b"
		if("spirit")
			name = "Spirit"
			species = /datum/species/ethereal
			npc.dna.features[FEATURE_ETHEREAL_COLOR] = "#ff3a3a"
		if("tankman")
			name = "Tankman"
			species = /datum/species/human
		if("darnell")
			name = "Darnell"
			species = /datum/species/human
			npc.skin_tone = "african2"
			hairstyle = "Bedhead"
			hair_colour = "#120d0a"
		if("nene")
			name = "Nene"
			species = /datum/species/human
			npc.gender = FEMALE
			npc.physique = FEMALE
			hairstyle = "Long Hair 1"
			hair_colour = "#e8e2d4"
		if("bf")
			name = "Boyfriend"
			species = /datum/species/human
			hairstyle = "Spiky"
			hair_colour = "#35c6ff"
	npc.set_species(species)
	npc.fully_replace_character_name(npc.real_name, name)
	if(hairstyle)
		npc.set_hairstyle(hairstyle, update = FALSE)
		npc.set_haircolor(hair_colour, update = FALSE)
	npc.update_body(is_creating = TRUE)
	fnf_dress_opponent(npc, character)
	if(!npc.dna.species.limb_rig_shape?["always"])
		npc.add_quirk(/datum/quirk/overanimated)
	// Everyone faces east, so the right hand is the one the crowd sees. Gunners keep the gun there
	// and the mic in the other.
	if(character == "pico" || character == "tankman")
		npc.put_in_r_hand(new /obj/item/toy/gun(npc))
		npc.put_in_l_hand(new /obj/item/fnf_microphone(npc))
	else
		npc.put_in_r_hand(new /obj/item/fnf_microphone(npc))
	return npc

/// Their outfit, from things the station has lying about.
/proc/fnf_dress_opponent(mob/living/carbon/human/npc, character)
	var/list/outfit
	switch(character)
		if("gf")
			outfit = list(/obj/item/clothing/under/dress/tango, /obj/item/clothing/shoes/sneakers/red)
		if("dad", "parents")
			outfit = list(/obj/item/clothing/under/suit/black, /obj/item/clothing/shoes/laceup)
		if("mom")
			outfit = list(/obj/item/clothing/under/dress/eveninggown, /obj/item/clothing/shoes/laceup)
		if("spooky")
			outfit = list(/obj/item/clothing/under/costume/skeleton, /obj/item/clothing/head/utility/hardhat/pumpkinhead)
		if("monster")
			outfit = list(/obj/item/clothing/under/color/black, /obj/item/clothing/shoes/sneakers/black)
		if("pico")
			outfit = list(/obj/item/clothing/under/color/white, /obj/item/clothing/shoes/sneakers/black)
		if("senpai")
			outfit = list(/obj/item/clothing/under/color/darkblue, /obj/item/clothing/shoes/laceup)
		if("tankman")
			outfit = list(/obj/item/clothing/under/syndicate/camo, /obj/item/clothing/head/helmet, /obj/item/clothing/shoes/jackboots)
		if("darnell")
			outfit = list(/obj/item/clothing/under/color/lightpurple, /obj/item/clothing/shoes/sneakers/black)
		if("nene")
			outfit = list(/obj/item/clothing/under/dress/skirt, /obj/item/clothing/shoes/sneakers/black)
		if("bf")
			outfit = list(/obj/item/clothing/under/color/white, /obj/item/clothing/head/soft/red, /obj/item/clothing/shoes/sneakers/red)
	for(var/item_type in outfit)
		var/obj/item/clothing/worn = new item_type(npc)
		if(!npc.equip_to_appropriate_slot(worn))
			qdel(worn)
