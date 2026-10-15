/// Cuts a sock sprite apart and lays it over the four pony legs. Cached per sock style.
/proc/pony_socks_icon(datum/sprite_accessory/socks/socks)
	var/static/list/pony_sock_cache = list()
	var/index = "[socks.icon]-[socks.icon_state]"
	if(pony_sock_cache[index])
		return pony_sock_cache[index]

	var/static/icon/toe_mask = icon('voidcrew/modules/ponies/icons/bodyparts.dmi', "toe_removal")
	var/static/icon/darken_mask = icon('voidcrew/modules/ponies/icons/bodyparts.dmi', "darken_back_shoe")
	var/static/list/sock_masks
	if(!sock_masks)
		sock_masks = list()
		for(var/part in list("l_leg", "r_leg", "l_arm", "r_arm"))
			sock_masks["[part]_[EAST]"] = icon('voidcrew/modules/ponies/icons/bodyparts.dmi', "[part]_sock_mask", EAST)
			sock_masks["[part]_[WEST]"] = icon('voidcrew/modules/ponies/icons/bodyparts.dmi', "[part]_sock_mask", WEST)

	var/icon/socks_icon = icon(socks.icon, socks.icon_state)
	socks_icon.Blend(toe_mask, ICON_SUBTRACT)

	// front and back views: fill the gap between the legs
	var/icon/new_south = icon(socks_icon, dir = SOUTH)
	var/icon/new_north = icon(socks_icon, dir = NORTH)
	for(var/i in 1 to 32)
		var/color_to_check = socks_icon.GetPixel(17, i, SOUTH)
		if(!color_to_check)
			break
		new_south.DrawBox(color_to_check, 16, i, 16, i)
		new_north.DrawBox(color_to_check, 16, i, 16, i)

	// side views: one copy per leg, masked and shifted into place. list(mask part, x offset, back leg)
	var/static/list/side_legs = list(
		"[EAST]" = list(list("l_leg", 0, TRUE), list("r_leg", -3, FALSE), list("r_arm", 8, TRUE), list("l_arm", 5, FALSE)),
		"[WEST]" = list(list("r_leg", 2, TRUE), list("l_leg", 5, FALSE), list("l_arm", -6, TRUE), list("r_arm", -4, FALSE)),
	)
	var/icon/final_icon = icon()
	final_icon.Insert(new_south, socks.icon_state, SOUTH)
	final_icon.Insert(new_north, socks.icon_state, NORTH)
	for(var/side in list(EAST, WEST))
		var/icon/blank = icon('icons/blanks/32x32.dmi', "nothing")
		for(var/list/leg in side_legs["[side]"])
			var/icon/leg_icon = icon(socks_icon, dir = side)
			if(leg[3])
				leg_icon.Blend(darken_mask, ICON_MULTIPLY)
			leg_icon.Blend(sock_masks["[leg[1]]_[side]"], ICON_SUBTRACT)
			blank.Blend(leg_icon, ICON_OVERLAY, leg[2], 0)
		final_icon.Insert(blank, socks.icon_state, side)

	. = fcopy_rsc(final_icon)
	pony_sock_cache[index] = .

