/**
 * SHED.MOV: the quest for the elements of armory, through Fluttershy's shed. The victim plays one of
 * three: the Rainbow part (dragged along to the end, sat in the chair and sawn in half; they come out
 * of it dead), the Pinkie part (out the window during the song, and still around at the asylum after)
 * or the Apple Bloom part (stepped on before the title, and watching the rest from under the foot).
 *
 * The cast are ponies of our own, coloured after their parts, with names off the pony list.
 * shed.dmm has five sets, left to right: the woods with the shed's outside, the white of the
 * flashbacks, the prom, the shed's inside and the asylum.
 */
/datum/smite/ponymov_shed
	name = "pony.mov: SHED.MOV"

/datum/smite/ponymov_shed/effect(client/user, mob/living/target)
	var/mob/living/carbon/human/victim = target
	if(!istype(victim) || victim.ponymov || !victim.client)
		to_chat(user, span_warning("This must be used on a human with a player, who isn't already in an episode."), confidential = TRUE)
		return
	var/static/list/roles = list("Random" = null, "Rainbow (dies)" = "rainbow", "Pinkie" = "pinkie", "Apple Bloom" = "applebloom")
	var/choice = tgui_input_list(user, "Which part do they get?", "SHED.MOV", roles, "Random")
	if(!choice || QDELETED(victim))
		return
	. = ..()
	new /datum/ponymov/shed(victim, roles[choice])

/obj/effect/ponymov_scenery/microphone
	name = "microphone"
	icon_state = "microphone"

/obj/effect/ponymov_scenery/lever
	name = "lever"
	icon_state = "lever"

/// Words painted up somewhere: on a wall, a banner.
/obj/effect/ponymov_scenery/writing
	icon = null
	maptext_width = 160
	maptext_x = -64
	maptext_y = 8
	layer = ABOVE_MOB_LAYER
	var/words = ""
	var/colour = "#ffffff"

/obj/effect/ponymov_scenery/writing/Initialize(mapload)
	. = ..()
	maptext = MAPTEXT("<div align='center'><span style='color:[colour];-dm-text-outline:1px #000000'>[words]</span></div>")

/obj/effect/ponymov_scenery/writing/prom_banner
	name = "banner"
	words = "<b>SENIOR PROM</b>"
	colour = "#fff2a0"

/obj/effect/ponymov_scenery/writing/bunny_brain_corner
	name = "sign"
	words = "BUNNY BRAIN CORNER"
	colour = "#d02020"

