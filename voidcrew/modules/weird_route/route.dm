/// Trait source for everything the Weird Route holds its player and Moffer to.
#define WEIRD_ROUTE_TRAIT "weird_route"
/// How many times they're asked: the game's endind.
#define WEIRD_ROUTE_END_INDEX 74
/// From which ask Moffer's under: the game's drownindex.
#define WEIRD_ROUTE_DROWN_INDEX 14
/// Where the pair stand when the asking starts, in the game's units (64 to a tile).
#define WEIRD_ROUTE_HANDOFF_X 370

/// Sleeps this many of the game's frames, and gives up if the route ended meanwhile.
#define WEIRD_ROUTE_WAIT(frames) sleep((frames) * WEIRD_ROUTE_FRAME); if(QDELETED(src)) { return }

/// Everyone down the Weird Route right now.
GLOBAL_LIST_EMPTY(weird_routes)

/mob/living/carbon/human
	/// The Weird Route this one's down, if any.
	var/datum/weird_route/weird_route

/**
 * One trip down the Weird Route: its player, Moffer, the lake and (if they make it) the Meat
 * Factory. The scene runs as the game's own does, frame for frame (30 to a second), with Moffer's
 * lines in Noelle's place and the player's name in Kris's.
 */
/datum/weird_route
	var/mob/living/carbon/human/player
	var/mob/living/carbon/human/moffer
	/// Where the player was, to go back to.
	var/turf/came_from
	var/datum/turf_reservation/lake
	var/datum/turf_reservation/factory
	/// The lake's bottom left turf (the game's x of 0 is WEIRD_ROUTE_LAKE_LEFT tiles east of it).
	var/turf/origin
	/// Where each of them is along the path, in the game's units, by mob.
	var/list/positions = list()
	/// Where the camera's centred, in the game's units, or null to follow the player.
	var/camera_x
	var/old_hud_version

	// The screen.
	var/atom/movable/screen/weird_route/box/box
	var/atom/movable/screen/weird_route/box/border/border
	var/atom/movable/screen/weird_route/box/portrait/portrait
	var/atom/movable/screen/weird_route/text/text
	var/atom/movable/screen/weird_route/text/option/left_option
	var/atom/movable/screen/weird_route/text/option/right_option
	var/atom/movable/screen/weird_route/heart/heart
	/// All black, over everything but the box.
	var/atom/movable/screen/weird_route/fill/blackout
	/// A cold blue over the lake while she remembers yesterday.
	var/atom/movable/screen/weird_route/fill/memory
	/// White over everything when they've hesitated too long.
	var/atom/movable/screen/weird_route/fill/whiteout
	/// White behind the two of them, taking the lake away.
	var/atom/movable/screen/weird_route/fill/behind/whiteness
	/// The pinwheel's wedges, a pair to each, in the order they fade in.
	var/list/atom/movable/screen/weird_route/pinwheel/pinwheel = list()
	/// How many of its wedges are showing.
	var/pinwheel_shown = 0
	/// How long it takes to turn once, in deciseconds, or 0 while it's still.
	var/pinwheel_period = 0
	/// How hard it ripples.
	var/pinwheel_wave = 0

	// The writer.
	/// Whether a message is being typed out, waited on, or chosen from.
	var/writer_busy = FALSE
	/// Bumped to stop whatever's being typed.
	var/writer_token = 0
	var/confirm_pressed = FALSE
	var/list/choices
	/// The option the heart's beside, 1 or 2.
	var/selected = 1
	/// The option chosen, or 0 while it's not.
	var/chosen = 0
	/// How far the text jitters, in pixels.
	var/text_shake = 0
	/// Whether the voice wavers.
	var/voice_waver = FALSE
	var/border_colour = COLOR_WHITE
	/// How far the box's inside has gone from black to white, 0 to 1.
	var/inner_white = 0
	var/highlight_colour = COLOR_YELLOW
	/// How far the heart's gone white, 0 to 1.
	var/heart_white = 0

	// The sound.
	var/music_channel
	var/chant_channel
	var/static_channel