/// Pony shoes: the shoe sprite copied onto all four hooves. Cached per shoe look.
/proc/pony_shoes_icon(obj/item/shoes, icon_file)
	var/static/list/pony_shoe_cache = list()
	var/state = shoes.worn_icon_state || shoes.icon_state
	var/index = "[shoes.worn_icon || icon_file]-[state]-[shoes.greyscale_colors]"
	if(pony_shoe_cache[index])
		return pony_shoe_cache[index]

	var/static/icon/toe_mask = icon('voidcrew/modules/ponies/icons/bodyparts.dmi', "toe_removal")
	var/static/icon/darken_mask = icon('voidcrew/modules/ponies/icons/bodyparts.dmi', "darken_back_shoe")
	var/icon/shoes_icon = icon(shoes.worn_icon || icon_file, state)
	shoes_icon.Blend(toe_mask, ICON_SUBTRACT)

	var/icon/new_south = icon(shoes_icon, dir = SOUTH)
	var/icon/new_north = icon(shoes_icon, dir = NORTH)
	for(var/i in 1 to 32)
		var/color_to_check = shoes_icon.GetPixel(17, i, SOUTH)
		if(!color_to_check)
			break
		new_south.DrawBox(color_to_check, 16, i, 16, i)
		new_north.DrawBox(color_to_check, 16, i, 16, i)

	var/icon/final_icon = icon()
	final_icon.Insert(new_south, state, SOUTH)
	final_icon.Insert(new_north, state, NORTH)
	// list(x offset of the back hooves, x offset of the front hooves)
	var/static/list/hoof_offsets = list("[EAST]" = list(list(-1, 7), list(-3, 5)), "[WEST]" = list(list(2, -6), list(4, -4)))
	for(var/side in list(EAST, WEST))
		var/icon/blank = icon('icons/blanks/32x32.dmi', "nothing")
		var/icon/back = icon(shoes_icon, dir = side)
		back.Blend(darken_mask, ICON_MULTIPLY)
		var/icon/front = icon(shoes_icon, dir = side)
		var/list/offsets = hoof_offsets["[side]"]
		for(var/x in offsets[1])
			blank.Blend(back, ICON_OVERLAY, x, 0)
		for(var/x in offsets[2])
			blank.Blend(front, ICON_OVERLAY, x, 0)
		final_icon.Insert(blank, state, side)

	. = fcopy_rsc(final_icon)
	pony_shoe_cache[index] = .

/// Belts and suit storage on ponies: drawn on the flanks only, using the front and back sprites as sides.
/proc/pony_front_back_icon(obj/item/worn, icon_file)
	var/state = worn.worn_icon_state || worn.icon_state
	var/file = worn.worn_icon || icon_file
	var/icon/blank = icon('icons/blanks/32x32.dmi', "nothing")
	var/icon/final_icon = icon()
	final_icon.Insert(blank, state, SOUTH)
	final_icon.Insert(blank, state, NORTH)
	final_icon.Insert(icon(file, state, SOUTH), state, EAST)
	final_icon.Insert(icon(file, state, NORTH), state, WEST)
	return final_icon

/// Pony hair is drawn for the pony head already, so it skips the face offset that fits human hair onto it
/obj/item/bodypart/head/proc/pony_hair_fits(datum/sprite_accessory/hair)
	return owner && hair && (owner.bodyshape & BODYSHAPE_PONY) && (hair.compatible_bodyshapes & BODYSHAPE_PONY)

/// Oversuits without a pony sprite: worn as is, with the back cut out. Returns null for suits with a pony sprite, which build_worn_icon masks itself.
/proc/pony_suit_icon(obj/item/suit, icon_file)
	if(suit.supports_variations_flags & CLOTHING_PONY_MASK)
		return null
	var/static/icon/north_mask = icon('voidcrew/modules/ponies/icons/bodyparts.dmi', "north_suit_mask")
	var/state = suit.worn_icon_state || suit.icon_state
	var/file = suit.worn_icon || icon_file
	var/icon/new_north = icon(file, state, NORTH)
	new_north.Blend(north_mask, ICON_SUBTRACT)
	var/icon/final_icon = icon()
	final_icon.Insert(icon(file, state, SOUTH), state, SOUTH)
	final_icon.Insert(new_north, state, NORTH)
	final_icon.Insert(icon(file, state, EAST), state, EAST)
	final_icon.Insert(icon(file, state, WEST), state, WEST)
	return final_icon

