// Pony sprites for existing clothing

/obj/item/clothing
	/// Pixels sampled from the worn sprite to colour the pony version, as list(x, y) pairs
	var/list/pony_clothing_sample_pixels = null
	/// Icon state in the pony greyscale config
	var/pony_icon_state = "jumpsuit"
	/// Greyscale config holding the pony version
	var/pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/get_key_colors(icon/base_icon)
	var/list/found_colors = list()
	for(var/list/pixel in pony_clothing_sample_pixels)
		found_colors += base_icon.GetPixel(pixel[1], pixel[2])
	return length(found_colors) ? found_colors : ..()

/obj/item/clothing/under
	supports_variations_flags = CLOTHING_DIGITIGRADE_MASK | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(15,17)
	)

/obj/item/clothing/under/visual_equipped(mob/user, slot)
	. = ..()
	if((supports_variations_flags & CLOTHING_PONY_MASK) && ishuman(user))
		var/mob/living/carbon/human/wearer = user
		if(wearer.bodyshape & BODYSHAPE_PONY)
			adjusted = DIGITIGRADE_STYLE // ponies can't roll their jumpsuit down
			update_appearance()

/obj/item/clothing/under/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/color_string_to_use = greyscale_colors
	if(length(greyscale_colors))
		var/datum/greyscale_config/config = SSgreyscale.configurations["[pony_config_path]"]
		var/list/finalized_colors = SSgreyscale.ParseColorString(greyscale_colors)
		if(length(finalized_colors) > config.expected_colors) // more colors than our config supports
			finalized_colors.Cut(config.expected_colors + 1)
			color_string_to_use = jointext(finalized_colors, "")
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, color_string_to_use), pony_icon_state)
	ponysuit.Insert(ponysuit, worn_icon_state || icon_state)
	return ponysuit

/obj/item/clothing/shoes
	pony_clothing_sample_pixels = list(
		list(17,2)
	)

/obj/item/clothing/suit/space
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "spacesuit"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/space/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/color_string_to_use = greyscale_colors
	if(!isnull(greyscale_colors) && length(greyscale_colors))
		var/datum/greyscale_config/config = SSgreyscale.configurations["[pony_config_path]"]
		var/list/finalized_colors = SSgreyscale.ParseColorString(greyscale_colors)
		var/colors_len = length(finalized_colors)
		if(colors_len > config.expected_colors) // more colors than our config supports
			var/list/filled_colors = finalized_colors.Copy()
			finalized_colors = list()
			for(var/index in 1 to config.expected_colors)
				finalized_colors += filled_colors[index]
			color_string_to_use = jointext(finalized_colors, "")
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, color_string_to_use), pony_icon_state)
	ponysuit.Insert(ponysuit, worn_icon_state ? worn_icon_state : icon_state)
	return ponysuit

/obj/item/clothing/suit/hooded/ablative
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "ablative"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/hooded/ablative/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/armor/vest/alt/sec
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "armor_sec"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/armor/vest/alt/sec/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/armor/hos
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(17,19)
	)
	pony_icon_state = "hos_coat"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/suit/armor/hos/trenchcoat
	pony_clothing_sample_pixels = list(
		list(14,19)
	)

