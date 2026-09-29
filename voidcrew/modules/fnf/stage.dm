/**
 * Everything on a rhythm battle's stage besides the two singers singing:
 * - The girlfriend (or Nene), summoned to stand behind them, bopping to the beat and cheering.
 * - The song's lyrics, where it has them, under the stage.
 * - Chart events that have someone do something: Boyfriend's "hey!", Tankman's "ugh", Pico's
 *   burp.
 * - Notes that are a move rather than a line. Tankman's "ugh" notes, and all of Weekend 1: in
 *   2hot Darnell lights cans and kicks them up for Pico to shoot, and Blazin' is a fistfight, every
 *   note a punch, block or dodge.
 * - What the song's stage does. Week 2's mansion gets struck by lightning, scaring everyone; Week 3's
 *   train comes rumbling past. Week 6 opens with its dialogue, and Darnell with Darnell lighting a
 *   can for Pico to shoot.
 */
/datum/fnf_stage
	var/datum/fnf_battle/battle
	/// Whoever's cheering from the back, summoned for the song.
	var/mob/living/carbon/human/girlfriend
	/// Whoever the player carries through the song (Stress: Girlfriend, or Nene clinging to Pico).
	var/mob/living/carbon/human/carried
	/// The next line of the lyrics to show, and when the one showing ends (song ms).
	var/next_lyric = 1
	var/lyric_ends = -1
	var/obj/effect/abstract/fnf_hud/text/lyric_text
	/// The can in the air in 2hot, if there is one.
	var/obj/effect/abstract/fnf_hud/can
	/// How far apart the singers stand, in pixels.
	var/gap_px = 96
	/// Week 2's lightning: the beat it last struck on, and how many beats until it can again.
	var/lightning_beat = 0
	var/lightning_wait = 8
	/// Week 3's train: beats since it last passed, and whether it's passing now.
	var/train_cooldown = 0
	var/train_passing = FALSE
	/// Week 6's dialogue box before the song, and its lines still to come.
	var/obj/effect/abstract/fnf_hud/text/dialogue_text
	var/list/dialogue_lines
	var/dialogue_channel

/datum/fnf_stage/New(datum/fnf_battle/battle, turf/left_turf, turf/right_turf)
	src.battle = battle
	gap_px = (right_turf.x - left_turf.x) * world.icon_size
	summon_girlfriend(left_turf, right_turf)
	summon_carried(right_turf)
	if(length(battle.song.lyrics) && battle.healthbar)
		lyric_text = new
		lyric_text.maptext_width = 256
		lyric_text.maptext_x = -112
		lyric_text.layer = ABOVE_ALL_MOB_LAYER + 0.05
		lyric_text.pixel_w = battle.healthbar.center_x - 16
		lyric_text.pixel_z = battle.healthbar.center_y - FNF_STRUM_Y - 44 - 30
		battle.healthbar.vis_contents += lyric_text
	start_intro()

/datum/fnf_stage/Destroy()
	if(girlfriend && !QDELETED(girlfriend))
		do_sparks(2, FALSE, girlfriend)
		qdel(girlfriend)
	girlfriend = null
	if(carried && !QDELETED(carried))
		qdel(carried)
	carried = null
	battle?.healthbar?.vis_contents -= lyric_text
	QDEL_NULL(lyric_text)
	battle?.healthbar?.vis_contents -= dialogue_text
	QDEL_NULL(dialogue_text)
	QDEL_NULL(can)
	if(dialogue_channel)
		for(var/mob/listener as anything in battle?.listeners)
			SEND_SOUND(listener, sound(null, channel = dialogue_channel))
		SSsounds.free_datum_channels(src)
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

/// In Stress, the player sings holding someone: Boyfriend carries Girlfriend, Nene clings to Pico's
/// back. They ride along on the player's tile, just behind them.
/datum/fnf_stage/proc/summon_carried(turf/right_turf)
	var/static/list/carried_by = list("bf-holding-gf" = "gf", "pico-holding-nene" = "nene")
	var/character = carried_by[battle.song.player_variant]
	if(!character || !battle.right?.singer)
		return
	carried = fnf_summon_opponent(character, right_turf)
	for(var/obj/item/held in carried.held_items)
		qdel(held)
	carried.setDir(battle.right.facing)
	// Behind the singer (who faces west), a little up off the floor, and drawn behind them.
	carried.pixel_w = battle.right.facing == WEST ? 7 : -7
	carried.pixel_z = 5
	carried.layer = battle.right.singer.layer - 0.01

