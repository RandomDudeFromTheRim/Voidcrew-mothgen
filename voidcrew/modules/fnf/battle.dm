/**
 * A rhythm battle: two singers facing each other, the challenger on the right, the
 * opponent (a person, a mob nobody's playing, or an Experiment summoned for it) on the left.
 *
 * Keeping the song and the notes together:
 * - The song is sent to everyone listening paused, the moment it's picked, and again when a
 *   challenge goes out, so their game has it downloaded and ready while people decide.
 * - A countdown, four beats long and never under two seconds, gives the download more time.
 *   The song then starts for everyone at once by unpausing it, rather than being sent at start.
 * - Notes aren't timers fired off in advance. Every tick, each side works out where the song is
 *   from the start time, puts on screen whatever is due, and animates it to land on its exact
 *   time. Presses are judged against that same clock, corrected for the singer's ping.
 */
/datum/fnf_battle
	var/datum/fnf_song/song
	var/difficulty
	var/state = FNF_STATE_READY
	/// The microphone that started it.
	var/obj/item/fnf_microphone/microphone
	var/datum/fnf_side/left
	var/datum/fnf_side/right
	var/list/datum/fnf_side/sides = list()
	/// The chart: list("player", "opponent", "events", "speed").
	var/list/chart
	/// world.time (in deciseconds, fractional) when the song is at 0.
	var/start_time = 0
	/// How long a note takes to rise to its strum, in milliseconds.
	var/travel_ms = 1100
	/// Milliseconds per beat.
	var/crochet = 600
	/// When the last note is over, in song milliseconds.
	var/end_ms = 0
	var/health = FNF_HEALTH_MAX / 2
	var/inst_channel
	var/left_voice_channel
	var/right_voice_channel
	/// Everyone hearing the song, mob => volume multiplier. Onlookers get it quieter.
	var/list/mob/listeners = list()
	var/list/channel_volumes = list()
	var/obj/effect/abstract/fnf_hud/healthbar/healthbar
	var/tick_timer
	var/next_event = 1
	var/last_beat = -1
	/// An Experiment summoned to sing against a lone challenger. Goes away afterwards.
	var/mob/living/carbon/human/npc

/datum/fnf_battle/New(datum/fnf_song/song, difficulty, obj/item/fnf_microphone/microphone)
	src.song = song
	src.difficulty = difficulty
	src.microphone = microphone
	chart = song.load_chart(difficulty)
	travel_ms = round(1800 / clamp(chart["speed"], 0.6, 4))
	crochet = 60000 / max(song.bpm, 30)
	for(var/list/note as anything in chart["player"] + chart["opponent"])
		end_ms = max(end_ms, note[1] + note[3])
	end_ms += 1500
	inst_channel = SSsounds.reserve_sound_channel(src)
	left_voice_channel = SSsounds.reserve_sound_channel(src)
	right_voice_channel = SSsounds.reserve_sound_channel(src)
	channel_volumes = list("[inst_channel]" = 1, "[left_voice_channel]" = 1, "[right_voice_channel]" = 1)

/datum/fnf_battle/Destroy()
	deltimer(tick_timer)
	for(var/mob/listener as anything in listeners)
		for(var/list/track as anything in get_tracks())
			SEND_SOUND(listener, sound(null, channel = track[2]))
		UnregisterSignal(listener, COMSIG_QDELETING)
	listeners.Cut()
	QDEL_NULL(left)
	QDEL_NULL(right)
	sides.Cut()
	QDEL_NULL(healthbar)
	if(npc && !QDELETED(npc))
		do_sparks(3, FALSE, npc)
		npc.visible_message(span_notice("[npc] bows, and is gone."))
		qdel(npc)
	npc = null
	SSsounds.free_datum_channels(src)
	if(microphone?.battle == src)
		microphone.battle = null
	microphone = null
	return ..()

/// The song position right now, in milliseconds. Negative during the countdown.
/datum/fnf_battle/proc/get_song_time()
	return (FNF_NOW - start_time) * 100

/// list(file, channel) for everything that plays: the backing track and both singers' vocals.
/datum/fnf_battle/proc/get_tracks()
	. = list(list(song.inst_file, inst_channel))
	if(song.player_voice_file)
		. += list(list(song.player_voice_file, right_voice_channel))
	if(song.opponent_voice_file)
		. += list(list(song.opponent_voice_file, left_voice_channel))

/datum/fnf_battle/proc/get_volume(mob/listener, channel)
	var/pref = listener.client?.prefs.read_preference(/datum/preference/numeric/volume/sound_jukebox)
	if(isnull(pref))
		pref = 100
	return 85 * pref / 100 * (listeners[listener] || 1) * (channel_volumes["[channel]"] || 0)

