/**
 * The Experiment.
 *
 * Dark, furry dog-rat people with big orange eyes, long digitigrade legs, thick thighs and an
 * enormous spiky tail. They're always drawn through the limb rig, built from their own piece
 * sprites (voidcrew/modules/limb_rig/sprite_rig.dm), a head taller than a human and reaching
 * past the tile. Worn clothes are stretched onto them piece by piece.
 */
/datum/species/experiment
	name = "Experiment"
	plural_form = "Experiments"
	id = SPECIES_EXPERIMENT
	sexes = FALSE
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	payday_modifier = 1.0
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/experiment,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/experiment,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/experiment,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/experiment,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/experiment,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/experiment,
	)
	limb_rig_shape = list(
		"always" = TRUE,
		"rig_type" = /datum/limb_rig/sprites/experiment,
		"sprites" = 'voidcrew/modules/expie/icons/rig.dmi',
		"cloth_masks" = 'voidcrew/modules/expie/icons/cloth_masks.dmi',
		// Rest joints, in pixels from the bottom left of the tile, limbs hanging straight down:
		// arms are shoulder, elbow, wrist; legs are hip, knee, hock, sole; crown is the top of the head.
		"skeleton" = list(
			"south" = list("l_arm" = list(list(19.96, 37.04), list(19.85, 31.27), list(19.96, 25.11)), "r_arm" = list(list(12.04, 37.04), list(12.15, 31.27), list(12.04, 25.11)), "l_leg" = list(list(18.56, 25.94), list(18.93, 18.34), list(18.93, 12.14), list(18.78, 0)), "r_leg" = list(list(13.44, 25.94), list(13.07, 18.34), list(13.07, 12.14), list(13.22, 0)), "head" = list(16, 38.31), "crown" = list(16, 52), "chest" = list(16, 25.8), "tail" = list(16, 27.26)),
			"north" = list("l_arm" = list(list(12.04, 37.04), list(12.15, 31.27), list(12.04, 25.11)), "r_arm" = list(list(19.96, 37.04), list(19.85, 31.27), list(19.96, 25.11)), "l_leg" = list(list(13.44, 25.94), list(13.07, 18.34), list(13.07, 12.14), list(13.22, 0)), "r_leg" = list(list(18.56, 25.94), list(18.93, 18.34), list(18.93, 12.14), list(18.78, 0)), "head" = list(16, 38.31), "crown" = list(16, 52), "chest" = list(16, 25.8), "tail" = list(16, 27.26)),
			"east" = list("l_arm" = list(list(15.89, 37.04), list(15.46, 31.27), list(16.05, 25.11)), "r_arm" = list(list(15.89, 37.04), list(15.46, 31.27), list(16.05, 25.11)), "l_leg" = list(list(16, 25.94), list(16, 18.34), list(16, 12.14), list(16, 0)), "r_leg" = list(list(16, 25.94), list(16, 18.34), list(16, 12.14), list(16, 0)), "head" = list(15.7, 38.31), "crown" = list(16, 52), "chest" = list(15.71, 25.8), "tail" = list(12.71, 27.26)),
			"west" = list("l_arm" = list(list(16.11, 37.04), list(16.54, 31.27), list(15.95, 25.11)), "r_arm" = list(list(16.11, 37.04), list(16.54, 31.27), list(15.95, 25.11)), "l_leg" = list(list(16, 25.94), list(16, 18.34), list(16, 12.14), list(16, 0)), "r_leg" = list(list(16, 25.94), list(16, 18.34), list(16, 12.14), list(16, 0)), "head" = list(16.3, 38.31), "crown" = list(16, 52), "chest" = list(16.29, 25.8), "tail" = list(19.29, 27.26)),
		),
		// Digitigrade: thigh forward, knee bent well back, foot forward again, in degrees.
		"leg_rest" = list(27.4, 85.2, 74.3),
		// The head is a good deal bigger than a human's.
		"hat_scale" = 1.4,
		"paw_height" = 4,
		"torso_width" = 1.2,
		// Thick thighs need wide trousers.
		"cloth_widths" = list("thigh" = 2, "shin" = 1.3, "arm" = 1.5, "forearm" = 1),
		// Tail carried a little raised.
		"posture" = list(
			RIG_TAIL = list("lift" = 10),
		),
	)

/datum/species/experiment/get_scream_sound(mob/living/carbon/human/human)
	return 'sound/mobs/non-humanoids/mouse/mousesqueek.ogg'

/datum/species/experiment/get_physical_attributes()
	return "Experiments are lanky, with dark fur, long digitigrade legs, thick thighs, big orange eyes, \
		swept-back ears and a huge spiky tail."

/datum/species/experiment/get_species_description()
	return "A weird dog-rat-person with big orange eyes, long bent legs and a tail nearly as big as \
		the rest of them."

/datum/species/experiment/get_species_lore()
	return list(
		"Nobody remembers signing off on them. Experiments turn up on crew manifests with no birthplace, \
		no next of kin and a lab number where a surname should be, and most of them would rather not talk about it.",

		"They learn fast, eat anything, fit through gaps nobody else would try, and flinch at loud noises. \
		Their tails give away every mood they have.",
	)