/datum/ponymov/shed
	episode = "shed"
	set_names = list("woods", "memory", "prom", "shed", "asylum")
	length = 283
	parts = list(
		// part = list(name, species, coat, mane, hairstyle, eyes, pony archetype)
		"rainbow" = list(null, /datum/species/pony, "#8fd3f5", "#e8403a", "Punk Rocker (Equestrian)", "#9b2c6e", "Pegasus"),
		"pinkie" = list(null, /datum/species/pony, "#f5a3cf", "#e83e8c", "Dork (Equestrian)", "#5fb6e6", "Earth"),
		"applebloom" = list(null, /datum/species/pony, "#f3ee9a", "#e2324f", "Soldier (Equestrian)", "#e0773a", "Earth"),
		"fluttershy" = list(null, /datum/species/pony, "#fbf29a", "#f5b7d2", "Timid (Equestrian)", "#2f9fa6", "Pegasus"),
		"spike" = list(null, /datum/species/lizard, "#9b59b6", "#9b59b6", "Bald", "#3fbf3f", null),
		"twilight" = list(null, /datum/species/pony, "#d3a8e6", "#2b2a68", "Bookworm (Equestrian)", "#6b3b8f", "Unicorn"),
		"sweetie" = list(null, /datum/species/pony, "#f4f2f6", "#b58ad6", "Fatale (Equestrian)", "#4bbd6b", "Unicorn"),
		"scootaloo" = list(null, /datum/species/pony, "#f7a948", "#bb5ab6", "Punk Rocker (Equestrian)", "#8a4fa0", "Pegasus"),
		"announcer" = list(null, /datum/species/pony, "#b98a5e", "#5a3a20", "Soldier (Equestrian)", "#3a2a10", "Earth"),
		"officer1" = list(null, /datum/species/pony, "#7fd18a", "#2d5f2d", "Soldier (Equestrian)", "#2d2d2d", "Earth"),
		"officer2" = list(null, /datum/species/pony, "#6fa0e0", "#203860", "Soldier (Equestrian)", "#2d2d2d", "Earth"),
		"doctor1" = list(null, /datum/species/pony, "#a9adb3", "#6a6e74", "Soldier (Equestrian)", "#2d2d2d", "Earth"),
		"doctor2" = list(null, /datum/species/pony, "#c8b8a8", "#7a6050", "Bookworm (Equestrian)", "#2d2d2d", "Earth"),
		"derpy" = list(null, /datum/species/pony, "#b9b9c3", "#f0e06a", "Dork (Equestrian)", "#e8d05a", "Pegasus"),
		"crowd1" = list(null, /datum/species/pony, "#e04848", "#f0a030", "Soldier (Equestrian)", "#2d6f2d", "Earth"),
		"crowd2" = list(null, /datum/species/pony, "#f0f0f8", "#6040a0", "Fatale (Equestrian)", "#3050c0", "Unicorn"),
		"crowd3" = list(null, /datum/species/pony, "#f0b050", "#d0d0c0", "Dork (Equestrian)", "#307030", "Earth"),
		"crowd4" = list(null, /datum/species/pony, "#9070c0", "#304080", "Bookworm (Equestrian)", "#5030a0", "Unicorn"),
		"crowd5" = list(null, /datum/species/pony, "#70c0e0", "#f0f0f0", "Timid (Equestrian)", "#406080", "Pegasus"),
		"crowd6" = list(null, /datum/species/pony, "#c09060", "#603020", "Punk Rocker (Equestrian)", "#204020", "Earth"),
	)
	screenplay = list(
		// The quest begins.
		list(0, "flip", "discord_open"),
		list(0, "beat", "dress_sets"),
		list(2.5, "cut", "woods", 8, 9),
		list(2.5, "place", "applebloom", "woods", 7, 8, SOUTH),
		list(2.5, "place", "sweetie", "woods", 8, 9, WEST),
		list(2.5, "place", "scootaloo", "woods", 9, 9, WEST),
		list(3.9, "beat", "cutie_mark"),
		list(6.1, "walk", "sweetie", 1, 9, 3.5),
		list(6.3, "walk", "scootaloo", 1, 9, 3.5),
		list(8, "face", "applebloom", WEST),
		list(9.8, "hide", "sweetie"),
		list(10, "hide", "scootaloo"),
		list(11.4, "flip", "foot"),
		list(13.6, "beat", "squash"),
		list(13.7, "flip", "title"),
		// Pinkie walks them in, Rainbow on her back and Spike on Rainbow's.
		list(18.1, "flip", "spike_bah"),
		list(18.1, "place", "pinkie", "woods", 2, 8, EAST),
		list(18.1, "place", "rainbow", "woods", 2, 8, EAST),
		list(18.1, "carry", "rainbow", "pinkie"),
		list(18.1, "place", "spike", "woods", 2, 8, EAST),
		list(18.1, "carry", "spike", "rainbow"),
		list(22, "cut", "woods", 8, 9),
		list(22, "walk", "pinkie", 13, 8, 7.5),
		list(26, "cut", "woods", 11, 9),
		list(31, "drop", "rainbow"),
		list(31, "drop", "pinkie"),
		list(31, "place", "rainbow", "woods", 12, 9, EAST),
		list(31, "place", "spike", "woods", 13, 9, NORTH),
		list(31, "face", "pinkie", NORTH),
		list(33, "beat", "read_arm"),
		list(37.1, "cut", "woods", 13, 9),
		list(37.1, "beat", "smoke"),
		list(40.5, "flip", "spike_arm"),
		list(42.9, "flip", "pinkie_face"),
		list(47.1, "cut", "woods", 13, 9),
		list(47.1, "face", "spike", SOUTH),
		// Flashback: spin the bottle, and the beating.
		list(48, "vignette", TRUE),
		list(49.5, "cut", "memory"),
		list(49.5, "place", "fluttershy", "memory", 11, 11, SOUTH),
		list(49.5, "place", "rainbow", "memory", 9, 9, EAST),
		list(49.5, "place", "pinkie", "memory", 13, 9, WEST),
		list(49.5, "place", "twilight", "memory", 11, 7, NORTH),
		list(49.5, "beat", "bottle"),
		list(52, "cut", "memory", 11, 10),
		list(56, "emote", "fluttershy", "giggle"),
		list(60, "unprop", "bottle"),
		list(60, "hide", "twilight"),
		list(60, "hide", "fluttershy"),
		list(60, "place", "rainbow", "memory", 10, 9, EAST),
		list(60, "lie", "rainbow"),
		list(60, "place", "pinkie", "memory", 12, 9, WEST),
		list(60, "lie", "pinkie"),
		list(60, "cut", "memory", 11, 9),
		list(63.7, "stand", "rainbow"),
		list(63.7, "stand", "pinkie"),
		list(63.7, "emote", "rainbow", "grin"),
		list(64.5, "emote", "pinkie", "grin"),
		list(68, "beat", "beating"),
		// The prom.
		list(81.8, "cut", "prom", 11, 10),
		list(81.8, "beat", "prom"),
		list(84.5, "flip", "fs_braces"),
		list(87.2, "cut", "prom", 11, 12),
		list(87.2, "beat", "rafters"),
		list(91.1, "beat", "bucket"),
		list(94.4, "cut", "prom", 11, 8),
		list(94.4, "beat", "laugh"),
		list(100.5, "cut", "prom", 11, 12),
		list(100.5, "face", "fluttershy", NORTH),
		list(102.2, "beat", "peek"),
		list(105.4, "flip", "fs_crying"),
		// Back at the shed.
		list(119.1, "vignette", FALSE),
		list(119.1, "cut", "woods", 13, 9),
		list(119.1, "beat", "back_at_the_shed"),
		list(126, "black", 2.1),
		list(128.1, "flip", "shed_bucket"),
		list(128.1, "cut", "shed", 11, 9),
		list(128.1, "place", "spike", "shed", 10, 6, NORTH),
		list(128.1, "place", "rainbow", "shed", 11, 6, NORTH),
		list(128.1, "place", "pinkie", "shed", 12, 6, NORTH),
		list(130.3, "walk", "spike", 10, 9, 2),
		list(130.3, "walk", "rainbow", 11, 9, 2),
		list(130.3, "walk", "pinkie", 12, 9, 2),
		list(134.6, "beat", "magazine"),
		list(141.7, "walk", "rainbow", 6, 12, 3),
		list(141.7, "walk", "pinkie", 7, 12, 3),
		list(149.7, "flip", "pinkie_scream"),
		list(151.8, "walk", "spike", 7, 12, 2),
		list(154, "beat", "toaster_cozy"),
		list(158, "walk", "rainbow", 8, 12, 1),
		list(158, "walk", "pinkie", 9, 12, 1.5),
		// The trap.
		list(164.9, "cut", "shed", 11, 8),
		list(164.9, "beat", "doorway"),
		list(171.1, "beat", "chainsaw"),
		list(172.2, "face", "spike", SOUTH),
		list(175.2, "flip", "song_pelts"),
		list(175.2, "beat", "pelts_sing"),
		list(186, "beat", "dance"),
		list(188, "beat", "windows"),
		list(191, "walk", "fluttershy", 13, 13, 2),
		list(193.3, "beat", "chair"),
		list(199, "walk", "fluttershy", 11, 10, 1.5),
		list(200.9, "flip", "fs_monster"),
		list(201, "beat", "monster"),
		list(206.7, "flip_end"),
		list(208.6, "flip", "rd_scream"),
		list(209.9, "beat", "saw"),
		list(209.9, "cut", "shed", 8, 12),
		list(213, "tint", "#6070a0", 2),
		// The police, and after.
		list(215.2, "cut", "shed", 11, 6),
		list(215.2, "beat", "police"),
		list(221.7, "cut", "shed", 11, 9),
		list(221.7, "beat", "innocent"),
		list(226, "beat", "peel"),
		list(235.8, "tint", null, 0),
		list(235.8, "cut", "asylum", 11, 7),
		list(235.8, "beat", "asylum"),
		list(246.4, "cut", "asylum", 11, 11),
		list(246.4, "place", "spike", "asylum", 10, 12, SOUTH),
		list(246.4, "place", "pinkie", "asylum", 12, 12, SOUTH),
		list(254.5, "walk", "spike", 4, 13, 3),
		list(257.7, "flip", "discord_end"),
		list(261.8, "flip", "end_card"),
	)

