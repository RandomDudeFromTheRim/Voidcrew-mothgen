/datum/dna_block/feature/pony_ears
	feature_key = FEATURE_PONY_EARS

/datum/dna_block/feature/pony_ears/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.pony_ears_list.Find(target.dna.features[feature_key]), length(SSaccessories.pony_ears_list))

/datum/dna_block/feature/pony_ears/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.pony_ears_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.pony_ears_list))]

/datum/dna_block/feature/pony_tail
	feature_key = FEATURE_PONY_TAIL

/datum/dna_block/feature/pony_tail/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.pony_tail_list.Find(target.dna.features[feature_key]), length(SSaccessories.pony_tail_list))

/datum/dna_block/feature/pony_tail/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.dna.features[feature_key] = SSaccessories.pony_tail_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.pony_tail_list))]
