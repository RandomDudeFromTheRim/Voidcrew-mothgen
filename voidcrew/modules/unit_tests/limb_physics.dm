/// A physics ragdoll's bones come from the rig's skeleton, every piece of the rig follows them, and
/// joints bend the right way facing either side. With the physics library present, a ragdoll
/// steps, stays in one piece, and hands the body back to its animations after.
/datum/unit_test/limb_physics

/datum/unit_test/limb_physics/Run()
	for(var/species_type in list(/datum/species/experiment, /datum/species/human, /datum/species/lizard))
		var/mob/living/carbon/human/consistent/body = allocate(/mob/living/carbon/human/consistent)
		body.set_species(species_type)
		body.update_limb_rig()
		var/datum/limb_rig/sprites/rig = body.limb_rig
		TEST_ASSERT(istype(rig), "[species_type] has no sprite-built rig to simulate.")
		for(var/facing in list(EAST, SOUTH))
			var/list/segments = rig.get_physics_segments(facing)
			TEST_ASSERT_EQUAL(length(segments), 12, "[species_type] facing [dir2text(facing)] has the wrong number of physics segments.")
			var/list/identity = list()
			for(var/part_id in segments)
				var/list/segment = segments[part_id]
				TEST_ASSERT(segment["width"] > 0 && segment["density"] > 0, "[part_id] on [species_type] has no size or weight.")
				if(part_id != "chest")
					TEST_ASSERT(segments[segment["parent"]], "[part_id] on [species_type] hangs off a segment that isn't there.")
				identity[part_id] = matrix()
			// Every piece of the rig gets put somewhere: body, clothes, shoes, held items, the pivot.
			var/list/matrices = rig.get_physics_matrices(identity, facing)
			for(var/part_id in rig.parts)
				TEST_ASSERT(matrices[rig.parts[part_id]], "[species_type]'s [part_id] piece isn't placed by physics.")
			for(var/part_id in rig.cloth_parts)
				TEST_ASSERT(matrices[rig.cloth_parts[part_id]], "[species_type]'s [part_id] clothes aren't placed by physics.")
			for(var/side in list("l", "r"))
				TEST_ASSERT(matrices[rig.shoe_parts[side]] && matrices[rig.item_parts[side]], "[species_type]'s [side] shoe or held item isn't placed by physics.")
			TEST_ASSERT(matrices[rig.pivot], "[species_type]'s torso pivot isn't reset by physics.")

	// Elbows and knees bend one way facing east, and the other facing west.
	var/list/east_elbow = limb_physics_joint_limits("elbow", EAST)
	var/list/west_elbow = limb_physics_joint_limits("elbow", WEST)
	TEST_ASSERT(east_elbow[1] >= 0 && east_elbow[2] > 0, "An elbow facing east bends backwards.")
	TEST_ASSERT(west_elbow[1] < 0 && west_elbow[2] <= 0, "An elbow facing west isn't mirrored.")

	// A point pushed through a turn and back comes out where it started.
	var/matrix/turned = rig_joint_matrix(10, 20, 1, 30, 14, 5)
	var/list/at = rig_apply_matrix(turned, 10, 20)
	TEST_ASSERT(abs(at[1] - 14) < 0.001 && abs(at[2] - 5) < 0.001, "rig_apply_matrix() doesn't put a joint where rig_joint_matrix() moved it.")
	TEST_ASSERT(abs(rig_matrix_angle(turned) + 30) < 0.001, "rig_matrix_angle() doesn't read a turn back.")

	if(!vcphys_available())
		return
	var/mob/living/carbon/human/consistent/ragdoll = allocate(/mob/living/carbon/human/consistent)
	ragdoll.set_species(/datum/species/experiment)
	ragdoll.update_limb_rig()
	TEST_ASSERT(ragdoll.set_limb_physics(TRUE), "A ragdoll couldn't go physical with the library loaded.")
	var/datum/limb_physics/physics = ragdoll.limb_rig.physics
	TEST_ASSERT_EQUAL(length(physics.body_by_part), 12, "The ragdoll is missing bodies.")
	TEST_ASSERT_EQUAL(length(physics.joint_by_part), 11, "The ragdoll is missing joints.")
	physics.push("chest", 30, 5)
	for(var/i in 1 to 20)
		physics.process(0.1)
	TEST_ASSERT(!QDELETED(physics), "The ragdoll's simulation blew up.")
	TEST_ASSERT_EQUAL(physics.steps, 20 * 6, "The ragdoll didn't take a fixed number of steps.")
	ragdoll.set_limb_physics(FALSE)
	TEST_ASSERT_NULL(ragdoll.limb_rig.physics, "Turning physics off left it on.")
