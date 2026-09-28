/// The song that ships with the game loads, with both singers' vocals and some long notes.
/datum/unit_test/fnf_song

/datum/unit_test/fnf_song/Run()
	var/list/songs = get_fnf_songs(refresh = TRUE)
	var/datum/fnf_song/song = songs["Yip Yap"]
	TEST_ASSERT_NOTNULL(song, "The bundled song did not load.")
	TEST_ASSERT_NOTNULL(song.player_voice_file, "The bundled song has no player vocals.")
	TEST_ASSERT_NOTNULL(song.opponent_voice_file, "The bundled song has no opponent vocals.")
	var/list/chart = song.load_chart("normal")
	TEST_ASSERT(length(chart["player"]) > 50, "The bundled chart has too few player notes.")
	TEST_ASSERT(length(chart["opponent"]) > 50, "The bundled chart has too few opponent notes.")
	var/holds = 0
	for(var/list/note as anything in chart["player"])
		if(note[3] > 0)
			holds++
	TEST_ASSERT(holds > 0, "The bundled chart has no long notes.")

/// A lone challenger gets an Experiment to sing against, the game plays both sides when nobody's
/// at the keys, and the summoned singer goes when the battle does.
/datum/unit_test/fnf_battle

/datum/unit_test/fnf_battle/Run()
	var/list/songs = get_fnf_songs(refresh = TRUE)
	var/datum/fnf_song/song = songs["Yip Yap"]
	var/mob/living/carbon/human/consistent/challenger = allocate(/mob/living/carbon/human/consistent)
	var/datum/fnf_battle/battle = new(song, "normal")
	battle.start(challenger, null)
	var/mob/living/carbon/human/npc = battle.npc
	TEST_ASSERT_NOTNULL(npc, "No opponent was summoned for a lone challenger.")
	TEST_ASSERT(is_species(npc, /datum/species/experiment), "The summoned opponent is not an Experiment.")
	TEST_ASSERT(battle.left.is_cpu && battle.right.is_cpu, "Singers without players are not played by the game.")

	// Twenty-five seconds in, past both singers' first verses: everything due so far gets sung.
	battle.start_time = world.time - 250
	battle.state = 2
	battle.tick()
	TEST_ASSERT(battle.right.score > 0, "The challenger's side sang nothing.")
	TEST_ASSERT(battle.left.score > 0, "The opponent's side sang nothing.")
	TEST_ASSERT_EQUAL(battle.right.misses, 0, "The game missed notes it was playing itself.")
	TEST_ASSERT_EQUAL(battle.health, 50, "The game playing itself moved the health bar.")

	qdel(battle)
	TEST_ASSERT(QDELETED(npc), "The summoned opponent stayed after the battle.")