/datum/ponymov/shed/pick_role()
	return pick_weight(list("rainbow" = 50, "pinkie" = 35, "applebloom" = 15))

/datum/ponymov/shed/dress_actor(mob/living/carbon/human/actor, part)
	if(actor != victim)
		actor.randomize_human_appearance(~RANDOMIZE_SPECIES)
	actor.dna.features[FEATURE_PONY_EARS] = "Pony"
	actor.dna.features[FEATURE_PONY_TAIL] = "Pony"
	. = ..()
	actor.delete_equipment()
	switch(part)
		if("officer1", "officer2")
			actor.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/officer(actor), ITEM_SLOT_ICLOTHING)
			actor.equip_to_slot_or_del(new /obj/item/clothing/head/hats/warden/police(actor), ITEM_SLOT_HEAD)
		if("doctor1", "doctor2")
			actor.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical/doctor(actor), ITEM_SLOT_ICLOTHING)
		if("announcer")
			actor.equip_to_slot_or_del(new /obj/item/clothing/under/suit/black(actor), ITEM_SLOT_ICLOTHING)

/// Speakers in the host's subtitles are the parts, but for the police, who're "officer".
/datum/ponymov/shed/run_cues()
	for(var/list/cue as anything in cues)
		if(cue[3] == "officer")
			cue[3] = "officer1"
		if(cue[3] == "doctor")
			cue[3] = "doctor1"
	return ..()

