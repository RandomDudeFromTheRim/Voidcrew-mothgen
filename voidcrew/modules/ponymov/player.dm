/**
 * pony.mov smites: one of the series' episodes acted out around the victim, who's made a pony and
 * given a part in it. Only they see it: the sets are a map of their own, on reserved ground.
 *
 * An episode is a screenplay, a list of timed lines (see /datum/ponymov/proc/run_line()), played
 * against the host's own copy of its soundtrack. Everything seen is acted out in the game, the
 * episode's close-ups done by zooming the victim's screen in on whoever they're of, as the rhythm
 * battles do. Nothing of the episode itself ships: its sound and subtitles are cut from a copy of
 * it by tools/ponymov/extract.py into data/ponymov/<episode>/ (gitignored), and it plays without
 * whichever of those aren't there.
 */

#define PONYMOV_TRAIT "ponymov"
#define PONYMOV_MAPS "_maps/voidcrew/templates/ponymov/"
#define PONYMOV_DATA "data/ponymov/"
/// The width and height of each set in an episode's map, sets being laid side by side.
#define PONYMOV_SET_WIDTH 21
#define PONYMOV_SET_HEIGHT 17

/// Sleeps until this many seconds into the episode, and gives up if it ended meanwhile.
#define PONYMOV_AT(seconds) sleep(started + (seconds) * 10 - world.time); if(QDELETED(src)) { return }

/mob/living/carbon/human
	/// The pony.mov episode they're in, if any.
	var/datum/ponymov/ponymov

/area/ponymov_set
	name = "Ponyville"
	icon = 'icons/area/areas_misc.dmi'
	icon_state = "unknown"
	area_flags = HIDDEN_AREA | EVENT_PROTECTED | NOTELEPORT | NO_DEATH_MESSAGE
	default_gravity = STANDARD_GRAVITY
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE
	ambience_index = null
	ambient_buzz = null

/// Just looks, set up in the sets' maps.
/obj/effect/ponymov_scenery
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = OBJ_LAYER
	icon = 'voidcrew/modules/ponymov/icons/ponymov.dmi'

/// What the camera's held on: the middle of whichever set's on.
/obj/effect/abstract/ponymov_camera
	name = ""
	invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/ponymov
	icon = 'voidcrew/modules/ponymov/icons/ponymov.dmi'
	screen_loc = "CENTER"
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_TRANSFORM | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ABOVE_HUD_PLANE

/// Black over the whole view, for cuts and the card at the start.
/atom/movable/screen/ponymov/blackout
	icon_state = "black"
	layer = 2
	alpha = 0

/// Big words over the blackout: the title, the end.
/atom/movable/screen/ponymov/card
	icon = null
	layer = 3
	maptext_width = 480
	maptext_height = 160
	maptext_x = -224
	maptext_y = -64

/// A flashback's soft white edge.
/atom/movable/screen/ponymov/vignette
	icon = 'voidcrew/modules/ponymov/icons/ponymov_vignette.dmi'
	icon_state = "vignette"
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | TILE_BOUND
	layer = 1
	alpha = 0

/atom/movable/screen/ponymov/subtitle
	icon = null
	layer = 4
	maptext_width = 576
	maptext_height = 64
	maptext_x = -272
	maptext_y = -224

/**
 * One showing of an episode to one victim. Subtypes are the episodes: their map, cast and
 * screenplay, and any of their lines too odd for the screenplay's verbs (their beat_* procs).
 */
