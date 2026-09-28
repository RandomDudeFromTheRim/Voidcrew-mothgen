/**
 * Who turns up to sing against a lone challenger: the song's own opponent, matched as closely as
 * the station gets to their Funkin' sprite. Skin, hair and eyes are coloured to the sprite, and
 * the outfit is recoloured to match (most station clothes can take any colour). Unknown
 * characters (and the song that ships with the game) get Experiment Dearest.
 *
 * Everyone summoned holds a battle microphone (Pico and Tankman a gun as well), moves in their own
 * style (see fnf_apply_style) and is rigged like a roundstart species even if they aren't one.
 *
 * Each entry, by character (as Funkin' names them, without variants):
 * - "name", "species"
 * - "skin": a colour for the skin, or "tone": one of the human skin tones
 * - "female": TRUE for a woman's body
 * - "hair", "hair_colour", "eyes"
 * - "outfit": list(list(item type, greyscale colours or null), ...)
 * - "mutant_colour", "ethereal_colour": for lizards and ethereals
 * - "gun": TRUE to hold a gun as well as the mic
 */
GLOBAL_LIST_INIT(fnf_opponents, list(
	"dad" = list(
		"name" = "Daddy Dearest",
		"species" = /datum/species/human,
		"skin" = "#c9a2dc",
		"hair" = "Swept Back Hair",
		"hair_colour" = "#5b6187",
		"eyes" = "#6b2f8c",
		"outfit" = list(
			list(/obj/item/clothing/under/suit/black, null),
			list(/obj/item/clothing/shoes/laceup, null),
		),
	),
	"mom" = list(
		"name" = "Mommy Mearest",
		"species" = /datum/species/human,
		"female" = TRUE,
		"skin" = "#e2c4ee",
		"hair" = "Very Long Hair",
		"hair_colour" = "#6e1510",
		"eyes" = "#7a2a9c",
		"outfit" = list(
			list(/obj/item/clothing/under/dress/eveninggown, "#d0102c"),
			list(/obj/item/clothing/shoes/jackboots, null),
		),
	),
	"pico" = list(
		"name" = "Pico",
		"species" = /datum/species/human,
		"tone" = "african1",
		"hair" = "Spiky",
		"hair_colour" = "#ff7a2a",
		"eyes" = "#3fbf4f",
		"gun" = TRUE,
		"outfit" = list(
			// Green shirt, khaki trousers.
			list(/obj/item/clothing/under/costume/buttondown/slacks, "#3fa34d#2f7a3a#a8875a#3a2a1a"),
			list(/obj/item/clothing/shoes/sneakers, "#8a1f2a#f2e6d8"),
		),
	),
	"darnell" = list(
		"name" = "Darnell",
		"species" = /datum/species/human,
		"tone" = "african2",
		"hair" = "Short Hair",
		"hair_colour" = "#120d0a",
		"eyes" = "#3a2418",
		"outfit" = list(
			list(/obj/item/clothing/under/color, "#243026"),
			list(/obj/item/clothing/suit/jacket/oversized, "#5a2a6e"),
			list(/obj/item/clothing/head/beanie, "#4a2360#4a2360"),
			list(/obj/item/clothing/shoes/sneakers, "#6a3d8c#f0ecf6"),
		),
	),
	"nene" = list(
		"name" = "Nene",
		"species" = /datum/species/human,
		"female" = TRUE,
		"tone" = "caucasian1",
		"hair" = "Messy",
		"hair_colour" = "#2b2e55",
		"eyes" = "#d02030",
		"outfit" = list(
			list(/obj/item/clothing/under/dress/skirt, "#d83a52#f28cb0"),
			list(/obj/item/clothing/shoes/sneakers, "#f28cb0#ffffff"),
		),
	),
	"gf" = list(
		"name" = "Girlfriend",
		"species" = /datum/species/human,
		"female" = TRUE,
		"tone" = "caucasian1",
		"hair" = "Very Long Hair",
		"hair_colour" = "#7a1a14",
		"eyes" = "#35b7c7",
		"outfit" = list(
			list(/obj/item/clothing/under/dress/eveninggown, "#e0203a"),
			list(/obj/item/clothing/shoes/sneakers, "#d01a2a#d01a2a"),
		),
	),
	"senpai" = list(
		"name" = "Senpai",
		"species" = /datum/species/human,
		"tone" = "caucasian1",
		"hair" = "Long Fringe",
		"hair_colour" = "#f2a65a",
		"eyes" = "#3a3a5a",
		"outfit" = list(
			list(/obj/item/clothing/under/color, "#2a2a40"),
			list(/obj/item/clothing/suit/jacket/oversized, "#6a4f9a"),
			list(/obj/item/clothing/shoes/laceup, null),
		),
	),
	"tankman" = list(
		"name" = "Tankman",
		"species" = /datum/species/human,
		"tone" = "caucasian2",
		"hair" = "Crewcut",
		"hair_colour" = "#1a1410",
		"eyes" = "#1a1a1a",
		"gun" = TRUE,
		"outfit" = list(
			// All in black, as he's drawn.
			list(/obj/item/clothing/under/color, "#1c1c1c"),
			list(/obj/item/clothing/head/helmet, null),
			list(/obj/item/clothing/mask/bandana/black, null),
			list(/obj/item/clothing/shoes/jackboots, null),
		),
	),
	"bf" = list(
		"name" = "Boyfriend",
		"species" = /datum/species/human,
		"tone" = "caucasian1",
		"hair" = "Spiky",
		"hair_colour" = "#35c6ff",
		"eyes" = "#1a1a2a",
		"outfit" = list(
			// White shirt, blue shorts, red cap and sneakers.
			list(/obj/item/clothing/under/costume/buttondown/shorts, "#f4f4f4#d02030#2d5bc8#2d2d33"),
			list(/obj/item/clothing/head/soft/red, null),
			list(/obj/item/clothing/shoes/sneakers, "#d02030#ffffff"),
		),
	),
	"monster" = list(
		// A black body with a lemon for a head.
		"name" = "Monster",
		"species" = /datum/species/lizard,
		"mutant_colour" = "#f0dc3a",
		"eyes" = "#1a1a1a",
		"outfit" = list(
			list(/obj/item/clothing/under/color, "#141414"),
			list(/obj/item/clothing/shoes/sneakers, "#141414#141414"),
		),
	),
	"spooky" = list(
		// Skid in his skeleton costume, Pump's pumpkin on his head.
		"name" = "Skid & Pump",
		"species" = /datum/species/skeleton,
		"outfit" = list(
			list(/obj/item/clothing/under/costume/skeleton, null),
			list(/obj/item/clothing/head/utility/hardhat/pumpkinhead, null),
		),
	),
	"spirit" = list(
		"name" = "Spirit",
		"species" = /datum/species/ethereal,
		"ethereal_colour" = "#ff3a3a",
	),
))

