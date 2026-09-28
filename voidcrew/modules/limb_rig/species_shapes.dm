/**
 * Every roundstart species is animated like the Experiment: always rigged, quirk or not. The
 * Overanimated quirk is left for anyone else human-shaped.
 *
 * Tails (lizard, felinid) come out of the body sprite onto their own piece and swing from the
 * small of the back, with every breath and pose. See limb_rig.dm for the keys.
 */

/datum/species/human
	limb_rig_shape = list("always" = TRUE)

/datum/species/human/felinid
	limb_rig_shape = list(
		"always" = TRUE,
		// Tail carried a touch high.
		"posture" = list(RIG_TAIL = list("lift" = 8)),
	)

/datum/species/lizard
	limb_rig_shape = list(
		"always" = TRUE,
		// A slight forward lean, chin up to make up for it, the tail carried up behind.
		"posture" = list(
			RIG_CHEST = list("bend" = 6),
			RIG_HEAD = list("nod" = -5),
			RIG_TAIL = list("lift" = 12),
		),
	)

/datum/species/moth
	limb_rig_shape = list("always" = TRUE)

/datum/species/plasmaman
	limb_rig_shape = list("always" = TRUE)

/datum/species/ethereal
	limb_rig_shape = list("always" = TRUE)
