/**
 * What the rig does with its pieces.
 *
 * A pose is a list of part id -> joint angles:
 * - arms and legs: "raise" (out to the side) and "swing" (forward and back)
 * - head: "nod" (down is positive) and "tilt" (toward the mob's right)
 * - torso: "bend" (forward) and "lean" (toward the mob's right), plus "breath" (0.03 = 3% taller)
 * - any part: "dx" and "dy" in pixels
 *
 * Angles are in 3D terms, and pose_matrix() works out how they look from the way the mob is
 * facing: a raised arm points out sideways from the front and barely moves side-on, a swung
 * arm does the opposite and foreshortens from the front. So one pose works for all four
 * directions, and turning mid-animation still looks right.
 *
 * A sequence is a list of keyframes, each list(pose, time in deciseconds).
 */

/// Joint positions per part and direction, in BYOND pixel coordinates (from the bottom left).
/// Arms swing at the shoulder, legs at the hip, the head at the neck, the torso at the hips.
/proc/get_rig_joint(part_id, facing)
	switch(part_id)
		if(RIG_HEAD)
			return (facing & (NORTH|SOUTH)) ? list(16, 23) : list(16, 22)
		if(RIG_CHEST)
			return list(16, 11)
		if(RIG_L_ARM)
			switch(facing)
				if(NORTH)
					return list(11, 21)
				if(SOUTH)
					return list(21, 21)
				if(EAST)
					return list(17, 20)
				else
					return list(19, 20)
		if(RIG_R_ARM)
			switch(facing)
				if(NORTH)
					return list(21, 21)
				if(SOUTH)
					return list(11, 21)
				if(EAST)
					return list(14, 20)
				else
					return list(16, 20)
		if(RIG_L_LEG)
			switch(facing)
				if(NORTH)
					return list(14, 10)
				if(SOUTH)
					return list(18, 10)
				else
					return list(16, 10)
		if(RIG_R_LEG)
			switch(facing)
				if(NORTH)
					return list(18, 10)
				if(SOUTH)
					return list(14, 10)
				else
					return list(17, 10)
	return list(16, 16)

/// The transform that puts one part in the given pose, seen from the given direction.
/proc/rig_pose_matrix(part_id, list/entry, facing)
	var/matrix/pose = matrix()
	if(!length(entry))
		return pose
	var/front = (facing == NORTH || facing == SOUTH)
	var/angle = 0
	var/scale_y = 1
	var/dy = entry["dy"] || 0
	switch(part_id)
		if(RIG_L_ARM, RIG_R_ARM, RIG_L_LEG, RIG_R_LEG)
			var/raise = entry["raise"] || 0
			var/swing = entry["swing"] || 0
			if(front)
				// From the front, the mob's right side is on the left of the screen. From behind it flips.
				var/right = (part_id == RIG_R_ARM || part_id == RIG_R_LEG)
				angle = (right == (facing == SOUTH)) ? raise : -raise
				// Swinging toward or away from the viewer just shortens the limb. Past 90
				// degrees the scale goes negative and the limb flips up over the joint.
				scale_y = cos(swing)
			else
				angle = facing == EAST ? -swing : swing
				scale_y = cos(raise)
		if(RIG_HEAD)
			var/nod = entry["nod"] || 0
			var/tilt = entry["tilt"] || 0
			if(front)
				angle = facing == SOUTH ? -tilt : tilt
				dy -= nod / 15
			else
				angle = facing == EAST ? nod : -nod
		if(RIG_CHEST)
			var/bend = entry["bend"] || 0
			var/lean = entry["lean"] || 0
			if(front)
				angle = facing == SOUTH ? -lean : lean
				scale_y = cos(bend)
			else
				angle = facing == EAST ? bend : -bend
			scale_y *= 1 + (entry["breath"] || 0)
	var/list/joint = get_rig_joint(part_id, facing)
	// Rotate and scale around the joint, not the middle of the sprite.
	pose.Translate(16.5 - joint[1], 16.5 - joint[2])
	pose.Scale(1, scale_y)
	pose.Turn(angle)
	pose.Translate(joint[1] - 16.5, joint[2] - 16.5)
	pose.Translate(entry["dx"] || 0, dy)
	return pose

