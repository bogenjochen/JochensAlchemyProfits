-- JochensAlchemyProfits
-- Turtle WoW / Vanilla 1.12.1 (Interface 11200)
-- No external libraries required.

JAP = {}
JAP.version = "0.10.9"
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
JAP.materials = {}
JAP.currentPage = "recipes"
JAP.materialFavoritesOnly = false
JAP.selectedMaterial = nil
JAP.selectedMaterials = {}

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
    if not JochensAlchemyProfitsDB.materialFavorites then
        JochensAlchemyProfitsDB.materialFavorites = {}
    end
    if not JochensAlchemyProfitsDB.materialHistory then
        JochensAlchemyProfitsDB.materialHistory = {}
    end
    if not JochensAlchemyProfitsDB.productHistory then
        JochensAlchemyProfitsDB.productHistory = {}
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
    if JochensAlchemyProfitsDB.settings.materialFavoritesOnly == nil then
        JochensAlchemyProfitsDB.settings.materialFavoritesOnly = false
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


local function updateMaterialHistory(name, currentPrice)
    if not name or not currentPrice or currentPrice <= 0 then
        return
    end

    local key = normalizeKey(name)
    local historyDb = db().materialHistory
    local history = historyDb[key]

    if not history then
        history = {
            name = name,
            referencePrice = currentPrice,
            lastPrice = currentPrice,
            lastIndex = 100,
            samples = 1,
            firstSeen = time(),
            lastSeen = time()
        }
        historyDb[key] = history
        return
    end

    local reference = history.referencePrice or currentPrice
    if reference <= 0 then reference = currentPrice end

    -- Display the current price relative to the historical reference.
    history.lastIndex = (currentPrice / reference) * 100
    history.lastPrice = currentPrice
    history.samples = (history.samples or 0) + 1
    history.lastSeen = time()

    -- Adaptive reference:
    -- move 10% toward each new observation so sustained price changes gradually
    -- become the new normal, while short spikes still remain visible.
    local alpha = 0.10
    history.referencePrice = reference + ((currentPrice - reference) * alpha)
end

local function getMaterialHistory(name)
    if not name then return nil end
    return db().materialHistory[normalizeKey(name)]
end

local function materialIndexText(name)
    local history = getMaterialHistory(name)
    if not history or not history.lastIndex then
        return "-"
    end

    local index = history.lastIndex
    local text = string.format("%.0f%%", index)

    if index < 97 then
        return "|cff55ff55" .. text .. "|r"
    elseif index > 103 then
        return "|cffff5555" .. text .. "|r"
    end

    return "|cffffff66" .. text .. "|r"
end

local function updateProductHistory(name, currentPrice)
    if not name or not currentPrice or currentPrice <= 0 then
        return
    end

    local key = normalizeKey(name)
    local historyDb = db().productHistory
    local history = historyDb[key]

    if not history then
        history = {
            name = name,
            referencePrice = currentPrice,
            lastPrice = currentPrice,
            lastIndex = 100,
            samples = 1,
            firstSeen = time(),
            lastSeen = time()
        }
        historyDb[key] = history
        return
    end

    local reference = history.referencePrice or currentPrice
    if reference <= 0 then reference = currentPrice end

    history.lastIndex = (currentPrice / reference) * 100
    history.lastPrice = currentPrice
    history.samples = (history.samples or 0) + 1
    history.lastSeen = time()

    local alpha = 0.10
    history.referencePrice = reference + ((currentPrice - reference) * alpha)
end

local function getProductHistory(name)
    if not name then return nil end
    return db().productHistory[normalizeKey(name)]
end

local function productIndexText(name)
    local history = getProductHistory(name)
    if not history or not history.lastIndex then
        return nil
    end

    local index = history.lastIndex
    local text = string.format("%.0f%%", index)

    if index < 97 then
        return "|cff55ff55" .. text .. "|r"
    elseif index > 103 then
        return "|cffff5555" .. text .. "|r"
    end

    return "|cffffff66" .. text .. "|r"
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


