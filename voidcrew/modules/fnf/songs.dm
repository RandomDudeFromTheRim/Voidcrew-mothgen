/**
 * Songs for rhythm battles.
 *
 * A song is a folder holding Inst.ogg, the singers' Voices-<who>.ogg, and the charts in
 * Friday Night Funkin's own format: <id>-chart.json and <id>-metadata.json. Notes are
 * {"t": time in ms, "d": lane, "l": hold length in ms}; lanes 0-3 (left, down, up, right) are
 * the player's, 4-7 the opponent's.
 *
 * Charts in the older format most mods use (Psych Engine and the like) work too: <id>.json for
 * normal and <id>-<difficulty>.json for the rest, each {"song": {"notes": [sections]}}, with
 * Inst.ogg and either Voices.ogg or separate Voices-Player.ogg and Voices-Opponent.ogg.
 *
 * One song ships with the game. Real Funkin' songs can't, but tools/fnf/fetch_funkin.py
 * downloads them into data/fnf/songs/, and any song folder in there (a mod's included) shows up
 * in the song list.
 */

/// Folders to look for songs in.
GLOBAL_LIST_INIT(fnf_song_dirs, list("voidcrew/modules/fnf/songs/", "data/fnf/songs/"))

/// Every playable song, by name. Filled the first time a microphone asks.
GLOBAL_LIST(fnf_songs)

/// Each player's own audio offset in milliseconds, by ckey: how late their sound comes out.
GLOBAL_LIST_EMPTY(fnf_offsets)

/proc/get_fnf_songs(refresh = FALSE)
	if(GLOB.fnf_songs && !refresh)
		return GLOB.fnf_songs
	var/list/songs = list()
	for(var/base in GLOB.fnf_song_dirs)
		for(var/entry in flist(base))
			if(copytext(entry, -1) != "/")
				continue
			var/datum/fnf_song/song = new("[base][entry]", copytext(entry, 1, -1))
			if(!song.valid)
				qdel(song)
				continue
			var/name = song.name
			if(songs[name])
				name = "[name] ([song.id])"
			songs[name] = song
	GLOB.fnf_songs = sort_list(songs)
	return GLOB.fnf_songs

/// Reads a JSON file, or returns null if it's missing or broken.
/proc/fnf_read_json(path)
	if(!fexists(path))
		return null
	try
		return json_decode(file2text(path))
	catch
		return null

/// A character's name without its variant: "mom" for "mom-car", "senpai" for "senpai-angry".
/proc/fnf_base_character(character)
	if(!istext(character))
		return null
	var/hyphen = findtext(character, "-")
	return hyphen ? copytext(character, 1, hyphen) : character

/proc/cmp_fnf_note(list/a, list/b)
	return a[1] - b[1]

/datum/fnf_song
	/// The folder name, and the start of the chart files' names.
	var/id
	/// The folder, with a trailing slash.
	var/path
	var/name
	var/artist = "Unknown"
	var/bpm = 100
	var/list/difficulties = list()
	var/inst_file
	var/player_voice_file
	var/opponent_voice_file
	/// Who sings against you, as Funkin' names them without variants ("mom" for "mom-car"). Decides
	/// who turns up when nobody's been challenged; see opponents.dm.
	var/opponent_character
	/// Whether there's enough here to play.
	var/valid = FALSE
	/// For charts in the older format, each difficulty's chart file.
	var/list/legacy_files

/datum/fnf_song/New(path, id)
	src.path = path
	src.id = id
	name = id
	if(!fexists("[path]Inst.ogg"))
		return
	inst_file = "[path]Inst.ogg"
	var/list/chart = fnf_read_json("[path][id]-chart.json")
	if(!islist(chart?["notes"]))
		read_legacy()
		return
	var/list/meta = fnf_read_json("[path][id]-metadata.json")
	if(meta)
		name = meta["songName"] || id
		artist = meta["artist"] || artist
		var/list/changes = meta["timeChanges"]
		if(length(changes))
			var/list/first_change = changes[1]
			bpm = first_change["bpm"] || bpm
		var/list/characters = meta["playData"]?["characters"]
		player_voice_file = find_voice(characters?["playerVocals"], characters?["player"])
		opponent_voice_file = find_voice(characters?["opponentVocals"], characters?["opponent"])
		opponent_character = fnf_base_character(characters?["opponent"])
	if(!player_voice_file && fexists("[path]Voices.ogg"))
		player_voice_file = "[path]Voices.ogg"
	var/list/notes = chart["notes"]
	for(var/difficulty in notes)
		difficulties += difficulty
	valid = length(difficulties) > 0

/// Reads a song charted in the older format, one file per difficulty.
/datum/fnf_song/proc/read_legacy()
	legacy_files = list()
	var/list/first_song
	for(var/file_name in flist(path))
		if(copytext(file_name, -5) != ".json")
			continue
		var/stem = copytext(file_name, 1, -5)
		var/difficulty
		if(stem == id)
			difficulty = "normal"
		else if(findtext(stem, "[id]-") == 1)
			difficulty = copytext(stem, length(id) + 2)
		if(!difficulty || difficulty == "metadata" || difficulty == "chart" || difficulty == "events")
			continue
		var/list/file_data = fnf_read_json("[path][file_name]")
		var/list/song = file_data?["song"]
		if(!islist(song?["notes"]))
			continue
		legacy_files[difficulty] = file_name
		difficulties += difficulty
		if(!first_song)
			first_song = song
	if(!first_song)
		return
	name = first_song["song"] || id
	if(isnum(first_song["bpm"]))
		bpm = first_song["bpm"]
	if(fexists("[path]Voices-Player.ogg"))
		player_voice_file = "[path]Voices-Player.ogg"
	else
		player_voice_file = find_voice(null, first_song["player1"])
	opponent_character = fnf_base_character(first_song["player2"])
	if(fexists("[path]Voices-Opponent.ogg"))
		opponent_voice_file = "[path]Voices-Opponent.ogg"
	else
		opponent_voice_file = find_voice(null, first_song["player2"])
	if(!player_voice_file && fexists("[path]Voices.ogg"))
		player_voice_file = "[path]Voices.ogg"
	valid = TRUE