/// Brings on a prop that's just looks, with this icon, somewhere in a set.
/datum/ponymov/shed/proc/scenery(name, icon, icon_state, set_name, x, y, pixel_w = 0, pixel_z = 0)
	var/obj/effect/ponymov_scenery/thing = new(set_turf(set_name, x, y))
	thing.icon = icon
	thing.icon_state = icon_state
	thing.pixel_w = pixel_w
	thing.pixel_z = pixel_z
	if(name)
		props[name] = thing
	return thing

/// Something dead, kept as a prop: the shed's pelts.
/datum/ponymov/shed/proc/carcass(type, set_name, x, y, pixel_w = 0, pixel_z = 0)
	var/mob/living/body = new type(set_turf(set_name, x, y))
	body.death()
	body.pixel_w = pixel_w
	body.pixel_z = pixel_z
	props["carcass [REF(body)]"] = body
	return body

/datum/ponymov/shed/proc/splatter(set_name, x, y, count = 3)
	for(var/i in 1 to count)
		var/obj/effect/decal/cleanable/blood/splatter/blood = new(set_turf(set_name, x, y))
		blood.pixel_w = rand(-12, 12)
		blood.pixel_z = rand(-12, 12)

/// The shed's inside, done up before anyone sees it: pelts all round the walls, the brains, Derpy.
/datum/ponymov/shed/proc/beat_dress_sets()
	for(var/x in 4 to 18)
		carcass(pick(/mob/living/basic/rabbit, /mob/living/basic/mouse, /mob/living/basic/chicken), "shed", x, 14, rand(-4, 4), 14)
		if(prob(60))
			splatter("shed", x, 14, 1)
	for(var/y in 5 to 13)
		carcass(pick(/mob/living/basic/rabbit, /mob/living/basic/mouse), "shed", 4, y, -14, rand(-4, 4))
		carcass(pick(/mob/living/basic/rabbit, /mob/living/basic/mouse), "shed", 18, y, 14, rand(-4, 4))
	for(var/i in 1 to 4)
		new /obj/effect/decal/remains/human(set_turf("shed", rand(5, 17), rand(5, 12)))
	splatter("shed", 11, 9, 5)
	splatter("shed", 6, 11, 3)
	for(var/i in 1 to 5)
		var/obj/item/organ/brain/brain = new(set_turf("shed", 15 + rand(-1, 1), 13))
		brain.pixel_z = rand(-6, 6)
	new /obj/item/organ/eyes(set_turf("shed", 5, 13))
	// Derpy, sewn into the cozy over the toaster.
	var/mob/living/carbon/human/derpy = cast["derpy"]
	derpy.forceMove(set_turf("shed", 7, 13))
	derpy.set_body_position(LYING_DOWN)
	derpy.alpha = 255
	derpy.transform = matrix(0.8, 0, 0, 0, 0.6, 4)

/datum/ponymov/shed/proc/beat_cutie_mark()
	var/mob/living/carbon/human/bloom = cast["applebloom"]
	bloom.SpinAnimation(speed = 0.6 SECONDS, loops = 1)
	bloom.emote("smile", forced = TRUE)

