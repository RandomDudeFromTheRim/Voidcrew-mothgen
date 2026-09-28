/**
 * How singers move in a rhythm battle. Rigged mobs (Experiments, and anyone Overanimated) strike
 * a pose per arrow, held for as long as the note; anyone else gets a little bump that way.
 *
 * Singers face the crowd (south), so pointing to the screen's left is the singer's right arm.
 */

/// Left, down, up and right, in limb rig pose terms (see limb_rig/animations.dm).
GLOBAL_LIST_INIT(fnf_sing_poses, list(
	// Left: the right arm flung out that way, leaning into it.
	list(
		RIG_R_ARM = list("raise" = 88, "elbow" = 5),
		RIG_L_ARM = list("raise" = 15, "swing" = 20, "elbow" = 55),
		RIG_CHEST = list("lean" = 9),
		RIG_HEAD = list("tilt" = 12),
		RIG_R_LEG = list("raise" = 12),
		RIG_TAIL = list("wag" = -25),
	),
	// Down: squatting low, head down, arms driven down.
	list(
		RIG_R_ARM = list("raise" = 30, "swing" = 15, "elbow" = 25),
		RIG_L_ARM = list("raise" = 30, "swing" = 15, "elbow" = 25),
		RIG_CHEST = list("bend" = 18, "breath" = -0.05),
		RIG_HEAD = list("nod" = 16),
		RIG_R_LEG = list("raise" = 10, "swing" = 25, "knee" = 40),
		RIG_L_LEG = list("raise" = 10, "swing" = 25, "knee" = 40),
		RIG_TAIL = list("lift" = -20),
	),
	// Up: reaching for the ceiling, chin up, up on the toes.
	list(
		RIG_R_ARM = list("raise" = 165, "elbow" = 5),
		RIG_L_ARM = list("raise" = 20, "swing" = 25, "elbow" = 45),
		RIG_CHEST = list("breath" = 0.05, "air" = 3, "lean" = -4),
		RIG_HEAD = list("nod" = -18),
		RIG_TAIL = list("lift" = 30),
	),
	// Right: the mirror of left.
	list(
		RIG_L_ARM = list("raise" = 88, "elbow" = 5),
		RIG_R_ARM = list("raise" = 15, "swing" = 20, "elbow" = 55),
		RIG_CHEST = list("lean" = -9),
		RIG_HEAD = list("tilt" = -12),
		RIG_L_LEG = list("raise" = 12),
		RIG_TAIL = list("wag" = 25),
	),
))

/// Flinching at a missed note, hands up by the face.
GLOBAL_LIST_INIT(fnf_miss_pose, list(
	RIG_R_ARM = list("raise" = 15, "swing" = 35, "elbow" = 95),
	RIG_L_ARM = list("raise" = 15, "swing" = 35, "elbow" = 95),
	RIG_CHEST = list("bend" = 14),
	RIG_HEAD = list("nod" = 22),
	RIG_TAIL = list("lift" = -30),
))

/// Hey! Both arms thrown up.
GLOBAL_LIST_INIT(fnf_hey_pose, list(
	RIG_R_ARM = list("raise" = 150, "elbow" = 20),
	RIG_L_ARM = list("raise" = 150, "elbow" = 20),
	RIG_CHEST = list("air" = 4, "breath" = 0.04),
	RIG_HEAD = list("nod" = -15),
	RIG_TAIL = list("lift" = 35, "wag" = 20),
))

/datum/limb_rig/proc/play_pose_for(list/pose, hold)
	play(list(
		list(pose, 0.6, CUBIC_EASING|EASE_OUT),
		list(pose, hold),
		list(null, 2.5),
	))

/// Strikes the pose for an arrow and holds it, in deciseconds.
/mob/living/proc/fnf_sing(lane, hold = 2)
	setDir(SOUTH)
	var/static/list/nudges = list(list(-3, 0), list(0, -3), list(0, 3), list(3, 0))
	var/list/nudge = nudges[lane + 1]
	fnf_nudge(nudge[1], nudge[2])

/mob/living/carbon/fnf_sing(lane, hold = 2)
	if(!limb_rig)
		return ..()
	setDir(SOUTH)
	limb_rig.play_pose_for(GLOB.fnf_sing_poses[lane + 1], hold)

/mob/living/proc/fnf_nudge(x_offset, z_offset)
	animate(src, pixel_w = x_offset, pixel_z = z_offset, time = 0.5, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_w = -x_offset, pixel_z = -z_offset, time = 2, easing = SINE_EASING)

/mob/living/proc/fnf_miss()
	add_atom_colour("#8a8aff", TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, "#8a8aff"), 3, TIMER_UNIQUE|TIMER_OVERRIDE)
	fnf_nudge(0, -2)

/mob/living/carbon/fnf_miss()
	if(!limb_rig)
		return ..()
	add_atom_colour("#8a8aff", TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, "#8a8aff"), 3, TIMER_UNIQUE|TIMER_OVERRIDE)
	limb_rig.play_pose_for(GLOB.fnf_miss_pose, 2)

/mob/living/proc/fnf_hey()
	fnf_nudge(0, 4)
	if(is_species(src, /datum/species/experiment))
		playsound(src, get_expie_exert_sound(), 40, TRUE)

/mob/living/carbon/fnf_hey()
	. = ..()
	limb_rig?.play_pose_for(GLOB.fnf_hey_pose, 6)

/// A little hop on each beat of the countdown.
/mob/living/proc/fnf_bounce()
	fnf_nudge(0, 2)

/// Lost. Run off the health bar means going down in a heap.
/mob/living/proc/fnf_lose(knocked_out)
	add_atom_colour("#6f6fff", TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, "#6f6fff"), 3 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	if(is_species(src, /datum/species/experiment))
		playsound(src, get_expie_pain_sound(), 50, TRUE)
	if(!knocked_out)
		return
	visible_message(span_danger("[src] got blue-balled!"))
	Knockdown(3 SECONDS)
