/**
 * Everything on a rhythm battle's stage besides the two singers singing:
 * - The girlfriend (or Nene), summoned to stand behind them, bopping to the beat and cheering.
 * - The song's lyrics, where it has them, under the stage.
 * - Chart events that have someone do something: Boyfriend's "hey!", Tankman's "ugh", Pico's
 *   burp.
 * - Notes that are a move rather than a line. Tankman's "ugh" notes, and all of Weekend 1: in
 *   2hot Darnell lights cans and kicks them up for Pico to shoot, and Blazin' is a fistfight, every
 *   note a punch, block or dodge.
 */
/datum/fnf_stage
	var/datum/fnf_battle/battle
	/// Whoever's cheering from the back, summoned for the song.
	var/mob/living/carbon/human/girlfriend
	/// The next line of the lyrics to show, and when the one showing ends (song ms).
	var/next_lyric = 1
	var/lyric_ends = -1
	var/obj/effect/abstract/fnf_hud/text/lyric_text
	/// The can in the air in 2hot, if there is one.
	var/obj/effect/abstract/fnf_hud/can
	/// How far apart the singers stand, in pixels.
	var/gap_px = 96

/datum/fnf_stage/New(datum/fnf_battle/battle, turf/left_turf, turf/right_turf)
	src.battle = battle
	gap_px = (right_turf.x - left_turf.x) * world.icon_size
	summon_girlfriend(left_turf, right_turf)
	if(length(battle.song.lyrics) && battle.healthbar)
		lyric_text = new
		lyric_text.maptext_width = 256
		lyric_text.maptext_x = -112
		lyric_text.layer = ABOVE_ALL_MOB_LAYER + 0.05
		lyric_text.pixel_w = battle.healthbar.center_x - 16
		lyric_text.pixel_z = battle.healthbar.center_y - FNF_STRUM_Y - 44 - 30
		battle.healthbar.vis_contents += lyric_text

/datum/fnf_stage/Destroy()
	if(girlfriend && !QDELETED(girlfriend))
		do_sparks(2, FALSE, girlfriend)
		qdel(girlfriend)
	girlfriend = null
	battle?.healthbar?.vis_contents -= lyric_text
	QDEL_NULL(lyric_text)
	QDEL_NULL(can)
	battle = null
	return ..()

/// She stands a step behind, halfway between the singers, if there's room.
/datum/fnf_stage/proc/summon_girlfriend(turf/left_turf, turf/right_turf)
	var/character = battle.song.girlfriend_character
	if(!GLOB.fnf_opponents[character])
		return
	var/turf/middle = locate(round((left_turf.x + right_turf.x) / 2), left_turf.y + 1, left_turf.z)
	if(!middle || middle.is_blocked_turf(exclude_mobs = FALSE))
		return
	girlfriend = fnf_summon_opponent(character, middle)
	for(var/obj/item/held in girlfriend.held_items)
		qdel(held)
	girlfriend.setDir(SOUTH)
	do_sparks(2, FALSE, girlfriend)

/datum/fnf_stage/proc/bop(beat_time)
	if(girlfriend && !QDELETED(girlfriend))
		girlfriend.fnf_bop(beat_time, RIG_R_ARM, SOUTH, null)

/// Puts up the lyrics as the song reaches them.
/datum/fnf_stage/proc/tick(now)
	if(!lyric_text)
		return
	var/list/lyrics = battle.song.lyrics
	if(lyric_ends >= 0 && now >= lyric_ends)
		lyric_text.maptext = null
		lyric_ends = -1
	while(next_lyric <= length(lyrics))
		var/list/line = lyrics[next_lyric]
		if(line[1] > now)
			break
		next_lyric++
		if(line[2] <= now)
			continue
		lyric_ends = line[2]
		lyric_text.maptext = MAPTEXT("<span style='text-align:center;font-size:8pt;color:#ffffff;-dm-text-outline:1px #000000'><i>[html_encode(line[3])]</i></span>")

/// Words over someone's head, rising and fading: "UGH!", "Hey!".
/datum/fnf_stage/proc/popup(mob/living/over, text, colour = "#ffffff")
	if(!over)
		return
	var/obj/effect/abstract/fnf_hud/text/words = new(get_turf(over))
	words.maptext = MAPTEXT("<span style='text-align:center;font-size:9pt;color:[colour];-dm-text-outline:1px #000000'><b>[html_encode(text)]</b></span>")
	words.pixel_z = 44
	words.transform = matrix() * 1.4
	animate(words, transform = matrix(), time = 1.5, easing = BACK_EASING|EASE_OUT)
	animate(pixel_z = 56, alpha = 0, time = 6, easing = SINE_EASING)
	QDEL_IN(words, 8)

