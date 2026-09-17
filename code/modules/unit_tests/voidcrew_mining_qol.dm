/// Regression guards for the mining quality-of-life changes: an ORM that pays out without an ore
/// silo, lavaland and icebox fauna that do not soak projectile damage, and a mining order console
/// that quotes the price it actually charges.

/datum/unit_test/voidcrew_orm_claims_without_silo

/datum/unit_test/voidcrew_orm_claims_without_silo/Run()
	var/obj/machinery/mineral/ore_redemption/orm_type = /obj/machinery/mineral/ore_redemption
	TEST_ASSERT(!initial(orm_type.requires_silo), "The ORM must pay out mining points without an ore silo, or a crew with no silo can never spend the ore it digs up.")

/datum/unit_test/voidcrew_mining_fauna_resist_no_projectile

/datum/unit_test/voidcrew_mining_fauna_resist_no_projectile/Run()
	var/list/vulnerable = string_list(MINING_MOB_PROJECTILE_VULNERABILITY)
	for(var/projectile_damage_type in list(BRUTE, BURN, TOX, OXY, STAMINA))
		TEST_ASSERT(projectile_damage_type in vulnerable, "Mining fauna still resist [projectile_damage_type] projectiles, so the ranged_armour element reduces them by 0.3 below 30 force.")

/datum/unit_test/voidcrew_mining_console_quotes_its_price

/datum/unit_test/voidcrew_mining_console_quotes_its_price/Run()
	var/obj/machinery/computer/order_console/mining/console_type = /obj/machinery/computer/order_console/mining
	TEST_ASSERT_EQUAL(initial(console_type.cargo_cost_multiplier), initial(console_type.express_cost_multiplier), "The mining console lists wares at the cargo multiplier but charges the express one, so the quoted price is not the price paid.")
