/**
 * A rigged body taken over by physics: a ragdoll.
 *
 * The limb rig normally plays authored poses. With physics on, it plays none: every body segment
 * (torso, head, upper and lower arms, thighs, shins, feet) becomes a Box2D body, pinned to its
 * neighbours by joints that bend like the real ones, and each tick the pieces are put wherever the
 * simulation says. Everything else on the rig (clothes, shoes, held items, the tail, wings) rides
 * along on the segment it belongs to, as it does in a pose. Turn physics off and the rig goes
 * straight back to its authored animation.
 *
 * Only sprite-built bodies can go physical (Experiments and the roundstart species): the bones
 * come from their skeletons.
 *
 * The simulation is in the body's own frame, drawn on the mob's tile: one metre is
 * LIMB_PHYSICS_PPM pixels, the floor is the bottom of the tile, and a wall stands a tile and a half
 * out on either side. The mob itself doesn't move.
 *
 * Only Box2D handles are kept here. The simulation is stepped a fixed LIMB_PHYSICS_STEPS_PER_FIRE
 * steps of LIMB_PHYSICS_DT every time SSlimb_physics fires, so it runs the same every time, however
 * the server's doing.
 */
/datum/limb_physics
	/// The rig being simulated.
	var/datum/limb_rig/sprites/rig
	/// Which way the body faced when it went physical. The bones are that direction's.
	var/facing
	/// The Box2D world, as the library's handle.
	var/world_handle
	/// Each segment's body handle, by piece id.
	var/list/body_by_part = list()
	/// Each segment's origin in its sprite (the joint it hangs off), by piece id: the point its
	/// body sits on.
	var/list/origins = list()
	/// Each joint's handle, by the piece id of its lower half.
	var/list/joint_by_part = list()
	/// Steps taken so far.
	var/steps = 0
	/// The last positions read back, for inspecting: handle => list(x, y, angle, vx, vy, spin).
	var/list/last_states

/datum/limb_physics/New(datum/limb_rig/sprites/rig)
	src.rig = rig
	rig.physics = src
	if(!build())
		qdel(src)
		return
	START_PROCESSING(SSlimb_physics, src)

/datum/limb_physics/Destroy()
	STOP_PROCESSING(SSlimb_physics, src)
	destroy_world()
	if(rig?.physics == src)
		rig.physics = null
		// Back to the authored animation, from where it is now.
		if(!QDELETED(rig) && !QDELETED(rig.owner))
			rig.snap_to(rig.held_pose)
			rig.settle()
	rig = null
	return ..()

/datum/limb_physics/proc/destroy_world()
	if(world_handle)
		vcphys_call("world_destroy", world_handle)
	world_handle = null
	body_by_part.Cut()
	joint_by_part.Cut()
	origins.Cut()

/// Starts over from the rig's current pose, facing the way the mob faces now.
/datum/limb_physics/proc/rebuild()
	destroy_world()
	if(!build())
		qdel(src)

/**
 * Makes the world: a floor and walls, and a body for every segment, starting exactly where the
 * rig has it drawn now, joined at its joints. Returns FALSE if anything couldn't be made.
 */