/datum/ponymov
	/// Whose showing it is.
	var/mob/living/carbon/human/victim
	/// Which part they've got, a key of the cast.
	var/role
	/// The episode's folder under data/ponymov/, and its map under PONYMOV_MAPS.
	var/episode
	/// The sets in the map, in order from the left.
	var/list/set_names = list()
	/// Every part and how they look: role = list(name, species, look...). See make_actor().
	var/list/parts = list()
	/// The screenplay: list(seconds, verb, args...), in order.
	var/list/screenplay = list()
	/// How long the episode runs, in seconds.
	var/running_time = 0

	var/datum/turf_reservation/stage
	var/turf/came_from
	var/started
	var/obj/effect/abstract/ponymov_camera/camera
	/// Who's playing what, the victim among them.
	var/list/mob/living/carbon/human/cast = list()
	/// Things brought on by the screenplay, by name.
	var/list/atom/movable/props = list()
	/// Who's riding on whom: carrier = rider.
	var/list/mob/living/carbon/human/riders = list()
	/// The victim's looks before, given back if they come out of it alive.
	var/datum/species/old_species

	var/atom/movable/screen/ponymov/blackout/blackout
	var/atom/movable/screen/ponymov/card/card
	var/atom/movable/screen/ponymov/vignette/vignette
	var/atom/movable/screen/ponymov/subtitle/subtitle
	/// The host's subtitles: list(start, end, speaker, text), seconds.
	var/list/cues = list()
	var/sound/soundtrack
	/// How far the victim's screen is zoomed in (see zoom()).
	var/zoomed = 1
	/// Their HUD before it was hidden, to give back.
	var/old_hud_version

/datum/ponymov/New(mob/living/carbon/human/victim, role)
	. = ..()
	if(!victim?.client)
		qdel(src)
		return
	src.victim = victim
	src.role = role || pick_role()
	victim.ponymov = src
	RegisterSignals(victim, list(COMSIG_QDELETING, COMSIG_MOB_LOGOUT), PROC_REF(on_lost))
	INVOKE_ASYNC(src, PROC_REF(prepare))

/// Which part a victim gets when the admin doesn't pick.
/datum/ponymov/proc/pick_role()
	return pick(parts)

/datum/ponymov/proc/prepare()
	var/static/list/templates = list()
	var/datum/map_template/template = templates[episode]
	if(!template)
		template = new(PONYMOV_MAPS + "[episode].dmm", cache = TRUE)
		templates[episode] = template
	stage = SSmapping.request_turf_block_reservation(template.width, template.height, requester = "pony.mov")
	if(!stage)
		message_admins("pony.mov couldn't take [key_name_admin(victim)]: there's no room for it.")
		qdel(src)
		return
	template.load(stage.bottom_left_turfs[1])
	load_data()
	if(QDELETED(src))
		return
	came_from = get_turf(victim)
	camera = new(set_turf(set_names[1], 11, 9))
	victim.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_GODMODE), PONYMOV_TRAIT)
	make_screen()
	// The card goes up before they're moved, and comes down when the episode starts.
	blackout.alpha = 255
	cast_everyone()
	victim.reset_perspective(camera)
	if(victim.hud_used)
		old_hud_version = victim.hud_used.hud_version
		victim.hud_used.show_hud(HUD_STYLE_NOHUD)
	sleep(2 SECONDS) // everyone's sprites get sent meanwhile
	if(QDELETED(src))
		return
	run_screenplay()

/// Reads what the host has cut from the episode: soundtrack and subtitles.
/datum/ponymov/proc/load_data()
	var/path = PONYMOV_DATA + "[episode]/"
	if(fexists(path + "soundtrack.ogg"))
		soundtrack = sound(file(path + "soundtrack.ogg"), channel = CHANNEL_ADMIN, volume = 80)
	if(fexists(path + "subtitles.srt"))
		cues = ponymov_read_srt(file2text(path + "subtitles.srt"))
	if(!soundtrack)
		message_admins("pony.mov: there's no [path]soundtrack.ogg, so [episode] plays silent (see tools/ponymov/extract.py).")

/// A turf of one of the sets, by its x and y within the set (from 1, at its bottom left).
/datum/ponymov/proc/set_turf(set_name, x, y)
	var/turf/origin = stage.bottom_left_turfs[1]
	return locate(origin.x + (set_names.Find(set_name) - 1) * PONYMOV_SET_WIDTH + x - 1, origin.y + y - 1, origin.z)