/// The foot comes down on Apple Bloom.
/datum/ponymov/shed/proc/beat_squash()
	var/mob/living/carbon/human/bloom = cast["applebloom"]
	bloom.set_body_position(LYING_DOWN)
	animate(bloom, transform = matrix(1.5, 0, 0, 0, 0.2, -12), time = 0.1 SECONDS)
	splatter("woods", 7, 8, 6)
	new /obj/effect/decal/cleanable/blood/gibs(set_turf("woods", 7, 8))
	playsound(bloom, 'sound/effects/splat.ogg', 70, FALSE)
	if(bloom == victim)
		to_chat(victim, span_userdanger("Something enormous steps on you."))

/// Spike reads where they're going off his arm, where it's written.
/datum/ponymov/shed/proc/beat_read_arm()
	var/mob/living/carbon/human/spike = cast["spike"]
	spike.setDir(WEST)
	spike.visible_message(span_notice("[spike] squints at something written on [spike.p_their()] arm."))

/datum/ponymov/shed/proc/beat_smoke()
	var/mob/living/carbon/human/spike = cast["spike"]
	var/obj/item/cigarette/rollie/cannabis/joint = new(spike)
	spike.equip_to_slot_or_del(joint, ITEM_SLOT_MASK)
	joint.light()

/datum/ponymov/shed/proc/beat_bottle()
	var/obj/effect/ponymov_scenery/bottle = scenery("bottle", 'icons/obj/drinks/bottles.dmi', "beer", "memory", 11, 9)
	bottle.SpinAnimation(speed = 0.4 SECONDS, loops = 6)

/// Rainbow and Pinkie kicking Fluttershy about, in the white.
/datum/ponymov/shed/proc/beat_beating()
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	var/mob/living/carbon/human/rainbow = cast["rainbow"]
	var/mob/living/carbon/human/pinkie = cast["pinkie"]
	shy.forceMove(set_turf("memory", 11, 10))
	shy.alpha = 255
	shy.set_body_position(LYING_DOWN)
	rainbow.forceMove(set_turf("memory", 10, 10))
	rainbow.setDir(EAST)
	pinkie.forceMove(set_turf("memory", 12, 10))
	pinkie.setDir(WEST)
	for(var/hit in 1 to 14)
		var/mob/living/carbon/human/kicker = (hit % 2) ? rainbow : pinkie
		kicker.do_attack_animation(shy, ATTACK_EFFECT_KICK)
		playsound(shy, 'sound/effects/hit_kick.ogg', 50, TRUE)
		shy.Shake(2, 0, 0.3 SECONDS)
		if(hit % 4 == 0)
			splatter("memory", 11, 10, 1)
		sleep(0.5 SECONDS)
		if(QDELETED(src))
			return
	shy.set_body_position(STANDING_UP)
	shy.setDir(SOUTH)

/datum/ponymov/shed/proc/beat_prom()
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	shy.forceMove(set_turf("prom", 12, 11))
	shy.setDir(SOUTH)
	run_line(list(0, "place", "announcer", "prom", 10, 11, SOUTH))
	run_line(list(0, "place", "spike", "prom", 8, 5, NORTH))
	var/list/spots = list(list(6, 4), list(9, 6), list(11, 5), list(13, 6), list(15, 4), list(16, 6))
	for(var/i in 1 to 6)
		var/list/spot = spots[i]
		run_line(list(0, "place", "crowd[i]", "prom", spot[1], spot[2], NORTH))
	for(var/part in list("rainbow", "pinkie", "twilight"))
		run_line(list(0, "hide", part))

/// Up in the rafters with the bucket, behind the curtain.
/datum/ponymov/shed/proc/beat_rafters()
	run_line(list(0, "place", "rainbow", "prom", 10, 14, SOUTH))
	run_line(list(0, "place", "pinkie", "prom", 13, 14, SOUTH))
	for(var/part in list("rainbow", "pinkie"))
		var/mob/living/carbon/human/up_there = cast[part]
		up_there.pixel_z = up_there.base_pixel_z + 20
		up_there.layer = ABOVE_MOB_LAYER
	var/obj/effect/ponymov_scenery/bucket = scenery("bucket", 'icons/obj/service/janitor.dmi', "bucket", "prom", 12, 11, 0, 56)
	bucket.layer = ABOVE_MOB_LAYER