/datum/limb_physics/proc/build()
	facing = rig.get_facing()
	world_handle = vcphys_call("world_create", 0, LIMB_PHYSICS_GRAVITY)
	if(!world_handle)
		return FALSE
	// The floor, the bottom of the tile, and a wall a tile and a half out either side.
	if(!add_static_box(0, -0.5, 4, 0.5) || !add_static_box(-2.9, 2, 0.5, 2.5) || !add_static_box(2.9, 2, 0.5, 2.5))
		return FALSE

	var/list/segments = rig.get_physics_segments(facing)
	var/list/drawn = rig.get_segment_matrices(rig.held_pose, facing)
	for(var/part_id in segments)
		var/list/segment = segments[part_id]
		var/list/origin = segment["origin"]
		var/list/end = segment["end"]
		var/matrix/now = drawn[part_id] || matrix()
		// Where the origin is drawn now, and how far it's turned (counter-clockwise, as Box2D has it).
		var/list/at = rig_apply_matrix(now, origin[1], origin[2])
		var/angle = TORADIANS(rig_matrix_angle(now))
		var/body = vcphys_call("body_create", world_handle, LIMB_PHYSICS_DYNAMIC, (at[1] - 16.5) / LIMB_PHYSICS_PPM, at[2] / LIMB_PHYSICS_PPM, angle, 0.05, 0.4)
		if(!body)
			return FALSE
		// The segment's box in the body's own frame: its sprite, before it's turned, with the
		// origin at (0, 0).
		var/length = max(sqrt((end[1] - origin[1]) ** 2 + (end[2] - origin[2]) ** 2), 2)
		var/centre_x = ((origin[1] + end[1]) / 2 - origin[1]) / LIMB_PHYSICS_PPM
		var/centre_y = ((origin[2] + end[2]) / 2 - origin[2]) / LIMB_PHYSICS_PPM
		if(!vcphys_call("fixture_box", world_handle, body, segment["width"] / 2 / LIMB_PHYSICS_PPM, length / 2 / LIMB_PHYSICS_PPM, centre_x, centre_y, 0, segment["density"], 0.7, 0.05, LIMB_PHYSICS_RAGDOLL_GROUP))
			return FALSE
		body_by_part[part_id] = body
		origins[part_id] = origin

	// Joints, each at the lower segment's origin, where it starts out.
	for(var/part_id in segments)
		var/list/segment = segments[part_id]
		var/parent = segment["parent"]
		if(!parent)
			continue
		var/list/origin = segment["origin"]
		var/list/at = rig_apply_matrix(drawn[part_id] || matrix(), origin[1], origin[2])
		var/list/limits = limb_physics_joint_limits(segment["joint"], facing)
		var/joint = vcphys_call("joint_revolute", world_handle, body_by_part[parent], body_by_part[part_id], (at[1] - 16.5) / LIMB_PHYSICS_PPM, at[2] / LIMB_PHYSICS_PPM, TORADIANS(limits[1]), TORADIANS(limits[2]), limits[3])
		if(!joint)
			return FALSE
		joint_by_part[part_id] = joint
	return TRUE

/datum/limb_physics/proc/add_static_box(x, y, half_width, half_height)
	var/body = vcphys_call("body_create", world_handle, LIMB_PHYSICS_STATIC, x, y, 0, 0, 0)
	return body && vcphys_call("fixture_box", world_handle, body, half_width, half_height, 0, 0, 0, 0, 0.8, 0, 0)

/datum/limb_physics/process(seconds_per_tick)
	if(QDELETED(rig) || QDELETED(rig.owner))
		qdel(src)
		return PROCESS_KILL
	// Always the same number of equal steps: the tick's actual length never comes into it.
	if(!vcphys_call("world_step", world_handle, LIMB_PHYSICS_DT, LIMB_PHYSICS_VELOCITY_ITERATIONS, LIMB_PHYSICS_POSITION_ITERATIONS, LIMB_PHYSICS_STEPS_PER_FIRE))
		qdel(src)
		return PROCESS_KILL
	steps += LIMB_PHYSICS_STEPS_PER_FIRE
	var/list/states = read_states()
	if(!states)
		qdel(src)
		return PROCESS_KILL
	draw(states, SSlimb_physics.wait)

/**
 * Every body's state, by handle: list(x, y, angle, vx, vy, spin). Null if the reply was garbled,
 * or anything has gone NaN or flown off (which would mean the simulation blew up).
 */
/datum/limb_physics/proc/read_states()
	var/reply = vcphys_call("world_read", world_handle)
	if(!reply)
		return null
	var/list/states = list()
	for(var/entry in splittext(reply, ";"))
		var/list/fields = splittext(entry, " ")
		if(length(fields) != 7)
			stack_trace("vcphys: a garbled body in world_read: [entry]")
			return null
		var/list/state = list()
		for(var/i in 2 to 7)
			var/value = text2num(fields[i])
			if(!isnum(value) || value != value || abs(value) > 1000)
				stack_trace("vcphys: body [fields[1]] blew up: [entry]")
				return null
			state += value
		states[fields[1]] = state
	last_states = states
	return states

/// Puts every piece where the simulation has it, easing there over time deciseconds.
/datum/limb_physics/proc/draw(list/states, time)
	var/list/segment_matrices = list()
	for(var/part_id in body_by_part)
		var/list/state = states["[body_by_part[part_id]]"]
		if(!state)
			continue
		var/list/origin = origins[part_id]
		// Box2D turns counter-clockwise in radians, BYOND clockwise in degrees.
		segment_matrices[part_id] = rig_joint_matrix(origin[1], origin[2], 1, -TODEGREES(state[3]), state[1] * LIMB_PHYSICS_PPM + 16.5, state[2] * LIMB_PHYSICS_PPM)
	var/list/matrices = rig.get_physics_matrices(segment_matrices, facing)
	for(var/atom/movable/piece as anything in matrices)
		animate(piece, transform = matrices[piece], time = time)

