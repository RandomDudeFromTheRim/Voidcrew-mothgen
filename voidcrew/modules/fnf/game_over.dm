/**
 * Getting run off the health bar, Funkin' style, seen only by whoever lost.
 *
 * Everything goes black. An Experiment is left standing alone, drawn like a health doll, and
 * gets shot in the head: its head outline goes red, it snaps back and drops. Then RETRY?
 * pulses over the body while the game over music plays. Against the game, clicking it sings the
 * song again; against a person it just says GAME OVER. It goes away on its own after a while.
 */
/datum/fnf_game_over
	var/mob/living/singer
	var/datum/fnf_song/song
	var/difficulty
	/// Whether RETRY? starts the song again (only against the game).
	var/can_retry = FALSE
	/// Which way the fallen singer faces.
	var/facing = WEST
	var/list/atom/movable/screen/fnf/screens = list()
	var/atom/movable/screen/fnf/blackout
	/// The body, with the head riding on it.
	var/atom/movable/screen/fnf/figure
	var/atom/movable/screen/fnf/head
	var/atom/movable/screen/fnf/retry/retry_button
	var/music_channel
	var/retrying = FALSE

/datum/fnf_game_over/New(mob/living/singer, datum/fnf_song/song, difficulty, can_retry, facing)
	src.singer = singer
	src.song = song
	src.difficulty = difficulty
	src.can_retry = can_retry
	src.facing = facing
	var/client/viewer = singer.client
	RegisterSignals(singer, list(COMSIG_QDELETING, COMSIG_MOB_LOGOUT), PROC_REF(on_singer_gone))
	music_channel = SSsounds.reserve_sound_channel(src)
	animate(viewer, pixel_w = 0, pixel_z = 0, time = 3)

	blackout = add_screen("bar", 'voidcrew/modules/fnf/icons/fnf.dmi', "WEST,SOUTH to EAST,NORTH", 1)
	blackout.color = "#000000"
	blackout.alpha = 0
	animate(blackout, alpha = 255, time = 6)
	SEND_SOUND(singer, sound("voidcrew/modules/fnf/sound/loss.ogg", volume = 60))

	if(is_species(singer, /datum/species/experiment))
		figure = add_screen("expie_body", 'voidcrew/modules/fnf/icons/fnf_dead.dmi', "CENTER:-16,CENTER", 2)
		head = new
		head.icon = 'voidcrew/modules/fnf/icons/fnf_dead.dmi'
		head.icon_state = "expie_head"
		head.vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_DIR
		figure.vis_contents += head
		figure.dir = facing
		figure.alpha = 0
		animate(figure, alpha = 255, time = 6)
		addtimer(CALLBACK(src, PROC_REF(cock_gun)), 10, TIMER_DELETE_ME)
		addtimer(CALLBACK(src, PROC_REF(shoot)), 18, TIMER_DELETE_ME)
		addtimer(CALLBACK(src, PROC_REF(show_retry)), 32, TIMER_DELETE_ME)
	else
		addtimer(CALLBACK(src, PROC_REF(show_retry)), 12, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(end)), 20 SECONDS, TIMER_DELETE_ME)

/datum/fnf_game_over/Destroy()
	if(singer)
		UnregisterSignal(singer, list(COMSIG_QDELETING, COMSIG_MOB_LOGOUT))
		singer.client?.screen -= screens
		SEND_SOUND(singer, sound(null, channel = music_channel))
	figure?.vis_contents.Cut()
	QDEL_NULL(head)
	QDEL_LIST(screens)
	blackout = null
	figure = null
	retry_button = null
	SSsounds.free_datum_channels(src)
	singer = null
	return ..()

/datum/fnf_game_over/proc/add_screen(state, icon_file, screen_loc, layer_offset)
	var/atom/movable/screen/fnf/screen = new
	screen.icon = icon_file
	screen.icon_state = state
	screen.screen_loc = screen_loc
	screen.layer += layer_offset
	SET_PLANE_EXPLICIT(screen, FULLSCREEN_PLANE, singer)
	screens += screen
	singer.client?.screen += screen
	return screen

