/**
 * How singers move in a rhythm battle, after how Boyfriend moves in Friday Night Funkin':
 * - Between notes, they bop on every beat, dipping down and springing back up, mic bobbing.
 * - A note snaps them into its pose, overshooting and settling, and a long note makes them
 *   vibrate in it for as long as it's held.
 * - The mic stays in one hand, up at the mouth. Singing at the rival thrusts it at them.
 *
 * The two singers face each other, like in Funkin': the challenger on the right looks left, the
 * opponent looks right. So the arrow pointing at the rival means leaning in, and the one pointing
 * away means rearing back. Rigged mobs (Experiments, and anyone Overanimated) do all that with the
 * limb rig; anyone else gets a little bump.
 */

/// Mic up at the mouth.
#define FNF_MIC_UP list("swing" = 50, "raise" = 10, "hand_y" = 27)
/// The free hand balled into a fist at the side.
#define FNF_FIST list("swing" = 15, "raise" = 10, "elbow" = 75)

/// A deep copy of a pose, safe to change.
/proc/fnf_copy_pose(list/pose)
	. = list()
	for(var/part_id in pose)
		var/list/entry = pose[part_id]
		.[part_id] = entry.Copy()

/// A pose with every angle scaled, for overshooting into it. Hand heights stay put.
/proc/fnf_scale_pose(list/pose, factor)
	. = fnf_copy_pose(pose)
	for(var/part_id in .)
		var/list/entry = .[part_id]
		for(var/key in entry)
			if(key != "hand_y")
				entry[key] *= factor

/// A pose with one value nudged, for a held note's vibrato.
/proc/fnf_nudge_pose(list/pose, part_id, key, amount)
	. = fnf_copy_pose(pose)
	var/list/entry = .[part_id]
	if(!entry)
		entry = list()
		.[part_id] = entry
	entry[key] = (entry[key] || 0) + amount

/**
 * A battle pose.
 *
 * * kind - "rest", "bop", "hey", "miss", or a lane: 0 to 3 for left, down, up, right
 * * mic_arm - the arm with the mic in it, RIG_L_ARM or RIG_R_ARM
 * * facing - which way the singer faces, WEST or EAST, to tell which arrow points at the rival
 * * style - a character's own way of moving on top (see fnf_apply_style), or null
 */