/datum/ponymov/shed/proc/beat_bucket()
	var/obj/effect/ponymov_scenery/bucket = props["bucket"]
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	animate(bucket, pixel_z = 8, transform = matrix().Turn(180), time = 0.4 SECONDS, easing = QUAD_EASING | EASE_IN)
	sleep(0.4 SECONDS)
	if(QDELETED(src))
		return
	playsound(shy, 'sound/effects/splat.ogg', 80, FALSE)
	shy.add_atom_colour("#d02020", TEMPORARY_COLOUR_PRIORITY)
	splatter("prom", 12, 11, 6)
	for(var/part in list("rainbow", "pinkie"))
		var/mob/living/carbon/human/up_there = cast[part]
		up_there.pixel_z = up_there.base_pixel_z
		up_there.layer = initial(up_there.layer)
		up_there.alpha = 0

/datum/ponymov/shed/proc/beat_laugh()
	var/list/laughers = list("spike")
	for(var/i in 1 to 6)
		laughers += "crowd[i]"
	for(var/part in shuffle(laughers))
		var/mob/living/carbon/human/laugher = cast[part]
		laugher.emote("laugh", forced = TRUE)
		sleep(rand(2, 6))
		if(QDELETED(src))
			return
	var/mob/living/carbon/human/spike = cast["spike"]
	spike.face_atom(cast["fluttershy"])

/// Rainbow, peeking round the curtain.
/datum/ponymov/shed/proc/beat_peek()
	run_line(list(0, "place", "rainbow", "prom", 17, 13, WEST))
	var/mob/living/carbon/human/rainbow = cast["rainbow"]
	rainbow.pixel_w = rainbow.base_pixel_w + 12
	animate(rainbow, pixel_w = rainbow.base_pixel_w, time = 0.5 SECONDS)

/datum/ponymov/shed/proc/beat_back_at_the_shed()
	for(var/part in list("fluttershy", "announcer", "crowd1", "crowd2", "crowd3", "crowd4", "crowd5", "crowd6"))
		run_line(list(0, "hide", part))
	run_line(list(0, "place", "spike", "woods", 13, 9, SOUTH))
	run_line(list(0, "place", "rainbow", "woods", 12, 9, EAST))
	run_line(list(0, "place", "pinkie", "woods", 14, 9, WEST))
	var/mob/living/carbon/human/spike = cast["spike"]
	spike.emote("grin", forced = TRUE)

/datum/ponymov/shed/proc/beat_magazine()
	var/mob/living/carbon/human/spike = cast["spike"]
	var/obj/item/book/magazine = new(spike)
	magazine.name = "magazine"
	spike.put_in_hands(magazine)
	spike.setDir(EAST)
	var/mob/living/carbon/human/rainbow = cast["rainbow"]
	rainbow.setDir(WEST)
	// Rainbow's wings stand up.
	animate(rainbow, pixel_z = rainbow.base_pixel_z + 3, time = 0.15 SECONDS, loop = 6)
	animate(pixel_z = rainbow.base_pixel_z, time = 0.15 SECONDS)

/datum/ponymov/shed/proc/beat_toaster_cozy()
	var/mob/living/carbon/human/spike = cast["spike"]
	spike.setDir(NORTH)
	spike.emote("hug", forced = TRUE)

/// Fluttershy in the doorway, dark.
/datum/ponymov/shed/proc/beat_doorway()
	run_line(list(0, "place", "fluttershy", "shed", 11, 4, NORTH))
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	shy.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	shy.add_atom_colour("#605050", TEMPORARY_COLOUR_PRIORITY)
	for(var/part in list("spike", "rainbow", "pinkie"))
		var/mob/living/carbon/human/caught = cast[part]
		caught.setDir(SOUTH)
	run_line(list(0, "walk", "spike", 10, 9, 2))
	run_line(list(0, "walk", "rainbow", 11, 9, 2))
	run_line(list(0, "walk", "pinkie", 12, 9, 2))

/datum/ponymov/shed/proc/beat_chainsaw()
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	shy.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	var/obj/effect/ponymov_scenery/saw = scenery("chainsaw", 'icons/obj/weapons/chainsaw.dmi', "chainsaw_on", "shed", 11, 4, 10, 6)
	saw.vis_flags = VIS_INHERIT_ID
	saw.layer = ABOVE_MOB_LAYER
	saw.forceMove(null)
	shy.vis_contents += saw
	playsound(shy, 'sound/items/weapons/chainsaw_start.ogg', 80, FALSE)

