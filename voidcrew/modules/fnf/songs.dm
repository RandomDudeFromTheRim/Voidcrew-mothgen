/**
 * Songs for rhythm battles.
 *
 * A song is a folder holding Inst.ogg, the singers' Voices-<who>.ogg, and the charts in
 * Friday Night Funkin's own format: <id>-chart.json and <id>-metadata.json. Notes are
 * {"t": time in ms, "d": lane, "l": hold length in ms, "k": kind}; lanes 0-3 (left, down, up,
 * right) are the player's, 4-7 the opponent's.
 *
 * A song can come in variations (Erect remixes, Pico mixes), each its own entry in the song list:
 * <id>-chart-<variation>.json and <id>-metadata-<variation>.json, with Inst-<instrumental>.ogg and
 * Voices-<who>-<variation>.ogg. A Pico mix has you singing as Pico, gun and all. Lyrics, where a
 * song has them, are in subtitles/song-lyrics[-<variation>].srt.
 *
 * Songs are picked by week, as Funkin' groups them (data/fnf/weeks/, fetched with the songs).
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

/// The weeks songs are picked from, in order: list(list("name" = label, "songs" = list(song, ...)), ...).
GLOBAL_LIST(fnf_weeks)

/// Where the week lists are.
#define FNF_WEEKS_DIR "data/fnf/weeks/"

/// Funkin's own weeks, for when the week lists weren't fetched with the songs.
GLOBAL_LIST_INIT(fnf_default_weeks, list(
	"sserafim" = list("name" = "LE SSERAFIM", "songs" = list("spaghetti")),
	"tutorial" = list("name" = "TEACHING TIME", "songs" = list("tutorial")),
	"week1" = list("name" = "DADDY DEAREST", "songs" = list("bopeebo", "fresh", "dadbattle")),
	"week2" = list("name" = "SPOOKY MONTH", "songs" = list("spookeez", "south", "monster")),
	"week3" = list("name" = "PICO", "songs" = list("pico", "philly-nice", "blammed")),
	"week4" = list("name" = "MOMMY MUST MURDER", "songs" = list("satin-panties", "high", "milf")),
	"week5" = list("name" = "RED SNOW", "songs" = list("cocoa", "eggnog", "winter-horrorland")),
	"week6" = list("name" = "HATING SIMULATOR FT. MOAWLING", "songs" = list("senpai", "roses", "thorns")),
	"week7" = list("name" = "TANKMAN FT. JOHNNYUTAH", "songs" = list("ugh", "guns", "stress")),
	"weekend1" = list("name" = "DUE DEBTS", "songs" = list("darnell", "lit-up", "2hot", "blazin")),
))

/// Each player's own audio offset in milliseconds, by ckey: how late their sound comes out.
GLOBAL_LIST_EMPTY(fnf_offsets)

/// Players who'd rather their screen didn't zoom in while they sing, by ckey.
GLOBAL_LIST_EMPTY(fnf_no_zoom)

/proc/get_fnf_songs(refresh = FALSE)
	if(GLOB.fnf_songs && !refresh)
		return GLOB.fnf_songs
	var/list/songs = list()
	for(var/base in GLOB.fnf_song_dirs)
		for(var/entry in flist(base))
			if(copytext(entry, -1) != "/")
				continue
			var/datum/fnf_song/song = new("[base][entry]", copytext(entry, 1, -1))
			var/list/versions = list(song)
			for(var/variation in song.variations)
				versions += new /datum/fnf_song("[base][entry]", song.id, variation)
			for(var/datum/fnf_song/version as anything in versions)
				if(!version.valid)
					qdel(version)
					continue
				var/name = version.name
				if(songs[name])
					name = "[name] ([version.id])"
				version.list_name = name
				songs[name] = version
	GLOB.fnf_songs = sort_list(songs)
	GLOB.fnf_weeks = null
	return GLOB.fnf_songs

/**
 * The songs grouped into weeks, as Funkin' has them: Week 1 is Bopeebo, Fresh and Dadbattle, with
 * each one's Erect and Pico mixes right after it. Anything in no week (mods, the song that ships
 * with the game) ends up in "Other songs".
 */
