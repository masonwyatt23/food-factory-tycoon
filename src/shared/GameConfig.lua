local GameConfig = {}

-- Currency
GameConfig.CurrencyName = "Tips"
GameConfig.StartingCash = 100
GameConfig.AutoPurchaseFirstItem = true

-- Income tick rate
GameConfig.IncomeInterval = 1

-- Restaurant-themed items
GameConfig.TycoonItems = {
	-- Tier 1: Food Cart
	{name = "Hot Dog Stand",      cost = 0,      income = 5,    description = "Your first food venture!"},
	{name = "Lemonade Bar",       cost = 25,     income = 8,    description = "Refreshing profits"},
	{name = "Popcorn Machine",    cost = 75,     income = 15,   description = "Movie-night snacks"},

	-- Tier 2: Cafe
	{name = "Coffee Corner",      cost = 200,    income = 30,   description = "Espresso empire"},
	{name = "Bakery",             cost = 500,    income = 50,   description = "Fresh bread daily"},
	{name = "Ice Cream Parlor",   cost = 1200,   income = 80,   description = "Sweet scoops of cash"},

	-- Tier 3: Restaurant
	{name = "Burger Joint",       cost = 3000,   income = 150,  description = "Flame-grilled profits"},
	{name = "Pizza Kitchen",      cost = 7500,   income = 300,  description = "Slice of the pie"},
	{name = "Sushi Bar",          cost = 18000,  income = 500,  description = "Raw fish, refined taste"},

	-- Tier 4: Fine Dining
	{name = "Steakhouse",         cost = 40000,  income = 900,  description = "Prime cuts, prime profits"},
	{name = "Seafood Palace",     cost = 100000, income = 2000, description = "Ocean-fresh fortune"},
	{name = "French Bistro",      cost = 250000, income = 4000, description = "Oui oui, money money"},

	-- Tier 5: Empire
	{name = "Food Court",         cost = 500000,  income = 8000,  description = "Mall food domination"},
	{name = "Hotel Restaurant",   cost = 1200000, income = 15000, description = "5-star dining"},
	{name = "Golden Kitchen",     cost = 3500000, income = 35000, description = "The ultimate chef"},

	-- Tier 6: VIP
	{name = "VIP Rooftop Bar",    cost = 8000000,  income = 50000,  description = "Sky-high dining", vip = true},
	{name = "VIP Yacht Club",     cost = 15000000, income = 80000,  description = "Nautical cuisine", vip = true},
	{name = "VIP Royal Feast",    cost = 30000000, income = 150000, description = "Fit for a king", vip = true},
}

-- Rebirth system (called "Prestige" in Restaurant Tycoon)
GameConfig.Rebirth = {
	baseCost = 500000,
	costMultiplier = 2.5,
	incomeMultiplier = 1.5,
	maxRebirths = 25,
}

GameConfig.StandardItemCount = 15
GameConfig.MaxPlots = 8
GameConfig.PlotSpacing = 100
GameConfig.PlotSize = 80

-- Warm restaurant colors
GameConfig.BuildingColors = {
	Color3.fromRGB(255, 200, 100),  -- Tier 1: Warm yellow
	Color3.fromRGB(255, 150, 80),   -- Tier 2: Orange
	Color3.fromRGB(200, 80, 80),    -- Tier 3: Red
	Color3.fromRGB(150, 50, 50),    -- Tier 4: Dark red
	Color3.fromRGB(200, 170, 100),  -- Tier 5: Gold
	Color3.fromRGB(255, 215, 0),    -- Tier 6: VIP Gold
}
GameConfig.BuildingHeights = {4, 6, 10, 14, 20, 25}
GameConfig.BuildingMaterials = {"Wood", "Brick", "Brick", "Marble", "Marble", "ForceField"}

GameConfig.PlotColors = {
	Color3.fromRGB(220, 200, 170),
	Color3.fromRGB(200, 190, 160),
	Color3.fromRGB(210, 195, 165),
	Color3.fromRGB(215, 200, 175),
	Color3.fromRGB(205, 195, 170),
	Color3.fromRGB(210, 200, 180),
	Color3.fromRGB(200, 195, 175),
	Color3.fromRGB(215, 205, 170),
}

GameConfig.Codes = {
	LAUNCH   = 5000,
	CHEF     = 1000,
	YUMMY    = 10000,
	PRESTIGE = 50000,
	BUSINESS = 25000,  -- cross-promo
	SPACE    = 15000,  -- cross-promo
}

GameConfig.DailyRewards = {500, 1500, 5000, 15000, 50000, 150000, 500000}

GameConfig.QuestPool = {
	{type = "earn_cash",   description = "Earn %s tips",          baseTarget = 50000,  rewardMult = 2},
	{type = "buy_items",   description = "Build %s stations",     baseTarget = 3,      rewardMult = 3},
	{type = "rebirth",     description = "Prestige %s time(s)",   baseTarget = 1,      rewardMult = 5},
	{type = "play_time",   description = "Cook for %s minutes",   baseTarget = 10,     rewardMult = 2},
	{type = "reach_item",  description = "Reach station #%s",     baseTarget = 10,     rewardMult = 3},
}

GameConfig.Achievements = {
	{id = "first_dish",      name = "First Dish",       trigger = "items",      threshold = 1,       reward = 500},
	{id = "sous_chef",       name = "Sous Chef",        trigger = "items",      threshold = 5,       reward = 5000},
	{id = "head_chef",       name = "Head Chef",        trigger = "items",      threshold = 15,      reward = 50000},
	{id = "first_prestige",  name = "First Prestige",   trigger = "rebirths",   threshold = 1,       reward = 10000},
	{id = "master_chef",     name = "Master Chef",      trigger = "rebirths",   threshold = 5,       reward = 100000},
	{id = "tip_millionaire", name = "Tip Millionaire",  trigger = "totalEarned", threshold = 1000000, reward = 50000},
	{id = "food_mogul",      name = "Food Mogul",       trigger = "totalEarned", threshold = 10000000, reward = 500000},
}

return GameConfig
