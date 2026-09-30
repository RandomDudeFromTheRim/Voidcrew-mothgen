/**
 * Corruption, from Carlito049's Corruption+ (a fan extension of Phantom Fear and Pincer's
 * Corruption mod): songs where a dark violet corruption eats its singers.
 *
 * A corruption song says who it starts with and when anyone changes, the way the mod does it: its
 * chart names the player, the opponent and whoever's in the girlfriend's place, and its "Change
 * Character" events swap them mid-song. Each of the mod's characters is a look and a level of
 * corruption here (GLOB.fnf_corruption_cast): Kapi goes from himself to fully corrupted over the
 * arcade songs, the corrupted Pico and Kapi fight it off and lose it again, the "bait" versions are
 * flashbacks to before. Whoever sings as the player keeps their own look and takes on the level;
 * the opponent and whoever's behind them are summoned as the mod's characters.
 *
 * Corruption spreads as it does in the mod's sprites: the far side first (the arm and leg away
 * from the crowd, the tail), then the hands go red, then the near limbs, the body and the head,
 * each piece taken over in growing dark violet splotches while every colour drains. Once the
 * head's gone, the face glows hot pink: "( • )" eyes turned on their side and a candy-corn grin.
 */

/**
 * The mod's characters: each a look (see opponents.dm; null for nobody, just the speakers), how
 * corrupted they are, and anything else about them: "eyes" ("red" instead of pink), "wings"
 * ("angel", "demon"), "flying".
 */
GLOBAL_LIST_INIT(fnf_corruption_cast, list(
	// Pico, corrupted from the start of the arcade; the second and third fight back (orange hair and
	// a green collar through the dark, then half his face), then it takes him again.
	"corruptedpico" = list("look" = "pico", "level" = 1),
	"corruptedpico2" = list("look" = "pico", "level" = 0.85),
	"corruptedpico3" = list("look" = "pico", "level" = 0.7),
	"corruptedpico4" = list("look" = "pico", "level" = 1),
	"corruptedpico5" = list("look" = "pico", "level" = 1),
	"pico-bait" = list("look" = "pico", "level" = 0),
	// Kapi at his arcade machine, taken a little more each time: a red hand, then the far side, then
	// half his face, then all of him.
	"kapi" = list("look" = "kapi", "level" = 0),
	"kapi1" = list("look" = "kapi", "level" = 0.08),
	"kapi2" = list("look" = "kapi", "level" = 0.25),
	"kapi3" = list("look" = "kapi", "level" = 0.45),
	"kapi4" = list("look" = "kapi", "level" = 0.65),
	"kapi5" = list("look" = "kapi", "level" = 0.85),
	"kapi6" = list("look" = "kapi", "level" = 1),
	"kapi-bait" = list("look" = "kapi", "level" = 0),
	// Kapi corrupted, hunting: he fights it (a grey ear and his blue coming back), then his eyes go red.
	"corruptedkapi" = list("look" = "kapi", "level" = 1),
	"corruptedkapi2" = list("look" = "kapi", "level" = 1),
	"corruptedkapi3" = list("look" = "kapi", "level" = 0.75),
	"corruptedkapi35" = list("look" = "kapi", "level" = 0.85),
	"corruptedkapi4" = list("look" = "kapi", "level" = 1, "eyes" = "red"),
	"morabait" = list("look" = "mora", "level" = 0),
	// Skarlet Bunny, with the corruption at her boots from the start.
	"skarlet1" = list("look" = "skarlet", "level" = 0.1),
	"skarlet2" = list("look" = "skarlet", "level" = 0.35),
	"skarlet3" = list("look" = "skarlet", "level" = 0.75),
	// Marble, behind the speaker, long gone.
	"corruptedmarble" = list("look" = "marble", "level" = 1),
	"corruptedmarble2" = list("look" = "marble", "level" = 0.9),
	"corruptedmarble3" = list("look" = "marble", "level" = 1),
	// Carol in the church ruins, then flying, half angel and half demon, then all demon.
	"carol1" = list("look" = "carol", "level" = 0.05),
	"carol2" = list("look" = "carol", "level" = 0.15),
	"carolBait" = list("look" = "carol", "level" = 0),
	"Acarol3" = list("look" = "carol", "level" = 0.6, "wings" = "angel", "flying" = TRUE),
	"Acarol4" = list("look" = "carol", "level" = 0.6, "wings" = "angel", "flying" = TRUE),
	"Acarol5" = list("look" = "carol", "level" = 0.9, "wings" = "demon", "flying" = TRUE),
	// Girlfriend, corrupted, singing and flying; Boyfriend corrupted on the speakers.
	"corruptedgirlfriend" = list("look" = "gf", "level" = 1),
	"corruptedgirlfriendBait" = list("look" = "gf", "level" = 0),
	"corruptedgirlfriendflying" = list("look" = "gf", "level" = 0.9, "flying" = TRUE),
	"corruptedgirlfriendflying2" = list("look" = "gf", "level" = 1, "flying" = TRUE),
	"EVILspeakersGF" = list("look" = "gf", "level" = 1),
	"EVILspeakersBF" = list("look" = "bf", "level" = 1),
	"EVILspeakersBFbait" = list("look" = "bf", "level" = 0),
	"GFPcorruptedBF" = list("look" = "bf", "level" = 1),
	"corruptedbf2" = list("look" = "bf", "level" = 1),
	// Nobody: just the speakers, or an empty stage.
	"speakers" = list("look" = null),
	"EVILspeakers" = list("look" = null),
	"nocharacter" = list("look" = null, "hidden" = TRUE),
))