/proc/fnf_pose(kind, mic_arm, facing, style)
	var/free_arm = mic_arm == RIG_L_ARM ? RIG_R_ARM : RIG_L_ARM
	if(isnum(kind) && (kind == 0 || kind == 3))
		kind = (kind == 0) == (facing == WEST) ? "toward" : "away"
	. = list()
	.[mic_arm] = FNF_MIC_UP
	.[free_arm] = FNF_FIST
	switch(kind)
		if("bop")
			// Dipped: knees bent, squashed down, head and mic bobbing with it.
			.[RIG_CHEST] = list("breath" = -0.035, "bend" = 8)
			.[RIG_HEAD] = list("nod" = 10)
			.[RIG_L_LEG] = list("swing" = 12, "knee" = 22)
			.[RIG_R_LEG] = list("swing" = 12, "knee" = 22)
			.[mic_arm] = list("swing" = 45, "raise" = 10, "hand_y" = 24)
			.[RIG_TAIL] = list("lift" = -8)
		if("toward")
			// Leaning in at the rival, mic thrust right in their face, a foot stepping in.
			.[RIG_CHEST] = list("bend" = 15)
			.[RIG_HEAD] = list("nod" = -6)
			.[mic_arm] = list("swing" = 90, "raise" = 5, "elbow" = 0)
			.[free_arm] = list("swing" = -25, "raise" = 10, "elbow" = 60)
			.[RIG_L_LEG] = list("swing" = 30, "knee" = 15)
			.[RIG_R_LEG] = list("swing" = -15)
			.[RIG_TAIL] = list("lift" = 25)
		if("away")
			// Rearing back, the free fist flung behind, mic still at the mouth.
			.[RIG_CHEST] = list("bend" = -14)
			.[RIG_HEAD] = list("nod" = -12)
			.[mic_arm] = list("swing" = 60, "raise" = 10, "hand_y" = 28)
			.[free_arm] = list("swing" = -70, "raise" = 15, "elbow" = 25)
			.[RIG_L_LEG] = list("swing" = -20, "knee" = 10)
			.[RIG_R_LEG] = list("swing" = 15)
			.[RIG_TAIL] = list("lift" = -15)
		if(1)
			// Down: a deep crouch, head down, mic thrust down at the floor.
			.[RIG_CHEST] = list("bend" = 28, "breath" = -0.05)
			.[RIG_HEAD] = list("nod" = 20)
			.[RIG_L_LEG] = list("swing" = 35, "knee" = 55)
			.[RIG_R_LEG] = list("swing" = 35, "knee" = 55)
			.[mic_arm] = list("swing" = 35, "raise" = 5, "elbow" = 0)
			.[free_arm] = list("swing" = -20, "raise" = 15, "elbow" = 50)
			.[RIG_TAIL] = list("lift" = -25)
		if(2)
			// Up: chin up, mic up high, up on the toes, fist in the air.
			.[RIG_CHEST] = list("bend" = -10, "breath" = 0.05, "air" = 3)
			.[RIG_HEAD] = list("nod" = -25)
			.[mic_arm] = list("swing" = 100, "raise" = 5, "hand_y" = 32)
			.[free_arm] = list("swing" = 150, "raise" = 10, "elbow" = 30)
			.[RIG_TAIL] = list("lift" = 35)
		if("miss")
			// Recoiling: leaning back, arms up in a flinch.
			.[RIG_CHEST] = list("bend" = -15, "breath" = -0.03)
			.[RIG_HEAD] = list("nod" = -15)
			.[mic_arm] = list("swing" = 60, "raise" = 15, "elbow" = 90)
			.[free_arm] = list("swing" = 70, "raise" = 15, "elbow" = 90)
			.[RIG_TAIL] = list("lift" = -30)
		if("hey")
			// Hey! Free arm thrown up, mic still at the mouth, up on the toes.
			.[free_arm] = list("swing" = 170, "raise" = 10, "elbow" = 10)
			.[RIG_CHEST] = list("air" = 4, "breath" = 0.04, "bend" = -6)
			.[RIG_HEAD] = list("nod" = -15)
			.[RIG_TAIL] = list("lift" = 35, "wag" = 20)
	if(style)
		fnf_apply_style(., kind, style, mic_arm, free_arm)

/// Which arm a singer has the mic in: the hand holding a battle microphone, or else the arm
/// nearer the crowd when facing that way.
/mob/living/proc/fnf_mic_arm(facing)
	for(var/obj/item/fnf_microphone/microphone in held_items)
		return IS_RIGHT_INDEX(get_held_index_of_item(microphone)) ? RIG_R_ARM : RIG_L_ARM
	return facing == WEST ? RIG_L_ARM : RIG_R_ARM

/// Snaps into an arrow's pose, holds it for hold deciseconds (vibrating if it's long), then goes back to the mic.
/mob/living/proc/fnf_sing(lane, hold, mic_arm, facing, style)
	setDir(facing)
	var/static/list/nudges = list(list(-3, 0), list(0, -3), list(0, 3), list(3, 0))
	var/list/nudge = nudges[lane + 1]
	fnf_nudge(nudge[1], nudge[2])

