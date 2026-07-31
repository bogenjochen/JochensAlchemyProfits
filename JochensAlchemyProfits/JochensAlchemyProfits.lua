-- JochensAlchemyProfits
-- Turtle WoW / Vanilla 1.12.1 (Interface 11200)
-- No external libraries required.

JAP = {}
JAP.version = "0.10.0"
JAP.recipes = {}
JAP.recipeByName = {}
JAP.priceCache = {}
JAP.scanQueue = {}
JAP.currentScan = nil
JAP.scanRunning = false
JAP.selectedRecipe = nil
JAP.selectedRecipes = {}
JAP.lastQueryAt = 0
JAP.queryDelay = 0.55
JAP.pendingQuery = nil
JAP.rows = {}
JAP.visibleRows = 12
JAP.scrollOffset = 0
JAP.sortMode = "skill"
JAP.favoritesOnly = false
JAP.productsOnly = false
JAP.displayRecipes = {}

local function chat(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffJAP:|r " .. tostring(message))
    end
end

local function trim(value)
    if not value then return "" end
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function lower(value)
    if not value then return "" end
    return string.lower(value)
end

local function now()
    return GetTime()
end

local function tableCount(t)
    local count = 0
    local key
    for key in pairs(t) do
        count = count + 1
    end
    return count
end

local function clearArray(t)
    local i
    for i = table.getn(t), 1, -1 do
        table.remove(t, i)
    end
end

local function moneyToText(copper)
    if copper == nil then return "N/A" end
    copper = math.floor(copper + 0.5)
    local sign = ""
    if copper < 0 then
        sign = "-"
        copper = -copper
    end
    local gold = math.floor(copper / 10000)
    local silver = math.floor(math.mod(copper, 10000) / 100)
    local coin = math.mod(copper, 100)
    if gold > 0 then
        return sign .. gold .. "g " .. silver .. "s " .. coin .. "c"
    elseif silver > 0 then
        return sign .. silver .. "s " .. coin .. "c"
    end
    return sign .. coin .. "c"
end

local function parseMoney(text)
    if not text then return nil end
    text = lower(trim(text))
    local _, _, goldText = string.find(text, "(%d+)%s*g")
    local _, _, silverText = string.find(text, "(%d+)%s*s")
    local _, _, copperText = string.find(text, "(%d+)%s*c")
    local gold = tonumber(goldText) or 0
    local silver = tonumber(silverText) or 0
    local copper = tonumber(copperText) or 0
    if gold == 0 and silver == 0 and copper == 0 then
        local plain = tonumber(text)
        if plain then return plain end
        return nil
    end
    return gold * 10000 + silver * 100 + copper
end

local function getItemId(link)
    if not link then return nil end
    local _, _, id = string.find(link, "item:(%d+)")
    return tonumber(id)
end

local function getItemNameFromLink(link)
    if not link then return nil end

    -- GetItemInfo is the preferred source because it returns the actual output item,
    -- not the profession recipe name.
    local itemName = GetItemInfo(link)
    if itemName then
        return itemName
    end

    -- Vanilla item links contain the visible item name in square brackets.
    local _, _, linkedName = string.find(link, "%[(.-)%]")
    return linkedName
end

local function normalizeKey(name)
    return lower(trim(name))
end

local function isExcludedVial(name)
    if not name then return false end
    return string.find(normalizeKey(name), "vial", 1, true) ~= nil
end

local function readRequiredSkillFromTooltip(professionName)
    local professionKey = normalizeKey(professionName)
    local lineIndex
    for lineIndex = 1, JAPSkillTooltip:NumLines() do
        local leftLine = getglobal("JAPSkillTooltipTextLeft" .. lineIndex)
        local rightLine = getglobal("JAPSkillTooltipTextRight" .. lineIndex)
        local candidates = {
            leftLine and leftLine:GetText(),
            rightLine and rightLine:GetText()
        }

        local candidateIndex
        for candidateIndex = 1, table.getn(candidates) do
            local text = candidates[candidateIndex]
            if text then
                local textKey = normalizeKey(text)
                local professionMatches =
                    professionKey == "" or
                    string.find(textKey, professionKey, 1, true) or
                    string.find(textKey, "alchemy", 1, true)

                if professionMatches then
                    local _, _, required = string.find(text, "%((%d+)%)")
                    if not required then
                        _, _, required = string.find(text, "(%d+)")
                    end
                    if required then
                        return tonumber(required)
                    end
                end
            end
        end
    end
    return nil
end

local function getRequiredSkill(index, professionName, recipeName)
    local database = db and db() or JochensAlchemyProfitsDB
    local key = normalizeKey(recipeName)
    if database and database.manualSkills and database.manualSkills[key] then
        return database.manualSkills[key], "manual"
    end

    if not JAPSkillTooltip then
        CreateFrame("GameTooltip", "JAPSkillTooltip", UIParent, "GameTooltipTemplate")
        JAPSkillTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end

    -- The crafted-item tooltip usually does not contain the recipe requirement.
    -- The recipe link does, so it must be attempted first.
    if GetTradeSkillRecipeLink then
        local recipeLink = GetTradeSkillRecipeLink(index)
        if recipeLink then
            JAPSkillTooltip:ClearLines()
            JAPSkillTooltip:SetHyperlink(recipeLink)
            local required = readRequiredSkillFromTooltip(professionName)
            if required then
                return required, "recipe"
            end
        end
    end

    -- Turtle clients may expose recipe data only while the trade-skill row is selected.
    if SelectTradeSkill then
        SelectTradeSkill(index)
        if GetTradeSkillRecipeLink then
            local selectedRecipeLink = GetTradeSkillRecipeLink(index)
            if selectedRecipeLink then
                JAPSkillTooltip:ClearLines()
                JAPSkillTooltip:SetHyperlink(selectedRecipeLink)
                local selectedRequired = readRequiredSkillFromTooltip(professionName)
                if selectedRequired then
                    return selectedRequired, "recipe"
                end
            end
        end
    end

    return nil, nil
end

local function difficultyRank(skillType)
    if skillType == "optimal" then return 4 end
    if skillType == "medium" then return 3 end
    if skillType == "easy" then return 2 end
    if skillType == "trivial" then return 1 end
    return 0
end

local function db()
    if not JochensAlchemyProfitsDB then
        JochensAlchemyProfitsDB = {}
    end
    if not JochensAlchemyProfitsDB.prices then
        JochensAlchemyProfitsDB.prices = {}
    end
    if not JochensAlchemyProfitsDB.manualPrices then
        JochensAlchemyProfitsDB.manualPrices = {}
    end
    if not JochensAlchemyProfitsDB.settings then
        JochensAlchemyProfitsDB.settings = {}
    end
    if not JochensAlchemyProfitsDB.favorites then
        JochensAlchemyProfitsDB.favorites = {}
    end
    if not JochensAlchemyProfitsDB.manualSkills then
        JochensAlchemyProfitsDB.manualSkills = {}
    end
    if not JochensAlchemyProfitsDB.recipes then
        JochensAlchemyProfitsDB.recipes = {}
    end
    if JochensAlchemyProfitsDB.settings.cacheMinutes == nil then
        JochensAlchemyProfitsDB.settings.cacheMinutes = 5
    end
    if JochensAlchemyProfitsDB.settings.ahCutPercent == nil then
        JochensAlchemyProfitsDB.settings.ahCutPercent = 5
    end
    if JochensAlchemyProfitsDB.settings.undercutCopper == nil then
        JochensAlchemyProfitsDB.settings.undercutCopper = 1
    end
    if JochensAlchemyProfitsDB.settings.sortMode == nil
       or JochensAlchemyProfitsDB.settings.sortMode == "skill" then
        JochensAlchemyProfitsDB.settings.sortMode = "alphabetical"
    end
    if JochensAlchemyProfitsDB.settings.favoritesOnly == nil then
        JochensAlchemyProfitsDB.settings.favoritesOnly = false
    end
    if JochensAlchemyProfitsDB.settings.productsOnly == nil then
        JochensAlchemyProfitsDB.settings.productsOnly = false
    end
    return JochensAlchemyProfitsDB
end

local function getCachedPrice(name)
    local key = normalizeKey(name)
    local database = db()

    if database.manualPrices[key] ~= nil then
        return database.manualPrices[key], "manual", nil
    end

    local entry = database.prices[key]
    if not entry then return nil, nil, nil end

    local age = time() - (entry.savedAt or 0)
    local maxAge = (database.settings.cacheMinutes or 5) * 60
    if age <= maxAge then
        return entry.unitBuyout, "cache", age
    end
    return nil, "stale", age
end

local function getAnyStoredPrice(name)
    local key = normalizeKey(name)
    local database = db()
    if database.manualPrices[key] ~= nil then
        return database.manualPrices[key], "manual"
    end
    local entry = database.prices[key]
    if entry then
        return entry.unitBuyout, "old"
    end
    return nil, nil
end

local function saveAuctionPrice(name, unitBuyout, itemId, auctions, scanMeta)
    local key = normalizeKey(name)
    db().prices[key] = {
        name = name,
        unitBuyout = unitBuyout,
        itemId = itemId,
        auctions = auctions or 0,
        pages = scanMeta and scanMeta.pages or 0,
        bestStackSize = scanMeta and scanMeta.bestStackSize or nil,
        bestStackBuyout = scanMeta and scanMeta.bestStackBuyout or nil,
        itemType = scanMeta and scanMeta.bestItemType or nil,
        itemSubType = scanMeta and scanMeta.bestItemSubType or nil,
        rejectedRecipes = scanMeta and scanMeta.rejectedRecipes or 0,
        savedAt = time()
    }
end

local function setStatus(text)
    if JAP.statusText then
        JAP.statusText:SetText(text or "")
    end
end

function JAP:SaveRecipes()
    local database = db()
    database.recipes = {}

    local recipeIndex
    for recipeIndex = 1, table.getn(self.recipes) do
        local recipe = self.recipes[recipeIndex]
        local savedRecipe = {
            name = recipe.name,
            key = recipe.key,
            productName = recipe.productName,
            productLink = recipe.productLink,
            productId = recipe.productId,
            minMade = recipe.minMade,
            maxMade = recipe.maxMade,
            skillType = recipe.skillType,
            requiredSkill = recipe.requiredSkill,
            requiredSkillSource = recipe.requiredSkillSource,
            reagents = {}
        }

        local reagentIndex
        for reagentIndex = 1, table.getn(recipe.reagents or {}) do
            local reagent = recipe.reagents[reagentIndex]
            table.insert(savedRecipe.reagents, {
                name = reagent.name,
                key = reagent.key,
                count = reagent.count,
                link = reagent.link,
                itemId = reagent.itemId
            })
        end

        table.insert(database.recipes, savedRecipe)
    end
end

function JAP:LoadSavedRecipes()
    local savedRecipes = db().recipes
    if not savedRecipes or table.getn(savedRecipes) == 0 then
        return false
    end

    clearArray(self.recipes)
    self.recipeByName = {}

    local recipeIndex
    for recipeIndex = 1, table.getn(savedRecipes) do
        local saved = savedRecipes[recipeIndex]
        if saved and saved.name then
            local recipe = {
                index = nil,
                name = saved.name,
                key = saved.key or normalizeKey(saved.name),
                productName = saved.productName or saved.name,
                productLink = saved.productLink,
                productId = saved.productId,
                minMade = saved.minMade or 1,
                maxMade = saved.maxMade or saved.minMade or 1,
                skillType = saved.skillType,
                requiredSkill = saved.requiredSkill,
                requiredSkillSource = saved.requiredSkillSource,
                reagents = {},
                result = nil
            }

            local reagentIndex
            for reagentIndex = 1, table.getn(saved.reagents or {}) do
                local reagent = saved.reagents[reagentIndex]
                if reagent and reagent.name then
                    table.insert(recipe.reagents, {
                        name = reagent.name,
                        key = reagent.key or normalizeKey(reagent.name),
                        count = reagent.count or 1,
                        link = reagent.link,
                        itemId = reagent.itemId
                    })
                end
            end

            table.insert(self.recipes, recipe)
            self.recipeByName[recipe.key] = recipe
        end
    end

    self.sortMode = db().settings.sortMode or "alphabetical"
    self:ApplySort()
    self.selectedRecipe = self.recipes[1]
    self.selectedRecipes = {}
    if self.selectedRecipe then
        self.selectedRecipes[self.selectedRecipe.key] = true
    end
    self:CalculateAllProfits()
    return table.getn(self.recipes) > 0
end

function JAP:ClearSavedRecipes()
    clearArray(self.recipes)
    clearArray(self.displayRecipes)
    self.recipeByName = {}
    self.selectedRecipe = nil
    self.selectedRecipes = {}
    self.scrollOffset = 0
    db().recipes = {}

    setStatus("Saved recipes cleared. Open Alchemy and click Read Alchemy.")
    chat("Saved recipes cleared. Open Alchemy and click Read Alchemy to scan them again.")
    self:RefreshUI()
end

function JAP:ReadAlchemy()
    if not TradeSkillFrame or not TradeSkillFrame:IsVisible() then
        chat("Open your Alchemy profession window first.")
        return false
    end

    local skillName = GetTradeSkillLine()
    if not skillName or lower(skillName) ~= "alchemy" then
        -- Localized clients may not return the English name. We still allow scanning.
        chat("Reading the currently open profession: " .. tostring(skillName or "unknown"))
    end

    clearArray(self.recipes)
    self.recipeByName = {}

    local count = GetNumTradeSkills()
    local index
    for index = 1, count do
        local recipeName, skillType = GetTradeSkillInfo(index)
        if recipeName and skillType ~= "header" then
            local productLink = GetTradeSkillItemLink(index)
            local productId = getItemId(productLink)
            local productName = recipeName
            if productLink and GetItemInfo then
                local linkedName = GetItemInfo(productLink)
                if linkedName then productName = linkedName end
            end
            local minMade, maxMade = GetTradeSkillNumMade(index)
            minMade = minMade or 1
            maxMade = maxMade or minMade

            local requiredSkill, requiredSkillSource = getRequiredSkill(index, skillName, recipeName)
            local recipe = {
                index = index,
                name = recipeName,
                key = normalizeKey(recipeName),
                productName = productName,
                productLink = productLink,
                productId = productId,
                minMade = minMade,
                maxMade = maxMade,
                skillType = skillType,
                requiredSkill = requiredSkill,
                requiredSkillSource = requiredSkillSource,
                reagents = {},
                result = nil
            }

            local reagentCount = GetTradeSkillNumReagents(index) or 0
            local reagentIndex
            for reagentIndex = 1, reagentCount do
                local reagentName, reagentTexture, requiredCount = GetTradeSkillReagentInfo(index, reagentIndex)
                local reagentLink = nil
                if GetTradeSkillReagentItemLink then
                    reagentLink = GetTradeSkillReagentItemLink(index, reagentIndex)
                end
                if reagentName then
                    table.insert(recipe.reagents, {
                        name = reagentName,
                        key = normalizeKey(reagentName),
                        count = requiredCount or 1,
                        link = reagentLink,
                        itemId = getItemId(reagentLink)
                    })
                end
            end

            table.insert(self.recipes, recipe)
            self.recipeByName[recipe.key] = recipe
        end
    end

    self.sortMode = db().settings.sortMode or "alphabetical"
    self:ApplySort()

    if table.getn(self.recipes) > 0 then
        self.selectedRecipe = self.recipes[1]
        self.selectedRecipes = {}
        self.selectedRecipes[self.selectedRecipe.key] = true
    else
        self.selectedRecipe = nil
    end

    self:SaveRecipes()
    chat("Read and saved " .. table.getn(self.recipes) .. " learned recipes.")
    self:RefreshUI()
    return true
end

function JAP:IsFavorite(recipe)
    if not recipe then return false end
    return db().favorites[recipe.key] == true
end

function JAP:ToggleFavorite(recipe)
    if not recipe then
        chat("Select a recipe first.")
        return
    end

    local database = db()
    database.favorites[recipe.key] = not database.favorites[recipe.key]
    if database.favorites[recipe.key] == false then
        database.favorites[recipe.key] = nil
        chat(recipe.name .. " removed from favorites and saved.")
    else
        chat(recipe.name .. " added to favorites and saved.")
    end

    self:BuildDisplayRecipes()
    if self.favoritesOnly and not self:IsFavorite(self.selectedRecipe) then
        self.selectedRecipe = self.displayRecipes[1]
    end

    self:RefreshUI()
end

function JAP:SetFavoritesOnly(enabled)
    self.favoritesOnly = enabled and true or false
    db().settings.favoritesOnly = self.favoritesOnly
    self.scrollOffset = 0

    self:BuildDisplayRecipes()

    if self.favoritesOnly then
        if table.getn(self.displayRecipes) > 0 then
            if not self.selectedRecipe or not self:IsFavorite(self.selectedRecipe) then
                self.selectedRecipe = self.displayRecipes[1]
                self.selectedRecipes = {}
                self.selectedRecipes[self.selectedRecipe.key] = true
            end
            setStatus("Showing " .. table.getn(self.displayRecipes) .. " favorite recipes.")
        else
            self.selectedRecipe = nil
            self.selectedRecipes = {}
            setStatus("No favorite recipes yet. Show all recipes and add one.")
        end
    else
        if not self.selectedRecipe and table.getn(self.displayRecipes) > 0 then
            self.selectedRecipe = self.displayRecipes[1]
        end
        setStatus("Showing all " .. table.getn(self.displayRecipes) .. " recipes.")
    end

    self:RefreshUI()
end

function JAP:BuildDisplayRecipes()
    clearArray(self.displayRecipes)
    local i
    for i = 1, table.getn(self.recipes) do
        local recipe = self.recipes[i]
        if not self.favoritesOnly or self:IsFavorite(recipe) then
            table.insert(self.displayRecipes, recipe)
        end
    end
end

function JAP:ApplySort()
    local mode = self.sortMode or "alphabetical"

    table.sort(self.recipes, function(a, b)
        if mode == "profit" then
            local ap = a.result and a.result.profit
            local bp = b.result and b.result.profit
            if ap ~= nil and bp ~= nil and ap ~= bp then
                return ap > bp
            elseif ap ~= nil and bp == nil then
                return true
            elseif ap == nil and bp ~= nil then
                return false
            end
        end

        return lower(a.name) < lower(b.name)
    end)
end

function JAP:SetSortMode(mode)
    if mode ~= "alphabetical" and mode ~= "profit" then
        return
    end
    self.sortMode = mode
    db().settings.sortMode = mode
    self.scrollOffset = 0
    self:ApplySort()
    self:RefreshUI()
end

function JAP:IsRecipeSelected(recipe)
    if not recipe then return false end
    return self.selectedRecipes[recipe.key] == true
end

function JAP:GetSelectedRecipes()
    local selected = {}
    local i
    for i = 1, table.getn(self.recipes) do
        local recipe = self.recipes[i]
        if self:IsRecipeSelected(recipe) then
            table.insert(selected, recipe)
        end
    end
    return selected
end

function JAP:GetSelectedRecipeCount()
    return table.getn(self:GetSelectedRecipes())
end

function JAP:SelectRecipe(recipe, additive)
    if not recipe then return end

    if not additive then
        self.selectedRecipes = {}
        self.selectedRecipes[recipe.key] = true
        self.selectedRecipe = recipe
    else
        if self.selectedRecipes[recipe.key] then
            self.selectedRecipes[recipe.key] = nil
            if self.selectedRecipe == recipe then
                local remaining = self:GetSelectedRecipes()
                self.selectedRecipe = remaining[1]
            end
        else
            self.selectedRecipes[recipe.key] = true
            self.selectedRecipe = recipe
        end
    end

    self:RefreshUI()
end

function JAP:SetProductsOnly(enabled)
    self.productsOnly = enabled and true or false
    db().settings.productsOnly = self.productsOnly

    if self.productsOnly then
        setStatus("Scan mode: crafted potion prices only. Ingredient prices will not be refreshed.")
        chat("Scan mode changed: crafted potion prices only.")
    else
        setStatus("Scan mode: full scan of crafted potions and ingredients.")
        chat("Scan mode changed: full potion and ingredient scan.")
    end

    self:RefreshUI()
end

function JAP:BuildSelectedScan()
    local selected = self:GetSelectedRecipes()

    if table.getn(selected) == 0 and self.selectedRecipe then
        self.selectedRecipes[self.selectedRecipe.key] = true
        selected = self:GetSelectedRecipes()
    end

    if table.getn(selected) == 0 then
        chat("Select one or more recipes first.")
        setStatus("Select one or more recipes first.")
        return
    end

    local items = {}
    local recipeIndex
    for recipeIndex = 1, table.getn(selected) do
        local recipe = selected[recipeIndex]
        local reagentIndex
        if not self.productsOnly then
            for reagentIndex = 1, table.getn(recipe.reagents or {}) do
                local reagent = recipe.reagents[reagentIndex]
                if reagent and reagent.name and not isExcludedVial(reagent.name) then
                    items[reagent.key or normalizeKey(reagent.name)] = {
                        name = reagent.name,
                        itemId = reagent.itemId,
                        itemKind = "reagent"
                    }
                end
            end
        end

        if recipe.productName then
            items[normalizeKey(recipe.productName)] = {
                name = recipe.productName,
                itemId = recipe.productId,
                itemKind = "product"
            }
        end
    end

    chat("Scanning " .. table.getn(selected) .. " selected recipe(s).")
    self:StartScan(items, "selected")
end

function JAP:BuildAllScan()
    local sourceRecipes = nil

    if self.favoritesOnly then
        self:BuildDisplayRecipes()
        sourceRecipes = self.displayRecipes
    else
        sourceRecipes = self.recipes
    end

    if not sourceRecipes or table.getn(sourceRecipes) == 0 then
        if self.favoritesOnly then
            chat("No favorite recipes available to scan.")
            setStatus("No favorite recipes available to scan.")
        else
            chat("Open Alchemy and click 'Read Alchemy' first.")
            setStatus("No saved recipes available. Open Alchemy and click Read Alchemy.")
        end
        return
    end

    local items = {}
    local recipeIndex
    for recipeIndex = 1, table.getn(sourceRecipes) do
        local recipe = sourceRecipes[recipeIndex]

        if recipe then
            if not self.productsOnly then
                local reagentIndex
                for reagentIndex = 1, table.getn(recipe.reagents or {}) do
                    local reagent = recipe.reagents[reagentIndex]
                    if reagent and reagent.name and not isExcludedVial(reagent.name) then
                        items[reagent.key or normalizeKey(reagent.name)] = {
                            name = reagent.name,
                            itemId = reagent.itemId,
                            itemKind = "reagent"
                        }
                    end
                end
            end

            if recipe.productName then
                items[normalizeKey(recipe.productName)] = {
                    name = recipe.productName,
                    itemId = recipe.productId,
                    itemKind = "product"
                }
            end
        end
    end

    local mode = self.favoritesOnly and "favorites" or "all"
    self:StartScan(items, mode)
end

function JAP:StartScan(items, mode)
    if not AuctionFrame or not AuctionFrame:IsVisible() then
        chat("Open the Auction House first.")
        return
    end
    if self.scanRunning then
        chat("A scan is already running.")
        return
    end

    clearArray(self.scanQueue)
    local key, item
    for key, item in pairs(items) do
        -- Every requested item is always queried again.
        -- Remove its previous AH result so the table reflects only this scan's progress.
        db().prices[normalizeKey(item.name)] = nil

        table.insert(self.scanQueue, {
            name = item.name,
            key = key,
            itemId = item.itemId,
            itemKind = item.itemKind,
            page = 0,
            best = nil,
            auctions = 0
        })
    end

    table.sort(self.scanQueue, function(a, b)
        return lower(a.name) < lower(b.name)
    end)

    -- Show N/A for not-yet-refreshed targets immediately, then fill values item by item.
    self:RecalculateLiveResults()

    self.scanMode = mode
    self.scanTotal = table.getn(self.scanQueue)
    self.scanDone = 0
    self.scanRunning = true
    self.currentScan = nil
    self.pendingQuery = nil

    if self.scanTotal == 0 then
        self.scanRunning = false
        self:CalculateAllProfits()
        setStatus("No Auction House items were found for this scan.")
        chat("No Auction House items were found for this scan.")
        return
    end

    local scanScope = self.productsOnly and "crafted potion prices only" or "potions and ingredients"

    if mode == "favorites" then
        chat("Starting fresh favorites scan for " .. self.scanTotal ..
            " unique items (" .. scanScope .. ").")
        setStatus("Scanning favorite recipes: " .. scanScope .. "...")
    elseif mode == "selected" then
        chat("Starting fresh selected scan for " .. self.scanTotal ..
            " unique items (" .. scanScope .. ").")
        setStatus("Scanning selected recipes: " .. scanScope .. "...")
    else
        chat("Starting fresh all-recipes scan for " .. self.scanTotal ..
            " unique items (" .. scanScope .. ").")
        setStatus("Scanning all recipes: " .. scanScope .. "...")
    end
    setStatus("Preparing scan...")
    self:StartNextItem()
end

function JAP:StartNextItem()
    if not self.scanRunning then return end

    if table.getn(self.scanQueue) == 0 then
        self.scanRunning = false
        self.currentScan = nil
        self.pendingQuery = nil
        self:RecalculateLiveResults()
        setStatus("Scan complete: " .. self.scanDone .. "/" .. self.scanTotal .. " items.")
        chat("Auction scan complete. Scanned " .. self.scanDone .. " unique item(s).")
        return
    end

    self.currentScan = table.remove(self.scanQueue, 1)
    self.currentScan.page = 0
    self.currentScan.best = nil
    self.currentScan.auctions = 0
    self.currentScan.pages = 0
    self.currentScan.rejectedRecipes = 0

    local itemNumber = self.scanDone + 1
    local kindText = self.currentScan.itemKind == "product" and "crafted item" or "ingredient"
    chat("[" .. itemNumber .. "/" .. self.scanTotal .. "] Scanning " ..
        kindText .. ": " .. self.currentScan.name)

    self:QueueCurrentPage()
end

function JAP:QueueCurrentPage()
    if not self.currentScan then return end
    self.pendingQuery = {
        name = self.currentScan.name,
        page = self.currentScan.page
    }
    setStatus("Scanning " .. self.currentScan.name .. " (" .. (self.scanDone + 1) .. "/" .. self.scanTotal .. ")")
end

function JAP:SendPendingQuery()
    if not self.pendingQuery or not self.scanRunning then return end
    if not AuctionFrame or not AuctionFrame:IsVisible() then
        self:CancelScan("Auction House was closed.")
        return
    end

    local elapsed = now() - self.lastQueryAt
    if elapsed < self.queryDelay then return end

    local canSend = true
    if CanSendAuctionQuery then
        local queryReady = CanSendAuctionQuery()
        if queryReady == nil or queryReady == false then
            canSend = false
        end
    end
    if not canSend then return end

    local query = self.pendingQuery
    self.pendingQuery = nil
    self.lastQueryAt = now()
    QueryAuctionItems(query.name, "", "", 0, 0, 0, query.page, false)
end

function JAP:ProcessAuctionPage()
    if not self.scanRunning or not self.currentScan then return end
    if self.pendingQuery then return end

    local batchCount, totalCount = GetNumAuctionItems("list")
    batchCount = batchCount or 0
    totalCount = totalCount or 0
    self.currentScan.pages = (self.currentScan.pages or 0) + 1

    local targetKey = normalizeKey(self.currentScan.name)
    local targetId = self.currentScan.itemId
    local index

    for index = 1, batchCount do
        local name, texture, count, quality, canUse, level, minBid, minIncrement,
              buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo("list", index)

        if name and buyoutPrice and buyoutPrice > 0 and count and count > 0 then
            local link = nil
            local auctionId = nil
            local itemType = nil
            local itemSubType = nil

            if GetAuctionItemLink then
                link = GetAuctionItemLink("list", index)
                auctionId = getItemId(link)
            end

            if link and GetItemInfo then
                local ignoredName, ignoredLink, ignoredQuality, ignoredLevel,
                      ignoredMinLevel, fetchedType, fetchedSubType = GetItemInfo(link)
                itemType = fetchedType
                itemSubType = fetchedSubType
            end

            local exactName = normalizeKey(name) == targetKey
            local exactId = targetId == nil or (auctionId ~= nil and auctionId == targetId)

            -- Recipe scrolls must never be accepted as the crafted potion.
            -- Exact item ID remains the strongest check; the type check is an
            -- additional safeguard for cached, custom, or ambiguous Turtle data.
            local isRecipe = normalizeKey(itemType) == "recipe"
            local categoryAllowed = true

            if self.currentScan.itemKind == "product" and isRecipe then
                categoryAllowed = false
                self.currentScan.rejectedRecipes = self.currentScan.rejectedRecipes + 1
            end

            if exactName and exactId and categoryAllowed then
                -- Compare every auction by buyout per individual item.
                -- Keep fractional copper internally so stacks are compared exactly:
                -- 5 for 5g = 10000c each, 15 for 10g = 6666.666c each.
                local unitPrice = buyoutPrice / count
                self.currentScan.auctions = self.currentScan.auctions + 1

                if self.currentScan.best == nil or unitPrice < self.currentScan.best then
                    self.currentScan.best = unitPrice
                    self.currentScan.bestStackSize = count
                    self.currentScan.bestStackBuyout = buyoutPrice
                    self.currentScan.bestItemType = itemType
                    self.currentScan.bestItemSubType = itemSubType
                end
            end
        end
    end

    local nextPage = self.currentScan.page + 1
    if nextPage * 50 < totalCount then
        self.currentScan.page = nextPage
        self:QueueCurrentPage()
    else
        saveAuctionPrice(
            self.currentScan.name,
            self.currentScan.best,
            self.currentScan.itemId,
            self.currentScan.auctions,
            self.currentScan
        )

        local finishText = "Finished: " .. self.currentScan.name ..
            " - " .. self.currentScan.auctions .. " matching auction(s) on " ..
            self.currentScan.pages .. " page(s)"

        if self.currentScan.best ~= nil then
            finishText = finishText .. ", cheapest " ..
                moneyToText(self.currentScan.best) .. " each"
        else
            finishText = finishText .. ", no buyout found"
        end

        chat(finishText)

        -- Update every affected recipe immediately. A recipe becomes fully priced
        -- as soon as its product and all non-vial ingredients have completed.
        self:RecalculateLiveResults()

        self.scanDone = self.scanDone + 1
        self:StartNextItem()
    end
end

function JAP:CancelScan(reason)
    self.scanRunning = false
    self.currentScan = nil
    self.pendingQuery = nil
    clearArray(self.scanQueue)
    setStatus(reason or "Scan cancelled.")
    chat(reason or "Scan cancelled.")
end

function JAP:CalculateRecipe(recipe)
    local craftingCost = 0
    local missing = {}
    local details = {}
    local i

    for i = 1, table.getn(recipe.reagents) do
        local reagent = recipe.reagents[i]

        if isExcludedVial(reagent.name) then
            table.insert(details, {
                name = reagent.name,
                count = reagent.count,
                excluded = true,
                total = 0
            })
        else
            local unitPrice, source = getAnyStoredPrice(reagent.name)
            if unitPrice == nil then
                table.insert(missing, reagent.name)
            else
                local total = unitPrice * reagent.count
                craftingCost = craftingCost + total
                table.insert(details, {
                    name = reagent.name,
                    count = reagent.count,
                    unitPrice = unitPrice,
                    total = total,
                    source = source
                })
            end
        end
    end

    local productPrice = getAnyStoredPrice(recipe.productName)
    local produced = recipe.minMade or 1
    local undercut = db().settings.undercutCopper or 1
    local suggestedUnit = nil
    local suggestedCraftRevenue = nil
    local ahCut = nil
    local profit = nil
    local margin = nil

    if productPrice ~= nil then
        -- Auction buyouts use whole copper. A stack can nevertheless produce a
        -- fractional per-item value, so floor the competitor's effective unit
        -- price before undercutting it by the configured copper amount.
        suggestedUnit = math.max(1, math.floor(productPrice) - undercut)
        suggestedCraftRevenue = suggestedUnit * produced
    end

    if table.getn(missing) == 0 and suggestedCraftRevenue ~= nil then
        ahCut = suggestedCraftRevenue * ((db().settings.ahCutPercent or 5) / 100)
        profit = suggestedCraftRevenue - ahCut - craftingCost
        if craftingCost > 0 then
            margin = (profit / craftingCost) * 100
        end
    end

    recipe.result = {
        craftingCost = table.getn(missing) == 0 and craftingCost or nil,
        missing = missing,
        details = details,
        marketUnit = productPrice,
        suggestedUnit = suggestedUnit,
        produced = produced,
        revenue = suggestedCraftRevenue,
        ahCut = ahCut,
        profit = profit,
        margin = margin
    }
end

function JAP:RecalculateLiveResults()
    local i
    for i = 1, table.getn(self.recipes) do
        self:CalculateRecipe(self.recipes[i])
    end

    self:ApplySort()
    self:RefreshUI()
end

function JAP:CalculateAllProfits()
    self:RecalculateLiveResults()
    self.scrollOffset = 0
    self:RefreshUI()
end

function JAP:RefreshUI()
    if not self.frame then return end

    self:BuildDisplayRecipes()

    if self.favoriteActionButton then
        if self.selectedRecipe and self:IsFavorite(self.selectedRecipe) then
            self.favoriteActionButton:SetText("Remove Favorite")
        else
            self.favoriteActionButton:SetText("Add Favorite")
        end
    end

    if self.favoritesViewButton then
        local favoriteCount = 0
        local favoriteIndex
        for favoriteIndex = 1, table.getn(self.recipes) do
            if self:IsFavorite(self.recipes[favoriteIndex]) then
                favoriteCount = favoriteCount + 1
            end
        end

        if self.favoritesOnly then
            self.favoritesViewButton:SetText("Show All")
        else
            self.favoritesViewButton:SetText("Favorites (" .. favoriteCount .. ")")
        end
    end

    if self.scanSelectedButton then
        local selectedCount = self:GetSelectedRecipeCount()
        if selectedCount > 1 then
            self.scanSelectedButton:SetText("Scan Selected (" .. selectedCount .. ")")
        else
            self.scanSelectedButton:SetText("Scan Selected")
        end
    end

    if self.scanAllButton then
        if self.favoritesOnly then
            self.scanAllButton:SetText("Scan Favorites")
        else
            self.scanAllButton:SetText("Scan All")
        end
    end

    if self.productsOnlyCheck then
        self.productsOnlyCheck:SetChecked(self.productsOnly)
    end

    local recipeCount = table.getn(self.displayRecipes)
    local i
    for i = 1, self.visibleRows do
        local row = self.rows[i]
        local recipeIndex = i + self.scrollOffset
        local recipe = self.displayRecipes[recipeIndex]

        if recipe then
            row.recipe = recipe
            row:Show()
            if self:IsFavorite(recipe) then
                row.name:SetText("|cffffd100[F] |r" .. recipe.name)
            else
                row.name:SetText(recipe.name)
            end

            local result = recipe.result
            if result then
                row.cost:SetText(moneyToText(result.craftingCost))
                row.market:SetText(moneyToText(result.marketUnit))
                if result.profit ~= nil then
                    if result.profit >= 0 then
                        row.profit:SetText("|cff55ff55+" .. moneyToText(result.profit) .. "|r")
                    else
                        row.profit:SetText("|cffff5555" .. moneyToText(result.profit) .. "|r")
                    end
                else
                    row.profit:SetText("N/A")
                end
            else
                row.cost:SetText("-")
                row.market:SetText("-")
                row.profit:SetText("-")
            end

            if self:IsRecipeSelected(recipe) then
                row.highlight:Show()
            else
                row.highlight:Hide()
            end
        else
            row.recipe = nil
            row:Hide()
        end
    end

    if self.scrollBar then
        local maxOffset = math.max(0, recipeCount - self.visibleRows)
        if self.scrollOffset > maxOffset then
            self.scrollOffset = maxOffset
        end

        self.updatingScrollBar = true
        self.scrollBar:SetMinMaxValues(0, maxOffset)
        if self.scrollBar:GetValue() ~= self.scrollOffset then
            self.scrollBar:SetValue(self.scrollOffset)
        end
        self.updatingScrollBar = false
    end

    self:RefreshDetails()
end

function JAP:RefreshDetails()
    if not self.detailText then return end

    local recipe = self.selectedRecipe
    if not recipe then
        self.detailText:SetText("Open Alchemy and click 'Read Alchemy'.")
        return
    end

    local lines = {}
    if self:IsFavorite(recipe) then
        table.insert(lines, "|cffffd100★ " .. recipe.name .. "|r")
    else
        table.insert(lines, "|cffffd100" .. recipe.name .. "|r")
    end
    if recipe.productName and recipe.productName ~= recipe.name then
        table.insert(lines, "Crafted item: " .. recipe.productName)
    end
    if recipe.productId then
        table.insert(lines, "Item ID: " .. recipe.productId)
    end
    table.insert(lines, "Produces: " .. recipe.minMade .. (recipe.maxMade ~= recipe.minMade and ("-" .. recipe.maxMade) or ""))
    table.insert(lines, "")
    table.insert(lines, "Ingredients:")

    local result = recipe.result
    local i
    for i = 1, table.getn(recipe.reagents) do
        local reagent = recipe.reagents[i]
        local text = "  " .. reagent.count .. "x " .. reagent.name .. ": "

        if isExcludedVial(reagent.name) then
            text = text .. "|cffaaaaaaexcluded from scan and cost|r"
        else
            local price, source = getAnyStoredPrice(reagent.name)
            if price ~= nil then
                text = text .. moneyToText(price) .. " each"
                if source == "manual" then text = text .. " |cffaaaaaa(manual)|r" end
            else
                text = text .. "|cffff5555no price|r"
            end
        end

        table.insert(lines, text)
    end

    table.insert(lines, "")
    if result then
        table.insert(lines, "Craft cost: " .. moneyToText(result.craftingCost))
        table.insert(lines, "Cheapest potion: " .. moneyToText(result.marketUnit) .. " each")

        local productCache = db().prices[normalizeKey(recipe.productName)]
        if productCache then
            if productCache.bestStackSize and productCache.bestStackBuyout then
                table.insert(lines,
                    "Best listing: " .. productCache.bestStackSize .. " for " ..
                    moneyToText(productCache.bestStackBuyout))
            end
            table.insert(lines,
                "Checked: " .. (productCache.auctions or 0) ..
                " matching auctions on " .. (productCache.pages or 0) .. " page(s)")
            if (productCache.rejectedRecipes or 0) > 0 then
                table.insert(lines,
                    "Ignored recipe items: " .. productCache.rejectedRecipes)
            end
        end

        table.insert(lines, "Suggested price: " .. moneyToText(result.suggestedUnit) .. " each")
        table.insert(lines, "AH cut (" .. db().settings.ahCutPercent .. "%): " .. moneyToText(result.ahCut))
        table.insert(lines, "Expected profit: " .. moneyToText(result.profit))
        if result.margin then
            table.insert(lines, string.format("Margin: %.1f%%", result.margin))
        end
        if table.getn(result.missing) > 0 then
            table.insert(lines, "")
            table.insert(lines, "|cffff5555Missing prices:|r " .. table.concat(result.missing, ", "))
        end
    else
        table.insert(lines, "Not calculated yet.")
    end

    self.detailText:SetText(table.concat(lines, "\n"))
end

function JAP:CreateButton(parent, text, width, x, y, handler)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetWidth(width)
    button:SetHeight(24)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetText(text)
    button:SetScript("OnClick", handler)
    return button
end

function JAP:CreateUI()
    self.sortMode = db().settings.sortMode or "alphabetical"
    self.favoritesOnly = db().settings.favoritesOnly == true
    self.productsOnly = db().settings.productsOnly == true
    local frame = CreateFrame("Frame", "JochensAlchemyProfitsFrame", UIParent)
    self.frame = frame
    frame:SetWidth(760)
    frame:SetHeight(550)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnShow", function()
        this:SetFrameStrata("DIALOG")
        this:Raise()
    end)
    frame:SetScript("OnDragStart", function()
        this:Raise()
        this:StartMoving()
    end)
    frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    frame:Hide()

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -18)
    title:SetText("JochensAlchemyProfits")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    -- Main action row.
    self:CreateButton(frame, "Read Alchemy", 120, 20, -48, function() JAP:ReadAlchemy() end)
    local scanSelectedButton = self:CreateButton(frame, "Scan Selected", 140, 155, -48, function()
        JAP:BuildSelectedScan()
    end)
    self.scanSelectedButton = scanSelectedButton

    local scanAllButton = self:CreateButton(frame, "Scan All", 130, 300, -48, function()
        JAP:BuildAllScan()
    end)
    self.scanAllButton = scanAllButton

    self:CreateButton(frame, "Cancel", 90, 445, -48, function()
        JAP:CancelScan("Scan cancelled.")
    end)

    -- Secondary row: favorites on the left, sorting and maintenance on the right.
    local favoriteActionButton = self:CreateButton(frame, "Add Favorite", 130, 20, -82, function()
        JAP:ToggleFavorite(JAP.selectedRecipe)
    end)
    self.favoriteActionButton = favoriteActionButton

    local favoritesViewButton = self:CreateButton(frame, "Show Favorites", 130, 165, -82, function()
        JAP:SetFavoritesOnly(not JAP.favoritesOnly)
    end)
    self.favoritesViewButton = favoritesViewButton

    local productsOnlyCheck = CreateFrame(
        "CheckButton",
        "JAPProductsOnlyCheck",
        frame,
        "UICheckButtonTemplate"
    )
    self.productsOnlyCheck = productsOnlyCheck
    productsOnlyCheck:SetWidth(24)
    productsOnlyCheck:SetHeight(24)
    productsOnlyCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 305, -80)
    productsOnlyCheck:SetChecked(self.productsOnly)
    productsOnlyCheck:SetScript("OnClick", function()
        JAP:SetProductsOnly(this:GetChecked() == 1)
    end)

    local productsOnlyLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    productsOnlyLabel:SetPoint("LEFT", productsOnlyCheck, "RIGHT", 2, 0)
    productsOnlyLabel:SetText("Potion prices only")

    local sortLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sortLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 485, -88)
    sortLabel:SetText("Sort by")

    local sortDropDown = CreateFrame("Frame", "JAPSortDropDown", frame, "UIDropDownMenuTemplate")
    self.sortDropDown = sortDropDown
    sortDropDown:SetPoint("TOPLEFT", frame, "TOPLEFT", 530, -74)
    UIDropDownMenu_SetWidth(110, sortDropDown)

    local clearRecipesButton = self:CreateButton(frame, "Clear Recipes", 100, 630, -48, function()
        JAP:ClearSavedRecipes()
    end)
    self.clearRecipesButton = clearRecipesButton

    UIDropDownMenu_Initialize(sortDropDown, function()
        local info = {}
        info.text = "Alphabetical"
        info.value = "alphabetical"
        info.func = function() JAP:SetSortMode("alphabetical"); UIDropDownMenu_SetSelectedValue(JAPSortDropDown, "alphabetical") end
        info.checked = JAP.sortMode == "alphabetical"
        UIDropDownMenu_AddButton(info)

        info = {}
        info.text = "Profit"
        info.value = "profit"
        info.func = function() JAP:SetSortMode("profit"); UIDropDownMenu_SetSelectedValue(JAPSortDropDown, "profit") end
        info.checked = JAP.sortMode == "profit"
        UIDropDownMenu_AddButton(info)
    end)
    if self.sortMode == "skill" then
        self.sortMode = "alphabetical"
        db().settings.sortMode = "alphabetical"
    end
    UIDropDownMenu_SetSelectedValue(sortDropDown, self.sortMode)

    local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.statusText = status
    status:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -118)
    status:SetWidth(710)
    status:SetJustifyH("LEFT")
    status:SetText("Open Alchemy, read recipes, then open the Auction House.")

    local headers = {"Recipe", "Craft cost", "Lowest price", "Profit"}
    local positions = {24, 245, 345, 445}
    local h
    for h = 1, 4 do
        local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", frame, "TOPLEFT", positions[h], -144)
        header:SetText(headers[h])
    end

    local rowIndex
    for rowIndex = 1, self.visibleRows do
        local row = CreateFrame("Button", nil, frame)
        row:SetWidth(505)
        row:SetHeight(25)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -161 - ((rowIndex - 1) * 27))

        row.highlight = row:CreateTexture(nil, "BACKGROUND")
        row.highlight:SetAllPoints(row)
        row.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row.highlight:SetBlendMode("ADD")
        row.highlight:Hide()

        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.name:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.name:SetWidth(215)
        row.name:SetJustifyH("LEFT")

        row.cost = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.cost:SetPoint("LEFT", row, "LEFT", 225, 0)
        row.cost:SetWidth(98)
        row.cost:SetJustifyH("LEFT")

        row.market = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.market:SetPoint("LEFT", row, "LEFT", 325, 0)
        row.market:SetWidth(98)
        row.market:SetJustifyH("LEFT")

        row.profit = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.profit:SetPoint("LEFT", row, "LEFT", 425, 0)
        row.profit:SetWidth(92)
        row.profit:SetJustifyH("LEFT")

        row:SetScript("OnClick", function()
            if this.recipe then
                local additive = false
                if IsControlKeyDown and IsControlKeyDown() then additive = true end
                if IsShiftKeyDown and IsShiftKeyDown() then additive = true end
                JAP:SelectRecipe(this.recipe, additive)
            end
        end)
        row:SetScript("OnEnter", function()
            if this.recipe then
                this.highlight:Show()
            end
        end)
        row:SetScript("OnLeave", function()
            if not JAP:IsRecipeSelected(this.recipe) then
                this.highlight:Hide()
            end
        end)

        self.rows[rowIndex] = row
    end

    local scroll = CreateFrame("Slider", nil, frame, "UIPanelScrollBarTemplate")
    self.scrollBar = scroll
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 526, -164)
    scroll:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 526, 55)

    -- Replace the template handler before SetValue is called.
    -- The default Vanilla handler expects a real ScrollFrame parent and otherwise
    -- tries to call SetVerticalScroll on the JAP frame.
    scroll:SetScript("OnValueChanged", function()
        if JAP.updatingScrollBar then return end

        local newOffset = math.floor(this:GetValue() + 0.5)
        if newOffset ~= JAP.scrollOffset then
            JAP.scrollOffset = newOffset
            JAP:RefreshUI()
        end
    end)

    scroll:SetMinMaxValues(0, 0)
    scroll:SetValueStep(1)
    scroll:SetValue(0)

    local detailBox = CreateFrame("Frame", nil, frame)
    detailBox:SetWidth(200)
    detailBox:SetHeight(350)
    detailBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -22, -148)
    detailBox:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    detailBox:SetBackdropColor(0, 0, 0, 0.75)

    local detail = detailBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.detailText = detail
    detail:SetPoint("TOPLEFT", detailBox, "TOPLEFT", 10, -10)
    detail:SetWidth(180)
    detail:SetJustifyH("LEFT")
    detail:SetJustifyV("TOP")
    detail:SetText("No recipe selected.")

    local help = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    help:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 22, 20)
    help:SetWidth(710)
    help:SetJustifyH("LEFT")
    help:SetText("Click = single select  |  Ctrl/Shift-click = multi-select  |  Scan Selected scans all marked")

    self:RefreshUI()