/// Which set a turf's in, and where in it.
/datum/ponymov/proc/where(atom/thing)
	var/turf/origin = stage.bottom_left_turfs[1]
	var/turf/spot = get_turf(thing)
	var/column = spot.x - origin.x
	return list(set_names[round(column / PONYMOV_SET_WIDTH) + 1], column % PONYMOV_SET_WIDTH + 1, spot.y - origin.y + 1)

/datum/ponymov/proc/make_screen()
	blackout = new(null, null)
	card = new(null, null)
	vignette = new(null, null)
	subtitle = new(null, null)
	victim.client.screen += list(blackout, card, vignette, subtitle)
	fit_to_view(blackout, 32, 32)
	fit_to_view(vignette, 304, 240)

/// Stretches a screen object of this many pixels to cover the victim's whole view.
/datum/ponymov/proc/fit_to_view(atom/movable/screen/thing, width, height)
	var/list/view = getviewsize(victim.client.view)
	var/scale = max(view[1] * world.icon_size / width, view[2] * world.icon_size / height)
	thing.transform = matrix(scale, 0, (width - world.icon_size) / -2, 0, scale, (height - world.icon_size) / -2)

/**
 * Zooms the victim's screen in on whatever it's looking at, by scaling the world's planes as the
 * rhythm battles do (see /datum/fnf_side/proc/zoom_screen()). Their HUD planes, which hold the
 * episode's blackout, card and subtitles, stay as they are.
 */
/datum/ponymov/proc/zoom(scale, seconds)
	zoomed = scale
	var/atom/movable/plane_master_controller/screen = victim.hud_used?.plane_master_controllers[PLANE_MASTERS_NON_MASTER]
	if(!screen)
		return
	for(var/atom/movable/screen/plane_master/plate as anything in screen.get_planes())
		if(plate.plane >= HUD_PLANE)
			continue
		if(scale == 1)
			plate.appearance_flags = (plate.appearance_flags & ~PIXEL_SCALE) | (initial(plate.appearance_flags) & PIXEL_SCALE)
		else
			plate.appearance_flags |= PIXEL_SCALE
		animate(plate, transform = matrix() * scale, time = seconds * 10, easing = SINE_EASING)

/// Everyone in their places: the victim made a pony and put in their part, the rest new.
/datum/ponymov/proc/cast_everyone()
	for(var/part in parts)
		var/mob/living/carbon/human/actor = (part == role) ? victim : new /mob/living/carbon/human(set_turf(set_names[1], 1, 1))
		if(actor == victim)
			old_species = victim.dna.species.type
		dress_actor(actor, part)
		actor.density = FALSE
		if(actor != victim)
			actor.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_GODMODE, TRAIT_NO_TRANSFORM), PONYMOV_TRAIT)
		actor.forceMove(get_turf(camera)) // out of sight under the camera until they're placed
		actor.alpha = 0
		cast[part] = actor

/// Makes them look the part: list(name, species, coat, mane, hairstyle, eyes, pony archetype).
/datum/ponymov/proc/dress_actor(mob/living/carbon/human/actor, part)
	var/list/look = parts[part]
	if(actor != victim)
		actor.fully_replace_character_name(actor.real_name, look[1] || pick(GLOB.pony_names))
	if(look[7])
		actor.dna.features[FEATURE_PONY_ARCHETYPE] = look[7]
	actor.dna.features[FEATURE_MUTANT_COLOR] = look[3]
	actor.set_species(look[2])
	actor.set_haircolor(look[4], update = FALSE)
	actor.set_hairstyle(look[5], update = FALSE)
	actor.set_eye_color(look[6], look[6])
	actor.update_body(is_creating = TRUE)