/// Back items on ponies hang off a flank, so every direction is drawn turned a quarter. The alt slot is the other flank.
/proc/pony_back_icon(obj/item/worn, icon_file, other_side = FALSE)
	var/state = worn.worn_icon_state || worn.icon_state
	var/file = worn.worn_icon || icon_file
	// list(dir drawn, dir of the sprite drawn there), for each of the four
	var/static/list/sources = list(list(SOUTH, WEST), list(NORTH, EAST), list(EAST, SOUTH), list(WEST, NORTH))
	var/static/list/other_sources = list(list(SOUTH, EAST), list(NORTH, WEST), list(EAST, NORTH), list(WEST, SOUTH))
	var/icon/final_icon = icon()
	for(var/list/pair as anything in (other_side ? other_sources : sources))
		final_icon.Insert(icon(file, state, pair[2]), state, pair[1])
	return final_icon

/// Modifies a sprite to conform to pony body shapes
/proc/wear_pony_version(icon/base_icon, obj/item/item, key, greyscale_colors)
	ASSERT(istype(item), "wear_pony_version: no item passed")
	ASSERT(istext(key), "wear_pony_version: no key passed")
	if(isnull(greyscale_colors) || length(SSgreyscale.ParseColorString(greyscale_colors)) > 1)
		greyscale_colors = item.get_key_colors(base_icon) || item.get_general_color(base_icon)
	var/color_key = islist(greyscale_colors) ? jointext(greyscale_colors, "") : greyscale_colors
	var/index = "[key]-[item.type]-[color_key]"
	var/static/list/pony_clothing_cache = list()
	var/icon/resulting_icon = pony_clothing_cache[index]
	if(!resulting_icon)
		resulting_icon = item.generate_pony_icons(base_icon, color_key)
		if(!resulting_icon)
			stack_trace("[item.type] is set to generate a masked pony icon, but generate_pony_icons was not implemented (or error'd).")
			return base_icon
		pony_clothing_cache[index] = fcopy_rsc(resulting_icon)
	return icon(resulting_icon)

/// Builds this item's pony sprite, recoloured with greyscale_colors
/obj/item/proc/generate_pony_icons(icon/base_icon, greyscale_colors)
	return null

/// The colours a pony sprite of this item gets painted with
/obj/item/proc/get_key_colors(icon/base_icon)
	return greyscale_colors || color

/mob/proc/update_worn_back_alt(update_obscured = FALSE)
	return

/// Draws the alt back slot next to the main one, on BACK_LAYER
/mob/living/carbon/human/update_worn_back_alt(update_obscured = TRUE)
	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK_ALT) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK_ALT) + 1]
		inv.update_icon()
	if(!back_alt)
		return
	update_hud_back_alt(back_alt)
	if(update_obscured)
		update_obscured_slots(back_alt.flags_inv)
	if(HAS_TRAIT(back_alt, TRAIT_NO_WORN_ICON))
		return
	var/icon_file = 'icons/mob/clothing/back.dmi'
	var/mutable_appearance/back_alt_overlay = back_alt.build_worn_icon(default_layer = BACK_LAYER, default_icon_file = icon_file, override_file = (bodyshape & BODYSHAPE_PONY) ? pony_back_icon(back_alt, icon_file, other_side = TRUE) : null)
	if(!back_alt_overlay)
		return
	var/obj/item/bodypart/chest/my_chest = get_bodypart(BODY_ZONE_CHEST)
	my_chest?.worn_back_offset?.apply_offset(back_alt_overlay)
	var/existing = overlays_standing[BACK_LAYER]
	overlays_standing[BACK_LAYER] = existing ? list(existing, back_alt_overlay) : back_alt_overlay

/mob/living/carbon/proc/update_hud_back_alt(obj/item/worn_item)
	return

/mob/living/carbon/human/update_hud_back_alt(obj/item/worn_item)
	worn_item.screen_loc = ui_back_alt
	if(client && hud_used?.hud_shown)
		client.screen += worn_item
	update_observer_view(worn_item, inventory = TRUE)