/datum/fnf_stage/proc/bop(beat_time)
	if(girlfriend && !QDELETED(girlfriend))
		girlfriend.fnf_bop(beat_time, RIG_R_ARM, SOUTH, null)
	if(carried && !QDELETED(carried))
		carried.fnf_bop(beat_time, RIG_R_ARM, battle.right.facing, null)
	var/beat = battle.last_beat
	switch(battle.song.id)
		if("spookeez", "south", "monster")
			// Struck at random, never twice within 8 to 24 beats. Spookeez opens with one, silent.
			if(beat == 4 && battle.song.id == "spookeez")
				lightning(FALSE)
			else if(beat > lightning_beat + lightning_wait && prob(10))
				lightning(TRUE)
		if("pico", "philly-nice", "blammed")
			// Now and then, on the middle of a bar, a train.
			if(!train_passing)
				train_cooldown++
				if(beat % 8 == 4 && train_cooldown > 8 && prob(30))
					train_cooldown = rand(-4, 0)
					pass_train()

/// Everyone listening: the singers, and anyone watching.
/datum/fnf_stage/proc/play_to_all(sound_file, volume = 60)
	for(var/mob/listener as anything in battle.listeners)
		SEND_SOUND(listener, sound(sound_file, volume = volume * (battle.listeners[listener] || 1)))

/// The mansion lit up by lightning: a flash, thunder, and Boyfriend and the girlfriend jumping.
/datum/fnf_stage/proc/lightning(with_thunder)
	lightning_beat = battle.last_beat
	lightning_wait = rand(8, 24)
	if(with_thunder)
		play_to_all("voidcrew/modules/fnf/sound/thunder[rand(1, 2)].ogg", 70)
	for(var/mob/listener as anything in battle.listeners)
		if(listener.client)
			flash_color(listener.client, "#dde8ff", 4)
	battle.right?.act("hit_high", 4)
	if(girlfriend && !QDELETED(girlfriend))
		girlfriend.fnf_act("hit_high", RIG_R_ARM, SOUTH, null, 4)

/// A train thunders past behind the stage: the rumble builds, the girlfriend's hair whips about as
/// it goes by, and it's gone.
/datum/fnf_stage/proc/pass_train()
	train_passing = TRUE
	play_to_all("voidcrew/modules/fnf/sound/train_passes.ogg", 55)
	addtimer(CALLBACK(src, PROC_REF(train_rushes)), 47, TIMER_DELETE_ME)
	addtimer(VARSET_CALLBACK(src, train_passing, FALSE), 90, TIMER_DELETE_ME)

/datum/fnf_stage/proc/train_rushes()
	for(var/mob/listener as anything in battle.listeners)
		shake_camera(listener, 12, 1)
	if(girlfriend && !QDELETED(girlfriend))
		girlfriend.fnf_act("dodge_high", RIG_R_ARM, SOUTH, null, 10)

/// What happens before the count in: Week 6's dialogue, or Darnell's can. Pushes the count in back
/// for as long as it takes.
/datum/fnf_stage/proc/start_intro()
	if(read_dialogue())
		return
	if(battle.song.id == "darnell" && !battle.song.variation)
		battle.lead_in += 4 SECONDS
		// He lights one, kicks it up, and Pico shoots it down. Darnell has a good laugh.
		addtimer(CALLBACK(src, PROC_REF(weekend_cans), null, "lightcan", TRUE), 5, TIMER_DELETE_ME)
		addtimer(CALLBACK(src, PROC_REF(weekend_cans), null, "kickcan", TRUE), 13, TIMER_DELETE_ME)
		addtimer(CALLBACK(src, PROC_REF(weekend_cans), null, "cockgun", TRUE), 18, TIMER_DELETE_ME)
		addtimer(CALLBACK(src, PROC_REF(weekend_cans), null, "firegun", TRUE), 24, TIMER_DELETE_ME)
		addtimer(CALLBACK(src, PROC_REF(darnell_laughs)), 29, TIMER_DELETE_ME)