/// The pelts on the walls play their bones.
/datum/ponymov/shed/proc/beat_pelts_sing()
	for(var/key in props)
		if(!findtext(key, "carcass "))
			continue
		var/atom/movable/pelt = props[key]
		var/base = pelt.pixel_z
		animate(pelt, pixel_z = base + 3, time = 0.25 SECONDS, loop = 40, easing = SINE_EASING)
		animate(pixel_z = base, time = 0.25 SECONDS, easing = SINE_EASING)

/datum/ponymov/shed/proc/beat_dance()
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	shy.forceMove(set_turf("shed", 11, 6))
	shy.SpinAnimation(speed = 0.8 SECONDS, loops = 2)

/// Pinkie and Spike out of the windows either side, leaving Rainbow on her own.
/datum/ponymov/shed/proc/beat_windows()
	for(var/list/escape in list(list("pinkie", 3, 2), list("spike", 19, 20)))
		var/mob/living/carbon/human/runner = cast[escape[1]]
		runner.forceMove(set_turf("shed", escape[2] + (escape[2] < 11 ? 1 : -1), 9))
		var/turf/window_turf = set_turf("shed", escape[2], 9)
		var/obj/structure/window/window = locate() in window_turf
		window?.deconstruct(FALSE)
		runner.forceMove(window_turf)
		runner.SpinAnimation(speed = 0.4 SECONDS, loops = 1)
		INVOKE_ASYNC(src, PROC_REF(walk), runner, escape[3], 9, 0.3)
	sleep(1 SECONDS)
	if(QDELETED(src))
		return
	run_line(list(0, "hide", "spike"))
	if(cast["pinkie"] != victim)
		run_line(list(0, "hide", "pinkie"))
	else
		// The Pinkie part watches the rest from outside the window.
		camera.forceMove(set_turf("shed", 11, 9))

/// The lever: a chair comes up under Rainbow and clamps her into it.
/datum/ponymov/shed/proc/beat_chair()
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	var/mob/living/carbon/human/rainbow = cast["rainbow"]
	shy.setDir(NORTH)
	var/obj/effect/ponymov_scenery/lever = locate() in set_turf("shed", 13, 14)
	if(lever)
		lever.icon_state = "lever_pulled"
	playsound(shy, 'sound/machines/click.ogg', 70, FALSE)
	var/obj/structure/chair/chair = new(get_turf(rainbow))
	chair.setDir(SOUTH)
	props["chair"] = chair
	chair.buckle_mob(rainbow, force = TRUE)
	rainbow.set_handcuffed(new /obj/item/restraints/handcuffs(rainbow))
	rainbow.update_handcuffed()
	playsound(rainbow, 'sound/items/weapons/handcuffs.ogg', 70, FALSE)

/// Fluttershy goes monstrous: bigger, red eyed, the saw revving.
/datum/ponymov/shed/proc/beat_monster()
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	shy.setDir(SOUTH)
	shy.set_eye_color(COLOR_RED, COLOR_RED)
	animate(shy, transform = matrix(1.35, 0, 0, 0, 1.35, 6), time = 1 SECONDS)
	playsound(shy, 'sound/items/weapons/chainsaw_loop.ogg', 80, FALSE)

/**
 * Rainbow sawn down the middle. Two copies of her, one half each, take her place, the saw left
 * in her; the left half peels away later (see beat_peel()).
 */
/datum/ponymov/shed/proc/beat_saw()
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	var/mob/living/carbon/human/rainbow = cast["rainbow"]
	playsound(rainbow, 'sound/items/weapons/chainsawhit.ogg', 90, FALSE)
	shy.vis_contents.Cut()
	splatter("shed", 11, 9, 8)
	new /obj/effect/decal/cleanable/blood/gibs(get_turf(rainbow))
	for(var/side in list("left", "right"))
		var/obj/effect/ponymov_scenery/half = scenery("[side] half", null, null, "shed", 11, 9)
		half.appearance = rainbow.appearance
		half.layer = rainbow.layer
		half.add_filter("half", 1, alpha_mask_filter(icon = icon('voidcrew/modules/ponymov/icons/ponymov.dmi', "[side]_half")))
	var/obj/effect/ponymov_scenery/guts = scenery("guts", 'voidcrew/modules/ponymov/icons/ponymov.dmi', "guts", "shed", 11, 9)
	guts.layer = rainbow.layer - 0.01
	var/obj/effect/ponymov_scenery/saw = scenery("chainsaw", 'icons/obj/weapons/chainsaw.dmi', "chainsaw_on", "shed", 11, 9, 0, 4)
	saw.transform = matrix().Turn(90)
	saw.layer = ABOVE_MOB_LAYER
	rainbow.alpha = 0