/obj/item/clothing/suit/armor/hos/trenchcoat/winter
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "hos_fancy_coat"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/armor/hos/trenchcoat/winter/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/armor/hos/hos_formal
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(16,19),
		list(19,20)
	)
	pony_icon_state = "parade"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/armor/vest/warden
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "warden_coat"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/armor/vest/warden/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/armor/vest/capcarapace/captains_formal
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(16,19),
		list(19,20)
	)
	pony_icon_state = "parade"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/armor/centcom_formal
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(19,20)
	)
	pony_icon_state = "parade"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/armor/vest/hop
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "hop_coat"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/armor/vest/hop/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/hooded/bloated_human //OH MY GOD WHAT HAVE YOU DONE!?!?!?
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "fleshsuit"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/hooded/bloated_human/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/toggle/jacket
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(13,19)
	)
	pony_icon_state = "suitjacket"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/suit/toggle/jacket/sweater
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "sweater"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/suit/jacket/oversized
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "trenchcoat"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/suit/apron
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "apron"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/apron/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/toggle/chef
	species_exception = list(/datum/species/golem)
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "chefcoat"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/toggle/chef/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/toggle/jacket/det_trench
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(13,20)
	)
	pony_icon_state = "trenchcoat"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/suit/toggle/lawyer
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(13,19)
	)
	pony_icon_state = "suitjacket"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/suit/toggle/cargo_tech
	allowed = list(
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/boxcutter,
		/obj/item/dest_tagger,
		/obj/item/stamp,
		/obj/item/storage/bag/mail,
		/obj/item/universal_scanner,
	)
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(13,19)
	)
	pony_icon_state = "suitjacket"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/suit/jacket/quartermaster
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "qm_coat"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/jacket/quartermaster/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/toggle/lawyer/greyscale
	flags_1 = IS_PLAYER_COLORABLE_1
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "suitjacket"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/suit/apron/surgical
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "surgical_apron"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/apron/surgical/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/toggle/labcoat
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(15,18)
	)
	pony_icon_state = "labcoat"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/suit/toggle/labcoat/paramedic
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "paramed_labcoat"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/toggle/labcoat/paramedic/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/toggle/labcoat/genetics
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "labcoat_sleeves"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/toggle/labcoat/chemist
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "labcoat_shoulders"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/toggle/labcoat/virologist
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "labcoat_sleeves"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/toggle/labcoat/coroner
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "labcoat_shoulders"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/toggle/labcoat/science
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "labcoat_shoulders"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/toggle/labcoat/roboticist
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "labcoat_shoulders"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/toggle/labcoat/interdyne
	greyscale_colors = "#EEEEEE#88242D#88242D#39393F"
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "labcoat_sleeves"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/toggle/labcoat/research_director
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "rd_labcoat"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/toggle/labcoat/research_director/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/jacket/straight_jacket
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "straightjacket"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/jacket/straight_jacket/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/utility/fire
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "firesuit"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/utility/fire/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/utility/bomb_suit
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "bombsuit"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/utility/bomb_suit/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/hooded/wintercoat
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(14,22),
		list(13,17)
	)
	pony_icon_state = "wintercoat"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/suit/hooded/wintercoat/captain
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "cap_wintercoat"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/hooded/wintercoat/captain/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/hooded/wintercoat/security
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "sec_wintercoat"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/hooded/wintercoat/security/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/hooded/wintercoat/custom
	flags_1 = IS_PLAYER_COLORABLE_1
	pony_clothing_sample_pixels = null

/obj/item/clothing/under/color/jumpskirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_icon_state = "jumpskirt"

/obj/item/clothing/under/rank/cargo
	pony_clothing_sample_pixels = list(
		list(15,20),
		list(13,8)
	)
	pony_icon_state = "cargotech"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/cargo/qm
	pony_clothing_sample_pixels = list(
		list(10,16),
		list(14,20),
		list(14,9)
	)
	pony_icon_state = "centcom"
	pony_config_path = /datum/greyscale_config/pony_clothes_3_color

/obj/item/clothing/under/rank/cargo/qm/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(10,16),
		list(14,20),
		list(15,10)
	)
	pony_icon_state = "centcom_skirt"

/obj/item/clothing/under/rank/cargo/tech/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(15,20),
		list(13,9)
	)
	pony_icon_state = "cargo_skirt"

/obj/item/clothing/under/rank/centcom
	pony_clothing_sample_pixels = list(
		list(10,16),
		list(14,20),
		list(14,9)
	)
	pony_icon_state = "centcom"
	pony_config_path = /datum/greyscale_config/pony_clothes_3_color

/obj/item/clothing/under/rank/centcom/officer
	pony_clothing_sample_pixels = list(
		list(13,20),
		list(14,11)
	)
	pony_icon_state = "cargotech"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/centcom/officer_skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(13,20),
		list(15,10)
	)
	pony_icon_state = "cargo_skirt"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/centcom/centcom_skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(10,16),
		list(14,20),
		list(15,10)
	)
	pony_icon_state = "centcom_skirt"