// The body.

/datum/limb_rig
	/// How far corruption has taken this body, 0 to 1.
	var/corruption = 0
	/// The colour its corrupted eyes glow: "pink", or "red".
	var/corruption_eyes = "pink"
	/// What corruption's drawn on each piece, by piece.
	var/list/corruption_images

/// Corrupts the body this far (0 to 1), its eyes glowing pink or red once its face is taken.
/datum/limb_rig/proc/set_corruption(level, eyes = "pink")
	corruption = clamp(level, 0, 1)
	corruption_eyes = eyes || "pink"
	refresh_corruption()
	refresh_fnf_face()

/datum/limb_rig/proc/refresh_corruption()
	for(var/atom/movable/piece as anything in corruption_images)
		piece.cut_overlay(corruption_images[piece])
		piece.color = null
	corruption_images = null
	if(!corruption)
		return
	corruption_images = list()
	var/far_side = get_facing() == EAST ? "l" : (get_facing() == WEST ? "r" : null)
	var/drained = color_matrix_saturation(1 - corruption * 0.7)
	for(var/list/piece_info as anything in get_corruption_pieces())
		var/atom/movable/piece = piece_info[1]
		var/part_id = piece_info[2]
		var/size = piece_info[3]
		if(!piece)
			continue
		var/list/images = list()
		var/amount = round(get_corruption_of(part_id, far_side) * 8)
		if(amount)
			var/image/coat = image(size == 64 ? 'voidcrew/modules/fnf/icons/corruption_64.dmi' : 'voidcrew/modules/fnf/icons/corruption_32.dmi', "splotch_[amount]")
			coat.blend_mode = BLEND_INSET_OVERLAY
			coat.color = FNF_CORRUPTION_COLOUR
			coat.alpha = 235
			coat.pixel_w = size == 64 ? -16 : 0
			coat.layer = FLOAT_LAYER - 0.01
			images += coat
		var/hands = piece_info[4]
		if(hands && corruption >= 0.2)
			var/image/red = image('voidcrew/modules/fnf/icons/corruption_64.dmi', hands)
			red.color = FNF_CORRUPTION_HANDS
			red.pixel_w = -16
			red.layer = FLOAT_LAYER - 0.005
			images += red
		piece.add_overlay(images)
		piece.color = drained
		corruption_images[piece] = images

/**
 * How far corruption has taken one piece of the body, 0 to 1: the far side first, then the near
 * limbs, the body, and the head last.
 */
/datum/limb_rig/proc/get_corruption_of(part_id, far_side)
	var/start
	switch(part_id)
		if(RIG_CHEST)
			start = 0.3
		if(RIG_HEAD)
			start = 0.5
		if(RIG_TAIL)
			start = 0.05
		if("wings")
			start = 0.1
		else
			var/side = copytext(part_id, 1, 2)
			var/is_arm = findtext(part_id, "arm")
			if(!far_side)
				start = 0.15
			else if(side == far_side)
				start = is_arm ? 0 : 0.05
			else
				start = is_arm ? 0.35 : 0.25
	return clamp((corruption - start) / FNF_CORRUPTION_SPAN, 0, 1)

/// Every piece corruption draws on: list(piece, piece id, its sprites' size, its hand mask or null).
/datum/limb_rig/proc/get_corruption_pieces()
	return list()

/datum/limb_rig/sprites/get_corruption_pieces()
	. = list()
	var/hand_set = istype(src, /datum/limb_rig/sprites/humanoid) ? "humanoid" : (sprite_icon == 'voidcrew/modules/expie/icons/rig.dmi' ? "experiment" : null)
	for(var/part_id in parts)
		var/hands = hand_set && findtext(part_id, "_forearm") ? "hands_[hand_set]_[part_id]" : null
		. += list(list(parts[part_id], part_id, 64, hands))
	for(var/part_id in cloth_parts)
		. += list(list(cloth_parts[part_id], part_id, 32, null))
	for(var/side in shoe_parts)
		. += list(list(shoe_parts[side], "[side]_foot", 32, null))

