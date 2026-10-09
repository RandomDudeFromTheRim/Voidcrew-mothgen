/**
 * *invincible: the Invincible wobble edit. The whole spessman bends about like a cut-out picture,
 * badly tweened: leaning, squashing and swinging about the feet, overshooting every move and
 * snapping between some, with a rubbery wave running up them all the while. A rigged body strikes
 * the edit's poses as well. They're invincible while it lasts, and held where they are.
 *
 * The edit, as it goes: a fighting crouch, lunging twice; flying, fists up, swaying; zipping
 * across and back, one fist up; and a punch at whoever's watching, drawn half again as big.
 */
/// How long it lasts (invincible.ogg's length), and how long until they can again.
#define GAG_INVINCIBLE_LENGTH (11.3 SECONDS)
#define GAG_INVINCIBLE_COOLDOWN (3 MINUTES)

/datum/emote/living/carbon/human/invincible
	key = "invincible"
	message = "becomes invincible."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = GAG_INVINCIBLE_COOLDOWN

/datum/emote/living/carbon/human/invincible/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	var/mob/living/carbon/human/human_user = user
	// Only on purpose, only when nothing's wrong, and not again for a while: it isn't a way out of
	// a fight. They can't do anything while it lasts, either.
	if(!intentional || !istype(human_user) || human_user.current_gag || human_user.stat != CONSCIOUS || human_user.body_position == LYING_DOWN || human_user.buckled || !isturf(human_user.loc))
		return FALSE
	if(human_user.health < human_user.maxHealth * 0.9 || HAS_TRAIT(human_user, TRAIT_RESTRAINED) || human_user.pulledby || human_user.on_fire)
		return FALSE
	if(world.time < human_user.next_invincible)
		return FALSE
	return ..()

/datum/emote/living/carbon/human/invincible/run_emote(mob/user, params, type_override, intentional = FALSE)
	. = ..()
	var/mob/living/carbon/human/human_user = user
	human_user.next_invincible = world.time + GAG_INVINCIBLE_COOLDOWN
	human_user.log_message("became invincible for [DisplayTimeText(GAG_INVINCIBLE_LENGTH)] (*invincible).", LOG_EMOTE)
	new /datum/gag/invincible(user)

/mob/living/carbon/human
	/// When they can next be invincible (see *invincible).
	var/next_invincible = 0

/**
 * The wobble, beat by beat, in time with invincible.ogg: list(when, in seconds into the clip; how
 * long it takes to get there, in deciseconds, 0 snapping; shear; squash; turn, in degrees; size;
 * pixel_w; pixel_z; easing). Shear leans the top over (1 being a pixel across for every pixel up),
 * squash below 1 squashes and above stretches, and all of it is about their feet. Leaning goes
 * the way they turn, so the two add up rather than cancel out.
 */
