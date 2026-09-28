/**
 * Getting run off the health bar, Funkin' style, seen only by whoever lost.
 *
 * Everything goes black. An Experiment is left standing alone, drawn like a health doll,
 * cowering, and gets shot in the head: its head outline goes red, its head whips back, its arms
 * fling up, its knees buckle and it goes over backwards, bouncing and spraying blood, then lies
 * twitching in the spreading pool (all baked into fnf_dead.dmi, after Boyfriend's death). RETRY?
 * pulses over the body while the game over music plays. Against the game, clicking it sings the
 * song again; against a person it just says GAME OVER. It goes away on its own after a while,
 * and the singer stays down on the floor until it does.
 *
 * The screens go through the mob's fullscreen overlays, so a HUD rebuild puts them back rather
 * than wiping them, and they land on the right plane whatever z-level the singer is on.
 */
/datum/fnf_game_over
	var/mob/living/singer
	var/datum/fnf_song/song
	var/difficulty
	/// Whether RETRY? starts the song again (only against the game).
	var/can_retry = FALSE
	/// Which way the fallen singer faces.
	var/facing = WEST
	/// The fullscreen categories this put up, to take down again.
	var/list/categories = list()
	var/atom/movable/screen/fullscreen/fnf/blackout
	/// The Experiment, standing, dying and then twitching.
	var/atom/movable/screen/fullscreen/fnf/figure
	var/atom/movable/screen/fullscreen/fnf/retry/retry_button
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
	singer.add_traits(list(TRAIT_FLOORED, TRAIT_IMMOBILIZED), FNF_GAME_OVER_TRAIT)

	blackout = add_screen("fnf_blackout", /atom/movable/screen/fullscreen/fnf)
	blackout.alpha = 0
	animate(blackout, alpha = 255, time = 6)
	SEND_SOUND(singer, sound("voidcrew/modules/fnf/sound/loss.ogg", volume = 60))

	if(is_species(singer, /datum/species/experiment))
		// 160 by 96, standing on the middle of its bottom edge, drawn twice size with its feet
		// kept on the singer's tile.
		figure = add_screen("fnf_figure", /atom/movable/screen/fullscreen/fnf/figure)
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
		singer.remove_traits(list(TRAIT_FLOORED, TRAIT_IMMOBILIZED), FNF_GAME_OVER_TRAIT)
		for(var/category in categories)
			singer.clear_fullscreen(category, FALSE)
		SEND_SOUND(singer, sound(null, channel = music_channel))
	categories.Cut()
	blackout = null
	figure = null
	retry_button = null
	SSsounds.free_datum_channels(src)
	singer = null
	return ..()

/datum/fnf_game_over/proc/add_screen(category, type)
	categories += category
	return singer.overlay_fullscreen(category, type)

/datum/fnf_game_over/proc/on_singer_gone(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/fnf_game_over/proc/cock_gun()
	SEND_SOUND(singer, sound("voidcrew/modules/fnf/sound/gun_cock.ogg", volume = 60))

/// Bang. The death plays through once, then it lies there twitching.
/datum/fnf_game_over/proc/shoot()
	SEND_SOUND(singer, sound("voidcrew/modules/fnf/sound/shot[rand(1, 4)].ogg", volume = 70))
	animate(blackout, color = "#ffffff", time = 0)
	animate(color = "#000000", time = 2)
	// A kick of recoil on the whole figure, on top of what the frames do.
	var/back = facing == EAST ? -1 : 1
	animate(figure, transform = matrix(2, 0, back * 6, 0, 2, 48), time = 0.5, easing = CUBIC_EASING|EASE_OUT)
	animate(transform = matrix(2, 0, 0, 0, 2, 48), time = 2)
	figure.icon_state = "expie_death"
	// 31 frames at half a decisecond each.
	addtimer(CALLBACK(src, PROC_REF(twitch)), 15.5, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(yelp)), 1, TIMER_DELETE_ME)

