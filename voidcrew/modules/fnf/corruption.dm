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
 * Clothes it's taken go dark violet, and their bright trims glow hot pink.
 *
 * Fighting it off doesn't run that backwards. Like the mod's Pico and Kapi breaking free for a
 * while, the head comes back first (their hair, then half their face: the near eye), and the near
 * hand with it, while the body comes back only slowly and the far side stays taken.
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
	/// The furthest it's got since the body was last clean: anything less is being fought off.
	var/corruption_peak = 0
	/// The colour its corrupted eyes glow: "pink", or "red".
	var/corruption_eyes = "pink"
	/// What corruption's drawn on each piece, by piece.
	var/list/corruption_images

/// Corrupts the body this far (0 to 1), its eyes glowing pink or red once its face is taken.
/datum/limb_rig/proc/set_corruption(level, eyes = "pink")
	corruption = clamp(level, 0, 1)
	corruption_peak = corruption ? max(corruption_peak, corruption) : 0
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
	var/list/tainted_clothes
	for(var/list/piece_info as anything in get_corruption_pieces())
		var/atom/movable/piece = piece_info[1]
		var/part_id = piece_info[2]
		var/size = piece_info[3]
		if(!piece)
			continue
		var/list/images = list()
		var/amount = round(get_corruption_of(part_id, far_side) * 8)
		var/is_cloth = size == 32
		// Clothes taken (most of the way) go dark violet, their bright trims glowing hot pink, rather than coated.
		var/tainted = is_cloth && amount >= 6
		if(amount && !tainted)
			var/image/coat = image(size == 64 ? 'voidcrew/modules/fnf/icons/corruption_64.dmi' : 'voidcrew/modules/fnf/icons/corruption_32.dmi', "splotch_[amount]")
			coat.blend_mode = BLEND_INSET_OVERLAY
			coat.color = FNF_CORRUPTION_COLOUR
			coat.alpha = 235
			coat.pixel_w = size == 64 ? -16 : 0
			coat.layer = FLOAT_LAYER - 0.01
			images += coat
		// The Experiment's orange tail tip glows hot pink as it's taken.
		var/tip = part_id == RIG_TAIL ? get_corruption_tail_tip() : null
		if(tip && amount)
			var/image/glow = image('voidcrew/modules/fnf/icons/corruption_64.dmi', tip)
			glow.color = FNF_CORRUPTION_TRIM
			glow.alpha = amount * 32 - 1
			glow.appearance_flags = RESET_COLOR
			glow.pixel_w = -16
			glow.layer = FLOAT_LAYER - 0.004
			images += glow
		var/hands = piece_info[4]
		// Red hands, gloves and all, until the hand's fought free.
		if(hands && corruption >= 0.2 && get_corruption_fought(part_id, far_side) < 0.5)
			var/image/red = image(is_cloth ? 'voidcrew/modules/fnf/icons/corruption_32.dmi' : 'voidcrew/modules/fnf/icons/corruption_64.dmi', hands)
			red.color = FNF_CORRUPTION_HANDS
			// Blood red whatever's drained the rest, and only on the glove or the hand itself.
			red.appearance_flags = RESET_COLOR
			red.blend_mode = BLEND_INSET_OVERLAY
			red.pixel_w = is_cloth ? 0 : -16
			red.layer = FLOAT_LAYER - 0.005
			images += red
		piece.add_overlay(images)
		if(tainted && !tainted_clothes)
			tainted_clothes = get_tainted_clothes_matrix()
		piece.color = tainted ? tainted_clothes : drained
		corruption_images[piece] = images

/**
 * The colour matrix for clothes corruption's taken whole: their main colour turns its dark violet,
 * anything darker goes on down to black, and anything brighter (trims, stripes, buttons, highlights)
 * climbs to hot pink.
 */
/datum/limb_rig/proc/get_tainted_clothes_matrix()
	var/list/main = rgb2num(get_main_clothes_colour())
	var/main_brightness = (main[1] * 0.3 + main[2] * 0.59 + main[3] * 0.11) / 255
	var/list/violet = rgb2num(FNF_CORRUPTION_CLOTHES_COLOUR)
	var/list/trim = rgb2num(FNF_CORRUPTION_TRIM)
	var/list/weights = list(0.3, 0.59, 0.11)
	. = new /list(12)
	for(var/channel in 1 to 3)
		// How fast this channel climbs from violet to pink with brightness.
		var/climb = (trim[channel] - violet[channel]) / 255 / FNF_CORRUPTION_TRIM_RISE
		for(var/source in 1 to 3)
			.[(source - 1) * 3 + channel] = climb * weights[source]
		.[9 + channel] = violet[channel] / 255 - climb * main_brightness

