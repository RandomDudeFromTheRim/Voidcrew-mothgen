/**
 * *67
 *
 * The "6-7" gesture: both palms up, hands bobbing up and down in turns like they're weighing
 * something, while you say six seven. A 6 and a 7 float over the hands and bob along. A rigged
 * mob works its arms too (see get_rig_emote()).
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

/// Floats a 6 over one hand and a 7 over the other, bobbing out of step, then clears them.
/// Drawn like balloon alerts: client images on the balloon chat plane, so nothing on the map hides them.
/mob/living/carbon/proc/show_sixseven()
	var/list/viewing_clients = list()
	for(var/mob/viewer as anything in viewers(world.view, src))
		if(viewer.client)
			viewing_clients += viewer.client
	if(!length(viewing_clients))
		return
	for(var/digit in list("6", "7"))
		var/image/number = image(loc = isturf(loc) ? src : get_atom_on_turf(src), layer = ABOVE_MOB_LAYER)
		SET_PLANE_EXPLICIT(number, BALLOON_CHAT_PLANE, src)
		number.appearance_flags = RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM|PIXEL_SCALE
		number.maptext = MAPTEXT("<span style='font-size: 12px; color: [digit == "6" ? "#ffd84a" : "#7ae0ff"]; -dm-text-outline: 1px #000'>[digit]</span>")
		number.maptext_width = 16
		number.maptext_height = 16
		// Read left to right: the 6 over the hand on the left of the screen, the 7 on the right.
		number.pixel_w = digit == "6" ? 3 : 21
		// Maptext sits at the top of its box, so this puts the digit just over the hands.
		number.pixel_z = 10
		number.alpha = 0
		// Out of step: when one goes up, the other goes down.
		var/start_up = digit == "6"
		animate(number, alpha = 255, time = 1)
		for(var/bob in 1 to round(SIXSEVEN_DURATION / SIXSEVEN_BOB))
			var/up = (bob % 2) ? start_up : !start_up
			animate(pixel_z = up ? 13 : 8, time = SIXSEVEN_BOB, easing = SINE_EASING)
		animate(alpha = 0, time = 2)
		flick_overlay_global(number, viewing_clients, SIXSEVEN_DURATION + 0.3 SECONDS)

#undef SIXSEVEN_DURATION
#undef SIXSEVEN_BOB
