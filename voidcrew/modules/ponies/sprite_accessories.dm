/datum/sprite_accessory
	/// Bodyshapes this was drawn for. Pony hair skips the face offset that fits human hair onto pony heads.
	var/compatible_bodyshapes = BODYSHAPE_HUMANOID | BODYSHAPE_DIGITIGRADE | BODYSHAPE_MONKEY | BODYSHAPE_SNOUTED

/datum/sprite_accessory/hair/eq_wintersshield
	name = "Soldier (Equestrian)"
	icon_state = "hair_eq_wintersshield"
	icon = 'voidcrew/modules/ponies/icons/pony_face.dmi'
	compatible_bodyshapes = BODYSHAPE_PONY
	natural_spawn = FALSE

/datum/sprite_accessory/hair/eq_dork
	name = "Dork (Equestrian)"
	icon_state = "hair_eq_dork"
	icon = 'voidcrew/modules/ponies/icons/pony_face.dmi'
	compatible_bodyshapes = BODYSHAPE_PONY
	natural_spawn = FALSE

/datum/sprite_accessory/hair/eq_punkrocker
	name = "Punk Rocker (Equestrian)"
	icon_state = "hair_eq_punkrocker"
	icon = 'voidcrew/modules/ponies/icons/pony_face.dmi'
	compatible_bodyshapes = BODYSHAPE_PONY
	natural_spawn = FALSE

/datum/sprite_accessory/hair/eq_timid
	name = "Timid (Equestrian)"
	icon_state = "hair_eq_timid"
	icon = 'voidcrew/modules/ponies/icons/pony_face.dmi'
	compatible_bodyshapes = BODYSHAPE_PONY
	natural_spawn = FALSE

/datum/sprite_accessory/hair/eq_bookworm
	name = "Bookworm (Equestrian)"
	icon_state = "hair_eq_bookworm"
	icon = 'voidcrew/modules/ponies/icons/pony_face.dmi'
	compatible_bodyshapes = BODYSHAPE_PONY
	natural_spawn = FALSE

/datum/sprite_accessory/hair/eq_fatale
	name = "Fatale (Equestrian)"
	icon_state = "hair_eq_fatale"
	icon = 'voidcrew/modules/ponies/icons/pony_face.dmi'
	compatible_bodyshapes = BODYSHAPE_PONY
	natural_spawn = FALSE

/datum/sprite_accessory/pony_ears
	icon = 'voidcrew/modules/ponies/icons/bodyparts.dmi'
	em_block = TRUE

/datum/sprite_accessory/pony_ears/pony
	name = "Pony"
	icon_state = "pony"
	color_src = MUTANT_COLOR

/datum/sprite_accessory/pony_tail
	icon = 'voidcrew/modules/ponies/icons/bodyparts.dmi'
	em_block = TRUE

/datum/sprite_accessory/pony_tail/pony
	name = "Pony"
	icon_state = "pony"
	color_src = HAIR_COLOR

/datum/sprite_accessory/pony_horn
	icon = 'voidcrew/modules/ponies/icons/bodyparts.dmi'
	em_block = TRUE

/datum/sprite_accessory/pony_horn/pony
	name = "Pony"
	icon_state = "pony"
	color_src = MUTANT_COLOR

/datum/sprite_accessory/pony_wings
	icon = 'voidcrew/modules/ponies/icons/bodyparts.dmi'
	em_block = TRUE

/datum/sprite_accessory/pony_wings/pony
	name = "Pony"
	icon_state = "pony"
	color_src = MUTANT_COLOR