/datum/weird_route/New(mob/living/carbon/human/player)
	. = ..()
	if(!player?.client)
		qdel(src)
		return
	lake = weird_route_build_lake()
	if(!lake)
		qdel(src)
		return
	origin = lake.bottom_left_turfs[1]
	src.player = player
	player.weird_route = src
	GLOB.weird_routes += src
	came_from = get_turf(player)
	music_channel = SSsounds.reserve_sound_channel(src)
	chant_channel = SSsounds.reserve_sound_channel(src)
	static_channel = SSsounds.reserve_sound_channel(src)
	moffer = make_moffer()
	hold(player)
	RegisterSignal(player, COMSIG_MOB_KEYDOWN, PROC_REF(on_key))
	RegisterSignals(player, list(COMSIG_QDELETING, COMSIG_MOB_LOGOUT, COMSIG_LIVING_DEATH), PROC_REF(on_lost))
	if(player.hud_used)
		old_hud_version = player.hud_used.hud_version
		player.hud_used.show_hud(HUD_STYLE_NOHUD)
	make_screen()
	INVOKE_ASYNC(src, PROC_REF(run))

/datum/weird_route/Destroy()
	GLOB.weird_routes -= src
	writer_token++
	if(player)
		UnregisterSignal(player, list(COMSIG_MOB_KEYDOWN, COMSIG_QDELETING, COMSIG_MOB_LOGOUT, COMSIG_LIVING_DEATH))
		let_go(player)
		player.weird_route = null
		for(var/channel in list(music_channel, chant_channel, static_channel))
			SEND_SOUND(player, sound(null, channel = channel))
		if(player.client)
			player.client.screen -= get_screen()
			player.client.pixel_x = 0
			player.client.pixel_y = 0
		if(old_hud_version)
			player.hud_used?.show_hud(old_hud_version)
		player.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]?.remove_filter("weird_route_blur")
		if(!QDELETED(player))
			player.forceMove(came_from || get_safe_random_station_turf())
	player = null
	QDEL_NULL(moffer)
	for(var/atom/movable/screen/part as anything in get_screen())
		qdel(part)
	SSsounds.free_datum_channels(src)
	QDEL_NULL(lake)
	QDEL_NULL(factory)
	return ..()

/datum/weird_route/proc/on_lost(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// Holds someone to the scene: nowhere to go, nothing in their hands, nothing to hurt them.
/datum/weird_route/proc/hold(mob/living/carbon/human/who)
	who.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_GODMODE), WEIRD_ROUTE_TRAIT)

/datum/weird_route/proc/let_go(mob/living/carbon/human/who)
	who.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_GODMODE), WEIRD_ROUTE_TRAIT)
	who.remove_filter("weird_route_sink")
	who.underlays.Cut()
	who.pixel_w = who.base_pixel_w
	who.pixel_z = who.base_pixel_z
	who.limb_rig?.set_seated(null)

/// Moffer: a moth, in Noelle's place.
/datum/weird_route/proc/make_moffer()
	var/mob/living/carbon/human/npc = new(origin)
	npc.set_species(/datum/species/moth)
	npc.gender = PLURAL
	npc.fully_replace_character_name(npc.real_name, "Moffer")
	npc.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(npc), ITEM_SLOT_ICLOTHING)
	npc.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(npc), ITEM_SLOT_FEET)
	if(!npc.dna.species.limb_rig_shape?["always"])
		npc.add_quirk(/datum/quirk/overanimated)
	hold(npc)
	return npc

/datum/weird_route/proc/get_screen()
	return list(box, border, portrait, text, left_option, right_option, heart, blackout, memory, whiteout, whiteness) + pinwheel - null

