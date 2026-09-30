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

/mob/living/carbon
	/// Corruption on this body, kept on the mob so a rebuilt rig (a species change, or one that isn't
	/// made yet) picks it up: list(level, peak, eyes), or null when clean.
	var/list/fnf_corruption_state

/// Corrupts this body (see /datum/limb_rig/proc/set_corruption()), rig or no rig yet.
/mob/living/carbon/proc/fnf_set_corruption(level, eyes)
	if(limb_rig)
		limb_rig.set_corruption(level, eyes)
		return
	level = clamp(level, 0, 1)
	fnf_corruption_state = level ? list(level, max(fnf_corruption_state?[2] || 0, level), eyes || "pink") : null

/datum/limb_rig/New(mob/living/carbon/owner)
	. = ..()
	var/list/state = owner.fnf_corruption_state
	if(state)
		corruption = state[1]
		corruption_peak = state[2]
		corruption_eyes = state[3]
		refresh_corruption()

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
	owner.fnf_corruption_state = corruption ? list(corruption, corruption_peak, corruption_eyes) : null
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
	// Dark clothes stay dark, only what really stands out on them glowing: going by a dark main
	// colour itself would send every shade on them pink.
	var/main_brightness = max((main[1] * 0.3 + main[2] * 0.59 + main[3] * 0.11) / 255, FNF_CORRUPTION_DARKEST_MAIN)
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
			if(worn)
				return get_icon_main_colour(worn.icon, worn.icon_state)
	return "#737373"

/// The colour most of an icon is (its outline and anything nearly black aside), worked out once per icon.
/proc/get_icon_main_colour(icon_file, icon_state)
	var/static/list/found = list()
	var/key = "[icon_file]-[icon_state]"
	if(found[key])
		return found[key]
	var/icon/sprite = icon(icon_file, icon_state, SOUTH, 1)
	var/list/counts = list()
	for(var/x in 1 to sprite.Width())
		for(var/y in 1 to sprite.Height())
			var/pixel = sprite.GetPixel(x, y)
			if(!pixel)
				continue
			var/list/rgb = rgb2num(pixel)
			if(length(rgb) > 3 && rgb[4] < 128)
				continue
			if(rgb[1] + rgb[2] + rgb[3] < 60)
				continue
			var/colour = copytext(pixel, 1, 8)
			counts[colour] = (counts[colour] || 0) + 1
	var/best = "#737373"
	var/most = 0
	for(var/colour in counts)
		if(counts[colour] > most)
			most = counts[colour]
			best = colour
	found[key] = best
	return best

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
	/// Everyone shown the song's screens (see get_screens()), to take them down after.
	var/list/mob/viewers = list()
	/// Who's drawn as a silhouette right now (the "Bad Apple" events), and in what colour.
	var/list/mob/silhouetted = list()
	/// Which silhouettes are up: "white" (black figures on white), "black" (white on black),
	/// "colour" (each in their colour, on black), or null.
	var/apple
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
		singer.fnf_set_corruption(0)
		singer.alpha = initial(singer.alpha)
		if(HAS_TRAIT_FROM(singer, TRAIT_MOVE_FLOATING, FNF_BATTLE_TRAIT))
			REMOVE_TRAIT(singer, TRAIT_MOVE_FLOATING, FNF_BATTLE_TRAIT)
	touched.Cut()
	set_apple(null, 0)
	for(var/mob/viewer as anything in viewers)
		for(var/category in GLOB.fnf_corruption_screens)
			viewer.clear_fullscreen(category, FALSE)
	viewers.Cut()
	battle?.healthbar?.vis_contents -= bar_frame
	QDEL_NULL(bar_frame)
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

