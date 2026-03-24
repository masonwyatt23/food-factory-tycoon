--[[
	RecipeUI — Recipe Lab interface
	Displays ingredient shop, mixing bowl for cooking, and recipe book.
	Purely cosmetic — all game state is server-authoritative.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local Utils = require(Shared:WaitForChild("Utils"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
local BuyIngredient = Remotes:WaitForChild("BuyIngredient", 15)
local CookRecipe = Remotes:WaitForChild("CookRecipe", 15)
local RecipeResult = Remotes:WaitForChild("RecipeResult", 15)
local RecipeInfo = Remotes:WaitForChild("RecipeInfo", 15)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Client state
local ingredientCounts = {} -- [name] = count
local discoveredRecipes = {} -- [key] = true
local totalBonus = 0
local selectedSlots = {} -- up to 3 ingredient names
local currentTab = "Cook" -- "Cook" or "Book"

-- Forward declarations
local updateMixingBowl
local refreshRecipeBook

-- UI references (set after creation)
local recipeFrame
local cookFrame
local bookFrame
local slotFrames = {}
local resultLabel
local ingredientButtons = {}
local bookScroll
local bookCounter

-- Helper: count discovered recipes
local function countDiscovered()
	local count = 0
	for _ in pairs(discoveredRecipes) do
		count = count + 1
	end
	return count
end

-- Helper: get all recipe keys sorted for consistent display
local function getSortedRecipeKeys()
	local keys = {}
	for key in pairs(GameConfig.Recipes) do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

-- Build the Recipe UI
local function createRecipeUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RecipeGUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	-- Main frame (centered, hidden by default)
	recipeFrame = Instance.new("Frame")
	recipeFrame.Name = "RecipeFrame"
	recipeFrame.Size = UDim2.new(0, 480, 0, 550)
	recipeFrame.Position = UDim2.new(0.5, -240, 0.5, -275)
	recipeFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	recipeFrame.BackgroundTransparency = 0.05
	recipeFrame.BorderSizePixel = 0
	recipeFrame.Visible = false
	recipeFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = recipeFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(200, 100, 30)
	stroke.Thickness = 2
	stroke.Parent = recipeFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -50, 0, 40)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "RECIPE LAB"
	title.TextColor3 = Color3.fromRGB(255, 200, 100)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = recipeFrame

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 35, 0, 35)
	closeBtn.Position = UDim2.new(1, -40, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 18
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = recipeFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		recipeFrame.Visible = false
	end)

	-- Tab buttons
	local cookTabBtn = Instance.new("TextButton")
	cookTabBtn.Name = "CookTab"
	cookTabBtn.Size = UDim2.new(0, 120, 0, 32)
	cookTabBtn.Position = UDim2.new(0, 10, 0, 42)
	cookTabBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 30)
	cookTabBtn.BorderSizePixel = 0
	cookTabBtn.Text = "Cook"
	cookTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	cookTabBtn.TextSize = 16
	cookTabBtn.Font = Enum.Font.GothamBold
	cookTabBtn.Parent = recipeFrame

	local cookTabCorner = Instance.new("UICorner")
	cookTabCorner.CornerRadius = UDim.new(0, 6)
	cookTabCorner.Parent = cookTabBtn

	local bookTabBtn = Instance.new("TextButton")
	bookTabBtn.Name = "BookTab"
	bookTabBtn.Size = UDim2.new(0, 120, 0, 32)
	bookTabBtn.Position = UDim2.new(0, 140, 0, 42)
	bookTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	bookTabBtn.BorderSizePixel = 0
	bookTabBtn.Text = "Recipe Book"
	bookTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
	bookTabBtn.TextSize = 16
	bookTabBtn.Font = Enum.Font.GothamBold
	bookTabBtn.Parent = recipeFrame

	local bookTabCorner = Instance.new("UICorner")
	bookTabCorner.CornerRadius = UDim.new(0, 6)
	bookTabCorner.Parent = bookTabBtn

	-- ========================
	-- COOK TAB FRAME
	-- ========================
	cookFrame = Instance.new("Frame")
	cookFrame.Name = "CookFrame"
	cookFrame.Size = UDim2.new(1, -20, 1, -85)
	cookFrame.Position = UDim2.new(0, 10, 0, 80)
	cookFrame.BackgroundTransparency = 1
	cookFrame.Visible = true
	cookFrame.Parent = recipeFrame

	-- Ingredient buttons (2 rows of 4)
	ingredientButtons = {}
	for i, ingredient in ipairs(GameConfig.Ingredients) do
		local col = ((i - 1) % 4)
		local row = math.floor((i - 1) / 4)
		local btnWidth = 105
		local btnHeight = 70
		local spacing = 8
		local startX = 5
		local startY = 0

		local card = Instance.new("Frame")
		card.Name = "Ingredient_" .. ingredient.name
		card.Size = UDim2.new(0, btnWidth, 0, btnHeight)
		card.Position = UDim2.new(0, startX + col * (btnWidth + spacing), 0, startY + row * (btnHeight + spacing))
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		card.BorderSizePixel = 0
		card.Parent = cookFrame

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card

		-- Ingredient name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -6, 0, 18)
		nameLabel.Position = UDim2.new(0, 3, 0, 2)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = ingredient.name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 13
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextXAlignment = Enum.TextXAlignment.Center
		nameLabel.Parent = card

		-- Count label
		local countLabel = Instance.new("TextLabel")
		countLabel.Name = "CountLabel"
		countLabel.Size = UDim2.new(1, -6, 0, 14)
		countLabel.Position = UDim2.new(0, 3, 0, 20)
		countLabel.BackgroundTransparency = 1
		countLabel.Text = "Owned: 0"
		countLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
		countLabel.TextSize = 11
		countLabel.Font = Enum.Font.Gotham
		countLabel.TextXAlignment = Enum.TextXAlignment.Center
		countLabel.Parent = card

		-- Buy button
		local buyBtn = Instance.new("TextButton")
		buyBtn.Name = "BuyBtn"
		buyBtn.Size = UDim2.new(1, -10, 0, 22)
		buyBtn.Position = UDim2.new(0, 5, 1, -26)
		buyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		buyBtn.BorderSizePixel = 0
		buyBtn.Text = "Buy $" .. Utils.formatCash(ingredient.cost)
		buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyBtn.TextSize = 11
		buyBtn.Font = Enum.Font.GothamBold
		buyBtn.Parent = card

		local buyBtnCorner = Instance.new("UICorner")
		buyBtnCorner.CornerRadius = UDim.new(0, 4)
		buyBtnCorner.Parent = buyBtn

		buyBtn.MouseButton1Click:Connect(function()
			if _G.PlayButtonClick then _G.PlayButtonClick() end
			BuyIngredient:FireServer(ingredient.name)
		end)

		-- Click card to add ingredient to mixing bowl
		local selectBtn = Instance.new("TextButton")
		selectBtn.Name = "SelectBtn"
		selectBtn.Size = UDim2.new(1, 0, 0, 34)
		selectBtn.Position = UDim2.new(0, 0, 0, 0)
		selectBtn.BackgroundTransparency = 1
		selectBtn.Text = ""
		selectBtn.Parent = card

		selectBtn.MouseButton1Click:Connect(function()
			if _G.PlayButtonClick then _G.PlayButtonClick() end
			-- Add to next empty slot if player has this ingredient
			local owned = ingredientCounts[ingredient.name] or 0
			-- Count how many of this ingredient are already in slots
			local inSlots = 0
			for _, slotName in ipairs(selectedSlots) do
				if slotName == ingredient.name then
					inSlots = inSlots + 1
				end
			end
			if owned <= inSlots then return end -- not enough
			if #selectedSlots >= 3 then return end -- slots full
			table.insert(selectedSlots, ingredient.name)
			updateMixingBowl()
		end)

		ingredientButtons[ingredient.name] = {
			card = card,
			countLabel = countLabel,
			buyBtn = buyBtn,
		}
	end

	-- Mixing bowl section label
	local bowlLabel = Instance.new("TextLabel")
	bowlLabel.Size = UDim2.new(1, 0, 0, 22)
	bowlLabel.Position = UDim2.new(0, 0, 0, 160)
	bowlLabel.BackgroundTransparency = 1
	bowlLabel.Text = "Mixing Bowl"
	bowlLabel.TextColor3 = Color3.fromRGB(200, 180, 140)
	bowlLabel.TextSize = 16
	bowlLabel.Font = Enum.Font.GothamBold
	bowlLabel.TextXAlignment = Enum.TextXAlignment.Center
	bowlLabel.Parent = cookFrame

	-- 3 mixing bowl slots
	slotFrames = {}
	for i = 1, 3 do
		local slotWidth = 130
		local totalWidth = slotWidth * 3 + 16
		local startX = (460 - totalWidth) / 2

		local slot = Instance.new("TextButton")
		slot.Name = "Slot" .. i
		slot.Size = UDim2.new(0, slotWidth, 0, 55)
		slot.Position = UDim2.new(0, startX + (i - 1) * (slotWidth + 8), 0, 185)
		slot.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
		slot.BorderSizePixel = 0
		slot.Text = "Empty"
		slot.TextColor3 = Color3.fromRGB(120, 120, 140)
		slot.TextSize = 14
		slot.Font = Enum.Font.Gotham
		slot.Parent = cookFrame

		local slotCorner = Instance.new("UICorner")
		slotCorner.CornerRadius = UDim.new(0, 8)
		slotCorner.Parent = slot

		local slotStroke = Instance.new("UIStroke")
		slotStroke.Color = Color3.fromRGB(80, 80, 100)
		slotStroke.Thickness = 1
		slotStroke.Parent = slot

		-- Click to remove ingredient from slot
		slot.MouseButton1Click:Connect(function()
			if selectedSlots[i] then
				table.remove(selectedSlots, i)
				updateMixingBowl()
			end
		end)

		slotFrames[i] = slot
	end

	-- COOK button
	local cookBtn = Instance.new("TextButton")
	cookBtn.Name = "CookButton"
	cookBtn.Size = UDim2.new(0, 160, 0, 45)
	cookBtn.Position = UDim2.new(0.5, -80, 0, 252)
	cookBtn.BackgroundColor3 = Color3.fromRGB(220, 120, 30)
	cookBtn.BorderSizePixel = 0
	cookBtn.Text = "COOK!"
	cookBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	cookBtn.TextSize = 22
	cookBtn.Font = Enum.Font.GothamBold
	cookBtn.Parent = cookFrame

	local cookBtnCorner = Instance.new("UICorner")
	cookBtnCorner.CornerRadius = UDim.new(0, 8)
	cookBtnCorner.Parent = cookBtn

	cookBtn.MouseButton1Click:Connect(function()
		if _G.PlayButtonClick then _G.PlayButtonClick() end
		if #selectedSlots < 3 then
			resultLabel.Text = "Select 3 ingredients first!"
			resultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			return
		end
		CookRecipe:FireServer(selectedSlots[1], selectedSlots[2], selectedSlots[3])
	end)

	-- Result display
	resultLabel = Instance.new("TextLabel")
	resultLabel.Name = "ResultLabel"
	resultLabel.Size = UDim2.new(1, -20, 0, 60)
	resultLabel.Position = UDim2.new(0, 10, 0, 305)
	resultLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
	resultLabel.BackgroundTransparency = 0.5
	resultLabel.BorderSizePixel = 0
	resultLabel.Text = "Combine 3 ingredients to discover recipes!"
	resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	resultLabel.TextSize = 14
	resultLabel.Font = Enum.Font.Gotham
	resultLabel.TextWrapped = true
	resultLabel.Parent = cookFrame

	local resultCorner = Instance.new("UICorner")
	resultCorner.CornerRadius = UDim.new(0, 8)
	resultCorner.Parent = resultLabel

	-- Bonus display at bottom of cook tab
	local bonusLabel = Instance.new("TextLabel")
	bonusLabel.Name = "BonusLabel"
	bonusLabel.Size = UDim2.new(1, -20, 0, 22)
	bonusLabel.Position = UDim2.new(0, 10, 1, -30)
	bonusLabel.BackgroundTransparency = 1
	bonusLabel.Text = "Recipe Bonus: +0% income"
	bonusLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
	bonusLabel.TextSize = 14
	bonusLabel.Font = Enum.Font.GothamBold
	bonusLabel.TextXAlignment = Enum.TextXAlignment.Center
	bonusLabel.Parent = cookFrame

	-- ========================
	-- RECIPE BOOK TAB FRAME
	-- ========================
	bookFrame = Instance.new("Frame")
	bookFrame.Name = "BookFrame"
	bookFrame.Size = UDim2.new(1, -20, 1, -85)
	bookFrame.Position = UDim2.new(0, 10, 0, 80)
	bookFrame.BackgroundTransparency = 1
	bookFrame.Visible = false
	bookFrame.Parent = recipeFrame

	-- Counter at top
	bookCounter = Instance.new("TextLabel")
	bookCounter.Name = "BookCounter"
	bookCounter.Size = UDim2.new(1, 0, 0, 25)
	bookCounter.Position = UDim2.new(0, 0, 0, 0)
	bookCounter.BackgroundTransparency = 1
	bookCounter.Text = "Recipes: 0/20 | Total Bonus: +0% income"
	bookCounter.TextColor3 = Color3.fromRGB(255, 200, 100)
	bookCounter.TextSize = 14
	bookCounter.Font = Enum.Font.GothamBold
	bookCounter.TextXAlignment = Enum.TextXAlignment.Center
	bookCounter.Parent = bookFrame

	-- ScrollingFrame for recipe cards
	bookScroll = Instance.new("ScrollingFrame")
	bookScroll.Name = "RecipeList"
	bookScroll.Size = UDim2.new(1, 0, 1, -32)
	bookScroll.Position = UDim2.new(0, 0, 0, 30)
	bookScroll.BackgroundTransparency = 1
	bookScroll.BorderSizePixel = 0
	bookScroll.ScrollBarThickness = 6
	bookScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 100, 30)
	bookScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	bookScroll.Parent = bookFrame

	local bookListLayout = Instance.new("UIListLayout")
	bookListLayout.Padding = UDim.new(0, 6)
	bookListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	bookListLayout.Parent = bookScroll

	bookListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		bookScroll.CanvasSize = UDim2.new(0, 0, 0, bookListLayout.AbsoluteContentSize.Y + 10)
	end)

	-- Tab switching
	local function switchTab(tab)
		currentTab = tab
		if tab == "Cook" then
			cookFrame.Visible = true
			bookFrame.Visible = false
			cookTabBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 30)
			cookTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			bookTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
			bookTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		else
			cookFrame.Visible = false
			bookFrame.Visible = true
			cookTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
			cookTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
			bookTabBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 30)
			bookTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			refreshRecipeBook()
		end
	end

	cookTabBtn.MouseButton1Click:Connect(function()
		if _G.PlayButtonClick then _G.PlayButtonClick() end
		switchTab("Cook")
	end)

	bookTabBtn.MouseButton1Click:Connect(function()
		if _G.PlayButtonClick then _G.PlayButtonClick() end
		switchTab("Book")
	end)

	return screenGui
