/// Everything a rhythm battle draws over the stage. It sits above the lighting, so a battle in
/// a dark corridor can still be played.
/obj/effect/abstract/fnf_hud
	name = ""
	icon = 'voidcrew/modules/fnf/icons/fnf.dmi'
	icon_state = null
	plane = ABOVE_LIGHTING_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = RESET_COLOR|RESET_TRANSFORM|RESET_ALPHA|PIXEL_SCALE|KEEP_APART
	vis_flags = VIS_INHERIT_PLANE

/obj/effect/abstract/fnf_hud/text
	maptext_width = 160
	maptext_height = 32
	maptext_x = -64

/**
 * The health bar, strung between the two singers: the opponent's colour from the left, the
 * challenger's from the right, meeting where the battle stands.
 */
/obj/effect/abstract/fnf_hud/healthbar
	/// Where the middle of the bar is, in pixels from this tile's bottom left.
	var/center_x = 16
	var/center_y = 16
	var/obj/effect/abstract/fnf_hud/frame
	var/obj/effect/abstract/fnf_hud/left_bar
	var/obj/effect/abstract/fnf_hud/right_bar
	/// The singers themselves, shrunk down, on either side of where the colours meet.
	var/obj/effect/abstract/fnf_portrait/left_portrait
	var/obj/effect/abstract/fnf_portrait/right_portrait
	/// Big text in the middle, for the countdown.
	var/obj/effect/abstract/fnf_hud/text/announcer

/obj/effect/abstract/fnf_hud/healthbar/Initialize(mapload, center_x, center_y, mob/living/left_mob, mob/living/right_mob)
	. = ..()
	src.center_x = center_x
	src.center_y = center_y
	frame = make_bar("#000000", FNF_BAR_WIDTH + 4, FNF_BAR_HEIGHT + 4, 0.01)
	left_bar = make_bar("#e0453a", FNF_BAR_WIDTH, FNF_BAR_HEIGHT, 0.02)
	right_bar = make_bar("#5de83a", FNF_BAR_WIDTH, FNF_BAR_HEIGHT, 0.03)
	announcer = new
	announcer.layer = ABOVE_ALL_MOB_LAYER + 0.05
	announcer.pixel_w = center_x - 16
	announcer.pixel_z = center_y + 8
	vis_contents += announcer
	if(left_mob)
		left_portrait = new(loc, left_mob)
	if(right_mob)
		right_portrait = new(loc, right_mob)
	update(FNF_HEALTH_MAX / 2, instant = TRUE)

/obj/effect/abstract/fnf_hud/healthbar/Destroy()
	vis_contents.Cut()
	QDEL_NULL(frame)
	QDEL_NULL(left_bar)
	QDEL_NULL(right_bar)
	QDEL_NULL(left_portrait)
	QDEL_NULL(right_portrait)
	QDEL_NULL(announcer)
	return ..()

/obj/effect/abstract/fnf_hud/healthbar/proc/make_bar(colour, width, height, layer_offset)
	var/obj/effect/abstract/fnf_hud/bar = new
	bar.icon_state = "bar"
	bar.color = colour
	bar.layer = ABOVE_ALL_MOB_LAYER + layer_offset
	bar.pixel_w = center_x - 16
	bar.pixel_z = center_y - 16
	bar.transform = matrix(width / 32, 0, 0, 0, height / 32, 0)
	vis_contents += bar
	return bar

/// Moves the split to match the health, which is how much of the bar is the challenger's.
/obj/effect/abstract/fnf_hud/healthbar/proc/update(health, instant = FALSE)
	var/width = max(FNF_BAR_WIDTH * health / FNF_HEALTH_MAX, 0.5)
	var/time = instant ? 0 : 1
	animate(right_bar, transform = matrix(width / 32, 0, (FNF_BAR_WIDTH - width) / 2, 0, FNF_BAR_HEIGHT / 32, 0), time = time)
	// Where the colours meet, from the bar's middle.
	var/split = FNF_BAR_WIDTH / 2 - width
	for(var/obj/effect/abstract/fnf_portrait/portrait as anything in list(left_portrait, right_portrait))
		if(!portrait)
			continue
		var/side_offset = portrait == left_portrait ? -11 : 11
		animate(portrait, pixel_w = center_x - 16 + split + side_offset, pixel_z = center_y - 14, time = time)
	// Whoever's losing badly goes pale.
	left_portrait?.color = health > 80 ? "#8888ff" : null
	right_portrait?.color = health < 20 ? "#8888ff" : null

/// Both portraits bob to the beat.
/obj/effect/abstract/fnf_hud/healthbar/proc/bop()
	for(var/obj/effect/abstract/fnf_portrait/portrait as anything in list(left_portrait, right_portrait))
		if(!portrait)
			continue
		animate(portrait, transform = matrix() * 0.62, time = 0)
		animate(transform = matrix() * 0.5, time = 2, easing = CUBIC_EASING|EASE_OUT)

/// Takes a singer's portrait down, when the singer is going away.
/obj/effect/abstract/fnf_hud/healthbar/proc/drop_portrait(mob/living/singer)
	if(left_portrait?.singer == singer)
		QDEL_NULL(left_portrait)
	if(right_portrait?.singer == singer)
		QDEL_NULL(right_portrait)

/obj/effect/abstract/fnf_hud/healthbar/proc/announce(text, colour = "#ffffff")
	announcer.maptext = MAPTEXT("<span style='text-align:center;font-size:12pt;color:[colour];-dm-text-outline:1px #000000'><b>[text]</b></span>")
	animate(announcer, alpha = 255, transform = matrix() * 1.4, time = 0)
	animate(transform = matrix(), time = 1.5, easing = BACK_EASING|EASE_OUT)
	animate(alpha = 0, time = 3, delay = 1)

/**
 * A singer shown shrunk beside the health bar: the singer itself, not a picture of it, so it
 * dances along. It shares the singer's plane so the whole body shrinks together, which also
 * means it's lit like the room.
 */
/obj/effect/abstract/fnf_portrait
	name = ""
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = KEEP_TOGETHER|PIXEL_SCALE
	var/mob/living/singer

/obj/effect/abstract/fnf_portrait/Initialize(mapload, mob/living/singer)
	. = ..()
	src.singer = singer
	transform = matrix() * 0.5
	vis_contents += singer

/obj/effect/abstract/fnf_portrait/Destroy()
	vis_contents.Cut()
	singer = null
	return ..()