/// In Skarlet's songs, her tainted frame round the health bar.
/datum/fnf_corruption/proc/make_screens()
	var/obj/effect/abstract/fnf_hud/healthbar/bar = battle.healthbar
	if(!bar || battle.song.note_skin != "skarlet")
		return
	bar_frame = new
	bar_frame.icon = 'voidcrew/modules/fnf/icons/fnf_healthbar_tainted.dmi'
	bar_frame.icon_state = "frame"
	bar_frame.pixel_w = bar.center_x - 72
	bar_frame.pixel_z = bar.center_y - 16
	bar_frame.layer = ABOVE_ALL_MOB_LAYER + 0.04
	bar.vis_contents += bar_frame

/**
 * One of the song's screens (see GLOB.fnf_corruption_screens) for everyone listening: laid over
 * each of their own views, sized to it, as the mod lays them over its screen.
 */
/datum/fnf_corruption/proc/get_screens(category)
	. = list()
	var/screen_type = GLOB.fnf_corruption_screens[category]
	for(var/mob/viewer as anything in battle.listeners)
		if(!viewer.client)
			continue
		viewers |= viewer
		. += viewer.overlay_fullscreen(category, screen_type)

/**
 * The mod's screen events, as it plays them:
 * - "overlay": an overlay fades in over three quarters of a second (value 1) or back out (0)
 * - "flash": an overlay up for its value in seconds, then quickly gone
 * - "light": the screen flashes a colour (the image), fading over the value in seconds
 * - "black": the screen fades to black over the value in seconds (image "1"), or comes back ("0")
 * - "bloom": a burst of glow, as strong as the value
 * - "apple": silhouettes (see set_apple()), the image saying which, over the value in seconds
 * - "anim": someone on stage acts something out (the image), the value saying who
 * - "shake": the screen shakes for the value in seconds
 */
/datum/fnf_corruption/proc/show(kind, image_name, value)
	switch(kind)
		if("anim")
			act_out(image_name, value)
		if("shake")
			for(var/mob/listener as anything in battle.listeners)
				shake_camera(listener, max(round(value * 10), 1), 1)
		if("overlay", "flash")
			var/static/list/images = icon_states('voidcrew/modules/fnf/icons/fnf_corruption_overlays.dmi')
			// Missing ones (the mod names a "yourcalls" it doesn't have) are skipped, as the mod skips them.
			if(!(image_name in images))
				return
			// The overlay itself, and its edges carried on above and below it.
			var/list/shown = list()
			for(var/part in list("", "_top", "_bottom"))
				for(var/atom/movable/screen/fullscreen/fnf/corruption/screen as anything in get_screens("fnf_corruption_[kind][part]"))
					shown[screen] = "[image_name][part]"
			for(var/atom/movable/screen/fullscreen/fnf/corruption/screen as anything in shown)
				if(kind == "flash")
					screen.icon_state = shown[screen]
					screen.alpha = 255
					animate(screen, alpha = 255, time = max(value, 0.1) * 10)
					animate(alpha = 0, time = 3)
				else if(value)
					screen.icon_state = shown[screen]
					animate(screen, alpha = 255, time = 7.5, easing = QUAD_EASING)
				else if(screen.icon_state == shown[screen])
					animate(screen, alpha = 0, time = 7.5, easing = QUAD_EASING)
		if("light")
			for(var/atom/movable/screen/fullscreen/fnf/corruption/fill/screen as anything in get_screens("fnf_corruption_light"))
				screen.color = image_name
				screen.alpha = 255
				animate(screen, alpha = 0, time = max(value, 0.1) * 10)
		if("black")
			for(var/atom/movable/screen/fullscreen/fnf/corruption/fill/screen as anything in get_screens("fnf_corruption_black"))
				if(image_name == "1")
					animate(screen, alpha = 255, time = max(value, 0.1) * 10, easing = QUAD_EASING)
				else
					animate(screen, alpha = 0, time = 0)
		if("bloom")
			for(var/atom/movable/screen/fullscreen/fnf/corruption/fill/screen as anything in get_screens("fnf_corruption_bloom"))
				screen.alpha = clamp(round(value * 45), 0, 120)
				animate(screen, alpha = 0, time = 8)
		if("apple")
			var/mode = image_name
			if(mode == "toggle-black")
				mode = apple == "black" ? null : "black"
			else if(mode == "toggle-colour")
				mode = apple == "colour" ? null : "colour"
			else if(mode == "off")
				mode = null
			set_apple(mode, value)