/datum/ponymov/proc/run_screenplay()
	started = world.time
	if(soundtrack)
		SEND_SOUND(victim, soundtrack)
	INVOKE_ASYNC(src, PROC_REF(run_cues))
	animate(blackout, alpha = 0, time = 0.5 SECONDS)
	for(var/list/line as anything in screenplay)
		PONYMOV_AT(line[1])
		run_line(line)
	PONYMOV_AT(running_time)
	finish()

/// The host's subtitles, each said by its speaker if they're in the cast, and shown along the bottom.
/datum/ponymov/proc/run_cues()
	for(var/list/cue as anything in cues)
		PONYMOV_AT(cue[1])
		var/mob/living/carbon/human/speaker = cast[cue[3]]
		var/text = cue[4]
		if(!length(text))
			continue
		if(speaker && speaker.alpha)
			speaker.say(text, language = /datum/language/common, forced = "pony.mov")
		subtitle.maptext = MAPTEXT("<div align='center'><span style='color:#ffffff;-dm-text-outline:1px #000000'>[html_encode(text)]</span></div>")
		INVOKE_ASYNC(src, PROC_REF(clear_cue), text, cue[2])

/datum/ponymov/proc/clear_cue(text, ends)
	PONYMOV_AT(ends)
	if(findtext(subtitle.maptext, html_encode(text)))
		subtitle.maptext = null

/**
 * One line of the screenplay, list(seconds, verb, args...). The verbs:
 *
 * * "cut", set, [x, y]: the camera's put on the set (on its middle, or this spot), zoomed out.
 * * "zoom", scale, [part], [seconds]: zooms in (or back out, at 1), held on one of the cast if given,
 *   who it then follows about. A close-up.
 * * "pan", x, y, seconds: the camera glides to there in its set.
 * * "black", seconds: the view goes black for that long.
 * * "card", text, [seconds]: big words on black, for that long (or until the next card, with none).
 * * "place", part, set, x, y, [dir]: puts one of the cast somewhere and shows them.
 * * "walk", part, x, y, seconds: they walk there in their set, x first.
 * * "carry", part, under: they ride on top of another of the cast, who'll take them along.
 *   "drop", under lets them down.
 * * "face", part, dir / "lie", part / "stand", part / "hide", part / "emote", part, emote
 * * "prop", name, type, set, x, y: brings something on. "unprop", name takes it off again.
 * * "vignette", on: the flashback's white edge, in or out.
 * * "tint", colour, seconds: the colour of everything, fading to it. Null to go back.
 * * "beat", name: anything else, the episode's beat_<name>() proc.
 */