/datum/fnf_stage/proc/darnell_laughs()
	battle.left?.act("taunt", 6)
	popup(battle.left?.singer, "Heh heh heh!")

/**
 * Week 6's dialogue, from data/fnf/dialogue/ (fetched with the songs): read the song's conversation
 * and start playing it in a box under the stage, one line after another, typed out to its music.
 * Returns TRUE if the song has one.
 */
/datum/fnf_stage/proc/read_dialogue()
	var/list/conversation = fnf_read_json("data/fnf/dialogue/[battle.song.id][battle.song.variation ? "-[battle.song.variation]" : ""].json")
	if(!length(conversation?["dialogue"]) || !battle.healthbar)
		return FALSE
	dialogue_lines = list()
	var/total = 0
	for(var/list/entry in conversation["dialogue"])
		var/text = jointext(entry["text"], " ")
		var/list/line = list(fnf_dialogue_speaker(entry["speaker"], battle), text)
		dialogue_lines += list(line)
		total += fnf_dialogue_line_time(text)
	battle.lead_in += total
	dialogue_text = new
	dialogue_text.maptext_width = 288
	dialogue_text.maptext_height = 64
	dialogue_text.maptext_x = -128
	dialogue_text.layer = ABOVE_ALL_MOB_LAYER + 0.07
	dialogue_text.pixel_w = battle.healthbar.center_x - 16
	dialogue_text.pixel_z = battle.healthbar.center_y - FNF_STRUM_Y - 44 - 64
	battle.healthbar.vis_contents += dialogue_text
	var/music = conversation["music"]?["asset"]
	if(music)
		dialogue_channel = SSsounds.reserve_sound_channel(src)
		var/music_file = music == "LunchboxScary" ? "voidcrew/modules/fnf/sound/dialogue_music_scary.ogg" : "voidcrew/modules/fnf/sound/dialogue_music.ogg"
		for(var/mob/listener as anything in battle.listeners)
			SEND_SOUND(listener, sound(music_file, repeat = TRUE, channel = dialogue_channel, volume = 35 * (battle.listeners[listener] || 1)))
	next_dialogue_line()
	return TRUE

/// How long a line of dialogue stays up, in deciseconds: typed out, then read.
/proc/fnf_dialogue_line_time(text)
	return round(length(text) * 0.35) + 20

/// Who's talking, as the box names them.
/proc/fnf_dialogue_speaker(speaker, datum/fnf_battle/battle)
	switch(fnf_base_character(speaker))
		if("senpai")
			return list("Senpai", "#ffb3d9")
		if("spirit")
			return list("Spirit", "#ff4a4a")
		if("nene")
			return list("Nene", "#ff8ad8")
		if("bf", "pico")
			return list(battle.right?.singer_name || "You", "#8ad8ff")
	return list(capitalize(speaker), "#ffffff")

/datum/fnf_stage/proc/next_dialogue_line()
	if(QDELETED(src) || !dialogue_text)
		return
	if(!length(dialogue_lines))
		battle.healthbar.vis_contents -= dialogue_text
		QDEL_NULL(dialogue_text)
		if(dialogue_channel)
			for(var/mob/listener as anything in battle.listeners)
				SEND_SOUND(listener, sound(null, channel = dialogue_channel))
		return
	var/list/line = dialogue_lines[1]
	dialogue_lines.Cut(1, 2)
	type_dialogue(line[1], line[2], 0)
	addtimer(CALLBACK(src, PROC_REF(next_dialogue_line)), fnf_dialogue_line_time(line[2]), TIMER_DELETE_ME)

