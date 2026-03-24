--[[
	RecipeManager — Recipe Lab crafting/discovery system
	Players buy ingredients and combine 3 at a time to discover recipes.
	Each discovered recipe gives a permanent income bonus.
	Server-authoritative: all validation and state changes happen here.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Create RemoteEvents
local function createRemote(name)
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = Remotes
	return remote
end

local BuyIngredientRemote = createRemote("BuyIngredient")
local CookRecipeRemote = createRemote("CookRecipe")
local RecipeResultRemote = createRemote("RecipeResult")
local RecipeInfoRemote = createRemote("RecipeInfo")

-- Build ingredient cost lookup from GameConfig
local IngredientCosts = {}
for _, ingredient in ipairs(GameConfig.Ingredients) do
	IngredientCosts[ingredient.name] = ingredient.cost
end

-- Build valid ingredient name set for validation
local ValidIngredients = {}
for _, ingredient in ipairs(GameConfig.Ingredients) do
	ValidIngredients[ingredient.name] = true
end

-- Rate limiting for cooking
local lastCookTime = {} -- [player] = tick()

-- Poll-wait helper: waits for a _G function to be registered by another script
local function waitForGlobal(name, timeout)
	local elapsed = 0
	while not _G[name] and elapsed < (timeout or 30) do
		task.wait(0.1)
		elapsed = elapsed + 0.1
	end
	return _G[name] ~= nil
end

-- Wait for dependencies
if not waitForGlobal("GetPlayerData", 30) then
	warn("[RecipeManager] Timed out waiting for GetPlayerData")
	return
end
if not waitForGlobal("AddCash", 30) then
	warn("[RecipeManager] Timed out waiting for AddCash")
	return
end

-- Get recipe bonus multiplier for a player (called by TycoonManager)
function _G.GetRecipeBonus(player)
	local data = _G.GetPlayerData(player)
	if not data then return 1 end
	return 1 + ((data.recipeBonus or 0) / 100)
end

-- Send current recipe state to a player
local function sendRecipeInfo(player)
	local data = _G.GetPlayerData(player)
	if not data then return end

	-- Ensure fields exist
	if not data.ingredientInventory then data.ingredientInventory = {} end
	if not data.discoveredRecipes then data.discoveredRecipes = {} end
	if not data.recipeBonus then data.recipeBonus = 0 end

	RecipeInfoRemote:FireClient(player, {
		ingredients = data.ingredientInventory,
		discovered = data.discoveredRecipes,
		bonus = data.recipeBonus,
	})
end

-- Handle ingredient purchase
BuyIngredientRemote.OnServerEvent:Connect(function(player, ingredientName)
	local data = _G.GetPlayerData(player)
	if not data then return end

	-- Validate ingredient name
	if type(ingredientName) ~= "string" then return end
	if not ValidIngredients[ingredientName] then return end

	local cost = IngredientCosts[ingredientName]
	if not cost then return end

	-- Validate player has enough Tips
	if data.cash < cost then return end

	-- Ensure inventory table exists
	if not data.ingredientInventory then data.ingredientInventory = {} end

	-- Deduct cash
	_G.AddCash(player, -cost)

	-- Add ingredient to inventory
	data.ingredientInventory[ingredientName] = (data.ingredientInventory[ingredientName] or 0) + 1

	-- Send updated state
	sendRecipeInfo(player)
end)

-- Handle cooking attempt
CookRecipeRemote.OnServerEvent:Connect(function(player, ingredient1, ingredient2, ingredient3)
	local data = _G.GetPlayerData(player)
	if not data then return end

	-- Rate limit: 1 cook per second
	local now = tick()
	if lastCookTime[player] and (now - lastCookTime[player]) < 1 then return end
	lastCookTime[player] = now

	-- Validate input types
	if type(ingredient1) ~= "string" or type(ingredient2) ~= "string" or type(ingredient3) ~= "string" then
		return
	end

	-- Validate all ingredients exist
	if not ValidIngredients[ingredient1] or not ValidIngredients[ingredient2] or not ValidIngredients[ingredient3] then
		return
	end

	-- Ensure inventory table exists
	if not data.ingredientInventory then data.ingredientInventory = {} end
	if not data.discoveredRecipes then data.discoveredRecipes = {} end
	if not data.recipeBonus then data.recipeBonus = 0 end

	-- Validate player has all 3 ingredients in inventory
	-- Handle duplicate ingredients (e.g., 2x Flour + 1x Sugar)
	local needed = {}
	needed[ingredient1] = (needed[ingredient1] or 0) + 1
	needed[ingredient2] = (needed[ingredient2] or 0) + 1
	needed[ingredient3] = (needed[ingredient3] or 0) + 1

	for name, count in pairs(needed) do
		if (data.ingredientInventory[name] or 0) < count then
			return -- not enough of this ingredient
		end
	end

	-- Sort alphabetically to create recipe key
	local sorted = {ingredient1, ingredient2, ingredient3}
	table.sort(sorted)
	local recipeKey = table.concat(sorted, ",")

	-- Look up recipe
	local recipe = GameConfig.Recipes[recipeKey]

	if recipe then
		-- Check if already discovered
		if data.discoveredRecipes[recipeKey] then
			-- Already discovered — return ingredients (no cost)
			RecipeResultRemote:FireClient(player, {
				success = false,
				message = "You already discovered " .. recipe.name .. "!",
			})
			return
		end

		-- Consume ingredients
		for name, count in pairs(needed) do
			data.ingredientInventory[name] = data.ingredientInventory[name] - count
			if data.ingredientInventory[name] <= 0 then
				data.ingredientInventory[name] = nil
			end
		end

		-- Add to discovered recipes
		data.discoveredRecipes[recipeKey] = true

		-- Add bonus to total
		data.recipeBonus = data.recipeBonus + recipe.bonus

		-- Notify client of success
		RecipeResultRemote:FireClient(player, {
			success = true,
			recipeName = recipe.name,
			bonus = recipe.bonus,
			totalBonus = data.recipeBonus,
			message = "Discovered: " .. recipe.name .. "! (+" .. recipe.bonus .. "% income)",
		})

		-- Send updated state
		sendRecipeInfo(player)

		print("[RecipeManager] " .. player.Name .. " discovered: " .. recipe.name)
	else
		-- No recipe found — return ingredients (no cost)
		RecipeResultRemote:FireClient(player, {
			success = false,
			message = "No recipe found with those ingredients!",
		})
	end
end)

-- Send recipe info when player joins (after data is ready)
Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		-- Wait for player data to be available
		local elapsed = 0
		while not _G.GetPlayerData(player) and elapsed < 15 do
			task.wait(0.5)
			elapsed = elapsed + 0.5
		end
		sendRecipeInfo(player)
	end)
end)

-- Handle players already in game (Studio testing)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		local elapsed = 0
		while not _G.GetPlayerData(player) and elapsed < 15 do
			task.wait(0.5)
			elapsed = elapsed + 0.5
		end
		sendRecipeInfo(player)
	end)
end

-- Clean up rate limit tracking
Players.PlayerRemoving:Connect(function(player)
	lastCookTime[player] = nil
end)

print("[RecipeManager] Initialized")