/**
 * The mod's "Bad Apple" moments: the stage blacked or whited out behind everyone on it, and them
 * drawn as flat silhouettes against it: black on white, white on black, or each in their own colour.
 */
/datum/fnf_corruption/proc/set_apple(mode, seconds)
	for(var/mob/living/figure as anything in silhouetted)
		if(!QDELETED(figure))
			figure.remove_atom_colour(ADMIN_COLOUR_PRIORITY, silhouetted[figure])
	silhouetted.Cut()
	apple = mode
	if(!battle)
		return
	for(var/atom/movable/screen/fullscreen/fnf/corruption/fill/screen as anything in get_screens("fnf_corruption_backdrop"))
		if(mode)
			screen.color = mode == "white" ? "#ffffff" : "#000000"
			animate(screen, alpha = 255, time = max(seconds, 0.1) * 10)
		else
			animate(screen, alpha = 0, time = max(seconds, 0.1) * 10)
	if(!mode)
		return
	// Each in their colour on the health bar (the girlfriend in hers).
	var/list/figures = list()
	if(battle.left?.singer)
		figures[battle.left.singer] = "#e0453a"
	if(battle.right?.singer)
		figures[battle.right.singer] = "#5de83a"
	if(battle.stage?.girlfriend)
		figures[battle.stage.girlfriend] = "#a5004d"
	for(var/mob/living/figure in figures)
		if(QDELETED(figure))
			continue
		var/list/rgb = rgb2num(figures[figure])
		var/silhouette
		switch(mode)
			if("white")
				silhouette = "#000000"
			if("black")
				silhouette = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1)
			else
				silhouette = list(0, 0, 0, 0, 0, 0, 0, 0, 0, rgb[1] / 255, rgb[2] / 255, rgb[3] / 255)
		figure.add_atom_colour(silhouette, ADMIN_COLOUR_PRIORITY)
		silhouetted[figure] = silhouette

/// Someone acting out one of the mod's animations, the way the stage acts out Funkin's own.
/datum/fnf_corruption/proc/act_out(animation, who)
	var/static/list/roles = list("bf" = "bf", "boyfriend" = "bf", "0" = "bf", "dad" = "dad", "1" = "dad", "gf" = "gf", "girlfriend" = "gf", "2" = "gf")
	battle.stage?.play_animation(roles[lowertext(who)], lowertext(animation))

/**
 * A miss in Skarlet's songs: the dark comes down over everything at once and the music drops out,
 * then both come back over a second or two.
 */
/datum/fnf_corruption/proc/player_missed()
	if(battle.song.note_skin != "skarlet")
		return
	for(var/part in list("", "_top", "_bottom"))
		for(var/atom/movable/screen/fullscreen/fnf/corruption/screen as anything in get_screens("fnf_corruption_dark[part]"))
			screen.icon_state = "overlayskarlet[part]"
			animate(screen, alpha = 255, time = 1, easing = QUAD_EASING|EASE_OUT)
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
	singer.fnf_set_corruption(cast["level"] || 0, cast["eyes"])
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

// The song's screens: laid over each listener's own view, under the arrows and over the world.

