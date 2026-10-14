// Unicorns hold items in a telekinetic glow that floats beside them instead of in hooves

/mob/living/carbon/human
	var/obj/effect/abstract/held_tk_effect/left/held_left
	var/obj/effect/abstract/held_tk_effect/right/held_right

/obj/effect/abstract/held_tk_effect
	name = "held_tk_effect"
	icon = 'voidcrew/modules/ponies/icons/bodyparts.dmi'
	icon_state = "holder"
	layer = HANDS_LAYER
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	var/is_right = TRUE
	var/list/base_x
	var/list/base_y

/obj/effect/abstract/held_tk_effect/proc/on_parent_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	set_direction_facing(new_dir)

/obj/effect/abstract/held_tk_effect/proc/set_direction_facing(new_dir)
	if(!base_x || !base_y)
		return
	var/current_dir = dir2text(new_dir)
	pixel_w = (current_dir in base_x) ? base_x[current_dir] : base_x["south"]
	pixel_z = ((current_dir in base_y) ? base_y[current_dir] : base_y["south"]) + 10
	switch(new_dir)
		if(NORTH)
			pixel_w += is_right ? 5 : -5
		if(SOUTH)
			pixel_w += is_right ? -5 : 5

/obj/effect/abstract/held_tk_effect/right
	is_right = TRUE

/obj/effect/abstract/held_tk_effect/left
	is_right = FALSE

/mob/living/carbon/human/Destroy()
	QDEL_NULL(held_left)
	QDEL_NULL(held_right)
	return ..()

/// Empties both floating holders before held items are redrawn
/mob/living/carbon/human/proc/clear_floating_held()
	held_left?.overlays.Cut()
	held_left?.underlays.Cut()
	held_right?.overlays.Cut()
	held_right?.underlays.Cut()

/// Puts a held item's overlay into the floating holder for its hand and returns the overlay that renders the holder
/mob/living/carbon/human/proc/float_held_item(mutable_appearance/hand_overlay, held_index, obj/item/bodypart/arm/held_in_hand)
	var/right = IS_RIGHT_INDEX(held_index)
	var/obj/effect/abstract/held_tk_effect/holder = right ? held_right : held_left
	if(!holder)
		holder = right ? new /obj/effect/abstract/held_tk_effect/right(src) : new /obj/effect/abstract/held_tk_effect/left(src)
		holder.render_target = "*[REF(src)]_hover_[right ? "right" : "left"]"
		holder.RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, TYPE_PROC_REF(/obj/effect/abstract/held_tk_effect, on_parent_dir_change))
		vis_contents += holder
		if(right)
			held_right = holder
		else
			held_left = holder
	holder.overlays.Cut()
	holder.underlays.Cut()
	holder.overlays += hand_overlay
	var/mutable_appearance/hover_effect = mutable_appearance(holder.icon, "hover_[right ? "right" : "left"]", HANDS_LAYER)
	hover_effect.color = dna.features[FEATURE_PONY_TK_COLOR] || "#FF99FF"
	holder.underlays += hover_effect
	var/datum/worn_feature_offset/hand_offset = held_in_hand?.held_hand_offset
	holder.base_x = hand_offset?.offset_x || list("south" = 0)
	holder.base_y = hand_offset?.offset_y || list("south" = 0)
	holder.set_direction_facing(dir)
	animate(holder, pixel_z = 2, time = 1 SECONDS, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_z = -2, time = 1 SECONDS, flags = ANIMATION_RELATIVE)
	var/mutable_appearance/rendered = mutable_appearance(layer = HANDS_LAYER, offset_spokesman = src)
	rendered.render_source = holder.render_target
	return rendered