/mob/living/carbon/fnf_sing(lane, hold, mic_arm, facing, style)
	if(!limb_rig)
		return ..()
	setDir(facing)
	var/list/pose = fnf_pose(lane, mic_arm, facing, style)
	var/list/keyframes = list(
		list(fnf_scale_pose(pose, 1.2), 0.5, CUBIC_EASING|EASE_OUT),
		list(pose, 1, SINE_EASING),
	)
	// Held notes: a vibrato, mic and head working with the voice.
	var/held = hold - 1.5
	var/beat = 0
	while(held > 0.6)
		beat++
		var/amount = beat % 2 ? 4 : -4
		var/list/wobble = fnf_nudge_pose(pose, mic_arm, "swing", amount)
		wobble = fnf_nudge_pose(wobble, RIG_HEAD, "nod", amount * 0.6)
		keyframes += list(list(wobble, 0.6, SINE_EASING))
		held -= 0.6
	keyframes += list(list(fnf_pose("rest", mic_arm, facing, style), 2, SINE_EASING))
	limb_rig.play(keyframes, settle_after = FALSE)

/// The between-notes bop, one beat long.
/mob/living/proc/fnf_bop(beat_time, mic_arm, facing, style)
	fnf_nudge(0, -1)

/mob/living/carbon/fnf_bop(beat_time, mic_arm, facing, style)
	if(!limb_rig)
		return ..()
	limb_rig.play(list(
		list(fnf_pose("bop", mic_arm, facing, style), beat_time * 0.25, CUBIC_EASING|EASE_OUT),
		list(fnf_pose("rest", mic_arm, facing, style), beat_time * 0.75, SINE_EASING),
	), settle_after = FALSE)

/mob/living/proc/fnf_nudge(x_offset, z_offset)
	animate(src, pixel_w = x_offset, pixel_z = z_offset, time = 0.5, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_w = -x_offset, pixel_z = -z_offset, time = 2, easing = SINE_EASING)

/mob/living/proc/fnf_flash(colour, duration)
	add_atom_colour(colour, TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, colour), duration, TIMER_UNIQUE|TIMER_OVERRIDE)

/mob/living/proc/fnf_miss(mic_arm, facing, style)
	fnf_flash("#8a8aff", 3)
	fnf_nudge(0, -2)

/mob/living/carbon/fnf_miss(mic_arm, facing, style)
	if(!limb_rig)
		return ..()
	fnf_flash("#8a8aff", 3)
	// Recoil, shake it off, back to the mic.
	var/list/flinch = fnf_pose("miss", mic_arm, facing, style)
	limb_rig.play(list(
		list(fnf_scale_pose(flinch, 1.15), 0.5, CUBIC_EASING|EASE_OUT),
		list(fnf_nudge_pose(flinch, RIG_HEAD, "nod", 12), 0.7, SINE_EASING),
		list(flinch, 0.7, SINE_EASING),
		list(fnf_pose("rest", mic_arm, facing, style), 1.5, SINE_EASING),
	), settle_after = FALSE)

/mob/living/proc/fnf_hey(mic_arm, facing, style)
	fnf_nudge(0, 4)
	if(is_species(src, /datum/species/experiment))
		playsound(src, get_expie_exert_sound(), 40, TRUE)

/mob/living/carbon/fnf_hey(mic_arm, facing, style)
	. = ..()
	if(!limb_rig)
		return
	var/list/hey = fnf_pose("hey", mic_arm, facing, style)
	limb_rig.play(list(
		list(fnf_scale_pose(hey, 1.15), 0.6, BACK_EASING|EASE_OUT),
		list(hey, 5),
		list(fnf_pose("rest", mic_arm, facing, style), 2, SINE_EASING),
	), settle_after = FALSE)

/// Lost. Run off the health bar means going down in a heap.
/mob/living/proc/fnf_lose(knocked_out)
	fnf_flash("#6f6fff", 3 SECONDS)
	if(is_species(src, /datum/species/experiment))
		playsound(src, get_expie_pain_sound(), 50, TRUE)
	if(!knocked_out)
		return
	visible_message(span_danger("[src] got blue-balled!"))
	Knockdown(3 SECONDS)

/// Back to standing about normally once the battle's over.
/mob/living/proc/fnf_rest()
	return

/mob/living/carbon/fnf_rest()
	limb_rig?.settle()