function JAP:BuildSelectedMaterialScan()
    self:BuildMaterialsList()
    local selected = self:GetSelectedMaterials()

    if table.getn(selected) == 0 then
        chat("Select one or more materials first.")
        setStatus("Select one or more materials first.")
        return
    end

    local items = {}
    local materialIndex
    for materialIndex = 1, table.getn(selected) do
        local material = selected[materialIndex]
        items[material.key] = {
            name = material.name,
            itemId = material.itemId,
            itemKind = "reagent"
        }
    end

    chat("Scanning " .. table.getn(selected) .. " selected material(s).")
    self:StartScan(items, "materials-selected")
end

function JAP:BuildAllMaterialScan()
    self:BuildMaterialsList()

    if table.getn(self.materials) == 0 then
        if self.materialFavoritesOnly then
            chat("No favorite materials available to scan.")
            setStatus("No favorite materials available to scan.")
        else
            chat("No materials available. Read your Alchemy recipes first.")
            setStatus("No materials available. Read your Alchemy recipes first.")
        end
        return
    end

    local items = {}
    local materialIndex
    for materialIndex = 1, table.getn(self.materials) do
        local material = self.materials[materialIndex]
        items[material.key] = {
            name = material.name,
            itemId = material.itemId,
            itemKind = "reagent"
        }
    end

    local mode = self.materialFavoritesOnly
        and "materials-favorites"
        or "materials-all"

    self:StartScan(items, mode)
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

    if mode == "materials-selected" then
        chat("Starting fresh scan for " .. self.scanTotal .. " selected material(s).")
        setStatus("Scanning selected materials...")
    elseif mode == "materials-favorites" then
        chat("Starting fresh scan for " .. self.scanTotal .. " favorite material(s).")
        setStatus("Scanning favorite materials...")
    elseif mode == "materials-all" then
        chat("Starting fresh scan for all " .. self.scanTotal .. " material(s).")
        setStatus("Scanning all materials...")
    elseif mode == "favorites" then
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

        if self.currentScan.itemKind == "reagent" and self.currentScan.best ~= nil then
            updateMaterialHistory(self.currentScan.name, self.currentScan.best)
        elseif self.currentScan.itemKind == "product" and self.currentScan.best ~= nil then
            updateProductHistory(self.currentScan.name, self.currentScan.best)
        end

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

    if self.currentPage == "materials" then
        self:BuildMaterialsList()

        if self.recipesTabButton then self.recipesTabButton:UnlockHighlight() end
        if self.materialsTabButton then self.materialsTabButton:LockHighlight() end

        local controls = self.recipeControls or {}
        local controlIndex
        for controlIndex = 1, table.getn(controls) do
            controls[controlIndex]:Hide()
        end

        local materialControls = self.materialControls or {}
        for controlIndex = 1, table.getn(materialControls) do
            materialControls[controlIndex]:Show()
        end

        if self.materialFavoriteActionButton then
            local selected = self:GetSelectedMaterials()
            local allFavorite = table.getn(selected) > 0
            local selectedIndex
            for selectedIndex = 1, table.getn(selected) do
                if not self:IsMaterialFavorite(selected[selectedIndex]) then
                    allFavorite = false
                    break
                end
            end

            if allFavorite then
                self.materialFavoriteActionButton:SetText("Remove Favorite")
            else
                self.materialFavoriteActionButton:SetText("Add Favorite")
            end
        end

        if self.materialScanSelectedButton then
            local selectedCount = table.getn(self:GetSelectedMaterials())
            if selectedCount > 1 then
                self.materialScanSelectedButton:SetText(
                    "Scan Selected (" .. selectedCount .. ")"
                )
            else
                self.materialScanSelectedButton:SetText("Scan Selected")
            end
        end

        if self.materialScanAllButton then
            if self.materialFavoritesOnly then
                self.materialScanAllButton:SetText("Scan Favorites")
            else
                self.materialScanAllButton:SetText("Scan All")
            end
        end

        if self.materialFavoritesViewButton then
            local favoriteCount = 0
            local favoriteKey, favoriteValue
            for favoriteKey, favoriteValue in pairs(db().materialFavorites) do
                if favoriteValue then favoriteCount = favoriteCount + 1 end
            end

            if self.materialFavoritesOnly then
                self.materialFavoritesViewButton:SetText("Show All")
            else
                self.materialFavoritesViewButton:SetText("Favorites (" .. favoriteCount .. ")")
            end
        end

        if self.columnHeaders then
            self.columnHeaders[1]:SetText("Material")
            self.columnHeaders[2]:SetText("Used by")
            self.columnHeaders[3]:SetText("Lowest price")
            self.columnHeaders[4]:SetText("History")
        end

        local materialCount = table.getn(self.materials)
        local i
        for i = 1, self.visibleRows do
            local row = self.rows[i]
            local material = self.materials[i + self.scrollOffset]

            if material then
                row.recipe = nil
                row.material = material
                row:Show()

                if self:IsMaterialFavorite(material) then
                    row.name:SetText("|cffffd100[F] |r" .. material.name)
                else
                    row.name:SetText(material.name)
                end

                row.cost:SetText(tostring(material.usedBy) .. " recipe(s)")

                local materialPrice = getAnyStoredPrice(material.name)
                row.market:SetText(moneyToText(materialPrice))
                row.profit:SetText(materialIndexText(material.name))

                if self:IsMaterialSelected(material) then
                    row.highlight:Show()
                else
                    row.highlight:Hide()
                end
            else
                row.recipe = nil
                row.material = nil
                row:Hide()
            end
        end

        if self.scrollBar then
            local maxOffset = math.max(0, materialCount - self.visibleRows)
            if self.scrollOffset > maxOffset then self.scrollOffset = maxOffset end

            self.updatingScrollBar = true
            self.scrollBar:SetMinMaxValues(0, maxOffset)
            self.scrollBar:SetValue(self.scrollOffset)
            self.updatingScrollBar = false
        end

        if self.detailText then
            local selected = self:GetSelectedMaterials()

            if table.getn(selected) == 1 then
                local material = selected[1]
                local favoriteText = self:IsMaterialFavorite(material)
                    and "Yes" or "No"

                local recipeLines = {}
                local recipeIndex
                for recipeIndex = 1, table.getn(material.recipes or {}) do
                    table.insert(recipeLines, "  - " .. material.recipes[recipeIndex])
                end

                local materialPrice = getAnyStoredPrice(material.name)
                local priceText = moneyToText(materialPrice)
                local priceEntry = db().prices[normalizeKey(material.name)]
                local history = getMaterialHistory(material.name)

                local historyText = "No historical data yet"
                if history then
                    historyText =
                        string.format("%.0f%%", history.lastIndex or 100) ..
                        " of adaptive reference\n" ..
                        "Reference: " .. moneyToText(history.referencePrice) .. "\n" ..
                        "Samples: " .. (history.samples or 1)
                end

                local scanText = ""
                if priceEntry then
                    scanText =
                        "\nChecked: " .. (priceEntry.auctions or 0) ..
                        " matching auction(s) on " ..
                        (priceEntry.pages or 0) .. " page(s)"
                end

                self.detailText:SetText(
                    "|cffffd100" .. material.name .. "|r\n\n" ..
                    "Lowest unit price: " .. priceText .. scanText .. "\n" ..
                    "Historical index: " .. historyText .. "\n" ..
                    "Used by: " .. material.usedBy .. " recipe(s)\n" ..
                    "Favorite: " .. favoriteText .. "\n\n" ..
                    "|cffffd100Used in recipes:|r\n" ..
                    table.concat(recipeLines, "\n")
                )
            elseif table.getn(selected) > 1 then
                self.detailText:SetText(
                    "|cffffd100" .. table.getn(selected) .. " materials selected|r\n\n" ..
                    "Use Ctrl-click or Shift-click to add or remove materials."
                )
            else
                self.detailText:SetText(
                    "|cffffd100Materials|r\n\n" ..
                    "No materials are available in this view."
                )
            end
        end

        if self.materialFavoritesOnly then
            setStatus("Showing " .. materialCount .. " favorite materials.")
        else
            setStatus("Showing " .. materialCount .. " unique materials.")
        end
        return
    end

    if self.recipesTabButton then self.recipesTabButton:LockHighlight() end
    if self.materialsTabButton then self.materialsTabButton:UnlockHighlight() end

    local controls = self.recipeControls or {}
    local controlIndex
    for controlIndex = 1, table.getn(controls) do
        controls[controlIndex]:Show()
    end

    local materialControls = self.materialControls or {}
    for controlIndex = 1, table.getn(materialControls) do
        materialControls[controlIndex]:Hide()
    end

    if self.columnHeaders then
        self.columnHeaders[1]:SetText("Recipe")
        self.columnHeaders[2]:SetText("Craft cost")
        self.columnHeaders[3]:SetText("Lowest price")
        self.columnHeaders[4]:SetText("Profit")
    end

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
                local marketText = moneyToText(result.marketUnit)
                local historyText = productIndexText(recipe.productName)
                if historyText then
                    marketText = marketText .. " (" .. historyText .. ")"
                end
                row.market:SetText(marketText)

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

        local productHistory = getProductHistory(recipe.productName)
        if productHistory then
            table.insert(lines,
                "Historical price: " ..
                string.format("%.0f%%", productHistory.lastIndex or 100) ..
                " of adaptive reference")
            table.insert(lines,
                "Reference price: " ..
                moneyToText(productHistory.referencePrice))
            table.insert(lines,
                "Price samples: " .. (productHistory.samples or 1))
        end

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




