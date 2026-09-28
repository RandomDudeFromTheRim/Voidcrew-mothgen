/**
 * The body every roundstart species is drawn with: a generated, shaded body a quarter bigger than
 * a human, built piece by piece like the Experiment's (see sprite_rig.dm), so an arm or leg moves
 * as a whole limb rather than a cut-out of a flat sprite.
 *
 * What makes the species stays their own. The body is tinted to each limb's colour (skin tone,
 * scales, fur; prosthetics come out their own colour). The real head goes on top, with its hair,
 * eyes, snout, horns, frills, ears and antennae, stretched onto the bigger body like a hat. Tails
 * come off the torso onto the tail bone, wings onto their own piece behind the back, and markings
 * and spines onto the torso like a shirt.
 */
/datum/limb_rig/sprites/humanoid
	/// Wings off the torso, unmasked, stretched onto the body like the shirt is.
	var/obj/effect/abstract/limb_rig_part/wings_part
	/// The head, as the species draws it, on the head's cloth piece.
	var/list/head_images
	/// Markings and spines off the torso, on the torso's cloth piece.
	var/list/chest_marks
	/// The body sprite on each piece, by piece id.
	var/list/skin_images = list()

/datum/limb_rig/sprites/humanoid/build_pieces()
	. = ..()
	wings_part = new_part(RIG_CHEST)
	pivot.vis_contents += wings_part
	// The tail as the species draws it, carried on the tail bone.
	tail_part = new_part(RIG_TAIL)
	hang_on_owner(tail_part)

/datum/limb_rig/sprites/humanoid/add_piece(part_id, obj/effect/abstract/limb_rig_part/container)
	. = ..()
	// The body sprite goes on in refresh_skin(), tinted.
	parts[part_id].cut_overlays()

/datum/limb_rig/sprites/humanoid/Destroy()
	. = ..()
	QDEL_NULL(wings_part)
	head_images = null
	chest_marks = null
	skin_images = null

/datum/limb_rig/sprites/humanoid/set_layer(cache_index, standing)
	. = ..()
	if(cache_index == BODYPARTS_LAYER)
		refresh_species_parts()

/datum/limb_rig/sprites/humanoid/refresh_limbs()
	. = ..()
	refresh_skin()

/// Puts each piece's body sprite on, tinted to its limb.
/datum/limb_rig/sprites/humanoid/proc/refresh_skin()
	var/list/zones = get_rig_piece_zones()
	var/mob/living/carbon/human/human_owner = owner
	var/female = istype(human_owner) && human_owner.physique == FEMALE
	for(var/part_id in zones)
		var/obj/effect/abstract/limb_rig_part/part = parts[part_id]
		part.cut_overlay(skin_images[part_id])
		var/image/skin = image(sprite_icon, (part_id == RIG_CHEST && female) ? "chest_f" : part_id)
		skin.pixel_w = -16
		var/obj/item/bodypart/limb = owner.get_bodypart(zones[part_id])
		skin.color = limb?.get_rig_skin_colour()
		part.add_overlay(skin)
		skin_images[part_id] = skin

/// Takes the head, tail, wings and markings from the species' own limb sprites.
/datum/limb_rig/sprites/humanoid/proc/refresh_species_parts()
	var/obj/effect/abstract/limb_rig_part/head_cloth = cloth_parts[RIG_HEAD]
	var/obj/effect/abstract/limb_rig_part/chest_cloth = cloth_parts[RIG_CHEST]
	head_cloth.cut_overlay(head_images)
	chest_cloth.cut_overlay(chest_marks)
	wings_part.cut_overlays()
	tail_part.cut_overlays()
	head_images = get_limb_images(BODY_ZONE_HEAD)
	head_cloth.add_overlay(head_images)

	chest_marks = list()
	var/list/wings = list()
	var/list/tail = list()
	var/obj/item/bodypart/chest/chest = owner.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return
	for(var/image/overlay as anything in get_limb_images(BODY_ZONE_CHEST))
		var/state = overlay.icon_state
		// The chest sprite itself (and its emissive blocker): the body is drawn instead.
		if(!istext(state) || findtext(state, "[chest.limb_id]_chest") == 1)
			continue
		if(findtext(state, "tail"))
			tail += overlay
		else if(findtext(state, "wing"))
			wings += overlay
		else
			chest_marks += overlay
	chest_cloth.add_overlay(chest_marks)
	wings_part.add_overlay(wings)
	tail_part.add_overlay(tail)

/// The images a limb is drawn with, as the mob last drew it.
/datum/limb_rig/sprites/humanoid/proc/get_limb_images(zone)
	var/key = owner.icon_render_keys[zone]
	var/list/images = key && owner.limb_icon_cache[key]
	return images ? images.Copy() : list()

/datum/limb_rig/sprites/humanoid/refresh_facing()
	. = ..()
	var/facing = owner.dir
	// Behind the back, unless the back is what's seen.
	wings_part.layer = facing == NORTH ? -1 : -8
	tail_part.layer = parts[RIG_TAIL].layer + 0.1
	sort_pieces()

/datum/limb_rig/sprites/humanoid/get_pose_matrices(list/pose, facing)
	. = ..()
	.[wings_part] = matrix(.[cloth_parts[RIG_CHEST]])
	// From where a human's tail joins on to this body's tail bone, then swung with it.
	var/list/root = get_tail_root(facing)
	var/list/bone = skeleton[dir2text(facing)][RIG_TAIL]
	.[tail_part] = rig_joint_matrix(root[1], root[2], hat_scale, 0, bone[1], bone[2], hat_scale) * .[parts[RIG_TAIL]]

/**
 * The colour a limb's skin is, to tint the body with: what the species colours it, or for a limb
 * drawn in its own colours (moths, plasmamen, prosthetics), the average of its sprite.
 */
/obj/item/bodypart/proc/get_rig_skin_colour()
	if(should_draw_greyscale && draw_color)
		return draw_color
	var/sprite_icon = (should_draw_greyscale && icon_greyscale) ? icon_greyscale : icon_static
	var/sprite_state = is_dimorphic ? "[limb_id]_[body_zone]_[limb_gender]" : "[limb_id]_[body_zone]"
	var/static/list/colours = list()
	var/key = "[sprite_icon]-[sprite_state]"
	if(!isnull(colours[key]))
		return colours[key]
	var/icon/sprite = icon(sprite_icon, sprite_state, SOUTH)
	var/red = 0
	var/green = 0
	var/blue = 0
	var/count = 0
	for(var/x in 1 to 32)
		for(var/y in 1 to 32)
			var/pixel = sprite.GetPixel(x, y)
			if(!pixel)
				continue
			var/list/channels = rgb2num(pixel)
			if(length(channels) > 3 && channels[4] < 128)
				continue
			red += channels[1]
			green += channels[2]
			blue += channels[3]
			count++
	// Lighten it a little: the body's shading darkens it again, and averages come out dull.
	colours[key] = count ? rgb(min(red / count * 1.1, 255), min(green / count * 1.1, 255), min(blue / count * 1.1, 255)) : "#ffffff"
	return colours[key]