/proc/get_fnf_weeks()
	var/list/songs = get_fnf_songs()
	if(GLOB.fnf_weeks)
		return GLOB.fnf_weeks
	var/list/by_id = list()
	for(var/name in songs)
		var/datum/fnf_song/song = songs[name]
		LAZYADD(by_id[song.id], song)
	var/list/weeks = list()
	var/list/week_files = list()
	for(var/file_name in flist(FNF_WEEKS_DIR))
		if(copytext(file_name, -5) == ".json")
			week_files += copytext(file_name, 1, -5)
	// Fetched week lists, and Funkin's own for any that weren't (a mod's songs fetched on their own).
	var/list/week_ids = week_files | assoc_to_keys(GLOB.fnf_default_weeks)
	sortTim(week_ids, GLOBAL_PROC_REF(cmp_fnf_week))
	for(var/week_id in week_ids)
		var/list/week = (week_id in week_files) ? fnf_read_json("[FNF_WEEKS_DIR][week_id].json") : GLOB.fnf_default_weeks[week_id]
		var/list/week_songs = list()
		for(var/song_id in week?["songs"])
			week_songs += by_id[song_id]
			by_id -= song_id
		if(length(week_songs))
			weeks += list(list("name" = "[fnf_week_label(week_id)]: [capitalize(lowertext(week["name"] || week_id))]", "songs" = week_songs))
	var/list/others = list()
	for(var/song_id in by_id)
		others += by_id[song_id]
	if(length(others))
		weeks += list(list("name" = "Other songs", "songs" = others))
	GLOB.fnf_weeks = weeks
	return weeks

/// "Week 1" for week1, "Weekend 1" for weekend1, "Tutorial" for tutorial, "Corruption+ 1" for Corruption+'s.
/proc/fnf_week_label(week_id)
	if(findtext(week_id, "corruption-") == 1)
		return "Corruption+ [copytext(week_id, 12)]"
	if(findtext(week_id, "weekend") == 1)
		return "Weekend [copytext(week_id, 8)]"
	if(findtext(week_id, "week") == 1)
		return "Week [copytext(week_id, 5)]"
	return capitalize(week_id)

/// The tutorial first, then the weeks in order, then the weekends, then Corruption+, then anything else.
/proc/cmp_fnf_week(week_a, week_b)
	var/rank_a = fnf_week_rank(week_a)
	var/rank_b = fnf_week_rank(week_b)
	if(rank_a != rank_b)
		return rank_a - rank_b
	return sorttext(week_b, week_a)

/proc/fnf_week_rank(week_id)
	if(week_id == "tutorial")
		return 0
	if(findtext(week_id, "weekend") == 1)
		return 2000 + (text2num(copytext(week_id, 8)) || 0)
	if(findtext(week_id, "corruption-") == 1)
		return 2500 + (text2num(copytext(week_id, 12)) || 0)
	if(findtext(week_id, "week") == 1)
		return 1000 + (text2num(copytext(week_id, 5)) || 0)
	return 3000

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
	/// Which mix this is ("erect", "pico"), or null for the original.
	var/variation
	/// The original's other mixes, to make songs of their own.
	var/list/variations = list()
	/// What it's called in the song list.
	var/list_name
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
	/// Who you sing as: "bf" usually, "pico" in a Pico mix.
	var/player_character = "bf"
	/// The same, with Funkin's variant on it: "bf-holding-gf" in Stress, carrying the girlfriend.
	var/player_variant
	/// Who cheers you on from the back, if anyone ("gf", "nene").
	var/girlfriend_character
	/// Timed lyrics, from the song's subtitles: list(list(start ms, end ms, text), ...).
	var/list/lyrics
	/// Whether there's enough here to play.
	var/valid = FALSE
	/// For charts in the older format, each difficulty's chart file.
	var/list/legacy_files
	/// Who an older-format chart starts with, as it names them: list("player", "opponent", "gf").
	var/list/legacy_cast
	/// Its "Change Character" events: list(list(ms, "player"/"opponent"/"gf", character), ...).
	var/list/character_changes
	/// Whether it's one of Corruption+'s (see corruption.dm): its player is one of the mod's characters.
	var/corruption = FALSE
	/// Which arrows its notes are drawn with, if not ours: "kapi" or "skarlet", Corruption+'s tainted skins.
	var/note_skin
	/// Its "Overlay Event" and "Image Flash" events: list(list(ms, "overlay"/"flash", image, value), ...).
	var/list/overlay_events