function JAP:IsMaterialSelected(material)
    if not material then return false end
    return self.selectedMaterials[material.key] == true
end

function JAP:GetSelectedMaterials()
    local selected = {}
    local materialIndex
    for materialIndex = 1, table.getn(self.materials) do
        local material = self.materials[materialIndex]
        if self:IsMaterialSelected(material) then
            table.insert(selected, material)
        end
    end
    return selected
end

function JAP:SelectMaterial(material, additive)
    if not material then return end

    if not additive then
        self.selectedMaterials = {}
        self.selectedMaterials[material.key] = true
    else
        if self.selectedMaterials[material.key] then
            self.selectedMaterials[material.key] = nil
        else
            self.selectedMaterials[material.key] = true
        end
    end

    local selected = self:GetSelectedMaterials()
    self.selectedMaterial = selected[1]
    self:RefreshUI()
end

function JAP:IsMaterialFavorite(material)
    if not material then return false end
    return db().materialFavorites[material.key] == true
end

function JAP:ToggleMaterialFavorite(material)
    local selected = self:GetSelectedMaterials()
    if table.getn(selected) == 0 and material then
        table.insert(selected, material)
    end

    if table.getn(selected) == 0 then
        chat("Select one or more materials first.")
        return
    end

    local shouldFavorite = false
    local selectedIndex
    for selectedIndex = 1, table.getn(selected) do
        if not self:IsMaterialFavorite(selected[selectedIndex]) then
            shouldFavorite = true
            break
        end
    end

    local database = db()
    for selectedIndex = 1, table.getn(selected) do
        local selectedMaterial = selected[selectedIndex]
        if shouldFavorite then
            database.materialFavorites[selectedMaterial.key] = true
        else
            database.materialFavorites[selectedMaterial.key] = nil
        end
    end

    if shouldFavorite then
        chat(table.getn(selected) .. " material(s) added to favorites and saved.")
    else
        chat(table.getn(selected) .. " material(s) removed from favorites and saved.")
    end

    if self.materialFavoritesOnly then
        self.selectedMaterials = {}
        self.selectedMaterial = nil
    end

    self:RefreshUI()