/// Types a line out a few letters at a time, blipping as it goes.
/datum/fnf_stage/proc/type_dialogue(list/speaker, text, shown)
	if(QDELETED(src) || !dialogue_text)
		return
	shown = min(shown + 4, length(text))
	dialogue_text.maptext = MAPTEXT("<span style='font-size:7pt;-dm-text-outline:1px #000000'><b style='color:[speaker[2]]'>[html_encode(speaker[1])]</b><br><span style='color:#ffffff'>[html_encode(copytext(text, 1, shown + 1))]</span></span>")
	if(shown % 8 == 0)
		play_to_all("voidcrew/modules/fnf/sound/dialogue_blip.ogg", 30)
	if(shown < length(text))
		addtimer(CALLBACK(src, PROC_REF(type_dialogue), speaker, text, shown), 1.4, TIMER_DELETE_ME)

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

/// Something said out loud, over their head, unless the song's lyrics already put it on screen.
/datum/fnf_stage/proc/say_line(mob/living/over, text, colour = "#ffffff")
	if(length(battle.song.lyrics))
		return
	popup(over, text, colour)

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
			// Boyfriend shouts "hey!"; Pico says "yeah!".
			popup(side.singer, side.style == "pico" ? "Yeah!" : "Hey!", "#ffe066")
			cheer()
		if("ugh", "augh")
			side.act("ugh", 4)
			say_line(side.singer, anim == "ugh" ? "UGH!" : "AUGH!", "#ff6a4a")
		if("laugh")
			side.act("taunt", 5)
			say_line(side.singer, "Heh heh heh!")
		if("beat it")
			side.act("taunt", 4)
			say_line(side.singer, "Beat it!")
		if("hehPrettyGood")
			side.hey()
			say_line(side.singer, "Heh, pretty good!")
		if("burpSmile")
			side.act("taunt", 3)
			popup(side.singer, "*burp*")
		if("redheadsAnim")
			// "Ugh, redheads..."
			side.act("taunt", 5)
		if("knifeToss")
			knife_toss()
		else
			side.hey()

/// Stress (Pico Mix): Nene, clinging to Pico, has heard enough about redheads, and throws a knife
/// at Tankman.
/datum/fnf_stage/proc/knife_toss()
	var/datum/fnf_side/tankman = battle.left
	var/mob/living/thrower = carried || battle.right?.singer
	if(!thrower || !tankman?.singer)
		return
	thrower.fnf_act("punch_high", RIG_R_ARM, battle.right.facing, null, 3)
	var/obj/effect/abstract/fnf_hud/knife = new(get_turf(thrower))
	knife.icon = 'icons/obj/service/kitchen.dmi'
	knife.icon_state = "knife"
	knife.pixel_w = thrower.pixel_w
	knife.pixel_z = 14
	animate(knife, pixel_w = -gap_px, pixel_z = 10, transform = turn(matrix(), -1080), time = 3, easing = LINEAR_EASING)
	QDEL_IN(knife, 3)
	addtimer(CALLBACK(src, PROC_REF(knife_lands)), 3, TIMER_DELETE_ME)

