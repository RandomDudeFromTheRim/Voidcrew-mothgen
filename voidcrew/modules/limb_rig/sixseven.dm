/**
 * *67
 *
 * The "6-7" gesture: both palms up, hands bobbing up and down in turns like they're weighing
 * something, while you say six seven. A 6 and a 7 float over the hands and bob along. An
 * Overanimated mob works its arms too (see get_rig_emote()).
 */
/datum/emote/living/carbon/sixseven
	key = "67"
	key_third_person = "67s"
	message = "goes six seven."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	hands_use_check = TRUE
	cooldown = 2 SECONDS

/datum/emote/living/carbon/sixseven/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/mob/living/carbon/carbon_user = user
	if(istype(carbon_user))
		carbon_user.show_sixseven()

/// Same thing, spelled out.
/datum/emote/living/carbon/sixseven/spelled
	key = "sixseven"
	key_third_person = "sixsevens"

/// How long the numbers stay up, matching the arm animation.
#define SIXSEVEN_DURATION (1.2 SECONDS)
/// One bob of a hand, up or down.
#define SIXSEVEN_BOB (1.5)

/// A floating digit for *67.
/obj/effect/abstract/sixseven
	name = ""
	appearance_flags = RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM|PIXEL_SCALE|KEEP_APART
	layer = ABOVE_MOB_LAYER
	maptext_width = 16
	maptext_height = 16

/// Floats a 6 over one hand and a 7 over the other, bobbing out of step, then clears them.
/// They ride in the mob's vis_contents on the balloon chat plane, so they follow the mob and
/// nothing on the map hides them.
/mob/living/carbon/proc/show_sixseven()
	var/list/numbers = list()
	for(var/digit in list("6", "7"))
		var/obj/effect/abstract/sixseven/number = new(null)
		SET_PLANE_EXPLICIT(number, BALLOON_CHAT_PLANE, src)
		number.maptext = MAPTEXT("<span style='font-size: 12px; color: [digit == "6" ? "#ffd84a" : "#7ae0ff"]; -dm-text-outline: 1px #000'>[digit]</span>")
		// Read left to right: the 6 over the hand on the left of the screen, the 7 on the right.
		number.pixel_w = digit == "6" ? 3 : 21
		// Maptext sits at the top of its box, so this puts the digit just over the hands.
		number.pixel_z = 10
		number.alpha = 0
		vis_contents += number
		numbers += number
		// Out of step: when one goes up, the other goes down.
		var/start_up = digit == "6"
		animate(number, alpha = 255, time = 1)
		for(var/bob in 1 to round(SIXSEVEN_DURATION / SIXSEVEN_BOB))
			var/up = (bob % 2) ? start_up : !start_up
			animate(pixel_z = up ? 13 : 8, time = SIXSEVEN_BOB, easing = SINE_EASING)
		animate(alpha = 0, time = 2)
	addtimer(CALLBACK(src, PROC_REF(clear_sixseven), numbers), SIXSEVEN_DURATION + 0.3 SECONDS)

/mob/living/carbon/proc/clear_sixseven(list/numbers)
	vis_contents -= numbers
	QDEL_LIST(numbers)

#undef SIXSEVEN_DURATION
#undef SIXSEVEN_BOB