end

-- Update mixing bowl slot display
updateMixingBowl = function()
	for i = 1, 3 do
		local slot = slotFrames[i]
		if selectedSlots[i] then
			slot.Text = selectedSlots[i]
			slot.TextColor3 = Color3.fromRGB(255, 255, 255)
			slot.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
		else
			slot.Text = "Empty"
			slot.TextColor3 = Color3.fromRGB(120, 120, 140)
			slot.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
		end
	end
end

-- Update ingredient count displays
local function updateIngredientDisplay()
	for _, ingredient in ipairs(GameConfig.Ingredients) do
		local btn = ingredientButtons[ingredient.name]
		if btn then
			local count = ingredientCounts[ingredient.name] or 0
			btn.countLabel.Text = "Owned: " .. count
		end
	end

	-- Update bonus label
	local bonusLabel = cookFrame:FindFirstChild("BonusLabel")
	if bonusLabel then
		bonusLabel.Text = "Recipe Bonus: +" .. totalBonus .. "% income"
	end
end

-- Refresh recipe book display
refreshRecipeBook = function()
	if not bookScroll then return end

	-- Clear existing cards
	for _, child in ipairs(bookScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Update counter
	local discovered = countDiscovered()
	bookCounter.Text = "Recipes: " .. discovered .. "/20 | Total Bonus: +" .. totalBonus .. "% income"

	-- Create recipe cards
	local sortedKeys = getSortedRecipeKeys()
	for order, key in ipairs(sortedKeys) do
		local recipe = GameConfig.Recipes[key]
		local isDiscovered = discoveredRecipes[key] == true
		local ingredients = key:split(",")

		local card = Instance.new("Frame")
		card.Name = "Recipe_" .. order
		card.Size = UDim2.new(1, -4, 0, 55)
		card.BorderSizePixel = 0
		card.LayoutOrder = order
		card.Parent = bookScroll

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card

		if isDiscovered then
			card.BackgroundColor3 = Color3.fromRGB(30, 60, 30)

			-- Recipe name
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0.65, -10, 0, 22)
			nameLabel.Position = UDim2.new(0, 10, 0, 4)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = recipe.name
			nameLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
			nameLabel.TextSize = 15
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = card

			-- Ingredients
			local ingLabel = Instance.new("TextLabel")
			ingLabel.Size = UDim2.new(0.65, -10, 0, 18)
			ingLabel.Position = UDim2.new(0, 10, 0, 28)
			ingLabel.BackgroundTransparency = 1
			ingLabel.Text = table.concat(ingredients, " + ")
			ingLabel.TextColor3 = Color3.fromRGB(160, 200, 160)
			ingLabel.TextSize = 11
			ingLabel.Font = Enum.Font.Gotham
			ingLabel.TextXAlignment = Enum.TextXAlignment.Left
			ingLabel.Parent = card

			-- Bonus
			local bonusLabel = Instance.new("TextLabel")
			bonusLabel.Size = UDim2.new(0.35, -10, 1, 0)
			bonusLabel.Position = UDim2.new(0.65, 0, 0, 0)
			bonusLabel.BackgroundTransparency = 1
			bonusLabel.Text = "+" .. recipe.bonus .. "% income"
			bonusLabel.TextColor3 = Color3.fromRGB(255, 215, 100)
			bonusLabel.TextSize = 14
			bonusLabel.Font = Enum.Font.GothamBold
			bonusLabel.TextXAlignment = Enum.TextXAlignment.Right
			bonusLabel.Parent = card
		else
			card.BackgroundColor3 = Color3.fromRGB(35, 35, 50)

			-- Mystery name
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0.65, -10, 0, 22)
			nameLabel.Position = UDim2.new(0, 10, 0, 4)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = "???"
			nameLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
			nameLabel.TextSize = 15
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = card

			-- Hint: show first ingredient
			local hintLabel = Instance.new("TextLabel")
			hintLabel.Size = UDim2.new(0.65, -10, 0, 18)
			hintLabel.Position = UDim2.new(0, 10, 0, 28)
			hintLabel.BackgroundTransparency = 1
			hintLabel.Text = "Hint: " .. ingredients[1] .. " + ? + ?"
			hintLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
			hintLabel.TextSize = 11
			hintLabel.Font = Enum.Font.Gotham
			hintLabel.TextXAlignment = Enum.TextXAlignment.Left
			hintLabel.Parent = card

			-- Locked bonus
			local bonusLabel = Instance.new("TextLabel")
			bonusLabel.Size = UDim2.new(0.35, -10, 1, 0)
			bonusLabel.Position = UDim2.new(0.65, 0, 0, 0)
			bonusLabel.BackgroundTransparency = 1
			bonusLabel.Text = "+?% income"
			bonusLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
			bonusLabel.TextSize = 14
			bonusLabel.Font = Enum.Font.GothamBold
			bonusLabel.TextXAlignment = Enum.TextXAlignment.Right
			bonusLabel.Parent = card
		end
	end
end

-- Create the UI
local recipeGui = createRecipeUI()

-- Expose toggle for TycoonUI button
_G.ShowRecipeUI = function()
	recipeFrame.Visible = not recipeFrame.Visible
end

-- Handle server events
RecipeInfo.OnClientEvent:Connect(function(info)
	if not info then return end
	ingredientCounts = info.ingredients or {}
	discoveredRecipes = info.discovered or {}
	totalBonus = info.bonus or 0
	updateIngredientDisplay()
	if currentTab == "Book" then
		refreshRecipeBook()
	end
end)

RecipeResult.OnClientEvent:Connect(function(result)
	if not result then return end

	if result.success then
		resultLabel.Text = result.message
		resultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		-- Clear mixing bowl on success
		selectedSlots = {}
		updateMixingBowl()
	else
		resultLabel.Text = result.message
		resultLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
	end
end)

print("[RecipeUI] Initialized")