/datum/weird_route/proc/make_screen()
	box = new(null, null, src)
	border = new(null, null, src)
	portrait = new(null, null, src)
	text = new(null, null, src)
	left_option = new(null, null, src)
	left_option.index = 1
	left_option.maptext_x = 150
	right_option = new(null, null, src)
	right_option.index = 2
	right_option.maptext_x = 290
	heart = new(null, null, src)
	blackout = new(null, null, src)
	blackout.color = COLOR_BLACK
	memory = new(null, null, src)
	memory.color = "#0a1650"
	whiteout = new(null, null, src)
	whiteness = new(null, null, src)
	for(var/wedges in 1 to 4)
		var/atom/movable/screen/weird_route/pinwheel/pair = new(null, null, src)
		pair.icon_state = "pinwheel[wedges]"
		pinwheel += pair
	show_box(FALSE)
	show_choices(FALSE)
	player.client.screen += get_screen()

// Input.

/datum/weird_route/proc/on_key(mob/source, key, client/user, full_key)
	SIGNAL_HANDLER
	var/direction = user?.movement_keys[key]
	if(choices && (direction == WEST || direction == EAST))
		var/now = direction == WEST ? 1 : 2
		if(now != selected)
			selected = now
			play_sound("snd_menumove.wav")
			update_choices()
		return
	if(uppertext(key) in list("Z", "SPACE", "RETURN", "ENTER"))
		confirm()

/// A confirm press: moves the text on, or takes the picked option.
/datum/weird_route/proc/confirm()
	if(choices)
		choose(selected)
		return
	confirm_pressed = TRUE

/datum/weird_route/proc/choose(index)
	if(!choices || chosen)
		return
	selected = index
	chosen = index
	play_sound("snd_select.wav")

// Sound.

/// Plays one of the route's sounds to its player, if it's there (see WEIRD_ROUTE_SOUNDS).
/datum/weird_route/proc/play_sound(name, volume = 100, frequency = 0, channel = 0, repeat = FALSE)
	if(!player || !fexists(WEIRD_ROUTE_SOUNDS + name))
		return
	var/sound/played = sound(file(WEIRD_ROUTE_SOUNDS + name), repeat = repeat, channel = channel, volume = volume)
	played.frequency = frequency
	SEND_SOUND(player, played)

/// Changes how loud and how fast a looping sound plays. Volume's the game's (1 is as made, 3 the loudest).
/datum/weird_route/proc/tune(channel, volume, pitch)
	var/sound/update = sound(null, channel = channel, volume = clamp(volume * 40, 0, 100))
	update.frequency = max(pitch, 0.05)
	update.status = SOUND_UPDATE
	SEND_SOUND(player, update)

/datum/weird_route/proc/stop_sounds()
	for(var/channel in list(music_channel, chant_channel, static_channel))
		SEND_SOUND(player, sound(null, channel = channel))

// Where they stand, and the camera.

/// Puts someone at x along the path (the game's units: the lake's left edge is 0, 64 to a tile).
/datum/weird_route/proc/put(mob/living/who, x, row = WEIRD_ROUTE_LAKE_ROW)
	positions[who] = x
	var/pixels = x / 2
	var/turf/spot = locate(origin.x + WEIRD_ROUTE_LAKE_LEFT + floor(pixels / 32), origin.y + row - 1, origin.z)
	if(spot && who.loc != spot)
		who.forceMove(spot)
	who.pixel_w = who.base_pixel_w + pixels - floor(pixels / 32) * 32 - 16
	if(who == player)
		update_camera()

/// Walks someone to x over this many frames (without waiting, unless wait).
/datum/weird_route/proc/walk_to(mob/living/who, to_x, frames, wait = FALSE)
	if(!wait)
		INVOKE_ASYNC(src, PROC_REF(walk_to), who, to_x, frames, TRUE)
		return
	var/from_x = positions[who]
	var/started = world.time
	var/took = frames * WEIRD_ROUTE_FRAME
	while(world.time < started + took)
		put(who, from_x + (to_x - from_x) * (world.time - started) / took)
		sleep(world.tick_lag)
		if(QDELETED(src) || QDELETED(who))
			return
	put(who, to_x)