/datum/fnf_song/New(path, id, variation)
	src.path = path
	src.id = id
	src.variation = variation
	name = id
	var/suffix = variation ? "-[variation]" : ""
	var/list/chart = fnf_read_json("[path][id]-chart[suffix].json")
	if(!islist(chart?["notes"]))
		if(!variation && fexists("[path]Inst.ogg"))
			inst_file = "[path]Inst.ogg"
			read_legacy()
		return
	var/list/meta = fnf_read_json("[path][id]-metadata[suffix].json")
	var/list/characters = meta?["playData"]?["characters"]
	var/instrumental = characters?["instrumental"] || variation
	if(instrumental && fexists("[path]Inst-[instrumental].ogg"))
		inst_file = "[path]Inst-[instrumental].ogg"
	else if(fexists("[path]Inst.ogg"))
		inst_file = "[path]Inst.ogg"
	else
		return
	if(meta)
		name = meta["songName"] || id
		artist = meta["artist"] || artist
		var/list/changes = meta["timeChanges"]
		if(length(changes))
			var/list/first_change = changes[1]
			bpm = first_change["bpm"] || bpm
		player_voice_file = find_voice(characters?["playerVocals"], characters?["player"])
		opponent_voice_file = find_voice(characters?["opponentVocals"], characters?["opponent"])
		opponent_character = fnf_base_character(characters?["opponent"])
		player_character = fnf_base_character(characters?["player"]) || player_character
		player_variant = characters?["player"]
		girlfriend_character = fnf_base_character(characters?["girlfriend"])
		if(!variation)
			for(var/other in meta["playData"]?["songVariations"])
				variations += "[other]"
	if(!player_voice_file && fexists("[path]Voices[suffix].ogg"))
		player_voice_file = "[path]Voices[suffix].ogg"
	if(!player_voice_file && fexists("[path]Voices.ogg"))
		player_voice_file = "[path]Voices.ogg"
	// The metadata says which are difficulties: charts also hold extra tracks under their own names
	// (Stress's "picospeaker", the speaker's shots), which aren't songs to sing.
	var/list/notes = chart["notes"]
	var/list/listed = meta?["playData"]?["difficulties"]
	for(var/difficulty in (length(listed) ? listed : notes))
		if(islist(notes[difficulty]) && difficulty != "picospeaker")
			difficulties += difficulty
	lyrics = read_lyrics("[path]subtitles/song-lyrics[suffix].srt")
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
	legacy_cast = list("player" = first_song["player1"], "opponent" = first_song["player2"], "gf" = first_song["gfVersion"] || first_song["player3"])
	character_changes = read_character_changes(first_song)
	overlay_events = read_overlay_events(first_song)
	var/static/list/skins = list("NOTE_assetsKapi" = "kapi", "NOTE_assetsSkarlet" = "skarlet")
	note_skin = skins[first_song["arrowSkin"]]
	if(fexists("[path]Voices-Player.ogg"))
		player_voice_file = "[path]Voices-Player.ogg"
	else
		player_voice_file = find_voice(null, first_song["player1"])
	opponent_character = fnf_base_character(first_song["player2"])
	// Corruption+'s songs: its characters, as their looks here.
	if(GLOB.fnf_corruption_cast[legacy_cast["player"]])
		corruption = TRUE
		opponent_character = GLOB.fnf_corruption_cast[legacy_cast["opponent"]]?["look"]
		// Whoever's behind the speakers, wherever in the song they turn up first.
		girlfriend_character = GLOB.fnf_corruption_cast[legacy_cast["gf"]]?["look"]
		for(var/list/change as anything in character_changes)
			if(!girlfriend_character && change[2] == "gf")
				girlfriend_character = GLOB.fnf_corruption_cast[change[3]]?["look"]
	if(fexists("[path]Voices-Opponent.ogg"))
		opponent_voice_file = "[path]Voices-Opponent.ogg"
	else
		opponent_voice_file = find_voice(null, first_song["player2"])
	if(!player_voice_file && fexists("[path]Voices.ogg"))
		player_voice_file = "[path]Voices.ogg"
	valid = TRUE

/**
 * An older-format song's "Change Character" events, from its chart and its events.json (Psych
 * Engine keeps them in either, or both), in order: list(list(ms, role, character), ...).
 */
/datum/fnf_song/proc/read_character_changes(list/song_data)
	var/list/raw = read_raw_events(song_data)
	var/static/list/roles = list("0" = "player", "bf" = "player", "boyfriend" = "player", "1" = "opponent", "dad" = "opponent", "2" = "gf", "gf" = "gf", "girlfriend" = "gf")
	var/list/seen = list()
	. = list()
	for(var/list/entry as anything in raw)
		var/list/events = entry[2]
		if(!islist(events))
			continue
		for(var/list/event in events)
			if(length(event) < 3 || event[1] != "Change Character")
				continue
			var/role = roles[lowertext(trim("[event[2]]"))]
			var/key = "[entry[1]]-[role]-[event[3]]"
			if(!role || seen[key])
				continue
			seen[key] = TRUE
			. += list(list(entry[1], role, "[event[3]]"))
	sortTim(., GLOBAL_PROC_REF(cmp_fnf_note))

/// An older-format song's events, as Psych Engine keeps them: list(list(ms, list(list(name, value, value), ...)), ...).
/datum/fnf_song/proc/read_raw_events(list/song_data)
	. = list()
	for(var/list/entry in song_data["events"])
		if(length(entry) >= 2)
			. += list(entry)
	var/list/events_file = fnf_read_json("[path]events.json")
	for(var/list/entry in events_file?["song"]?["events"])
		if(length(entry) >= 2)
			. += list(entry)