/datum/limb_rig/sprites/humanoid/get_corruption_pieces()
	. = ..()
	. += list(list(wings_part, "wings", 32, null))
	. += list(list(tail_part, RIG_TAIL, 32, null))

/// Which side's far changes with facing: corruption goes with it.
/datum/limb_rig/refresh_facing()
	. = ..()
	if(corruption)
		refresh_corruption()

// Singing it.

/**
 * A corruption song's cast, played out: the player taking on whoever the song says they are now,
 * the summoned opponent and the one behind them changing with the song.
 */
/datum/fnf_corruption
	var/datum/fnf_battle/battle
	/// The changes still to come: list(list(ms, role, character), ...), in order.
	var/list/changes
	var/next_change = 1
	/// Everyone it's touched, to put right after.
	var/list/mob/living/carbon/touched = list()

/datum/fnf_corruption/New(datum/fnf_battle/battle)
	src.battle = battle
	var/datum/fnf_song/song = battle.song
	changes = song.character_changes || list()
	apply("player", song.legacy_cast["player"])
	apply("opponent", song.legacy_cast["opponent"])
	apply("gf", song.legacy_cast["gf"])

/datum/fnf_corruption/Destroy()
	for(var/mob/living/carbon/singer as anything in touched)
		if(QDELETED(singer))
			continue
		singer.limb_rig?.set_corruption(0)
		singer.alpha = initial(singer.alpha)
		if(HAS_TRAIT_FROM(singer, TRAIT_MOVE_FLOATING, FNF_BATTLE_TRAIT))
			REMOVE_TRAIT(singer, TRAIT_MOVE_FLOATING, FNF_BATTLE_TRAIT)
	touched.Cut()
	battle = null
	return ..()

/datum/fnf_corruption/proc/tick(now)
	while(next_change <= length(changes))
		var/list/change = changes[next_change]
		if(change[1] > now)
			return
		next_change++
		apply(change[2], change[3])

/// Makes someone on stage whoever the song says they are now.
/datum/fnf_corruption/proc/apply(role, character)
	var/list/cast = GLOB.fnf_corruption_cast[character]
	if(!cast)
		return
	switch(role)
		if("player")
			corrupt(battle.right?.singer, cast)
		if("opponent")
			corrupt(battle.left?.singer, cast)
		if("gf")
			var/datum/fnf_stage/stage = battle.stage
			if(!stage)
				return
			if(!cast["look"])
				if(stage.girlfriend)
					stage.girlfriend.alpha = 0
				return
			if(!stage.girlfriend || stage.girlfriend.fnf_look != cast["look"])
				QDEL_NULL(stage.girlfriend)
				stage.summon_girlfriend_as(cast["look"])
			if(stage.girlfriend)
				stage.girlfriend.alpha = 255
				corrupt(stage.girlfriend, cast)

/datum/fnf_corruption/proc/corrupt(mob/living/carbon/singer, list/cast)
	if(!istype(singer))
		return
	touched |= singer
	singer.alpha = cast["hidden"] ? 0 : initial(singer.alpha)
	singer.limb_rig?.set_corruption(cast["level"] || 0, cast["eyes"])
	// Only the song's own characters grow wings; a player stays as they are.
	if(singer == battle.npc || singer == battle.stage?.girlfriend)
		fnf_set_wings(singer, cast["wings"])
	if(cast["flying"])
		ADD_TRAIT(singer, TRAIT_MOVE_FLOATING, FNF_BATTLE_TRAIT)
	else
		REMOVE_TRAIT(singer, TRAIT_MOVE_FLOATING, FNF_BATTLE_TRAIT)

/// Gives a summoned singer wings for the song ("angel", "demon"), or takes them away.
/proc/fnf_set_wings(mob/living/carbon/singer, wings)
	var/obj/item/organ/wings/current = singer.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	var/wanted_type = wings == "angel" ? /obj/item/organ/wings/functional/angel : (wings == "demon" ? /obj/item/organ/wings/functional/dragon : null)
	if(current && (!wanted_type || current.type != wanted_type))
		// Only wings the song gave: a singer's own stay.
		if(!HAS_TRAIT_FROM(current, TRAIT_NODROP, FNF_BATTLE_TRAIT))
			return
		current.Remove(singer)
		qdel(current)
		current = null
	if(wanted_type && !current)
		var/obj/item/organ/wings/given = new wanted_type
		ADD_TRAIT(given, TRAIT_NODROP, FNF_BATTLE_TRAIT)
		given.Insert(singer, special = TRUE)