/// Every moving piece mapped to the pose entry that drives it. Held items move with their arm.
/datum/limb_rig/proc/get_pose_targets(list/pose)
	. = list()
	.[pivot] = pose ? pose[RIG_CHEST] : null
	.[parts[RIG_HEAD]] = pose ? pose[RIG_HEAD] : null
	.[parts[RIG_L_ARM]] = pose ? pose[RIG_L_ARM] : null
	.[parts[RIG_R_ARM]] = pose ? pose[RIG_R_ARM] : null
	.[item_parts["l"]] = pose ? pose[RIG_L_ARM] : null
	.[item_parts["r"]] = pose ? pose[RIG_R_ARM] : null
	.[finger_parts["l"]] = pose ? pose[RIG_L_ARM] : null
	.[finger_parts["r"]] = pose ? pose[RIG_R_ARM] : null
	.[parts[RIG_L_LEG]] = pose ? pose[RIG_L_LEG] : null
	.[parts[RIG_R_LEG]] = pose ? pose[RIG_R_LEG] : null

/// Puts every piece in a pose immediately.
/datum/limb_rig/proc/snap_to(list/pose)
	var/facing = owner.dir
	var/list/targets = get_pose_targets(pose)
	for(var/obj/effect/abstract/limb_rig_part/part as anything in targets)
		animate(part, transform = rig_pose_matrix(part.part_id, targets[part], facing), time = 0)

/**
 * Animates every piece through a sequence of keyframes.
 *
 * * keyframes - list of list(pose, deciseconds)
 * * loop - how many times to play it, -1 for forever
 * * activity - what the rig is doing while this plays
 * * settle_after - go back to idle once the sequence has played through (ignored when looping)
 */
/datum/limb_rig/proc/play(list/keyframes, loop = 1, activity = RIG_ACTIVITY_ONESHOT, settle_after = TRUE)
	src.activity = activity
	deltimer(settle_timer)
	settle_timer = null
	var/facing = owner.dir
	var/total_time = 0
	for(var/list/keyframe as anything in keyframes)
		total_time += keyframe[2]
	var/list/last_keyframe = keyframes[length(keyframes)]
	held_pose = last_keyframe[1]
	var/list/targets_per_keyframe = list()
	for(var/list/keyframe as anything in keyframes)
		targets_per_keyframe += list(get_pose_targets(keyframe[1]))
	for(var/obj/effect/abstract/limb_rig_part/part as anything in targets_per_keyframe[1])
		var/first = TRUE
		for(var/i in 1 to length(keyframes))
			var/list/keyframe = keyframes[i]
			var/list/targets = targets_per_keyframe[i]
			var/matrix/target = rig_pose_matrix(part.part_id, targets[part], facing)
			if(first)
				animate(part, transform = target, time = keyframe[2], loop = loop, easing = SINE_EASING)
				first = FALSE
			else
				animate(transform = target, time = keyframe[2], easing = SINE_EASING)
	if(settle_after && loop == 1)
		settle_timer = addtimer(CALLBACK(src, PROC_REF(settle)), total_time, TIMER_STOPPABLE|TIMER_DELETE_ME)

/// Goes back to the right background loop: working a tool, or just breathing.
/datum/limb_rig/proc/settle()
	deltimer(settle_timer)
	settle_timer = null
	if(QDELETED(owner))
		return
	if(working && owner.stat == CONSCIOUS)
		play_work()
		return
	var/deep = owner.stat != CONSCIOUS
	var/list/inhale = list(RIG_CHEST = list("breath" = deep ? 0.05 : 0.035), RIG_HEAD = list("nod" = deep ? 4 : 0))
	var/list/exhale = list(RIG_HEAD = list("nod" = deep ? 4 : 0))
	play(list(
		list(inhale, deep ? 22 : 15),
		list(exhale, deep ? 28 : 20),
	), loop = -1, activity = RIG_ACTIVITY_IDLE)
	held_pose = exhale

/// How long one step takes, in deciseconds, from how fast the mob glides between tiles.
/datum/limb_rig/proc/get_step_time()
	var/ticks = world.icon_size / max(owner.glide_size, 1)
	return clamp(ticks * world.tick_lag, 1, 8)