GLOBAL_LIST_INIT(gag_invincible_beats, list(
	// A fighting crouch, swaying, lunging twice.
	list(0, 1, 0.1, 0.95, 0, 1, 0, 0, SINE_EASING),
	list(0.2, 1.5, 0.4, 0.78, 5, 1, 6, 0, LINEAR_EASING),
	list(0.45, 4, -0.1, 1.05, 0, 1, 0, 0, ELASTIC_EASING),
	list(0.8, 2, 0.15, 0.95, 0, 1, 0, 0, SINE_EASING),
	list(1, 1.5, 0.42, 0.75, 6, 1, 7, 0, LINEAR_EASING),
	list(1.25, 4, -0.15, 1.08, -4, 1, 0, 0, ELASTIC_EASING),
	list(1.7, 3, 0.2, 0.92, 3, 1, 0, 0, ELASTIC_EASING),
	list(2.1, 3, -0.18, 1.06, -3, 1, 0, 0, ELASTIC_EASING),
	list(2.5, 3, 0.22, 0.9, 4, 1, 0, 0, ELASTIC_EASING),
	list(2.85, 1.5, -0.1, 1.1, 0, 1, 0, 3, LINEAR_EASING),
	// Flying, fists up, swaying from side to side.
	list(3, 0, 0, 1, 45, 1.1, -4, 10, LINEAR_EASING),
	list(3.05, 4, -0.15, 1.05, -6, 1.1, 0, 10, ELASTIC_EASING),
	list(3.5, 3, 0.2, 0.92, 12, 1.1, 0, 8, ELASTIC_EASING),
	list(3.95, 3, -0.2, 1.06, -12, 1.1, 0, 11, ELASTIC_EASING),
	list(4.4, 3, 0.22, 0.9, 14, 1.1, 0, 8, ELASTIC_EASING),
	list(4.85, 2, -0.25, 1, -18, 1.1, 0, 10, LINEAR_EASING),
	list(5.2, 0, 0.05, 1, 6, 1.1, 0, 10, LINEAR_EASING),
	list(5.3, 3, -0.15, 1.04, -10, 1.1, 0, 9, ELASTIC_EASING),
	list(5.75, 3, 0.2, 0.94, 12, 1.1, 0, 10, ELASTIC_EASING),
	list(6.2, 2, -0.1, 1, -6, 1.1, 0, 9, ELASTIC_EASING),
	// Zipping across, one fist up, and back.
	list(6.5, 0, 0, 1, 90, 1, -20, 4, LINEAR_EASING),
	list(6.52, 3, 0, 1, 80, 1, 20, 4, LINEAR_EASING),
	list(6.85, 0, 0, 1, -10, 1, 0, 10, LINEAR_EASING),
	list(6.9, 3, 0.15, 1.04, 8, 1, 0, 10, ELASTIC_EASING),
	list(7.25, 3, -0.15, 0.96, -10, 1, 0, 9, ELASTIC_EASING),
	list(7.6, 0, 0, 1, -95, 1, 20, 4, LINEAR_EASING),
	list(7.62, 3, 0, 1, -85, 1, -20, 4, LINEAR_EASING),
	list(7.95, 0, 0, 1, 10, 1, 0, 10, LINEAR_EASING),
	list(8, 3, -0.15, 1.04, -8, 1, 0, 10, ELASTIC_EASING),
	list(8.35, 3, 0.18, 0.95, 10, 1, 0, 9, ELASTIC_EASING),
	// The punch at the camera, rocking.
	list(8.75, 0, 0, 1, 0, 1.7, 0, 0, LINEAR_EASING),
	list(8.8, 3, -0.15, 1.05, -8, 1.55, 0, 0, ELASTIC_EASING),
	list(9.25, 3, 0.15, 0.95, 8, 1.55, 0, 0, ELASTIC_EASING),
	list(9.7, 3, -0.12, 1.04, -8, 1.55, 0, 0, ELASTIC_EASING),
	list(10.15, 3, 0.15, 0.95, 9, 1.55, 0, 0, ELASTIC_EASING),
	list(10.6, 3, -0.1, 1.03, -6, 1.55, 0, 0, ELASTIC_EASING),
	list(11.1, 1.5, 0, 1, 0, 1, 0, 0, LINEAR_EASING),
))

/// When a rigged body strikes each pose: list(when, in seconds; facing; pose; how long it takes, in deciseconds).
GLOBAL_LIST_INIT(gag_invincible_posing, list(
	list(0, EAST, "stance", 1),
	list(0.2, EAST, "lunge", 1.5),
	list(0.45, EAST, "stance", 3),
	list(1, EAST, "lunge", 1.5),
	list(1.25, EAST, "stance", 3),
	list(3, SOUTH, "fists_up", 0.5),
	list(6.5, EAST, "dive", 0.5),
	list(6.85, SOUTH, "one_fist", 0.5),
	list(7.6, WEST, "dive", 0.5),
	list(7.95, SOUTH, "one_fist", 0.5),
	list(8.75, SOUTH, "punch", 0.5),
))

/// The poses, by name.
GLOBAL_LIST_INIT(gag_invincible_poses, list(
	"stance" = list(RIG_CHEST = list("bend" = 12), RIG_HEAD = list("nod" = -8), RIG_L_ARM = list("swing" = 60, "elbow" = 100), RIG_R_ARM = list("swing" = 35, "elbow" = 120), RIG_L_LEG = list("swing" = 35, "knee" = 55), RIG_R_LEG = list("swing" = -20, "knee" = 25)),
	"lunge" = list(RIG_CHEST = list("bend" = 35), RIG_HEAD = list("nod" = -15), RIG_L_ARM = list("swing" = 95, "elbow" = 5), RIG_R_ARM = list("swing" = 20, "elbow" = 130), RIG_L_LEG = list("swing" = 55, "knee" = 45), RIG_R_LEG = list("swing" = -45, "knee" = 5)),
	"fists_up" = list(RIG_HEAD = list("nod" = -10), RIG_L_ARM = list("raise" = 160, "elbow" = 30), RIG_R_ARM = list("raise" = 160, "elbow" = 30), RIG_L_LEG = list("swing" = -15, "knee" = 35), RIG_R_LEG = list("swing" = 10, "knee" = 50)),
	"dive" = list(RIG_CHEST = list("bend" = -10), RIG_HEAD = list("nod" = -20), RIG_L_ARM = list("swing" = 175), RIG_R_ARM = list("swing" = 165, "elbow" = 10), RIG_L_LEG = list("swing" = -20, "knee" = 10), RIG_R_LEG = list("swing" = -35, "knee" = 30)),
	"one_fist" = list(RIG_L_ARM = list("raise" = 30, "swing" = 20, "elbow" = 90), RIG_R_ARM = list("raise" = 170), RIG_L_LEG = list("swing" = -10, "knee" = 40), RIG_R_LEG = list("knee" = 20)),
	"punch" = list(RIG_CHEST = list("bend" = 15), RIG_HEAD = list("nod" = 5), RIG_L_ARM = list("swing" = 40, "raise" = 10, "elbow" = 110), RIG_R_ARM = list("swing" = 80, "raise" = 25), RIG_L_LEG = list("swing" = 20, "knee" = 30), RIG_R_LEG = list("swing" = -15, "knee" = 15)),
))

