/**
 * Faces in a rhythm battle: while someone sings, their head (side-on, the way singers face each
 * other) pulls faces with the song. An open mouth for every note, shaped for which one; a wince on
 * a miss; a grin for a hey; blinking in between. Seen from the front or back, the head is as it
 * always is.
 *
 * Faces are drawn in the head's own pixels, over its own sprite, in pure black: solid black eyes,
 * as Funkin' draws most people, or white ones in a black rim for the characters drawn that way
 * (Pico and his crowd), or Daddy and Mommy Dearest's red glare. Experiments keep their own orange
 * eyes. Each face covers the head's own eye pixel with the head's own shade, tinted to its skin,
 * so a squint or a blink hides it. Nothing's drawn under a mask or helmet that covers the face,
 * and plasmamen, all skull, go without.
 */

/mob/living/carbon
	/// Which eyes this singer's face has in a rhythm battle, if not solid black: "white" or "demon".
	var/fnf_face_eyes

/datum/limb_rig
	/// The face being pulled, while a rhythm battle has one on.
	var/fnf_face
	/// Turns the face back to idle once a note's pose is over.
	var/fnf_face_timer
	/// The images drawn on the head for it.
	var/list/fnf_face_images

/**
 * Pulls a face: one of "idle" (blinking), "left", "down", "up", "right", "miss", "hey" or "dead".
 * With a duration, it goes back to idle after it.
 */
/datum/limb_rig/proc/set_fnf_face(expression, duration)
	deltimer(fnf_face_timer)
	fnf_face_timer = null
	fnf_face = expression
	if(duration)
		fnf_face_timer = addtimer(CALLBACK(src, PROC_REF(set_fnf_face), "idle"), duration, TIMER_STOPPABLE|TIMER_DELETE_ME)
	refresh_fnf_face()

/// Stops pulling faces.
/datum/limb_rig/proc/clear_fnf_face()
	deltimer(fnf_face_timer)
	fnf_face_timer = null
	fnf_face = null
	refresh_fnf_face()

/// Whether a face is being held (a note, a miss) rather than idling.
/datum/limb_rig/proc/is_pulling_fnf_face()
	return !!fnf_face_timer

/datum/limb_rig/proc/refresh_fnf_face()
	var/atom/movable/holder = get_fnf_face_holder()
	holder?.cut_overlay(fnf_face_images)
	fnf_face_images = null
	if(!fnf_face || !holder || !can_show_fnf_face())
		return
	fnf_face_images = get_fnf_face_images(fnf_face)
	holder.add_overlay(fnf_face_images)

/// The piece the head's drawn on.
/datum/limb_rig/proc/get_fnf_face_holder()
	return null

/// The images for a face, bottom first.
/datum/limb_rig/proc/get_fnf_face_images(expression)
	return list()

/// Whether the face can be seen at all: there's a head, and nothing hides it.
/datum/limb_rig/proc/can_show_fnf_face()
	if(!owner.get_bodypart(BODY_ZONE_HEAD))
		return FALSE
	for(var/obj/item/worn as anything in list(owner.wear_mask, owner.head))
		if(worn && (worn.flags_inv & HIDEFACE))
			return FALSE
	return TRUE

// The Experiment's own head.

/datum/limb_rig/sprites/get_fnf_face_holder()
	return parts[RIG_HEAD]

/datum/limb_rig/sprites/get_fnf_face_images(expression)
	if(sprite_icon != 'voidcrew/modules/expie/icons/rig.dmi')
		return list()
	var/image/face = image('voidcrew/modules/fnf/icons/fnf_faces_experiment.dmi', "experiment_[expression]")
	// Its sprites are 64 wide, drawn from 16 pixels left of the piece.
	face.pixel_w = -16
	face.layer = FLOAT_LAYER
	return list(face)

// Everyone else's heads, as tg draws them.

/datum/limb_rig/sprites/humanoid/get_fnf_face_holder()
	return cloth_parts[RIG_HEAD]

/datum/limb_rig/sprites/humanoid/get_fnf_face_images(expression)
	var/obj/item/bodypart/head/head = owner.get_bodypart(BODY_ZONE_HEAD)
	var/face_set = get_fnf_face_set(head?.limb_id)
	if(!face_set)
		return list()
	var/image/cover = image('voidcrew/modules/fnf/icons/fnf_faces.dmi', "[face_set]_cover")
	cover.layer = FLOAT_LAYER
	// The head's own shade, tinted as the head is (a head drawn in its own colours isn't).
	if(head.should_draw_greyscale && head.draw_color)
		cover.color = head.draw_color
	// Only people's faces come in other eyes.
	var/eyes = face_set == "human" && owner.fnf_face_eyes ? "_[owner.fnf_face_eyes]" : ""
	var/image/face = image('voidcrew/modules/fnf/icons/fnf_faces.dmi', "[face_set][eyes]_[expression]")
	face.layer = FLOAT_LAYER
	return list(cover, face)

/// Which faces fit a head, by its limb id: null for a head that can't pull one.
/proc/get_fnf_face_set(limb_id)
	switch(limb_id)
		if(SPECIES_PLASMAMAN)
			return null
		if(SPECIES_LIZARD)
			return "lizard"
		if(SPECIES_MOTH)
			return "moth"
		if(SPECIES_ETHEREAL, SPECIES_ETHEREAL_LUSTROUS)
			return "ethereal"
		if(SPECIES_SKELETON)
			return "skeleton"
	return "human"