/// Shoves a segment: an impulse in newton-seconds, right and up are positive.
/datum/limb_physics/proc/push(part_id, impulse_x, impulse_y)
	var/body = body_by_part[part_id]
	return body && vcphys_call("body_impulse", world_handle, body, impulse_x, impulse_y)

/// Spins a segment: an angular impulse, counter-clockwise positive.
/datum/limb_physics/proc/twist(part_id, impulse)
	var/body = body_by_part[part_id]
	return body && vcphys_call("body_angular_impulse", world_handle, body, impulse)

/**
 * How far each joint bends, in degrees, relative to how it sits at the start, and how stiff it is:
 * list(lower, upper, friction torque in newton-metres). Side-on, bending is anatomical (elbows and
 * knees only go one way), mirrored facing west. Seen from the front, it's a looser, symmetric range.
 */
/proc/limb_physics_joint_limits(joint, facing)
	// Facing east: counter-clockwise is forward.
	var/static/list/side_on = list(
		"neck" = list(-40, 40, 1.5),
		"shoulder" = list(-80, 170, 2),
		"elbow" = list(0, 145, 1),
		"hip" = list(-30, 110, 3),
		"knee" = list(-120, 10, 2),
		"ankle" = list(-30, 30, 1),
	)
	var/static/list/front_on = list(
		"neck" = list(-25, 25, 1.5),
		"shoulder" = list(-150, 150, 2),
		"elbow" = list(-60, 60, 1),
		"hip" = list(-50, 50, 3),
		"knee" = list(-15, 15, 2),
		"ankle" = list(-15, 15, 1),
	)
	var/list/table = (facing & (EAST|WEST)) ? side_on : front_on
	var/list/limits = table[joint] || list(-30, 30, 1)
	if(facing == WEST)
		return list(-limits[2], -limits[1], limits[3])
	return limits.Copy()

/// Where a matrix puts a point, as rig_joint_matrix() works them: about the middle of a 32 pixel
/// tile, in the skeleton's pixel coordinates. Scale and skew are taken as they come.
/proc/rig_apply_matrix(matrix/transform, x, y)
	return list(
		transform.a * (x - 16.5) + transform.b * (y - 16.5) + transform.c + 16.5,
		transform.d * (x - 16.5) + transform.e * (y - 16.5) + transform.f + 16.5,
	)

/// How far a matrix turns things, in degrees counter-clockwise.
/proc/rig_matrix_angle(matrix/transform)
	return arctan(transform.a, transform.d)

// The rig's side of it.

/datum/limb_rig
	/// The physics driving this rig instead of its animations, while it has any.
	var/datum/limb_physics/physics

/**
 * The segments physics simulates, by piece id, from the skeleton facing this way:
 * list("origin" = the joint it hangs off, "end" = its far end, "width" = pixels across,
 * "density" = kilograms per square metre, "parent" = the piece it hangs off, "joint" = what kind
 * of joint that is). The torso hangs off nothing.
 */
/datum/limb_rig/sprites/proc/get_physics_segments(facing)
	var/list/bones = skeleton[dir2text(facing)]
	var/front = facing & (NORTH|SOUTH)
	var/list/hips = bones[RIG_CHEST]
	var/list/neck = bones[RIG_HEAD]
	var/list/crown = bones["crown"] || list(neck[1], neck[2] + 10)
	var/list/l_shoulder = bones["l_arm"][1]
	var/list/r_shoulder = bones["r_arm"][1]
	. = list()
	.[RIG_CHEST] = list("origin" = hips, "end" = neck, "width" = front ? max(abs(l_shoulder[1] - r_shoulder[1]) - 2, 6) : 7, "density" = 60)
	var/head_height = crown[2] - neck[2]
	.[RIG_HEAD] = list("origin" = neck, "end" = crown, "width" = clamp(head_height * 0.8, 6, 12), "density" = 50, "parent" = RIG_CHEST, "joint" = "neck")
	for(var/side in list("l", "r"))
		var/list/arm = bones["[side]_arm"]
		var/list/wrist = arm[3]
		.["[side]_arm"] = list("origin" = arm[1], "end" = arm[2], "width" = 4, "density" = 45, "parent" = RIG_CHEST, "joint" = "shoulder")
		// On past the wrist to take in the hand.
		.["[side]_forearm"] = list("origin" = arm[2], "end" = list(wrist[1], wrist[2] - 3), "width" = 3.5, "density" = 45, "parent" = "[side]_arm", "joint" = "elbow")
		var/list/leg = bones["[side]_leg"]
		.["[side]_thigh"] = list("origin" = leg[1], "end" = leg[2], "width" = 5, "density" = 50, "parent" = RIG_CHEST, "joint" = "hip")
		.["[side]_shin"] = list("origin" = leg[2], "end" = leg[3], "width" = 4, "density" = 45, "parent" = "[side]_thigh", "joint" = "knee")
		.["[side]_foot"] = list("origin" = leg[3], "end" = leg[4], "width" = 4, "density" = 45, "parent" = "[side]_shin", "joint" = "ankle")

