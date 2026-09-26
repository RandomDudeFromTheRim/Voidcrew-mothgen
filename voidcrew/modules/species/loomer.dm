/**
 * Loomers.
 *
 * Human underneath, drawn by the limb rig with arms three times and legs four and a half times
 * the length of anyone else's, fingers to match, a permanent stoop so they still fit through a doorway, and a
 * long loping walk. Loosely after the Serverblight and DOORS' Figure, minus the blindness:
 * they see perfectly well. It's all looks; they play exactly like humans.
 */
/datum/species/human/loomer
	name = "Loomer"
	id = SPECIES_LOOMER
	examine_limb_id = SPECIES_HUMAN
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	limb_rig_shape = list(
		"arm_stretch" = 3.2,
		"leg_stretch" = 4.5,
		"finger_stretch" = 3,
		"walk" = RIG_WALK_LOPE,
		// Stooped: back bent, head craned up to see where it's going, arms hanging out in
		// front, knees never quite straight.
		"posture" = list(
			RIG_CHEST = list("bend" = 40),
			RIG_HEAD = list("nod" = -30),
			RIG_L_ARM = list("swing" = 18, "raise" = 6, "elbow" = 20),
			RIG_R_ARM = list("swing" = 18, "raise" = 6, "elbow" = 20),
			RIG_L_LEG = list("swing" = 10, "knee" = 22),
			RIG_R_LEG = list("swing" = 10, "knee" = 22),
		),
	)

/datum/species/human/loomer/get_species_description()
	return "Loomers are people with far too much arm and leg. They stoop to fit through \
		doors, lope instead of walk, and can reach the top shelf from the floor."

/datum/species/human/loomer/get_species_lore()
	return list(
		"Nobody agrees on where Loomers came from. The popular story is a colony ship that \
			spent a few generations in low gravity; the unpopular one involves a gene clinic \
			with a decimal point in the wrong place.",
		"Either way, they're otherwise ordinary people, and most of them are tired of being \
			asked to change lightbulbs.",
	)

/datum/species/human/loomer/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "body",
			SPECIES_PERK_NAME = "All Limbs",
			SPECIES_PERK_DESC = "Legs four times as long as a human's, arms three times, long fingers, and a permanent stoop. Purely cosmetic.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "shoe-prints",
			SPECIES_PERK_NAME = "Loping Gait",
			SPECIES_PERK_DESC = "Walks with long, high-kneed strides. Moves at the same speed as anyone else.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Eyes Included",
			SPECIES_PERK_DESC = "Despite appearances, Loomers see just as well as humans do.",
		),
	)