/// Sends someone the song, paused, so it's downloaded by the time it starts.
/datum/fnf_battle/proc/preload(mob/listener, volume = 1)
	if(!listener?.client)
		return
	if(!listeners[listener])
		RegisterSignal(listener, COMSIG_QDELETING, PROC_REF(on_listener_deleted))
	listeners[listener] = volume
	for(var/list/track as anything in get_tracks())
		var/sound/music = sound(file(track[1]), repeat = FALSE, wait = FALSE, channel = track[2], volume = get_volume(listener, track[2]))
		music.status = SOUND_PAUSED
		SEND_SOUND(listener, music)

/datum/fnf_battle/proc/on_listener_deleted(mob/source)
	SIGNAL_HANDLER
	listeners -= source

/// Starts the paused song for everyone at once.
/datum/fnf_battle/proc/unpause_song()
	for(var/mob/listener as anything in listeners)
		for(var/list/track as anything in get_tracks())
			var/sound/update = sound(null, repeat = FALSE, wait = FALSE, channel = track[2], volume = get_volume(listener, track[2]))
			update.status = SOUND_UPDATE
			SEND_SOUND(listener, update)

/datum/fnf_battle/proc/set_channel_volume(channel, multiplier)
	if(channel_volumes["[channel]"] == multiplier)
		return
	channel_volumes["[channel]"] = multiplier
	if(state != FNF_STATE_PLAYING && state != FNF_STATE_OVER)
		return
	for(var/mob/listener as anything in listeners)
		var/sound/update = sound(null, repeat = FALSE, wait = FALSE, channel = channel, volume = get_volume(listener, channel))
		update.status = SOUND_UPDATE
		SEND_SOUND(listener, update)

/// Everyone nearby gets the song too, a little quieter.
/datum/fnf_battle/proc/preload_onlookers(atom/center)
	for(var/mob/onlooker in hearers(7, center))
		if(onlooker.client && !listeners[onlooker])
			preload(onlooker, 0.6)

/**
 * Sets the stage and counts in.
 *
 * * challenger - sings the player's part, on the right
 * * opponent - sings the other part, on the left. Nobody means an Experiment is summoned.
 */
/datum/fnf_battle/proc/start(mob/living/challenger, mob/living/opponent)
	var/turf/right_turf = get_turf(challenger)
	var/turf/left_turf = find_opponent_spot(right_turf, opponent)
	if(!opponent)
		opponent = summon_opponent(left_turf || right_turf)
	else if(left_turf && get_turf(opponent) != left_turf)
		opponent.forceMove(left_turf)
	left_turf = get_turf(opponent)

	right = new(src, challenger, TRUE, chart["player"], right_voice_channel)
	left = new(src, opponent, FALSE, chart["opponent"], left_voice_channel)
	if(opponent == npc)
		left.is_cpu = TRUE
		left.update_score_text()
	sides = list(left, right)

	// The bar hangs between the two, above their strums.
	var/center_x = 16 + (left_turf.x - right_turf.x) * world.icon_size / 2
	var/center_y = 16 + (left_turf.y - right_turf.y) * world.icon_size / 2 + FNF_STRUM_Y + 44
	healthbar = new(right_turf, center_x, center_y, opponent, challenger)

	preload(challenger)
	preload(opponent)
	preload_onlookers(right_turf)

	state = FNF_STATE_COUNTDOWN
	var/countdown_ds = max(4 * crochet, 2000) / 100
	// Line the start up with a tick, so the song starts on exactly the tick it's meant to.
	start_time = world.time + CEILING(10 + countdown_ds, world.tick_lag)
	var/static/list/counts = list("3", "2", "1", "GO!")
	for(var/i in 1 to 4)
		addtimer(CALLBACK(src, PROC_REF(count_in), i, counts[i]), start_time - world.time - (5 - i) * crochet / 100, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(begin_song)), start_time - world.time, TIMER_DELETE_ME)
	tick_timer = addtimer(CALLBACK(src, PROC_REF(tick)), world.tick_lag, TIMER_LOOP|TIMER_STOPPABLE|TIMER_DELETE_ME)
	challenger.visible_message(span_boldnotice("[challenger] and [opponent] square up for a rhythm battle: [song.name]!"))

/// Three tiles to the challenger's left is the opponent's spot, or as close as there's room.
/datum/fnf_battle/proc/find_opponent_spot(turf/right_turf, mob/living/opponent)
	for(var/distance in list(3, 2, 4))
		var/turf/spot = locate(right_turf.x - distance, right_turf.y, right_turf.z)
		if(!spot)
			continue
		if(opponent && get_turf(opponent) == spot)
			return spot
		if(!spot.is_blocked_turf(exclude_mobs = FALSE))
			return spot
	return null

/datum/fnf_battle/proc/summon_opponent(turf/spot)
	npc = new /mob/living/carbon/human/species/experiment(spot)
	npc.fully_replace_character_name(npc.real_name, "Experiment Dearest")
	npc.setDir(EAST)
	// Mic in the hand nearer the crowd, so it shows.
	npc.put_in_r_hand(new /obj/item/fnf_microphone(npc))
	do_sparks(3, FALSE, npc)
	npc.visible_message(span_notice("[npc] steps out of nowhere, ready to sing."))
	return npc