/**
 * Where a pose draws each segment, in the body's own frame (not relative to the torso, as the arms
 * and head usually are): the matrix taking the segment's sprite to where it's drawn, by piece id.
 */
/datum/limb_rig/sprites/proc/get_segment_matrices(list/pose, facing)
	var/list/posed = get_pose_matrices(pose, facing)
	var/matrix/torso = posed[pivot] || matrix()
	. = list()
	.[RIG_CHEST] = torso
	for(var/part_id in list(RIG_HEAD, "l_arm", "l_forearm", "r_arm", "r_forearm"))
		.[part_id] = (posed[parts[part_id]] || matrix()) * torso
	for(var/part_id in list("l_thigh", "l_shin", "l_foot", "r_thigh", "r_shin", "r_foot"))
		.[part_id] = posed[parts[part_id]] || matrix()

/**
 * Transforms for every piece of the rig, from where physics has each segment (in the body's own
 * frame, as get_segment_matrices()): the segments themselves, their clothes and shoes, held items
 * at the wrists, and the tail on the torso. The torso's pivot stays put, since the segments are
 * already placed in the body's frame.
 */
/datum/limb_rig/sprites/proc/get_physics_matrices(list/segment_matrices, facing)
	. = list()
	.[pivot] = matrix()
	for(var/part_id in segment_matrices)
		var/matrix/segment = segment_matrices[part_id]
		.[parts[part_id]] = segment
		if(cloth_parts[part_id])
			.[cloth_parts[part_id]] = get_cloth_map(part_id, facing) * segment
	var/list/bones = skeleton[dir2text(facing)]
	for(var/side in list("l", "r"))
		var/matrix/foot = segment_matrices["[side]_foot"]
		if(foot)
			.[shoe_parts[side]] = get_cloth_map("[side]_foot", facing) * foot
		var/matrix/forearm = segment_matrices["[side]_forearm"]
		if(forearm)
			// Held items are drawn for a human hand: put that hand at this wrist, turned with it.
			var/list/wrist = bones["[side]_arm"][3]
			var/list/at = rig_apply_matrix(forearm, wrist[1], wrist[2])
			var/list/human_hand = get_rig_joint(side == "l" ? RIG_L_ARM : RIG_R_ARM, facing)
			.[item_parts[side]] = rig_joint_matrix(human_hand[1], LIMB_PHYSICS_HUMAN_HAND_Y, item_scale, -rig_matrix_angle(forearm), at[1], at[2], item_scale)
	var/matrix/torso = segment_matrices[RIG_CHEST]
	if(torso && parts[RIG_TAIL])
		.[parts[RIG_TAIL]] = rig_tail_matrix(bones[RIG_TAIL], null, facing) * torso

/datum/limb_rig/sprites/humanoid/get_physics_matrices(list/segment_matrices, facing)
	. = ..()
	var/matrix/torso = segment_matrices[RIG_CHEST]
	if(!torso)
		return
	.[wings_part] = get_cloth_map(RIG_CHEST, facing) * torso
	var/list/root = get_tail_root(facing)
	var/list/bone = skeleton[dir2text(facing)][RIG_TAIL]
	.[tail_part] = rig_joint_matrix(root[1], root[2], hat_scale, 0, bone[1], bone[2], hat_scale) * .[parts[RIG_TAIL]]

/// Turns physics on or off for this mob's rig. Returns whether it's on now.
/mob/living/carbon/proc/set_limb_physics(enabled)
	if(!enabled)
		if(limb_rig?.physics)
			qdel(limb_rig.physics)
		return FALSE
	if(!istype(limb_rig, /datum/limb_rig/sprites) || !vcphys_available())
		return FALSE
	if(!limb_rig.physics)
		new /datum/limb_physics(limb_rig)
	return !!limb_rig.physics

/// Steps every rig that's gone physical, every decisecond.
PROCESSING_SUBSYSTEM_DEF(limb_physics)
	name = "Limb Physics"
	flags = SS_NO_INIT
	wait = 1
