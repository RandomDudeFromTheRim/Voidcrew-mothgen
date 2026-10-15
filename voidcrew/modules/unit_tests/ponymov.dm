/// SHED.MOV plays through in each of its parts: its sets load as the map has them, the victim's made
/// a pony whose clothes draw, every line of the screenplay runs, and the victim comes back as their
/// part leaves them.
/datum/unit_test/ponymov_shed

/datum/unit_test/ponymov_shed/Run()
	// The pony clothes' greyscale config draws, rather than greyscale's error icon.
	var/icon/coloured = SSgreyscale.GetColoredIconByType(/datum/greyscale_config/pony_clothes_1_color, "#ff0000")
	TEST_ASSERT("jumpsuit" in icon_states(coloured), "The pony clothes' greyscale config has no jumpsuit.")
	// Every piece of clothing with a pony sprite finds it in its greyscale config.
	for(var/obj/item/clothing/clothing_type as anything in subtypesof(/obj/item/clothing))
		if(!(initial(clothing_type.supports_variations_flags) & CLOTHING_PONY_MASK))
			continue
		var/config_type = initial(clothing_type.pony_config_path)
		var/datum/greyscale_config/config = SSgreyscale.configurations["[config_type]"]
		if(!config)
			TEST_FAIL("[clothing_type]'s pony config [config_type] doesn't exist.")
			continue
		var/colours = ""
		for(var/i in 1 to config.expected_colors)
			colours += "#ffffff"
		var/state = initial(clothing_type.pony_icon_state)
		if(!(state in icon_states(SSgreyscale.GetColoredIconByType(config_type, colours))))
			TEST_FAIL("[clothing_type]'s pony sprite, [state], isn't in [config_type].")
	// The pony versions of worn things have the thing's own state in them, or they'd draw nothing.
	var/obj/item/storage/backpack/backpack = allocate(/obj/item/storage/backpack)
	var/obj/item/storage/belt/utility/belt = allocate(/obj/item/storage/belt/utility)
	var/obj/item/clothing/suit/hazardvest/vest = allocate(/obj/item/clothing/suit/hazardvest)
	var/obj/item/clothing/shoes/sneakers/black/shoes = allocate(/obj/item/clothing/shoes/sneakers/black)
	check_state(pony_back_icon(backpack, 'icons/mob/clothing/back.dmi'), backpack)
	check_state(pony_back_icon(backpack, 'icons/mob/clothing/back.dmi', other_side = TRUE), backpack)
	check_state(pony_front_back_icon(belt, 'icons/mob/clothing/belt.dmi'), belt)
	check_state(pony_suit_icon(vest, DEFAULT_SUIT_FILE), vest)
	check_state(pony_shoes_icon(shoes, DEFAULT_SHOES_FILE), shoes)
	for(var/part in list("rainbow", "pinkie", "applebloom"))
		play_as(part)

/datum/unit_test/ponymov_shed/proc/check_state(icon/drawn, obj/item/worn)
	var/state = worn.worn_icon_state || worn.icon_state
	TEST_ASSERT(state in icon_states(drawn), "The pony version of [worn] has no [state] state.")

/datum/unit_test/ponymov_shed/proc/play_as(part)
	var/mob/living/carbon/human/consistent/victim = allocate(/mob/living/carbon/human/consistent)
	victim.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(victim), ITEM_SLOT_ICLOTHING)
	var/turf/start = get_turf(victim)
	var/datum/ponymov/shed/showing = new(victim, part, TRUE)
	TEST_ASSERT(showing.set_up(), "SHED.MOV couldn't set up as [part].")

	// The sets, as shed.dmm has them.
	TEST_ASSERT(istype(showing.set_turf("town", 11, 8), /turf/open/floor/stone), "Ponyville's street isn't there.")
	TEST_ASSERT(locate(/obj/structure/mineral_door) in showing.set_turf("shed", 11, 3), "The shed's door isn't there.")
	TEST_ASSERT(locate(/obj/structure/grille) in showing.set_turf("asylum", 11, 11), "The cell's window isn't there.")
	var/obj/structure/curtain/curtain = locate() in showing.set_turf("prom", 11, 14)
	TEST_ASSERT_EQUAL(curtain?.icon_state, "cur_fancy-closed", "The prom's curtains aren't drawn.")

	TEST_ASSERT(istype(victim.dna.species, /datum/species/pony), "The [part] part wasn't made a pony.")
	TEST_ASSERT_EQUAL(showing.cast[part], victim, "The victim isn't playing [part].")

	for(var/list/line as anything in showing.screenplay)
		showing.run_line(line)

	var/mob/living/carbon/human/shy = showing.cast["fluttershy"]
	TEST_ASSERT_EQUAL(showing.where(shy)[1], "asylum", "Fluttershy didn't end up in the asylum.")
	TEST_ASSERT(istype(shy.wear_suit, /obj/item/clothing/suit/jacket/straight_jacket), "Fluttershy isn't in her straitjacket.")

	qdel(showing)
	TEST_ASSERT_EQUAL(get_turf(victim), start, "The [part] part didn't come back where they were.")
	if(part == "rainbow")
		TEST_ASSERT_EQUAL(victim.stat, DEAD, "The Rainbow part came out of it alive.")
	else
		TEST_ASSERT(victim.stat != DEAD, "The [part] part came out of it dead.")
