/**
 * Things on a rhythm battle's stage, from Funkin' and Corruption+'s own art: the boombox Girlfriend
 * sits on between the singers (and that Pico and Otis stand on to shoot from), its corrupted one and
 * Nene's A-Bot, three tiles wide (icons/fnf_speakers.dmi); Kapi's arcade dance pad, lighting up where
 * he steps, and the little speaker Marble leans on (icons/fnf_props.dmi).
 *
 * Whoever's up on one is raised to stand on it, or to sit on its edge with their legs hanging over.
 */
/obj/effect/abstract/fnf_prop
	name = ""
	icon = 'voidcrew/modules/fnf/icons/fnf_props.dmi'
	// 64 pixels wide, centred on its tile.
	pixel_w = -16
	plane = GAME_PLANE
	layer = BELOW_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Who's up on it, and how far it raised them.
	var/mob/living/rider
	var/raised = 0

	/// A dance pad's panels, lit when stepped on, by lane.
	var/list/obj/effect/abstract/panels
	/// Whether it's drawn mirrored (for someone facing west), left and right swapped.
	var/mirrored = FALSE

/obj/effect/abstract/fnf_prop/Destroy()
	set_rider(null)
	vis_contents.Cut()
	QDEL_LIST(panels)
	return ..()

/// Shows one of the props.
/obj/effect/abstract/fnf_prop/proc/set_look(state)
	icon_state = state
	if(state in list("speakers", "speakers_evil", "abot"))
		icon = 'voidcrew/modules/fnf/icons/fnf_speakers.dmi'
		pixel_w = -32
	else
		icon = initial(icon)
		pixel_w = initial(pixel_w)

/// How high each prop's top is, in pixels, for standing on.
/proc/fnf_prop_height(state)
	var/static/list/heights = list("speakers" = 61, "speakers_evil" = 61, "abot" = 38, "dance_pad" = 8, "dance_pad_corrupt" = 8)
	return heights[state] || 0

/// A dance pad's panel lighting up, stepped on: lane 0 to 3 for left, down, up, right.
/obj/effect/abstract/fnf_prop/proc/step_on(lane)
	if(!findtext(icon_state, "dance_pad"))
		return
	var/static/list/lanes = list("left", "down", "up", "right")
	if(!panels)
		panels = list()
		for(var/name in lanes)
			var/obj/effect/abstract/panel = new
			panel.icon = icon
			panel.icon_state = "[icon_state]_lit_[name]"
			panel.alpha = 0
			panel.vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE|VIS_INHERIT_LAYER
			panel.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			panels += panel
			vis_contents += panel
	// Mirrored, the left panel's on the right.
	if(mirrored && (lane == 0 || lane == 3))
		lane = 3 - lane
	var/obj/effect/abstract/panel = panels[clamp(lane + 1, 1, 4)]
	animate(panel, alpha = 255, time = 0)
	animate(alpha = 0, time = 4, easing = QUAD_EASING|EASE_IN)

/// Puts someone up on it, sitting on its edge or standing on top, or (with null) gets them down.
/obj/effect/abstract/fnf_prop/proc/set_rider(mob/living/new_rider, seated = FALSE)
	if(rider && !QDELETED(rider))
		rider.pixel_z -= raised
		if(iscarbon(rider))
			var/mob/living/carbon/carbon_rider = rider
			carbon_rider.limb_rig?.set_seated(FALSE)
	rider = new_rider
	raised = 0
	if(!rider)
		return
	// Sitting, the hips are on the top, the shins hanging down in front.
	raised = fnf_prop_height(icon_state) - (seated ? 8 : 0)
	rider.pixel_z += raised
	if(seated && iscarbon(rider))
		var/mob/living/carbon/carbon_rider = rider
		carbon_rider.limb_rig?.set_seated(TRUE)

/// The speakers thump with the beat.
/obj/effect/abstract/fnf_prop/proc/thump()
	animate(src, transform = matrix(1.04, 0, 0, 0, 0.94, -0.7), time = 0.5)
	animate(transform = matrix(), time = 2.5, easing = SINE_EASING)