/// When they're smeared across, zipping: list(from, to), in seconds.
GLOBAL_LIST_INIT(gag_invincible_smears, list(list(6.5, 6.85), list(7.6, 7.95)))

/datum/gag/invincible
	/// Ends it come what may, invincibility and all.
	var/failsafe

/datum/gag/invincible/New(mob/living/carbon/human/victim)
	. = ..()
	ADD_TRAIT(victim, TRAIT_GODMODE, GAG_TRAIT)
	// Whatever happens to the rest of it, this ends when the clip does, and the invincibility with it
	// (see /datum/gag/Destroy()).
	failsafe = QDEL_IN_STOPPABLE(src, GAG_INVINCIBLE_LENGTH + 1 SECONDS)
	// Moved off their spot (pulled, thrown, teleported): over.
	RegisterSignal(victim, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/gag/invincible/act()
	playsound(victim, 'voidcrew/modules/gags/sound/invincible.ogg', 80, FALSE)
	// Rubbery all the way through: a wave running up them, bending them from side to side.
	victim.add_filter("gag_invincible_wave", 1, wave_filter(x = 0, y = 20, size = 2, flags = WAVE_SIDEWAYS))
	var/wave = victim.get_filter("gag_invincible_wave")
	animate(wave, offset = 1, time = 7, loop = -1)
	animate(offset = 0, time = 0)
	var/list/beats = GLOB.gag_invincible_beats
	var/list/posing = GLOB.gag_invincible_posing
	var/list/smears = GLOB.gag_invincible_smears
	var/next_beat = 1
	var/next_pose = 1
	var/next_smear = 1
	var/smearing = FALSE
	while(next_beat <= length(beats))
		// Whichever comes next: a beat, a pose or a smear starting or stopping.
		var/list/beat = beats[next_beat]
		var/list/pose = next_pose <= length(posing) ? posing[next_pose] : null
		var/list/smear = next_smear <= length(smears) ? smears[next_smear] : null
		var/smear_at = smear ? smear[smearing ? 2 : 1] : INFINITY
		var/at = min(beat[1], pose ? pose[1] : INFINITY, smear_at)
		GAG_AT(at SECONDS)
		if(smear_at == at)
			if(smearing)
				victim.remove_filter("gag_invincible_smear")
				next_smear++
			else
				victim.add_filter("gag_invincible_smear", 2, motion_blur_filter(x = 4, y = 0))
			smearing = !smearing
		if(pose && pose[1] == at)
			victim.setDir(pose[2])
			gag_pose(victim, GLOB.gag_invincible_poses[pose[3]], pose[4])
			next_pose++
		if(beat[1] == at)
			animate(victim,
				transform = old_transform * gag_invincible_matrix(beat[3], beat[4], beat[5], beat[6]),
				pixel_w = victim.base_pixel_w + beat[7],
				pixel_z = victim.base_pixel_z + beat[8],
				time = beat[2],
				easing = beat[9],
			)
			next_beat++
	GAG_AT(GAG_INVINCIBLE_LENGTH)
	qdel(src)

/datum/gag/invincible/proc/on_moved(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/gag/invincible/Destroy()
	deltimer(failsafe)
	if(victim)
		UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
		// Stops the wobble where it is, before they're put back.
		animate(victim)
		victim.remove_filter(list("gag_invincible_wave", "gag_invincible_smear"))
		victim.limb_rig?.settle()
	return ..()

/// Leans, squashes, turns and sizes something about its feet (the bottom of its tile), as the wobble does.
/proc/gag_invincible_matrix(shear, squash, turn, size)
	var/matrix/wobble = matrix(1, shear, 0, 0, 1, 0)
	wobble.Scale(size * (2 - squash), size * squash)
	wobble.Turn(turn)
	// Back onto its feet: whatever the rest did to the middle of the bottom edge, undone.
	wobble.Translate(16 * wobble.b, 16 * wobble.e - 16)
	return wobble

#undef GAG_INVINCIBLE_LENGTH
#undef GAG_INVINCIBLE_COOLDOWN