/// Every screen a corruption song puts up, by fullscreen category.
GLOBAL_LIST_INIT(fnf_corruption_screens, list(
	"fnf_corruption_backdrop" = /atom/movable/screen/fullscreen/fnf/corruption/fill/backdrop,
	"fnf_corruption_overlay" = /atom/movable/screen/fullscreen/fnf/corruption,
	"fnf_corruption_overlay_top" = /atom/movable/screen/fullscreen/fnf/corruption/top,
	"fnf_corruption_overlay_bottom" = /atom/movable/screen/fullscreen/fnf/corruption/bottom,
	"fnf_corruption_flash" = /atom/movable/screen/fullscreen/fnf/corruption,
	"fnf_corruption_flash_top" = /atom/movable/screen/fullscreen/fnf/corruption/top,
	"fnf_corruption_flash_bottom" = /atom/movable/screen/fullscreen/fnf/corruption/bottom,
	"fnf_corruption_dark" = /atom/movable/screen/fullscreen/fnf/corruption,
	"fnf_corruption_dark_top" = /atom/movable/screen/fullscreen/fnf/corruption/top,
	"fnf_corruption_dark_bottom" = /atom/movable/screen/fullscreen/fnf/corruption/bottom,
	"fnf_corruption_light" = /atom/movable/screen/fullscreen/fnf/corruption/fill,
	"fnf_corruption_black" = /atom/movable/screen/fullscreen/fnf/corruption/fill,
	"fnf_corruption_bloom" = /atom/movable/screen/fullscreen/fnf/corruption/fill/bloom,
))

/**
 * One of the mod's overlays (320 by 180), fitted to the whole width of the view: every word of it
 * shows, whatever shape the view is. The top and bottom pieces fill whatever's left above and
 * below with the overlay's own edges, drawn out.
 */
/atom/movable/screen/fullscreen/fnf/corruption
	icon = 'voidcrew/modules/fnf/icons/fnf_corruption_overlays.dmi'
	icon_state = ""
	color = null
	alpha = 0
	plane = ABOVE_LIGHTING_PLANE
	layer = ABOVE_ALL_MOB_LAYER + 0.005
	appearance_flags = PIXEL_SCALE
	// Centred on the view.
	screen_loc = "CENTER:-144,CENTER:-74"
	/// "top" or "bottom" for the pieces above and below, null for the overlay itself.
	var/part
	/// The view it's fitted to, in pixels.
	var/view_width
	var/view_height

/atom/movable/screen/fullscreen/fnf/corruption/update_for_view(client_view)
	view = client_view
	var/list/size = getviewsize(client_view)
	view_width = size[1] * ICON_SIZE_X
	view_height = size[2] * ICON_SIZE_Y
	fit()

/atom/movable/screen/fullscreen/fnf/corruption/proc/fit()
	if(!view_width)
		return
	var/scale = min(view_width / 320, view_height / 180)
	if(!part)
		transform = matrix(scale, 0, 0, 0, scale, 0)
		return
	// A pixel of overlap, so no seam.
	var/strip = max((view_height - 180 * scale) / 2, 0) + 2
	var/offset = (180 * scale + strip) / 2 - 1
	transform = matrix(scale, 0, 0, 0, strip / 180, part == "top" ? offset : -offset)

/atom/movable/screen/fullscreen/fnf/corruption/top
	part = "top"

/atom/movable/screen/fullscreen/fnf/corruption/bottom
	part = "bottom"

/// A flash of colour, or the dark, over the whole view.
/atom/movable/screen/fullscreen/fnf/corruption/fill
	icon = 'voidcrew/modules/fnf/icons/fnf.dmi'
	icon_state = "bar"
	color = "#000000"
	layer = ABOVE_ALL_MOB_LAYER + 0.004
	screen_loc = "WEST,SOUTH to EAST,NORTH"

/atom/movable/screen/fullscreen/fnf/corruption/fill/fit()
	return

/// A burst of glow: white, added onto everything under it.
/atom/movable/screen/fullscreen/fnf/corruption/fill/bloom
	color = "#ffffff"
	blend_mode = BLEND_ADD

/// Blacks or whites out the stage behind whoever's on it, for the silhouettes (see set_apple()).
/atom/movable/screen/fullscreen/fnf/corruption/fill/backdrop
	plane = GAME_PLANE
	layer = MOB_LAYER - 0.01