/**
 * Sat on something, facing the front: the thighs swung straight out at the viewer (so they
 * foreshorten to nothing) and the shins hanging down, on top of whatever the body does anyway.
 */
/datum/limb_rig/proc/set_seated(seated)
	var/mob/living/carbon/human/human_owner = owner
	var/list/own_posture = istype(human_owner) ? human_owner.dna.species.limb_rig_shape?["posture"] : null
	if(!seated)
		posture = own_posture
		return
	posture = rig_merge_pose(own_posture, list(
		RIG_L_LEG = list("swing" = 88, "knee" = 88),
		RIG_R_LEG = list("swing" = 88, "knee" = 88),
	))

// The stage's.

/datum/fnf_stage
	/// What the girlfriend's place is up on, if anything.
	var/obj/effect/abstract/fnf_prop/seat
	/// Props by the singers (Kapi's dance pad, Marble's speaker), by singer.
	var/list/singer_props = list()

/// Where the girlfriend stands: a step behind, halfway between the singers. Null if there's no room.
/datum/fnf_stage/proc/get_girlfriend_spot()
	if(!left_spot || !right_spot)
		return null
	var/turf/middle = locate(round((left_spot.x + right_spot.x) / 2), left_spot.y + 1, left_spot.z)
	if(!middle || middle.is_blocked_turf(exclude_mobs = TRUE))
		return null
	return middle

/**
 * Puts something in the girlfriend's place for her to sit on ("speakers", "speakers_evil", "abot"),
 * or to stand on, or takes it away (null). Whoever's there now gets up on it, if they're seen.
 */
/datum/fnf_stage/proc/set_seat(state, seated = TRUE)
	if(seat?.icon_state != state)
		QDEL_NULL(seat)
		if(!state)
			return
		var/turf/spot = girlfriend ? get_turf(girlfriend) : get_girlfriend_spot()
		if(!spot)
			return
		seat = new(spot)
		seat.set_look(state)
	seat.set_rider(girlfriend && girlfriend.alpha ? girlfriend : null, seated)

/// What the girlfriend's place has to stand on for this character, as Funkin' has it: list(state, seated).
/datum/fnf_stage/proc/get_seat_for(character)
	if(length(battle.chart["speaker"]))
		// Stress: up on the speakers, to shoot from.
		return list("speakers", FALSE)
	switch(character)
		if("gf")
			return list("speakers", TRUE)
		if("nene")
			return list("abot", TRUE)

/// Gives a singer one of their props ("dance_pad", "speaker_small"), or takes it away (null).
/datum/fnf_stage/proc/set_singer_prop(mob/living/singer, state)
	var/obj/effect/abstract/fnf_prop/old = singer_props[singer]
	if(old?.icon_state == state)
		return
	if(old)
		singer_props -= singer
		qdel(old)
	if(!state || !singer)
		return
	var/obj/effect/abstract/fnf_prop/prop = new(get_turf(singer))
	prop.set_look(state)
	singer_props[singer] = prop
	if(state == "speaker_small")
		// Beside her, behind, for a hand to rest on, facing her enemy.
		prop.pixel_w += get_enemy_side(singer) == WEST ? 12 : -12
		return
	// Facing west (playing as Kapi), the pad's turned round to match: the rail behind them.
	for(var/datum/fnf_side/side as anything in battle.sides)
		if(side.singer == singer && side.facing == WEST)
			prop.mirrored = TRUE
			prop.transform = matrix(-1, 0, 0, 0, 1, 0)
	prop.set_rider(singer)

/// A singer's dance pad lighting up where they step (lane 0 to 3), if they have one.
/datum/fnf_stage/proc/step_on_pad(mob/living/singer, lane)
	var/obj/effect/abstract/fnf_prop/prop = singer_props[singer]
	prop?.step_on(lane)

/// Which way the girlfriend's place faces to glare at the enemy, the opponent on the left.
/datum/fnf_stage/proc/get_enemy_side(mob/living/watcher)
	var/mob/living/enemy = battle.left?.singer
	if(!enemy || enemy == watcher)
		return WEST
	return enemy.x > watcher.x ? EAST : WEST