/obj/item/clothing/under/rank/civilian
	pony_clothing_sample_pixels = list(
		list(14,16),
		list(12,20)
	)
	pony_icon_state = "janitor"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/purple_bartender
	pony_clothing_sample_pixels = list(
		list(14,16),
		list(12,20)
	)
	pony_icon_state = "janitor"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/chaplain
	pony_clothing_sample_pixels = list(
		list(16,21),
		list(16,18)
	)
	pony_icon_state = "janitor"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/chaplain/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_icon_state = "janitor_skirt"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/head_of_personnel
	pony_clothing_sample_pixels = list(
		list(12,22),
		list(15,19),
		list(13,9)
	)
	pony_icon_state = "centcom"
	pony_config_path = /datum/greyscale_config/pony_clothes_3_color

/obj/item/clothing/under/rank/civilian/head_of_personnel/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(12,22),
		list(15,19),
		list(13,10)
	)
	pony_icon_state = "centcom_skirt"

/obj/item/clothing/under/rank/civilian/head_of_personnel/suit
	pony_clothing_sample_pixels = list(
		list(16,19),
		list(15,16),
		list(14,18)
	)

/obj/item/clothing/under/rank/civilian/head_of_personnel/suit/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(16,19),
		list(15,16),
		list(13,10)
	)
	pony_icon_state = "centcom_skirt"

/obj/item/clothing/under/rank/civilian/hydroponics
	pony_clothing_sample_pixels = list(
		list(10,18),
		list(15,17)
	)
	pony_icon_state = "janitor"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/hydroponics/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(10,18),
		list(15,19)
	)
	pony_icon_state = "janitor_skirt"

/obj/item/clothing/under/rank/civilian/janitor
	pony_clothing_sample_pixels = list(
		list(11,20),
		list(13,19)
	)
	pony_icon_state = "janitor"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/janitor/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(11,20),
		list(13,19)
	)
	pony_icon_state = "janitor_skirt"

/obj/item/clothing/under/rank/civilian/janitor/maid
	pony_clothing_sample_pixels = list(
		list(10,18),
		list(16,17)
	)
	pony_icon_state = "janitor_skirt"

/obj/item/clothing/under/rank/civilian/lawyer
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(13,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/lawyer/black/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(13,10)
	)
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/civilian/lawyer/beige/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(13,10)
	)
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/civilian/lawyer/red/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(13,10)
	)
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/civilian/lawyer/blue/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(13,10)
	)
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	pony_clothing_sample_pixels = null

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(13,10)
	)
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/civilian/lawyer/galaxy/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(13,10)
	)
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/civilian/lawyer/galaxy/red/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(13,10)
	)
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/civilian/cookjorts
	pony_clothing_sample_pixels = list(
		list(16,18),
		list(13,7)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/mime
	pony_clothing_sample_pixels = list(
		list(16,19),
		list(16,21)
	)
	pony_icon_state = "mime"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/mime/skirt
	pony_icon_state = "mime_skirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK

/obj/item/clothing/under/rank/civilian/mime/sexy
	pony_clothing_sample_pixels = list(
		list(16,19),
		list(16,18)
	)

/obj/item/clothing/under/rank/civilian/clown
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(16,17),
		list(16,18)
	)
	pony_icon_state = "clown"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/clown/jester
	pony_clothing_sample_pixels = list(
		list(15,18),
		list(17,19)
	)

/obj/item/clothing/under/rank/civilian/curator
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(13,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/civilian/curator/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(12,20),
		list(13,10)
	)
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/captain
	pony_clothing_sample_pixels = list(
		list(10,16),
		list(14,20),
		list(14,9)
	)
	pony_icon_state = "centcom"
	pony_config_path = /datum/greyscale_config/pony_clothes_3_color

/obj/item/clothing/under/rank/captain/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(10,16),
		list(14,20),
		list(15,10)
	)
	pony_icon_state = "centcom_skirt"