/datum/fnf_battle/proc/count_in(number, text)
	if(state == FNF_STATE_OVER)
		return
	healthbar?.announce(text, number == 4 ? "#ffe066" : "#ffffff")
	var/sound_file = number == 4 ? "voidcrew/modules/fnf/sound/countgo.ogg" : "voidcrew/modules/fnf/sound/count[4 - number].ogg"
	for(var/mob/listener as anything in listeners)
		SEND_SOUND(listener, sound(sound_file, volume = 50 * (listeners[listener] || 1)))
	for(var/datum/fnf_side/side as anything in sides)
		side.bop(crochet / 100)

/datum/fnf_battle/proc/begin_song()
	if(state != FNF_STATE_COUNTDOWN)
		return
	state = FNF_STATE_PLAYING
	unpause_song()

/datum/fnf_battle/proc/tick()
	if(state == FNF_STATE_OVER)
		return
	var/now = get_song_time()
	for(var/datum/fnf_side/side as anything in sides)
		side.process_notes(now)
		if(state == FNF_STATE_OVER)
			return
	var/beat = floor(now / crochet)
	if(beat > last_beat && beat >= 0)
		last_beat = beat
		healthbar?.bop()
		for(var/datum/fnf_side/side as anything in sides)
			side.bop(crochet / 100)
	var/list/events = chart["events"]
	while(next_event <= length(events))
		var/list/event = events[next_event]
		if(event["t"] > now)
			break
		next_event++
		run_event(event)
	if(state == FNF_STATE_PLAYING && now >= end_ms)
		finish()

/// The one chart event that means something here: a singer shouting "hey!".
/datum/fnf_battle/proc/run_event(list/event)
	if(event["e"] != "PlayAnimation")
		return
	var/list/value = event["v"]
	if(!islist(value) || value["anim"] != "hey")
		return
	var/datum/fnf_side/side = value["target"] == "bf" ? right : (value["target"] == "dad" ? left : null)
	side?.hey()

/// Pushes the health toward whoever did well (or away from whoever did badly).
/datum/fnf_battle/proc/adjust_health(amount, datum/fnf_side/side)
	if(state == FNF_STATE_OVER)
		return
	health = clamp(health + (side == right ? amount : -amount), 0, FNF_HEALTH_MAX)
	healthbar?.update(health)
	if(health <= 0)
		finish(left, right)
	else if(health >= FNF_HEALTH_MAX && !left.is_cpu)
		// Against a person, running them off the bar wins outright. The CPU can't be beaten early.
		finish(right, left)

/datum/fnf_battle/proc/forfeit(datum/fnf_side/quitter, reason)
	if(state == FNF_STATE_OVER)
		return
	var/datum/fnf_side/other = quitter == left ? right : left
	for(var/mob/listener as anything in listeners)
		to_chat(listener, span_warning("[quitter.singer_name] [reason], and forfeits!"))
	finish(other, null)

/**
 * Ends the battle.
 *
 * * winner - who won, or null to go by the health bar and then the score
 * * knocked_out - whoever was run off the health bar, who takes it badly
 */
/datum/fnf_battle/proc/finish(datum/fnf_side/winner, datum/fnf_side/knocked_out)
	if(state == FNF_STATE_OVER)
		return
	state = FNF_STATE_OVER
	deltimer(tick_timer)
	tick_timer = null
	if(!winner)
		if(health != FNF_HEALTH_MAX / 2)
			winner = health > FNF_HEALTH_MAX / 2 ? right : left
		else if(left.score != right.score)
			winner = left.score > right.score ? left : right
	var/datum/fnf_side/loser = winner ? (winner == left ? right : left) : null

	var/list/lines = list("<b>[song.name]</b> ([difficulty])")
	lines += winner ? "<b>[winner.singer_name] wins!</b>" : "<b>It's a draw!</b>"
	lines += right.get_results()
	lines += left.get_results()
	var/message = boxed_message(jointext(lines, "<br>"))
	for(var/mob/listener as anything in listeners)
		to_chat(listener, message)
	healthbar?.announce(winner ? "[winner.singer_name] wins!" : "Draw!", "#ffe066")

	winner?.hey()
	if(loser?.singer && !QDELETED(loser.singer))
		loser.singer.fnf_lose(loser == knocked_out)

	// Fade the song out rather than cutting it dead.
	for(var/step in 1 to 4)
		addtimer(CALLBACK(src, PROC_REF(fade_step), 1 - step / 4), step * 5, TIMER_DELETE_ME)
	QDEL_IN(src, 3 SECONDS)

/datum/fnf_battle/proc/fade_step(multiplier)
	for(var/list/track as anything in get_tracks())
		var/channel = track[2]
		if(channel_volumes["[channel]"])
			set_channel_volume(channel, multiplier)