/datum/fnf_game_over/proc/twitch()
	figure.icon_state = "expie_twitch"

/datum/fnf_game_over/proc/yelp()
	SEND_SOUND(singer, sound(get_expie_death_sound(), volume = 50))

/datum/fnf_game_over/proc/show_retry()
	if(retrying)
		return
	var/sound/music = sound("voidcrew/modules/fnf/sound/gameover_loop.ogg", repeat = TRUE, channel = music_channel, volume = 45)
	SEND_SOUND(singer, music)
	retry_button = add_screen("fnf_retry", /atom/movable/screen/fullscreen/fnf/retry)
	retry_button.game_over = src
	retry_button.set_text(can_retry ? "RETRY?" : "GAME OVER")

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
	for(var/atom/movable/screen/fullscreen/fnf/screen as anything in list(blackout, figure, retry_button))
		if(screen)
			animate(screen, alpha = 0, time = 10)
	QDEL_IN(src, 10)

/// The black that covers everything.
/atom/movable/screen/fullscreen/fnf
	icon = 'voidcrew/modules/fnf/icons/fnf.dmi'
	icon_state = "bar"
	color = "#000000"
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = 50
	appearance_flags = PIXEL_SCALE|KEEP_TOGETHER
	show_when_dead = TRUE

/// The fallen Experiment. 160 by 96, standing on the middle of its bottom edge, drawn twice size
/// with its feet kept on the singer's tile.
/atom/movable/screen/fullscreen/fnf/figure
	icon = 'voidcrew/modules/fnf/icons/fnf_dead.dmi'
	icon_state = "expie_doomed"
	color = null
	screen_loc = "CENTER:-64,CENTER"
	layer = 51

/atom/movable/screen/fullscreen/fnf/figure/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	transform = matrix(2, 0, 0, 0, 2, 48)

/// RETRY?, pulsing. A black box behind the text makes it easy to click.
/atom/movable/screen/fullscreen/fnf/retry
	screen_loc = "CENTER,CENTER+4"
	layer = 53
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/datum/fnf_game_over/game_over
	var/atom/movable/screen/label

/atom/movable/screen/fullscreen/fnf/retry/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	transform = matrix(8, 0, 0, 0, 2.5, 0)
	label = new
	label.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	label.appearance_flags = RESET_TRANSFORM|RESET_COLOR|PIXEL_SCALE
	label.vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_ID
	label.maptext_width = 320
	label.maptext_height = 64
	label.maptext_x = -144
	label.maptext_y = -8
	vis_contents += label

/atom/movable/screen/fullscreen/fnf/retry/Destroy()
	vis_contents.Cut()
	QDEL_NULL(label)
	game_over = null
	return ..()

/atom/movable/screen/fullscreen/fnf/retry/proc/set_text(text)
	label.maptext = MAPTEXT("<span style='text-align:center;font-size:28pt;color:#ffffff;-dm-text-outline:2px #000000'><b>[text]</b></span>")
	// Pops in, then throbs.
	label.transform = matrix() * 2
	animate(label, transform = matrix(), time = 3, easing = BACK_EASING|EASE_OUT)
	animate(alpha = 110, transform = matrix() * 0.92, time = 6, loop = -1, easing = SINE_EASING)
	animate(alpha = 255, transform = matrix() * 1.08, time = 6, easing = SINE_EASING)

/atom/movable/screen/fullscreen/fnf/retry/proc/confirm()
	label.maptext = MAPTEXT("<span style='text-align:center;font-size:28pt;color:#ffe066;-dm-text-outline:2px #000000'><b>RETRY!</b></span>")
	animate(label, alpha = 255, transform = matrix() * 1.5, time = 1)
	animate(transform = matrix() * 1.2, time = 3)

/atom/movable/screen/fullscreen/fnf/retry/Click(location, control, params)
	if(usr == game_over?.singer)
		game_over.retry()