/// What colour the owner's clothes mostly are: their outer suit's, or else their jumpsuit's.
/datum/limb_rig/proc/get_main_clothes_colour()
	var/mob/living/carbon/human/wearer = owner
	if(istype(wearer))
		for(var/obj/item/worn in list(wearer.wear_suit, wearer.w_uniform))
			var/list/colours = worn.greyscale_colors ? splittext(worn.greyscale_colors, "#") : null
			if(length(colours) > 1 && length(colours[2]) == 6)
				return "#[colours[2]]"
			if(istext(worn.color))
				return worn.color
	return "#737373"

/**
 * How far corruption has taken one piece of the body, 0 to 1: the far side first, then the near
 * limbs, the body, and the head last. Whatever's been fought off since its peak is taken back out.
 */
/datum/limb_rig/proc/get_corruption_of(part_id, far_side)
	return get_corruption_spread(part_id, far_side, corruption_peak) * (1 - get_corruption_fought(part_id, far_side))

/**
 * How much of one piece has been fought free, 0 to 1, going by how far the body's come back from
 * its peak: the head first, the near hand and the body next, the far side last.
 */
/datum/limb_rig/proc/get_corruption_fought(part_id, far_side)
	var/fought = corruption_peak - corruption
	if(fought <= 0)
		return 0
	var/delay
	switch(part_id)
		if(RIG_HEAD)
			delay = 0
		if(RIG_CHEST)
			delay = 0.2
		if(RIG_TAIL, "wings")
			delay = 0.3
		else
			var/side = copytext(part_id, 1, 2)
			var/is_arm = findtext(part_id, "arm")
			if(!far_side)
				delay = 0.2
			else if(side == far_side)
				delay = is_arm ? 0.4 : 0.35
			else if(findtext(part_id, "forearm"))
				delay = 0.03
			else
				delay = is_arm ? 0.2 : 0.25
	return clamp((fought - delay) / FNF_CORRUPTION_FIGHT, 0, 1)

/// How far corruption at this level spreads over one piece, 0 to 1.
/datum/limb_rig/proc/get_corruption_spread(part_id, far_side, level)
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
	return clamp((level - start) / FNF_CORRUPTION_SPAN, 0, 1)

/// The mask of the tail's own bright tip, to glow once it's taken, if it has one.
/datum/limb_rig/proc/get_corruption_tail_tip()
	return null

/datum/limb_rig/sprites/get_corruption_tail_tip()
	return fnf_face_set ? "tail_[fnf_face_set]" : null

/// Every piece corruption draws on: list(piece, piece id, its sprites' size, its hand mask or null).
/datum/limb_rig/proc/get_corruption_pieces()
	return list()

/datum/limb_rig/sprites/get_corruption_pieces()
	. = list()
	var/hand_set = istype(src, /datum/limb_rig/sprites/humanoid) ? "humanoid" : fnf_face_set
	for(var/part_id in parts)
		var/hands = hand_set && findtext(part_id, "_forearm") ? "hands_[hand_set]_[part_id]" : null
		. += list(list(parts[part_id], part_id, 64, hands))
	for(var/part_id in cloth_parts)
		. += list(list(cloth_parts[part_id], part_id, 32, findtext(part_id, "_forearm") ? "hands_cloth" : null))
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
	/// The song's overlays, flashes, animations and shakes (see /datum/fnf_song/var/overlay_events), in order.
	var/list/overlay_events
	var/next_overlay = 1
	/// Everyone it's touched, to put right after.
	var/list/mob/living/carbon/touched = list()
	/// Over the whole view: the song's overlay, a flash, and the dark that comes down on a miss.
	var/obj/effect/abstract/fnf_hud/overlay
	var/obj/effect/abstract/fnf_hud/flash
	var/obj/effect/abstract/fnf_hud/miss_dark
	/// The tainted health bar's frame, in Skarlet's songs.
	var/obj/effect/abstract/fnf_hud/bar_frame

/datum/fnf_corruption/New(datum/fnf_battle/battle)
	src.battle = battle
	var/datum/fnf_song/song = battle.song
	changes = song.character_changes || list()
	overlay_events = song.overlay_events || list()
	apply("player", song.legacy_cast["player"])
	apply("opponent", song.legacy_cast["opponent"])
	apply("gf", song.legacy_cast["gf"])
	make_screens()

/datum/fnf_corruption/Destroy()
	for(var/mob/living/carbon/singer as anything in touched)
		if(QDELETED(singer))
			continue
		singer.limb_rig?.set_corruption(0)
		singer.alpha = initial(singer.alpha)
		if(HAS_TRAIT_FROM(singer, TRAIT_MOVE_FLOATING, FNF_BATTLE_TRAIT))
			REMOVE_TRAIT(singer, TRAIT_MOVE_FLOATING, FNF_BATTLE_TRAIT)
	touched.Cut()
	for(var/obj/effect/abstract/fnf_hud/screen as anything in list(overlay, flash, miss_dark, bar_frame))
		battle?.healthbar?.vis_contents -= screen
		qdel(screen)
	overlay = null
	flash = null
	miss_dark = null
	bar_frame = null
	battle = null
	return ..()