end

function JAP:SetMaterialFavoritesOnly(enabled)
    self.materialFavoritesOnly = enabled and true or false
    db().settings.materialFavoritesOnly = self.materialFavoritesOnly
    self.scrollOffset = 0
    self.selectedMaterial = nil
    self.selectedMaterials = {}
    self:RefreshUI()
end

function JAP:BuildMaterialsList()
    clearArray(self.materials)

    local unique = {}
    local recipeIndex
    for recipeIndex = 1, table.getn(self.recipes) do
        local recipe = self.recipes[recipeIndex]

        if recipe and recipe.reagents then
            local reagentIndex
            for reagentIndex = 1, table.getn(recipe.reagents) do
                local reagent = recipe.reagents[reagentIndex]

                if reagent and reagent.name and not isExcludedVial(reagent.name) then
                    local key = reagent.key or normalizeKey(reagent.name)

                    if not unique[key] then
                        unique[key] = {
                            name = reagent.name,
                            key = key,
                            itemId = reagent.itemId,
                            link = reagent.link,
                            usedBy = 0,
                            recipes = {}
                        }
                    end

                    unique[key].usedBy = unique[key].usedBy + 1
                    table.insert(unique[key].recipes, recipe.name)
                end
            end
        end
    end

    local key, material
    for key, material in pairs(unique) do
        if not self.materialFavoritesOnly or self:IsMaterialFavorite(material) then
            table.insert(self.materials, material)
        end
    end

    table.sort(self.materials, function(a, b)
        return lower(a.name) < lower(b.name)
    end)

    local visibleSelection = {}
    local materialIndex
    for materialIndex = 1, table.getn(self.materials) do
        local material = self.materials[materialIndex]
        if self.selectedMaterials[material.key] then
            visibleSelection[material.key] = true
        end
    end
    self.selectedMaterials = visibleSelection

    local selected = self:GetSelectedMaterials()
    self.selectedMaterial = selected[1]

    if not self.selectedMaterial and table.getn(self.materials) > 0 then
        self.selectedMaterial = self.materials[1]
        self.selectedMaterials[self.selectedMaterial.key] = true
    end