/obj/item/clothing/under/rank/captain/suit/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(10,16),
		list(14,20),
		list(15,10)
	)
	pony_icon_state = "centcom_skirt"

/obj/item/clothing/under/rank/engineering
	pony_clothing_sample_pixels = list(
		list(15,10),
		list(18,16)
	)
	pony_icon_state = "engine"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/engineering/chief_engineer
	pony_clothing_sample_pixels = list(
		list(16,17),
		list(10,18)
	)

/obj/item/clothing/under/rank/engineering/chief_engineer/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_icon_state = "engine_skirt"

/obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck
	pony_clothing_sample_pixels = list(
		list(13,20),
		list(14,11)
	)
	pony_icon_state = "cargotech"

/obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(13,20),
		list(15,10)
	)
	pony_icon_state = "cargo_skirt"

/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_icon_state = "engine_skirt"

/obj/item/clothing/under/rank/engineering/engineer/hazard
	pony_clothing_sample_pixels = list(
		list(15,15),
		list(15,18)
	)

/obj/item/clothing/under/rank/engineering/engineer/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_icon_state = "engine_skirt"

/obj/item/clothing/under/rank/medical
	pony_clothing_sample_pixels = list(
		list(15,18)
	)
	pony_icon_state = "medical"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/under/rank/medical/doctor/skirt
	pony_clothing_sample_pixels = list(
		list(15,18),
		list(18,17)
	)
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color
	pony_icon_state = "medical_skirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK

/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt
	pony_clothing_sample_pixels = list(
		list(15,18),
		list(18,17)
	)
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color
	pony_icon_state = "medical_skirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK

/obj/item/clothing/under/rank/medical/chief_medical_officer/scrubs
	pony_clothing_sample_pixels = list(
		list(13,8)
	)
	pony_icon_state = "scrubs"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck
	pony_clothing_sample_pixels = list(
		list(13,19),
		list(15,11)
	)
	pony_icon_state = "cargotech"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_icon_state = "cargo_skirt"

/obj/item/clothing/under/rank/medical/virologist/skirt
	pony_clothing_sample_pixels = list(
		list(15,18),
		list(18,17)
	)
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color
	pony_icon_state = "medical_skirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK

/obj/item/clothing/under/rank/medical/scrubs
	pony_clothing_sample_pixels = list(
		list(16,19)
	)
	pony_icon_state = "scrubs"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/under/rank/medical/coroner/skirt
	pony_clothing_sample_pixels = list(
		list(15,18),
		list(18,17)
	)
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color
	pony_icon_state = "medical_skirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK

/obj/item/clothing/under/rank/medical/chemist/skirt
	pony_clothing_sample_pixels = list(
		list(15,18),
		list(18,17)
	)
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color
	pony_icon_state = "medical_skirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK

/obj/item/clothing/under/rank/medical/paramedic/skirt
	pony_clothing_sample_pixels = list(
		list(15,18),
		list(18,17)
	)
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color
	pony_icon_state = "medical_skirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK

/obj/item/clothing/under/rank/medical/doctor/nurse
	pony_clothing_sample_pixels = list(
		list(15,18),
		list(15,18)
	)
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color
	pony_icon_state = "medical_skirt"

/obj/item/clothing/under/rank/rnd
	pony_clothing_sample_pixels = list(
		list(11,20),
		list(14,19)
	)
	pony_icon_state = "science"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/rnd/research_director
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(13,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/rnd/research_director/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(19,10)
	)
	pony_icon_state = "secskirt"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/rnd/research_director/alt
	pony_clothing_sample_pixels = null
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/rnd/research_director/alt/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK

/obj/item/clothing/under/rank/rnd/research_director/turtleneck
	pony_clothing_sample_pixels = list(
		list(13,20),
		list(14,11)
	)
	pony_icon_state = "cargotech"

/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(13,20),
		list(15,10)
	)
	pony_icon_state = "cargo_skirt"

