/obj/machinery/computer/order_console/mining
	// VOIDCREW EDIT ADDITION START - the console forces express (below), but the shop quotes its
	// wares at the cargo price while charging the express price: order_computer.dm's ui_static_data
	// lists `cost_per_order * cargo_cost_multiplier` while purchase_items charges
	// `get_total_cost() * express_cost_multiplier`. At 0.65 against 1 you were quoted 35% under what
	// you actually paid, and could not tell what you could afford until checkout. Equalising the two
	// makes the listed price the charged price; the charge itself does not change.
	cargo_cost_multiplier = 1
	// The stock cargo tooltip promised a discount that cannot be taken on an express-only console.
	purchase_tooltip = @{"Your purchases will arrive at cargo,
	and hopefully get delivered by them."}
	// VOIDCREW EDIT ADDITION END

/obj/machinery/computer/order_console/mining/Initialize(mapload)
	forced_express = TRUE
	return ..()
