// Pony hooks on existing types: languages, the alt back slot, limbgrower designs, machinery

/datum/language_holder/pony
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/ponish = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/ponish = list(LANGUAGE_ATOM),
	)

/mob/living/carbon
	var/obj/item/back_alt = null

/datum/strippable_item/mob_item_slot/back_alt
	key = STRIPPABLE_ITEM_BACK_ALT
	item_slot = ITEM_SLOT_BACK_ALT

/obj/machinery/modular_computer
	interaction_flags_machine = parent_type::interaction_flags_machine | INTERACT_MACHINE_PONY_REQUIRES_SITTING

/datum/movespeed_modifier/pony_holding_no_items
	multiplicative_slowdown = -0.3
	blacklisted_movetypes = FLOATING|FLYING

/datum/movespeed_modifier/pony_holding_two_items
	multiplicative_slowdown = 0.4
	blacklisted_movetypes = FLOATING|FLYING

/obj/item/disk/design_disk/limbs/pony
	name = "Pony Organ Design Disk"
	limb_designs = list(
		/datum/design/pony_eyes,
		/datum/design/pony_ears,
		/datum/design/pony_tongue,
		/datum/design/pony_lungs,
		/datum/design/pony_horn,
		/datum/design/pony_wings,
		/datum/design/earth_pony_core
	)

/datum/design/pony_eyes
	name = "Pony Eyes"
	id = "pony_eyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/eyes/pony
	category = list(SPECIES_PONY)

/datum/design/pony_ears
	name = "Pony Ears"
	id = "pony_ears"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/ears/pony
	category = list(SPECIES_PONY)

/datum/design/pony_tongue
	name = "Pony Tongue"
	id = "pony_tongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/tongue/pony
	category = list(SPECIES_PONY)

/datum/design/pony_lungs
	name = "Pony Lungs"
	id = "pony_lungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/lungs/pony
	category = list(SPECIES_PONY)

/datum/design/pony_horn
	name = "Unicorn Horn"
	id = "pony_horn"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/medicine/earthsblood = 10)
	build_path = /obj/item/organ/pony_horn
	category = list(SPECIES_PONY)

/datum/design/earth_pony_core
	name = "Earth Pony Core"
	id = "earth_pony_core"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/medicine/earthsblood = 10)
	build_path = /obj/item/organ/earth_pony_core
	category = list(SPECIES_PONY)

/datum/design/pony_wings
	name = "Pegasus Wings"
	id = "pony_wings"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/medicine/earthsblood = 10)
	build_path = /obj/item/organ/pony_wings
	category = list(SPECIES_PONY)

/datum/design/pony_leftarm
	name = "Pony Left Foreleg"
	id = "pony_leftarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/arm/left/pony
	category = list(RND_CATEGORY_INITIAL, SPECIES_PONY)

/datum/design/pony_rightarm
	name = "Pony Right Foreleg"
	id = "pony_rightarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/arm/right/pony
	category = list(RND_CATEGORY_INITIAL, SPECIES_PONY)

/datum/design/pony_leftleg
	name = "Pony Left Hindleg"
	id = "pony_leftleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/leg/left/pony
	category = list(RND_CATEGORY_INITIAL, SPECIES_PONY)

/datum/design/pony_rightleg
	name = "Pony Right Hindleg"
	id = "pony_rightleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/leg/right/pony
	category = list(RND_CATEGORY_INITIAL, SPECIES_PONY)

/datum/design/pony_head
	name = "Pony Head"
	id = "pony_head"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/head/pony
	category = list(RND_CATEGORY_INITIAL, SPECIES_PONY)

/datum/design/limb_disk/pony
	name = "Pony Organ Design Disk"
	desc = "Contains designs for pony organs for the limbgrower."
	id = "limbdesign_pony"
	build_path = /obj/item/disk/design_disk/limbs/pony

/datum/techweb_node/xenobiology
	design_ids = list(
		"xenobioconsole",
		"slime_scanner",
		"limbdesign_ethereal",
		"limbdesign_felinid",
		"limbdesign_lizard",
		"limbdesign_plasmaman",
		"limbdesign_pony",
	)

/obj/machinery/computer
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_REQUIRES_LITERACY|INTERACT_MACHINE_PONY_REQUIRES_SITTING

/obj/machinery/limbgrower
	var/list/categories = list(SPECIES_HUMAN, SPECIES_LIZARD, SPECIES_MOTH, SPECIES_PLASMAMAN, SPECIES_ETHEREAL, SPECIES_PONY, RND_CATEGORY_LIMBS_OTHER, RND_CATEGORY_LIMBS_DIGITIGRADE)

/// Ponies are too short for consoles unless buckled or standing on furniture
/proc/pony_can_reach(mob/user)
	if(!ishuman(user))
		return TRUE
	var/mob/living/carbon/human/human_user = user
	if(!(human_user.bodyshape & BODYSHAPE_PONY) || human_user.buckled)
		return TRUE
	var/static/list/elevations = typecacheof(list(/obj/structure/chair, /obj/structure/bed, /obj/structure/rack, /obj/structure/table))
	for(var/obj/found_object in get_turf(user))
		if(elevations[found_object.type])
			return TRUE
	to_chat(user, span_warning("You can't reach the controls! Get some elevation with a chair or something to buckle yourself to."))
	user.balloon_alert(user, "can't reach controls, need chair!")
	return FALSE

/mob/living
	/// The verb used for hugging interactions
	var/hug_verb = "hug"

/datum/preference/choiced/socks/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	var/datum/species/species = GLOB.species_prototypes[preferences.read_preference(/datum/preference/choiced/species)]
	return !(TRAIT_NO_SOCKS_ONLY in species.inherent_traits)

/datum/preference/choiced/undershirt/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	var/datum/species/species = GLOB.species_prototypes[preferences.read_preference(/datum/preference/choiced/species)]
	return !(TRAIT_NO_UNDERSHIRT_ONLY in species.inherent_traits)
