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

	-- Tier 6: Celebrity Chef
	{name = "Cooking Show Studio", cost = 5000000,   income = 75000,   description = "TV fame pays well"},
	{name = "Michelin Restaurant", cost = 12000000,  income = 120000,  description = "3 stars of profit"},
	{name = "Food Network HQ",    cost = 25000000,  income = 200000,  description = "Media empire"},

	-- Tier 7: Global Food Chain
	{name = "Farm to Table Co",   cost = 50000000,  income = 350000,  description = "From soil to tips"},
	{name = "International Chain", cost = 100000000, income = 600000,  description = "Franchise worldwide"},
	{name = "Space Kitchen",      cost = 200000000, income = 1000000, description = "Zero-G gourmet"},

	-- Tier 8: Culinary Empire
	{name = "AI Cooking Lab",     cost = 500000000,  income = 1800000, description = "Robot chefs print money"},
	{name = "Flavor Dimension",   cost = 1000000000, income = 3000000, description = "Taste the multiverse"},
	{name = "Molecular Gastro Lab", cost = 2000000000, income = 5000000, description = "Science meets cuisine"},

	-- Tier 9: Legendary
	{name = "Ambrosia Factory",   cost = 5000000000,  income = 10000000,  description = "Food of the gods"},
	{name = "Infinity Buffet",    cost = 10000000000, income = 18000000,  description = "Never-ending feast"},

	-- Tier 10: Secret
	{name = "The Last Supper",    cost = 25000000000, income = 50000000,  description = "The ultimate meal", secret = true},

	-- VIP Exclusive
	{name = "VIP Rooftop Bar",    cost = 50000000000,  income = 80000000,  description = "Sky-high dining", vip = true},
	{name = "VIP Yacht Club",     cost = 100000000000, income = 150000000, description = "Nautical cuisine", vip = true},
	{name = "VIP Royal Feast",    cost = 250000000000, income = 300000000, description = "Fit for a king", vip = true},
}

-- Rebirth system (called "Prestige" in Restaurant Tycoon)
GameConfig.Rebirth = {
	baseCost = 500000,
	costMultiplier = 2.5,
	incomeMultiplier = 1.5,
	maxRebirths = 25,
}

GameConfig.StandardItemCount = 28
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
	Color3.fromRGB(255, 100, 50),   -- Tier 6: Celebrity Orange
	Color3.fromRGB(100, 200, 100),  -- Tier 7: Global Green
	Color3.fromRGB(200, 50, 200),   -- Tier 8: Empire Purple
	Color3.fromRGB(255, 255, 200),  -- Tier 9: Legendary Cream
	Color3.fromRGB(255, 215, 0),    -- Tier 10: Secret Gold
	Color3.fromRGB(255, 215, 0),    -- VIP Gold
}
GameConfig.BuildingHeights = {4, 6, 10, 14, 20, 25, 30, 35, 40, 45, 50}
GameConfig.BuildingMaterials = {"Wood", "Brick", "Brick", "Marble", "Marble", "ForceField", "DiamondPlate", "Glass", "Neon", "ForceField", "ForceField"}

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
	CASHFLOW = 25000,  -- Cross-promo: play CashFlow Empire
	GALAXY   = 25000,  -- Cross-promo: play Galaxy Empire
	TOWER    = 25000,  -- Cross-promo: play Tower of Chaos
}

GameConfig.DailyRewards = {500, 1500, 5000, 15000, 50000, 150000, 500000}

GameConfig.QuestPool = {
	{type = "earn_cash",        description = "Earn %s tips",          baseTarget = 50000,  rewardMult = 2},
	{type = "buy_items",        description = "Build %s stations",     baseTarget = 3,      rewardMult = 3},
	{type = "rebirth",          description = "Prestige %s time(s)",   baseTarget = 1,      rewardMult = 5},
	{type = "play_time",        description = "Cook for %s minutes",   baseTarget = 10,     rewardMult = 2},
	{type = "reach_item",       description = "Reach station #%s",     baseTarget = 10,     rewardMult = 3},
	{type = "discover_recipes", description = "Discover %s recipes",   baseTarget = 2,      rewardMult = 5},
}

