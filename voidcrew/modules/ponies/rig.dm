/**
 * Ponies on the limb rig: the pony's own sprites cut into pieces (icons/pony_rig.dmi, made from
 * bodyparts.dmi), front legs moving as the arms and hind legs as the legs. Clothes are already
 * drawn pony-shaped, so they're only cut along the same lines (icons/pony_rig_masks.dmi), never
 * stretched. The head, mane, horn, wings and tail come from the pony's own sprites, as for any
 * humanoid.
 *
 * They trot, diagonal pairs of legs together, and gallop when running. Bending the torso tips the
 * body about the hind legs, so a negative bend rears up.
 */
/datum/species/pony
	limb_rig_shape = list(
		"always" = TRUE,
		"optional" = TRUE,
		"bodyshape" = BODYSHAPE_PONY,
		"rig_type" = /datum/limb_rig/sprites/humanoid/pony,
		"sprites" = 'voidcrew/modules/ponies/icons/pony_rig.dmi',
		"cloth_masks" = 'voidcrew/modules/ponies/icons/pony_rig_masks.dmi',
		"skeleton" = list(
			"south" = list("l_arm" = list(list(14, 11), list(14, 5), list(14, 0.5)), "r_arm" = list(list(18, 11), list(18, 5), list(18, 0.5)), "l_leg" = list(list(14, 11), list(14, 5), list(14, 2), list(14, 0.5)), "r_leg" = list(list(18, 11), list(18, 5), list(18, 2), list(18, 0.5)), "head" = list(16.5, 16.5), "crown" = list(16.5, 28.5), "chest" = list(16.5, 9), "tail" = list(16.5, 12)),
			"north" = list("l_arm" = list(list(14, 11), list(14, 5), list(14, 0.5)), "r_arm" = list(list(18, 11), list(18, 5), list(18, 0.5)), "l_leg" = list(list(14, 11), list(14, 5), list(14, 2), list(14, 0.5)), "r_leg" = list(list(18, 11), list(18, 5), list(18, 2), list(18, 0.5)), "head" = list(16.5, 16.5), "crown" = list(16.5, 28.5), "chest" = list(16.5, 9), "tail" = list(16.5, 12)),
			"east" = list("l_arm" = list(list(20.5, 11), list(20.5, 5), list(20.5, 0.5)), "r_arm" = list(list(23, 11), list(23, 5), list(23, 0.5)), "l_leg" = list(list(15, 11), list(15, 5), list(15, 2), list(15, 0.5)), "r_leg" = list(list(12, 11), list(12, 5), list(12, 2), list(12, 0.5)), "head" = list(20, 16.5), "crown" = list(22, 26.5), "chest" = list(12, 11), "tail" = list(11, 13)),
			"west" = list("l_arm" = list(list(10, 11), list(10, 5), list(10, 0.5)), "r_arm" = list(list(12.5, 11), list(12.5, 5), list(12.5, 0.5)), "l_leg" = list(list(21, 11), list(21, 5), list(21, 2), list(21, 0.5)), "r_leg" = list(list(18, 11), list(18, 5), list(18, 2), list(18, 0.5)), "head" = list(13, 16.5), "crown" = list(11, 26.5), "chest" = list(21, 11), "tail" = list(22, 13)),
		),
		"tail_root" = list("south" = list(16.5, 12), "north" = list(16.5, 12), "east" = list(11, 13), "west" = list(22, 13)),
		"leg_rest" = list(0, 0, 0),
		"paw_height" = 2,
		"item_scale" = 0.75,
	)

/datum/limb_rig/sprites/humanoid/pony
	/// The shoes on the front hooves, which ride on the forearms' cloth pieces.
	var/front_shoes

// Pony clothes are drawn for this body already.
/datum/limb_rig/sprites/humanoid/pony/get_cloth_map(part_id, facing)
	return matrix()