end

function JAP:Toggle()
    if not self.frame then self:CreateUI() end
    if self.frame:IsVisible() then
        self.frame:Hide()
    else
        self.frame:Show()
        self.frame:SetFrameStrata("DIALOG")
        self.frame:Raise()
        self:RefreshUI()
    end
end

function JAP:HandleSlash(message)
    message = trim(message)
    if message == "" or lower(message) == "show" then
        self:Toggle()
        return
    end

    if lower(message) == "read" then
        self:ReadAlchemy()
        return
    end

    if lower(message) == "clearrecipes" then
        self:ClearSavedRecipes()
        return
    end

    if lower(message) == "scan" then
        self:BuildSelectedScan()
        return
    end

    if lower(message) == "scanall" then
        self:BuildAllScan()
        return
    end

    local _, _, priceName, priceText = string.find(message, "^setprice%s+(.+)%s*=%s*(.+)$")
    if priceName and priceText then
        priceName = trim(priceName)
        local copper = parseMoney(priceText)
        if copper then
            db().manualPrices[normalizeKey(priceName)] = copper
            chat("Manual price set: " .. priceName .. " = " .. moneyToText(copper) .. " each.")
            self:CalculateAllProfits()
        else
            chat("Invalid price. Example: /jap setprice Crystal Vial = 5s")
        end
        return
    end

    local _, _, clearName = string.find(message, "^clearprice%s+(.+)$")
    if clearName then
        clearName = trim(clearName)
        db().manualPrices[normalizeKey(clearName)] = nil
        chat("Manual price cleared: " .. clearName)
        self:CalculateAllProfits()
        return
    end

    local _, _, skillName, skillText = string.find(message, "^setskill%s+(.+)%s*=%s*(%d+)$")
    if skillName and skillText then
        skillName = trim(skillName)
        db().manualSkills[normalizeKey(skillName)] = tonumber(skillText)
        local recipe = self.recipeByName[normalizeKey(skillName)]
        if recipe then
            recipe.requiredSkill = tonumber(skillText)
            recipe.requiredSkillSource = "manual"
        end
        chat("Required skill set: " .. skillName .. " = " .. skillText .. ".")
        self:ApplySort()
        self:RefreshUI()
        return
    end

    local _, _, clearSkillName = string.find(message, "^clearskill%s+(.+)$")
    if clearSkillName then
        clearSkillName = trim(clearSkillName)
        db().manualSkills[normalizeKey(clearSkillName)] = nil
        chat("Manual skill cleared: " .. clearSkillName .. ". Re-read Alchemy to retry automatic detection.")
        return
    end

    if lower(message) == "favorites" then
        self:SetFavoritesOnly(not self.favoritesOnly)
        return
    end

    if lower(message) == "productsonly" then
        self:SetProductsOnly(not self.productsOnly)
        return
    end

    if lower(message) == "debugitem" then
        if self.selectedRecipe then
            chat("Recipe: " .. tostring(self.selectedRecipe.name))
            chat("Crafted item: " .. tostring(self.selectedRecipe.productName))
            chat("Item ID: " .. tostring(self.selectedRecipe.productId))
            chat("Item link: " .. tostring(self.selectedRecipe.productLink))
        else
            chat("No recipe selected.")
        end
        return
    end

    local _, _, cutText = string.find(message, "^cut%s+(%d+)$")
    if cutText then
        db().settings.ahCutPercent = tonumber(cutText)
        chat("Auction House cut set to " .. cutText .. "%.")
        self:CalculateAllProfits()
        return
    end

    chat("Commands: /jap, /jap read, /jap clearrecipes, /jap scan, /jap scanall")
    chat("/jap scanall scans all recipes, or only favorites while the favorites view is active.")
    chat("/jap setprice Item Name = 1g 20s")
    chat("/jap clearprice Item Name, /jap cut 5")
    chat("/jap favorites, /jap productsonly")
    chat("/jap setskill Recipe Name = 275, /jap clearskill Recipe Name")
    chat("/jap debugitem shows the exact crafted item used for the selected recipe.")
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
eventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
eventFrame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
eventFrame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        db()
        JAP:CreateUI()
        if JAP:LoadSavedRecipes() then
            setStatus("Loaded " .. table.getn(JAP.recipes) .. " saved recipes.")
            chat("Loaded v" .. JAP.version .. " with " .. table.getn(JAP.recipes) .. " saved recipes. Type /jap to open.")
        else
            chat("Loaded v" .. JAP.version .. ". Open Alchemy and click Read Alchemy.")
        end
    elseif event == "TRADE_SKILL_SHOW" then
        -- Deliberately do not auto-read: the player may have opened another profession.
    elseif event == "TRADE_SKILL_UPDATE" then
        -- Recipe indices can change while filters/headers change; explicit re-read is safer.
    elseif event == "AUCTION_ITEM_LIST_UPDATE" then
        JAP:ProcessAuctionPage()
    elseif event == "AUCTION_HOUSE_CLOSED" then
        if JAP.scanRunning then
            JAP:CancelScan("Auction House was closed.")
        end
    end
end)

eventFrame:SetScript("OnUpdate", function()
    JAP:SendPendingQuery()
end)

SLASH_JOCHENSALCHEMYPROFITS1 = "/jap"
SLASH_JOCHENSALCHEMYPROFITS2 = "/jochenalchemy"
SlashCmdList["JOCHENSALCHEMYPROFITS"] = function(message)
    JAP:HandleSlash(message)
end
