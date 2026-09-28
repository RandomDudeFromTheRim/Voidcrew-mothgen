/**
 * Every roundstart species is animated like the Experiment: always rigged, on a generated body a
 * quarter bigger than a human with their own head on top (see humanoid_rig.dm). The Overanimated
 * quirk is left for anyone else human-shaped.
 *
 * Tails (lizard, felinid) come off the torso onto the tail bone and swing from the small of the
 * back, with every breath and pose. See limb_rig.dm for the keys.
 */

/// The generated body: its sprites, bones, and how clothes are stretched onto it.
#define HUMANOID_RIG_BODY \
	"always" = TRUE, \
	"rig_type" = /datum/limb_rig/sprites/humanoid, \
	"sprites" = 'voidcrew/modules/limb_rig/icons/humanoid.dmi', \
	"cloth_masks" = 'voidcrew/modules/expie/icons/cloth_masks.dmi', \
	"skeleton" = list( \
		"south" = list("l_arm" = list(list(21.3, 24.4), list(21.41, 18.9), list(21.3, 13.6)), "r_arm" = list(list(10.7, 24.4), list(10.59, 18.9), list(10.7, 13.6)), "l_leg" = list(list(18.35, 14.6), list(18.35, 8.2), list(18.35, 2.2), list(18.35, 0)), "r_leg" = list(list(13.65, 14.6), list(13.65, 8.2), list(13.65, 2.2), list(13.65, 0)), "head" = list(16, 26.6), "crown" = list(16, 35.6), "chest" = list(16, 14.0), "tail" = list(16, 15.2)), \
		"north" = list("l_arm" = list(list(10.7, 24.4), list(10.59, 18.9), list(10.7, 13.6)), "r_arm" = list(list(21.3, 24.4), list(21.41, 18.9), list(21.3, 13.6)), "l_leg" = list(list(13.65, 14.6), list(13.65, 8.2), list(13.65, 2.2), list(13.65, 0)), "r_leg" = list(list(18.35, 14.6), list(18.35, 8.2), list(18.35, 2.2), list(18.35, 0)), "head" = list(16, 26.6), "crown" = list(16, 35.6), "chest" = list(16, 14.0), "tail" = list(16, 15.2)), \
		"east" = list("l_arm" = list(list(15.8, 24.4), list(15.8, 18.9), list(16.0, 13.6)), "r_arm" = list(list(15.8, 24.4), list(15.8, 18.9), list(16.0, 13.6)), "l_leg" = list(list(16, 14.6), list(16.15, 8.2), list(15.9, 2.2), list(15.9, 0)), "r_leg" = list(list(16, 14.6), list(16.15, 8.2), list(15.9, 2.2), list(15.9, 0)), "head" = list(16.3, 26.6), "crown" = list(16.3, 35.6), "chest" = list(16, 14.0), "tail" = list(13.8, 15.2)), \
		"west" = list("l_arm" = list(list(16.2, 24.4), list(16.2, 18.9), list(16.0, 13.6)), "r_arm" = list(list(16.2, 24.4), list(16.2, 18.9), list(16.0, 13.6)), "l_leg" = list(list(16, 14.6), list(15.85, 8.2), list(16.1, 2.2), list(16.1, 0)), "r_leg" = list(list(16, 14.6), list(15.85, 8.2), list(16.1, 2.2), list(16.1, 0)), "head" = list(15.7, 26.6), "crown" = list(15.7, 35.6), "chest" = list(16, 14.0), "tail" = list(18.2, 15.2)), \
	), \
	"leg_rest" = list(2, 4, 2), \
	"hat_scale" = 1.25, \
	"paw_height" = 2.8, \
	"torso_width" = 1.2, \
	"cloth_widths" = list("thigh" = 1.3, "shin" = 1.2, "arm" = 1.25, "forearm" = 1.2)

/datum/species/human
	limb_rig_shape = list(HUMANOID_RIG_BODY)

/datum/species/human/felinid
	limb_rig_shape = list(
		HUMANOID_RIG_BODY,
		// Tail carried a touch high.
		"posture" = list(RIG_TAIL = list("lift" = 8)),
	)

/datum/species/lizard
	limb_rig_shape = list(
		HUMANOID_RIG_BODY,
		// A slight forward lean, chin up to make up for it, the tail carried up behind.
		"posture" = list(
			RIG_CHEST = list("bend" = 6),
			RIG_HEAD = list("nod" = -5),
			RIG_TAIL = list("lift" = 12),
		),
	)

/datum/species/moth
	limb_rig_shape = list(HUMANOID_RIG_BODY)

/datum/species/plasmaman
	limb_rig_shape = list(HUMANOID_RIG_BODY)

/datum/species/ethereal
	limb_rig_shape = list(HUMANOID_RIG_BODY)

#undef HUMANOID_RIG_BODY