/datum/limb_rig/sprites/humanoid/pony/set_layer(cache_index, standing)
	. = ..()
	if(cache_index != SHOES_LAYER)
		return
	// Four hooves, four shoes: the front two go on the forearms.
	for(var/side in list("l", "r"))
		var/obj/effect/abstract/limb_rig_part/forearm = cloth_parts["[side]_forearm"]
		forearm.cut_overlay(front_shoes)
		if(standing)
			forearm.add_overlay(standing)
	front_shoes = standing

/datum/limb_rig/sprites/humanoid/pony/refresh_facing()
	. = ..()
	// Pony wings are drawn over the body every way round.
	wings_part.layer = -1
	sort_pieces()

/datum/limb_rig/sprites/humanoid/pony/get_own_step(step_time, running, lying)
	if(lying)
		return null
	var/lead = left_foot_forward ? 1 : -1
	var/list/keyframes
	if(running)
		// A gallop: the hind legs gather under the body, push it off into the air with the front
		// legs reaching, and the front hooves come down first.
		var/list/gather = list(
			RIG_L_ARM = list("swing" = -15, "elbow" = -20), RIG_R_ARM = list("swing" = -20, "elbow" = -10),
			RIG_L_LEG = list("swing" = 35, "knee" = 25), RIG_R_LEG = list("swing" = 30, "knee" = 30),
			RIG_CHEST = list("bend" = 4, "breath" = -0.05), RIG_HEAD = list("nod" = 8),
			RIG_TAIL = list("lift" = -5, "wag" = 6 * lead),
		)
		var/list/flight = list(
			RIG_L_ARM = list("swing" = 45, "elbow" = -10), RIG_R_ARM = list("swing" = 40, "elbow" = -25),
			RIG_L_LEG = list("swing" = -40, "knee" = 5), RIG_R_LEG = list("swing" = -35, "knee" = 10),
			RIG_CHEST = list("bend" = -8, "breath" = 0.04, "air" = 4), RIG_HEAD = list("nod" = -10),
			RIG_TAIL = list("lift" = 15),
		)
		var/list/land = list(
			RIG_L_ARM = list("swing" = 15), RIG_R_ARM = list("swing" = 25, "elbow" = -15),
			RIG_L_LEG = list("swing" = -15, "knee" = 20), RIG_R_LEG = list("swing" = -5, "knee" = 30),
			RIG_CHEST = list("bend" = 6, "air" = 1), RIG_HEAD = list("nod" = 4),
			RIG_TAIL = list("lift" = 5, "wag" = -6 * lead),
		)
		keyframes = list(
			list(gather, step_time * 0.3, QUAD_EASING | EASE_OUT),
			list(flight, step_time * 0.4, SINE_EASING | EASE_OUT),
			list(land, step_time * 0.3, CUBIC_EASING | EASE_IN),
		)
	else
		// A trot: diagonal pairs of legs (left front with right hind, then the other two) reach
		// and push together, then the pushing pair swings through with its hooves tucked.
		var/list/reach = list(
			RIG_L_ARM = list("swing" = 24 * lead), RIG_R_ARM = list("swing" = -20 * lead),
			RIG_R_LEG = list("swing" = 20 * lead, "knee" = lead > 0 ? 0 : 15), RIG_L_LEG = list("swing" = -20 * lead, "knee" = lead > 0 ? 15 : 0),
			RIG_HEAD = list("nod" = 3),
			RIG_TAIL = list("wag" = -8 * lead, "lift" = -3),
		)
		var/list/tucked = list("swing" = 12, "elbow" = -75)
		var/list/hind_tucked = list("swing" = 6, "knee" = 55)
		var/list/through = list(
			RIG_L_ARM = lead > 0 ? list() : tucked, RIG_R_ARM = lead > 0 ? tucked : list(),
			RIG_L_LEG = lead > 0 ? hind_tucked : list(), RIG_R_LEG = lead > 0 ? list() : hind_tucked,
			RIG_CHEST = list("air" = 1.5, "breath" = 0.02), RIG_HEAD = list("nod" = -3),
			RIG_TAIL = list("wag" = 0, "lift" = 4),
		)
		keyframes = list(
			list(rig_scale_gait(reach, get_gait_scale(FALSE)), step_time * 0.5),
			list(through, step_time * 0.5),
		)
	return keyframes