/**
 * A chart's PlayAnimation event: someone on stage does something.
 *
 * * target - who: "bf" or "boyfriend" (the right), "dad" (the left), "gf" or "girlfriend"
 * * anim - what, as Funkin' names the animation
 */
/datum/fnf_stage/proc/play_animation(target, anim)
	var/datum/fnf_side/side
	switch(target)
		if("bf", "boyfriend")
			side = battle.right
		if("dad", "opponent")
			side = battle.left
		if("gf", "girlfriend")
			cheer()
			return
	if(!side)
		return
	switch(anim)
		if("hey", "cheer")
			side.hey()
			popup(side.singer, "Hey!", "#ffe066")
			cheer()
		if("ugh", "augh")
			side.act("ugh", 4)
			popup(side.singer, anim == "ugh" ? "UGH!" : "AUGH!", "#ff6a4a")
		if("laugh")
			side.act("taunt", 5)
			popup(side.singer, "Heh heh heh!")
		if("beat it")
			side.act("taunt", 4)
			popup(side.singer, "Beat it!")
		if("hehPrettyGood")
			side.hey()
			popup(side.singer, "Heh, pretty good!")
		if("burpSmile")
			side.act("taunt", 3)
			popup(side.singer, "*burp*")
		else
			side.hey()

/// The girlfriend throws her arms up: "Hey!"
/datum/fnf_stage/proc/cheer()
	if(!girlfriend || QDELETED(girlfriend))
		return
	girlfriend.fnf_hey(RIG_R_ARM, SOUTH, null)
	popup(girlfriend, "Hey!", "#ff8ad8")

/// The singer on the other side from this one.
/datum/fnf_stage/proc/rival_of(datum/fnf_side/side)
	return side == battle.left ? battle.right : battle.left

/**
 * A note was hit. Returns TRUE if it was a move the stage acted out, so the singer doesn't also
 * sing it.
 */
/datum/fnf_stage/proc/note_hit(datum/fnf_side/side, datum/fnf_note/note)
	var/kind = note.kind
	if(!kind)
		return FALSE
	switch(kind)
		if("noanim")
			return TRUE
		if("ugh")
			side.act("ugh", 3)
			popup(side.singer, "UGH!", "#ff6a4a")
			return TRUE
		if("hehPrettyGood")
			side.hey()
			popup(side.singer, "Heh, pretty good!")
			return TRUE
	if(findtext(kind, "weekend-1-") != 1)
		return FALSE
	var/move = copytext(kind, 11)
	if(weekend_cans(side, move, TRUE))
		return TRUE
	return blazin(side, move, TRUE)

/// A note was missed. Returns TRUE if the stage showed what that cost, instead of the usual flinch.
/datum/fnf_stage/proc/note_missed(datum/fnf_side/side, datum/fnf_note/note)
	if(findtext(note.kind, "weekend-1-") != 1)
		return FALSE
	var/move = copytext(note.kind, 11)
	if(weekend_cans(side, move, FALSE))
		return TRUE
	return blazin(side, move, FALSE)

/**
 * 2hot: Darnell lights a can, kicks it up (and knees it higher), Pico racks his gun and shoots it
 * out of the air. Miss the shot and the can comes down on Pico's head.
 */
/datum/fnf_stage/proc/weekend_cans(datum/fnf_side/side, move, hit)
	var/static/list/can_moves = list("lightcan", "kickcan", "kneecan", "cockgun", "firegun")
	if(!(move in can_moves))
		return FALSE
	var/datum/fnf_side/darnell = battle.left
	var/datum/fnf_side/pico = battle.right
	if(!darnell.singer || !pico.singer)
		return TRUE
	switch(move)
		if("lightcan")
			darnell.act("cock", 3)
			QDEL_NULL(can)
			can = new(get_turf(darnell.singer))
			can.icon = 'icons/obj/drinks/soda.dmi'
			can.icon_state = "cola"
			can.pixel_w = 8
			can.pixel_z = 10
			playsound(darnell.singer, 'sound/items/lighter/zippo_on.ogg', 50, TRUE)
		if("kickcan")
			darnell.act("kick", 2)
			if(can)
				playsound(darnell.singer, 'sound/items/weapons/genhit1.ogg', 40, TRUE)
				// Up in an arc, over toward Pico.
				animate(can, pixel_w = gap_px * 0.45, pixel_z = 56, transform = turn(matrix(), 360), time = 4, easing = SINE_EASING|EASE_OUT)
				animate(pixel_z = 40, time = 4, easing = SINE_EASING|EASE_IN)
		if("kneecan")
			darnell.act("kick", 2)
			if(can)
				playsound(darnell.singer, 'sound/items/weapons/genhit2.ogg', 40, TRUE)
				animate(can, pixel_w = gap_px * 0.55, pixel_z = 72, transform = turn(matrix(), 180), time = 4, easing = SINE_EASING|EASE_OUT)
				animate(pixel_z = 64, time = 6, easing = SINE_EASING)
		if("cockgun")
			pico.act("cock", 3)
			playsound(pico.singer, 'voidcrew/modules/fnf/sound/gun_cock.ogg', 50, TRUE)
		if("firegun")
			if(hit)
				pico.act("shoot", 2)
				playsound(pico.singer, "voidcrew/modules/fnf/sound/shot[rand(1, 4)].ogg", 60, TRUE)
				if(can)
					var/obj/effect/temp_visual/explosion/fast/pop = new(can.loc)
					pop.pixel_w = can.pixel_w - 32
					pop.pixel_z = can.pixel_z - 32
					pop.transform = matrix() * 0.35
					playsound(can, 'sound/effects/pop_expl.ogg', 40, TRUE)
					QDEL_NULL(can)
			else
				// The can drops right on the shooter.
				if(can)
					animate(can, pixel_w = gap_px, pixel_z = 24, time = 2, easing = QUAD_EASING|EASE_IN)
					QDEL_IN(can, 3)
					can = null
				pico.act("hit_high", 3)
				playsound(pico.singer, 'sound/items/weapons/genhit3.ogg', 50, TRUE)
				popup(pico.singer, "OW!", "#ff6a4a")
	return TRUE