/// Adds to one angle of a pose in place, making the entry if it isn't there.
/proc/fnf_pose_add(list/pose, part_id, key, amount)
	var/list/entry = pose[part_id]
	if(!entry)
		entry = list()
		pose[part_id] = entry
	entry[key] = (entry[key] || 0) + amount

/**
 * A summoned character's own way of moving, on top of the shared poses.
 *
 * * pose - the pose so far, changed in place
 * * kind - as for fnf_pose(), with the side arrows already turned into "toward" and "away"
 */
/proc/fnf_apply_style(list/pose, kind, style, mic_arm, free_arm)
	switch(style)
		if("pico", "tankman")
			// The gun's in the free hand, and goes where the note does: levelled at the rival, up at
			// the sky, down at the floor. Pico sings the rival note into the mic and lets the gun talk.
			switch(kind)
				if("rest", "bop", "miss")
					pose[free_arm] = list("swing" = 40, "raise" = 10, "elbow" = 45)
				if("toward")
					pose[free_arm] = list("swing" = 90, "raise" = 5, "elbow" = 0)
					pose[mic_arm] = FNF_MIC_UP
				if("away")
					pose[free_arm] = list("swing" = -35, "raise" = 25, "elbow" = 70)
				if(1)
					pose[free_arm] = list("swing" = 35, "raise" = 5, "elbow" = 0)
				if(2, "hey")
					pose[free_arm] = list("swing" = 175, "raise" = 5, "elbow" = 0)
			if(style == "tankman")
				// Parade-ground stiff: stands up straight whatever he's singing.
				var/list/chest = pose[RIG_CHEST]
				if(chest)
					chest["bend"] = (chest["bend"] || 0) * 0.4
				fnf_pose_add(pose, RIG_HEAD, "nod", -4)
		if("dad", "parents")
			// Rockstar: legs planted wide, headbanging, the mic thrown to the sky on the high notes.
			fnf_pose_add(pose, RIG_L_LEG, "raise", 10)
			fnf_pose_add(pose, RIG_R_LEG, "raise", 10)
			if(kind == "bop" || kind == 1)
				fnf_pose_add(pose, RIG_HEAD, "nod", 14)
				fnf_pose_add(pose, RIG_CHEST, "bend", 8)
			if(kind == 2)
				pose[mic_arm] = list("swing" = 160, "raise" = 10, "elbow" = 5)
		if("mom")
			// Swaying her hips into every note.
			fnf_pose_add(pose, RIG_CHEST, "lean", kind == "away" ? -8 : 8)
			fnf_pose_add(pose, RIG_HEAD, "tilt", kind == "away" ? 8 : -8)
			if(kind == "bop")
				fnf_pose_add(pose, RIG_CHEST, "bend", -4)
		if("spooky")
			// Hopping into everything, arms everywhere.
			fnf_pose_add(pose, RIG_CHEST, "air", 5)
			fnf_pose_add(pose, mic_arm, "raise", 30)
			fnf_pose_add(pose, free_arm, "raise", 45)
			fnf_pose_add(pose, RIG_L_LEG, "knee", 25)
		if("senpai")
			// Far too cool to move much.
			for(var/part_id in pose)
				var/list/entry = pose[part_id]
				for(var/key in entry)
					if(key != "hand_y")
						entry[key] *= 0.55
			fnf_pose_add(pose, RIG_HEAD, "tilt", 10)
		if("monster")
			// Hunched right over, head jerking about.
			fnf_pose_add(pose, RIG_CHEST, "bend", 16)
			fnf_pose_add(pose, RIG_HEAD, "nod", kind == 2 ? -20 : 12)
		if("darnell")
			// Laid back, leaning away, all swagger.
			fnf_pose_add(pose, RIG_CHEST, "bend", -8)
			fnf_pose_add(pose, RIG_HEAD, "nod", -6)
			fnf_pose_add(pose, RIG_L_LEG, "swing", 15)

#undef FNF_MIC_UP
#undef FNF_FIST
