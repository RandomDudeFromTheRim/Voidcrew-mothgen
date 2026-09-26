/**
 * Loomer.
 *
 * A quirk any species can take: the limb rig draws you with legs four and a half times their
 * length, arms three times, long fingers, a permanent stoop so you still fit through doors,
 * and a long loping walk. In combat mode with your hands empty you reach out, arms straight,
 * fingers creeping longer, trembling all over.
 *
 * Loosely after the Serverblight and DOORS' Figure, minus the blindness: you see fine. It's
 * all looks; nothing about how you play changes.
 */
GLOBAL_LIST_INIT(loomer_rig_shape, list(
	"arm_stretch" = 3.2,
	"leg_stretch" = 4.5,
	"finger_stretch" = 3,
	"walk" = RIG_WALK_LOPE,
	"menace" = TRUE,
	// Stooped: back bent, head craned up to see where it's going, arms hanging out in front,
	// knees never quite straight.
	"posture" = list(
		RIG_CHEST = list("bend" = 40),
		RIG_HEAD = list("nod" = -30),
		RIG_L_ARM = list("swing" = 18, "raise" = 6, "elbow" = 20),
		RIG_R_ARM = list("swing" = 18, "raise" = 6, "elbow" = 20),
		RIG_L_LEG = list("swing" = 10, "knee" = 22),
		RIG_R_LEG = list("swing" = 10, "knee" = 22),
	),
))

/datum/quirk/loomer
	name = "Loomer"
	desc = "You have far too much arm and leg. You stoop to fit through doors, lope instead of walking, \
		and reach out with long, twitching fingers when you square up empty-handed. Purely cosmetic."
	icon = FA_ICON_RULER_VERTICAL
	value = 0
	gain_text = span_notice("You feel very, very tall.")
	lose_text = span_notice("Your limbs settle back to a sensible length.")
	medical_record_text = "Patient's limbs are several times longer than expected. Patient has asked us to stop measuring."

/datum/quirk/loomer/add(client/client_source)
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		carbon_holder.update_limb_rig()

/datum/quirk/loomer/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(istype(carbon_holder))
		// The quirk is still listed while this runs, so check again once it's gone.
		addtimer(CALLBACK(carbon_holder, TYPE_PROC_REF(/mob/living/carbon, update_limb_rig)), 0.1 SECONDS, TIMER_UNIQUE)
