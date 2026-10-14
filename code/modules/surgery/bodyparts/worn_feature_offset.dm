/// A datum for controlling how to position items on an unusually offset body part
/// For instance if you have an asymmetrical head, hats might need to be offset to one side
/datum/worn_feature_offset
	/// Owner of mob we are attached to, could be null on a severed limb
	var/mob/living/carbon/owner
	/// What are we attached to
	var/obj/item/bodypart/attached_part
	/// Key used to identify what this offset applies to
	var/feature_key
	/// Offsets to apply on the x axis for each direction
	var/list/offset_x
	/// Offsets to apply on the y axis for each direction
	var/list/offset_y
	// VOIDCREW EDIT ADDITION START - Ponies
	/// Size modifier to apply for each direction.
	var/list/size_modifier
	/// Rotation modifier to apply for each direction.
	var/list/rotation_modifier
	/// Should we call an update body parts when we offset? Makes hair rotate.
	var/update_body_parts = FALSE
	// VOIDCREW EDIT ADDITION END

/datum/worn_feature_offset/New(
	obj/item/bodypart/attached_part,
	feature_key = null, // VOIDCREW EDIT CHANGE - Ponies - ORIGINAL: feature_key,
	list/offset_x = list("south" = 0),
	list/offset_y = list("south" = 0),
	// VOIDCREW EDIT ADDITION START - Ponies
	list/size_modifier = list("south" = 1),
	list/rotation_modifier = list("south" = 0),
	update_body_parts = FALSE
	// VOIDCREW EDIT ADDITION END
)
	attached_part.feature_offsets[feature_key] = src
	owner = attached_part.owner
	src.attached_part = attached_part
	src.feature_key = feature_key
	src.offset_x = offset_x
	src.offset_y = offset_y
	// VOIDCREW EDIT ADDITION START - Ponies
	src.size_modifier = size_modifier
	src.rotation_modifier = rotation_modifier
	src.update_body_parts = update_body_parts
	// VOIDCREW EDIT ADDITION END

	if (length(offset_x) <= 1 && length(offset_y) <= 1 && length(size_modifier) <= 1 && length(rotation_modifier) <= 1) // VOIDCREW EDIT CHANGE - Ponies - ORIGINAL: if (length(offset_x) <= 1 && length(offset_y) <= 1)
		return // We don't need to do any extra signal handling

	if (!isnull(owner))
		changed_owner(src, owner) // VOIDCREW EDIT CHANGE - Ponies - ORIGINAL: changed_owner(owner)
	RegisterSignal(attached_part, COMSIG_BODYPART_CHANGED_OWNER, PROC_REF(changed_owner))

/// Returns the current offset which should be used for this feature
/datum/worn_feature_offset/proc/get_offset()
	var/current_dir = owner ? owner.dir : SOUTH
	current_dir = dir2text(current_dir)
	var/x = length(offset_x) ? ((current_dir in offset_x) ? offset_x[current_dir] : offset_x["south"]) : 0
	var/y = length(offset_y) ? ((current_dir in offset_y) ? offset_y[current_dir] : offset_y["south"]) : 0
	// VOIDCREW EDIT CHANGE START - Ponies
	var/size = length(size_modifier) ? ((current_dir in size_modifier) ? size_modifier[current_dir] : size_modifier["south"]) : 1
	var/rotation = length(rotation_modifier) ? ((current_dir in rotation_modifier) ? rotation_modifier[current_dir] : rotation_modifier["south"]) : 0
	return list("x" = x, "y" = y, "size" = size, "rotation" = rotation)
	// VOIDCREW EDIT CHANGE END

/// Applies the current offset to a provided overlay image
/datum/worn_feature_offset/proc/apply_offset(image/overlay)
	var/list/offset = get_offset()
	// VOIDCREW EDIT ADDITION START - Ponies
	if(offset["size"] != 1 || offset["rotation"] != 0)
		overlay.appearance_flags |= PIXEL_SCALE
		var/matrix/new_matrix = matrix(overlay.transform)
		new_matrix.Scale(offset["size"])
		new_matrix.Turn(offset["rotation"])
		overlay.transform = new_matrix
	// VOIDCREW EDIT ADDITION END

	overlay.pixel_w += offset["x"]
	overlay.pixel_z += offset["y"]

/// When the owner of the bodypart changes, update our signal registrations
/datum/worn_feature_offset/proc/changed_owner(obj/item/bodypart/part, mob/living/new_owner, mob/living/old_owner)
	SIGNAL_HANDLER
	owner = new_owner
	if (!isnull(old_owner))
		UnregisterSignal(old_owner, COMSIG_ATOM_POST_DIR_CHANGE)
	if (!isnull(new_owner))
		RegisterSignal(new_owner, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(on_dir_change))
		RegisterSignal(new_owner, COMSIG_QDELETING, PROC_REF(on_owner_deleted))
		// VOIDCREW EDIT ADDITION START - Ponies
		if(ishuman(new_owner))
			var/mob/living/carbon/human/new_human = new_owner
			new_human.update_features(feature_key)
		// VOIDCREW EDIT ADDITION END

/// If the owner is deleted, stop updating
/datum/worn_feature_offset/proc/on_owner_deleted(mob/living/host)
	SIGNAL_HANDLER
	owner = null

/// When we change direction, re-apply the offset
/datum/worn_feature_offset/proc/on_dir_change(mob/living/carbon/owner, olddir, newdir)
	SIGNAL_HANDLER
	if(olddir != newdir)
		// VOIDCREW EDIT CHANGE START - Ponies
		if(ishuman(owner))
			var/mob/living/carbon/human/new_human = owner
			new_human.update_features(feature_key)
		// VOIDCREW EDIT CHANGE END
