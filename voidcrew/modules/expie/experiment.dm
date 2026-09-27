/**
 * The Experiment.
 *
 * Small, dark, dog-rat people with a crest of swept-back spikes, big orange eyes and an
 * enormous spiky tail. They're always drawn through the limb rig (voidcrew/modules/limb_rig):
 * the sprites are laid out like a human's so every piece of clothing still fits, and the rig
 * shortens the legs and arms to make them small, and wags the tail.
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
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/experiment,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/experiment,
	)
	limb_rig_shape = list(
		"always" = TRUE,
		"leg_stretch" = 0.75,
		"arm_stretch" = 0.9,
		"masks" = 'voidcrew/modules/expie/icons/rig_masks.dmi',
		"tail" = list(
			"icon" = 'voidcrew/modules/expie/icons/tail.dmi',
			// Where the tail joins the body, by dir2text() of the facing, in pixels from the bottom left.
			"root" = list("north" = list(16, 10), "south" = list(16, 11), "east" = list(13, 12), "west" = list(18, 12)),
		),
		// Carried high, bent a little forward.
		"posture" = list(
			RIG_TAIL = list("lift" = 20),
			RIG_CHEST = list("bend" = 4),
		),
	)

/datum/species/experiment/get_scream_sound(mob/living/carbon/human/human)
	return 'sound/mobs/non-humanoids/mouse/mousesqueek.ogg'

/datum/species/experiment/get_physical_attributes()
	return "Experiments are short and slight, with dark fur, digitigrade legs, big orange eyes, a crest of \
		soft spikes sweeping back off the head and a huge spiky tail."

/datum/species/experiment/get_species_description()
	return "A short-statured, weird dog-rat-person with a crest of spikes down the back of the head \
		and a tail bigger than the rest of them."

/datum/species/experiment/get_species_lore()
	return list(
		"Nobody remembers signing off on them. Experiments turn up on crew manifests with no birthplace, \
		no next of kin and a lab number where a surname should be, and most of them would rather not talk about it.",

		"They learn fast, eat anything, fit through gaps nobody else would try, and flinch at loud noises. \
		Their tails give away every mood they have.",
	)