GameConfig.Achievements = {
	{id = "first_dish",      name = "First Dish",       trigger = "items",      threshold = 1,       reward = 500},
	{id = "sous_chef",       name = "Sous Chef",        trigger = "items",      threshold = 5,       reward = 5000},
	{id = "head_chef",       name = "Head Chef",        trigger = "items",      threshold = 15,      reward = 50000},
	{id = "first_prestige",  name = "First Prestige",   trigger = "rebirths",   threshold = 1,       reward = 10000},
	{id = "master_chef",     name = "Master Chef",      trigger = "rebirths",   threshold = 5,       reward = 100000},
	{id = "tip_millionaire", name = "Tip Millionaire",  trigger = "totalEarned", threshold = 1000000, reward = 50000},
	{id = "food_mogul",      name = "Food Mogul",       trigger = "totalEarned", threshold = 10000000, reward = 500000},
	{id = "apprentice_chef", name = "Apprentice Chef",  trigger = "recipes",     threshold = 5,        reward = 10000},
	{id = "recipe_master",   name = "Recipe Master",    trigger = "recipes",     threshold = 20,       reward = 500000},
}

-- Recipe Lab: Ingredients
GameConfig.Ingredients = {
	{name = "Flour",     cost = 500},
	{name = "Eggs",      cost = 500},
	{name = "Sugar",     cost = 800},
	{name = "Butter",    cost = 800},
	{name = "Chocolate", cost = 1500},
	{name = "Vanilla",   cost = 1000},
	{name = "Cream",     cost = 1200},
	{name = "Fruit",     cost = 2000},
}

-- Recipe Lab: Recipes (keys are alphabetically-sorted ingredient combos)
GameConfig.Recipes = {
	["Butter,Flour,Sugar"]       = {name = "Classic Cookie",          bonus = 3},
	["Chocolate,Cream,Sugar"]    = {name = "Chocolate Mousse",        bonus = 5},
	["Cream,Fruit,Vanilla"]      = {name = "Fruit Parfait",           bonus = 4},
	["Eggs,Flour,Sugar"]         = {name = "Sponge Cake",             bonus = 3},
	["Butter,Chocolate,Cream"]   = {name = "Chocolate Truffle",       bonus = 6},
	["Eggs,Flour,Vanilla"]       = {name = "Vanilla Crepe",           bonus = 4},
	["Chocolate,Flour,Sugar"]    = {name = "Brownie",                 bonus = 3},
	["Butter,Eggs,Flour"]        = {name = "Croissant",               bonus = 4},
	["Fruit,Sugar,Vanilla"]      = {name = "Fruit Sorbet",            bonus = 5},
	["Cream,Eggs,Sugar"]         = {name = "Creme Brulee",            bonus = 5},
	["Butter,Sugar,Vanilla"]     = {name = "Caramel",                 bonus = 4},
	["Chocolate,Eggs,Flour"]     = {name = "Chocolate Cake",          bonus = 5},
	["Cream,Flour,Sugar"]        = {name = "Pancakes",                bonus = 3},
	["Chocolate,Fruit,Vanilla"]  = {name = "Chocolate Fondue",        bonus = 6},
	["Butter,Cream,Vanilla"]     = {name = "Ice Cream",               bonus = 5},
	["Eggs,Fruit,Sugar"]         = {name = "Fruit Tart",              bonus = 4},
	["Chocolate,Eggs,Vanilla"]   = {name = "Chocolate Souffle",       bonus = 7},
	["Butter,Fruit,Sugar"]       = {name = "Fruit Crumble",           bonus = 4},
	["Cream,Fruit,Sugar"]        = {name = "Fruit Smoothie",          bonus = 3},
	["Chocolate,Cream,Vanilla"]  = {name = "Dark Chocolate Ganache",  bonus = 6},
}

return GameConfig
