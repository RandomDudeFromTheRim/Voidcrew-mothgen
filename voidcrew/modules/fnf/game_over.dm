/**
 * Getting run off the health bar, Funkin' style, seen only by whoever lost.
 *
 * Everything goes black. An Experiment is left standing alone, drawn like a health doll,
 * cowering, and gets shot in the head: its head outline goes red, its head whips back, its arms
 * fling up, its knees buckle and it goes over backwards, bouncing and spraying blood, then lies
 * twitching in the spreading pool (all baked into fnf_dead.dmi, after Boyfriend's death).
 *
 * Then it waits, the game over music looping, for the singer to pick: RETRY (against the game
 * only) or GIVE UP. Until then they're down on the floor, can't touch anything, and their mic
 * stays in their hand.
 *
 * An Experiment that retries makes its last stand, as in Casualties Unknown: "Let's not give up
 * just yet." flickers over everything to a drone while the world slowly fades back in, and the
 * song counts in again as the drone ends. The new battle is set up while it's still dark, so the
 * singer is already back in their stance when the world comes back.
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
	var/atom/movable/screen/fullscreen/fnf/button/retry_button
	var/atom/movable/screen/fullscreen/fnf/button/give_up_button
	var/atom/movable/screen/fullscreen/fnf/laststand
	/// Held items glued to the singer's hands, as weakrefs.
	var/list/datum/weakref/stuck_items = list()
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
	// Down, and out of it: no touching the world, and the mic doesn't fall out of their hand when
	// they hit the floor.
	for(var/obj/item/held in singer.held_items)
		ADD_TRAIT(held, TRAIT_NODROP, FNF_GAME_OVER_TRAIT)
		stuck_items += WEAKREF(held)
	singer.add_traits(list(TRAIT_FLOORED, TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_UI_BLOCKED), FNF_GAME_OVER_TRAIT)

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
		addtimer(CALLBACK(src, PROC_REF(show_buttons)), 32, TIMER_DELETE_ME)
	else
		addtimer(CALLBACK(src, PROC_REF(show_buttons)), 12, TIMER_DELETE_ME)

/datum/fnf_game_over/Destroy()
	if(singer)
		UnregisterSignal(singer, list(COMSIG_QDELETING, COMSIG_MOB_LOGOUT))
		release_singer()
		for(var/category in categories)
			singer.clear_fullscreen(category, FALSE)
		SEND_SOUND(singer, sound(null, channel = music_channel))
	categories.Cut()
	blackout = null
	figure = null
	retry_button = null
	give_up_button = null
	laststand = null
	SSsounds.free_datum_channels(src)
	singer = null
	return ..()

/// Lets the singer up and gives them their hands back.
/datum/fnf_game_over/proc/release_singer()
	singer.remove_traits(list(TRAIT_FLOORED, TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_UI_BLOCKED), FNF_GAME_OVER_TRAIT)
	for(var/datum/weakref/item_ref as anything in stuck_items)
		var/obj/item/held = item_ref.resolve()
		if(held)
			REMOVE_TRAIT(held, TRAIT_NODROP, FNF_GAME_OVER_TRAIT)
	stuck_items.Cut()

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

/datum/fnf_game_over/proc/show_buttons()
	if(retrying)
		return
	var/sound/music = sound("voidcrew/modules/fnf/sound/gameover_loop.ogg", repeat = TRUE, channel = music_channel, volume = 45)
	SEND_SOUND(singer, music)
	if(can_retry)
		retry_button = add_screen("fnf_retry", /atom/movable/screen/fullscreen/fnf/button/retry)
		retry_button.game_over = src
		retry_button.pop_in()
	give_up_button = add_screen("fnf_give_up", /atom/movable/screen/fullscreen/fnf/button/give_up)
	give_up_button.game_over = src
	give_up_button.pop_in()

/// Clicked RETRY: an Experiment makes its last stand, anyone else hears the jingle; then the song
/// starts again.
/datum/fnf_game_over/proc/retry()
	if(retrying || !can_retry)
		return
	retrying = TRUE
	SEND_SOUND(singer, sound(null, channel = music_channel))
	retry_button.confirm()
	animate(give_up_button, alpha = 0, time = 3)
	if(figure)
		last_stand()
		return
	SEND_SOUND(singer, sound("voidcrew/modules/fnf/sound/gameover_retry.ogg", volume = 60))
	animate(blackout, alpha = 255, time = 15)
	addtimer(CALLBACK(src, PROC_REF(sing_again), 0, 20), 25, TIMER_DELETE_ME)
	// Back into the light as the count in starts.
	animate(blackout, alpha = 255, time = 25)
	animate(alpha = 0, time = 20, easing = SINE_EASING)

/**
 * "Let's not give up just yet." Eight seconds of drone, the screen flickering through its three
 * grainy takes, fading back slowly to the world as it ends. Once it's fully dark the new battle is
 * set up, counting in two seconds late, as the drone runs out.
 */
