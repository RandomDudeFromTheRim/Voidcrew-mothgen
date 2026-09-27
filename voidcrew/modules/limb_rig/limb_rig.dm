/**
 * Limb rig.
 *
 * Every living, human-shaped carbon with the Overanimated quirk (quirk.dm) has its sprite cut
 * into moving pieces: head, torso, both arms, both legs, and whatever each hand is holding. The pieces then walk, crawl,
 * breathe, work tools, swing at things and act out emotes (animations.dm).
 *
 * How the cut works: a human is drawn entirely from overlays_standing. While rigged, those
 * layers go onto the pieces instead of the mob. Every piece gets every layer, and a
 * per-direction alpha mask (icons/rig_masks.dmi) keeps only its own region, so clothes,
 * hair and skin split along the same lines as the body. Held items skip the masks and ride on
 * their own pieces that move with the arm, so a long gun stays whole.
 *
 * The pieces are vis_contents, so they follow the mob, turn with it, pass clicks through
 * to it, and inherit its transform when it lies down. Arms and legs are two pieces each
 * (upper arm and forearm, thigh and shin). The head and arms sit inside a torso pivot, so
 * bending or breathing the torso carries them along; the legs hang off the mob directly.
 *
 * Idea and joint positions from the dancing PR, tgstation/tgstation#95581. That PR paints
 * each dancer's clothes into new icons every time; this masks the existing overlays instead,
 * so it's cheap enough to leave on everyone.
 */

#define RIG_MASKS 'voidcrew/modules/limb_rig/icons/rig_masks.dmi'

/// One cut-out piece of a rigged mob.
/obj/effect/abstract/limb_rig_part
	name = ""
	appearance_flags = KEEP_TOGETHER|PIXEL_SCALE|TILE_BOUND
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_DIR|VIS_INHERIT_PLANE
	layer = FLOAT_LAYER
	/// Which piece of the body this is, one of the RIG_ defines. Held item pieces use their arm's.
	var/part_id

/datum/limb_rig
	/// The mob being cut up.
	var/mob/living/carbon/owner
	/// Invisible piece at the hips that the whole upper body hangs off.
	var/obj/effect/abstract/limb_rig_part/pivot
	/// Pieces that show a masked copy of the body, by part id. RIG_CHEST is the torso inside the pivot.
	var/list/obj/effect/abstract/limb_rig_part/parts = list()
	/// Unmasked pieces holding each hand's held item, "l" and "r".
	var/list/obj/effect/abstract/limb_rig_part/item_parts = list()
	/// The overlays_standing layers currently copied onto the pieces, by cache index.
	var/list/mirrored_layers = list()
	/// What the rig is currently doing, a RIG_ACTIVITY_ define.
	var/activity = RIG_ACTIVITY_IDLE
	/// The pose the rig is holding (or animating toward), used to snap it right after turning.
	var/list/held_pose
	/// Nested do_afters in progress. Tool work animates for as long as this is above zero.
	var/working = 0
	/// Which leg leads on the next step.
	var/left_foot_forward = FALSE
	/// When the step in progress finishes, in world.time.
	var/step_ends_at = 0
	/// Timer that puts the rig back to its idle loop after a one-off animation or a walk.
	var/settle_timer
	/// How much longer than the sprite the arms and legs are drawn.
	var/arm_stretch = RIG_ARM_STRETCH
	var/leg_stretch = RIG_LEG_STRETCH
	/// How much bigger than the sprite the head (and whatever is on it) is drawn.
	var/head_scale = 1
	/// Angles added to every pose, from the species.
	var/list/posture
	/// How this body walks, a RIG_WALK_ define.
	var/walk_style = RIG_WALK_NORMAL
	/// Pieces hung directly on the mob (the rest hang off the pivot), to take back off.
	var/list/obj/effect/abstract/limb_rig_part/owner_pieces = list()

/datum/limb_rig/New(mob/living/carbon/owner)
	src.owner = owner
	refresh_shape()
	build_pieces()

	// Take the body off the mob and put it on the pieces.
	for(var/cache_index in 1 to length(owner.overlays_standing))
		var/standing = owner.overlays_standing[cache_index]
		if(!standing)
			continue
		owner.cut_overlay(standing)
		set_layer(cache_index, standing)

	RegisterSignal(owner, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(on_dir_change))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(owner, COMSIG_DO_AFTER_BEGAN, PROC_REF(on_work_began))
	RegisterSignal(owner, COMSIG_DO_AFTER_ENDED, PROC_REF(on_work_ended))
	RegisterSignals(owner, list(COMSIG_MOB_STATCHANGE, COMSIG_LIVING_SET_BODY_POSITION), PROC_REF(on_posture_change))
	RegisterSignal(owner, COMSIG_MOB_EMOTE, PROC_REF(on_emote))
	refresh_facing()
	settle()