/// One step of walking, or one pull of crawling when lying down.
/datum/limb_rig/proc/play_step()
	if(activity == RIG_ACTIVITY_ONESHOT)
		return // Let an emote or a swing finish; the next step catches up.
	left_foot_forward = !left_foot_forward
	var/step_time = get_step_time()
	var/lead = left_foot_forward ? 1 : -1
	var/list/stride
	var/list/passing
	if(owner.body_position == LYING_DOWN)
		// Crawling: one arm reaches past the head and drags, the legs kick a little.
		stride = list(
			RIG_L_ARM = list("raise" = lead > 0 ? 165 : 70),
			RIG_R_ARM = list("raise" = lead > 0 ? 70 : 165),
			RIG_L_LEG = list("raise" = 12 * lead),
			RIG_R_LEG = list("raise" = -12 * lead),
			RIG_HEAD = list("nod" = -10),
		)
		passing = list(
			RIG_L_ARM = list("raise" = 110),
			RIG_R_ARM = list("raise" = 110),
			RIG_HEAD = list("nod" = -6),
			RIG_CHEST = list("dx" = 1),
		)
	else
		stride = list(
			RIG_L_LEG = list("swing" = 26 * lead),
			RIG_R_LEG = list("swing" = -26 * lead),
			RIG_L_ARM = list("swing" = -22 * lead, "raise" = 4),
			RIG_R_ARM = list("swing" = 22 * lead, "raise" = 4),
			RIG_CHEST = list("bend" = 3, "lean" = 2 * lead),
			RIG_HEAD = list("tilt" = -2 * lead),
		)
		passing = list(
			RIG_CHEST = list("dy" = 1, "bend" = 2),
			RIG_L_ARM = list("raise" = 4),
			RIG_R_ARM = list("raise" = 4),
		)
	play(list(
		list(stride, step_time * 0.5),
		list(passing, step_time * 0.5),
	), activity = RIG_ACTIVITY_MOVING, settle_after = FALSE)
	// Stand still again if no step follows.
	settle_timer = addtimer(CALLBACK(src, PROC_REF(settle)), step_time + 1, TIMER_STOPPABLE|TIMER_DELETE_ME)

/// The working hand saws away until the progress bar is done.
/datum/limb_rig/proc/play_work()
	var/arm = IS_RIGHT_INDEX(owner.active_hand_index) ? RIG_R_ARM : RIG_L_ARM
	var/list/push = list(RIG_HEAD = list("nod" = 14), RIG_CHEST = list("bend" = 6))
	push[arm] = list("swing" = 58, "raise" = 12)
	var/list/pull = list(RIG_HEAD = list("nod" = 12), RIG_CHEST = list("bend" = 5))
	pull[arm] = list("swing" = 28, "raise" = 6)
	play(list(list(push, 3), list(pull, 3)), loop = -1, activity = RIG_ACTIVITY_WORKING)

/// A quick swing of the active arm, for hitting things.
/datum/limb_rig/proc/play_attack()
	var/arm = IS_RIGHT_INDEX(owner.active_hand_index) ? RIG_R_ARM : RIG_L_ARM
	var/list/wind_up = list(RIG_CHEST = list("bend" = -6))
	wind_up[arm] = list("swing" = 110, "raise" = 15)
	var/list/follow_through = list(RIG_CHEST = list("bend" = 10))
	follow_through[arm] = list("swing" = 40, "raise" = 10)
	play(list(list(wind_up, 1), list(follow_through, 1), list(null, 2.5)))

/// Acts out an emote, if there's an animation for it.
/datum/limb_rig/proc/play_emote(emote_key)
	var/list/keyframes = get_rig_emote(emote_key)
	if(keyframes)
		play(keyframes)