/// Pans the camera to centre on x over this many frames.
/datum/weird_route/proc/pan(to_x, frames)
	set waitfor = FALSE
	var/from_x = isnull(camera_x) ? positions[player] : camera_x
	var/started = world.time
	var/took = max(frames * WEIRD_ROUTE_FRAME, world.tick_lag)
	while(world.time < started + took)
		camera_x = from_x + (to_x - from_x) * (world.time - started) / took
		update_camera()
		sleep(world.tick_lag)
		if(QDELETED(src))
			return
	camera_x = to_x
	update_camera()

/datum/weird_route/proc/update_camera()
	var/client/viewer = player?.client
	if(!viewer || !origin)
		return
	var/centre = isnull(camera_x) ? positions[player] : camera_x
	viewer.pixel_x = round(centre / 2 - ((player.x - origin.x - WEIRD_ROUTE_LAKE_LEFT) * 32 + 16))

/// The screen shaking, up and down (the pans have the sideways).
/datum/weird_route/proc/shake_screen()
	var/client/viewer = player?.client
	if(!viewer)
		return
	animate(viewer, pixel_y = rand(-4, 4), time = 0.5)
	animate(pixel_y = rand(-3, 3), time = 0.5)
	animate(pixel_y = 0, time = 0.5)

/// A long shadow behind someone, the sun low over the water (or in the Meat Factory, off the white).
/datum/weird_route/proc/give_shadow(mob/living/who, toward = WEST, colour)
	var/image/shadow = image('voidcrew/modules/weird_route/icons/weird_route.dmi', "shadow")
	var/matrix/stretch = matrix()
	stretch.Scale(2.5, 1)
	shadow.transform = stretch
	shadow.pixel_w = toward == WEST ? -24 : 24
	shadow.pixel_z = 1
	shadow.color = colour
	shadow.appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	who.underlays.Cut()
	who.underlays += shadow

/// A pose for Moffer or the player (see /proc/weird_route_pose()), eased into over this many frames.
/datum/weird_route/proc/pose(mob/living/carbon/who, kind, frames = 8)
	if(!who?.limb_rig)
		return
	who.limb_rig.set_seated(kind == "kneel" || kind == "kneel_head_down" || kind == "kneel_head_up" || kind == "fall" ? "crouch" : null)
	who.limb_rig.play(list(list(weird_route_pose(kind), max(frames * WEIRD_ROUTE_FRAME, 0.5), SINE_EASING)), settle_after = FALSE)

/// Shakes someone where they stand, a few times.
/datum/weird_route/proc/shake(mob/living/who)
	var/home = who.pixel_w
	animate(who, pixel_w = home + 2, time = 0.5)
	for(var/i in 1 to 3)
		animate(pixel_w = home - 2, time = 0.5)
		animate(pixel_w = home + 2, time = 0.5)
	animate(pixel_w = home, time = 0.5)

/**
 * The poses standing in for Noelle's and Kris's sprites in this scene ("spr_noelle_silo_..."): the
 * names are theirs, without the prefix.
 */