/datum/limb_rig/Destroy()
	UnregisterSignal(owner, list(
		COMSIG_ATOM_POST_DIR_CHANGE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_DO_AFTER_BEGAN,
		COMSIG_DO_AFTER_ENDED,
		COMSIG_MOB_STATCHANGE,
		COMSIG_LIVING_SET_BODY_POSITION,
		COMSIG_MOB_EMOTE,
	))
	deltimer(settle_timer)
	// Give the body back to the mob, as it stands now.
	if(owner.limb_rig == src)
		owner.limb_rig = null
	for(var/cache_index in 1 to length(owner.overlays_standing))
		var/standing = owner.overlays_standing[cache_index]
		if(standing)
			owner.add_overlay(standing)
	owner.vis_contents -= owner_pieces
	owner_pieces = null
	QDEL_LIST_ASSOC_VAL(parts)
	QDEL_LIST_ASSOC_VAL(item_parts)
	QDEL_NULL(pivot)
	mirrored_layers = null
	owner = null
	return ..()

/// Takes the limb lengths, head size, posture and walk from the species.
/datum/limb_rig/proc/refresh_shape()
	var/mob/living/carbon/human/human_owner = owner
	var/list/shape = istype(human_owner) ? human_owner.dna?.species?.limb_rig_shape : null
	arm_stretch = shape?["arm_stretch"] || RIG_ARM_STRETCH
	leg_stretch = shape?["leg_stretch"] || RIG_LEG_STRETCH
	head_scale = shape?["head_scale"] || 1
	posture = shape?["posture"]
	walk_style = shape?["walk"] || RIG_WALK_NORMAL

/// Makes the pieces and hangs them up: the upper body off the pivot, the legs off the mob.
/datum/limb_rig/proc/build_pieces()
	pivot = new_part(RIG_CHEST)
	hang_on_owner(pivot)
	for(var/part_id in list(RIG_CHEST, RIG_HEAD, RIG_L_ARM, RIG_R_ARM, "l_forearm", "r_forearm"))
		parts[part_id] = new_part(part_id)
		pivot.vis_contents += parts[part_id]
	for(var/side in list("l", "r"))
		item_parts[side] = new_part(side == "l" ? RIG_L_ARM : RIG_R_ARM)
		pivot.vis_contents += item_parts[side]
	for(var/part_id in list(RIG_L_LEG, RIG_R_LEG, "l_shin", "r_shin"))
		parts[part_id] = new_part(part_id)
		hang_on_owner(parts[part_id])

/datum/limb_rig/proc/hang_on_owner(obj/effect/abstract/limb_rig_part/part)
	owner.vis_contents += part
	owner_pieces += part

/datum/limb_rig/proc/new_part(part_id)
	var/obj/effect/abstract/limb_rig_part/part = new
	part.part_id = part_id
	return part

/// Copies one overlays_standing layer onto the pieces, replacing what was there for that layer.
/datum/limb_rig/proc/set_layer(cache_index, standing)
	if(cache_index == HANDS_LAYER)
		refresh_held_items()
		return
	var/key = "[cache_index]"
	var/list/old = mirrored_layers[key]
	if(old)
		for(var/part_id in parts)
			var/obj/effect/abstract/limb_rig_part/part = parts[part_id]
			part.cut_overlay(old)
		mirrored_layers -= key
	if(!standing)
		return
	for(var/part_id in parts)
		var/obj/effect/abstract/limb_rig_part/part = parts[part_id]
		part.add_overlay(standing)
	mirrored_layers[key] = standing

/// Rebuilds each hand's held item piece. Held items aren't masked, so a long gun stays whole.
/datum/limb_rig/proc/refresh_held_items()
	for(var/side in item_parts)
		var/obj/effect/abstract/limb_rig_part/part = item_parts[side]
		part.cut_overlays()
	if(owner.handcuffed)
		return
	for(var/obj/item/held in owner.held_items)
		var/hand_index = owner.get_held_index_of_item(held)
		var/right = IS_RIGHT_INDEX(hand_index)
		var/obj/effect/abstract/limb_rig_part/part = item_parts[right ? "r" : "l"]
		part.add_overlay(held.build_worn_icon(
			default_layer = HANDS_LAYER,
			default_icon_file = right ? held.righthand_file : held.lefthand_file,
			isinhands = TRUE,
		))

/// Redraws wounds a body draws for itself, rather than the mob's damage overlay. Most don't.
/datum/limb_rig/proc/refresh_damage_marks()
	return

