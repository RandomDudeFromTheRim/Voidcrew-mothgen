/**
 * *skibidi: for a chorus of the song, the body's gone and there's a toilet, and their head comes up out
 * of it on a long neck, grinning far too wide, bobbing to the beat, twitching, and turning about.
 * Then it's all as it was.
 *
 * The body's masked away below the neck (gags_mask.dmi) and the head drawn twice the size, as
 * the meme's heads are; the face over it is drawn at that size too (gags_face.dmi), so it gets
 * every pixel of its grin.
 */
/datum/emote/living/carbon/human/skibidi
	key = "skibidi"
	key_third_person = "skibidis"
	message = "goes skibidi."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 15 SECONDS

/datum/emote/living/carbon/human/skibidi/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	var/mob/living/carbon/human/human_user = user
	if(!istype(human_user) || human_user.current_gag || human_user.body_position == LYING_DOWN || human_user.buckled || !isturf(human_user.loc) || !human_user.get_bodypart(BODY_ZONE_HEAD))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/skibidi/run_emote(mob/user, params, type_override, intentional = FALSE)
	. = ..()
	new /datum/gag/skibidi(user)

/// How long the song is, and how far apart its beats are.
#define SKIBIDI_LENGTH (11.4 SECONDS)
#define SKIBIDI_BEAT 3
/// The bottom of the toilet's bowl, where the neck comes out, in pixels up its sprite.
#define SKIBIDI_BOWL 12
/// How far the head's raised (pixels) sunk in the bowl, and out at the top of the neck.
#define SKIBIDI_SUNK -14
#define SKIBIDI_OUT 10

/datum/gag/skibidi
	var/obj/effect/abstract/skibidi_part/toilet
	var/obj/effect/abstract/skibidi_part/neck
	var/mutable_appearance/face

/obj/effect/abstract/skibidi_part
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet10"
	layer = MOB_LAYER - 0.02
	appearance_flags = PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/gag/skibidi/act()
	playsound(victim, 'voidcrew/modules/gags/sound/skibidi.ogg', 75, FALSE)
	toilet = new(get_turf(victim))
	neck = new(get_turf(victim))
	neck.icon = 'icons/effects/alphacolors.dmi'
	neck.icon_state = "white"
	neck.layer = MOB_LAYER - 0.01
	var/obj/item/bodypart/head/head = victim.get_bodypart(BODY_ZONE_HEAD)
	neck.color = head?.draw_color || "#d9b98c"
	victim.add_filter("gag_skibidi", 1, alpha_mask_filter(icon = icon('voidcrew/modules/gags/icons/gags_mask.dmi', "head_only")))
	face = mutable_appearance('voidcrew/modules/gags/icons/gags_face.dmi', "skibidi", MOB_LAYER + 0.1)
	// Drawn at twice the size, like the head under it: halved, then doubled with the rest of them.
	face.pixel_w = -16
	face.pixel_z = -16
	face.transform = matrix() * 0.5
	victim.add_overlay(face)
	victim.setDir(SOUTH)
	raise(SKIBIDI_SUNK, 0, 0)
	raise(SKIBIDI_OUT, 0, 6)
	var/beat = 0
	var/static/list/turning = list(SOUTH, WEST, NORTH, EAST)
	while(world.time < started + SKIBIDI_LENGTH - 8)
		GAG_AT(6 + beat * SKIBIDI_BEAT)
		beat++
		// Up and down with the beat, never still, and about every bar.
		raise(beat % 2 ? SKIBIDI_OUT + 5 : SKIBIDI_OUT - 2, rand(-7, 7), SKIBIDI_BEAT)
		if(beat % 4 == 0)
			victim.setDir(turning[(beat / 4) % 4 + 1])
	raise(SKIBIDI_SUNK, 0, 5)
	GAG_AT(SKIBIDI_LENGTH)
	qdel(src)

/// Puts the head this many pixels up the neck, tilted a little, over this long; the neck with it.
/datum/gag/skibidi/proc/raise(rise, tilt, time)
	var/matrix/head = matrix(old_transform)
	head.Scale(2)
	head.Turn(tilt)
	head.Translate(rand(-1, 1), rise)
	animate(victim, transform = head, time = time, easing = SINE_EASING)
	// From the bowl to the bottom of the head (21 pixels up the sprite, twice as far from its middle).
	var/neck_length = max(16 + (21 - 16) * 2 + rise - SKIBIDI_BOWL + 2, 1)
	var/matrix/stretched = matrix()
	stretched.Scale(8 / 32, neck_length / 32)
	stretched.Translate(0, SKIBIDI_BOWL - (16 - neck_length / 2))
	animate(neck, transform = stretched, time = time, easing = SINE_EASING)

/datum/gag/skibidi/Destroy()
	if(victim)
		victim.remove_filter("gag_skibidi")
		victim.cut_overlay(face)
	QDEL_NULL(toilet)
	QDEL_NULL(neck)
	return ..()

#undef SKIBIDI_LENGTH
#undef SKIBIDI_BEAT
#undef SKIBIDI_BOWL
#undef SKIBIDI_SUNK
#undef SKIBIDI_OUT