/proc/weird_route_pose(kind)
	. = list()
	switch(kind)
		if("head_down")
			.[RIG_HEAD] = list("nod" = 28)
		if("up_head_tilt")
			.[RIG_HEAD] = list("nod" = -18, "tilt" = 12)
		if("up")
			.[RIG_HEAD] = list("nod" = -25)
		if("exasperated")
			.[RIG_CHEST] = list("bend" = -8)
			.[RIG_HEAD] = list("nod" = -10)
			.[RIG_L_ARM] = list("swing" = 50, "raise" = 45, "elbow" = 25)
			.[RIG_R_ARM] = list("swing" = 50, "raise" = 45, "elbow" = 25)
		if("hands_to_chest", "hands_to_chest_head_down", "hands_to_chest_head_down_more", "hands_to_chest_turn_head", "hands_to_chest_turn_up")
			.[RIG_L_ARM] = list("swing" = 35, "raise" = 15, "elbow" = 120)
			.[RIG_R_ARM] = list("swing" = 35, "raise" = 15, "elbow" = 120)
			switch(kind)
				if("hands_to_chest_head_down")
					.[RIG_HEAD] = list("nod" = 22)
				if("hands_to_chest_head_down_more")
					.[RIG_HEAD] = list("nod" = 34)
					.[RIG_CHEST] = list("bend" = 10)
				if("hands_to_chest_turn_head")
					.[RIG_HEAD] = list("nod" = 10, "tilt" = 10)
				if("hands_to_chest_turn_up")
					.[RIG_HEAD] = list("nod" = -20)
		if("hands_to_side")
			.[RIG_L_ARM] = list("swing" = -10, "raise" = 35)
			.[RIG_R_ARM] = list("swing" = -10, "raise" = 35)
		if("walk_left_hands_up")
			.[RIG_L_ARM] = list("swing" = 120, "raise" = 15, "elbow" = 20)
			.[RIG_R_ARM] = list("swing" = 120, "raise" = 15, "elbow" = 20)
		if("fall")
			.[RIG_CHEST] = list("bend" = 30)
			.[RIG_HEAD] = list("nod" = 30)
			.[RIG_L_ARM] = list("swing" = 20, "raise" = 10)
			.[RIG_R_ARM] = list("swing" = 20, "raise" = 10)
		if("kneel", "kneel_head_down")
			.[RIG_HEAD] = list("nod" = 26)
			.[RIG_L_ARM] = list("swing" = 15, "raise" = 10)
			.[RIG_R_ARM] = list("swing" = 15, "raise" = 10)
		if("kneel_head_up")
			.[RIG_HEAD] = list("nod" = -12)
		if("take_hands")
			.[RIG_L_ARM] = list("swing" = 70, "raise" = 5, "elbow" = 10)
			.[RIG_R_ARM] = list("swing" = 70, "raise" = 5, "elbow" = 10)
		// Leading, a hand held out behind for the one following.
		if("lead")
			.[RIG_L_ARM] = list("swing" = -45, "raise" = 10)
			.[RIG_R_ARM] = list("swing" = -45, "raise" = 10)
		// Following, a hand held out ahead.
		if("follow")
			.[RIG_L_ARM] = list("swing" = 45, "raise" = 10)
			.[RIG_R_ARM] = list("swing" = 45, "raise" = 10)

// The writer.

/// The player's first name, for Kris's.
/datum/weird_route/proc/get_kris()
	return first_name(player?.real_name) || "Kris"

/datum/weird_route/proc/show_box(shown, with_portrait = FALSE)
	box.alpha = shown ? 255 : 0
	border.alpha = shown ? 255 : 0
	portrait.alpha = shown && with_portrait ? 255 : 0
	text.maptext_x = with_portrait ? 90 : 18
	text.maptext_width = with_portrait ? 340 : 410
	if(!shown)
		text.maptext = null

/datum/weird_route/proc/show_choices(shown)
	left_option.alpha = shown ? 255 : 0
	right_option.alpha = shown ? 255 : 0
	heart.alpha = shown ? 255 : 0
	if(shown)
		update_choices()

/datum/weird_route/proc/update_choices()
	if(!choices)
		return
	left_option.maptext = weird_route_text(choices[1], selected == 1 ? highlight_colour : text_colour())
	right_option.maptext = weird_route_text(choices[2], selected == 2 ? highlight_colour : text_colour())
	heart.pixel_w = (selected == 1 ? left_option.maptext_x : right_option.maptext_x) - 30
	heart.pixel_z = 2

/// The text's colour: white on the black box, going dark as the box goes white.
/datum/weird_route/proc/text_colour()
	return weird_route_blend(COLOR_WHITE, COLOR_BLACK, inner_white)

/// One colour going over to another, 0 to 1 of the way: the game's merge_color().
/proc/weird_route_blend(from, to, amount)
	var/list/a = rgb2num(from)
	var/list/b = rgb2num(to)
	amount = clamp(amount, 0, 1)
	return rgb(a[1] + (b[1] - a[1]) * amount, a[2] + (b[2] - a[2]) * amount, a[3] + (b[3] - a[3]) * amount)