/// The keyframes for an emote, or null if it doesn't move anything.
/proc/get_rig_emote(emote_key)
	switch(emote_key)
		if("wave")
			var/list/up = list(RIG_R_ARM = list("raise" = 150), RIG_HEAD = list("tilt" = 6))
			var/list/over = list(RIG_R_ARM = list("raise" = 175), RIG_HEAD = list("tilt" = 6))
			return list(list(up, 2), list(over, 1.5), list(up, 1.5), list(over, 1.5), list(up, 1.5), list(null, 2))
		if("clap")
			var/list/apart = list(RIG_L_ARM = list("swing" = 70, "raise" = -8), RIG_R_ARM = list("swing" = 70, "raise" = -8))
			var/list/together = list(RIG_L_ARM = list("swing" = 70, "raise" = -28), RIG_R_ARM = list("swing" = 70, "raise" = -28))
			return list(list(apart, 1.5), list(together, 1), list(apart, 1), list(together, 1), list(apart, 1), list(together, 1), list(null, 2))
		if("shrug")
			var/list/shrug = list(RIG_L_ARM = list("raise" = 35, "swing" = 35), RIG_R_ARM = list("raise" = 35, "swing" = 35), RIG_HEAD = list("tilt" = 12), RIG_CHEST = list("dy" = 1))
			return list(list(shrug, 2), list(shrug, 6), list(null, 3))
		if("nod")
			var/list/down = list(RIG_HEAD = list("nod" = 22))
			return list(list(down, 1.5), list(null, 1.5), list(down, 1.5), list(null, 1.5))
		if("shake")
			var/list/left = list(RIG_HEAD = list("tilt" = -14))
			var/list/right = list(RIG_HEAD = list("tilt" = 14))
			return list(list(left, 1), list(right, 1.5), list(left, 1.5), list(right, 1.5), list(null, 1))
		if("point")
			var/list/point = list(RIG_R_ARM = list("swing" = 90, "raise" = 20), RIG_HEAD = list("nod" = -4))
			return list(list(point, 1.5), list(point, 12), list(null, 3))
		if("salute")
			var/list/salute = list(RIG_R_ARM = list("raise" = 140, "swing" = 40), RIG_CHEST = list("dy" = 1))
			return list(list(salute, 2), list(salute, 10), list(null, 3))
		if("bow", "curtsy")
			var/list/bow = list(RIG_CHEST = list("bend" = 45), RIG_HEAD = list("nod" = 20), RIG_L_ARM = list("swing" = 20), RIG_R_ARM = list("swing" = 20))
			return list(list(bow, 4), list(bow, 6), list(null, 5))
		if("laugh", "giggle", "chuckle", "cackle", "snicker")
			var/list/up = list(RIG_CHEST = list("bend" = -8, "dy" = 1), RIG_HEAD = list("nod" = -18))
			var/list/down = list(RIG_CHEST = list("bend" = 6), RIG_HEAD = list("nod" = -8))
			return list(list(up, 1.5), list(down, 1.5), list(up, 1.5), list(down, 1.5), list(up, 1.5), list(null, 2.5))
		if("cry", "sob", "whimper", "sniff")
			var/list/cry = list(RIG_HEAD = list("nod" = 28), RIG_L_ARM = list("swing" = 140, "raise" = -25), RIG_R_ARM = list("swing" = 140, "raise" = -25), RIG_CHEST = list("bend" = 12))
			var/list/heave = list(RIG_HEAD = list("nod" = 32), RIG_L_ARM = list("swing" = 140, "raise" = -25), RIG_R_ARM = list("swing" = 140, "raise" = -25), RIG_CHEST = list("bend" = 18, "dy" = -1))
			return list(list(cry, 3), list(heave, 2), list(cry, 2), list(heave, 2), list(cry, 2), list(null, 4))
		if("scream", "screech", "shriek")
			var/list/scream = list(RIG_L_ARM = list("raise" = 165), RIG_R_ARM = list("raise" = 165), RIG_HEAD = list("nod" = -25), RIG_CHEST = list("bend" = -10))
			return list(list(scream, 1.5), list(scream, 8), list(null, 4))
		if("jump")
			var/list/crouch = list(RIG_L_LEG = list("swing" = 30), RIG_R_LEG = list("swing" = 30), RIG_CHEST = list("dy" = -2, "bend" = 10), RIG_L_ARM = list("swing" = -30), RIG_R_ARM = list("swing" = -30))
			var/list/air = list(RIG_L_ARM = list("raise" = 60), RIG_R_ARM = list("raise" = 60), RIG_L_LEG = list("swing" = -10), RIG_R_LEG = list("swing" = -10))
			return list(list(crouch, 1.5), list(air, 1.5), list(crouch, 1.5), list(null, 2))
		if("dance")
			. = list()
			for(var/move in 1 to 10)
				. += list(list(list(
					RIG_L_ARM = list("raise" = rand(-20, 175), "swing" = rand(-40, 90)),
					RIG_R_ARM = list("raise" = rand(-20, 175), "swing" = rand(-40, 90)),
					RIG_L_LEG = list("raise" = rand(-10, 35), "swing" = rand(-30, 40)),
					RIG_R_LEG = list("raise" = rand(-10, 35), "swing" = rand(-30, 40)),
					RIG_CHEST = list("bend" = rand(-15, 20), "lean" = rand(-15, 15), "dy" = rand(0, 2)),
					RIG_HEAD = list("nod" = rand(-25, 25), "tilt" = rand(-20, 20)),
				), 2.5))
			. += list(list(null, 3))
			return .
		if("wiggle")
			var/list/a = list(RIG_L_ARM = list("swing" = 45, "raise" = -6), RIG_R_ARM = list("swing" = 45, "raise" = -6))
			var/list/b = list(RIG_L_ARM = list("swing" = 50, "raise" = 4), RIG_R_ARM = list("swing" = 50, "raise" = 4))
			return list(list(a, 1.5), list(b, 1), list(a, 1), list(b, 1), list(a, 1), list(b, 1), list(null, 2))
		if("crack")
			var/list/crack = list(RIG_L_ARM = list("swing" = 85, "raise" = -30), RIG_R_ARM = list("swing" = 85, "raise" = -30), RIG_CHEST = list("bend" = 5))
			var/list/pop = list(RIG_L_ARM = list("swing" = 90, "raise" = -34), RIG_R_ARM = list("swing" = 90, "raise" = -34), RIG_CHEST = list("bend" = 7))
			return list(list(crack, 2), list(pop, 0.5), list(crack, 0.5), list(pop, 0.5), list(null, 2))
		if("snap")
			var/list/snap = list(RIG_R_ARM = list("raise" = 70, "swing" = 60))
			var/list/flick = list(RIG_R_ARM = list("raise" = 80, "swing" = 70))
			return list(list(snap, 1.5), list(flick, 0.5), list(null, 2))
		if("facepalm")
			var/list/palm = list(RIG_R_ARM = list("swing" = 150, "raise" = -20), RIG_HEAD = list("nod" = 16))
			return list(list(palm, 1.5), list(palm, 8), list(null, 3))
		if("stretch", "yawn")
			var/list/stretch = list(RIG_L_ARM = list("raise" = 170), RIG_R_ARM = list("raise" = 170), RIG_CHEST = list("bend" = -10, "breath" = 0.05), RIG_HEAD = list("nod" = -20))
			return list(list(stretch, 4), list(stretch, 5), list(null, 4))
		if("sigh")
			var/list/sigh = list(RIG_CHEST = list("dy" = -1, "bend" = 6), RIG_HEAD = list("nod" = 18), RIG_L_ARM = list("swing" = -6), RIG_R_ARM = list("swing" = -6))
			return list(list(sigh, 5), list(null, 5))
		if("cough", "sneeze")
			var/list/hack = list(RIG_CHEST = list("bend" = 18), RIG_HEAD = list("nod" = 25), RIG_R_ARM = list("swing" = 120, "raise" = -15))
			return list(list(hack, 1), list(null, 1.5), list(hack, 1), list(null, 2))
		if("shiver", "tremble", "twitch", "twitch_s", "shudder")
			. = list()
			for(var/shake in 1 to 8)
				. += list(list(list(
					RIG_CHEST = list("lean" = rand(-6, 6)),
					RIG_HEAD = list("tilt" = rand(-8, 8)),
					RIG_L_ARM = list("raise" = rand(-8, 10)),
					RIG_R_ARM = list("raise" = rand(-8, 10)),
				), 0.6))
			. += list(list(null, 1.5))
			return .
		if("flap", "aflap")
			var/list/up = list(RIG_L_ARM = list("raise" = 120), RIG_R_ARM = list("raise" = 120))
			var/list/down = list(RIG_L_ARM = list("raise" = 30), RIG_R_ARM = list("raise" = 30))
			return list(list(up, 1), list(down, 1), list(up, 1), list(down, 1), list(null, 1.5))
		if("hug")
			var/list/hug = list(RIG_L_ARM = list("swing" = 80, "raise" = -40), RIG_R_ARM = list("swing" = 80, "raise" = -40), RIG_CHEST = list("bend" = 8))
			return list(list(hug, 2), list(hug, 6), list(null, 3))
		if("dab")
			var/list/dab = list(RIG_L_ARM = list("raise" = 150), RIG_R_ARM = list("raise" = 115, "swing" = 70), RIG_HEAD = list("nod" = 30, "tilt" = 20))
			return list(list(dab, 1), list(dab, 8), list(null, 3))
		if("glare", "frown", "grumble", "huff")
			var/list/glare = list(RIG_HEAD = list("nod" = 10), RIG_CHEST = list("bend" = 4))
			return list(list(glare, 2), list(glare, 5), list(null, 3))
		if("gasp", "choke")
			var/list/gasp = list(RIG_HEAD = list("nod" = -18), RIG_CHEST = list("bend" = -6, "breath" = 0.06), RIG_R_ARM = list("swing" = 130, "raise" = -30))
			return list(list(gasp, 1), list(gasp, 5), list(null, 3))
		if("collapse", "faint")
			var/list/slump = list(RIG_CHEST = list("bend" = 25, "dy" = -2), RIG_HEAD = list("nod" = 30), RIG_L_ARM = list("raise" = 20), RIG_R_ARM = list("raise" = 20))
			return list(list(slump, 3), list(null, 3))
	return null