/datum/fnf_stage/proc/knife_lands()
	var/datum/fnf_side/tankman = battle?.left
	if(!tankman?.singer)
		return
	playsound(tankman.singer, 'sound/items/weapons/bladeslice.ogg', 60, TRUE)
	tankman.act("hit_high", 5)
	popup(tankman.singer, "AGH!", "#ff6a4a")

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
			say_line(side.singer, "UGH!", "#ff6a4a")
			return TRUE
		if("hehPrettyGood")
			side.hey()
			say_line(side.singer, "Heh, pretty good!")
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
	// Where the can hangs to be shot: in the air between them, right where Pico's gun points.
	var/hover_x = gap_px * 0.55
	var/hover_y = 31 + max(gap_px * 0.45 - 9, 8) * 0.7
	switch(move)
		if("lightcan")
			darnell.act("cock", 3)
			QDEL_NULL(can)
			can = new(get_turf(darnell.singer))
			can.icon = 'icons/obj/art/crayons.dmi'
			can.icon_state = "spraycan"
			can.pixel_w = 8
			can.pixel_z = 6
			playsound(darnell.singer, 'sound/items/lighter/zippo_on.ogg', 50, TRUE)
		if("kickcan")
			darnell.act("kick", 2)
			if(can)
				playsound(darnell.singer, 'sound/items/weapons/genhit1.ogg', 40, TRUE)
				// Up in an arc over toward Pico, and hanging there.
				animate(can, pixel_w = hover_x - 16, pixel_z = hover_y + 10 - 16, transform = turn(matrix(), 360), time = 4, easing = SINE_EASING|EASE_OUT)
				animate(pixel_z = hover_y - 16, time = 6, easing = SINE_EASING)
		if("kneecan")
			darnell.act("kick", 2)
			if(can)
				playsound(darnell.singer, 'sound/items/weapons/genhit2.ogg', 40, TRUE)
				animate(can, pixel_w = hover_x - 16, pixel_z = hover_y + 14 - 16, transform = turn(matrix(), 180), time = 3, easing = SINE_EASING|EASE_OUT)
				animate(pixel_z = hover_y - 16, time = 5, easing = SINE_EASING)
		if("cockgun")
			pico.act("cock", 3)
			playsound(pico.singer, 'voidcrew/modules/fnf/sound/gun_cock.ogg', 50, TRUE)
		if("firegun")
			if(hit)
				pico.act("shoot", 2)
				playsound(pico.singer, "voidcrew/modules/fnf/sound/shot[rand(1, 4)].ogg", 60, TRUE)
				if(can)
					tracer(get_turf(darnell.singer), gap_px - 9, 31, can.pixel_w + 16, can.pixel_z + 16)
					var/obj/effect/temp_visual/explosion/fast/pop = new(can.loc)
					// It's already moved 32 px down and left to centre its 96 px sprite on a tile.
					pop.pixel_w = can.pixel_w
					pop.pixel_z = can.pixel_z
					pop.transform = matrix() * 0.35
					playsound(can, 'sound/effects/pop_expl.ogg', 40, TRUE)
					QDEL_NULL(can)
			else
				// Unshot, the can comes down and goes off in Pico's face.
				if(can)
					var/face_x = gap_px - 3
					animate(can, pixel_w = face_x - 16, pixel_z = 31 - 16, transform = turn(matrix(), 540), time = 2, easing = QUAD_EASING|EASE_IN)
					addtimer(CALLBACK(src, PROC_REF(can_in_face), can, face_x), 2, TIMER_DELETE_ME)
					can = null
	return TRUE

/// The can Pico didn't shoot blows up in his face: a big chunk of health, and charred for a moment.
/datum/fnf_stage/proc/can_in_face(obj/effect/abstract/fnf_hud/missed_can, face_x)
	var/turf/where = missed_can.loc
	qdel(missed_can)
	var/datum/fnf_side/pico = battle?.right
	if(!pico?.singer || !where)
		return
	var/obj/effect/temp_visual/explosion/fast/bang = new(where)
	bang.pixel_w = face_x - 16
	bang.pixel_z = 31 - 16
	bang.transform = matrix() * 0.55
	playsound(pico.singer, 'sound/effects/pop_expl.ogg', 70, TRUE)
	shake_camera(pico.singer, 3, 2)
	pico.singer.fnf_flash("#2a3470", 8)
	pico.act("hit_high", 4)
	popup(pico.singer, "BOOM!", "#ff8a3a")
	battle.adjust_health(-32, pico)

/// A bullet's streak, from one point to another (pixels from the bottom left of a turf).
/datum/fnf_stage/proc/tracer(turf/from_turf, from_x, from_y, to_x, to_y)
	var/delta_x = to_x - from_x
	var/delta_y = to_y - from_y
	var/length = sqrt(delta_x ** 2 + delta_y ** 2)
	var/obj/effect/abstract/fnf_hud/streak = new(from_turf)
	streak.icon_state = "bar"
	streak.color = "#fff3a0"
	streak.pixel_w = (from_x + to_x) / 2 - 16
	streak.pixel_z = (from_y + to_y) / 2 - 16
	var/matrix/line = matrix(length / 32, 0, 0, 0, 1 / 32, 0)
	line.Turn(-arctan(delta_x, delta_y))
	streak.transform = line
	animate(streak, alpha = 0, time = 2)
	QDEL_IN(streak, 3)

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