/datum/fnf_game_over/proc/on_singer_gone(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/fnf_game_over/proc/cock_gun()
	SEND_SOUND(singer, sound("voidcrew/modules/fnf/sound/gun_cock.ogg", volume = 60))

/// Bang. The head snaps back, then the whole body goes over backwards.
/datum/fnf_game_over/proc/shoot()
	SEND_SOUND(singer, sound("voidcrew/modules/fnf/sound/shot[rand(1, 4)].ogg", volume = 70))
	// Back is away from where it was facing.
	var/back = facing == EAST ? -1 : 1
	animate(blackout, color = "#ffffff", time = 0)
	animate(color = "#000000", time = 2)
	// Turned about the middle of the head, which sits 9 pixels above the sprite's middle.
	var/matrix/snapped = matrix()
	snapped.Translate(0, -9)
	snapped.Turn(back * 35)
	snapped.Translate(back * 3, 11)
	// The head goes red where it's hit.
	head.icon_state = "expie_head_shot"
	animate(head, transform = snapped, time = 1, easing = CUBIC_EASING|EASE_OUT)
	var/matrix/fallen = matrix()
	fallen.Turn(back * 90)
	fallen.Translate(back * 8, -22)
	animate(figure, transform = fallen, time = 5, delay = 2, easing = BOUNCE_EASING|EASE_OUT)
	addtimer(CALLBACK(src, PROC_REF(yelp)), 1, TIMER_DELETE_ME)

/datum/fnf_game_over/proc/yelp()
	SEND_SOUND(singer, sound(get_expie_death_sound(), volume = 50))

/datum/fnf_game_over/proc/show_retry()
	if(retrying)
		return
	var/sound/music = sound("voidcrew/modules/fnf/sound/gameover_loop.ogg", repeat = TRUE, channel = music_channel, volume = 45)
	SEND_SOUND(singer, music)
	retry_button = new
	retry_button.game_over = src
	retry_button.screen_loc = "CENTER,CENTER+2"
	SET_PLANE_EXPLICIT(retry_button, FULLSCREEN_PLANE, singer)
	retry_button.set_text(can_retry ? "RETRY?" : "GAME OVER")
	screens += retry_button
	singer.client?.screen += retry_button

/// Clicked RETRY?: the jingle, then the song again.
/datum/fnf_game_over/proc/retry()
	if(retrying || !can_retry)
		return
	retrying = TRUE
	SEND_SOUND(singer, sound(null, channel = music_channel))
	SEND_SOUND(singer, sound("voidcrew/modules/fnf/sound/gameover_retry.ogg", volume = 60))
	retry_button.confirm()
	animate(blackout, alpha = 255, time = 15)
	addtimer(CALLBACK(src, PROC_REF(sing_again)), 25, TIMER_DELETE_ME)

/datum/fnf_game_over/proc/sing_again()
	var/mob/living/again = singer
	var/datum/fnf_song/song_again = song
	var/difficulty_again = difficulty
	qdel(src)
	if(QDELETED(again) || again.stat != CONSCIOUS)
		return
	var/obj/item/fnf_microphone/microphone = locate() in again.held_items
	if(microphone?.battle)
		if(microphone.battle.state != FNF_STATE_OVER)
			return
		microphone.battle = null
	var/datum/fnf_battle/battle = new(song_again, difficulty_again, microphone)
	if(microphone)
		microphone.battle = battle
	battle.preload(again)
	battle.start(again, null)

/datum/fnf_game_over/proc/end()
	if(retrying)
		return
	animate(blackout, alpha = 0, time = 10)
	for(var/atom/movable/screen/fnf/screen as anything in screens - blackout)
		animate(screen, alpha = 0, time = 10)
	QDEL_IN(src, 10)

/atom/movable/screen/fnf
	icon = 'voidcrew/modules/fnf/icons/fnf.dmi'
	plane = FULLSCREEN_PLANE
	layer = 50
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE|KEEP_TOGETHER

/// RETRY?, pulsing. A black box behind the text makes it easy to click.
/atom/movable/screen/fnf/retry
	icon_state = "bar"
	color = "#000000"
	layer = 53
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/datum/fnf_game_over/game_over
	var/atom/movable/screen/fnf/label

/atom/movable/screen/fnf/retry/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	transform = matrix(3, 0, 0, 0, 1, 0)
	label = new
	label.appearance_flags = RESET_TRANSFORM|RESET_COLOR|PIXEL_SCALE
	label.vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_ID
	label.maptext_width = 128
	label.maptext_height = 32
	label.maptext_x = -48
	label.maptext_y = 8
	vis_contents += label

/atom/movable/screen/fnf/retry/Destroy()
	vis_contents.Cut()
	QDEL_NULL(label)
	game_over = null
	return ..()

/atom/movable/screen/fnf/retry/proc/set_text(text)
	label.maptext = MAPTEXT("<span style='text-align:center;font-size:12pt;color:#ffffff;-dm-text-outline:1px #000000'><b>[text]</b></span>")
	animate(label, alpha = 90, time = 6, loop = -1, easing = SINE_EASING)
	animate(alpha = 255, time = 6, easing = SINE_EASING)

/atom/movable/screen/fnf/retry/proc/confirm()
	label.maptext = MAPTEXT("<span style='text-align:center;font-size:12pt;color:#ffe066;-dm-text-outline:1px #000000'><b>RETRY!</b></span>")
	animate(label, alpha = 255, transform = matrix() * 1.3, time = 1)
	animate(transform = matrix(), time = 2)

/atom/movable/screen/fnf/retry/Click(location, control, params)
	if(usr == game_over?.singer)
		game_over.retry()
