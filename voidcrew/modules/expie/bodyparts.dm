#define EXPIE_BODYPARTS 'voidcrew/modules/expie/icons/bodyparts.dmi'
#define EXPIE_TAIL 'voidcrew/modules/expie/icons/tail.dmi'

/obj/item/bodypart/head/experiment
	icon = EXPIE_BODYPARTS
	icon_static = EXPIE_BODYPARTS
	limb_id = SPECIES_EXPERIMENT
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	// No hair, and the eyes are drawn into the head.
	head_flags = HEAD_DEBRAIN

/obj/item/bodypart/chest/experiment
	icon = EXPIE_BODYPARTS
	icon_static = EXPIE_BODYPARTS
	limb_id = SPECIES_EXPERIMENT
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/// The tail rides on the chest: behind the body, except seen from behind, where it's in front.
/// The limb rig lifts it off onto its own piece so it can wag (see limb_rig.dm).
/obj/item/bodypart/chest/experiment/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	if(is_invisible)
		return
	for(var/state in list("tail_behind", "tail_front"))
		var/image/tail = image(EXPIE_TAIL, state, state == "tail_front" ? -BODY_FRONT_LAYER : -BODY_BEHIND_LAYER)
		// The tail icon is 64 wide, with the tile's left edge 16 pixels in.
		tail.pixel_w = -16
		if(is_husked)
			tail.color = husk_color
		. += tail

/obj/item/bodypart/arm/left/experiment
	icon = EXPIE_BODYPARTS
	icon_static = EXPIE_BODYPARTS
	limb_id = SPECIES_EXPERIMENT
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/experiment
	icon = EXPIE_BODYPARTS
	icon_static = EXPIE_BODYPARTS
	limb_id = SPECIES_EXPERIMENT
	should_draw_greyscale = FALSE

// Digitigrade legs, like a lizard's: clothes with a digitigrade sprite use it, and anything
// worn without one squashes the leg straight.
/obj/item/bodypart/leg/left/digitigrade/experiment
	icon = EXPIE_BODYPARTS
	icon_static = EXPIE_BODYPARTS
	limb_id = BODYPART_ID_EXPERIMENT_DIGITIGRADE
	should_draw_greyscale = FALSE
	footprint_sprite = FOOTPRINT_SPRITE_PAWS

/obj/item/bodypart/leg/left/digitigrade/experiment/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? SPECIES_EXPERIMENT : BODYPART_ID_EXPERIMENT_DIGITIGRADE

/obj/item/bodypart/leg/right/digitigrade/experiment
	icon = EXPIE_BODYPARTS
	icon_static = EXPIE_BODYPARTS
	limb_id = BODYPART_ID_EXPERIMENT_DIGITIGRADE
	should_draw_greyscale = FALSE
	footprint_sprite = FOOTPRINT_SPRITE_PAWS

/obj/item/bodypart/leg/right/digitigrade/experiment/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? SPECIES_EXPERIMENT : BODYPART_ID_EXPERIMENT_DIGITIGRADE

#undef EXPIE_BODYPARTS
#undef EXPIE_TAIL