/proc/fnf_summon_opponent(character, turf/spot)
	// Week 5's "parents" are Mommy and Daddy together; Daddy comes.
	if(character == "parents")
		character = "dad"
	var/list/look = GLOB.fnf_opponents[character]
	var/mob/living/carbon/human/npc = new(spot)
	if(!look)
		npc.set_species(/datum/species/experiment)
		npc.fully_replace_character_name(npc.real_name, "Experiment Dearest")
		npc.put_in_r_hand(new /obj/item/fnf_microphone(npc))
		return npc

	if(look["female"])
		npc.gender = FEMALE
		npc.physique = FEMALE
	if(look["tone"])
		npc.skin_tone = look["tone"]
	if(look["mutant_colour"])
		npc.dna.features[FEATURE_MUTANT_COLOR] = look["mutant_colour"]
	if(look["ethereal_colour"])
		npc.dna.features[FEATURE_ETHEREAL_COLOR] = look["ethereal_colour"]
	npc.set_species(look["species"])
	npc.fully_replace_character_name(npc.real_name, look["name"])
	npc.set_facial_hairstyle("Shaved", update = FALSE)
	if(look["hair"])
		npc.set_hairstyle(look["hair"], update = FALSE)
		npc.set_haircolor(look["hair_colour"], update = FALSE)
	if(look["eyes"])
		npc.set_eye_color(look["eyes"], look["eyes"])
	// Skin no human skin tone covers (Daddy and Mommy are lavender).
	if(look["skin"])
		for(var/obj/item/bodypart/limb as anything in npc.bodyparts)
			limb.add_color_override(look["skin"], FNF_SKIN_PRIORITY)
	npc.update_body(is_creating = TRUE)

	for(var/list/piece as anything in look["outfit"])
		var/item_type = piece[1]
		var/obj/item/clothing/worn = new item_type(npc)
		if(piece[2])
			worn.set_greyscale(piece[2])
		if(!npc.equip_to_appropriate_slot(worn))
			qdel(worn)

	if(!npc.dna.species.limb_rig_shape?["always"])
		npc.add_quirk(/datum/quirk/overanimated)
	// Everyone faces east, so the right hand is the one the crowd sees. Gunners keep the gun there
	// and the mic in the other.
	if(look["gun"])
		npc.put_in_r_hand(new /obj/item/toy/gun(npc))
		npc.put_in_l_hand(new /obj/item/fnf_microphone(npc))
	else
		npc.put_in_r_hand(new /obj/item/fnf_microphone(npc))
	return npc