/// Some text in the box's font.
/proc/weird_route_text(message, colour)
	return "<span style='font-family: \"Pixellari\"; font-size: 12pt; line-height: 1.3; color: [colour]'>[message]</span>"

/**
 * Types out messages in the box, one at a time, each waiting on a press: lines are the game's own,
 * with "^1" a pause, "&" a new line, and a trailing "/" or "/%". A callback among them runs when the
 * box gets to it (the game's c_wait_box()). With choices (two options), the last message waits on a
 * choice instead, and chosen is set. Out of the box (in_box FALSE), the text's wherever it's been put.
 *
 * * voice - "snd_txtnoe.wav" for Moffer, "snd_text.wav" for nobody in particular
 * * rate - frames a letter: 1 is the game's usual, 2 and 4 slower
 */
/datum/weird_route/proc/write(list/lines, voice = "snd_txtnoe.wav", with_portrait = FALSE, rate = 1, list/choice_options, in_box = TRUE)
	var/token = ++writer_token
	writer_busy = TRUE
	chosen = 0
	selected = 1
	if(in_box)
		show_box(TRUE, with_portrait)
	var/list/entries = lines.Copy()
	var/messages = 0
	for(var/entry in entries)
		if(!istype(entry, /datum/callback))
			messages++
	if(!messages && choice_options)
		entries += ""
		messages = 1
	var/typed = 0
	for(var/entry in entries)
		if(istype(entry, /datum/callback))
			var/datum/callback/at_box = entry
			at_box.Invoke()
			continue
		typed++
		type_message(entry, voice, rate, token)
		if(token != writer_token)
			return
		if(choice_options && typed == messages)
			choices = choice_options
			show_choices(TRUE)
			while(!chosen)
				sleep(world.tick_lag)
				if(token != writer_token)
					return
			choices = null
			show_choices(FALSE)
		else
			confirm_pressed = FALSE
			while(!confirm_pressed)
				sleep(world.tick_lag)
				if(token != writer_token)
					return
	if(in_box)
		show_box(FALSE)
	writer_busy = FALSE

/// Types one message out, a letter at a time with the voice.
/datum/weird_route/proc/type_message(message, voice, rate, token)
	message = replacetext(message, "/%", "")
	message = replacetext(message, "/", "")
	message = replacetext(message, "%", "")
	message = replacetext(message, "Kris", get_kris())
	message = replacetext(message, "Noelle", "Moffer")
	var/shown = ""
	var/owed = 0
	var/last_voice = 0
	var/length = length(message)
	var/index = 1
	while(index <= length)
		var/letter = message[index]
		index++
		if(letter == "^" && index <= length && text2num(message[index]))
			owed += text2num(message[index]) * 10 * WEIRD_ROUTE_FRAME
			index++
			continue
		if(letter == "&")
			shown += "<br>"
			continue
		shown += html_encode(letter)
		owed += rate * WEIRD_ROUTE_FRAME
		if(!(letter in list(" ", ".", ",", "!", "?", "*", "(", ")", "\"")) && world.time > last_voice)
			last_voice = world.time
			play_sound(voice, 60, voice_waver ? 0.8 + rand() * 0.4 : 0)
		if(owed >= world.tick_lag)
			text.maptext = weird_route_text(shown, text_colour())
			sleep(owed)
			owed = 0
			if(token != writer_token)
				return
	text.maptext = weird_route_text(shown, text_colour())

/// Stops whatever's being typed or chosen, and puts the box away.
/datum/weird_route/proc/stop_writing()
	writer_token++
	writer_busy = FALSE
	choices = null
	show_choices(FALSE)
	show_box(FALSE)

/// Writes and waits for it to finish: the game's c_talk_wait().
/datum/weird_route/proc/say(list/lines, voice = "snd_txtnoe.wav", rate = 1)
	write(lines, voice, FALSE, rate)
