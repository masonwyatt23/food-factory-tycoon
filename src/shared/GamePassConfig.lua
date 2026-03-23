local GamePassConfig = {}

-- Game Passes (one-time purchases) — IDs from Creator Dashboard
GamePassConfig.Passes = {
	DoubleIncome = {
		id = 0,
		name = "2x Tips",
		price = 199,
		description = "Permanently double all your income!",
		multiplier = 2,
	},
	AutoCollect = {
		id = 0,
		name = "Auto-Cook",
		price = 149,
		description = "Automatically buy the next business as soon as you can afford it!",
	},
	VIP Chef = {
		id = 0,
		name = "VIP Chef",
		price = 399,
		description = "Unlock 3 exclusive VIP Chef-only buildings with massive income!",
	},
	SpeedBoost = {
		id = 0,
		name = "Speed Serve",
		price = 99,
		description = "Walk 1.5x faster!",
		speedMultiplier = 1.5,
	},
}

-- Developer Products (repeatable purchases) — IDs from Creator Dashboard
GamePassConfig.Products = {
	SmallCashPack = {
		id = 0,
		name = "Small Tip Pack",
		price = 49,
		cashAmount = 10000,
		description = "+10,000 Cash",
	},
	LargeCashPack = {
		id = 0,
		name = "Large Tip Pack",
		price = 199,
		cashAmount = 50000,
		description = "+50,000 Cash",
	},
	InstantRebirth = {
		id = 0,
		name = "Instant Prestige",
		price = 99,
		description = "Rebirth without meeting the cash requirement!",
	},
	TemporaryBoost = {
		id = 0,
		name = "5min 2x Boost",
		price = 29,
		duration = 300,
		multiplier = 2,
		description = "2x income for 5 minutes!",
	},
	StarterBundle = {
		id = 0, -- CREATE IN CREATOR DASHBOARD: "Starter Bundle" R$99
		name = "Starter Bundle",
		price = 99,
		cashAmount = 50000,
		boostDuration = 600, -- 10 min 2x boost
		boostMultiplier = 2,
		description = "50K Cash + 10min 2x Boost! Best value for new players!",
	},
}

return GamePassConfig