/datum/ponymov/shed/proc/beat_police()
	run_line(list(0, "place", "officer1", "shed", 10, 2, NORTH))
	run_line(list(0, "place", "officer2", "shed", 12, 2, NORTH))
	var/obj/structure/mineral_door/door = locate() in set_turf("shed", 11, 3)
	door?.Open()
	INVOKE_ASYNC(src, PROC_REF(police_lights))
	sleep(3.2 SECONDS)
	if(QDELETED(src))
		return
	run_line(list(0, "walk", "officer1", 10, 6, 1.5))
	run_line(list(0, "walk", "officer2", 12, 6, 1.5))

/datum/ponymov/shed/proc/police_lights()
	for(var/i in 1 to 6)
		animate(victim.client, color = "#e05050", time = 0.25 SECONDS)
		animate(color = "#5060f0", time = 0.25 SECONDS)
		sleep(0.5 SECONDS)
		if(QDELETED(src) || !victim?.client)
			return
	animate(victim.client, color = "#7080b0", time = 0.5 SECONDS)

/// Fluttershy, quite small and sweet again.
/datum/ponymov/shed/proc/beat_innocent()
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	var/list/look = parts["fluttershy"]
	shy.set_eye_color(look[6], look[6])
	animate(shy, transform = null, time = 0.6 SECONDS)
	shy.forceMove(set_turf("shed", 12, 9))
	shy.setDir(SOUTH)
	animate(victim.client, color = null, time = 1 SECONDS)

/datum/ponymov/shed/proc/beat_peel()
	var/obj/effect/ponymov_scenery/half = props["left half"]
	if(!half)
		return
	animate(half, transform = matrix().Turn(-75), pixel_w = -10, pixel_z = -8, time = 1.5 SECONDS, easing = BOUNCE_EASING)
	playsound(half, 'sound/effects/splat.ogg', 60, FALSE)

/// Off to the padded cell in a straitjacket, dragged.
/datum/ponymov/shed/proc/beat_asylum()
	var/mob/living/carbon/human/shy = cast["fluttershy"]
	shy.equip_to_slot_or_del(new /obj/item/clothing/suit/jacket/straight_jacket(shy), ITEM_SLOT_OCLOTHING)
	shy.equip_to_slot_or_del(new /obj/item/clothing/mask/muzzle(shy), ITEM_SLOT_MASK)
	shy.forceMove(set_turf("asylum", 11, 1))
	shy.set_body_position(LYING_DOWN)
	run_line(list(0, "place", "doctor1", "asylum", 10, 2, NORTH))
	run_line(list(0, "place", "doctor2", "asylum", 12, 2, NORTH))
	for(var/part in list("officer1", "officer2"))
		run_line(list(0, "hide", part))
	var/obj/structure/mineral_door/door = locate() in set_turf("asylum", 11, 3)
	door?.Open()
	var/mob/living/carbon/human/doctor1 = cast["doctor1"]
	var/mob/living/carbon/human/doctor2 = cast["doctor2"]
	for(var/y in 2 to 7)
		doctor1.Move(set_turf("asylum", 10, y + 1), NORTH)
		doctor2.Move(set_turf("asylum", 12, y + 1), NORTH)
		shy.Move(set_turf("asylum", 11, y), NORTH)
		sleep(0.7 SECONDS)
		if(QDELETED(src))
			return
	sleep(1 SECONDS)
	run_line(list(0, "walk", "doctor1", 10, 1, 2))
	run_line(list(0, "walk", "doctor2", 12, 1, 2))
	sleep(2.2 SECONDS)
	if(QDELETED(src))
		return
	run_line(list(0, "hide", "doctor1"))
	run_line(list(0, "hide", "doctor2"))
	door?.Close()

/// The Rainbow part ends sawn in half.
/datum/ponymov/shed/victim_fate()
	if(role != "rainbow")
		return
	for(var/zone in list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG))
		var/obj/item/bodypart/limb = victim.get_bodypart(zone)
		limb?.dismember()
	victim.death()