/obj/item/clothing/under/rank/rnd/scientist/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_icon_state = "science_skirt"

/obj/item/clothing/under/rank/rnd/roboticist
	pony_clothing_sample_pixels = list(
		list(17,16),
		list(14,19)
	)

/obj/item/clothing/under/rank/rnd/roboticist/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_icon_state = "science_skirt"

/obj/item/clothing/under/rank/rnd/geneticist/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_icon_state = "science_skirt"

/obj/item/clothing/under/rank/security
	pony_clothing_sample_pixels = list(
		list(14,19)
	)
	pony_icon_state = "rsecurity"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/under/rank/security/officer/skirt
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(20,9)
	)
	pony_icon_state = "secskirt"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK

/obj/item/clothing/under/rank/security/officer/blueshirt
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(14,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/officer/formal
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(14,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/constable
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(14,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/warden/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(20,9)
	)
	pony_icon_state = "secskirt"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/warden/formal
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(14,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/detective
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(14,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/detective/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(19,10)
	)
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/security/detective/noir/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(19,10)
	)
	pony_icon_state = "secskirt"

/obj/item/clothing/under/rank/security/head_of_security/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(20,9)
	)
	pony_icon_state = "secskirt"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/head_of_security/alt
	pony_clothing_sample_pixels = list(
		list(13,20),
		list(14,11)
	)
	pony_icon_state = "cargotech"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/head_of_security/alt/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(13,20),
		list(14,11)
	)
	pony_icon_state = "cargo_skirt"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/head_of_security/formal
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(14,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/officer/spacepol
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(14,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/prisoner
	pony_icon_state = "jumpsuit"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/under/rank/prisoner/skirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_PONY_MASK
	pony_icon_state = "jumpskirt"

/obj/item/clothing/under/rank/security/officer/beatcop
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(14,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/detective/disco
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(14,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/rank/security/detective/kim
	pony_clothing_sample_pixels = list(
		list(14,19),
		list(14,8)
	)
	pony_icon_state = "shirt_and_pants"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color

/obj/item/clothing/under/shorts
	supports_variations_flags = CLOTHING_PONY_MASK

/datum/greyscale_config/digitigrade
	json_config = 'code/datums/greyscale/json_configs/digitigrade.json'

/datum/greyscale_config/pony_clothes_override
	name = "Pony Clothes (Overrides)"
	icon_file = 'voidcrew/modules/ponies/icons/pony_template.dmi'
	json_config = 'voidcrew/modules/ponies/greyscale/no_color.json'

/datum/greyscale_config/pony_clothes_1_color
	name = "Pony Clothes (1 Color)"
	icon_file = 'voidcrew/modules/ponies/icons/pony_template.dmi'
	json_config = 'voidcrew/modules/ponies/greyscale/1_color.json'

/datum/greyscale_config/pony_clothes_2_color
	name = "Pony Clothes (2 Color)"
	icon_file = 'voidcrew/modules/ponies/icons/pony_template.dmi'
	json_config = 'voidcrew/modules/ponies/greyscale/2_color.json'

/datum/greyscale_config/pony_clothes_3_color
	name = "Pony Clothes (3 Color)"
	icon_file = 'voidcrew/modules/ponies/icons/pony_template.dmi'
	json_config = 'voidcrew/modules/ponies/greyscale/3_color.json'

/obj/item/clothing/suit/armor/changeling
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "chitinsuit"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/armor/changeling/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/hooded/cultrobes/alt
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "cultrobe"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/hooded/cultrobes/alt/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "hereticrobe"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/hooded/cultrobes/eldritch/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/jacket/leather_trenchcoat
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(13,19)
	)
	pony_icon_state = "trenchcoat"
	pony_config_path = /datum/greyscale_config/pony_clothes_1_color

/obj/item/clothing/suit/hooded/cloak/drake
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "bonearmor"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/hooded/cloak/drake/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/mod
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = list(
		list(16,19),
		list(15,15)
	)
	pony_icon_state = "modsuit"
	pony_config_path = /datum/greyscale_config/pony_clothes_2_color
