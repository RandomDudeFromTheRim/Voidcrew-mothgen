/**
 * Serverblight: an admin smite that gets into a ragdoll's physics and ruins it.
 *
 * Nothing here is animated. The body is made physical, then everything that keeps a ragdoll
 * looking like a body is turned against it: every joint's limits are swung round to bend the wrong
 * way and driven there by a motor, the arms grow on past the hand into long spinning chains ending
 * in fingers, a second pair of arms comes out of the ribs, the head is pinned to a foot and the
 * torso to a shin, and all of it collides with itself and with whatever walls and furniture stand
 * around the victim. The solver is starved of iterations, so it can never settle any of that: the
 * shaking is it failing to, every step.
 *
 * Turning limb physics off (the Limb Physics: Toggle admin verb) puts the body back.
 */
/datum/smite/serverblight
	name = "Serverblight"

/datum/smite/serverblight/effect(client/user, mob/living/target)
	. = ..()
	if(!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	if(!vcphys_available())
		to_chat(user, span_warning("The physics library (vcphys) isn't loaded. It goes next to the game, like rust_g."), confidential = TRUE)
		return
	var/mob/living/carbon/victim = target
	if(!victim.set_limb_physics(TRUE))
		to_chat(user, span_warning("[victim] has no sprite-built limb rig to corrupt."), confidential = TRUE)
		return
	if(!victim.limb_rig.physics.blight())
		to_chat(user, span_warning("[victim] is already blighted, or the physics library refused."), confidential = TRUE)
		return
	playsound(victim, 'sound/effects/wounds/crack2.ogg', 100, TRUE)
	to_chat(victim, span_userdanger("Something reaches into you and rewrites where your bones go."))
	victim.visible_message(span_danger("[victim]'s body folds the wrong way, and keeps folding."), ignored_mobs = victim)

/**
 * How far each joint is forced, in degrees relative to where it started: list(lower, upper).
 * Facing east, every band is on the side the joint can't go; mirrored facing west.
 */
/proc/serverblight_joint_band(joint, facing)
	var/static/list/bands = list(
		"neck" = list(140, 160),
		"shoulder" = list(160, 178),
		"elbow" = list(-170, -150),
		"hip" = list(-100, -80),
		"knee" = list(60, 80),
		"ankle" = list(140, 170),
	)
	var/list/band = bands[joint] || list(120, 150)
	if(facing == WEST)
		return list(-band[2], -band[1])
	return band.Copy()

/**
 * Blights the body. It must already be physical. Returns FALSE if it was already, or the library
 * wouldn't have it.
 */
/datum/limb_physics/proc/blight()
	if(blighted || !world_handle)
		return FALSE
	var/list/states = read_states()
	if(!states)
		return FALSE
	blighted = TRUE
	// Too few iterations to ever solve all of it: what's left over each step is the twitching.
	velocity_iterations = 4
	position_iterations = 2
	var/mirror = facing == WEST ? -1 : 1

	// Every segment collides with every other: a second, weightless box outside the ragdoll's group.
	for(var/part_id in body_by_part)
		var/list/segment = segments[part_id]
		var/list/origin = segment["origin"]
		var/list/end = segment["end"]
		var/length = max(sqrt((end[1] - origin[1]) ** 2 + (end[2] - origin[2]) ** 2), 2)
		vcphys_call("fixture_box", world_handle, body_by_part[part_id], segment["width"] / 2 / LIMB_PHYSICS_PPM, length / 2 / LIMB_PHYSICS_PPM, ((origin[1] + end[1]) / 2 - origin[1]) / LIMB_PHYSICS_PPM, ((origin[2] + end[2]) / 2 - origin[2]) / LIMB_PHYSICS_PPM, 0, 0, 0.7, 0.05, 0)

	// Every joint bent the way it doesn't go, and driven further.
	for(var/part_id in joint_by_part)
		var/list/band = serverblight_joint_band(segments[part_id]["joint"], facing)
		var/joint = joint_by_part[part_id]
		vcphys_call("joint_set_limits", world_handle, joint, TORADIANS(band[1]), TORADIANS(band[2]))
		vcphys_call("joint_set_motor", world_handle, joint, band[1] > 0 ? -18 : 18, 45)

	// Each arm goes on past the hand: three more forearms, spinning against each other, then fingers.
	for(var/side in list("l", "r"))
		var/sign = (side == "l" ? 1 : -1) * mirror
		var/source = "[side]_forearm"
		var/list/segment = segments[source]
		var/list/forearm = states["[body_by_part[source]]"]
		var/list/wrist = segment_point(forearm, segment["origin"], segment["end"])
		var/x = wrist[1]
		var/y = wrist[2]
		var/angle = forearm[3]
		var/parent = body_by_part[source]
		var/link_length = segment_length(segment) * 1.7 / LIMB_PHYSICS_PPM
		for(var/link in 1 to 3)
			parent = grow(source, parent, x, y, angle, 1.7, 1, sign * (ISODD(link) ? 12 : -15.6), 40)
			if(!parent)
				return TRUE
			x += link_length * sin(TODEGREES(angle))
			y -= link_length * cos(TODEGREES(angle))
		for(var/spread in list(-35, 0, 35))
			var/finger = grow(source, parent, x, y, angle + TORADIANS(spread), 0.9, 0.35, sign * (spread <= 0 ? 14 : -14), 8)
			if(finger)
				tips += finger

	// A second pair of arms out of the ribs.
	var/list/chest_segment = segments[RIG_CHEST]
	var/list/hips = chest_segment["origin"]
	var/list/neck = chest_segment["end"]
	var/list/chest = states["[body_by_part[RIG_CHEST]]"]
	for(var/side in list("l", "r"))
		var/height = side == "l" ? 0.55 : 0.3
		var/list/root = segment_point(chest, hips, list(hips[1], hips[2] + (neck[2] - hips[2]) * height))
		var/angle = chest[3] + TORADIANS((side == "l" ? 100 : -100) * mirror)
		var/arm = grow("[side]_arm", body_by_part[RIG_CHEST], root[1], root[2], angle, 1.4, 1, 12, 30, -150, 150)
		if(!arm)
			return TRUE
		var/arm_length = segment_length(segments["[side]_arm"]) * 1.4 / LIMB_PHYSICS_PPM
		var/hand = grow("[side]_forearm", arm, root[1] + arm_length * sin(TODEGREES(angle)), root[2] - arm_length * cos(TODEGREES(angle)), angle, 1.6, 1, -12, 30, -150, 150)
		if(hand)
			tips += hand

	// The head pinned to a foot and the torso to a shin, each halfway between where they are.
	for(var/list/pair in list(list(RIG_HEAD, "l_foot"), list(RIG_CHEST, "r_shin")))
		var/list/first = states["[body_by_part[pair[1]]]"]
		var/list/second = states["[body_by_part[pair[2]]]"]
		vcphys_call("joint_revolute", world_handle, body_by_part[pair[1]], body_by_part[pair[2]], (first[1] + second[1]) / 2, (first[2] + second[2]) / 2, 0, 0, 0)

	add_surroundings()
	rig.sort_pieces()
	ADD_TRAIT(rig.owner, TRAIT_IMMOBILIZED, SERVERBLIGHT_TRAIT)
	ADD_TRAIT(rig.owner, TRAIT_HANDS_BLOCKED, SERVERBLIGHT_TRAIT)
	return TRUE

/// A segment's length in pixels, as build() gives its box.
/datum/limb_physics/proc/segment_length(list/segment)
	var/list/origin = segment["origin"]
	var/list/end = segment["end"]
	return max(sqrt((end[1] - origin[1]) ** 2 + (end[2] - origin[2]) ** 2), 2)

/// Where a point on a segment's sprite is in the world, in metres, with the segment's body in
/// state (list(x, y, angle, ...)) and its sprite hanging off origin.
/datum/limb_physics/proc/segment_point(list/state, list/origin, list/point)
	var/dx = (point[1] - origin[1]) / LIMB_PHYSICS_PPM
	var/dy = (point[2] - origin[2]) / LIMB_PHYSICS_PPM
	var/turn = TODEGREES(state[3])
	return list(state[1] + dx * cos(turn) - dy * sin(turn), state[2] + dx * sin(turn) + dy * cos(turn))

/**
 * Grows a copy of a segment off another body, pinned at (x, y) and hanging from there at angle,
 * drawn as the segment is, stretched. Its joint turns freely unless given limits (degrees), and is
 * driven at motor_speed with up to motor_torque. It never sleeps, so its motor never stalls.
 * Returns the new body's handle.
 */
/datum/limb_physics/proc/grow(source, parent, x, y, angle, length_scale, width_scale, motor_speed, motor_torque, lower = 0, upper = 0)
	var/list/segment = segments[source]
	var/length = segment_length(segment) * length_scale / LIMB_PHYSICS_PPM
	var/body = vcphys_call("body_create", world_handle, LIMB_PHYSICS_DYNAMIC, x, y, angle, 0.09, 0.3, 0)
	if(!body)
		return null
	vcphys_call("fixture_box", world_handle, body, segment["width"] * width_scale / 2 / LIMB_PHYSICS_PPM, length / 2, 0, -length / 2, 0, 35, 0.7, 0.05, 0)
	var/joint = vcphys_call("joint_revolute", world_handle, parent, body, x, y, TORADIANS(lower), TORADIANS(upper), 0)
	if(joint)
		vcphys_call("joint_set_motor", world_handle, joint, motor_speed, motor_torque)

	// Hung on the mob, just behind the upper body, or behind everything if its arm is.
	var/obj/effect/abstract/limb_rig_part/original = rig.parts[source]
	var/layer = original.layer <= -6 ? -7.5 : -2.5
	var/obj/effect/abstract/limb_rig_part/skin = rig.new_part(source)
	skin.appearance = original.appearance
	skin.layer = layer
	var/obj/effect/abstract/limb_rig_part/cloth
	if(rig.cloth_parts[source])
		cloth = rig.new_part(source)
		cloth.appearance = rig.cloth_parts[source].appearance
		cloth.layer = layer + 0.05
	rig.owner.vis_contents += skin
	if(cloth)
		rig.owner.vis_contents += cloth
	growths += list(list(skin, cloth, body, source, length_scale, width_scale))
	return body

/// Puts every growth where the simulation has it, as draw() does the body.
/datum/limb_physics/proc/draw_growths(list/states, time)
	for(var/list/growth as anything in growths)
		var/list/state = states["[growth[3]]"]
		if(!state)
			continue
		var/list/origin = segments[growth[4]]["origin"]
		var/matrix/segment = rig_joint_matrix(origin[1], origin[2], growth[5], -TODEGREES(state[3]), state[1] * LIMB_PHYSICS_PPM + 16.5, state[2] * LIMB_PHYSICS_PPM, growth[6])
		animate(growth[1], transform = segment, time = time)
		if(growth[2])
			animate(growth[2], transform = rig.get_cloth_map(growth[4], facing) * segment, time = time)

/// Pulls every fingertip away from the torso (and a little up), as hard as they'll stretch.
/datum/limb_physics/proc/pull_tips()
	var/list/chest = last_states?["[body_by_part[RIG_CHEST]]"]
	if(!chest)
		return
	for(var/tip in tips)
		var/list/state = last_states["[tip]"]
		if(!state)
			continue
		var/dx = state[1] - chest[1]
		var/dy = state[2] - chest[2]
		var/distance = max(sqrt(dx ** 2 + dy ** 2), 0.01)
		vcphys_call("body_force", world_handle, tip, 40 * dx / distance, 40 * dy / distance + 10)

/// Walls and dense furniture on the tiles around the victim, as they're drawn around it: the body
/// is simulated on its own tile, a tile being 32 pixels.
/datum/limb_physics/proc/add_surroundings()
	var/turf/centre = get_turf(rig.owner)
	if(!centre)
		return
	var/tile = 32 / LIMB_PHYSICS_PPM
	for(var/dx in -1 to 1)
		for(var/dy in -1 to 1)
			if(!dx && !dy)
				continue
			var/turf/spot = locate(centre.x + dx, centre.y + dy, centre.z)
			if(!spot)
				continue
			if(spot.density)
				add_static_box(dx * tile, (dy + 0.5) * tile, tile / 2, tile / 2)
				continue
			for(var/obj/thing in spot)
				if(thing.density)
					add_static_box(dx * tile, (dy + 0.5) * tile, tile * 0.35, tile * 0.35)
					break

/// Takes away everything Serverblight grew.
/datum/limb_physics/proc/clear_growths()
	for(var/list/growth as anything in growths)
		for(var/obj/effect/abstract/limb_rig_part/piece in growth.Copy(1, 3))
			rig?.owner?.vis_contents -= piece
			qdel(piece)
	growths.Cut()
	tips.Cut()
