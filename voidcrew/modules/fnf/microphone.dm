/// Starts rhythm battles. Pick a song in hand, then sing it at someone, or at nobody and see
/// who turns up.
/obj/item/fnf_microphone
	name = "battle microphone"
	desc = "A chunky wireless microphone with four coloured arrows down its handle. It feels like it wants a rival."
	icon = 'icons/obj/service/broadcast.dmi'
	icon_state = "microphone"
	inhand_icon_state = "microphone"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	/// The battle this microphone has lined up or is running.
	var/datum/fnf_battle/battle

/obj/item/fnf_microphone/Destroy()
	if(battle?.state == FNF_STATE_READY)
		QDEL_NULL(battle)
	battle = null
	return ..()

/obj/item/fnf_microphone/examine(mob/user)
	. = ..()
	if(battle?.state == FNF_STATE_READY)
		. += span_notice("It's cued up to [battle.song.name] ([battle.difficulty]).")
	. += span_notice("Alt-click it to set how late your speakers are.")

/obj/item/fnf_microphone/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(battle && battle.state != FNF_STATE_READY)
		balloon_alert(user, "mid-song!")
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(pick_song), user)
	return TRUE

/obj/item/fnf_microphone/proc/pick_song(mob/living/user)
	var/list/songs = get_fnf_songs()
	if(!length(songs))
		balloon_alert(user, "no songs!")
		return
	var/choice = tgui_input_list(user, "Pick a song", "Rhythm battle", songs)
	var/datum/fnf_song/song = songs[choice]
	if(!song || !user.is_holding(src))
		return
	var/difficulty = song.difficulties[1]
	if(length(song.difficulties) > 1)
		var/default = ("hard" in song.difficulties) ? "hard" : song.difficulties[1]
		difficulty = tgui_input_list(user, "How hard?", "Rhythm battle", song.difficulties, default)
		if(!difficulty || !user.is_holding(src))
			return
	var/rival = tgui_alert(user, "Who are you singing against?", "Rhythm battle", list("Summon someone", "I'll pick someone"))
	if(!rival || !user.is_holding(src))
		return
	if(battle && battle.state != FNF_STATE_READY)
		return
	QDEL_NULL(battle)
	battle = new(song, difficulty, src)
	battle.preload(user)
	if(rival == "Summon someone")
		battle.start(user, null)
		return
	to_chat(user, span_notice("You cue up [song.name]. Hit someone with the microphone to challenge them."))
	user.visible_message(span_notice("[user] taps [src], looking for someone to sing at."))

/obj/item/fnf_microphone/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with) || interacting_with == user || battle?.state != FNF_STATE_READY)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(challenge), user, interacting_with)
	return ITEM_INTERACT_SUCCESS

/obj/item/fnf_microphone/proc/challenge(mob/living/user, mob/living/rival)
	if(rival.stat != CONSCIOUS)
		balloon_alert(user, "they're in no state to sing!")
		return
	var/datum/fnf_battle/offered = battle
	if(rival.client)
		// While they make up their mind, their game downloads the song.
		offered.preload(rival)
		user.visible_message(span_notice("[user] shoves [src] at [rival], challenging [rival.p_them()] to a rhythm battle!"))
		var/answer = tgui_alert(rival, "[user] challenges you to a rhythm battle: [offered.song.name] ([offered.difficulty]). Sing?", "Rhythm battle", list("Bring it on", "No thanks"), 20 SECONDS)
		if(answer != "Bring it on")
			to_chat(user, span_warning("[rival] doesn't want to sing."))
			return
	if(QDELETED(offered) || battle != offered || offered.state != FNF_STATE_READY || !user.is_holding(src))
		return
	if(get_dist(user, rival) > 7 || rival.stat != CONSCIOUS || user.stat != CONSCIOUS)
		return
	offered.start(user, rival)

/obj/item/fnf_microphone/click_alt(mob/user)
	var/client/player = user.client
	if(!player)
		return CLICK_ACTION_BLOCKING
	var/offset = tgui_input_number(user, "How late your sound comes out, in milliseconds. Raise it if you're always hitting late, lower it if you're early.", "Audio offset", GLOB.fnf_offsets[player.ckey] || 0, 500, -300)
	if(isnull(offset) || QDELETED(player))
		return CLICK_ACTION_BLOCKING
	GLOB.fnf_offsets[player.ckey] = offset
	to_chat(user, span_notice("Your audio offset is now [offset]ms. Your ping ([round(player.avgping)]ms) is already taken off every press."))
	return CLICK_ACTION_SUCCESS

/datum/loadout_item/pocket_items/fnf_microphone
	name = "Battle Microphone"
	item_path = /obj/item/fnf_microphone