/// Everything the rig took off the mob, for things that copy the mob's look (mirrors).
/datum/limb_rig/proc/get_body_overlays()
	. = list()
	for(var/standing in owner.overlays_standing)
		if(standing)
			. += standing

/// Matches the masks and the draw order to the way the mob is facing.
/datum/limb_rig/proc/refresh_facing()
	var/facing = owner.dir
	for(var/part_id in parts)
		var/obj/effect/abstract/limb_rig_part/part = parts[part_id]
		var/mask_state = part_id
		var/flags = NONE
		if(part_id == RIG_HEAD)
			mask_state = "head_cut"
			flags = MASK_INVERSE
		else if(part_id == RIG_CHEST)
			mask_state = "torso_cut"
			flags = MASK_INVERSE
		part.add_filter("limb_rig_mask", 1, alpha_mask_filter(icon = get_rig_mask(mask_state, facing), flags = flags))

	// Seen side-on, the arm on the far side goes behind the torso. Seen from behind, both do:
	// anything the arms do in front of the body happens on the other side of the spine.
	var/far_side = facing == EAST ? "l" : (facing == WEST ? "r" : null)
	pivot.layer = -2
	for(var/part_id in list(RIG_L_LEG, RIG_R_LEG, "l_shin", "r_shin"))
		parts[part_id].layer = -3
	parts[RIG_CHEST].layer = -5
	parts[RIG_HEAD].layer = -4
	for(var/side in list("l", "r"))
		var/obj/effect/abstract/limb_rig_part/arm = parts[side == "l" ? RIG_L_ARM : RIG_R_ARM]
		var/obj/effect/abstract/limb_rig_part/item = item_parts[side]
		var/obj/effect/abstract/limb_rig_part/forearm = parts["[side]_forearm"]
		var/behind = (side == far_side || facing == NORTH)
		arm.layer = behind ? -7 : -3
		forearm.layer = arm.layer + 0.2
		item.layer = behind ? -6 : -2
	sort_pieces()

/// Pieces draw in the order they sit in vis_contents, whatever their layers say, so every time
/// the layers change, put the pieces in layer order: lowest first, drawn at the back.
/datum/limb_rig/proc/sort_pieces()
	for(var/atom/movable/container as anything in list(owner, pivot))
		var/list/pieces = list()
		for(var/obj/effect/abstract/limb_rig_part/part in container.vis_contents)
			pieces += part
		if(length(pieces) < 2)
			continue
		sortTim(pieces, GLOBAL_PROC_REF(cmp_atom_layer_asc))
		container.vis_contents -= pieces
		container.vis_contents += pieces

/// The mask icon for one piece facing one way. Built once each and kept.
/proc/get_rig_mask(mask_state, facing, mask_icon = RIG_MASKS)
	var/static/list/masks = list()
	var/key = "[mask_icon]-[mask_state]-[facing]"
	var/icon/mask = masks[key]
	if(!mask)
		mask = icon(mask_icon, mask_state, facing)
		masks[key] = mask
	return mask