/datum/fnf_game_over/proc/last_stand()
	SEND_SOUND(singer, sound("voidcrew/modules/fnf/sound/laststand_drone.ogg", volume = 70))
	laststand = add_screen("fnf_laststand", /atom/movable/screen/fullscreen/fnf/laststand)
	laststand.alpha = 0
	// In over the dead body, held a while, then eased away as the world comes back.
	animate(laststand, alpha = 255, time = 8)
	animate(alpha = 255, time = 14)
	animate(alpha = 0, time = 50, easing = SINE_EASING)
	animate(figure, alpha = 0, time = 8)
	animate(retry_button, alpha = 0, time = 10, delay = 5)
	animate(blackout, alpha = 255, time = 30)
	animate(alpha = 0, time = 50, easing = SINE_EASING)
	addtimer(CALLBACK(src, PROC_REF(sing_again), 2 SECONDS, 50), 30, TIMER_DELETE_ME)

/**
 * Starts the song again, straight from the floor into the new battle so they never stand around
 * in between.
 *
 * * lead_in - extra deciseconds before the count in
 * * linger - deciseconds to leave the game over screens up, to finish fading
 */
/datum/fnf_game_over/proc/sing_again(lead_in = 0, linger = 0)
	var/mob/living/again = singer
	var/datum/fnf_song/song_again = song
	var/difficulty_again = difficulty
	if(linger)
		QDEL_IN(src, linger)
	else
		qdel(src)
	if(QDELETED(again) || again.stat != CONSCIOUS)
		return
	var/obj/item/fnf_microphone/microphone = locate() in again.held_items
	if(microphone?.battle)
		if(microphone.battle.state != FNF_STATE_OVER)
			return
		microphone.battle = null
	var/datum/fnf_battle/battle = new(song_again, difficulty_again, microphone)
	battle.lead_in = lead_in
	if(microphone)
		microphone.battle = battle
	battle.preload(again)
	battle.start(again, null)
	// Only now let go, so they go from lying down straight into their stance.
	if(!QDELETED(src))
		release_singer()

/// Clicked GIVE UP: everything fades out and the singer gets up.
/datum/fnf_game_over/proc/give_up()
	if(retrying)
		return
	retrying = TRUE
	SEND_SOUND(singer, sound(null, channel = music_channel))
	for(var/atom/movable/screen/fullscreen/fnf/screen as anything in list(blackout, figure, retry_button, give_up_button))
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

/// "Let's not give up just yet.", 640 by 360, centred and blown up to cover the screen.
/atom/movable/screen/fullscreen/fnf/laststand
	icon = 'voidcrew/modules/fnf/icons/laststand.dmi'
	icon_state = "laststand"
	color = null
	screen_loc = "CENTER-9:-16,CENTER-5:-4"
	layer = 55

/atom/movable/screen/fullscreen/fnf/laststand/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	transform = matrix() * 1.4

/**
 * A game over button. These sit on the HUD plane: the fullscreen plane doesn't take clicks at all.
 * They light up under the mouse.
 */
/atom/movable/screen/fullscreen/fnf/button
	icon = 'voidcrew/modules/fnf/icons/fnf_buttons.dmi'
	color = null
	plane = HUD_PLANE
	layer = 60
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	appearance_flags = PIXEL_SCALE
	var/datum/fnf_game_over/game_over
	/// Whether it's been clicked, and stays lit.
	var/pressed = FALSE

/atom/movable/screen/fullscreen/fnf/button/Destroy()
	game_over = null
	return ..()

/atom/movable/screen/fullscreen/fnf/button/proc/pop_in()
	transform = matrix() * 1.8
	alpha = 0
	animate(src, transform = matrix(), alpha = 255, time = 3, easing = BACK_EASING|EASE_OUT)

/atom/movable/screen/fullscreen/fnf/button/MouseEntered(location, control, params)
	. = ..()
	if(!pressed)
		icon_state = "[initial(icon_state)]_lit"

/atom/movable/screen/fullscreen/fnf/button/MouseExited(location, control, params)
	. = ..()
	if(!pressed)
		icon_state = initial(icon_state)

/atom/movable/screen/fullscreen/fnf/button/proc/confirm()
	pressed = TRUE
	icon_state = "[initial(icon_state)]_lit"
	animate(src, transform = matrix() * 1.3, time = 1)
	animate(transform = matrix() * 1.1, time = 3)

/// RETRY, throbbing gently until it's clicked.
/atom/movable/screen/fullscreen/fnf/button/retry
	icon_state = "retry"
	screen_loc = "CENTER:-80,CENTER+3"

/atom/movable/screen/fullscreen/fnf/button/retry/pop_in()
	transform = matrix() * 1.8
	alpha = 0
	animate(src, transform = matrix(), alpha = 255, time = 3, easing = BACK_EASING|EASE_OUT)
	animate(transform = matrix() * 0.94, time = 6, loop = -1, easing = SINE_EASING)
	animate(transform = matrix() * 1.04, time = 6, easing = SINE_EASING)

/atom/movable/screen/fullscreen/fnf/button/retry/Click(location, control, params)
	if(usr == game_over?.singer)
		game_over.retry()

/atom/movable/screen/fullscreen/fnf/button/give_up
	icon_state = "giveup"
	screen_loc = "CENTER:-80,CENTER-3"

/atom/movable/screen/fullscreen/fnf/button/give_up/Click(location, control, params)
	if(usr == game_over?.singer)
		game_over.give_up()