/**
 * An older-format song's overlays (Corruption+'s "Overlay Event": 1 fades an image in, 0 fades it
 * out) and flashes ("Image Flash": an image up for so many seconds), in order, once each.
 */
/datum/fnf_song/proc/read_overlay_events(list/song_data)
	var/list/seen = list()
	. = list()
	for(var/list/entry as anything in read_raw_events(song_data))
		var/list/events = entry[2]
		if(!islist(events))
			continue
		for(var/list/event in events)
			if(length(event) < 3)
				continue
			var/list/found
			if(event[1] == "Overlay Event")
				found = list(entry[1], "overlay", "[event[3]]", text2num("[event[2]]"))
			else if(event[1] == "Image Flash")
				found = list(entry[1], "flash", "[event[2]]", text2num("[event[3]]"))
			if(!found)
				continue
			var/key = jointext(found, "-")
			if(seen[key])
				continue
			seen[key] = TRUE
			. += list(found)
	sortTim(., GLOBAL_PROC_REF(cmp_fnf_note))

/// The first Voices-<name>.ogg that exists for these singers. Funkin' names variants like
/// "bf-car", while the file is just Voices-bf, so the part before any hyphen is tried too. A mix's
/// own recording (Voices-pico-pico.ogg for the Pico mix) comes before the original's.
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
	if(variation)
		var/list/mixed = list()
		for(var/candidate in candidates)
			mixed += "[candidate]-[variation]"
		candidates = mixed + candidates
	for(var/candidate in candidates)
		if(fexists("[path]Voices-[candidate].ogg"))
			return "[path]Voices-[candidate].ogg"

/// Reads timed lyrics from a SubRip (.srt) file: list(list(start ms, end ms, text), ...), or null.
/datum/fnf_song/proc/read_lyrics(file_path)
	if(!fexists(file_path))
		return null
	. = list()
	var/list/lines = splittext(replacetext(file2text(file_path), ascii2text(13), ""), "\n")
	var/index = 1
	while(index <= length(lines))
		var/line = lines[index]
		index++
		var/arrow = findtext(line, "-->")
		if(!arrow)
			continue
		var/start = fnf_srt_time(copytext(line, 1, arrow))
		var/finish = fnf_srt_time(copytext(line, arrow + 3))
		var/list/text_lines = list()
		while(index <= length(lines) && length(trim(lines[index])))
			text_lines += trim(lines[index])
			index++
		if(!isnull(start) && !isnull(finish) && length(text_lines))
			. += list(list(start, finish, jointext(text_lines, " ")))

/// "00:01:02,500" as milliseconds.
/proc/fnf_srt_time(text)
	var/list/parts = splittext(trim(replacetext(text, ",", ".")), ":")
	if(length(parts) != 3)
		return null
	var/hours = text2num(parts[1])
	var/minutes = text2num(parts[2])
	var/seconds = text2num(parts[3])
	if(isnull(hours) || isnull(minutes) || isnull(seconds))
		return null
	return round(((hours * 60 + minutes) * 60 + seconds) * 1000)

/**
 * Loads one difficulty's chart. Returns list("player" = notes, "opponent" = notes,
 * "events" = events, "speed" = scroll speed, "speaker" = list(list(ms, direction), ...)), with each note a list(time in ms, lane 0-3,
 * hold length in ms, kind or null), in time order.
 */
/datum/fnf_song/proc/load_chart(difficulty)
	if(legacy_files)
		return load_legacy_chart(difficulty)
	var/list/chart = fnf_read_json("[path][id]-chart[variation ? "-[variation]" : ""].json")
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
		var/list/entry = list(time, lane % 4, isnum(hold) ? max(hold, 0) : 0, istext(kind) ? kind : null)
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
	// Stress's speaker track: when (and which way) whoever's on the speaker shoots a tankman.
	var/list/speaker = list()
	for(var/list/shot in chart?["notes"]?["picospeaker"])
		if(isnum(shot["t"]) && isnum(shot["d"]))
			speaker += list(list(shot["t"], shot["d"]))
	sortTim(speaker, GLOBAL_PROC_REF(cmp_fnf_note))
	return list("player" = remove_stacked(player), "opponent" = remove_stacked(opponent), "events" = events, "speed" = speed, "speaker" = speaker)

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
			var/list/entry = list(time, lane % 4, isnum(hold) ? max(hold, 0) : 0, istext(kind) ? kind : null)
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

#undef FNF_WEEKS_DIR