/datum/limb_rig/proc/on_dir_change(mob/living/carbon/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(old_dir == new_dir)
		return
	refresh_facing()
	// A pose looks different from every side, so snap to how the current one reads from here,
	// then carry on with whatever loop was running.
	snap_to(held_pose)
	if(activity == RIG_ACTIVITY_IDLE || activity == RIG_ACTIVITY_WORKING)
		settle()

/datum/limb_rig/proc/on_moved(mob/living/carbon/source, atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER
	if(forced || !isturf(owner.loc) || !isturf(old_loc) || owner.buckled || owner.stat >= UNCONSCIOUS)
		return
	play_step()

/datum/limb_rig/proc/on_work_began(mob/living/carbon/source)
	SIGNAL_HANDLER
	working++
	if(working == 1 && activity != RIG_ACTIVITY_ONESHOT)
		settle()

/datum/limb_rig/proc/on_work_ended(mob/living/carbon/source)
	SIGNAL_HANDLER
	working = max(working - 1, 0)
	if(!working && activity == RIG_ACTIVITY_WORKING)
		settle()

/// Emotes act themselves out, once they've actually gone through.
/datum/limb_rig/proc/on_emote(mob/living/carbon/source, datum/emote/emote, act, m_type, message, intentional)
	SIGNAL_HANDLER
	play_emote(emote.key)

/datum/limb_rig/proc/on_posture_change(mob/living/carbon/source)
	SIGNAL_HANDLER
	if(activity != RIG_ACTIVITY_ONESHOT)
		settle()

// The body is drawn from overlays_standing; while rigged, it goes to the pieces instead.
// Mirrors, MODlinks and status displays listen for these signals, so they still fire.

/mob/living/carbon
	/// The cut-up version of this mob's sprite, while it has one.
	var/datum/limb_rig/limb_rig

/mob/living/carbon/apply_overlay(cache_index)
	if(!limb_rig)
		return ..()
	. = overlays_standing[cache_index]
	limb_rig.set_layer(cache_index, .)
	SEND_SIGNAL(src, COMSIG_CARBON_APPLY_OVERLAY, cache_index, .)

/mob/living/carbon/remove_overlay(cache_index)
	if(!limb_rig)
		return ..()
	var/old = overlays_standing[cache_index]
	if(old)
		limb_rig.set_layer(cache_index, null)
		overlays_standing[cache_index] = null
	SEND_SIGNAL(src, COMSIG_CARBON_REMOVE_OVERLAY, cache_index, old)

/// Whether this mob should be cut into moving pieces right now.
/mob/living/carbon/proc/can_have_limb_rig()
	if(QDELETED(src) || stat == DEAD || !ishuman(src) || istype(src, /mob/living/carbon/human/dummy))
		return FALSE
	var/mob/living/carbon/human/human_self = src
	if(!has_quirk(/datum/quirk/overanimated) && !human_self.dna?.species?.limb_rig_shape?["always"])
		return FALSE
	var/obj/item/bodypart/chest/chest = get_bodypart(BODY_ZONE_CHEST)
	// The masks are cut for a human-shaped body. Monkeys and xenos are built differently.
	return chest && (chest.bodyshape & BODYSHAPE_HUMANOID) && !(chest.bodyshape & BODYSHAPE_MONKEY)

/// Adds or removes the rig to match can_have_limb_rig(), and keeps its shape matching the species.
/mob/living/carbon/proc/update_limb_rig()
	if(can_have_limb_rig())
		// Start over, so a new species' pieces are right from the first layer.
		QDEL_NULL(limb_rig)
		var/mob/living/carbon/human/human_self = src
		var/list/shape = human_self.dna?.species?.limb_rig_shape
		var/rig_type = shape?["rig_type"] || (shape?["sprites"] ? /datum/limb_rig/sprites : /datum/limb_rig)
		limb_rig = new rig_type(src)
	else if(limb_rig)
		QDEL_NULL(limb_rig)

/mob/living/carbon/proc/on_limb_rig_species_change(mob/living/carbon/source)
	SIGNAL_HANDLER
	// Species swaps rebuild the body over several procs; look once it has settled.
	addtimer(CALLBACK(src, PROC_REF(update_limb_rig)), 0.1 SECONDS, TIMER_UNIQUE)

// Dying takes the rig off and being revived puts it back. This hooks set_stat() rather than
// the death signal, because navigation registers that same signal on the mob mid-round.
/mob/living/carbon/human/set_stat(new_stat)
	. = ..()
	if(stat == DEAD || limb_rig == null)
		update_limb_rig()

/datum/species
	/**
	 * How the limb rig draws this species, or null for the usual. Keys:
	 * - "arm_stretch", "leg_stretch": how much longer than the sprite
	 * - "head_scale": how much bigger than the sprite the head is drawn, hats and all
	 * - "always": the species is always rigged, quirk or not, because it only looks right rigged
	 * - "sprites", "skeleton", "leg_rest", "cloth_masks", "hat_scale", "torso_width", "cloth_widths", "paw_height",
	 *   "damage":
	 *   a body built from its own piece sprites (see sprite_rig.dm)
	 * - "rig_type": a /datum/limb_rig subtype with the species' own animations
	 * - "posture": a pose added to every pose (see animations.dm)
	 * - "walk": a RIG_WALK_ define
	 */
	var/list/limb_rig_shape

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SPECIES_GAIN, PROC_REF(on_limb_rig_species_change))
	// The body finishes drawing itself during Initialize, so cut it up just after.
	addtimer(CALLBACK(src, PROC_REF(update_limb_rig)), 0.1 SECONDS, TIMER_UNIQUE)

/mob/living/carbon/Destroy()
	QDEL_NULL(limb_rig)
	return ..()

/// Bodies that draw their own wounds redraw them whenever the damage overlay would change.
/mob/living/carbon/update_damage_overlays()
	. = ..()
	limb_rig?.refresh_damage_marks()

/// Swinging at something swings an arm.
/mob/living/carbon/human/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	. = ..()
	limb_rig?.play_attack()

/// Mirrors copy the mob's appearance, which has no body on it while rigged, so add it back.
/datum/component/reflection/copy_appearance_to_reflection(obj/effect/abstract/reflection, atom/movable/target)
	. = ..()
	var/mob/living/carbon/rigged = target
	if(istype(rigged) && rigged.limb_rig)
		reflection.add_overlay(rigged.limb_rig.get_body_overlays())

#undef RIG_MASKS