/**
 * Blazin': every note is a move in the fight between Pico (right) and Darnell (left), named for
 * what Pico does or has done to him. Hit it and it goes Pico's way; miss it and it doesn't: a
 * whiffed punch, or a punch that should have been blocked landing.
 */
/datum/fnf_stage/proc/blazin(datum/fnf_side/side, move, hit)
	var/datum/fnf_side/darnell = battle.left
	var/datum/fnf_side/pico = battle.right
	var/static/list/punches = list(
		"punchhigh" = "high", "punchlow" = "low", "punchhighspin" = "high", "punchlowspin" = "low",
	)
	var/static/list/blocked_punches = list("punchhighblocked" = "high", "punchlowblocked" = "low", "punchlowdodged" = "low")
	var/static/list/guards = list("blockhigh" = "high", "blocklow" = "low", "blockspin" = "high", "dodgehigh" = "high", "dodgelow" = "low")
	var/static/list/hits = list("hithigh" = "high", "hitlow" = "low")
	if(!darnell.singer || !pico.singer)
		return FALSE
	if(punches[move])
		var/height = punches[move]
		pico.act("punch_[height]", 2)
		if(hit)
			darnell.act("hit_[height]", 3)
			punch_sound(darnell)
		else
			darnell.act("dodge_[height]", 3)
			popup(pico.singer, "Whiff!")
		return TRUE
	if(blocked_punches[move])
		var/height = blocked_punches[move]
		pico.act("punch_[height]", 2)
		if(findtext(move, "dodged"))
			darnell.act("dodge_[height]", 3)
		else
			darnell.act("block", 3)
			playsound(darnell.singer, 'sound/items/weapons/block_shield.ogg', 40, TRUE)
		return TRUE
	if(guards[move])
		var/height = guards[move]
		darnell.act("punch_[height]", 2)
		if(hit)
			if(findtext(move, "dodge"))
				pico.act("dodge_[height]", 3)
			else
				pico.act("block", 3)
				playsound(pico.singer, 'sound/items/weapons/block_shield.ogg', 40, TRUE)
		else
			pico.act("hit_[height]", 3)
			punch_sound(pico)
		return TRUE
	if(hits[move])
		// Scripted: Darnell gets one in whatever happens.
		var/height = hits[move]
		darnell.act("punch_[height]", 2)
		pico.act("hit_[height]", 3)
		punch_sound(pico)
		return TRUE
	switch(move)
		if("picouppercutprep")
			pico.act("prep", 4)
		if("picouppercut")
			pico.act("uppercut", 3)
			if(hit)
				darnell.act("uppercut_hit", 5)
				punch_sound(darnell, TRUE)
			else
				darnell.act("dodge_high", 3)
		if("darnelluppercutprep")
			darnell.act("prep", 4)
		if("darnelluppercut")
			darnell.act("uppercut", 3)
			if(hit)
				pico.act("dodge_high", 3)
			else
				pico.act("uppercut_hit", 5)
				punch_sound(pico, TRUE)
		if("fakeout")
			pico.act("punch_high", 1)
			darnell.act("block", 3)
			popup(pico.singer, "Psych!")
		if("taunt")
			pico.act("taunt", 5)
		if("idle")
			return TRUE
		else
			return FALSE
	return TRUE

/datum/fnf_stage/proc/punch_sound(datum/fnf_side/struck, big = FALSE)
	if(struck.singer)
		playsound(struck.singer, "sound/items/weapons/punch[rand(1, 4)].ogg", big ? 70 : 50, TRUE)
		shake_camera(struck.singer, big ? 3 : 1, big ? 2 : 1)