/datum/fnf_corruption/proc/tick(now)
	while(next_change <= length(changes))
		var/list/change = changes[next_change]
		if(change[1] > now)
			break
		next_change++
		apply(change[2], change[3])
	while(next_overlay <= length(overlay_events))
		var/list/event = overlay_events[next_overlay]
		if(event[1] > now)
			break
		next_overlay++
		show(event[2], event[3], event[4])

/**
 * What's laid over the whole view, as the mod lays it over its screen: under the arrows, over
 * everything else, centred where the singers' cameras look. And in Skarlet's songs, her tainted
 * frame round the health bar.
 */
/datum/fnf_corruption/proc/make_screens()
	var/obj/effect/abstract/fnf_hud/healthbar/bar = battle.healthbar
	if(!bar)
		return
	var/view_x = battle.camera_x - bar.x * world.icon_size
	var/view_y = battle.camera_y - bar.y * world.icon_size
	for(var/i in 1 to 3)
		var/obj/effect/abstract/fnf_hud/screen = new
		screen.icon = 'voidcrew/modules/fnf/icons/fnf_corruption_overlays.dmi'
		screen.alpha = 0
		// A quarter the mod's size, and a little bigger than the singers see: always to the edges.
		screen.pixel_w = view_x - 160
		screen.pixel_z = view_y - 90
		screen.transform = matrix() * 1.4
		screen.layer = ABOVE_ALL_MOB_LAYER + 0.005 + i * 0.0001
		bar.vis_contents += screen
		switch(i)
			if(1)
				overlay = screen
			if(2)
				flash = screen
			if(3)
				miss_dark = screen
				miss_dark.icon_state = "overlayskarlet"
	if(battle.song.note_skin == "skarlet")
		bar_frame = new
		bar_frame.icon = 'voidcrew/modules/fnf/icons/fnf_healthbar_tainted.dmi'
		bar_frame.icon_state = "frame"
		bar_frame.pixel_w = bar.center_x - 72
		bar_frame.pixel_z = bar.center_y - 16
		bar_frame.layer = ABOVE_ALL_MOB_LAYER + 0.04
		bar.vis_contents += bar_frame

/**
 * The mod's overlay and flash events: an overlay fades in over three quarters of a second (value
 * 1) or back out (value 0); a flash is up for its value in seconds, then fades out quickly.
 */
/datum/fnf_corruption/proc/show(kind, image_name, value)
	if(kind == "anim")
		act_out(image_name, value)
		return
	if(kind == "shake")
		for(var/mob/listener as anything in battle.listeners)
			shake_camera(listener, max(round(value * 10), 1), 1)
		return
	var/static/list/images = icon_states('voidcrew/modules/fnf/icons/fnf_corruption_overlays.dmi')
	// Missing ones (the mod names a "yourcalls" it doesn't have) are skipped, as the mod skips them.
	if(!overlay || !(image_name in images))
		return
	if(kind == "overlay")
		if(value)
			overlay.icon_state = image_name
			animate(overlay, alpha = 255, time = 7.5, easing = QUAD_EASING)
		else if(overlay.icon_state == image_name)
			animate(overlay, alpha = 0, time = 7.5, easing = QUAD_EASING)
		return
	flash.icon_state = image_name
	flash.alpha = 255
	animate(flash, alpha = 255, time = max(value, 0.1) * 10)
	animate(alpha = 0, time = 3)

/// Someone acting out one of the mod's animations. Only the scream has a move here.
/datum/fnf_corruption/proc/act_out(animation, who)
	if(animation != "scream")
		return
	var/static/list/players = list("bf", "boyfriend", "0")
	var/static/list/opponents = list("dad", "1")
	if(who in players)
		battle.right?.scream()
	else if(who in opponents)
		battle.left?.scream()

/**
 * A miss in Skarlet's songs: the dark comes down over everything at once and the music drops out,
 * then both come back over a second or two.
 */
/datum/fnf_corruption/proc/player_missed()
	if(battle.song.note_skin != "skarlet" || !miss_dark)
		return
	animate(miss_dark, alpha = 255, time = 1, easing = QUAD_EASING|EASE_OUT)
	animate(alpha = 255, time = 10)
	animate(alpha = 0, time = 10)
	for(var/channel in list(battle.inst_channel, battle.left_voice_channel))
		battle.set_channel_volume(channel, 0)
		for(var/step in 1 to 5)
			addtimer(CALLBACK(battle, TYPE_PROC_REF(/datum/fnf_battle, set_channel_volume), channel, step / 5), 5 + step * 3, TIMER_DELETE_ME)

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