/datum/ponymov/proc/run_line(list/line)
	var/action = line[2]
	switch(action)
		if("cut")
			// Held far enough in that a 19 by 15 view doesn't see past the set.
			var/x = clamp(length(line) >= 5 ? line[4] : 11, 10, PONYMOV_SET_WIDTH - 9)
			var/y = clamp(length(line) >= 5 ? line[5] : 9, 8, PONYMOV_SET_HEIGHT - 7)
			camera.forceMove(set_turf(line[3], x, y))
			victim.reset_perspective(camera)
			if(zoomed != 1)
				zoom(1, 0)
		if("zoom")
			var/mob/living/carbon/human/subject = length(line) >= 4 ? cast[line[4]] : null
			if(subject)
				victim.reset_perspective(subject)
			zoom(line[3], length(line) >= 5 ? line[5] : 0.5)
		if("pan")
			victim.reset_perspective(camera)
			INVOKE_ASYNC(src, PROC_REF(walk_to_spot), camera, line[3], line[4], line[5])
		if("card")
			show_card(line[3], length(line) >= 4 ? line[4] : null)
		if("black")
			blackout.alpha = 255
			animate(blackout, alpha = 255, time = line[3] * 10)
			animate(alpha = 0, time = 0)
		if("place")
			var/mob/living/carbon/human/actor = cast[line[3]]
			actor.forceMove(set_turf(line[4], line[5], line[6]))
			actor.setDir(length(line) >= 7 ? line[7] : SOUTH)
			actor.alpha = 255
		if("walk")
			INVOKE_ASYNC(src, PROC_REF(walk_to_spot), cast[line[3]], line[4], line[5], line[6])
		if("carry")
			var/mob/living/carbon/human/rider = cast[line[3]]
			var/mob/living/carbon/human/carrier = cast[line[4]]
			rider.forceMove(carrier.loc)
			rider.pixel_z = carrier.pixel_z + 10
			rider.layer = carrier.layer + 0.01
			riders[carrier] = rider
			RegisterSignal(carrier, COMSIG_MOVABLE_MOVED, PROC_REF(take_rider), override = TRUE)
		if("drop")
			drop_rider(cast[line[3]])
		if("face")
			var/mob/living/carbon/human/actor = cast[line[3]]
			actor.setDir(line[4])
		if("lie")
			var/mob/living/carbon/human/actor = cast[line[3]]
			actor.set_body_position(LYING_DOWN)
		if("stand")
			var/mob/living/carbon/human/actor = cast[line[3]]
			actor.set_body_position(STANDING_UP)
		if("hide")
			var/mob/living/carbon/human/actor = cast[line[3]]
			actor.alpha = 0
		if("emote")
			var/mob/living/carbon/human/actor = cast[line[3]]
			actor.emote(line[4], forced = TRUE)
		if("prop")
			var/prop_type = line[4]
			props[line[3]] = new prop_type(set_turf(line[5], line[6], line[7]))
		if("unprop")
			var/atom/movable/prop = props[line[3]]
			props -= line[3]
			qdel(prop)
		if("vignette")
			animate(vignette, alpha = line[3] ? 255 : 0, time = 0.5 SECONDS)
		if("tint")
			animate(victim.client, color = line[3], time = (length(line) >= 4 ? line[4] : 0) * 10)
		if("beat")
			call(src, "beat_[line[3]]")()
		else
			stack_trace("pony.mov: [episode]'s screenplay has an unknown verb, [action].")

/datum/ponymov/proc/show_card(text, seconds)
	blackout.alpha = 255
	card.maptext = MAPTEXT("<div align='center'><span style='font-size:36px;color:#c01818;-dm-text-outline:2px #300000'>[text]</span></div>")
	card.alpha = 0
	animate(card, alpha = 255, time = 0.5 SECONDS)
	if(seconds)
		addtimer(CALLBACK(src, PROC_REF(hide_card)), seconds * 10)

/datum/ponymov/proc/hide_card()
	card.maptext = null
	blackout.alpha = 0

/// Walks one of the cast (or the camera) to x, y in their set: along first, then up or down, gliding.
/datum/ponymov/proc/walk_to_spot(atom/movable/actor, x, y, seconds)
	var/list/at = where(actor)
	var/steps = abs(x - at[2]) + abs(y - at[3])
	if(!steps)
		return
	var/delay = seconds * 10 / steps
	actor.set_glide_size(DELAY_TO_GLIDE_SIZE(delay))
	var/turf/target = set_turf(at[1], x, y)
	while(!QDELETED(src) && !QDELETED(actor) && get_turf(actor) != target)
		var/dir = (actor.x != target.x) ? get_dir(actor, locate(target.x, actor.y, actor.z)) : get_dir(actor, target)
		actor.Move(get_step(actor, dir), dir)
		actor.setDir(dir)
		sleep(delay)

/// Whoever's riding a carrier goes where they go.
/datum/ponymov/proc/take_rider(mob/living/carbon/human/carrier)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/rider = riders[carrier]
	if(QDELETED(rider))
		return
	rider.set_glide_size(carrier.glide_size)
	rider.forceMove(carrier.loc)
	rider.setDir(carrier.dir)