/// The first Voices-<name>.ogg that exists for these singers. Funkin' names variants like
/// "bf-car", while the file is just Voices-bf, so the part before any hyphen is tried too.
/datum/fnf_song/proc/find_voice(list/vocals, character)
	var/list/candidates = list()
	for(var/vocal in vocals)
		candidates += "[vocal]"
	if(character)
		candidates += "[character]"
	for(var/candidate in candidates.Copy())
		var/hyphen = findtext(candidate, "-")
		if(hyphen)
			candidates |= copytext(candidate, 1, hyphen)
	for(var/candidate in candidates)
		if(fexists("[path]Voices-[candidate].ogg"))
			return "[path]Voices-[candidate].ogg"

/**
 * Loads one difficulty's chart. Returns list("player" = notes, "opponent" = notes,
 * "events" = events, "speed" = scroll speed), with each note a list(time in ms, lane 0-3,
 * hold length in ms), in time order.
 */
/datum/fnf_song/proc/load_chart(difficulty)
	if(legacy_files)
		return load_legacy_chart(difficulty)
	var/list/chart = fnf_read_json("[path][id]-chart.json")
	var/list/raw = chart?["notes"]?[difficulty]
	var/list/player = list()
	var/list/opponent = list()
	for(var/list/note in raw)
		var/lane = note["d"]
		var/time = note["t"]
		if(!isnum(lane) || !isnum(time) || lane < 0 || lane > 7)
			continue
		// Notes that hurt to hit are a mechanic of their own, not played here.
		var/kind = note["k"]
		if(istext(kind) && (findtext(kind, "hurt") || findtext(kind, "mine")))
			continue
		var/hold = note["l"]
		var/list/entry = list(time, lane % 4, isnum(hold) ? max(hold, 0) : 0)
		if(lane < 4)
			player += list(entry)
		else
			opponent += list(entry)
	sortTim(player, GLOBAL_PROC_REF(cmp_fnf_note))
	sortTim(opponent, GLOBAL_PROC_REF(cmp_fnf_note))
	var/speed = chart?["scrollSpeed"]
	if(islist(speed))
		var/list/speeds = speed
		speed = speeds[difficulty] || speeds["default"] || speeds["normal"]
	if(!isnum(speed))
		speed = 1.3
	var/list/events = list()
	for(var/list/event in chart?["events"])
		if(isnum(event["t"]))
			events += list(event)
	return list("player" = remove_stacked(player), "opponent" = remove_stacked(opponent), "events" = events, "speed" = speed)

/// The older format: the notes come in sections, and each section says whose turn it is. Lanes
/// 0-3 are whoever's turn it is, 4-7 the other singer, except in Psych Engine 1.0 charts,
/// where 0-3 are always the player.
/datum/fnf_song/proc/load_legacy_chart(difficulty)
	var/list/file_data = fnf_read_json("[path][legacy_files[difficulty]]")
	var/list/song = file_data?["song"]
	var/fixed_lanes = findtext("[song?["format"]]", "psych_v1")
	var/list/player = list()
	var/list/opponent = list()
	for(var/list/section in song?["notes"])
		var/players_turn = section["mustHitSection"]
		for(var/list/raw in section["sectionNotes"])
			if(length(raw) < 2)
				continue
			var/time = raw[1]
			var/lane = raw[2]
			if(!isnum(time) || !isnum(lane) || lane < 0 || lane > 7)
				continue
			var/kind = length(raw) >= 4 ? raw[4] : null
			if(istext(kind) && (findtext(kind, "hurt") || findtext(kind, "mine")))
				continue
			var/hold = length(raw) >= 3 ? raw[3] : 0
			var/list/entry = list(time, lane % 4, isnum(hold) ? max(hold, 0) : 0)
			var/players_note = fixed_lanes ? lane < 4 : (players_turn ? lane < 4 : lane >= 4)
			if(players_note)
				player += list(entry)
			else
				opponent += list(entry)
	sortTim(player, GLOBAL_PROC_REF(cmp_fnf_note))
	sortTim(opponent, GLOBAL_PROC_REF(cmp_fnf_note))
	var/speed = song?["speed"]
	return list("player" = remove_stacked(player), "opponent" = remove_stacked(opponent), "events" = list(), "speed" = isnum(speed) ? speed : 1.3)

/// Drops notes charted twice on the same lane at the same time.
/datum/fnf_song/proc/remove_stacked(list/notes)
	. = list()
	var/list/last_by_lane = list()
	for(var/list/note as anything in notes)
		var/lane_key = "[note[2]]"
		var/last_time = last_by_lane[lane_key]
		if(!isnull(last_time) && note[1] - last_time < 5)
			continue
		last_by_lane[lane_key] = note[1]
		. += list(note)