end

function JAP:SetPage(page)
    if page ~= "recipes" and page ~= "materials" then return end
    self.currentPage = page
    self.scrollOffset = 0
    self:RefreshUI()
end


function JAP:HandleMouseWheel(delta)
    if not self.scrollBar or not delta then return end

    local minValue, maxValue = self.scrollBar:GetMinMaxValues()
    local currentValue = self.scrollBar:GetValue() or 0
    local newValue = currentValue - (delta * 3)

    if newValue < minValue then newValue = minValue end
    if newValue > maxValue then newValue = maxValue end

    self.scrollBar:SetValue(newValue)
end

function JAP:CreateUI()
    self.sortMode = db().settings.sortMode or "alphabetical"
    self.favoritesOnly = db().settings.favoritesOnly == true
    self.productsOnly = db().settings.productsOnly == true
    self.currentPage = "recipes"
    self.materialFavoritesOnly = db().settings.materialFavoritesOnly == true
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
    frame:EnableMouseWheel(1)
    frame:SetScript("OnMouseWheel", function()
        JAP:HandleMouseWheel(arg1)
    end)
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

    -- Allow the standard Escape key to close the addon window.
    local specialFrameExists = false
    local specialIndex
    for specialIndex = 1, table.getn(UISpecialFrames) do
        if UISpecialFrames[specialIndex] == "JochensAlchemyProfitsFrame" then
            specialFrameExists = true
            break
        end
    end
    if not specialFrameExists then
        table.insert(UISpecialFrames, "JochensAlchemyProfitsFrame")
    end

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -18)
    title:SetText("JochensAlchemyProfits")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    local recipesTabButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    self.recipesTabButton = recipesTabButton
    recipesTabButton:SetWidth(100)
    recipesTabButton:SetHeight(22)
    recipesTabButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -42)
    recipesTabButton:SetText("Recipes")
    recipesTabButton:SetScript("OnClick", function() JAP:SetPage("recipes") end)

    local materialsTabButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    self.materialsTabButton = materialsTabButton
    materialsTabButton:SetWidth(100)
    materialsTabButton:SetHeight(22)
    materialsTabButton:SetPoint("LEFT", recipesTabButton, "RIGHT", 8, 0)
    materialsTabButton:SetText("Materials")
    materialsTabButton:SetScript("OnClick", function() JAP:SetPage("materials") end)

    self.recipeControls = {}
    self.materialControls = {}

    local materialScanSelectedButton = self:CreateButton(
        frame,
        "Scan Selected",
        140,
        20,
        -76,
        function()
            JAP:BuildSelectedMaterialScan()
        end
    )
    self.materialScanSelectedButton = materialScanSelectedButton
    table.insert(self.materialControls, materialScanSelectedButton)
    materialScanSelectedButton:Hide()

    local materialScanAllButton = self:CreateButton(
        frame,
        "Scan All",
        130,
        175,
        -76,
        function()
            JAP:BuildAllMaterialScan()
        end
    )
    self.materialScanAllButton = materialScanAllButton
    table.insert(self.materialControls, materialScanAllButton)
    materialScanAllButton:Hide()

    local materialCancelButton = self:CreateButton(
        frame,
        "Cancel",
        90,
        320,
        -76,
        function()
            JAP:CancelScan("Scan cancelled.")
        end
    )
    table.insert(self.materialControls, materialCancelButton)
    materialCancelButton:Hide()

    local materialFavoriteActionButton = self:CreateButton(
        frame,
        "Add Favorite",
        130,
        20,
        -110,
        function()
            JAP:ToggleMaterialFavorite(JAP.selectedMaterial)
        end
    )
    self.materialFavoriteActionButton = materialFavoriteActionButton
    table.insert(self.materialControls, materialFavoriteActionButton)
    materialFavoriteActionButton:Hide()

    local materialFavoritesViewButton = self:CreateButton(
        frame,
        "Show Favorites",
        130,
        165,
        -110,
        function()
            JAP:SetMaterialFavoritesOnly(not JAP.materialFavoritesOnly)
        end
    )
    self.materialFavoritesViewButton = materialFavoritesViewButton
    table.insert(self.materialControls, materialFavoritesViewButton)
    materialFavoritesViewButton:Hide()

    -- Main action row.
    local readAlchemyButton = self:CreateButton(frame, "Read Alchemy", 120, 20, -76, function() JAP:ReadAlchemy() end)
    table.insert(self.recipeControls, readAlchemyButton)
    local scanSelectedButton = self:CreateButton(frame, "Scan Selected", 140, 155, -76, function()
        JAP:BuildSelectedScan()
    end)
    self.scanSelectedButton = scanSelectedButton
    table.insert(self.recipeControls, scanSelectedButton)

    local scanAllButton = self:CreateButton(frame, "Scan All", 130, 300, -76, function()
        JAP:BuildAllScan()
    end)
    self.scanAllButton = scanAllButton
    table.insert(self.recipeControls, scanAllButton)

    local cancelButton = self:CreateButton(frame, "Cancel", 90, 445, -76, function()
        JAP:CancelScan("Scan cancelled.")
    end)
    table.insert(self.recipeControls, cancelButton)

    -- Secondary row: favorites on the left, sorting and maintenance on the right.
    local favoriteActionButton = self:CreateButton(frame, "Add Favorite", 130, 20, -110, function()
        JAP:ToggleFavorite(JAP.selectedRecipe)
    end)
    self.favoriteActionButton = favoriteActionButton
    table.insert(self.recipeControls, favoriteActionButton)

    local favoritesViewButton = self:CreateButton(frame, "Show Favorites", 130, 165, -110, function()
        JAP:SetFavoritesOnly(not JAP.favoritesOnly)
    end)
    self.favoritesViewButton = favoritesViewButton
    table.insert(self.recipeControls, favoritesViewButton)

    local productsOnlyCheck = CreateFrame(
        "CheckButton",
        "JAPProductsOnlyCheck",
        frame,
        "UICheckButtonTemplate"
    )
    self.productsOnlyCheck = productsOnlyCheck
    table.insert(self.recipeControls, productsOnlyCheck)
    productsOnlyCheck:SetWidth(24)
    productsOnlyCheck:SetHeight(24)
    productsOnlyCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 305, -108)
    productsOnlyCheck:SetChecked(self.productsOnly)
    productsOnlyCheck:SetScript("OnClick", function()
        JAP:SetProductsOnly(this:GetChecked() == 1)
    end)

    local productsOnlyLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    productsOnlyLabel:SetPoint("LEFT", productsOnlyCheck, "RIGHT", 2, 0)
    productsOnlyLabel:SetText("Potion prices only")
    table.insert(self.recipeControls, productsOnlyLabel)

    local sortLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sortLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 485, -116)
    sortLabel:SetText("Sort by")
    table.insert(self.recipeControls, sortLabel)

    local sortDropDown = CreateFrame("Frame", "JAPSortDropDown", frame, "UIDropDownMenuTemplate")
    self.sortDropDown = sortDropDown
    table.insert(self.recipeControls, sortDropDown)
    sortDropDown:SetPoint("TOPLEFT", frame, "TOPLEFT", 530, -102)
    UIDropDownMenu_SetWidth(110, sortDropDown)

    local clearRecipesButton = self:CreateButton(frame, "Clear Recipes", 100, 630, -76, function()
        JAP:ClearSavedRecipes()
    end)
    self.clearRecipesButton = clearRecipesButton
    table.insert(self.recipeControls, clearRecipesButton)

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
    status:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -145)
    status:SetWidth(710)
    status:SetJustifyH("LEFT")
    status:SetText("Open Alchemy, read recipes, then open the Auction House.")

    local headers = {"Recipe", "Craft cost", "Lowest price", "Profit"}
    local positions = {24, 245, 345, 445}
    self.columnHeaders = {}
    local h
    for h = 1, 4 do
        local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", frame, "TOPLEFT", positions[h], -171)
        header:SetText(headers[h])
        self.columnHeaders[h] = header
    end

    local listWheelCatcher = CreateFrame("Frame", nil, frame)
    self.listWheelCatcher = listWheelCatcher
    listWheelCatcher:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -184)
    listWheelCatcher:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 525, 55)
    listWheelCatcher:SetFrameLevel(frame:GetFrameLevel() + 1)
    listWheelCatcher:EnableMouse(false)
    listWheelCatcher:EnableMouseWheel(1)
    listWheelCatcher:SetScript("OnMouseWheel", function()
        JAP:HandleMouseWheel(arg1)
    end)

    local rowIndex
    for rowIndex = 1, self.visibleRows do
        local row = CreateFrame("Button", nil, frame)
        row:SetWidth(505)
        row:SetHeight(25)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -188 - ((rowIndex - 1) * 27))
        row:EnableMouseWheel(1)
        row:SetScript("OnMouseWheel", function()
            JAP:HandleMouseWheel(arg1)
        end)

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
            if JAP.currentPage == "recipes" and this.recipe then
                local additive = false
                if IsControlKeyDown and IsControlKeyDown() then additive = true end
                if IsShiftKeyDown and IsShiftKeyDown() then additive = true end
                JAP:SelectRecipe(this.recipe, additive)
            elseif JAP.currentPage == "materials" and this.material then
                local additive = false
                if IsControlKeyDown and IsControlKeyDown() then additive = true end
                if IsShiftKeyDown and IsShiftKeyDown() then additive = true end
                JAP:SelectMaterial(this.material, additive)
            end
        end)
        row:SetScript("OnEnter", function()
            if this.recipe or this.material then
                this.highlight:Show()
            end
        end)
        row:SetScript("OnLeave", function()
            if JAP.currentPage == "recipes" then
                if not JAP:IsRecipeSelected(this.recipe) then
                    this.highlight:Hide()
                end
            elseif JAP.currentPage == "materials" then
                if not JAP:IsMaterialSelected(this.material) then
                    this.highlight:Hide()
                end
            end
        end)

        self.rows[rowIndex] = row
    end

    local scroll = CreateFrame("Slider", nil, frame, "UIPanelScrollBarTemplate")
    self.scrollBar = scroll
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 526, -191)
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
    scroll:EnableMouseWheel(1)
    scroll:SetScript("OnMouseWheel", function()
        JAP:HandleMouseWheel(arg1)
    end)

    local detailBox = CreateFrame("Frame", nil, frame)
    detailBox:SetWidth(200)
    detailBox:SetHeight(350)
    detailBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -22, -175)
    detailBox:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    detailBox:SetBackdropColor(0, 0, 0, 0.75)
    detailBox:EnableMouse(true)
    detailBox:EnableMouseWheel(1)
    detailBox:SetScript("OnMouseWheel", function()
        JAP:HandleMouseWheel(arg1)
    end)

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

    if lower(message) == "scanmaterials" then
        self:BuildSelectedMaterialScan()
        return
    end

    if lower(message) == "scanallmaterials" then
        self:BuildAllMaterialScan()
        return
    end

    if lower(message) == "resethistory" then
        db().materialHistory = {}
        db().productHistory = {}
        chat("Material and potion price history cleared.")
        self:RefreshUI()
        return
    end

    if lower(message) == "resetmaterialhistory" then
        db().materialHistory = {}
        chat("Material price history cleared.")
        self:RefreshUI()
        return
    end

    if lower(message) == "resetpotionhistory" then
        db().productHistory = {}
        chat("Potion price history cleared.")
        self:RefreshUI()
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
    chat("/jap scanmaterials, /jap scanallmaterials")
    chat("/jap resethistory, /jap resetmaterialhistory, /jap resetpotionhistory")
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