/// Lets one of the cast down off whoever's carrying them.
/datum/ponymov/proc/drop_rider(mob/living/carbon/human/carrier)
	var/mob/living/carbon/human/rider = riders[carrier]
	riders -= carrier
	UnregisterSignal(carrier, COMSIG_MOVABLE_MOVED)
	if(rider)
		rider.pixel_z = rider.base_pixel_z
		rider.layer = initial(rider.layer)

/// The end: back where they came from, alive or not as the episode leaves them (see victim_fate()).
/datum/ponymov/proc/finish()
	animate(blackout, alpha = 255, time = 1 SECONDS)
	sleep(1 SECONDS)
	qdel(src)

/// What's done to the victim on their way out. Their part may not have ended well.
/datum/ponymov/proc/victim_fate()
	return

/datum/ponymov/proc/on_lost(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/ponymov/Destroy()
	if(victim)
		UnregisterSignal(victim, list(COMSIG_QDELETING, COMSIG_MOB_LOGOUT))
		victim.client?.screen -= list(blackout, card, vignette, subtitle)
		if(victim.client)
			victim.client.color = null
			victim.stop_sound_channel(CHANNEL_ADMIN)
		if(zoomed != 1)
			zoom(1, 0)
		if(old_hud_version)
			victim.hud_used?.show_hud(old_hud_version)
		victim.reset_perspective()
		victim.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED, TRAIT_GODMODE), PONYMOV_TRAIT)
		victim.buckled?.unbuckle_mob(victim, force = TRUE)
		victim.uncuff()
		victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
		victim.alpha = 255
		victim.transform = null
		victim.pixel_w = victim.base_pixel_w
		victim.pixel_z = victim.base_pixel_z
		victim.density = initial(victim.density)
		victim.ponymov = null
		cast -= role
		victim.forceMove(came_from || get_safe_random_station_turf())
		victim_fate()
		victim = null
	riders.Cut()
	QDEL_LIST_ASSOC_VAL(cast)
	QDEL_LIST_ASSOC_VAL(props)
	QDEL_NULL(camera)
	QDEL_NULL(blackout)
	QDEL_NULL(card)
	QDEL_NULL(vignette)
	QDEL_NULL(subtitle)
	// Nobody's left behind when the sets go, living or not.
	if(stage)
		for(var/turf/spot as anything in stage.reserved_turfs)
			for(var/mob/left in spot)
				left.forceMove(came_from || get_safe_random_station_turf())
	QDEL_NULL(stage)
	return ..()

/// Reads SubRip subtitles into list(start, end, speaker, text) by cue, times in seconds. A cue's
/// speaker is whatever's before a colon at its start ("rainbow: ..."), matched to the cast's parts.
/proc/ponymov_read_srt(text)
	. = list()
	var/regex/timing = new(@"(\d+):(\d+):(\d+)[,.](\d+)\s*-->\s*(\d+):(\d+):(\d+)[,.](\d+)")
	for(var/block in splittext(replacetext(text, ascii2text(13), ""), "\n\n"))
		var/list/lines = splittext(trim(block), "\n")
		var/timing_line = 0
		for(var/i in 1 to length(lines))
			if(timing.Find(lines[i]))
				timing_line = i
				break
		if(!timing_line || timing_line == length(lines))
			continue
		var/start = text2num(timing.group[1]) * 3600 + text2num(timing.group[2]) * 60 + text2num(timing.group[3]) + text2num(timing.group[4]) / 1000
		var/ends = text2num(timing.group[5]) * 3600 + text2num(timing.group[6]) * 60 + text2num(timing.group[7]) + text2num(timing.group[8]) / 1000
		var/said = jointext(lines.Copy(timing_line + 1), " ")
		var/speaker
		var/colon = findtext(said, ":")
		if(colon && colon < 16)
			speaker = LOWER_TEXT(trim(copytext(said, 1, colon)))
			said = trim(copytext(said, colon + 1))
		. += list(list(start, ends, speaker, said))
