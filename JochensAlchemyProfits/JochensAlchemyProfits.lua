-- JochensAlchemyProfits
-- Turtle WoW / Vanilla 1.12.1 (Interface 11200)
-- No external libraries required.

JAP = {}
JAP.version = "0.20.20"
JAP.recipes = {}
JAP.recipeByName = {}
JAP.priceCache = {}
JAP.scanQueue = {}
JAP.currentScan = nil
JAP.scanRunning = false
JAP.selectedRecipe = nil
JAP.selectedRecipes = {}
JAP.lastQueryAt = 0
JAP.queryDelay = 0.05
JAP.lastLiveRecalculateAt = 0
JAP.liveRecalculateMinInterval = 0.05
JAP.completionSounds = true
JAP.pendingQuery = nil
JAP.rows = {}
JAP.visibleRows = 12
JAP.scrollOffset = 0
JAP.sortMode = "alphabetical"
JAP.favoritesOnly = false
JAP.productsOnly = false
JAP.displayRecipes = {}
JAP.materials = {}
JAP.currentPage = "recipes"
JAP.materialFavoritesOnly = false
JAP.selectedMaterial = nil
JAP.selectedMaterials = {}
JAP.missingRecipes = {}
JAP.selectedMissingRecipes = {}
JAP.selectedMissingRecipe = nil
JAP.missingFavoritesOnly = false
JAP.missingRecipeFavorites = {}
JAP.productionRecipes = {}
JAP.productionPlan = {}
JAP.productionTargetAmount = 5
JAP.productionRecipeTargets = {}
JAP.productionTargetRecipeIndex = 1
JAP.productionTemplateNames = {}
JAP.currentProductionTemplateName = nil
JAP.currentProductionTemplateIndex = 0
JAP.productionBuyCandidates = {}
JAP.productionBuyQueue = {}
JAP.productionBuyRunning = false
JAP.productionBuyPendingQuery = nil
JAP.productionBuyWaiting = false
JAP.productionBuyNextAt = 0
JAP.productionBuySpent = 0
JAP.productionBuyPlannedTotal = 0
JAP.productionLiveBuyPrices = {}
JAP.productionLiveBuyStacks = {}
JAP.productionCurrentPurchase = nil
JAP.productionBuyQuerySent = false
JAP.productionBuyResultReceived = false
JAP.productionBuyQuerySentAt = 0
JAP.productionBuyVerifyAttempts = 0
JAP.productionBuyPhase = nil
JAP.productionBuyConfirmedCount = 0
JAP.productionBuyScanReuseSeconds = 20
JAP.productionBuyUsedCachedScan = false

JAP.productionCraftQueue = {}
JAP.productionCraftRunning = false
JAP.productionCraftNextAt = 0
JAP.productionCraftCurrent = nil
JAP.productionCraftStartedAt = 0
JAP.productionCraftWaitingForBags = false
JAP.productionCraftWaitingForClick = false
JAP.productionCraftProgress = {}
JAP.productionCraftCompleted = {}
JAP.productionCraftSkipped = {}
JAP.productionBuySkipped = {}

JAP.productionPostQueue = {}
JAP.productionPostRunning = false
JAP.productionPostNextAt = 0
JAP.productionPostScanPending = false
JAP.productionPostPending = nil
JAP.productionPostPrepareAttempts = 0
JAP.productionPostSplitSourceBag = nil
JAP.productionPostSplitSourceSlot = nil
JAP.productionPostSplitTargetBag = nil
JAP.productionPostSplitTargetSlot = nil
JAP.productionPostStage = nil
JAP.productionPostLivePrices = {}
JAP.productionPostLiveListings = {}
JAP.productionPostReferenceInfo = {}
JAP.productionPostConfirmAttempts = 0
JAP.productionPostSourceBag = nil
JAP.productionPostSourceSlot = nil
JAP.productionPostStartedAt = 0
JAP.productionPostStackSize = 1
JAP.productionPostDuration = 6
JAP.productionPostProgress = {}
JAP.productionPostCompleted = {}
JAP.detailScrollOffset = 0
JAP.detailScrollMax = 0
JAP.detailScrollStep = 28
JAP.auctionWatchResults = {}
JAP.auctionWatchOwn = {}
JAP.auctionWatchOwnerScanRunning = false
JAP.auctionWatchOwnerPage = 0
JAP.auctionWatchLastCheck = nil
JAP.auctionWatchSelected = nil
JAP.auctionWatchSelectedItems = {}
JAP.auctionWatchCancelRunning = false
JAP.auctionWatchCancelTargets = {}
JAP.auctionWatchCancelMode = nil
JAP.auctionWatchCancelPage = 0
JAP.auctionWatchCancelWaiting = false
JAP.auctionWatchCancelCurrentName = nil
JAP.auctionWatchCancelCount = 0
JAP.auctionWatchCancelSkippedBids = 0
JAP.auctionWatchCancelEmptyPasses = 0
JAP.auctionWatchCancelNextRefreshAt = 0
JAP.auctionWatchCancelProcessAt = 0
JAP.auctionWatchCancelBidSkipped = {}
JAP.auctionWatchOwnerRefreshOnly = false
JAP.auctionWatchPreservedResults = nil
JAP.auctionWatchOwnerRefreshProcessAt = 0
JAP.auctionWatchOwnerRefreshStage = 0

local MISSING_RECIPE_CATALOG = {
    "Recipe: Alchemist's Stone",
    "Outline: Starfeather Arrows",
    "Recipe: Concoction of the Arcane Giant",
    "Recipe: Concoction of the Dreamwater",
    "Recipe: Dreamshard Elixir",
    "Recipe: Elixir of Greater Arcane Power",
    "Recipe: Elixir of Greater Frost Power",
    "Recipe: Elixir of Greater Nature Power",
    "Recipe: Elixir of Rapid Growth",
    "Recipe: Lucidity Potion",
    "Recipe: Major Rejuvenation Potion",
    "Recipe: Potion of Quickness",
    "Recipe: Discolored Healing Potion",
    "Recipe: Elixir of Brute Force",
    "Recipe: Elixir of Detect Lesser Invisibility",
    "Recipe: Elixir of Dream Vision",
    "Recipe: Elixir of Giant Growth",
    "Recipe: Elixir of Giants",
    "Recipe: Elixir of Greater Firepower",
    "Recipe: Elixir of Lesser Agility",
    "Recipe: Elixir of Minor Agility",
    "Recipe: Elixir of Shadow Power",
    "Recipe: Elixir of the Mongoose",
    "Recipe: Elixir of the Sages",
    "Recipe: Flask of Chromatic Resistance",
    "Recipe: Flask of Distilled Wisdom",
    "Recipe: Flask of Petrification",
    "Recipe: Flask of Supreme Power",
    "Recipe: Flask of the Titans",
    "Recipe: Frost Oil",
    "Recipe: Gift of Arthas",
    "Recipe: Greater Arcane Elixir",
    "Recipe: Greater Arcane Protection Potion",
    "Recipe: Greater Fire Protection Potion",
    "Recipe: Greater Frost Protection Potion",
    "Recipe: Greater Holy Protection Potion",
    "Recipe: Greater Nature Protection Potion",
    "Recipe: Greater Shadow Protection Potion",
    "Recipe: Greater Stoneshield Potion",
    "Recipe: Invisibility Potion",
    "Recipe: Limited Invulnerability Potion",
    "Recipe: Magic Resistance Potion",
    "Recipe: Major Mana Potion",
    "Recipe: Mighty Rage Potion",
    "Recipe: Purification Potion",
    "Recipe: Swiftness Potion",
    "Recipe: Transmute Air to Fire",
    "Recipe: Transmute Earth to Life",
    "Recipe: Transmute Earth to Water",
    "Recipe: Transmute Fire to Earth",
    "Recipe: Transmute Life to Earth",
    "Recipe: Transmute Undeath to Water",
    "Recipe: Transmute Water to Air",
    "Recipe: Transmute Water to Undeath",
    "Recipe: Transmute Arcanite",
    "Recipe: Transmute Elemental Fire",
    "Recipe: Transmute Iron to Gold",
    "Recipe: Transmute Mithril to Truesilver",
    "Recipe: Philosopher's Stone",
    "Recipe: Major Healing Potion",
    "Recipe: Superior Mana Potion",
    "Recipe: Free Action Potion",
    "Recipe: Elixir of Demonslaying",
    "Recipe: Shadow Oil",
    "Recipe: Elixir of Ogre's Strength",
    "Recipe: Mighty Troll's Blood Potion",
    "Recipe: Mageblood Potion",
    "Recipe: Goblin Rocket Fuel",
    "Recipe: Ghost Dye",
    "Recipe: Elixir of Poison Resistance",
    "Recipe: Shadow Protection Potion",
    "Recipe: Fire Protection Potion",
    "Recipe: Elixir of Superior Defense",
    "Recipe: Rage Potion",
    "Recipe: Elixir of Frost Power",
    "Recipe: Living Action Potion",
    "Recipe: Nature Protection Potion",
    "Recipe: Great Rage Potion",
    "Recipe: Major Troll's Blood Potion",
    "Recipe: Elixir of Fortitude",
    "Recipe: Minor Magic Resistance Potion",
    "Recipe: Frost Protection Potion",
    "Recipe: Holy Protection Potion",
    "Recipe: Lesser Stoneshield Potion",
    "Recipe: Greater Dreamless Sleep",
    "Recipe: Wildvine Potion",
    "Recipe: Cowardly Flight Potion",
    "Recipe: Elixir of Tongues",
    "Recipe: Restorative Potion",
    "Recipe: Elixir of Detect Demon",
    "Recipe: Elixir of Detect Undead",
    "Recipe: Elixir of Water Walking",
    "Recipe: Oil of Immolation",
}

local MISSING_RECIPE_MATERIALS = {
    ["recipe: flask of the titans"] = {
        {name = "Gromsblood", count = 30},
        {name = "Stonescale Oil", count = 10},
        {name = "Black Lotus", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: flask of supreme power"] = {
        {name = "Dreamfoil", count = 30},
        {name = "Mountain Silversage", count = 10},
        {name = "Black Lotus", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: flask of distilled wisdom"] = {
        {name = "Dreamfoil", count = 30},
        {name = "Icecap", count = 10},
        {name = "Black Lotus", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: flask of chromatic resistance"] = {
        {name = "Icecap", count = 30},
        {name = "Mountain Silversage", count = 10},
        {name = "Black Lotus", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: flask of petrification"] = {
        {name = "Stonescale Oil", count = 30},
        {name = "Ghost Mushroom", count = 10},
        {name = "Black Lotus", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: major mana potion"] = {
        {name = "Dreamfoil", count = 3},
        {name = "Icecap", count = 2},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: major healing potion"] = {
        {name = "Golden Sansam", count = 2},
        {name = "Mountain Silversage", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: elixir of the mongoose"] = {
        {name = "Mountain Silversage", count = 2},
        {name = "Plaguebloom", count = 2},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: greater arcane elixir"] = {
        {name = "Dreamfoil", count = 3},
        {name = "Mountain Silversage", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: elixir of brute force"] = {
        {name = "Gromsblood", count = 2},
        {name = "Plaguebloom", count = 2},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: elixir of giants"] = {
        {name = "Sungrass", count = 1},
        {name = "Gromsblood", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: elixir of shadow power"] = {
        {name = "Ghost Mushroom", count = 3},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: elixir of greater firepower"] = {
        {name = "Fire Oil", count = 3},
        {name = "Firebloom", count = 3},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: greater fire protection potion"] = {
        {name = "Elemental Fire", count = 1},
        {name = "Dreamfoil", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: greater frost protection potion"] = {
        {name = "Elemental Water", count = 1},
        {name = "Dreamfoil", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: greater nature protection potion"] = {
        {name = "Elemental Earth", count = 1},
        {name = "Dreamfoil", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: greater shadow protection potion"] = {
        {name = "Shadow Oil", count = 1},
        {name = "Dreamfoil", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: greater stoneshield potion"] = {
        {name = "Stonescale Oil", count = 3},
        {name = "Thorium Ore", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: mighty rage potion"] = {
        {name = "Gromsblood", count = 3},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: purification potion"] = {
        {name = "Icecap", count = 2},
        {name = "Plaguebloom", count = 2},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: limited invulnerability potion"] = {
        {name = "Blindweed", count = 2},
        {name = "Ghost Mushroom", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: invisibility potion"] = {
        {name = "Ghost Mushroom", count = 1},
        {name = "Sungrass", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: free action potion"] = {
        {name = "Blackmouth Oil", count = 2},
        {name = "Stranglekelp", count = 1},
        {name = "Leaded Vial", count = 1}
    },
    ["recipe: swiftness potion"] = {
        {name = "Swiftthistle", count = 1},
        {name = "Briarthorn", count = 1},
        {name = "Empty Vial", count = 1}
    },
    ["recipe: frost oil"] = {
        {name = "Khadgar's Whisker", count = 4},
        {name = "Wintersbite", count = 2},
        {name = "Leaded Vial", count = 1}
    },
    ["recipe: shadow oil"] = {
        {name = "Fadeleaf", count = 4},
        {name = "Grave Moss", count = 4},
        {name = "Leaded Vial", count = 1}
    },
    ["recipe: goblin rocket fuel"] = {
        {name = "Firebloom", count = 1},
        {name = "Volatile Rum", count = 1},
        {name = "Leaded Vial", count = 1}
    },
    ["recipe: ghost dye"] = {
        {name = "Ghost Mushroom", count = 2},
        {name = "Purple Dye", count = 1},
        {name = "Crystal Vial", count = 1}
    },
    ["recipe: transmute arcanite"] = {
        {name = "Thorium Bar", count = 1},
        {name = "Arcane Crystal", count = 1}
    },
    ["recipe: transmute iron to gold"] = {
        {name = "Iron Bar", count = 1}
    },
    ["recipe: transmute mithril to truesilver"] = {
        {name = "Mithril Bar", count = 1}
    },
    ["recipe: transmute elemental fire"] = {
        {name = "Heart of Fire", count = 1}
    },
    ["recipe: philosopher's stone"] = {
        {name = "Iron Bar", count = 4},
        {name = "Black Vitriol", count = 1},
        {name = "Purple Lotus", count = 4},
        {name = "Firebloom", count = 4}
    }
}

local function getMissingRecipeMaterials(item)
    if not item or not item.name then return nil end

    -- This helper is declared before the addon's local normalizeKey function.
    -- Use the standard string functions directly so Vanilla Lua does not try
    -- to call a non-existent global normalizeKey.
    local key = string.lower(item.name)
    key = string.gsub(key, "^%s+", "")
    key = string.gsub(key, "%s+$", "")
    key = string.gsub(key, "%s+", " ")

    return MISSING_RECIPE_MATERIALS[key]
end

local function missingRecipeMaterialsText(item)
    local materials = getMissingRecipeMaterials(item)
    if not materials or table.getn(materials) == 0 then
        return "|cffaaaaaaNo reagent data is stored for this recipe yet.|r"
    end

    local lines = {}
    local i
    for i = 1, table.getn(materials) do
        local material = materials[i]
        table.insert(lines, "  - " .. material.count .. "x " .. material.name)
    end

    return table.concat(lines, "\n")
end

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

local function truncateUiText(text, maxChars)
    if not text then return "" end

    text = tostring(text)
    if not maxChars or maxChars < 4 then
        return text
    end

    if string.len(text) <= maxChars then
        return text
    end

    return string.sub(text, 1, maxChars - 3) .. "..."
end

-- Static vial vendor costs in copper per vendor bundle.
local VIAL_VENDOR_BUNDLE_SIZE = 5
local VIAL_VENDOR_BUNDLE_PRICES = {
    ["empty vial"] = 18,
    ["leaded vial"] = 180,
    ["crystal vial"] = 2250,
    ["imbued vial"] = 27000
}

local function getStaticVialUnitPrice(name)
    if not name then return nil end

    local bundlePrice = VIAL_VENDOR_BUNDLE_PRICES[normalizeKey(name)]
    if not bundlePrice then return nil end

    return bundlePrice / VIAL_VENDOR_BUNDLE_SIZE
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
    if JochensAlchemyProfitsDB.settings.productionPostStackSize == nil then
        JochensAlchemyProfitsDB.settings.productionPostStackSize = 1
    end
    if JochensAlchemyProfitsDB.settings.productionPostDuration == nil then
        JochensAlchemyProfitsDB.settings.productionPostDuration = 6
    end
    if JochensAlchemyProfitsDB.settings.completionSounds == nil then
        JochensAlchemyProfitsDB.settings.completionSounds = true
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
    if not JochensAlchemyProfitsDB.recipeScrollHistory then
        JochensAlchemyProfitsDB.recipeScrollHistory = {}
    end
    if not JochensAlchemyProfitsDB.missingRecipeFavorites then
        JochensAlchemyProfitsDB.missingRecipeFavorites = {}
    end
    if not JochensAlchemyProfitsDB.productionTemplates then
        JochensAlchemyProfitsDB.productionTemplates = {}
    end
    if not JochensAlchemyProfitsDB.productionTemplateStatus then
        JochensAlchemyProfitsDB.productionTemplateStatus = {}
    end
    if JochensAlchemyProfitsDB.currentProductionTemplateName == nil then
        JochensAlchemyProfitsDB.currentProductionTemplateName = nil
    end
    if not JochensAlchemyProfitsDB.manualSkills then
        JochensAlchemyProfitsDB.manualSkills = {}
    end
    if not JochensAlchemyProfitsDB.recipes then
        JochensAlchemyProfitsDB.recipes = {}
    end
    if not JochensAlchemyProfitsDB.recipeBackup then
        JochensAlchemyProfitsDB.recipeBackup = {}
    end
    if not JochensAlchemyProfitsDB.recipeLastScan then
        JochensAlchemyProfitsDB.recipeLastScan = {}
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
    if JochensAlchemyProfitsDB.settings.missingFavoritesOnly == nil then
        JochensAlchemyProfitsDB.settings.missingFavoritesOnly = false
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

local function formatScanTimestamp(timestamp, shortFormat)
    if not timestamp then return "Never" end

    if date then
        if shortFormat then
            return date("%d.%m %H:%M", timestamp)
        end
        return date("%d.%m.%Y %H:%M", timestamp)
    end

    return tostring(timestamp)
end

local function inferRecipePriceTimestamp(recipe)
    if not recipe then return nil end

    local database = db()
    local oldest = nil
    local foundAny = false

    local function includePriceTimestamp(name)
        if not name then return false end

        local entry = database.prices[normalizeKey(name)]
        if not entry or not entry.savedAt then
            return false
        end

        foundAny = true
        if not oldest or entry.savedAt < oldest then
            oldest = entry.savedAt
        end
        return true
    end

    -- A recipe's complete pricing is only as fresh as its oldest required
    -- Auction House component. Vendor vials are intentionally ignored.
    local complete = includePriceTimestamp(recipe.productName)

    local i
    for i = 1, table.getn(recipe.reagents or {}) do
        local reagent = recipe.reagents[i]
        if reagent and reagent.name and not isExcludedVial(reagent.name) then
            if not includePriceTimestamp(reagent.name) then
                complete = false
            end
        end
    end

    if foundAny then
        return oldest, complete
    end

    return nil, false
end

local function getRecipeLastScanInfo(recipe)
    if not recipe then return nil, nil, nil end

    local saved =
        db().recipeLastScan and
        db().recipeLastScan[recipe.key or normalizeKey(recipe.name)]

    if saved then
        if type(saved) == "table" then
            return saved.at, saved.productsOnly == true, "recipe-scan"
        end
        return saved, false, "recipe-scan"
    end

    local inferredAt, complete = inferRecipePriceTimestamp(recipe)
    if inferredAt then
        return inferredAt, not complete, "stored-prices"
    end

    return nil, nil, nil
end

local function recipeLastScanShortText(recipe)
    local timestamp, productsOnly = getRecipeLastScanInfo(recipe)

    if not timestamp then
        return "|cff777777Never|r"
    end

    local mode = productsOnly and " P" or ""
    return "|cffaaaaaa" .. formatScanTimestamp(timestamp, true) .. mode .. "|r"
end

local function calculateWholeStackPurchase(listings, needed)
    if not listings or not needed or needed <= 0 then
        return 0, 0, 0, true
    end

    local sorted = {}
    local i

    for i = 1, table.getn(listings) do
        local listing = listings[i]
        if listing and listing.count and listing.count > 0
           and listing.buyout and listing.buyout > 0 then
            table.insert(sorted, {
                count = listing.count,
                buyout = listing.buyout,
                unitPrice = listing.unitPrice or
                    (listing.buyout / listing.count)
            })
        end
    end

    table.sort(sorted, function(a, b)
        if a.unitPrice == b.unitPrice then
            return a.buyout < b.buyout
        end
        return a.unitPrice < b.unitPrice
    end)

    local purchased = 0
    local totalCost = 0
    local auctionsUsed = 0

    for i = 1, table.getn(sorted) do
        if purchased >= needed then break end

        purchased = purchased + sorted[i].count
        totalCost = totalCost + sorted[i].buyout
        auctionsUsed = auctionsUsed + 1
    end

    return totalCost, purchased, auctionsUsed, purchased >= needed
end

local function saveAuctionPrice(name, unitBuyout, itemId, auctions, scanMeta)
    if not name or not unitBuyout or unitBuyout <= 0 then
        -- A failed, empty, interrupted, or temporarily unavailable scan must
        -- never erase the last known valid price.
        return false
    end

    local key = normalizeKey(name)
    local previous = db().prices[key]

    db().prices[key] = {
        name = name,
        unitBuyout = unitBuyout,
        itemId = itemId or (previous and previous.itemId),
        auctions = auctions or 0,
        pages = scanMeta and scanMeta.pages or 0,
        bestStackSize = scanMeta and scanMeta.bestStackSize or nil,
        bestStackBuyout = scanMeta and scanMeta.bestStackBuyout or nil,
        itemType = scanMeta and scanMeta.bestItemType or nil,
        itemSubType = scanMeta and scanMeta.bestItemSubType or nil,
        rejectedRecipes = scanMeta and scanMeta.rejectedRecipes or 0,
        purchaseListings =
            scanMeta and scanMeta.persistPurchaseListings
            and scanMeta.listings or nil,
        purchaseListingsSavedAt =
            scanMeta and scanMeta.persistPurchaseListings
            and time() or nil,
        savedAt = time(),
        previousUnitBuyout =
            previous and previous.unitBuyout or nil
    }

    return true
end


local HISTORY_WINDOW_SECONDS = 14 * 24 * 60 * 60

local function migrateHistorySamples(history)
    if history.samplesList then
        return
    end

    history.samplesList = {}

    local oldPrice = history.lastPrice or history.referencePrice
    local oldTime = history.lastSeen or time()

    if oldPrice and oldPrice > 0 then
        table.insert(history.samplesList, {
            price = oldPrice,
            timestamp = oldTime
        })
    end
end

local function pruneHistorySamples(history, currentTime)
    migrateHistorySamples(history)

    local cutoff = currentTime - HISTORY_WINDOW_SECONDS
    local kept = {}
    local sampleIndex

    for sampleIndex = 1, table.getn(history.samplesList) do
        local sample = history.samplesList[sampleIndex]
        if sample
           and sample.price
           and sample.price > 0
           and sample.timestamp
           and sample.timestamp >= cutoff then
            table.insert(kept, sample)
        end
    end

    history.samplesList = kept
end

local function averageHistorySamples(samples)
    if not samples or table.getn(samples) == 0 then
        return nil
    end

    local total = 0
    local count = 0
    local sampleIndex

    for sampleIndex = 1, table.getn(samples) do
        local sample = samples[sampleIndex]
        if sample and sample.price and sample.price > 0 then
            total = total + sample.price
            count = count + 1
        end
    end

    if count == 0 then
        return nil
    end

    return total / count
end

local function updateRollingHistory(historyDb, name, currentPrice)
    if not name or not currentPrice or currentPrice <= 0 then
        return
    end

    local key = normalizeKey(name)
    local currentTime = time()
    local history = historyDb[key]

    if not history then
        history = {
            name = name,
            samplesList = {},
            firstSeen = currentTime
        }
        historyDb[key] = history
    end

    pruneHistorySamples(history, currentTime)

    local previousReference = averageHistorySamples(history.samplesList)
    if previousReference and previousReference > 0 then
        history.lastIndex = (currentPrice / previousReference) * 100
    else
        history.lastIndex = 100
    end

    table.insert(history.samplesList, {
        price = currentPrice,
        timestamp = currentTime
    })

    history.referencePrice =
        averageHistorySamples(history.samplesList) or currentPrice
    history.lastPrice = currentPrice
    history.samples = table.getn(history.samplesList)
    history.lastSeen = currentTime
end

local function updateMaterialHistory(name, currentPrice)
    updateRollingHistory(db().materialHistory, name, currentPrice)
end

local function getMaterialHistory(name)
    if not name then return nil end

    local history = db().materialHistory[normalizeKey(name)]
    if history then
        pruneHistorySamples(history, time())
        history.referencePrice =
            averageHistorySamples(history.samplesList) or history.lastPrice
        history.samples = table.getn(history.samplesList)
    end

    return history
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
    updateRollingHistory(db().productHistory, name, currentPrice)
end

local function getProductHistory(name)
    if not name then return nil end

    local history = db().productHistory[normalizeKey(name)]
    if history then
        pruneHistorySamples(history, time())
        history.referencePrice =
            averageHistorySamples(history.samplesList) or history.lastPrice
        history.samples = table.getn(history.samplesList)
    end

    return history
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


local function updateRecipeScrollHistory(name, currentPrice)
    updateRollingHistory(db().recipeScrollHistory, name, currentPrice)
end

local function getRecipeScrollHistory(name)
    if not name then return nil end
    local history = db().recipeScrollHistory[normalizeKey(name)]
    if history then
        pruneHistorySamples(history, time())
        history.referencePrice =
            averageHistorySamples(history.samplesList) or history.lastPrice
        history.samples = table.getn(history.samplesList)
    end
    return history
end

local function recipeScrollIndexText(name)
    local history = getRecipeScrollHistory(name)
    if not history or not history.lastIndex then return "-" end
    local index = history.lastIndex
    local text = string.format("%.0f%%", index)
    if index < 97 then return "|cff55ff55" .. text .. "|r" end
    if index > 103 then return "|cffff5555" .. text .. "|r" end
    return "|cffffff66" .. text .. "|r"
end

local function setStatus(text)
    if JAP.statusText then
        JAP.statusText:SetText(text or "")
    end
end

function JAP:SerializeRecipes(recipeList)
    local serialized = {}
    local source = recipeList or self.recipes
    local recipeIndex

    for recipeIndex = 1, table.getn(source or {}) do
        local recipe = source[recipeIndex]

        if recipe and recipe.name then
            local savedRecipe = {
                name = recipe.name,
                key = recipe.key or normalizeKey(recipe.name),
                productName = recipe.productName or recipe.name,
                productLink = recipe.productLink,
                productId = recipe.productId,
                minMade = recipe.minMade or 1,
                maxMade = recipe.maxMade or recipe.minMade or 1,
                skillType = recipe.skillType,
                requiredSkill = recipe.requiredSkill,
                requiredSkillSource = recipe.requiredSkillSource,
                reagents = {}
            }

            local reagentIndex
            for reagentIndex = 1, table.getn(recipe.reagents or {}) do
                local reagent = recipe.reagents[reagentIndex]

                if reagent and reagent.name then
                    table.insert(savedRecipe.reagents, {
                        name = reagent.name,
                        key = reagent.key or normalizeKey(reagent.name),
                        count = reagent.count or 1,
                        link = reagent.link,
                        itemId = reagent.itemId
                    })
                end
            end

            table.insert(serialized, savedRecipe)
        end
    end

    return serialized
end

function JAP:SaveRecipes()
    local database = db()
    local serialized = self:SerializeRecipes(self.recipes)

    -- Never replace a known-good master list with an empty incidental state.
    if table.getn(serialized) == 0
       and table.getn(database.recipes or {}) > 0 then
        chat(
            "Recipe save skipped because the current runtime list is empty. " ..
            "The last saved master list was preserved."
        )
        return false
    end

    -- Rotate the currently saved list into a last-known-good backup before
    -- committing the new complete snapshot.
    if table.getn(database.recipes or {}) > 0 then
        database.recipeBackup = database.recipes
    end

    database.recipes = serialized
    database.recipeRevision = (database.recipeRevision or 0) + 1
    database.recipeSavedAt = time()

    return true
end

function JAP:LoadSavedRecipes()
    local database = db()
    local savedRecipes = database.recipes

    if not savedRecipes or table.getn(savedRecipes) == 0 then
        savedRecipes = database.recipeBackup

        if savedRecipes and table.getn(savedRecipes) > 0 then
            database.recipes = savedRecipes
            chat("Recovered the learned-recipe master list from backup.")
        else
            return false
        end
    end

    local loaded = {}
    local loadedByName = {}
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

            table.insert(loaded, recipe)
            loadedByName[recipe.key] = recipe
        end
    end

    if table.getn(loaded) == 0 then
        return false
    end

    -- Commit only after the complete saved snapshot has been validated.
    clearArray(self.recipes)
    self.recipeByName = {}

    for recipeIndex = 1, table.getn(loaded) do
        table.insert(self.recipes, loaded[recipeIndex])
        self.recipeByName[loaded[recipeIndex].key] =
            loaded[recipeIndex]
    end

    self.sortMode = "alphabetical"
    db().settings.sortMode = "alphabetical"
    self:ApplySort()
    self.selectedRecipe = self.recipes[1]
    self.selectedRecipes = {}

    if self.selectedRecipe then
        self.selectedRecipes[self.selectedRecipe.key] = true
    end

    self:CalculateAllProfits()
    return true
end

function JAP:ClearSavedRecipes()
    clearArray(self.recipes)
    clearArray(self.displayRecipes)
    self.recipeByName = {}
    self.selectedRecipe = nil
    self.selectedRecipes = {}
    self.scrollOffset = 0
    db().recipes = {}
    db().recipeBackup = {}
    db().recipeRevision = (db().recipeRevision or 0) + 1
    db().recipeSavedAt = time()

    setStatus("Saved recipes cleared. Open Alchemy and click Read Alchemy.")
    chat("Saved recipes cleared. Open Alchemy and click Read Alchemy to scan them again.")
    self:RefreshUI()
end

function JAP:ReadAlchemy(silent)
    if not TradeSkillFrame or not TradeSkillFrame:IsVisible() then
        chat("Open your Alchemy profession window first.")
        return false
    end

    local skillName = GetTradeSkillLine()
    if not skillName or lower(skillName) ~= "alchemy" then
        chat(
            "Reading the currently open profession: " ..
            tostring(skillName or "unknown")
        )
    end

    -- Scan into an isolated temporary snapshot. Never clear the persistent
    -- runtime master list before the client has returned valid data.
    local scannedRecipes = {}
    local scannedByName = {}
    local count = GetNumTradeSkills() or 0
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

            local requiredSkill, requiredSkillSource =
                getRequiredSkill(index, skillName, recipeName)

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

            local reagentCount =
                GetTradeSkillNumReagents(index) or 0
            local reagentIndex
            local reagentScanComplete = true
            local reagentsRead = 0

            for reagentIndex = 1, reagentCount do
                local reagentName, reagentTexture, requiredCount =
                    GetTradeSkillReagentInfo(index, reagentIndex)
                local reagentLink = nil

                if GetTradeSkillReagentItemLink then
                    reagentLink =
                        GetTradeSkillReagentItemLink(
                            index,
                            reagentIndex
                        )
                end

                if reagentName and reagentName ~= "" then
                    reagentsRead = reagentsRead + 1
                    table.insert(recipe.reagents, {
                        name = reagentName,
                        key = normalizeKey(reagentName),
                        count = requiredCount or 1,
                        link = reagentLink,
                        itemId = getItemId(reagentLink),
                        reagentIndex = reagentIndex
                    })
                else
                    -- Turtle/Vanilla can briefly report the correct reagent
                    -- count while one individual reagent slot is still nil.
                    -- Never let that transient API state overwrite a complete
                    -- saved recipe with a recipe missing an ingredient.
                    reagentScanComplete = false
                end
            end

            if reagentsRead ~= reagentCount then
                reagentScanComplete = false
            end

            if reagentScanComplete then
                table.insert(scannedRecipes, recipe)
                scannedByName[recipe.key] = recipe
            else
                local existingRecipe =
                    self.recipeByName and self.recipeByName[recipe.key]

                if existingRecipe then
                    -- Keep the last known complete recipe. The merge below
                    -- will preserve it because this incomplete scan is not
                    -- entered into scannedByName.
                    if not silent then
                        chat(
                            "Kept saved reagents for " .. recipeName ..
                            ": Turtle returned only " .. reagentsRead ..
                            "/" .. reagentCount .. " reagent(s)."
                        )
                    end
                elseif not silent then
                    chat(
                        "Skipped incomplete recipe read for " .. recipeName ..
                        " (" .. reagentsRead .. "/" .. reagentCount ..
                        " reagents). Re-read Alchemy to try again."
                    )
                end
            end
        end
    end

    if table.getn(scannedRecipes) == 0 then
        if not silent then
            chat(
                "Alchemy returned no recipes. The saved master list was " ..
                "left unchanged."
            )
        end
        return false
    end

    -- Merge the successful scan into the master list. Scanned entries replace
    -- older copies, while recipes temporarily absent because of loading,
    -- filtering, or client state remain preserved.
    local merged = {}
    local mergedByName = {}
    local existingIndex

    for existingIndex = 1, table.getn(self.recipes or {}) do
        local existing = self.recipes[existingIndex]

        if existing and existing.name then
            local key = existing.key or normalizeKey(existing.name)
            local replacement = scannedByName[key]

            if replacement then
                table.insert(merged, replacement)
                mergedByName[key] = replacement
                scannedByName[key] = nil
            else
                table.insert(merged, existing)
                mergedByName[key] = existing
            end
        end
    end

    local scannedIndex
    for scannedIndex = 1, table.getn(scannedRecipes) do
        local scanned = scannedRecipes[scannedIndex]

        if scannedByName[scanned.key] then
            table.insert(merged, scanned)
            mergedByName[scanned.key] = scanned
            scannedByName[scanned.key] = nil
        end
    end

    if table.getn(merged) == 0 then
        return false
    end

    -- Atomic in-memory commit after the complete merged snapshot is ready.
    clearArray(self.recipes)
    self.recipeByName = {}

    for existingIndex = 1, table.getn(merged) do
        table.insert(self.recipes, merged[existingIndex])
        self.recipeByName[merged[existingIndex].key] =
            merged[existingIndex]
    end

    self.sortMode = "alphabetical"
    db().settings.sortMode = "alphabetical"
    self:ApplySort()

    -- Preserve current selection when possible.
    local previousKey =
        self.selectedRecipe and self.selectedRecipe.key or nil
    self.selectedRecipes = {}

    if previousKey and self.recipeByName[previousKey] then
        self.selectedRecipe = self.recipeByName[previousKey]
    else
        self.selectedRecipe = self.recipes[1]
    end

    if self.selectedRecipe then
        self.selectedRecipes[self.selectedRecipe.key] = true
    end

    local saved = self:SaveRecipes()

    if not silent then
        chat(
            "Read " .. table.getn(scannedRecipes) ..
            " complete recipes and preserved " ..
            table.getn(self.recipes) ..
            " recipes in the master list."
        )
    end

    -- Re-reading Alchemy rebuilds recipe objects and therefore clears the
    -- transient recipe.result field. Recalculate immediately from the durable
    -- global price cache so the Recipes table never appears empty.
    self:CalculateAllProfits()
    return saved ~= false
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
    self.sortMode = "alphabetical"
    db().settings.sortMode = "alphabetical"

    table.sort(self.recipes, function(a, b)
        return lower(a.name or "") < lower(b.name or "")
    end)
end

function JAP:SetSortMode(mode)
    self.sortMode = "alphabetical"
    db().settings.sortMode = "alphabetical"
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
    local recipeScanKeys = {}
    local recipeScanRequirements = {}
    local recipeIndex
    for recipeIndex = 1, table.getn(selected) do
        local recipe = selected[recipeIndex]
        recipeScanKeys[recipe.key] = true
        recipeScanRequirements[recipe.key] = {}
        local reagentIndex
        if not self.productsOnly then
            for reagentIndex = 1, table.getn(recipe.reagents or {}) do
                local reagent = recipe.reagents[reagentIndex]
                if reagent and reagent.name and not isExcludedVial(reagent.name) then
                    local reagentKey =
                        reagent.key or normalizeKey(reagent.name)

                    items[reagentKey] = {
                        name = reagent.name,
                        itemId = reagent.itemId,
                        itemKind = "reagent"
                    }
                    recipeScanRequirements[recipe.key][reagentKey] = true
                end
            end
        end

        if recipe.productName then
            local productKey = normalizeKey(recipe.productName)
            items[productKey] = {
                name = recipe.productName,
                itemId = recipe.productId,
                itemKind = "product"
            }
            recipeScanRequirements[recipe.key][productKey] = true
        end
    end

    chat("Scanning " .. table.getn(selected) .. " selected recipe(s).")
    self:StartScan(
        items,
        "selected",
        recipeScanKeys,
        recipeScanRequirements
    )
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
    local recipeScanKeys = {}
    local recipeScanRequirements = {}
    local recipeIndex
    for recipeIndex = 1, table.getn(sourceRecipes) do
        local recipe = sourceRecipes[recipeIndex]

        if recipe then
            recipeScanKeys[recipe.key] = true
            recipeScanRequirements[recipe.key] = {}
            if not self.productsOnly then
                local reagentIndex
                for reagentIndex = 1, table.getn(recipe.reagents or {}) do
                    local reagent = recipe.reagents[reagentIndex]
                    if reagent and reagent.name and not isExcludedVial(reagent.name) then
                        local reagentKey =
                            reagent.key or normalizeKey(reagent.name)

                        items[reagentKey] = {
                            name = reagent.name,
                            itemId = reagent.itemId,
                            itemKind = "reagent"
                        }
                        recipeScanRequirements[recipe.key][reagentKey] = true
                    end
                end
            end

            if recipe.productName then
                local productKey = normalizeKey(recipe.productName)
                items[productKey] = {
                    name = recipe.productName,
                    itemId = recipe.productId,
                    itemKind = "product"
                }
                recipeScanRequirements[recipe.key][productKey] = true
            end
        end
    end

    local mode = self.favoritesOnly and "favorites" or "all"
    self:StartScan(
        items,
        mode,
        recipeScanKeys,
        recipeScanRequirements
    )
end

function JAP:RecalculateLiveResultsThrottled(force)
    local currentTime = now()

    if force
       or currentTime - (self.lastLiveRecalculateAt or 0) >=
          (self.liveRecalculateMinInterval or 0.05) then
        self.lastLiveRecalculateAt = currentTime
        self:RecalculateLiveResults()
        return true
    end

    return false
end

function JAP:IsAlchemyAuctionWatchProduct(name)
    if not name then return false end

    local key = normalizeKey(name)
    local recipeIndex

    for recipeIndex = 1, table.getn(self.recipes or {}) do
        local recipe = self.recipes[recipeIndex]
        local productName = recipe and (recipe.productName or recipe.name)

        if productName and normalizeKey(productName) == key then
            return true
        end
    end

    -- Safe fallback for alchemy outputs that are posted but not present in the
    -- currently loaded learned-recipe list.
    return string.find(key, "potion", 1, true) ~= nil
        or string.find(key, "elixir", 1, true) ~= nil
        or string.find(key, "flask", 1, true) ~= nil
end

function JAP:ClearAuctionWatch()
    self.auctionWatchResults = {}
    self.auctionWatchOwn = {}
    self.auctionWatchSelected = nil
    self.auctionWatchSelectedItems = {}
end

function JAP:IsAuctionWatchSelected(result)
    if not result or not result.key then return false end
    return self.auctionWatchSelectedItems
        and self.auctionWatchSelectedItems[result.key] ~= nil
end

function JAP:GetAuctionWatchSelectedCount()
    local count = 0
    local key, result

    for key, result in pairs(self.auctionWatchSelectedItems or {}) do
        if result then count = count + 1 end
    end

    return count
end

function JAP:SelectAuctionWatchItem(result, additive)
    if not result or not result.key then return end

    if not self.auctionWatchSelectedItems then
        self.auctionWatchSelectedItems = {}
    end

    if not additive then
        self.auctionWatchSelectedItems = {}
        self.auctionWatchSelectedItems[result.key] = result
        self.auctionWatchSelected = result
    else
        if self.auctionWatchSelectedItems[result.key] then
            self.auctionWatchSelectedItems[result.key] = nil

            if self.auctionWatchSelected
               and self.auctionWatchSelected.key == result.key then
                self.auctionWatchSelected = nil
            end
        else
            self.auctionWatchSelectedItems[result.key] = result
            self.auctionWatchSelected = result
        end

        if not self.auctionWatchSelected then
            local key, selected
            for key, selected in pairs(self.auctionWatchSelectedItems) do
                self.auctionWatchSelected = selected
                break
            end
        end
    end

    self:RefreshUI()
end

function JAP:RequestOwnerAuctionList()
    if GetOwnerAuctionItems then
        GetOwnerAuctionItems()
    end
end

function JAP:CanStartAuctionWatchCancel()
    if not AuctionFrame or not AuctionFrame:IsVisible() then
        chat("Open the Auction House first.")
        setStatus("Open the Auction House before cancelling auctions.")
        return false
    end

    if self.auctionWatchCancelRunning then
        chat("An auction cancellation is already running.")
        return false
    end

    if self.scanRunning or self.auctionWatchOwnerScanRunning
       or self.productionBuyRunning or self.productionPostRunning then
        chat("Finish the current Auction House operation first.")
        return false
    end

    if not CancelAuction or not GetOwnerAuctionItems then
        chat("This client does not expose the required owner-auction API.")
        return false
    end

    return true
end

function JAP:StartAuctionWatchCancelTargets(targets, mode)
    if not self:CanStartAuctionWatchCancel() then return end

    local targetCount = 0
    local key, enabled
    for key, enabled in pairs(targets or {}) do
        if enabled then targetCount = targetCount + 1 end
    end

    if targetCount == 0 then
        chat("No matching auctions to cancel.")
        return
    end

    self.auctionWatchCancelRunning = true
    self.auctionWatchCancelTargets = targets
    self.auctionWatchCancelMode = mode
    self.auctionWatchCancelPage = 0
    self.auctionWatchCancelWaiting = false
    self.auctionWatchCancelCurrentName = nil
    self.auctionWatchCancelCount = 0
    self.auctionWatchCancelSkippedBids = 0
    self.auctionWatchCancelEmptyPasses = 0
    self.auctionWatchCancelNextRefreshAt = 0
    self.auctionWatchCancelProcessAt = 0
    self.auctionWatchCancelBidSkipped = {}

    setStatus(
        "Cancelling matching auctions one at a time..."
    )
    chat(
        "Cancelling all matching auctions, including auctions with active bids."
    )

    -- My Auctions has already loaded the owner list. Start immediately instead
    -- of waiting for an event that Turtle may not emit again.
    self:ProcessAuctionWatchCancelOwnerList()
end

function JAP:CancelAuctionWatchSelected()
    local targets = {}
    local selectedCount = 0
    local key, result

    for key, result in pairs(self.auctionWatchSelectedItems or {}) do
        if result then
            targets[key] = true
            selectedCount = selectedCount + 1
        end
    end

    if selectedCount == 0 then
        chat("Select one or more products in My Auctions first.")
        setStatus(
            "Select one or more products before using Cancel Selected."
        )
        return
    end

    chat(
        "Cancelling auctions for " ..
        selectedCount .. " selected product type(s)."
    )

    self:StartAuctionWatchCancelTargets(targets, "selected")
end

function JAP:CancelAuctionWatchUndercut()
    local targets = {}
    local results = self:GetAuctionWatchDisplayResults()
    local count = 0
    local i

    -- Use exactly the results currently shown in the My Auctions table.
    -- This avoids an internal stale-table mismatch where visible UNDERCUT
    -- rows existed but auctionWatchResults no longer contained them.
    for i = 1, table.getn(results) do
        local result = results[i]
        if result and result.key and result.status == "undercut" then
            targets[result.key] = true
            count = count + 1
        end
    end

    if count == 0 then
        chat("No undercut product types are currently shown.")
        setStatus("Nothing to cancel: no visible undercut products found.")
        return
    end

    self:StartAuctionWatchCancelTargets(targets, "undercut")
end

function JAP:RefreshAuctionWatchFromCurrentOwnerList()
    local preserved = self.auctionWatchResults or {}
    local refreshedOwn = {}

    local batchCount, totalCount = GetNumAuctionItems("owner")
    batchCount = batchCount or 0
    totalCount = totalCount or batchCount

    local ownerCount = totalCount
    if ownerCount < batchCount then ownerCount = batchCount end

    local index
    for index = 1, ownerCount do
        local name, texture, count, quality, canUse, level,
              minBid, minIncrement, buyoutPrice, bidAmount,
              highBidder, owner =
              GetAuctionItemInfo("owner", index)

        if name and buyoutPrice and buyoutPrice > 0
           and count and count > 0
           and self:IsAlchemyAuctionWatchProduct(name) then
            local key = normalizeKey(name)
            local unitPrice = buyoutPrice / count
            local entry = refreshedOwn[key]

            if not entry then
                entry = {
                    key = key,
                    name = name,
                    myLowest = unitPrice,
                    myHighest = unitPrice,
                    auctionCount = 0,
                    itemCount = 0,
                    stacks = {}
                }
                refreshedOwn[key] = entry
            end

            entry.auctionCount = entry.auctionCount + 1
            entry.itemCount = entry.itemCount + count

            if unitPrice < entry.myLowest then
                entry.myLowest = unitPrice
            end
            if unitPrice > entry.myHighest then
                entry.myHighest = unitPrice
            end

            table.insert(entry.stacks, {
                count = count,
                buyout = buyoutPrice,
                unitPrice = unitPrice
            })
        end
    end

    self.auctionWatchOwn = refreshedOwn
    self.auctionWatchResults = {}

    local key, own
    for key, own in pairs(refreshedOwn) do
        local oldResult = preserved[key]

        if oldResult then
            self.auctionWatchResults[key] = {
                key = key,
                name = own.name,
                myLowest = own.myLowest,
                myHighest = own.myHighest,
                myAuctionCount = own.auctionCount,
                myItemCount = own.itemCount,
                competitorBest = oldResult.competitorBest,
                competitorOwner = oldResult.competitorOwner,
                competitorCount = oldResult.competitorCount,
                status = oldResult.status,
                checkedAt = oldResult.checkedAt
            }
        else
            self.auctionWatchResults[key] = {
                key = key,
                name = own.name,
                myLowest = own.myLowest,
                myHighest = own.myHighest,
                myAuctionCount = own.auctionCount,
                myItemCount = own.itemCount,
                status = "checking"
            }
        end
    end

    -- Drop selections that no longer exist after cancellation.
    local selected = {}
    local selectedKey, selectedResult
    for selectedKey, selectedResult in
        pairs(self.auctionWatchSelectedItems or {}) do
        if refreshedOwn[selectedKey] then
            selected[selectedKey] =
                self.auctionWatchResults[selectedKey]
        end
    end
    self.auctionWatchSelectedItems = selected

    if self.auctionWatchSelected
       and not refreshedOwn[self.auctionWatchSelected.key] then
        self.auctionWatchSelected = nil
    elseif self.auctionWatchSelected then
        self.auctionWatchSelected =
            self.auctionWatchResults[self.auctionWatchSelected.key]
    end

    self.scrollOffset = 0
    self:RefreshUI()

    return refreshedOwn
end

function JAP:FinishAuctionWatchCancel()
    local cancelled = self.auctionWatchCancelCount or 0

    self.auctionWatchCancelRunning = false
    self.auctionWatchCancelTargets = {}
    self.auctionWatchCancelMode = nil
    self.auctionWatchCancelPage = 0
    self.auctionWatchCancelWaiting = false
    self.auctionWatchCancelCurrentName = nil
    self.auctionWatchCancelEmptyPasses = 0
    self.auctionWatchCancelNextRefreshAt = 0
    self.auctionWatchCancelProcessAt = 0
    self.auctionWatchCancelBidSkipped = {}

    local text =
        "Auction cancellation complete: " ..
        cancelled .. " auction(s) cancelled."

    chat(text)

    -- Keep ONLY the market comparison data temporarily. The visible owner
    -- list itself is deliberately destroyed right now so stale rows can
    -- never remain on screen after a cancellation.
    self.auctionWatchPreservedResults = self.auctionWatchResults or {}

    self.auctionWatchOwn = {}
    self.auctionWatchResults = {}
    self.auctionWatchSelected = nil
    self.auctionWatchSelectedItems = {}
    self.scrollOffset = 0

    self.auctionWatchOwnerRefreshOnly = true
    self.auctionWatchOwnerScanRunning = true
    self.auctionWatchOwnerRefreshStage = 1
    self.auctionWatchOwnerRefreshProcessAt = now() + 0.60

    -- Clear the table visually BEFORE requesting anything from Turtle.
    self:RefreshUI()
    setStatus(
        "Cancelled auctions removed. Reloading your current owner list..."
    )

    self:RequestOwnerAuctionList()
end

function JAP:ProcessAuctionWatchCancelOwnerList()
    if not self.auctionWatchCancelRunning then return end
    if self.auctionWatchCancelWaiting then return end

    local batchCount, totalCount = GetNumAuctionItems("owner")
    batchCount = batchCount or 0
    totalCount = totalCount or batchCount

    -- Owner auctions are loaded as one local list. Use totalCount so indices
    -- above 50 are checked as well; AuctionFrameAuctions.page is UI-only.
    local ownerCount = totalCount
    if ownerCount < batchCount then ownerCount = batchCount end

    local index
    for index = 1, ownerCount do
        local name, texture, count, quality, canUse, level,
              minBid, minIncrement, buyoutPrice, bidAmount,
              highBidder, owner =
              GetAuctionItemInfo("owner", index)

        local key = name and normalizeKey(name) or nil

        if key and self.auctionWatchCancelTargets[key] then
            self.auctionWatchCancelEmptyPasses = 0
            self.auctionWatchCancelWaiting = true
            self.auctionWatchCancelCurrentName = name
            self.auctionWatchCancelCount =
                (self.auctionWatchCancelCount or 0) + 1

            setStatus(
                "Cancelling " .. tostring(name) ..
                " (" .. tostring(self.auctionWatchCancelCount) .. ")..."
            )

            if SetSelectedAuctionItem then
                SetSelectedAuctionItem("owner", index)
            end

            -- Intentionally also cancel auctions with active bids.
            CancelAuction(index)

            -- Ignore any immediate transitional owner update. We explicitly
            -- refresh after a short delay and then process the refreshed list.
            self.auctionWatchCancelNextRefreshAt = now() + 0.60
            self.auctionWatchCancelProcessAt = 0
            return
        end
    end

    -- No target found in the currently loaded owner list. Confirm once more
    -- with a fresh owner request before declaring completion.
    self.auctionWatchCancelEmptyPasses =
        (self.auctionWatchCancelEmptyPasses or 0) + 1

    if self.auctionWatchCancelEmptyPasses < 2 then
        setStatus("Verifying that no matching auctions remain...")
        self.auctionWatchCancelNextRefreshAt = now() + 0.35
        self.auctionWatchCancelProcessAt = 0
        return
    end

    self:FinishAuctionWatchCancel()
end

function JAP:ProcessAuctionWatchCancelRefresh()
    if not self.auctionWatchCancelRunning then return end

    local currentTime = now()

    local refreshAt = self.auctionWatchCancelNextRefreshAt or 0
    if refreshAt > 0 and currentTime >= refreshAt then
        self.auctionWatchCancelNextRefreshAt = 0
        self.auctionWatchCancelWaiting = false

        self:RequestOwnerAuctionList()

        -- Do not depend on AUCTION_OWNED_LIST_UPDATE. Process the list again
        -- after a small grace period even if Turtle emits no event at all.
        self.auctionWatchCancelProcessAt = currentTime + 0.20
        return
    end

    local processAt = self.auctionWatchCancelProcessAt or 0
    if processAt > 0 and currentTime >= processAt then
        self.auctionWatchCancelProcessAt = 0
        self:ProcessAuctionWatchCancelOwnerList()
    end
end

function JAP:ProcessAuctionWatchOwnerRefreshFallback()
    if not self.auctionWatchOwnerScanRunning then
        self.auctionWatchOwnerRefreshProcessAt = 0
        self.auctionWatchOwnerRefreshStage = 0
        return
    end

    local processAt = self.auctionWatchOwnerRefreshProcessAt or 0
    if processAt <= 0 or now() < processAt then return end

    -- After a cancel run we deliberately request the owner list TWICE.
    -- Stage 1 gives Turtle time to settle, requests the current owner list
    -- again, then stage 2 rebuilds the table from that fresh list.
    if self.auctionWatchOwnerRefreshOnly
       and self.auctionWatchOwnerRefreshStage == 1 then
        self.auctionWatchOwnerRefreshStage = 2
        self.auctionWatchOwnerRefreshProcessAt = now() + 0.30
        self:RequestOwnerAuctionList()
        return
    end

    self.auctionWatchOwnerRefreshProcessAt = 0
    self.auctionWatchOwnerRefreshStage = 0
    self:ProcessAuctionWatchOwnerPage()
end

function JAP:StartAuctionWatch()
    if self.auctionWatchCancelRunning then
        chat("Wait until the current auction cancellation is finished.")
        return
    end

    if not AuctionFrame or not AuctionFrame:IsVisible() then
        chat("Open the Auction House first.")
        setStatus("Open the Auction House before checking your auctions.")
        return
    end

    if self.scanRunning or self.productionBuyRunning
       or self.productionPostRunning then
        chat("Finish the current Auction House operation first.")
        return
    end

    -- A manual Check My Auctions is always a completely fresh run.
    -- Throw away every visible/result row first so stale data can never make
    -- the second check look like nothing happened.
    self:ClearAuctionWatch()
    self.scrollOffset = 0
    self.auctionWatchOwnerRefreshOnly = false
    self.auctionWatchPreservedResults = nil
    self.auctionWatchOwnerRefreshStage = 0
    self.auctionWatchOwnerScanRunning = true
    self.auctionWatchOwnerPage = 0
    self.auctionWatchLastCheck = nil

    -- Clear the visible table immediately.
    self:RefreshUI()

    setStatus("Reading your current Auction House listings...")
    chat("Checking your current Alchemy auctions...")

    if GetOwnerAuctionItems then
        self:RequestOwnerAuctionList()

        -- Turtle/Octo may not emit AUCTION_OWNED_LIST_UPDATE again when the
        -- owner list was already loaded. Always process it after a short delay
        -- as a fallback. If the real event arrives first it cancels this timer.
        self.auctionWatchOwnerRefreshProcessAt = now() + 0.30
    else
        self.auctionWatchOwnerScanRunning = false
        self.auctionWatchOwnerRefreshProcessAt = 0
        chat("This client does not expose the owner auction list.")
    end
end

function JAP:ProcessAuctionWatchOwnerPage()
    if not self.auctionWatchOwnerScanRunning then return end

    self.auctionWatchOwnerRefreshProcessAt = 0
    self.auctionWatchOwnerRefreshStage = 0

    local batchCount, totalCount = GetNumAuctionItems("owner")
    batchCount = batchCount or 0
    totalCount = totalCount or batchCount

    local ownerCount = totalCount
    if ownerCount < batchCount then ownerCount = batchCount end

    local index
    for index = 1, ownerCount do
        local name, texture, count, quality, canUse, level,
              minBid, minIncrement, buyoutPrice, bidAmount,
              highBidder, owner =
              GetAuctionItemInfo("owner", index)

        if name and buyoutPrice and buyoutPrice > 0
           and count and count > 0
           and self:IsAlchemyAuctionWatchProduct(name) then
            local key = normalizeKey(name)
            local unitPrice = buyoutPrice / count
            local entry = self.auctionWatchOwn[key]

            if not entry then
                entry = {
                    key = key,
                    name = name,
                    myLowest = unitPrice,
                    myHighest = unitPrice,
                    auctionCount = 0,
                    itemCount = 0,
                    stacks = {}
                }
                self.auctionWatchOwn[key] = entry
            end

            entry.auctionCount = entry.auctionCount + 1
            entry.itemCount = entry.itemCount + count
            if unitPrice < entry.myLowest then entry.myLowest = unitPrice end
            if unitPrice > entry.myHighest then entry.myHighest = unitPrice end

            table.insert(entry.stacks, {
                count = count,
                buyout = buyoutPrice,
                unitPrice = unitPrice
            })
        end
    end

    self.auctionWatchOwnerScanRunning = false

    local items = {}
    local key, own
    local typeCount = 0
    for key, own in pairs(self.auctionWatchOwn) do
        items[key] = {
            name = own.name,
            itemKind = "product"
        }
        typeCount = typeCount + 1
    end

    if self.auctionWatchOwnerRefreshOnly then
        local preserved = self.auctionWatchPreservedResults or {}
        self.auctionWatchResults = {}

        for key, own in pairs(self.auctionWatchOwn) do
            local oldResult = preserved[key]

            if oldResult then
                self.auctionWatchResults[key] = {
                    key = key,
                    name = own.name,
                    myLowest = own.myLowest,
                    myHighest = own.myHighest,
                    myAuctionCount = own.auctionCount,
                    myItemCount = own.itemCount,
                    competitorBest = oldResult.competitorBest,
                    competitorOwner = oldResult.competitorOwner,
                    competitorCount = oldResult.competitorCount,
                    status = oldResult.status,
                    checkedAt = oldResult.checkedAt
                }
            else
                self.auctionWatchResults[key] = {
                    key = key,
                    name = own.name,
                    myLowest = own.myLowest,
                    myHighest = own.myHighest,
                    myAuctionCount = own.auctionCount,
                    myItemCount = own.itemCount,
                    status = "checking"
                }
            end
        end

        self.auctionWatchOwnerRefreshOnly = false
        self.auctionWatchPreservedResults = nil

        if typeCount == 0 then
            setStatus("No current Potion/Elixir/Flask auctions remain.")
        else
            setStatus(
                "Remaining auctions refreshed; market prices kept from the last check."
            )
        end

        self:RefreshUI()
        return
    end

    if typeCount == 0 then
        setStatus("No current Potion/Elixir/Flask auctions found.")
        chat("No current Alchemy product auctions were found in your owner list.")
        self:RefreshUI()
        return
    end

    setStatus(
        "Found " .. typeCount ..
        " Alchemy product type(s); checking competitors..."
    )

    self:StartScan(items, "auction-watch")
end

function JAP:FinalizeAuctionWatchItem(scan)
    if not scan then return end

    local own = self.auctionWatchOwn[scan.key]
    if not own then return end

    local playerName = UnitName("player")
    local competitorBest = nil
    local competitorOwner = nil
    local competitorCount = 0
    local listingIndex

    for listingIndex = 1, table.getn(scan.listings or {}) do
        local listing = scan.listings[listingIndex]
        local isMine =
            listing.owner and playerName
            and lower(listing.owner) == lower(playerName)

        if not isMine then
            competitorCount = competitorCount + 1

            if competitorBest == nil
               or listing.unitPrice < competitorBest then
                competitorBest = listing.unitPrice
                competitorOwner = listing.owner
            end
        end
    end

    local status = "cheapest"
    if competitorBest ~= nil then
        if competitorBest < own.myLowest then
            status = "undercut"
        elseif math.floor(competitorBest) ==
               math.floor(own.myLowest) then
            status = "tied"
        end
    end

    local result = {
        key = own.key,
        name = own.name,
        myLowest = own.myLowest,
        myHighest = own.myHighest,
        myAuctionCount = own.auctionCount,
        myItemCount = own.itemCount,
        competitorBest = competitorBest,
        competitorOwner = competitorOwner,
        competitorCount = competitorCount,
        status = status,
        checkedAt = time()
    }

    self.auctionWatchResults[own.key] = result

    if status == "undercut" then
        chat(
            "|cffff5555WARNING: " .. own.name ..
            " was undercut.|r Your cheapest: " ..
            moneyToText(own.myLowest) ..
            " each; competitor: " ..
            moneyToText(competitorBest) .. " each."
        )
    end

    if self.currentPage == "auction-watch" then
        self:RefreshUI()
    end
end

function JAP:GetAuctionWatchDisplayResults()
    local results = {}
    local key, own

    for key, own in pairs(self.auctionWatchOwn or {}) do
        local result = self.auctionWatchResults[key]

        if result then
            table.insert(results, result)
        else
            table.insert(results, {
                key = key,
                name = own.name,
                myLowest = own.myLowest,
                myHighest = own.myHighest,
                myAuctionCount = own.auctionCount,
                myItemCount = own.itemCount,
                status = "checking"
            })
        end
    end

    table.sort(results, function(a, b)
        local rank = {
            undercut = 1,
            tied = 2,
            checking = 3,
            cheapest = 4
        }

        local ar = rank[a.status] or 9
        local br = rank[b.status] or 9

        if ar ~= br then return ar < br end
        return lower(a.name or "") < lower(b.name or "")
    end)

    return results
end

function JAP:AuctionWatchDetailText()
    local results = self:GetAuctionWatchDisplayResults()
    local undercut = 0
    local tied = 0
    local cheapest = 0
    local checking = 0
    local totalAuctions = 0
    local totalItems = 0
    local i

    for i = 1, table.getn(results) do
        local result = results[i]
        totalAuctions = totalAuctions + (result.myAuctionCount or 0)
        totalItems = totalItems + (result.myItemCount or 0)

        if result.status == "undercut" then
            undercut = undercut + 1
        elseif result.status == "tied" then
            tied = tied + 1
        elseif result.status == "cheapest" then
            cheapest = cheapest + 1
        else
            checking = checking + 1
        end
    end

    local lines = {
        "|cffffd100My Auctions|r",
        "",
        "Checks the Alchemy products that are actually",
        "listed in your current Auction House owner list.",
        ""
    }

    if self.auctionWatchLastCheck then
        table.insert(
            lines,
            "Last check: " ..
            date("%d.%m.%Y %H:%M", self.auctionWatchLastCheck)
        )
    else
        table.insert(lines, "Last check: Never")
    end

    table.insert(lines, "")
    table.insert(lines, "|cffffd100Summary:|r")
    table.insert(lines, "Product types: " .. table.getn(results))
    table.insert(
        lines,
        "Your auctions: " .. totalAuctions ..
        "  |  Items: " .. totalItems
    )
    table.insert(
        lines,
        "|cffff5555Undercut: " .. undercut .. "|r" ..
        "  |  |cffffff55Tied: " .. tied .. "|r" ..
        "  |  |cff55ff55Cheapest: " .. cheapest .. "|r"
    )

    if checking > 0 then
        table.insert(lines, "Still checking: " .. checking)
    end

    if table.getn(results) == 0 then
        table.insert(lines, "")
        table.insert(
            lines,
            "Open the Auction House and click Check My Auctions."
        )
    else
        table.insert(lines, "")
        table.insert(lines, "|cffffd100Meaning:|r")
        table.insert(lines, "|cff55ff55CHEAPEST|r = your lowest listing is below competitors.")
        table.insert(lines, "|cffffff55TIED|r = competitor matches your lowest price.")
        table.insert(lines, "|cffff5555UNDERCUT|r = a competitor is cheaper.")
        table.insert(lines, "")
        table.insert(lines, "Warnings are grouped per potion/elixir/flask type.")
        table.insert(lines, "")
        table.insert(lines, "|cffffd100Cancel actions:|r")
        table.insert(lines, "Cancel Selected removes all auctions of every selected type.")
        table.insert(lines, "Ctrl/Shift-click adds or removes products from the selection.")
        table.insert(lines, "Cancel Undercut removes all your auctions for UNDERCUT types.")
        table.insert(lines, "Auctions with active bids are also cancelled; WoW may charge its cancellation fee.")
        table.insert(lines, "Cancelled items return through the Auction House mailbox.")
    end

    return table.concat(lines, "\n")
end

function JAP:LoadCompletionSoundSetting()
    self.completionSounds =
        db().settings.completionSounds ~= false

    if self.completionSoundButton then
        if self.completionSounds then
            self.completionSoundButton:SetText("Sound: On")
        else
            self.completionSoundButton:SetText("Sound: Off")
        end
    end
end

function JAP:ToggleCompletionSounds()
    self.completionSounds = not self.completionSounds
    db().settings.completionSounds = self.completionSounds

    if self.completionSoundButton then
        if self.completionSounds then
            self.completionSoundButton:SetText("Sound: On")
        else
            self.completionSoundButton:SetText("Sound: Off")
        end
    end

    if self.completionSounds then
        chat("Completion sounds enabled.")
        self:PlayCompletionSound("scan")
    else
        chat("Completion sounds disabled.")
    end
end

function JAP:PlayCompletionSound(kind)
    if not self.completionSounds or not PlaySound then return end

    if kind == "craft" then
        -- Short coin sound used when money is looted/collected.
        PlaySound("LOOTWINDOWCOINSOUND")
    else
        -- Turtle/Vanilla uses this exact CamelCase sound name.
        PlaySound("AuctionWindowOpen")
    end
end

function JAP:StartScan(
    items,
    mode,
    recipeScanKeys,
    recipeScanRequirements
)
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
        -- Every requested item is queried again, but the last known valid
        -- price remains visible until a complete successful scan replaces it.
        table.insert(self.scanQueue, {
            name = item.name,
            key = key,
            itemId = item.itemId,
            itemKind = item.itemKind,
            needed = item.needed,
            page = 0,
            best = nil,
            auctions = 0
        })
    end

    table.sort(self.scanQueue, function(a, b)
        return lower(a.name) < lower(b.name)
    end)

    -- Keep the last valid values visible and refresh the affected rows.
    self:RecalculateLiveResultsThrottled(true)

    self.scanMode = mode
    self.activeRecipeScanKeys = recipeScanKeys
    self.activeRecipeScanProductsOnly = self.productsOnly == true
    self.activeRecipeScanRequirements = recipeScanRequirements
    self.activeRecipeScanRemaining = {}
    self.activeItemRecipeDependencies = {}

    if recipeScanRequirements then
        local recipeKey, requirements, itemKey

        for recipeKey, requirements in pairs(recipeScanRequirements) do
            local remaining = 0

            for itemKey, required in pairs(requirements) do
                if required then
                    remaining = remaining + 1

                    if not self.activeItemRecipeDependencies[itemKey] then
                        self.activeItemRecipeDependencies[itemKey] = {}
                    end

                    self.activeItemRecipeDependencies[itemKey][recipeKey] = true
                end
            end

            self.activeRecipeScanRemaining[recipeKey] = remaining
        end
    end

    if mode == "production-buy" then
        self.productionBuyCandidates = {}
    end

    self.scanTotal = table.getn(self.scanQueue)
    self.scanDone = 0
    self.scanRunning = true
    self.currentScan = nil
    self.pendingQuery = nil

    if self.scanTotal == 0 then
        self.scanRunning = false
        self:ClearActiveRecipeScanTracking()
        self:CalculateAllProfits()
        setStatus("No Auction House items were found for this scan.")
        chat("No Auction House items were found for this scan.")
        return
    end

    local scanScope = self.productsOnly and "crafted potion prices only" or "potions and ingredients"

    if mode == "auction-watch" then
        chat("Scanning competitors for your current Alchemy auctions.")
        setStatus("Checking whether your auctions are still cheapest...")
    elseif mode == "production-buy" then
        chat("Scanning exact auctions for the Production purchase.")
        setStatus("Scanning materials before Buy All.")
    elseif mode == "production-post-scan" then
        chat("Scanning finished potion prices before posting.")
        setStatus("Scanning potion prices before Post All.")
    elseif mode == "materials-selected" then
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

function JAP:RecordRecipeScanCompleted(recipeKey)
    if not recipeKey then return end

    db().recipeLastScan[recipeKey] = {
        at = time(),
        productsOnly = self.activeRecipeScanProductsOnly == true
    }
end

function JAP:RecordCompletedScanItemForRecipes(itemKey)
    local dependencies =
        self.activeItemRecipeDependencies and
        self.activeItemRecipeDependencies[itemKey]

    if not dependencies then return end

    local recipeKey, required
    for recipeKey, required in pairs(dependencies) do
        if required then
            local remaining =
                self.activeRecipeScanRemaining and
                self.activeRecipeScanRemaining[recipeKey]

            if remaining and remaining > 0 then
                remaining = remaining - 1
                self.activeRecipeScanRemaining[recipeKey] = remaining

                -- The timestamp changes immediately after the final required
                -- product/reagent query for THIS recipe completes.
                if remaining == 0 then
                    self:RecordRecipeScanCompleted(recipeKey)
                end
            end
        end
    end
end

function JAP:ClearActiveRecipeScanTracking()
    self.activeRecipeScanKeys = nil
    self.activeRecipeScanProductsOnly = nil
    self.activeRecipeScanRequirements = nil
    self.activeRecipeScanRemaining = nil
    self.activeItemRecipeDependencies = nil
end

function JAP:StartNextItem()
    if not self.scanRunning then return end

    if table.getn(self.scanQueue) == 0 then
        local completedMode = self.scanMode

        self.scanRunning = false
        self.currentScan = nil
        self.pendingQuery = nil

        self:ClearActiveRecipeScanTracking()

        self:RecalculateLiveResultsThrottled(true)

        if completedMode == "auction-watch" then
            self.auctionWatchLastCheck = time()

            local results = self:GetAuctionWatchDisplayResults()
            local warningCount = 0
            local resultIndex
            for resultIndex = 1, table.getn(results) do
                if results[resultIndex].status == "undercut" then
                    warningCount = warningCount + 1
                end
            end

            if warningCount > 0 then
                setStatus(
                    "Auction check complete: " .. warningCount ..
                    " product type(s) undercut."
                )
                chat(
                    "Auction check complete: " .. warningCount ..
                    " product type(s) are currently undercut."
                )
            else
                setStatus("Auction check complete: no undercuts found.")
                chat("Auction check complete: your checked Alchemy auctions are cheapest or tied.")
            end

            self:RefreshUI()
            self:PlayCompletionSound("scan")
            return
        elseif completedMode == "production-buy" then
            self:BuildProductionPlan(true)
            setStatus(
                "Fresh scan complete. Verifying the cheapest auction before each buy."
            )
            self:StartProductionPurchaseExecution()
            return
        elseif completedMode == "production-post-scan"
               and self.productionPostScanPending then
            self.productionPostScanPending = false

            if self:BuildProductionPostQueue() then
                self.productionPostRunning = true
                self.productionPostNextAt = now()
                setStatus(
                    "Posting " ..
                    table.getn(self.productionPostQueue) ..
                    " single-item auction(s)."
                )
            end
            return
        end

        setStatus("Scan complete: " .. self.scanDone .. "/" .. self.scanTotal .. " items.")
        chat("Auction scan complete. Scanned " .. self.scanDone .. " unique item(s).")
        self:PlayCompletionSound("scan")
        return
    end

    self.currentScan = table.remove(self.scanQueue, 1)
    self.currentScan.page = 0
    self.currentScan.targetKey =
        normalizeKey(self.currentScan.name)
    self.currentScan.best = nil
    self.currentScan.auctions = 0
    self.currentScan.pages = 0
    self.currentScan.rejectedRecipes = 0
    self.currentScan.listings = {}

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
    if self.productionBuyRunning
       and self.productionBuyPendingQuery
       and not self.scanRunning then
        if self.productionBuyQuerySent then
            self.productionBuyResultReceived = true
        end
        return
    end

    if not self.scanRunning or not self.currentScan then return end
    if self.pendingQuery then return end

    local batchCount, totalCount = GetNumAuctionItems("list")
    batchCount = batchCount or 0
    totalCount = totalCount or 0
    self.currentScan.pages = (self.currentScan.pages or 0) + 1

    local targetKey = self.currentScan.targetKey or normalizeKey(self.currentScan.name)
    local targetId = self.currentScan.itemId
    local index

    for index = 1, batchCount do
        local name, texture, count, quality, canUse, level, minBid, minIncrement,
              buyoutPrice, bidAmount, highBidder, owner =
              GetAuctionItemInfo("list", index)

        -- Most Blizzard name searches also return partial matches. Reject those
        -- before requesting item links or cached item metadata.
        local exactName =
            name and normalizeKey(name) == targetKey

        if exactName and buyoutPrice and buyoutPrice > 0
           and count and count > 0 then
            local link = nil
            local auctionId = nil
            local itemType = nil
            local itemSubType = nil
            local needsLink =
                targetId ~= nil
                or self.currentScan.itemKind == "product"
                or self.scanMode == "production-buy"

            if needsLink and GetAuctionItemLink then
                link = GetAuctionItemLink("list", index)
                auctionId = getItemId(link)
            end

            -- Only products need type metadata to reject Recipe: ... scrolls.
            if self.currentScan.itemKind == "product"
               and link and GetItemInfo then
                local ignoredName, ignoredLink, ignoredQuality, ignoredLevel,
                      ignoredMinLevel, fetchedType, fetchedSubType =
                      GetItemInfo(link)
                itemType = fetchedType
                itemSubType = fetchedSubType
            end

            local exactId =
                targetId == nil
                or auctionId == nil
                or auctionId == targetId

            local categoryAllowed = true
            if self.currentScan.itemKind == "product"
               and normalizeKey(itemType) == "recipe" then
                categoryAllowed = false
                self.currentScan.rejectedRecipes =
                    self.currentScan.rejectedRecipes + 1
            end

            if exactId and categoryAllowed then
                -- Compare every auction by buyout per individual item.
                -- Keep fractional copper internally so stacks are compared exactly:
                -- 5 for 5g = 10000c each, 15 for 10g = 6666.666c each.
                local unitPrice = buyoutPrice / count
                self.currentScan.auctions = self.currentScan.auctions + 1

                if self.scanMode == "production-buy"
                   or self.scanMode == "production-materials"
                   or self.scanMode == "production-post-scan"
                   or self.scanMode == "auction-watch" then
                    table.insert(self.currentScan.listings, {
                        name = name,
                        itemId = auctionId,
                        page = self.currentScan.page,
                        count = count,
                        buyout = buyoutPrice,
                        unitPrice = unitPrice,
                        owner = owner,
                        link = link
                    })
                end

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
        if self.scanMode == "production-materials" then
            self.currentScan.persistPurchaseListings = true
        end

        saveAuctionPrice(
            self.currentScan.name,
            self.currentScan.best,
            self.currentScan.itemId,
            self.currentScan.auctions,
            self.currentScan
        )

        if self.scanMode == "auction-watch" then
            self:FinalizeAuctionWatchItem(self.currentScan)
        elseif self.scanMode == "production-buy" then
            self.productionBuyCandidates[self.currentScan.key] =
                self.currentScan.listings or {}
        elseif self.scanMode == "production-post-scan" then
            self.productionPostLivePrices[self.currentScan.key] =
                self.currentScan.best
            self.productionPostLiveListings[self.currentScan.key] =
                self.currentScan.listings or {}
        end

        if self.currentScan.itemKind == "reagent" and self.currentScan.best ~= nil then
            updateMaterialHistory(self.currentScan.name, self.currentScan.best)
        elseif self.currentScan.itemKind == "product" and self.currentScan.best ~= nil then
            updateProductHistory(self.currentScan.name, self.currentScan.best)
        elseif self.currentScan.itemKind == "recipe-scroll" and self.currentScan.best ~= nil then
            updateRecipeScrollHistory(self.currentScan.name, self.currentScan.best)
        end

        if self.scanMode == "production-materials" then
            self:BuildProductionPlan(true)
        end

        local finishText = "Finished: " .. self.currentScan.name ..
            " - " .. self.currentScan.auctions .. " matching auction(s) on " ..
            self.currentScan.pages .. " page(s)"

        if self.currentScan.best ~= nil then
            finishText = finishText .. ", cheapest " ..
                moneyToText(self.currentScan.best) .. " each"
        else
            local previousPrice =
                getAnyStoredPrice(self.currentScan.name)

            if previousPrice then
                finishText = finishText ..
                    ", no new buyout found; kept previous " ..
                    moneyToText(previousPrice) .. " each"
            else
                finishText = finishText .. ", no buyout found"
            end
        end

        chat(finishText)

        if self.scanMode == "selected"
           or self.scanMode == "favorites"
           or self.scanMode == "all" then
            self:RecordCompletedScanItemForRecipes(self.currentScan.key)
        end

        -- Update affected recipes live without doing duplicate refresh work
        -- multiple times inside the same event-loop tick.
        self:RecalculateLiveResultsThrottled(false)

        self.scanDone = self.scanDone + 1
        self:StartNextItem()
    end
end

function JAP:CancelScan(reason)
    local cancelledMode = self.scanMode

    self.scanRunning = false
    self.currentScan = nil
    self.pendingQuery = nil
    clearArray(self.scanQueue)
    self:ClearActiveRecipeScanTracking()

    if cancelledMode == "production-buy" then
        self.productionBuyRunning = false
        self.productionBuyPhase = nil
        self.productionBuyCandidates = {}
    elseif cancelledMode == "production-post-scan" then
        self.productionPostScanPending = false
    end

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
            local vialUnitPrice = getStaticVialUnitPrice(reagent.name)
            local vialTotal = 0

            if vialUnitPrice then
                vialTotal = vialUnitPrice * reagent.count
                craftingCost = craftingCost + vialTotal
            end

            table.insert(details, {
                name = reagent.name,
                count = reagent.count,
                unitPrice = vialUnitPrice,
                total = vialTotal,
                source = "vendor",
                excludedFromScan = true
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

function JAP:ApplyDefaultTableLayout()
    self:PositionColumnHeaders(-188)

    local i
    for i = 1, self.visibleRows do
        local row = self.rows[i]

        row:ClearAllPoints()
        row:SetPoint(
            "TOPLEFT",
            self.frame,
            "TOPLEFT",
            20,
            -208 - ((i - 1) * 27)
        )

        row.name:ClearAllPoints()
        row.name:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.name:SetWidth(205)

        row.cost:ClearAllPoints()
        row.cost:SetPoint("LEFT", row, "LEFT", 215, 0)
        row.cost:SetWidth(90)

        row.market:ClearAllPoints()
        row.market:SetPoint("LEFT", row, "LEFT", 310, 0)
        row.market:SetWidth(90)

        row.profit:ClearAllPoints()
        row.profit:SetPoint("LEFT", row, "LEFT", 405, 0)
        row.profit:SetWidth(140)
    end
end

function JAP:ApplyAuctionWatchTableLayout()
    local positions = {24, 245, 345, 445}
    local i

    for i = 1, 4 do
        self.columnHeaders[i]:ClearAllPoints()
        self.columnHeaders[i]:SetPoint(
            "TOPLEFT",
            self.frame,
            "TOPLEFT",
            positions[i],
            -206
        )
    end

    for i = 1, self.visibleRows do
        local row = self.rows[i]

        row:ClearAllPoints()
        row:SetPoint(
            "TOPLEFT",
            self.frame,
            "TOPLEFT",
            20,
            -226 - ((i - 1) * 27)
        )

        row.name:ClearAllPoints()
        row.name:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.name:SetWidth(215)

        row.cost:ClearAllPoints()
        row.cost:SetPoint("LEFT", row, "LEFT", 225, 0)
        row.cost:SetWidth(95)

        row.market:ClearAllPoints()
        row.market:SetPoint("LEFT", row, "LEFT", 325, 0)
        row.market:SetWidth(95)

        row.profit:ClearAllPoints()
        row.profit:SetPoint("LEFT", row, "LEFT", 425, 0)
        row.profit:SetWidth(120)
    end
end

function JAP:ApplyProductionTableLayout()
    local positions = {24, 150, 300, 405}
    local i

    for i = 1, 4 do
        self.columnHeaders[i]:ClearAllPoints()
        self.columnHeaders[i]:SetPoint(
            "TOPLEFT",
            self.frame,
            "TOPLEFT",
            positions[i],
            -188
        )
    end

    for i = 1, self.visibleRows do
        local row = self.rows[i]

        row:ClearAllPoints()
        row:SetPoint(
            "TOPLEFT",
            self.frame,
            "TOPLEFT",
            20,
            -208 - ((i - 1) * 27)
        )

        row.name:ClearAllPoints()
        row.name:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.name:SetWidth(120)

        row.cost:ClearAllPoints()
        row.cost:SetPoint("LEFT", row, "LEFT", 130, 0)
        row.cost:SetWidth(140)

        row.market:ClearAllPoints()
        row.market:SetPoint("LEFT", row, "LEFT", 280, 0)
        row.market:SetWidth(95)

        row.profit:ClearAllPoints()
        row.profit:SetPoint("LEFT", row, "LEFT", 385, 0)
        row.profit:SetWidth(150)
    end
end

function JAP:PositionColumnHeaders(y)
    local headerY = y or -188
    local positions = {24, 225, 320, 415}
    local i

    for i = 1, 4 do
        if self.columnHeaders[i] then
            self.columnHeaders[i]:ClearAllPoints()
            self.columnHeaders[i]:SetPoint(
                "TOPLEFT",
                self.frame,
                "TOPLEFT",
                positions[i],
                headerY
            )
        end
    end
end

function JAP:RefreshUI()
    if not self.frame then return end

    if self.currentPage == "auction-watch" then
        self:ApplyAuctionWatchTableLayout()

        if self.recipesTabButton then self.recipesTabButton:UnlockHighlight() end
        if self.materialsTabButton then self.materialsTabButton:UnlockHighlight() end
        if self.missingTabButton then self.missingTabButton:UnlockHighlight() end
        if self.productionTabButton then self.productionTabButton:UnlockHighlight() end
        if self.auctionWatchTabButton then self.auctionWatchTabButton:LockHighlight() end

        local i
        local groups = {
            self.recipeControls,
            self.materialControls,
            self.missingControls,
            self.productionControls
        }
        local groupIndex
        for groupIndex = 1, table.getn(groups) do
            local controls = groups[groupIndex] or {}
            for i = 1, table.getn(controls) do controls[i]:Hide() end
        end

        local controls = self.auctionWatchControls or {}
        for i = 1, table.getn(controls) do controls[i]:Show() end

        self.columnHeaders[1]:SetText("My product")
        self.columnHeaders[2]:SetText("My lowest")
        self.columnHeaders[3]:SetText("Competitor")
        self.columnHeaders[4]:SetText("Status")

        local results = self:GetAuctionWatchDisplayResults()
        local count = table.getn(results)

        for i = 1, self.visibleRows do
            local row = self.rows[i]
            local result = results[i + self.scrollOffset]

            row.recipe = nil
            row.material = nil
            row.missingRecipe = nil
            row.productionItem = nil
            row.auctionWatchItem = result

            if result then
                row:Show()
                row.name:SetText(result.name or "")
                row.cost:SetText(moneyToText(result.myLowest))

                if result.competitorBest then
                    row.market:SetText(moneyToText(result.competitorBest))
                else
                    row.market:SetText("-")
                end

                if result.status == "undercut" then
                    row.profit:SetText("|cffff5555UNDERCUT|r")
                elseif result.status == "tied" then
                    row.profit:SetText("|cffffff55TIED|r")
                elseif result.status == "cheapest" then
                    row.profit:SetText("|cff55ff55CHEAPEST|r")
                else
                    row.profit:SetText("|cffffff66CHECKING...|r")
                end

                if self:IsAuctionWatchSelected(result) then
                    row.highlight:Show()
                else
                    row.highlight:Hide()
                end
            else
                row:Hide()
            end
        end

        local maxOffset = math.max(0, count - self.visibleRows)
        if self.scrollOffset > maxOffset then self.scrollOffset = maxOffset end
        self.updatingScrollBar = true
        self.scrollBar:SetMinMaxValues(0, maxOffset)
        self.scrollBar:SetValue(self.scrollOffset)
        self.updatingScrollBar = false

        local selectedCount = self:GetAuctionWatchSelectedCount()

        if selectedCount > 1 then
            local lines = {
                "|cffffd100Selected products: " ..
                tostring(selectedCount) .. "|r",
                "",
                "Cancel Selected will remove all of your current",
                "Auction House listings for these product types:",
                ""
            }

            local selectedResults = {}
            local selectedKey, selectedResult
            for selectedKey, selectedResult in
                pairs(self.auctionWatchSelectedItems or {}) do
                if selectedResult then
                    table.insert(selectedResults, selectedResult)
                end
            end

            table.sort(selectedResults, function(a, b)
                return lower(a.name or "") < lower(b.name or "")
            end)

            local selectedIndex
            for selectedIndex = 1, table.getn(selectedResults) do
                local selectedResult = selectedResults[selectedIndex]
                local statusText = "CHECKING"

                if selectedResult.status == "undercut" then
                    statusText = "|cffff5555UNDERCUT|r"
                elseif selectedResult.status == "tied" then
                    statusText = "|cffffff55TIED|r"
                elseif selectedResult.status == "cheapest" then
                    statusText = "|cff55ff55CHEAPEST|r"
                end

                table.insert(
                    lines,
                    "- " .. tostring(selectedResult.name or "") ..
                    "  " .. statusText
                )
            end

            self:SetDetailText(table.concat(lines, "\n"))
        elseif self.auctionWatchSelected then
            local result = self.auctionWatchSelected
            local lines = {
                "|cffffd100" .. tostring(result.name or "") .. "|r",
                "",
                "Your auctions: " .. tostring(result.myAuctionCount or 0),
                "Your item count: " .. tostring(result.myItemCount or 0),
                "Your cheapest: " .. moneyToText(result.myLowest)
            }

            if result.myHighest
               and math.floor(result.myHighest) ~= math.floor(result.myLowest) then
                table.insert(
                    lines,
                    "Your highest: " .. moneyToText(result.myHighest)
                )
            end

            table.insert(lines, "")

            if result.status == "undercut" then
                table.insert(lines, "|cffff5555STATUS: UNDERCUT|r")
                table.insert(
                    lines,
                    "Cheapest competitor: " ..
                    moneyToText(result.competitorBest)
                )
                if result.competitorOwner then
                    table.insert(
                        lines,
                        "Competitor: " .. tostring(result.competitorOwner)
                    )
                end
                table.insert(
                    lines,
                    "Difference: " ..
                    moneyToText(result.myLowest - result.competitorBest)
                )
            elseif result.status == "tied" then
                table.insert(lines, "|cffffff55STATUS: TIED CHEAPEST|r")
                table.insert(
                    lines,
                    "Competitor price: " ..
                    moneyToText(result.competitorBest)
                )
            elseif result.status == "cheapest" then
                table.insert(lines, "|cff55ff55STATUS: CHEAPEST|r")
                if result.competitorBest then
                    table.insert(
                        lines,
                        "Next competitor: " ..
                        moneyToText(result.competitorBest)
                    )
                else
                    table.insert(lines, "No competing buyout found.")
                end
            else
                table.insert(lines, "|cffffff66Still checking...|r")
            end

            self:SetDetailText(table.concat(lines, "\n"))
        else
            self:SetDetailText(self:AuctionWatchDetailText())
        end

        if self.auctionWatchOwnerScanRunning then
            setStatus("Reading your current Auction House listings...")
        elseif self.scanRunning and self.scanMode == "auction-watch" then
            -- Keep the scan engine's live item status.
        elseif count == 0 then
            setStatus("Open the Auction House and click Check My Auctions.")
        end

        return
    end

    if self.auctionWatchTabButton then
        self.auctionWatchTabButton:UnlockHighlight()
    end

    if self.currentPage == "production" then
        self:ApplyProductionTableLayout()
        local planOk, planError = pcall(
            function()
                JAP:BuildProductionPlan(true)
            end
        )

        if not planOk then
            self.productionRecipes = {}
            self.productionPlan = {}
            chat("Production plan contained invalid data and was cleared.")
            setStatus("Production queue was cleared after a data error.")
        end

        if self.recipesTabButton then self.recipesTabButton:UnlockHighlight() end
        if self.materialsTabButton then self.materialsTabButton:UnlockHighlight() end
        if self.missingTabButton then self.missingTabButton:UnlockHighlight() end
        if self.productionTabButton then self.productionTabButton:LockHighlight() end

        local i
        local controls = self.recipeControls or {}
        for i = 1, table.getn(controls) do controls[i]:Hide() end
        controls = self.materialControls or {}
        for i = 1, table.getn(controls) do controls[i]:Hide() end
        controls = self.missingControls or {}
        for i = 1, table.getn(controls) do controls[i]:Hide() end
        controls = self.productionControls or {}
        for i = 1, table.getn(controls) do controls[i]:Show() end




        self.columnHeaders[1]:SetText("Material")
        self.columnHeaders[2]:SetText("Used for")
        self.columnHeaders[3]:SetText("Need / Bag")
        self.columnHeaders[4]:SetText("Missing / Buy cost")

        local count = table.getn(self.productionPlan)
        for i = 1, self.visibleRows do
            local row = self.rows[i]
            local item = self.productionPlan[i + self.scrollOffset]
            row.recipe = nil
            row.material = nil
            row.missingRecipe = nil
            row.productionItem = item

            row:ClearAllPoints()
            row:SetPoint(
                "TOPLEFT",
                self.frame,
                "TOPLEFT",
                20,
                -208 - ((i - 1) * 27)
            )

            if item then
                row:Show()
                row.name:SetText(item.name)
                row.cost:SetText(self:JoinProductionRecipeNames(item.recipeNames))
                row.market:SetText(item.needed .. " / " .. item.inBags)

                local missingText = tostring(item.missing)

                if item.missing == 0 then
                    missingText = "0 / |cff55ff550c|r"
                elseif item.liveBuyPrice then
                    local stackText = ""
                    if item.liveBuyStack then
                        stackText = " x" .. item.liveBuyStack
                    end
                    missingText = missingText ..
                        " / |cff55ff55BUY " ..
                        moneyToText(item.liveBuyPrice) ..
                        stackText .. "|r"
                elseif self.productionBuyRunning
                   and self.scanMode == "production-buy" then
                    missingText = missingText ..
                        " / |cffffff66Fresh scan...|r"
                elseif item.estimatedCost then
                    missingText = missingText .. " / " ..
                        moneyToText(item.estimatedCost)

                    if item.purchaseOverage
                       and item.purchaseOverage > 0 then
                        missingText = missingText ..
                            " |cffffff66(+" ..
                            item.purchaseOverage .. ")|r"
                    end
                elseif item.estimateMode == "insufficient-auctions" then
                    missingText = missingText ..
                        " / |cffff5555Only " ..
                        (item.estimatedAvailableQuantity or 0) ..
                        " available|r"
                elseif self.scanActive
                   and self.scanMode == "production-materials" then
                    missingText = missingText .. " / |cffffff66Scanning...|r"
                else
                    missingText = missingText .. " / |cffff5555No price|r"
                end

                row.profit:SetText(missingText)
                row.highlight:Hide()
            else
                row:Hide()
            end
        end

        local maxOffset = math.max(0, count - self.visibleRows)
        if self.scrollOffset > maxOffset then self.scrollOffset = maxOffset end
        self.updatingScrollBar = true
        self.scrollBar:SetMinMaxValues(0, maxOffset)
        self.scrollBar:SetValue(self.scrollOffset)
        self.updatingScrollBar = false

        self:RefreshProductionTargetRecipeSelector()

        local recipes = self:GetProductionRecipes()
        local totalMissing = 0
        local estimated = 0
        local unknownPriceCount = 0

        for i = 1, table.getn(self.productionPlan) do
            local planItem = self.productionPlan[i]
            totalMissing = totalMissing + planItem.missing
            estimated = estimated + (planItem.estimatedCost or 0)

            if planItem.missing > 0 and not planItem.estimatedCost then
                unknownPriceCount = unknownPriceCount + 1
            end
        end

        local detailText = self:BuildProductionDetailText()
        detailText = detailText ..
            "\n\n|cffffd100Shopping summary:|r" ..
            "\nMissing material units: " .. totalMissing

        if unknownPriceCount == 0 then
            detailText = detailText ..
                "\nActual scanned stack total: |cff55ff55" ..
                moneyToText(estimated) .. "|r"
        else
            detailText = detailText ..
                "\nKnown-price subtotal: " .. moneyToText(estimated) ..
                "\n|cffff5555" .. unknownPriceCount ..
                " material cost(s) unavailable or insufficient.|r" ..
                "\nRun Scan All again before buying."
        end

        self:SetDetailText(detailText)

        if self.productionBuyRunning then
            setStatus(
                "Buy All active: " ..
                table.getn(self.productionBuyQueue or {}) ..
                " auction(s) remaining."
            )
        elseif self.productionCraftRunning then
            if self.productionCraftWaitingForClick
               and self.productionCraftCurrent then
                setStatus(
                    "Craft Next ready: " ..
                    self.productionCraftCurrent.productName ..
                    "; " ..
                    table.getn(self.productionCraftQueue or {}) ..
                    " recipe(s) remaining."
                )
            elseif self.productionCraftCurrent then
                local activeCraft =
                    self.productionCraftCurrent
                local activeKey =
                    normalizeKey(activeCraft.recipeName)
                local activeCreated =
                    self.productionCraftProgress[activeKey] or 0

                setStatus(
                    "Crafting: " ..
                    activeCraft.productName ..
                    " (" .. activeCreated .. "/" ..
                    tostring(self:GetProductionRecipeTarget(activeKey)) ..
                    "); " ..
                    table.getn(self.productionCraftQueue or {}) ..
                    " recipe(s) remaining."
                )
            end
        elseif self.productionPostRunning then
            setStatus(
                "Post All active: " ..
                table.getn(self.productionPostQueue or {}) ..
                " single-item auction(s) remaining."
            )
        else
            setStatus(
                "Production plan: " .. table.getn(recipes) ..
                " potion recipe(s), " .. totalMissing ..
                " missing material unit(s)."
            )
        end
        return
    end

    if self.productionTabButton then self.productionTabButton:UnlockHighlight() end

    if self.currentPage == "missing" then
        self:ApplyDefaultTableLayout()
        self:BuildMissingRecipes()
        if self.recipesTabButton then self.recipesTabButton:UnlockHighlight() end
        if self.materialsTabButton then self.materialsTabButton:UnlockHighlight() end
        if self.missingTabButton then self.missingTabButton:LockHighlight() end

        local i
        local controls = self.recipeControls or {}
        for i = 1, table.getn(controls) do controls[i]:Hide() end
        controls = self.materialControls or {}
        for i = 1, table.getn(controls) do controls[i]:Hide() end
        controls = self.missingControls or {}
        for i = 1, table.getn(controls) do controls[i]:Show() end
        controls = self.productionControls or {}
        for i = 1, table.getn(controls) do controls[i]:Hide() end

        local selectedMissing = self:GetSelectedMissingRecipes()
        if self.missingFavoriteActionButton then
            local allFavorite = table.getn(selectedMissing) > 0
            for i = 1, table.getn(selectedMissing) do
                if not self:IsMissingRecipeFavorite(selectedMissing[i]) then
                    allFavorite = false
                    break
                end
            end

            if allFavorite then
                self.missingFavoriteActionButton:SetText("Remove Favorite")
            else
                self.missingFavoriteActionButton:SetText("Add Favorite")
            end
        end

        if self.missingFavoritesViewButton then
            local favoriteCount = 0
            local favoriteKey, favoriteValue
            for favoriteKey, favoriteValue in pairs(self.missingRecipeFavorites or {}) do
                if favoriteValue then favoriteCount = favoriteCount + 1 end
            end

            if self.missingFavoritesOnly then
                self.missingFavoritesViewButton:SetText("Show All")
            else
                self.missingFavoritesViewButton:SetText(
                    "Favorites (" .. favoriteCount .. ")"
                )
            end
        end

        if self.missingScanAllButton then
            if self.missingFavoritesOnly then
                self.missingScanAllButton:SetText("Scan Favorites")
            else
                self.missingScanAllButton:SetText("Scan All Missing")
            end
        end

        self.columnHeaders[1]:SetText("Missing recipe")
        self.columnHeaders[2]:SetText("")
        self.columnHeaders[3]:SetText("Lowest price")
        self.columnHeaders[4]:SetText("14d history")

        local count = table.getn(self.missingRecipes)
        for i = 1, self.visibleRows do
            local row = self.rows[i]
            local item = self.missingRecipes[i + self.scrollOffset]
            row.recipe = nil
            row.material = nil
            row.missingRecipe = item
            if item then
                row:Show()
                if self:IsMissingRecipeFavorite(item) then
                    row.name:SetText("|cffffd100[F] |r" .. item.name)
                else
                    row.name:SetText(item.name)
                end
                row.cost:SetText("")
                row.market:SetText(moneyToText(getAnyStoredPrice(item.name)))
                row.profit:SetText(recipeScrollIndexText(item.name))
                if self:IsMissingRecipeSelected(item) then row.highlight:Show()
                else row.highlight:Hide() end
            else
                row:Hide()
            end
        end

        local maxOffset = math.max(0, count - self.visibleRows)
        if self.scrollOffset > maxOffset then self.scrollOffset = maxOffset end
        self.updatingScrollBar = true
        self.scrollBar:SetMinMaxValues(0, maxOffset)
        self.scrollBar:SetValue(self.scrollOffset)
        self.updatingScrollBar = false

        local selected = self:GetSelectedMissingRecipes()
        if table.getn(selected) == 1 then
            local item = selected[1]
            local h = getRecipeScrollHistory(item.name)
            local favoriteText = self:IsMissingRecipeFavorite(item)
                and "Yes" or "No"
            local text = "|cffffd100" .. item.name .. "|r\n\n" ..
                "Favorite: " .. favoriteText .. "\n" ..
                "Lowest AH price: " .. moneyToText(getAnyStoredPrice(item.name))
            if h then
                text = text .. "\n14-day index: " ..
                    string.format("%.0f%%", h.lastIndex or 100) ..
                    "\n14-day average: " .. moneyToText(h.referencePrice) ..
                    "\nSamples: " .. (h.samples or 1)
            end

            text = text .. "\n\n|cffffd100Required materials:|r\n" ..
                missingRecipeMaterialsText(item)

            self:SetDetailText(text)
        elseif table.getn(selected) > 1 then
            self:SetDetailText("|cffffd100" .. table.getn(selected) ..
                " missing recipes selected|r")
        else
            self:SetDetailText("|cffffd100Missing Recipes|r\n\n" ..
                "Recipes from the built-in Octo/Turtle catalog that were not found in your learned Alchemy list.")
        end
        local liveAlchemyOpen =
            TradeSkillFrame and TradeSkillFrame:IsVisible() and
            GetTradeSkillLine and
            lower(GetTradeSkillLine() or "") == "alchemy"

        if self.missingFavoritesOnly then
            if liveAlchemyOpen then
                setStatus("Showing " .. count ..
                    " favorite missing recipes; learned list refreshed live.")
            else
                setStatus("Showing " .. count ..
                    " favorite missing recipes from the last saved Alchemy list.")
            end
        else
            if liveAlchemyOpen then
                setStatus("Showing " .. count ..
                    " missing recipes; learned list refreshed live.")
            else
                setStatus("Showing " .. count ..
                    " missing recipes from the last saved Alchemy list.")
            end
        end
        return
    end

    if self.missingTabButton then self.missingTabButton:UnlockHighlight() end

    if self.currentPage == "materials" then
        self:ApplyDefaultTableLayout()
        self:BuildMaterialsList()

        if self.recipesTabButton then self.recipesTabButton:UnlockHighlight() end
        if self.materialsTabButton then self.materialsTabButton:LockHighlight() end

        local controls = self.recipeControls or {}
        local controlIndex
        for controlIndex = 1, table.getn(controls) do
            controls[controlIndex]:Hide()
        end

        local missingControls = self.missingControls or {}
        for controlIndex = 1, table.getn(missingControls) do missingControls[controlIndex]:Hide() end

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
                        " of 14-day average\n" ..
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

                self:SetDetailText(
                    "|cffffd100" .. material.name .. "|r\n\n" ..
                    "Lowest unit price: " .. priceText .. scanText .. "\n" ..
                    "Historical index: " .. historyText .. "\n" ..
                    "Used by: " .. material.usedBy .. " recipe(s)\n" ..
                    "Favorite: " .. favoriteText .. "\n\n" ..
                    "|cffffd100Used in recipes:|r\n" ..
                    table.concat(recipeLines, "\n")
                )
            elseif table.getn(selected) > 1 then
                self:SetDetailText(
                    "|cffffd100" .. table.getn(selected) .. " materials selected|r\n\n" ..
                    "Use Ctrl-click or Shift-click to add or remove materials."
                )
            else
                self:SetDetailText(
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

    local missingControls = self.missingControls or {}
    for controlIndex = 1, table.getn(missingControls) do
        missingControls[controlIndex]:Hide()
    end

    local productionControls = self.productionControls or {}
    for controlIndex = 1, table.getn(productionControls) do
        productionControls[controlIndex]:Hide()
    end

    if self.columnHeaders then
        self:ApplyDefaultTableLayout()

    self.columnHeaders[1]:SetText("Recipe")
        self.columnHeaders[2]:SetText("Craft cost")
        self.columnHeaders[3]:SetText("Lowest price")
        self.columnHeaders[4]:SetText("Profit / Last scan")
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
                        row.profit:SetText(
                            "|cff55ff55+" .. moneyToText(result.profit) .. "|r " ..
                            recipeLastScanShortText(recipe)
                        )
                    else
                        row.profit:SetText(
                            "|cffff5555" .. moneyToText(result.profit) .. "|r " ..
                            recipeLastScanShortText(recipe)
                        )
                    end
                else
                    row.profit:SetText(
                        "N/A " .. recipeLastScanShortText(recipe)
                    )
                end
            else
                row.cost:SetText("-")
                row.market:SetText("-")
                row.profit:SetText(
                    "- " .. recipeLastScanShortText(recipe)
                )
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
        self:SetDetailText("Open Alchemy and click 'Read Alchemy'.")
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

    local lastScanAt, lastScanProductsOnly, lastScanSource =
        getRecipeLastScanInfo(recipe)

    if lastScanAt then
        local scanModeText =
            lastScanProductsOnly and " (potion only)" or " (full recipe)"
        if lastScanSource == "stored-prices" then
            scanModeText = scanModeText .. " |cffaaaaaa(inferred)|r"
        end

        table.insert(lines,
            "|cffffd100Last scan:|r " ..
            formatScanTimestamp(lastScanAt, false) ..
            scanModeText)
    else
        table.insert(lines,
            "|cffffd100Last scan:|r |cffff5555Never|r")
    end

    table.insert(lines, "")
    table.insert(lines, "Ingredients:")

    local result = recipe.result
    local i
    for i = 1, table.getn(recipe.reagents) do
        local reagent = recipe.reagents[i]
        local text = "  " .. reagent.count .. "x " .. reagent.name .. ": "

        if isExcludedVial(reagent.name) then
            local vialPrice = getStaticVialUnitPrice(reagent.name)
            if vialPrice then
                text = text .. moneyToText(vialPrice) ..
                    " each |cffaaaaaa(static vendor price; not AH-scanned)|r"
            else
                text = text .. "|cffff5555unknown vial vendor price|r"
            end
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
                " of 14-day average")
            table.insert(lines,
                "14-day average: " ..
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

    self:SetDetailText(table.concat(lines, "\n"))
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


local function normalizeRecipeComparisonName(name)
    local value = lower(name or "")

    -- Remove item-type prefixes used by recipe scrolls.
    value = string.gsub(value, "^%s*recipe%s*:%s*", "")
    value = string.gsub(value, "^%s*formula%s*:%s*", "")
    value = string.gsub(value, "^%s*outline%s*:%s*", "")
    value = string.gsub(value, "^%s*pattern%s*:%s*", "")
    value = string.gsub(value, "^%s*plans%s*:%s*", "")
    value = string.gsub(value, "^%s*schematic%s*:%s*", "")

    -- Remove harmless formatting differences.
    value = string.gsub(value, "%s+", " ")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    value = string.gsub(value, "%s*%(%s*rank%s+%d+%s*%)%s*$", "")
    value = string.gsub(value, "%s*%[%s*rank%s+%d+%s*%]%s*$", "")

    return value
end

local function learnedRecipeKeyFromScrollName(scrollName)
    return normalizeRecipeComparisonName(scrollName)
end


function JAP:LoadMissingRecipeFavorites()
    self.missingRecipeFavorites = {}

    local saved = db().missingRecipeFavorites or {}
    local key, value

    for key, value in pairs(saved) do
        if value then
            self.missingRecipeFavorites[key] = true
        end
    end
end

function JAP:SaveMissingRecipeFavorites()
    local saved = {}
    local key, value

    for key, value in pairs(self.missingRecipeFavorites or {}) do
        if value then
            saved[key] = true
        end
    end

    db().missingRecipeFavorites = saved
end

function JAP:IsMissingRecipeFavorite(item)
    if not item then return false end
    return self.missingRecipeFavorites[item.key] == true
end

function JAP:ToggleMissingRecipeFavorite()
    local selected = self:GetSelectedMissingRecipes()
    if table.getn(selected) == 0 then
        chat("Select one or more missing recipes first.")
        return
    end

    local shouldFavorite = false
    local i
    for i = 1, table.getn(selected) do
        if not self:IsMissingRecipeFavorite(selected[i]) then
            shouldFavorite = true
            break
        end
    end

    for i = 1, table.getn(selected) do
        local item = selected[i]
        if shouldFavorite then
            self.missingRecipeFavorites[item.key] = true
        else
            self.missingRecipeFavorites[item.key] = nil
        end
    end

    self:SaveMissingRecipeFavorites()

    if shouldFavorite then
        chat(table.getn(selected) .. " missing recipe(s) added to favorites.")
    else
        chat(table.getn(selected) .. " missing recipe(s) removed from favorites.")
    end

    if self.missingFavoritesOnly and not shouldFavorite then
        self.selectedMissingRecipes = {}
        self.selectedMissingRecipe = nil
    end

    self:RefreshUI()
end

function JAP:SetMissingFavoritesOnly(enabled)
    self.missingFavoritesOnly = enabled and true or false
    db().settings.missingFavoritesOnly = self.missingFavoritesOnly
    self.selectedMissingRecipes = {}
    self.selectedMissingRecipe = nil
    self.scrollOffset = 0
    self:RefreshUI()
end

function JAP:BuildMissingRecipes()
    clearArray(self.missingRecipes)
    local learned = {}
    local i
    for i = 1, table.getn(self.recipes) do
        local recipe = self.recipes[i]
        learned[normalizeRecipeComparisonName(recipe.name)] = true
        if recipe.productName then
            learned[normalizeRecipeComparisonName(recipe.productName)] = true
        end
    end

    for i = 1, table.getn(MISSING_RECIPE_CATALOG) do
        local name = MISSING_RECIPE_CATALOG[i]
        local comparisonKey = learnedRecipeKeyFromScrollName(name)

        -- Handle common recipe-item versus learned-spell naming variants.
        local learnedMatch = learned[comparisonKey] == true
        if not learnedMatch then
            local withoutPotion = string.gsub(comparisonKey, "%s+potion$", "")
            local withoutElixir = string.gsub(comparisonKey, "^elixir%s+of%s+", "")
            if withoutPotion ~= comparisonKey and learned[withoutPotion] then
                learnedMatch = true
            elseif withoutElixir ~= comparisonKey and learned[withoutElixir] then
                learnedMatch = true
            end
        end

        if not learnedMatch then
            local item = {
                name = name,
                key = normalizeKey(name)
            }
            item.materials = getMissingRecipeMaterials(item)

            if not self.missingFavoritesOnly
               or self.missingRecipeFavorites[item.key] == true then
                table.insert(self.missingRecipes, item)
            end
        end
    end

    table.sort(self.missingRecipes, function(a, b)
        return lower(a.name) < lower(b.name)
    end)

    local visible = {}
    for i = 1, table.getn(self.missingRecipes) do
        local item = self.missingRecipes[i]
        if self.selectedMissingRecipes[item.key] then visible[item.key] = true end
    end
    self.selectedMissingRecipes = visible
    self.selectedMissingRecipe = nil
    for i = 1, table.getn(self.missingRecipes) do
        if self.selectedMissingRecipes[self.missingRecipes[i].key] then
            self.selectedMissingRecipe = self.missingRecipes[i]
            break
        end
    end
end

function JAP:IsMissingRecipeSelected(item)
    return item and self.selectedMissingRecipes[item.key] == true
end

function JAP:GetSelectedMissingRecipes()
    local result = {}
    local i
    for i = 1, table.getn(self.missingRecipes) do
        if self:IsMissingRecipeSelected(self.missingRecipes[i]) then
            table.insert(result, self.missingRecipes[i])
        end
    end
    return result
end

function JAP:SelectMissingRecipe(item, additive)
    if not item then return end
    if not additive then self.selectedMissingRecipes = {} end
    if additive and self.selectedMissingRecipes[item.key] then
        self.selectedMissingRecipes[item.key] = nil
    else
        self.selectedMissingRecipes[item.key] = true
    end
    local selected = self:GetSelectedMissingRecipes()
    self.selectedMissingRecipe = selected[1]
    self:RefreshUI()
end

function JAP:ScanSelectedMissingRecipes()
    self:BuildMissingRecipes()
    local selected = self:GetSelectedMissingRecipes()
    if table.getn(selected) == 0 then
        chat("Select one or more missing recipes first.")
        return
    end
    local items = {}
    local i
    for i = 1, table.getn(selected) do
        items[selected[i].key] = {
            name = selected[i].name,
            itemKind = "recipe-scroll"
        }
    end
    self:StartScan(items, "missing-selected")
end

function JAP:ScanAllMissingRecipes()
    self:BuildMissingRecipes()
    local items = {}
    local i
    for i = 1, table.getn(self.missingRecipes) do
        local item = self.missingRecipes[i]
        items[item.key] = {name = item.name, itemKind = "recipe-scroll"}
    end
    self:StartScan(items, "missing-all")
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


function JAP:ScheduleAutoReadAlchemy(delay)
    if self.autoReadingAlchemy then return end
    if self.productionCraftRunning
       or self.productionBuyRunning
       or self.productionPostRunning then
        return
    end
    if not TradeSkillFrame or not TradeSkillFrame:IsVisible() then return end

    local wait = delay or 0.50
    self.pendingAlchemyReadAt = GetTime() + wait
end

function JAP:TryAutoReadAlchemy()
    if self.autoReadingAlchemy then
        return false
    end

    if self.productionCraftRunning
       or self.productionBuyRunning
       or self.productionPostRunning then
        return false
    end

    if not TradeSkillFrame or not TradeSkillFrame:IsVisible() then
        return false
    end

    local skillName = GetTradeSkillLine and GetTradeSkillLine() or nil
    if skillName and lower(skillName) ~= "alchemy" then
        return false
    end

    self.autoReadingAlchemy = true
    self.pendingAlchemyReadAt = nil
    local success = self:ReadAlchemy(true)
    self.autoReadingAlchemy = false
    self.lastAutoAlchemyRead = GetTime()
    return success
end

function JAP:ProcessPendingAlchemyRead()
    if not self.pendingAlchemyReadAt then return end
    if GetTime() < self.pendingAlchemyReadAt then return end

    self.pendingAlchemyReadAt = nil
    self:TryAutoReadAlchemy()
end


local function getItemNameFromLink(link)
    if not link then return nil end

    -- Vanilla item links contain the visible name inside square brackets.
    local startPos, endPos, itemName =
        string.find(link, "%[([^%]]+)%]")

    if itemName then
        return itemName
    end

    -- Fallback for clients that return a cached name via GetItemInfo.
    if GetItemInfo then
        return GetItemInfo(link)
    end

    return nil
end

local function getBagItemCountByName(itemName)
    if not itemName then return 0 end

    local wanted = normalizeKey(itemName)
    local total = 0
    local bag

    for bag = 0, 4 do
        local slots = GetContainerNumSlots and GetContainerNumSlots(bag) or 0
        local slot

        for slot = 1, slots do
            local link =
                GetContainerItemLink and
                GetContainerItemLink(bag, slot) or nil

            if link then
                local bagItemName = getItemNameFromLink(link)

                if bagItemName
                   and normalizeKey(bagItemName) == wanted then
                    local texture, count =
                        GetContainerItemInfo(bag, slot)

                    total = total + (count or 1)
                end
            end
        end
    end

    return total
end



function JAP:GetProductionStatusKey()
    return self.currentProductionTemplateName or "__unsaved__"
end

function JAP:GetProductionTemplateStatus(create)
    local key = self:GetProductionStatusKey()
    local store = db().productionTemplateStatus

    if create and not store[key] then
        store[key] = {
            craftProgress = {},
            craftCompleted = {},
            postProgress = {},
            postCompleted = {}
        }
    end

    return store[key]
end

function JAP:LoadProductionTemplateStatus()
    local status = self:GetProductionTemplateStatus(false)

    self.productionCraftProgress = {}
    self.productionCraftCompleted = {}
    self.productionCraftSkipped = {}
    self.productionPostProgress = {}
    self.productionPostCompleted = {}

    if not status then return end

    local key, value
    for key, value in pairs(status.craftProgress or {}) do
        self.productionCraftProgress[key] = value
    end
    for key, value in pairs(status.craftCompleted or {}) do
        self.productionCraftCompleted[key] = value
    end
    for key, value in pairs(status.craftSkipped or {}) do
        self.productionCraftSkipped[key] = value
    end
    for key, value in pairs(status.postProgress or {}) do
        self.productionPostProgress[key] = value
    end
    for key, value in pairs(status.postCompleted or {}) do
        self.productionPostCompleted[key] = value
    end
end

function JAP:SaveProductionTemplateStatus()
    local status = self:GetProductionTemplateStatus(true)
    status.craftProgress = self.productionCraftProgress or {}
    status.craftCompleted = self.productionCraftCompleted or {}
    status.craftSkipped = self.productionCraftSkipped or {}
    status.postProgress = self.productionPostProgress or {}
    status.postCompleted = self.productionPostCompleted or {}
    status.updatedAt = time()
end

function JAP:ResetProductionTemplateStatus()
    local key = self:GetProductionStatusKey()
    db().productionTemplateStatus[key] = {
        craftProgress = {},
        craftCompleted = {},
        postProgress = {},
        postCompleted = {},
        updatedAt = time()
    }

    self.productionCraftProgress = {}
    self.productionCraftCompleted = {}
    self.productionCraftSkipped = {}
    self.productionBuySkipped = {}
    self.productionPostProgress = {}
    self.productionPostCompleted = {}

    setStatus("Production status reset for this template.")
    chat(
        "Production status reset for template '" ..
        tostring(self.currentProductionTemplateName or "unsaved") .. "'."
    )

    self:RefreshUI()
end

function JAP:RefreshProductionTemplateNames()
    clearArray(self.productionTemplateNames)

    local name, template
    for name, template in pairs(db().productionTemplates or {}) do
        if type(name) == "string" and template then
            table.insert(self.productionTemplateNames, name)
        end
    end

    table.sort(self.productionTemplateNames, function(a, b)
        return lower(a) < lower(b)
    end)

    self.currentProductionTemplateIndex = 0
    if self.currentProductionTemplateName then
        local i
        for i = 1, table.getn(self.productionTemplateNames) do
            if self.productionTemplateNames[i] ==
               self.currentProductionTemplateName then
                self.currentProductionTemplateIndex = i
                break
            end
        end
    end
end

function JAP:GetProductionTemplateRecipeKeys()
    local keys = {}
    local key, enabled

    for key, enabled in pairs(self.productionRecipes or {}) do
        if enabled then
            table.insert(keys, key)
        end
    end

    table.sort(keys)
    return keys
end

function JAP:GetProductionRecipeTarget(recipeKey)
    local value = self.productionRecipeTargets and self.productionRecipeTargets[recipeKey]
    value = tonumber(value)
    if value == nil then value = self.productionTargetAmount or 5 end
    value = math.floor(value)
    if value < 0 then value = 0 end
    if value > 999 then value = 999 end
    return value
end

function JAP:SetProductionRecipeTarget(recipeKey, amount)
    if not recipeKey then return end
    amount = tonumber(amount)
    if not amount then return end
    amount = math.floor(amount)
    if amount < 0 then amount = 0 end
    if amount > 999 then amount = 999 end

    self.productionRecipeTargets = self.productionRecipeTargets or {}
    self.productionRecipeTargets[recipeKey] = amount

    -- Keep an already-saved active template synchronized immediately.
    if self.currentProductionTemplateName then
        local template = db().productionTemplates[self.currentProductionTemplateName]
        if template then
            template.recipeTargets = template.recipeTargets or {}
            template.recipeTargets[recipeKey] = amount
            template.updatedAt = time()
        end
    end

    self:BuildProductionPlan(true)
    self:RefreshProductionTargetRecipeSelector()
    self:RefreshUI()
end

function JAP:GetProductionTargetRecipeList()
    return self:GetProductionRecipes()
end

function JAP:RefreshProductionTargetRecipeSelector()
    local recipes = self:GetProductionTargetRecipeList()
    local count = table.getn(recipes)

    if count == 0 then
        self.productionTargetRecipeIndex = 1
        if self.productionTargetRecipeName then
            self.productionTargetRecipeName:SetText("No recipe")
        end
        if self.productionTargetEdit then
            self.productionTargetEdit:SetText("0")
        end
        return
    end

    local index = self.productionTargetRecipeIndex or 1
    if index < 1 then index = count end
    if index > count then index = 1 end
    self.productionTargetRecipeIndex = index

    local recipe = recipes[index]
    local key = recipe.key or normalizeKey(recipe.name)
    recipe.key = key

    if self.productionTargetRecipeName then
        self.productionTargetRecipeName:SetText(truncateUiText(recipe.productName or recipe.name, 24))
    end
    if self.productionTargetEdit then
        self.productionTargetEdit:SetText(tostring(self:GetProductionRecipeTarget(key)))
    end
end

function JAP:CycleProductionTargetRecipe(direction)
    local recipes = self:GetProductionTargetRecipeList()
    local count = table.getn(recipes)
    if count == 0 then
        self:RefreshProductionTargetRecipeSelector()
        return
    end

    -- Save the amount currently typed into the edit box before changing
    -- recipes. This makes < and > behave like an implicit Enter/Set Amount.
    self:SetSelectedProductionRecipeTarget()

    -- SetSelectedProductionRecipeTarget refreshes the UI but keeps the
    -- currently selected recipe index, so we can safely move afterwards.
    recipes = self:GetProductionTargetRecipeList()
    count = table.getn(recipes)
    if count == 0 then return end

    local index = (self.productionTargetRecipeIndex or 1) + direction
    if index < 1 then index = count end
    if index > count then index = 1 end
    self.productionTargetRecipeIndex = index
    self:RefreshProductionTargetRecipeSelector()
end

function JAP:SetSelectedProductionRecipeTarget()
    local recipes = self:GetProductionTargetRecipeList()
    local recipe = recipes[self.productionTargetRecipeIndex or 1]
    if not recipe or not self.productionTargetEdit then return end
    local key = recipe.key or normalizeKey(recipe.name)
    self:SetProductionRecipeTarget(key, self.productionTargetEdit:GetNumber())
end

function JAP:SaveProductionTemplate()
    local name = nil

    if self.productionTemplateEdit then
        name = self.productionTemplateEdit:GetText()
    end

    name = name or self.currentProductionTemplateName or ""
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")

    if name == "" then
        chat("Enter a template name first.")
        return
    end

    local recipeKeys = self:GetProductionTemplateRecipeKeys()
    if table.getn(recipeKeys) == 0 then
        chat("Add at least one recipe to Production first.")
        return
    end

    local recipeTargets = {}
    local targetIndex
    for targetIndex = 1, table.getn(recipeKeys) do
        local recipeKey = recipeKeys[targetIndex]
        recipeTargets[recipeKey] = self:GetProductionRecipeTarget(recipeKey)
    end

    db().productionTemplates[name] = {
        name = name,
        targetAmount = self.productionTargetAmount or 5,
        recipeKeys = recipeKeys,
        recipeTargets = recipeTargets,
        updatedAt = time()
    }

    self.currentProductionTemplateName = name
    db().currentProductionTemplateName = name
    self:RefreshProductionTemplateNames()
    self:SaveProductionTemplateStatus()
    self:LoadProductionTemplateStatus()

    if self.productionTemplateEdit then
        self.productionTemplateEdit:SetText(name)
    end

    chat(
        "Production template '" .. name ..
        "' saved with " .. table.getn(recipeKeys) ..
        " recipe(s) with individual amounts."
    )

    self:RefreshUI()
end

function JAP:LoadProductionTemplate(name)
    if not name or name == "" then
        chat("No Production template selected.")
        return
    end

    local template = db().productionTemplates[name]
    if not template then
        chat("Production template not found: " .. name)
        return
    end

    self.productionRecipes = {}

    local i
    for i = 1, table.getn(template.recipeKeys or {}) do
        self.productionRecipes[template.recipeKeys[i]] = true
    end

    self.productionTargetAmount =
        tonumber(template.targetAmount) or 5
    self.productionRecipeTargets = {}

    local targetKey, targetValue
    for targetKey, targetValue in pairs(template.recipeTargets or {}) do
        self.productionRecipeTargets[targetKey] = tonumber(targetValue) or self.productionTargetAmount
    end

    -- Old templates transparently inherit their former global amount.
    local recipeTargetIndex
    for recipeTargetIndex = 1, table.getn(template.recipeKeys or {}) do
        local recipeKey = template.recipeKeys[recipeTargetIndex]
        if self.productionRecipeTargets[recipeKey] == nil then
            self.productionRecipeTargets[recipeKey] = self.productionTargetAmount
        end
    end
    self.productionTargetRecipeIndex = 1

    self.currentProductionTemplateName = name
    db().currentProductionTemplateName = name
    self:RefreshProductionTemplateNames()

    self:RefreshProductionTargetRecipeSelector()

    if self.productionTemplateEdit then
        self.productionTemplateEdit:SetText(name)
    end

    self.scrollOffset = 0
    self:BuildProductionPlan(true)
    self:RefreshUI()

    chat("Loaded Production template '" .. name .. "'.")
end

function JAP:LoadProductionTemplateFromField()
    local name = self.productionTemplateEdit
        and self.productionTemplateEdit:GetText() or nil

    if name and db().productionTemplates[name] then
        self:LoadProductionTemplate(name)
    elseif self.currentProductionTemplateName then
        self:LoadProductionTemplate(
            self.currentProductionTemplateName
        )
    else
        chat("Choose a saved template with Previous/Next first.")
    end
end

function JAP:CycleProductionTemplate(direction)
    self:RefreshProductionTemplateNames()

    local count = table.getn(self.productionTemplateNames)
    if count == 0 then
        chat("No Production templates have been saved yet.")
        return
    end

    local index = self.currentProductionTemplateIndex or 0

    if direction < 0 then
        index = index - 1
        if index < 1 then index = count end
    else
        index = index + 1
        if index > count then index = 1 end
    end

    local name = self.productionTemplateNames[index]
    self.currentProductionTemplateIndex = index
    self:LoadProductionTemplate(name)
end


function JAP:ShowProductionTemplates()
    self:RefreshProductionTemplateNames()

    local lines = {}
    local count = table.getn(self.productionTemplateNames)

    table.insert(lines, "|cffffd100Saved Production Templates|r")
    table.insert(lines, "")
    table.insert(lines, "Saved templates: " .. count)
    table.insert(lines, "")

    if count == 0 then
        table.insert(lines, "No templates saved yet.")
        table.insert(lines, "")
        table.insert(lines, "Enter a name and press Save / Update.")
    else
        local i
        for i = 1, count do
            local name = self.productionTemplateNames[i]

            if name == self.currentProductionTemplateName then
                table.insert(
                    lines,
                    "|cff55ff55> " .. name .. "  (loaded)|r"
                )
            else
                table.insert(lines, "  " .. name)
            end
        end

        table.insert(lines, "")
        table.insert(
            lines,
            "|cffaaaaaaUse < and > to switch between templates.|r"
        )
    end

    self:SetDetailText(table.concat(lines, "\n"))
end

function JAP:DeleteProductionTemplate()
    local name = self.currentProductionTemplateName

    if self.productionTemplateEdit then
        local fieldName = self.productionTemplateEdit:GetText()
        if fieldName and fieldName ~= "" then
            name = fieldName
        end
    end

    if not name or not db().productionTemplates[name] then
        chat("No saved Production template selected.")
        return
    end

    db().productionTemplates[name] = nil
    db().productionTemplateStatus[name] = nil

    if self.currentProductionTemplateName == name then
        self.currentProductionTemplateName = nil
        db().currentProductionTemplateName = nil
    end

    self:RefreshProductionTemplateNames()

    if self.productionTemplateEdit then
        self.productionTemplateEdit:SetText("")
    end

    chat("Deleted Production template '" .. name .. "'.")
    self:RefreshUI()
end

function JAP:LoadSavedProductionTemplateState()
    self:RefreshProductionTemplateNames()

    local savedName = db().currentProductionTemplateName
    if savedName and db().productionTemplates[savedName] then
        self:LoadProductionTemplate(savedName)
    end
end

function JAP:AddSelectedRecipesToProduction()
    local selected = self:GetSelectedRecipes()
    if table.getn(selected) == 0 then
        chat("Select one or more learned recipes first.")
        return
    end

    local added = 0
    local skipped = 0
    local i

    for i = 1, table.getn(selected) do
        local recipe = selected[i]
        local recipeKey = recipe and (recipe.key or normalizeKey(recipe.name))

        if recipe and recipeKey and recipe.name then
            recipe.key = recipeKey
            self.productionRecipes[recipeKey] = true
            self.productionRecipeTargets = self.productionRecipeTargets or {}
            if self.productionRecipeTargets[recipeKey] == nil then
                self.productionRecipeTargets[recipeKey] = self.productionTargetAmount or 5
            end
            added = added + 1
        else
            skipped = skipped + 1
        end
    end

    if added > 0 then
        chat(added .. " recipe(s) added to Production.")
    end

    if skipped > 0 then
        chat(skipped .. " invalid recipe(s) were skipped.")
    end

    self:SetPage("production")
end

function JAP:ClearProduction()
    self.productionRecipes = {}
    self.productionPlan = {}
    self.productionRecipeTargets = {}
    self.productionTargetRecipeIndex = 1
    self.currentProductionTemplateName = nil
    db().currentProductionTemplateName = nil

    if self.productionTemplateEdit then
        self.productionTemplateEdit:SetText("")
    end

    self:RefreshProductionTemplateNames()
    self:RefreshUI()
end

function JAP:SetProductionTargetAmount(amount)
    amount = tonumber(amount)
    if not amount then return end
    amount = math.floor(amount)
    if amount < 1 then amount = 1 end
    if amount > 999 then amount = 999 end
    self.productionTargetAmount = amount

    local success = pcall(
        function()
            JAP:BuildProductionPlan()
        end
    )

    if not success then
        self.productionRecipes = {}
        self.productionPlan = {}
        chat("Invalid Production data was cleared. Please re-read Alchemy.")
        self:RefreshUI()
    end
end

function JAP:GetProductionRecipes()
    local result = {}
    local validKeys = {}
    local i

    for i = 1, table.getn(self.recipes or {}) do
        local recipe = self.recipes[i]
        if recipe and recipe.name then
            local recipeKey = recipe.key or normalizeKey(recipe.name)
            recipe.key = recipeKey
            validKeys[recipeKey] = true

            if self.productionRecipes[recipeKey] then
                table.insert(result, recipe)
            end
        end
    end

    -- Remove stale or malformed queue entries so they cannot break the page
    -- every time it is opened.
    local queuedKey, queuedValue
    for queuedKey, queuedValue in pairs(self.productionRecipes or {}) do
        if not queuedValue or not validKeys[queuedKey] then
            self.productionRecipes[queuedKey] = nil
        end
    end

    return result
end


function JAP:JoinProductionRecipeNames(recipeNames)
    if not recipeNames or table.getn(recipeNames) == 0 then
        return "-"
    end

    local text = ""
    local i
    for i = 1, table.getn(recipeNames) do
        if i > 1 then text = text .. ", " end
        text = text .. recipeNames[i]
    end

    if string.len(text) > 34 then
        text = string.sub(text, 1, 31) .. "..."
    end

    return text
end

function JAP:BuildProductionDetailText()
    local recipes = self:GetProductionRecipes()
    local plan = self.productionPlan or {}
    local lines = {}

    local function add(line)
        table.insert(lines, line)
    end

    add("|cffffd100Production Queue|r")
    if self.currentProductionTemplateName then
        add("|cffaaaaaaTemplate: " .. self.currentProductionTemplateName .. "|r")
    else
        add("|cffaaaaaaTemplate: unsaved|r")
    end

    self:RefreshProductionTemplateNames()
    add(
        "|cffaaaaaaSaved templates: " ..
        table.getn(self.productionTemplateNames) .. "|r"
    )
    add("")

    if table.getn(recipes) == 0 then
        add("No recipes selected.")
        add("")
        add("Select learned recipes on the")
        add("Recipes page and press Add to Production.")
        return table.concat(lines, "\n")
    end

    local totalTarget = 0
    local totalCreated = 0
    local totalRemaining = 0
    local craftDone = 0
    local craftActive = 0
    local craftBlocked = 0
    local craftOpen = 0
    local postDoneCount = 0
    local postPartialCount = 0
    local postOpenCount = 0
    local missingMaterialTypes = 0
    local missingMaterialUnits = 0
    local estimatedBuyTotal = 0
    local estimatedPartialCount = 0
    local estimatedUnknownCount = 0

    local i
    for i = 1, table.getn(recipes) do
        local recipe = recipes[i]
        local recipeKey = recipe.key or normalizeKey(recipe.name)
        local target = self:GetProductionRecipeTarget(recipeKey)
        local progress = self.productionCraftProgress[recipeKey] or 0
        local completed = self.productionCraftCompleted[recipeKey] == true
        local skippedCraft = self.productionCraftSkipped[recipeKey]
        local isCurrent = self.productionCraftCurrent
            and self.productionCraftCurrent.recipeName == recipe.name

        if completed or progress >= target then
            progress = math.max(progress, target)
            craftDone = craftDone + 1
        elseif isCurrent then
            craftActive = craftActive + 1
        elseif skippedCraft then
            craftBlocked = craftBlocked + 1
        else
            craftOpen = craftOpen + 1
        end

        local shownCreated = math.min(progress, target)
        local remaining = math.max(0, target - shownCreated)
        totalTarget = totalTarget + target
        totalCreated = totalCreated + shownCreated
        totalRemaining = totalRemaining + remaining

        local postProgress = self.productionPostProgress[recipeKey]
        local postedItems = postProgress and postProgress.postedItems or 0
        if self.productionPostCompleted[recipeKey] or postedItems >= target then
            postDoneCount = postDoneCount + 1
        elseif postedItems > 0 then
            postPartialCount = postPartialCount + 1
        else
            postOpenCount = postOpenCount + 1
        end
    end

    for i = 1, table.getn(plan) do
        local item = plan[i]
        if item.missing and item.missing > 0 then
            missingMaterialTypes = missingMaterialTypes + 1
            missingMaterialUnits = missingMaterialUnits + item.missing

            if item.estimatedCost then
                estimatedBuyTotal = estimatedBuyTotal + item.estimatedCost
            elseif item.estimateMode == "insufficient-auctions" then
                estimatedPartialCount = estimatedPartialCount + 1
                estimatedBuyTotal =
                    estimatedBuyTotal + (item.estimatedPartialCost or 0)
            else
                estimatedUnknownCount = estimatedUnknownCount + 1
            end
        end
    end

    add("|cffffd100Summary:|r")
    add(
        "Recipes: " .. table.getn(recipes) ..
        "  |  Target items: " .. totalTarget
    )
    add(
        "Crafted: " .. totalCreated ..
        "  |  Remaining: " .. totalRemaining
    )
    add(
        "Missing materials: " .. missingMaterialUnits ..
        " across " .. missingMaterialTypes .. " item(s)"
    )

    if estimatedPartialCount == 0 and estimatedUnknownCount == 0 then
        add("Estimated buy total: " .. moneyToText(estimatedBuyTotal))
    else
        local estimateLine =
            "Known buy subtotal: " .. moneyToText(estimatedBuyTotal)

        if estimatedPartialCount > 0 then
            estimateLine = estimateLine ..
                "  |  " .. estimatedPartialCount ..
                " item(s) not fully covered"
        end

        if estimatedUnknownCount > 0 then
            estimateLine = estimateLine ..
                "  |  " .. estimatedUnknownCount ..
                " item(s) unpriced"
        end

        add(estimateLine)
    end

    add(
        "AH settings: stack " .. (self.productionPostStackSize or 1) ..
        "  |  " .. (self.productionPostDuration or 6) ..
        "h  |  Sound: " ..
        ((self.completionSounds and "On") or "Off")
    )
    add("")

    add("|cffffd100Queue overview:|r")
    add(
        "Crafting: " .. craftDone .. " done  |  " ..
        craftActive .. " active  |  " ..
        craftBlocked .. " blocked  |  " ..
        craftOpen .. " open"
    )
    add(
        "Auction House: " .. postDoneCount .. " posted  |  " ..
        postPartialCount .. " partial  |  " ..
        postOpenCount .. " open"
    )

    if self.productionCraftCurrent then
        add(
            "Current craft: " ..
            (self.productionCraftCurrent.productName or
                self.productionCraftCurrent.recipeName or "unknown")
        )
    end

    if self.productionPostPending then
        add(
            "Current post: " ..
            tostring(self.productionPostPending.name or "unknown")
        )
    end

    add("")
    add("|cffffd100Recipe status:|r")

    for i = 1, table.getn(recipes) do
        local recipe = recipes[i]
        local recipeKey = recipe.key or normalizeKey(recipe.name)
        local target = self:GetProductionRecipeTarget(recipeKey)
        local productName = recipe.productName or recipe.name
        local progress = self.productionCraftProgress[recipeKey] or 0
        local completed = self.productionCraftCompleted[recipeKey] == true
        local skippedCraft = self.productionCraftSkipped[recipeKey]
        local status = "|cffffffffOpen|r"

        if completed or progress >= target then
            status = "|cff55ff55Done|r"
            progress = math.max(progress, target)
        elseif self.productionCraftCurrent
           and self.productionCraftCurrent.recipeName == recipe.name then
            skippedCraft = nil
            if self.productionCraftWaitingForClick then
                status = "|cffffff55Ready - click Craft Next|r"
            elseif self.productionCraftWaitingForBags then
                status = "|cffffaa00Crafting|r"
            else
                status = "|cffffff55Queued|r"
            end
        elseif skippedCraft then
            status = "|cffff5555Blocked|r"
        end

        local shownCreated = math.min(progress, target)
        local remaining = math.max(0, target - shownCreated)
        local postProgress = self.productionPostProgress[recipeKey]
        local postedItems = postProgress and postProgress.postedItems or 0
        local remainingToPost = math.max(0, target - postedItems)

        add(status .. "  " .. productName)
        add(
            "  Craft: " .. shownCreated .. "/" .. target ..
            "  |  Remaining: " .. remaining
        )
        add(
            "  AH: " .. postedItems .. "/" .. target ..
            " posted  |  Remaining: " .. remainingToPost
        )

        if skippedCraft
           and not completed
           and not (
                self.productionCraftCurrent
                and self.productionCraftCurrent.recipeName == recipe.name
           ) then
            add(
                "  |cffff7777Missing: " ..
                tostring(skippedCraft.details or
                    skippedCraft.reason or "materials") ..
                "|r"
            )
        end
    end

    add("")
    add("|cffffd100Auction House details:|r")

    for i = 1, table.getn(recipes) do
        local recipe = recipes[i]
        local recipeKey = recipe.key or normalizeKey(recipe.name)
        local target = self:GetProductionRecipeTarget(recipeKey)
        local productName = recipe.productName or recipe.name
        local postProgress = self.productionPostProgress[recipeKey]
        local postedItems = postProgress and postProgress.postedItems or 0
        local remainingToPost = math.max(0, target - postedItems)

        if self.productionPostCompleted[recipeKey]
           or postedItems >= target then
            add("|cff55ff55Posted|r  " .. productName)
        elseif postedItems > 0 then
            add("|cffffff55Partly posted|r  " .. productName)
        else
            add("|cffffffffOpen|r  " .. productName)
        end

        add(
            "  Posted: " .. postedItems .. "/" .. target ..
            "  |  Remaining: " .. remainingToPost
        )

        if postProgress and postProgress.auctions
           and table.getn(postProgress.auctions) > 0 then
            local auctionIndex
            for auctionIndex = 1, table.getn(postProgress.auctions) do
                local auction = postProgress.auctions[auctionIndex]
                add(
                    "  - " .. auction.stackSize .. "x @ " ..
                    moneyToText(auction.unitBuyout) ..
                    " each = " ..
                    moneyToText(auction.totalBuyout)
                )
            end
        end
    end

    local skippedPurchaseCount = 0
    local skippedPurchaseKey, skippedPurchase

    for skippedPurchaseKey, skippedPurchase in
        pairs(self.productionBuySkipped or {}) do
        skippedPurchaseCount = skippedPurchaseCount + 1
    end

    if skippedPurchaseCount > 0 then
        add("")
        add("|cffffd100Skipped purchases:|r")

        for skippedPurchaseKey, skippedPurchase in
            pairs(self.productionBuySkipped or {}) do
            add(
                "|cffff5555Skipped|r  " ..
                tostring(skippedPurchase.name or skippedPurchaseKey)
            )
            add(
                "  " ..
                tostring(skippedPurchase.reason or "unknown reason")
            )
        end
    end

    add("")
    add("|cffffd100Recipe breakdown:|r")

    for i = 1, table.getn(recipes) do
        local recipe = recipes[i]
        local recipeKey = recipe.key or normalizeKey(recipe.name)
        local target = self:GetProductionRecipeTarget(recipeKey)
        local productName = recipe.productName or recipe.name
        local produced = recipe.minMade or 1
        if produced < 1 then produced = 1 end
        local crafts = math.ceil(target / produced)

        add("")
        add("|cffffff66" .. target .. "x " .. productName .. "|r")

        local reagents = recipe.reagents or {}
        local reagentCount = table.getn(reagents)

        if reagentCount == 0 then
            add(
                "  - |cffff5555No reagent data available; re-read Alchemy.|r"
            )
        else
            local reagentIndex
            for reagentIndex = 1, reagentCount do
                local reagent = reagents[reagentIndex]
                if reagent and reagent.name then
                    local requiredAmount = (reagent.count or 1) * crafts
                    add("  - " .. requiredAmount .. "x " .. reagent.name)
                end
            end
        end
    end

    add("")
    add("|cffffd100Purchase rules:|r")
    add("Only missing bag quantities are purchased.")
    add("Abort above 110% of planned total.")
    add(
        "Post stacks: " ..
        tostring(self.productionPostStackSize or 1) ..
        " item(s), " ..
        tostring(self.productionPostDuration or 6) ..
        " hours."
    )

    return table.concat(lines, "\n")
end

function JAP:BuildProductionPlan(noRefresh)
    clearArray(self.productionPlan)

    local recipes = self:GetProductionRecipes()
    local required = {}
    local i

    for i = 1, table.getn(recipes) do
        local recipe = recipes[i]
        local recipeKey = recipe.key or normalizeKey(recipe.name)
        local target = self:GetProductionRecipeTarget(recipeKey)
        local produced = recipe.minMade or 1
        if produced < 1 then produced = 1 end
        local crafts = math.ceil(target / produced)

        local reagents = recipe.reagents or {}
        local reagentIndex

        for reagentIndex = 1, table.getn(reagents) do
            local reagent = reagents[reagentIndex]

            if reagent and reagent.name then
                local key = normalizeKey(reagent.name)

                if key and key ~= "" then
                    if not required[key] then
                        required[key] = {
                            name = reagent.name,
                            key = key,
                            needed = 0,
                            itemId = reagent.itemId,
                            recipes = 0,
                            recipeNames = {},
                            neededByRecipe = {}
                        }
                    end

                    local amountForRecipe = (reagent.count or 1) * crafts
                    required[key].needed =
                        required[key].needed + amountForRecipe

                    local recipeDisplayName =
                        recipe.productName or recipe.name or "Unknown recipe"

                    if not required[key].neededByRecipe[recipeDisplayName] then
                        required[key].neededByRecipe[recipeDisplayName] = 0
                        table.insert(
                            required[key].recipeNames,
                            recipeDisplayName
                        )
                        required[key].recipes =
                            required[key].recipes + 1
                    end

                    required[key].neededByRecipe[recipeDisplayName] =
                        required[key].neededByRecipe[recipeDisplayName] +
                        amountForRecipe
                end
            end
        end
    end

    local key, item
    for key, item in pairs(required) do
        item.inBags = getBagItemCountByName(item.name)
        item.missing = math.max(0, item.needed - item.inBags)

        if isExcludedVial(item.name) then
            local auctionPrice = getAnyStoredPrice(item.name)

            if auctionPrice then
                item.unitPrice = auctionPrice
                item.source = "auction"
                item.hasScannedPrice = true
            else
                item.unitPrice = getStaticVialUnitPrice(item.name)
                item.source = "vendor-fallback"
                item.hasScannedPrice = false
            end
        else
            item.unitPrice = getAnyStoredPrice(item.name)
            item.source = "auction"
            item.hasScannedPrice = item.unitPrice ~= nil
        end

        if item.missing > 0 then
            local priceEntry = db().prices[item.key]
            local listings =
                priceEntry and priceEntry.purchaseListings or nil

            if listings and table.getn(listings) > 0 then
                local exactCost, purchaseQuantity, auctionsUsed, enough =
                    calculateWholeStackPurchase(listings, item.missing)

                item.purchaseQuantity = purchaseQuantity
                item.purchaseOverage =
                    math.max(0, purchaseQuantity - item.missing)
                item.purchaseAuctions = auctionsUsed
                item.purchaseCoverageComplete = enough

                if enough then
                    item.estimatedCost = exactCost
                    item.estimateMode = "whole-stacks"
                else
                    item.estimatedPartialCost = exactCost
                    item.estimatedAvailableQuantity = purchaseQuantity
                    item.estimateMode = "insufficient-auctions"
                end
            elseif item.unitPrice then
                item.estimatedCost = item.unitPrice * item.missing
                item.estimateMode = "unit-fallback"
            end
        end

        item.liveBuyPrice = self.productionLiveBuyPrices[item.key]
        item.liveBuyStack = self.productionLiveBuyStacks[item.key]

        table.insert(self.productionPlan, item)
    end

    table.sort(self.productionPlan, function(a, b)
        local aName = a and a.name or ""
        local bName = b and b.name or ""
        return lower(aName) < lower(bName)
    end)

    if not noRefresh then
        self.scrollOffset = 0
        self:RefreshUI()
    end
end

function JAP:ScanProductionMaterials()
    self:BuildProductionPlan(true)

    local items = {}
    local i
    for i = 1, table.getn(self.productionPlan) do
        local material = self.productionPlan[i]
        if material.missing > 0 then
            items[material.key] = {
                name = material.name,
                itemId = material.itemId,
                itemKind = "reagent",
                needed = material.missing
            }
        end
    end

    self:StartScan(items, "production-materials")
end

function JAP:LoadFreshProductionBuyCandidates()
    local maxAge = self.productionBuyScanReuseSeconds or 20
    local currentTime = time()
    local reusable = {}
    local reusedMaterials = 0
    local i

    for i = 1, table.getn(self.productionPlan or {}) do
        local material = self.productionPlan[i]

        if material and material.missing and material.missing > 0 then
            local entry = db().prices[material.key]
            local listings = entry and entry.purchaseListings or nil
            local savedAt =
                entry and
                (entry.purchaseListingsSavedAt or entry.savedAt) or nil

            if not listings
               or table.getn(listings) == 0
               or not savedAt
               or (currentTime - savedAt) > maxAge then
                return false, reusedMaterials
            end

            reusable[material.key] = listings
            reusedMaterials = reusedMaterials + 1
        end
    end

    if reusedMaterials == 0 then
        return false, 0
    end

    self.productionBuyCandidates = reusable
    return true, reusedMaterials
end

function JAP:ProductionBuyAll()
    if self.productionBuyRunning or self.scanRunning then
        chat("A scan or purchase is already running.")
        return
    end

    if not AuctionFrame or not AuctionFrame:IsVisible() then
        chat("Open the Auction House first.")
        return
    end

    self:BuildProductionPlan(true)
    self.productionBuyCandidates = {}
    self.productionLiveBuyPrices = {}
    self.productionLiveBuyStacks = {}
    self.productionCurrentPurchase = nil
    self.productionBuyUsedCachedScan = false
    self.productionBuyConfirmedCount = 0
    self.productionBuySkipped = {}

    local items = {}
    local i

    for i = 1, table.getn(self.productionPlan) do
        local material = self.productionPlan[i]
        if material.missing > 0 then
            items[material.key] = {
                name = material.name,
                itemId = material.itemId,
                itemKind = "reagent",
                needed = material.missing
            }
        end
    end

    if next(items) == nil then
        chat("All required materials are already in your bags.")
        return
    end

    local reused, reusedCount =
        self:LoadFreshProductionBuyCandidates()

    if reused then
        self.productionBuyRunning = true
        self.productionBuyPhase = "preparing"
        self.productionBuyUsedCachedScan = true

        chat(
            "Using fresh Production scan for " ..
            reusedCount .. " material(s); " ..
            "each auction will still be verified before purchase."
        )
        setStatus(
            "Using fresh Production scan; preparing safe purchase queue."
        )

        self:StartProductionPurchaseExecution()
        return
    end

    self.productionBuyRunning = true
    self.productionBuyPhase = "scanning"
    self:StartScan(items, "production-buy")
    setStatus("Scanning exact auctions before purchasing.")
end

function JAP:ProductionCraftAll()
    if not TradeSkillFrame or not TradeSkillFrame:IsVisible() then
        chat("Open the Alchemy profession window first.")
        return
    end

    local skillName = GetTradeSkillLine and GetTradeSkillLine() or nil
    if skillName and lower(skillName) ~= "alchemy" then
        chat("The open profession window is not Alchemy.")
        return
    end

    if self.productionCraftRunning then
        if self.productionCraftWaitingForClick
           and self.productionCraftCurrent then
            self:ExecuteCurrentProductionCraft()
        elseif self.productionCraftWaitingForBags then
            chat("The current recipe is still crafting.")
        end
        return
    end

    self:BuildProductionPlan(true)

    self:BuildProductionCraftQueue()

    if table.getn(self.productionCraftQueue) == 0 then
        chat("No Production crafts are queued.")
        return
    end

    self.productionCraftRunning = true
    self.productionCraftCurrent = nil
    self.productionCraftWaitingForBags = false
    self.productionCraftWaitingForClick = false
    self.productionCraftStartedAt = 0
    self.productionCraftNextAt = 0
    self.productionCraftProgress = {}
    self.productionCraftCompleted = {}

    local progressRecipes = self:GetProductionRecipes()
    local progressIndex
    for progressIndex = 1, table.getn(progressRecipes) do
        local progressRecipe = progressRecipes[progressIndex]
        local progressKey =
            progressRecipe.key or normalizeKey(progressRecipe.name)
        self.productionCraftProgress[progressKey] = 0
        self.productionCraftCompleted[progressKey] = false
    end

    self:PrepareNextProductionCraft()
    self:ExecuteCurrentProductionCraft()
end

function JAP:ProductionPostAll()
    if self.productionPostRunning or self.scanRunning then
        chat("A scan or posting sequence is already running.")
        return
    end

    if not AuctionFrame or not AuctionFrame:IsVisible() then
        chat("Open the Auction House first.")
        return
    end

    local recipes = self:GetProductionRecipes()
    local items = {}
    local i

    for i = 1, table.getn(recipes) do
        local recipe = recipes[i]
        local productName = recipe.productName or recipe.name
        if getBagItemCountByName(productName) > 0 then
            items[normalizeKey(productName)] = {
                name = productName,
                itemId = recipe.productId,
                itemKind = "product"
            }
        end
    end

    if next(items) == nil then
        chat("No planned finished potions were found in your bags.")
        return
    end

    self.productionPostPending = nil
    self.productionPostPrepareAttempts = 0
    self.productionPostConfirmAttempts = 0
    self.productionPostSourceBag = nil
    self.productionPostSourceSlot = nil
    self.productionPostStartedAt = 0
    self.productionPostLivePrices = {}
    self.productionPostLiveListings = {}
    self.productionPostReferenceInfo = {}
    self.productionPostSplitSourceBag = nil
    self.productionPostSplitSourceSlot = nil
    self.productionPostSplitTargetBag = nil
    self.productionPostSplitTargetSlot = nil
    self.productionPostStage = nil
    self.productionPostScanPending = true
    self:StartScan(items, "production-post-scan")
    setStatus("Scanning current potion prices before posting.")
end


local function getBagSlotByName(itemName)
    if not itemName then return nil, nil, nil end

    local wanted = normalizeKey(itemName)
    local bag

    for bag = 0, 4 do
        local slots = GetContainerNumSlots and GetContainerNumSlots(bag) or 0
        local slot

        for slot = 1, slots do
            local link =
                GetContainerItemLink and
                GetContainerItemLink(bag, slot) or nil

            if link then
                local bagItemName = getItemNameFromLink(link)
                if bagItemName
                   and normalizeKey(bagItemName) == wanted then
                    local texture, count =
                        GetContainerItemInfo(bag, slot)
                    return bag, slot, count or 1
                end
            end
        end
    end

    return nil, nil, nil
end


local function getBagSlotByNameAndCount(itemName, wantedCount)
    if not itemName then return nil, nil, nil end

    local wanted = normalizeKey(itemName)
    local bag

    for bag = 0, 4 do
        local slots = GetContainerNumSlots and GetContainerNumSlots(bag) or 0
        local slot

        for slot = 1, slots do
            local link =
                GetContainerItemLink and
                GetContainerItemLink(bag, slot) or nil

            if link then
                local bagItemName = getItemNameFromLink(link)
                local texture, count =
                    GetContainerItemInfo(bag, slot)

                if bagItemName
                   and normalizeKey(bagItemName) == wanted
                   and (count or 1) == wantedCount then
                    return bag, slot, count or 1
                end
            end
        end
    end

    return nil, nil, nil
end

local function getFirstEmptyBagSlot()
    local bag

    for bag = 0, 4 do
        local slots = GetContainerNumSlots and GetContainerNumSlots(bag) or 0
        local slot

        for slot = 1, slots do
            local link =
                GetContainerItemLink and
                GetContainerItemLink(bag, slot) or nil

            if not link then
                return bag, slot
            end
        end
    end

    return nil, nil
end

function JAP:GetTradeSkillIndexByRecipeName(recipeName)
    if not recipeName or not GetNumTradeSkills then return nil end

    local wanted = normalizeRecipeComparisonName(recipeName)
    local count = GetNumTradeSkills()
    local index

    for index = 1, count do
        local name, skillType = GetTradeSkillInfo(index)

        if name and skillType ~= "header"
           and normalizeRecipeComparisonName(name) == wanted then
            return index
        end
    end

    return nil
end

function JAP:StopProductionBuy(reason)
    self.productionBuyRunning = false
    self.productionBuyPendingQuery = nil
    self.productionBuyWaiting = false
    self.productionBuyNextAt = 0
    self.productionCurrentPurchase = nil
    self.productionBuyQuerySent = false
    self.productionBuyResultReceived = false
    self.productionBuyQuerySentAt = 0
    self.productionBuyVerifyAttempts = 0
    self.productionBuyPhase = nil
    self.productionBuyUsedCachedScan = false
    setStatus(reason or "Production purchase stopped.")
    chat(reason or "Production purchase stopped.")
    self:BuildProductionPlan(true)
    self:RefreshUI()
end

function JAP:StopProductionCraft(reason)
    self.productionCraftRunning = false
    self.productionCraftNextAt = 0
    self.productionCraftCurrent = nil
    self.productionCraftWaitingForBags = false
    self.productionCraftWaitingForClick = false
    self.productionCraftStartedAt = 0

    if self.productionCraftButton then
        self.productionCraftButton:SetText("Craft All")
    end

    setStatus(reason or "Production crafting stopped.")
    chat(reason or "Production crafting stopped.")
    self:BuildProductionPlan(true)
    self:RefreshUI()
end

function JAP:StopProductionPost(reason)
    self.productionPostRunning = false
    self.productionPostNextAt = 0
    self.productionPostPending = nil
    self.productionPostPrepareAttempts = 0
    self.productionPostSplitSourceBag = nil
    self.productionPostSplitSourceSlot = nil
    self.productionPostSplitTargetBag = nil
    self.productionPostSplitTargetSlot = nil
    self.productionPostStage = nil
    self.productionPostConfirmAttempts = 0
    self.productionPostSourceBag = nil
    self.productionPostSourceSlot = nil
    self.productionPostStartedAt = 0
    ClearCursor()
    setStatus(reason or "Production posting stopped.")
    chat(reason or "Production posting stopped.")
    self:RefreshUI()
end

function JAP:BuildProductionPurchaseQueue()
    clearArray(self.productionBuyQueue)

    local plannedTotal = 0
    local planIndex

    for planIndex = 1, table.getn(self.productionPlan) do
        local material = self.productionPlan[planIndex]

        if material.missing > 0 then
            local candidates =
                self.productionBuyCandidates[material.key] or {}

            table.sort(candidates, function(a, b)
                if a.unitPrice == b.unitPrice then
                    return a.buyout < b.buyout
                end
                return a.unitPrice < b.unitPrice
            end)

            local remaining = material.missing
            local candidateIndex

            for candidateIndex = 1, table.getn(candidates) do
                if remaining <= 0 then break end

                local candidate = candidates[candidateIndex]
                table.insert(self.productionBuyQueue, {
                    name = material.name,
                    key = material.key,
                    itemId = material.itemId,
                    page = candidate.page,
                    count = candidate.count,
                    buyout = candidate.buyout,
                    unitPrice = candidate.unitPrice,
                    owner = candidate.owner,
                    link = candidate.link
                })

                plannedTotal = plannedTotal + candidate.buyout
                remaining = remaining - candidate.count
            end

            if remaining > 0 then
                self.productionBuySkipped[material.key] = {
                    name = material.name,
                    reason =
                        "Not enough buyout auctions; still missing " ..
                        remaining,
                    time = time()
                }

                chat(
                    "Skipping " .. material.name ..
                    ": not enough buyout auctions; " ..
                    remaining .. " unit(s) remain missing."
                )
            end
        end
    end

    self.productionBuyPlannedTotal = plannedTotal
    return true
end

function JAP:StartProductionPurchaseExecution()
    if not self:BuildProductionPurchaseQueue() then
        return
    end

    if table.getn(self.productionBuyQueue) == 0 then
        self.productionBuyRunning = false
        self.productionBuyPhase = nil
        self.productionBuyConfirmedCount = 0
        self:BuildProductionPlan(true)
        self:RefreshUI()
        setStatus("Fresh scan complete; no purchase is required.")
        chat(
            "Production scan complete. No material purchase is required."
        )
        return
    end

    if GetMoney and GetMoney() < self.productionBuyPlannedTotal then
        self:StopProductionBuy(
            "Not enough money. Planned purchase total: " ..
            moneyToText(self.productionBuyPlannedTotal)
        )
        return
    end

    self.productionBuyRunning = true
    self.productionBuyPhase = "buying"
    self.productionBuySpent = 0
    self.productionBuyConfirmedCount = 0
    self.productionBuyWaiting = false
    self.productionBuyNextAt = now()

    chat(
        "Buying " .. table.getn(self.productionBuyQueue) ..
        " auction(s), planned total " ..
        moneyToText(self.productionBuyPlannedTotal) .. "."
    )
    if self.productionBuyUsedCachedScan then
        setStatus(
            "Fast purchase queue ready; every auction is still verified."
        )
    else
        setStatus("Production purchase queue ready.")
    end
end

function JAP:SkipCurrentProductionPurchase(purchase, reason)
    local key = purchase and purchase.key or
        normalizeKey(purchase and purchase.name or "unknown")

    self.productionBuySkipped[key] = {
        name = purchase and purchase.name or "Unknown",
        reason = reason or "Skipped",
        time = time()
    }

    chat(
        "Skipping purchase of " ..
        tostring(purchase and purchase.name or "unknown") ..
        ": " .. tostring(reason or "unknown reason") .. "."
    )

    self.productionBuyPendingQuery = nil
    self.productionBuyWaiting = false
    self.productionBuyQuerySent = false
    self.productionBuyResultReceived = false
    self.productionBuyQuerySentAt = 0
    self.productionBuyVerifyAttempts = 0
    self.productionCurrentPurchase = nil

    if table.getn(self.productionBuyQueue) > 0 then
        table.remove(self.productionBuyQueue, 1)
    end

    self.productionBuyNextAt = now() + 0.10
end

function JAP:QueueNextProductionPurchase()
    if not self.productionBuyRunning then return end
    if self.productionBuyPhase ~= "buying" then return end

    if table.getn(self.productionBuyQueue) == 0 then
        self.productionBuyRunning = false
        self.productionBuyPendingQuery = nil
        self.productionBuyWaiting = false
        self.productionCurrentPurchase = nil
        self.productionBuyQuerySent = false
        self.productionBuyResultReceived = false
        self.productionBuyQuerySentAt = 0
        self.productionBuyVerifyAttempts = 0
        self:BuildProductionPlan(true)
        self:RefreshUI()
        self.productionBuyPhase = nil
        self.productionBuyUsedCachedScan = false

        local skippedCount = 0
        local skippedKey, skippedValue
        for skippedKey, skippedValue in pairs(self.productionBuySkipped or {}) do
            skippedCount = skippedCount + 1
        end

        if (self.productionBuyConfirmedCount or 0) > 0 then
            setStatus(
                "Purchases complete; " .. skippedCount ..
                " material(s) skipped."
            )
            chat(
                "Production purchases complete. Bought " ..
                self.productionBuyConfirmedCount ..
                " auction(s), spent approximately " ..
                moneyToText(self.productionBuySpent) ..
                ", skipped " .. skippedCount ..
                " material(s). Collect purchased items from the mailbox."
            )
            self:PlayCompletionSound("buy")
        else
            setStatus("Purchase plan complete; no auction was bought.")
            chat(
                "Production purchase check complete. No auction was bought."
            )
            self:PlayCompletionSound("buy")
        end
        return
    end

    if not AuctionFrame or not AuctionFrame:IsVisible() then
        self:StopProductionBuy("Auction House was closed.")
        return
    end

    local purchase = self.productionBuyQueue[1]
    self.productionCurrentPurchase = purchase
    self.productionBuyPendingQuery = {
        name = purchase.name,
        page = purchase.page or 0,
        purchase = purchase
    }

    self.productionBuyQuerySent = false
    self.productionBuyResultReceived = false
    self.productionBuyQuerySentAt = 0
    self.productionBuyVerifyAttempts = 0
    self.productionBuyWaiting = true
    self.productionBuyNextAt = now()
    setStatus(
        "Preparing purchase: " .. purchase.name ..
        " x" .. purchase.count
    )
end

function JAP:SendProductionPurchaseQuery()
    if not self.productionBuyRunning
       or not self.productionBuyPendingQuery
       or not self.productionBuyWaiting then
        return
    end

    if now() < self.productionBuyNextAt then return end

    local elapsed = now() - (self.lastQueryAt or 0)
    if elapsed < (self.queryDelay or 0.05) then return end

    local canSend = true
    if CanSendAuctionQuery then
        local ready = CanSendAuctionQuery()
        if ready == nil or ready == false then canSend = false end
    end
    if not canSend then return end

    local query = self.productionBuyPendingQuery
    self.productionBuyWaiting = false
    self.productionBuyQuerySent = true
    self.productionBuyResultReceived = false
    self.productionBuyQuerySentAt = now()
    self.lastQueryAt = self.productionBuyQuerySentAt

    QueryAuctionItems(
        query.name,
        "",
        "",
        0,
        0,
        0,
        query.page or 0,
        false
    )
end

function JAP:ProcessProductionPurchaseResults()
    if not self.productionBuyRunning
       or not self.productionBuyPendingQuery then
        return false
    end

    local query = self.productionBuyPendingQuery
    local purchase = query.purchase
    local batchCount = GetNumAuctionItems("list") or 0
    local matchIndex = nil
    local actualBuyout = nil
    local actualCount = nil
    local actualUnitPrice = nil
    local index

    for index = 1, batchCount do
        local name, texture, count, quality, canUse, level,
              minBid, minIncrement, buyoutPrice, bidAmount,
              highBidder, owner =
              GetAuctionItemInfo("list", index)

        if name and count and count > 0
           and buyoutPrice and buyoutPrice > 0 then
            local link = GetAuctionItemLink
                and GetAuctionItemLink("list", index) or nil
            local itemId = getItemId(link)

            local sameName =
                normalizeKey(name) == normalizeKey(purchase.name)
            local sameId =
                purchase.itemId == nil
                or itemId == nil
                or itemId == purchase.itemId

            if sameName and sameId then
                local unitPrice = buyoutPrice / count

                if actualUnitPrice == nil
                   or unitPrice < actualUnitPrice
                   or (unitPrice == actualUnitPrice
                       and buyoutPrice < actualBuyout) then
                    matchIndex = index
                    actualBuyout = buyoutPrice
                    actualCount = count
                    actualUnitPrice = unitPrice
                end
            end
        end
    end

    if not matchIndex then
        self.productionBuyVerifyAttempts =
            (self.productionBuyVerifyAttempts or 0) + 1

        if self.productionBuyVerifyAttempts < 4 then
            self.productionBuyQuerySent = false
            self.productionBuyResultReceived = false
            self.productionBuyWaiting = true
            self.productionBuyNextAt = now() + 0.20

            setStatus(
                "Retrying current buyout check for " ..
                purchase.name .. " (" ..
                self.productionBuyVerifyAttempts .. "/3)..."
            )
            return true
        end

        self:SkipCurrentProductionPurchase(
            purchase,
            "no current buyout was found after 3 verification queries"
        )
        return true
    end

    self.productionBuyPendingQuery = nil

    self.productionBuyQuerySent = false
    self.productionBuyResultReceived = false
    self.productionBuyQuerySentAt = 0
    self.productionBuyVerifyAttempts = 0

    self.productionLiveBuyPrices[purchase.key] = actualBuyout
    self.productionLiveBuyStacks[purchase.key] = actualCount

    -- This verification found the current cheapest unit price. Commit it to
    -- the same global store used by Recipes, Materials, and Production.
    saveAuctionPrice(
        purchase.name,
        actualUnitPrice,
        purchase.itemId,
        1,
        {
            pages = 1,
            bestStackSize = actualCount,
            bestStackBuyout = actualBuyout
        }
    )
    updateMaterialHistory(purchase.name, actualUnitPrice)
    self:RecalculateLiveResults()
    self.productionCurrentPurchase = {
        name = purchase.name,
        key = purchase.key,
        count = actualCount,
        buyout = actualBuyout,
        unitPrice = actualUnitPrice
    }

    self:BuildProductionPlan(true)
    self:RefreshUI()

    local plannedUnitPrice = purchase.unitPrice or 0
    local perAuctionLimit =
        plannedUnitPrice > 0 and (plannedUnitPrice * 1.10) or nil

    if perAuctionLimit
       and actualUnitPrice > perAuctionLimit then
        self:SkipCurrentProductionPurchase(
            purchase,
            "current unit price " ..
            moneyToText(actualUnitPrice) ..
            " is more than 10% above planned " ..
            moneyToText(plannedUnitPrice)
        )
        return true
    end

    local projectedSpent =
        self.productionBuySpent + actualBuyout
    local allowedTotal =
        self.productionBuyPlannedTotal * 1.10

    if projectedSpent > allowedTotal then
        self:StopProductionBuy(
            "Purchase stopped: total would exceed the 10% price limit."
        )
        return true
    end

    if GetMoney and GetMoney() < actualBuyout then
        self:StopProductionBuy(
            "Purchase stopped: not enough money for " ..
            purchase.name .. "."
        )
        return true
    end

    PlaceAuctionBid("list", matchIndex, actualBuyout)
    self.productionBuySpent = projectedSpent
    self.productionBuyConfirmedCount =
        (self.productionBuyConfirmedCount or 0) + 1
    table.remove(self.productionBuyQueue, 1)

    local extraCovered = (actualCount or purchase.count) - purchase.count
    if extraCovered > 0 then
        local queueIndex = 1
        while queueIndex <= table.getn(self.productionBuyQueue)
              and extraCovered > 0 do
            local queued = self.productionBuyQueue[queueIndex]

            if queued.key == purchase.key then
                if queued.count <= extraCovered then
                    extraCovered = extraCovered - queued.count
                    table.remove(self.productionBuyQueue, queueIndex)
                else
                    extraCovered = 0
                    queueIndex = queueIndex + 1
                end
            else
                queueIndex = queueIndex + 1
            end
        end
    end

    setStatus(
        "Bought " .. purchase.name .. " x" .. actualCount ..
        " for " .. moneyToText(actualBuyout) ..
        "; " .. table.getn(self.productionBuyQueue) ..
        " auction(s) remaining."
    )

    self.productionBuyNextAt = now() + 0.10
    self.productionBuyWaiting = false
    return true
end

function JAP:ProcessProductionBuy()
    if not self.productionBuyRunning then return end

    -- Buy All marks the operation as running while its fresh AH scan is active.
    -- The purchase queue is intentionally still empty during that phase.
    if self.productionBuyPhase == "scanning" then
        return
    end

    if self.productionBuyPhase ~= "buying" then
        return
    end

    if self.productionBuyPendingQuery then
        if self.productionBuyWaiting then
            self:SendProductionPurchaseQuery()
            return
        end

        if self.productionBuyQuerySent
           and self.productionBuyResultReceived
           and now() >=
               ((self.productionBuyQuerySentAt or 0) + 0.10) then
            self:ProcessProductionPurchaseResults()
        end
        return
    end

    if now() >= (self.productionBuyNextAt or 0) then
        self:QueueNextProductionPurchase()
    end
end

function JAP:BuildProductionCraftQueue()
    clearArray(self.productionCraftQueue)

    local recipes = self:GetProductionRecipes()
    local i

    for i = 1, table.getn(recipes) do
        local recipe = recipes[i]
        local recipeKey = recipe.key or normalizeKey(recipe.name)
        local target = self:GetProductionRecipeTarget(recipeKey)
        local produced = recipe.minMade or 1
        if produced < 1 then produced = 1 end

        local productName = recipe.productName or recipe.name
        local existing = getBagItemCountByName(productName)

        -- The target means newly crafted finished items per recipe,
        -- not the desired final number already present in the bags.
        local crafts = math.ceil(target / produced)
        local expectedCreated = crafts * produced

        if crafts > 0 then
            table.insert(self.productionCraftQueue, {
                recipeName = recipe.name,
                productName = productName,
                crafts = crafts,
                producedPerCraft = produced,
                requestedNewItems = target,
                expectedCreated = expectedCreated,
                startingCount = existing,
                expectedFinalCount = existing + expectedCreated
            })
        end
    end
end

function JAP:GetRecipeByName(recipeName)
    local wanted = normalizeKey(recipeName)
    local i
    for i = 1, table.getn(self.recipes or {}) do
        local recipe = self.recipes[i]
        if recipe and normalizeKey(recipe.name) == wanted then
            return recipe
        end
    end
    return nil
end

function JAP:ReevaluateBlockedProductionRecipes()
    local changed = false
    local recipeKey, skipped

    for recipeKey, skipped in pairs(self.productionCraftSkipped or {}) do
        if self.productionCraftCompleted[recipeKey] == true then
            self.productionCraftSkipped[recipeKey] = nil
            changed = true
        else
            local recipe = self.recipeByName and self.recipeByName[recipeKey]

            if not recipe then
            recipe = self:GetRecipeByName(recipeKey)
        end

        if recipe then
            local produced = recipe.minMade or 1
            if produced < 1 then produced = 1 end

            local craft = {
                recipeName = recipe.name,
                productName = recipe.productName or recipe.name,
                crafts = math.ceil(
                    self:GetProductionRecipeTarget(recipe.key or normalizeKey(recipe.name)) / produced
                ),
                producedPerCraft = produced
            }

            local missing = self:GetCraftMissingMaterials(craft)

            if table.getn(missing) == 0 then
                self.productionCraftSkipped[recipeKey] = nil
                changed = true

                chat(
                    (recipe.productName or recipe.name) ..
                    " is no longer blocked; all materials are now in the bags."
                )
            else
                skipped.details = self:FormatMissingMaterials(missing)
            end
        end
        end
    end

    if changed then
        self:SaveProductionTemplateStatus()
    end

    return changed
end

function JAP:GetCraftMissingMaterials(craft)
    local missing = {}
    local recipe = self:GetRecipeByName(craft.recipeName)

    if not recipe then
        table.insert(missing, {name = "Recipe data unavailable", count = 1})
        return missing
    end

    local reagentIndex
    for reagentIndex = 1, table.getn(recipe.reagents or {}) do
        local reagent = recipe.reagents[reagentIndex]
        local required = (reagent.count or 1) * (craft.crafts or 1)
        local inBags = getBagItemCountByName(reagent.name)

        if inBags < required then
            table.insert(missing, {
                name = reagent.name,
                count = required - inBags
            })
        end
    end

    return missing
end

function JAP:FormatMissingMaterials(missing)
    local parts = {}
    local i
    for i = 1, table.getn(missing or {}) do
        local entry = missing[i]
        table.insert(parts, entry.count .. "x " .. entry.name)
    end
    return table.concat(parts, ", ")
end

function JAP:PrepareNextProductionCraft()
    if not self.productionCraftRunning then return end

    if table.getn(self.productionCraftQueue) == 0 then
        self.productionCraftRunning = false
        self.productionCraftCurrent = nil
        self.productionCraftWaitingForBags = false
        self.productionCraftWaitingForClick = false
        self.productionCraftStartedAt = 0
        self.productionCraftNextAt = 0

        self:BuildProductionPlan(true)
        self:RefreshUI()

        local completedRecipes = self:GetProductionRecipes()
        local completedIndex
        for completedIndex = 1, table.getn(completedRecipes) do
            local completedRecipe = completedRecipes[completedIndex]
            local completedKey =
                completedRecipe.key or normalizeKey(completedRecipe.name)
            self.productionCraftCompleted[completedKey] = true
            self.productionCraftProgress[completedKey] =
                self:GetProductionRecipeTarget(completedKey)
        end

        self:SaveProductionTemplateStatus()
        self:RefreshUI()

        setStatus(
            "Craft All complete. Open the Auction House to post the potions."
        )
        chat("Production crafting complete.")
        self:PlayCompletionSound("craft")

        if self.productionCraftButton then
            self.productionCraftButton:SetText("Craft All")
        end
        return
    end

    local craft = nil

    while table.getn(self.productionCraftQueue) > 0 do
        local candidate = self.productionCraftQueue[1]
        local missing = self:GetCraftMissingMaterials(candidate)

        if table.getn(missing) == 0 then
            craft = candidate
            self.productionCraftSkipped[normalizeKey(candidate.recipeName)] = nil
            self:SaveProductionTemplateStatus()
            break
        end

        local recipeKey = normalizeKey(candidate.recipeName)
        self.productionCraftSkipped[recipeKey] = {
            reason = "Missing materials",
            details = self:FormatMissingMaterials(missing)
        }

        chat(
            "Skipping " .. candidate.productName ..
            " for now; missing " ..
            self:FormatMissingMaterials(missing) .. "."
        )

        table.remove(self.productionCraftQueue, 1)
    end

    if not craft then
        self.productionCraftRunning = false
        self.productionCraftCurrent = nil
        self.productionCraftWaitingForClick = false
        self.productionCraftWaitingForBags = false

        self:BuildProductionPlan(true)
        self:SaveProductionTemplateStatus()
        self:RefreshUI()

        setStatus("Craft queue finished with blocked recipes still open.")
        chat("Craft queue finished. Some recipes were skipped because materials were missing.")
        self:PlayCompletionSound("craft")

        if self.productionCraftButton then
            self.productionCraftButton:SetText("Craft All")
        end
        return
    end

    self.productionCraftCurrent = craft
    self.productionCraftSkipped[normalizeKey(craft.recipeName)] = nil
    self.productionCraftWaitingForClick = true
    self.productionCraftWaitingForBags = false

    setStatus(
        "Next craft ready: " .. craft.expectedCreated ..
        " new " .. craft.productName ..
        ". Click Craft Next."
    )

    if self.productionCraftButton then
        self.productionCraftButton:SetText("Craft Next")
    end

    self:BuildProductionPlan(true)
    self:RefreshUI()
end

function JAP:ExecuteCurrentProductionCraft()
    if not self.productionCraftRunning
       or not self.productionCraftCurrent
       or not self.productionCraftWaitingForClick then
        return
    end

    if not TradeSkillFrame or not TradeSkillFrame:IsVisible() then
        self:StopProductionCraft("Alchemy window was closed.")
        return
    end

    local craft = self.productionCraftCurrent
    local missing = self:GetCraftMissingMaterials(craft)

    if table.getn(missing) > 0 then
        local recipeKey = normalizeKey(craft.recipeName)
        self.productionCraftSkipped[recipeKey] = {
            reason = "Missing materials",
            details = self:FormatMissingMaterials(missing)
        }

        chat(
            "Skipping " .. craft.productName ..
            "; missing " .. self:FormatMissingMaterials(missing) .. "."
        )

        table.remove(self.productionCraftQueue, 1)
        self.productionCraftCurrent = nil
        self.productionCraftWaitingForClick = false
        self.productionCraftWaitingForBags = false
        self:PrepareNextProductionCraft()
        return
    end

    local tradeIndex =
        self:GetTradeSkillIndexByRecipeName(craft.recipeName)

    if not tradeIndex then
        self:StopProductionCraft(
            "Could not find learned recipe: " .. craft.recipeName
        )
        return
    end

    craft.tradeIndex = tradeIndex
    craft.startingCount =
        getBagItemCountByName(craft.productName)
    craft.expectedCreated =
        craft.crafts * (craft.producedPerCraft or 1)
    craft.expectedFinalCount =
        craft.startingCount + craft.expectedCreated

    craft.reagentStartCounts = {}
    craft.reagentRequiredCounts = {}

    local craftRecipe = self:GetRecipeByName(craft.recipeName)
    if craftRecipe then
        local reagentIndex
        for reagentIndex = 1, table.getn(craftRecipe.reagents or {}) do
            local reagent = craftRecipe.reagents[reagentIndex]
            if reagent and reagent.name then
                local reagentKey = normalizeKey(reagent.name)
                craft.reagentStartCounts[reagentKey] =
                    getBagItemCountByName(reagent.name)
                craft.reagentRequiredCounts[reagentKey] =
                    (reagent.count or 1) * (craft.crafts or 1)
            end
        end
    end

    -- Once the batch has actually started, it can no longer become Blocked
    -- because those exact materials are intentionally being consumed.
    self.productionCraftSkipped[normalizeKey(craft.recipeName)] = nil

    self.productionCraftWaitingForClick = false
    self.productionCraftWaitingForBags = true
    self.productionCraftStartedAt = now()

    DoTradeSkill(tradeIndex, craft.crafts)

    setStatus(
        "Crafting " .. craft.expectedCreated .. " new " ..
        craft.productName .. "."
    )

    chat(
        "Started " .. craft.crafts .. " craft(s) for " ..
        craft.expectedCreated .. " new " ..
        craft.productName .. "."
    )

    if self.productionCraftButton then
        self.productionCraftButton:SetText("Crafting...")
    end

    self:BuildProductionPlan(true)
    self:RefreshUI()
end

function JAP:ProductionCraftReagentsConsumed(craft)
    if not craft
       or not craft.reagentStartCounts
       or not craft.reagentRequiredCounts then
        return false
    end

    local recipe = self:GetRecipeByName(craft.recipeName)
    if not recipe then return false end

    local checkedAny = false
    local reagentIndex

    for reagentIndex = 1, table.getn(recipe.reagents or {}) do
        local reagent = recipe.reagents[reagentIndex]
        if reagent and reagent.name then
            local reagentKey = normalizeKey(reagent.name)
            local starting = craft.reagentStartCounts[reagentKey]
            local required = craft.reagentRequiredCounts[reagentKey]

            if starting ~= nil and required and required > 0 then
                checkedAny = true

                local current =
                    getBagItemCountByName(reagent.name)
                local consumed =
                    math.max(0, starting - current)

                if consumed < required then
                    return false
                end
            end
        end
    end

    return checkedAny
end

function JAP:FinishCurrentProductionCraftBatch(craft, createdDetected)
    if not craft then return end

    local recipeKey = normalizeKey(craft.recipeName)
    local target =
        craft.requestedNewItems or
        self:GetProductionRecipeTarget(recipeKey)

    -- The batch itself completed. From this point forward the queue must never
    -- reinterpret its consumed reagents as a new Missing/Blocked condition.
    self.productionCraftProgress[recipeKey] = target
    self.productionCraftCompleted[recipeKey] = true
    self.productionCraftSkipped[recipeKey] = nil

    self:SaveProductionTemplateStatus()

    chat(
        "Finished " .. target .. " " ..
        craft.productName ..
        (createdDetected and "." or
            " (confirmed by reagent consumption).")
    )

    table.remove(self.productionCraftQueue, 1)
    self.productionCraftCurrent = nil
    self.productionCraftWaitingForBags = false
    self.productionCraftWaitingForClick = false
    self.productionCraftStartedAt = 0

    self:BuildProductionPlan(true)
    self:RefreshUI()

    self:PrepareNextProductionCraft()
    self:RefreshUI()
end

function JAP:ProcessProductionCraft()
    if not self.productionCraftRunning then return end

    if self.productionCraftWaitingForBags
       and self.productionCraftCurrent then
        local craft = self.productionCraftCurrent
        local currentCount =
            getBagItemCountByName(craft.productName)
        local createdNow =
            math.max(0, currentCount - (craft.startingCount or 0))
        local recipeKey =
            normalizeKey(craft.recipeName)

        -- Update the visible craft progress after every completed item,
        -- not only after the entire recipe batch has finished.
        local previousProgress =
            self.productionCraftProgress[recipeKey] or 0

        if createdNow > previousProgress then
            self.productionCraftProgress[recipeKey] = createdNow

            if createdNow >= (craft.requestedNewItems or self:GetProductionRecipeTarget(recipeKey)) then
                self.productionCraftCompleted[recipeKey] = true
            end

            self:SaveProductionTemplateStatus()
            self:BuildProductionPlan(true)
            self:RefreshUI()
        end

        if currentCount >= craft.expectedFinalCount then
            self:FinishCurrentProductionCraftBatch(craft, true)
            return
        end

        -- Vanilla/Turtle can deliver BAG_UPDATE events in an order where the
        -- output count is not yet visible although the batch has completed.
        -- Reagent consumption is a second independent completion signal.
        if now() - (self.productionCraftStartedAt or 0) > 0.20
           and self:ProductionCraftReagentsConsumed(craft) then
            self:FinishCurrentProductionCraftBatch(craft, false)
            return
        end

        if now() - (self.productionCraftStartedAt or 0) > 45 then
            self:StopProductionCraft(
                "Crafting stopped: no completed output was detected for " ..
                craft.productName ..
                ". Check bag space and the Alchemy window."
            )
        end

        return
    end

end

function JAP:LoadProductionPostSettings()
    local settings = db().settings or {}

    local stackSize =
        tonumber(settings.productionPostStackSize) or 1
    if stackSize < 1 then stackSize = 1 end
    self.productionPostStackSize = math.floor(stackSize)

    local duration =
        tonumber(settings.productionPostDuration) or 6
    if duration ~= 6 and duration ~= 24 and duration ~= 72 then
        duration = 6
    end
    self.productionPostDuration = duration

    if self.productionPostStackEdit then
        self.productionPostStackEdit:SetText(
            tostring(self.productionPostStackSize)
        )
    end

    if self.productionPostDurationButton then
        self.productionPostDurationButton:SetText(
            tostring(self.productionPostDuration) .. "h"
        )
    end
end

function JAP:SetProductionPostStackSize()
    local value = self.productionPostStackEdit
        and tonumber(self.productionPostStackEdit:GetText()) or 1

    if not value or value < 1 then value = 1 end
    value = math.floor(value)

    self.productionPostStackSize = value
    db().settings.productionPostStackSize = value

    if self.productionPostStackEdit then
        self.productionPostStackEdit:SetText(tostring(value))
    end

    chat("Production auction stack size set to " .. value .. ".")
    self:RefreshUI()
end

function JAP:CycleProductionPostDuration()
    local duration = self.productionPostDuration or 6

    if duration == 6 then
        duration = 24
    elseif duration == 24 then
        duration = 72
    else
        duration = 6
    end

    self.productionPostDuration = duration
    db().settings.productionPostDuration = duration

    if self.productionPostDurationButton then
        self.productionPostDurationButton:SetText(
            tostring(duration) .. "h"
        )
    end

    chat("Production auction duration set to " .. duration .. " hours.")
    self:RefreshUI()
end

function JAP:GetProductionPostDurationValue()
    if self.productionPostDuration == 24 then
        return 480
    elseif self.productionPostDuration == 72 then
        return 1440
    end

    return 120
end

local function isOwnAuctionOwner(owner)
    if not owner or not UnitName then return false end

    local playerName = UnitName("player")
    if not playerName then return false end

    return normalizeKey(owner) == normalizeKey(playerName)
end

local function getProtectedPostReference(productName, listings)
    if not listings or table.getn(listings) == 0 then
        return nil, nil
    end

    local prices = {}
    local i
    local rawCheapest = nil

    -- Own auctions must never cause us to undercut ourselves.
    for i = 1, table.getn(listings) do
        local listing = listings[i]
        if listing and listing.unitPrice and listing.unitPrice > 0
           and not isOwnAuctionOwner(listing.owner) then
            table.insert(prices, listing.unitPrice)

            if not rawCheapest or listing.unitPrice < rawCheapest then
                rawCheapest = listing.unitPrice
            end
        end
    end

    if table.getn(prices) == 0 then
        return nil, {
            ignoredOwnOnly = true
        }
    end

    table.sort(prices)

    local protectedPrice = prices[1]
    local reason = nil
    local history = getProductHistory(productName)
    local historyReference =
        history and history.referencePrice or nil

    -- First protection layer: compare against the recent 14-day reference.
    -- A listing below 70% of that reference is considered suspicious if a
    -- current listing exists back in the normal range.
    if historyReference and historyReference > 0
       and protectedPrice < historyReference * 0.70 then
        local historyFloor = historyReference * 0.70

        for i = 1, table.getn(prices) do
            if prices[i] >= historyFloor then
                protectedPrice = prices[i]
                reason = "history-floor"
                break
            end
        end
    end

    -- Second layer: detect a large live-market gap. This also works for items
    -- without useful history. A jump of at least 35% means the lower cluster
    -- is treated as a dumping/outlier cluster and the first price after the
    -- gap becomes the posting reference.
    local gapReference = nil
    for i = 1, table.getn(prices) - 1 do
        local low = prices[i]
        local high = prices[i + 1]

        if low > 0 and high >= low * 1.35 then
            gapReference = high
            break
        end
    end

    if gapReference and gapReference > protectedPrice then
        protectedPrice = gapReference
        reason = "market-gap"
    end

    return protectedPrice, {
        rawCheapest = rawCheapest,
        protectedPrice = protectedPrice,
        reason = reason,
        historyReference = historyReference,
        competitorListings = table.getn(prices)
    }
end

function JAP:BuildProductionPostQueue()
    clearArray(self.productionPostQueue)

    local recipes = self:GetProductionRecipes()
    local configuredStackSize = self.productionPostStackSize or 1

    if configuredStackSize < 1 then
        configuredStackSize = 1
    end

    local i
    for i = 1, table.getn(recipes) do
        local recipe = recipes[i]
        local recipeKey = recipe.key or normalizeKey(recipe.name)
        local target = self:GetProductionRecipeTarget(recipeKey)
        local productName = recipe.productName or recipe.name
        local productKey = normalizeKey(productName)
        local bagCount = getBagItemCountByName(productName)
        local postCount = math.min(target, bagCount)
        local liveListings =
            self.productionPostLiveListings[productKey]
        local competitorUnitPrice, referenceInfo =
            getProtectedPostReference(productName, liveListings)

        if not competitorUnitPrice then
            competitorUnitPrice =
                self.productionPostLivePrices[productKey] or
                getAnyStoredPrice(productName)
        end

        self.productionPostReferenceInfo[productKey] = referenceInfo

        if postCount > 0 then
            if not competitorUnitPrice or competitorUnitPrice <= 1 then
                self:StopProductionPost(
                    "No fresh competitor price for " ..
                    productName .. "."
                )
                return false
            end

            if referenceInfo and referenceInfo.reason
               and referenceInfo.rawCheapest
               and referenceInfo.protectedPrice
               and referenceInfo.protectedPrice > referenceInfo.rawCheapest then
                chat(
                    "Price protection for " .. productName ..
                    ": ignored dump at " ..
                    moneyToText(referenceInfo.rawCheapest) ..
                    "; using " ..
                    moneyToText(referenceInfo.protectedPrice) ..
                    " as market reference."
                )
            end

            local ownUnitBuyout =
                math.max(1, math.floor(competitorUnitPrice) - 1)
            local remaining = postCount

            while remaining > 0 do
                local actualStackSize =
                    math.min(configuredStackSize, remaining)
                local totalBuyout =
                    ownUnitBuyout * actualStackSize
                local totalMinBid =
                    math.max(1, math.floor(totalBuyout * 0.95))

                table.insert(self.productionPostQueue, {
                    name = productName,
                    key = productKey,
                    sourceUnitPrice = competitorUnitPrice,
                    rawCheapestUnitPrice =
                        referenceInfo and referenceInfo.rawCheapest or nil,
                    priceProtectionReason =
                        referenceInfo and referenceInfo.reason or nil,
                    ownUnitBuyout = ownUnitBuyout,
                    stackSize = actualStackSize,
                    buyout = totalBuyout,
                    minBid = totalMinBid
                })

                remaining = remaining - actualStackSize
            end
        end
    end

    return true
end


function JAP:SetAuctionPostFields(minBid, buyout)
    local duration = self.productionPostDuration or 6
    local durationValue = self:GetProductionPostDurationValue()

    if AuctionFrameAuctions then
        AuctionFrameAuctions.duration = durationValue
    end

    if AuctionsShortAuctionButton then
        AuctionsShortAuctionButton:SetChecked(duration == 6 and 1 or nil)
    end
    if AuctionsMediumAuctionButton then
        AuctionsMediumAuctionButton:SetChecked(duration == 24 and 1 or nil)
    end
    if AuctionsLongAuctionButton then
        AuctionsLongAuctionButton:SetChecked(duration == 72 and 1 or nil)
    end

    if MoneyInputFrame_SetCopper then
        if StartPrice then
            MoneyInputFrame_SetCopper(StartPrice, minBid)
        end
        if BuyoutPrice then
            MoneyInputFrame_SetCopper(BuyoutPrice, buyout)
        end
    end
end


function JAP:PostAuctionFromBagSlot(post, bag, slot)
    local link = GetContainerItemLink(bag, slot)
    local name = getItemNameFromLink(link)
    local texture, count = GetContainerItemInfo(bag, slot)
    local wantedCount = post.stackSize or 1

    if not name
       or normalizeKey(name) ~= normalizeKey(post.name)
       or (count or 1) ~= wantedCount then
        self:StopProductionPost(
            "Posting source is not a verified stack of " ..
            wantedCount .. "x " .. post.name .. "."
        )
        return
    end

    ClearCursor()
    ClickAuctionSellItemButton()
    ClearCursor()
    PickupContainerItem(bag, slot)
    ClickAuctionSellItemButton()
    ClearCursor()

    self:SetAuctionPostFields(post.minBid, post.buyout)

    chat(
        "Posting " .. wantedCount .. "x " .. post.name ..
        ": " .. moneyToText(post.ownUnitBuyout) ..
        " each, total buyout " ..
        moneyToText(post.buyout) ..
        ", bid " .. moneyToText(post.minBid) ..
        " (competitor " ..
        moneyToText(post.sourceUnitPrice) .. " each)."
    )

    self.productionPostPending = post
    self.productionPostSourceBag = bag
    self.productionPostSourceSlot = slot
    self.productionPostStage = "wait-for-system-confirmation"
    self.productionPostStartedAt = now()
    self.productionPostNextAt = now() + 0.10

    StartAuction(
        post.minBid,
        post.buyout,
        self:GetProductionPostDurationValue()
    )
end

function JAP:OnProductionAuctionStarted()
    if not self.productionPostRunning
       or self.productionPostStage ~= "wait-for-system-confirmation"
       or not self.productionPostPending then
        return
    end

    local post = self.productionPostPending

    local postKey = post.key or normalizeKey(post.name)
    local progress = self.productionPostProgress[postKey]

    if not progress then
        progress = {
            postedItems = 0,
            auctions = {},
            totalBuyout = 0
        }
        self.productionPostProgress[postKey] = progress
    end

    progress.postedItems =
        (progress.postedItems or 0) + (post.stackSize or 1)
    progress.totalBuyout =
        (progress.totalBuyout or 0) + (post.buyout or 0)

    table.insert(progress.auctions, {
        stackSize = post.stackSize or 1,
        unitBuyout = post.ownUnitBuyout or 0,
        totalBuyout = post.buyout or 0,
        minBid = post.minBid or 0,
        postedAt = time()
    })

    if progress.postedItems >= self:GetProductionRecipeTarget(postKey) then
        self.productionPostCompleted[postKey] = true
    end

    self:SaveProductionTemplateStatus()
    table.remove(self.productionPostQueue, 1)

    self.productionPostPending = nil
    self.productionPostPrepareAttempts = 0
    self.productionPostConfirmAttempts = 0
    self.productionPostSplitSourceBag = nil
    self.productionPostSplitSourceSlot = nil
    self.productionPostSplitTargetBag = nil
    self.productionPostSplitTargetSlot = nil
    self.productionPostSourceBag = nil
    self.productionPostSourceSlot = nil
    self.productionPostStartedAt = 0
    self.productionPostStage = nil

    setStatus(
        "Server confirmed " .. post.name ..
        " at " .. moneyToText(post.buyout) ..
        "; " .. table.getn(self.productionPostQueue) ..
        " auction(s) remaining."
    )

    self.productionPostNextAt = now() + 0.25
    self:RefreshUI()
end


function JAP:ProcessProductionPost()
    if not self.productionPostRunning then return end
    if now() < (self.productionPostNextAt or 0) then return end

    if not AuctionFrame or not AuctionFrame:IsVisible() then
        self:StopProductionPost("Auction House was closed.")
        return
    end

    if self.productionPostStage == "wait-for-system-confirmation" then
        if now() - (self.productionPostStartedAt or 0) > 10 then
            self:StopProductionPost(
                "The server did not confirm the auction within 10 seconds. " ..
                "The current queue entry was not removed."
            )
        else
            self.productionPostNextAt = now() + 0.10
        end
        return
    end

    if self.productionPostStage == "wait-for-split" then
        local bag = self.productionPostSplitTargetBag
        local slot = self.productionPostSplitTargetSlot
        local link = bag and slot and GetContainerItemLink(bag, slot) or nil

        if link then
            local name = getItemNameFromLink(link)
            local texture, count = GetContainerItemInfo(bag, slot)
            local wantedCount =
                self.productionPostPending.stackSize or 1

            if name
               and normalizeKey(name) ==
                   normalizeKey(self.productionPostPending.name)
               and (count or 1) == wantedCount then
                local post = self.productionPostPending
                self.productionPostStage = nil
                self:PostAuctionFromBagSlot(post, bag, slot)
                return
            end
        end

        self.productionPostPrepareAttempts =
            (self.productionPostPrepareAttempts or 0) + 1

        if self.productionPostPrepareAttempts < 15 then
            self.productionPostNextAt = now() + 0.05
            return
        end

        self:StopProductionPost(
            "Could not create the configured auction stack for " ..
            self.productionPostPending.name .. "."
        )
        return
    end

    if table.getn(self.productionPostQueue) == 0 then
        self.productionPostRunning = false
        self.productionPostPending = nil
        self.productionPostStage = nil
        self.productionPostStartedAt = 0
        setStatus("All planned potion auctions were posted.")
        chat("Production posting complete.")
        self:PlayCompletionSound("post")
        self:RefreshUI()
        return
    end

    local post = self.productionPostQueue[1]
    local wantedCount = post.stackSize or 1
    local bag, slot, count =
        getBagSlotByNameAndCount(post.name, wantedCount)

    if bag == nil then
        bag, slot, count = getBagSlotByName(post.name)
    end

    if bag == nil then
        self:StopProductionPost(
            "Could not find " .. post.name .. " in the bags."
        )
        return
    end

    self.productionPostPending = post
    self.productionPostPrepareAttempts = 0

    if count and count ~= wantedCount then
        if count < wantedCount then
            self:StopProductionPost(
                "Could not find a bag stack large enough for " ..
                wantedCount .. "x " .. post.name .. "."
            )
            return
        end

        local emptyBag, emptySlot = getFirstEmptyBagSlot()

        if emptyBag == nil then
            self:StopProductionPost(
                "A free bag slot is required to prepare the auction stack for " ..
                post.name .. "."
            )
            return
        end

        ClearCursor()
        SplitContainerItem(bag, slot, wantedCount)
        PickupContainerItem(emptyBag, emptySlot)
        ClearCursor()

        self.productionPostSplitSourceBag = bag
        self.productionPostSplitSourceSlot = slot
        self.productionPostSplitTargetBag = emptyBag
        self.productionPostSplitTargetSlot = emptySlot
        self.productionPostStage = "wait-for-split"
        self.productionPostNextAt = now() + 0.05

        setStatus(
            "Preparing " .. wantedCount .. "x " ..
            post.name .. " for auction..."
        )
        return
    end

    self:PostAuctionFromBagSlot(post, bag, slot)
end

function JAP:ProcessProductionActions()
    self:ProcessProductionBuy()
    self:ProcessProductionCraft()
    self:ProcessProductionPost()
end

function JAP:SetPage(page)
    if page ~= "recipes" and page ~= "materials"
       and page ~= "missing" and page ~= "production"
       and page ~= "auction-watch" then return end

    local groups = {
        self.recipeControls,
        self.materialControls,
        self.missingControls,
        self.productionControls,
        self.auctionWatchControls
    }

    local groupIndex
    for groupIndex = 1, table.getn(groups) do
        local group = groups[groupIndex] or {}
        local controlIndex
        for controlIndex = 1, table.getn(group) do
            group[controlIndex]:Hide()
        end
    end

    if page == "missing" then
        self:ScheduleAutoReadAlchemy(0.20)
    end

    self.currentPage = page
    self.scrollOffset = 0

    if page == "recipes" then
        -- recipe.result is runtime-only; rebuild it every time the Recipes page
        -- becomes active from the permanently stored item prices.
        self:RecalculateLiveResults()
    else
        self:RefreshUI()
    end
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


function JAP:ApplyDetailScrollOffset()
    if not self.detailScrollChild or not self.detailScrollFrame then
        return
    end

    self.detailScrollChild:ClearAllPoints()
    self.detailScrollChild:SetPoint(
        "TOPLEFT",
        self.detailScrollFrame,
        "TOPLEFT",
        0,
        self.detailScrollOffset or 0
    )
end

function JAP:ResetDetailScroll()
    self.detailScrollOffset = 0

    self:ApplyDetailScrollOffset()

    if self.detailScrollBar then
        self.updatingDetailScrollBar = true
        self.detailScrollBar:SetValue(0)
        self.updatingDetailScrollBar = false
    end
end

function JAP:UpdateDetailScrollRange()
    if not self.detailScrollFrame
       or not self.detailScrollChild
       or not self.detailText then
        return
    end

    local frameHeight = self.detailScrollFrame:GetHeight() or 320
    local textHeight = self.detailText:GetHeight() or 0
    local contentHeight = math.max(frameHeight, textHeight + 8)
    local maxScroll = math.max(0, contentHeight - frameHeight)

    self.detailScrollChild:SetHeight(contentHeight)
    self.detailScrollMax = maxScroll

    if self.detailScrollOffset > maxScroll then
        self.detailScrollOffset = maxScroll
    end
    if self.detailScrollOffset < 0 then
        self.detailScrollOffset = 0
    end

    self:ApplyDetailScrollOffset()

    if self.detailScrollBar then
        self.updatingDetailScrollBar = true
        self.detailScrollBar:SetMinMaxValues(0, maxScroll)
        self.detailScrollBar:SetValue(self.detailScrollOffset)
        self.updatingDetailScrollBar = false

        if maxScroll > 0 then
            self.detailScrollBar:Show()
        else
            self.detailScrollBar:Hide()
        end
    end
end

function JAP:ScrollDetail(delta)
    if not delta or not self.detailScrollFrame then return end

    self:UpdateDetailScrollRange()

    if delta > 0 then
        self.detailScrollOffset =
            self.detailScrollOffset - self.detailScrollStep
    else
        self.detailScrollOffset =
            self.detailScrollOffset + self.detailScrollStep
    end

    if self.detailScrollOffset < 0 then
        self.detailScrollOffset = 0
    end
    if self.detailScrollOffset > (self.detailScrollMax or 0) then
        self.detailScrollOffset = self.detailScrollMax or 0
    end

    self:ApplyDetailScrollOffset()

    if self.detailScrollBar then
        self.updatingDetailScrollBar = true
        self.detailScrollBar:SetValue(self.detailScrollOffset)
        self.updatingDetailScrollBar = false
    end
end

function JAP:SetDetailText(text, keepScroll)
    if not self.detailText then return end

    if not keepScroll then
        self:ResetDetailScroll()
    end

    self.detailText:SetText(text or "")
    self:UpdateDetailScrollRange()
end

function JAP:CreateUI()
    self.sortMode = "alphabetical"
    db().settings.sortMode = "alphabetical"
    self.favoritesOnly = db().settings.favoritesOnly == true
    self.productsOnly = db().settings.productsOnly == true
    self.currentPage = "recipes"
    self.materialFavoritesOnly = db().settings.materialFavoritesOnly == true
    self.missingFavoritesOnly = db().settings.missingFavoritesOnly == true
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

    local missingTabButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    self.missingTabButton = missingTabButton
    missingTabButton:SetWidth(120)
    missingTabButton:SetHeight(22)
    missingTabButton:SetPoint("LEFT", materialsTabButton, "RIGHT", 8, 0)
    missingTabButton:SetText("Missing Recipes")
    missingTabButton:SetScript("OnClick", function() JAP:SetPage("missing") end)

    local productionTabButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    self.productionTabButton = productionTabButton
    productionTabButton:SetWidth(100)
    productionTabButton:SetHeight(22)
    productionTabButton:SetPoint("LEFT", missingTabButton, "RIGHT", 8, 0)
    productionTabButton:SetText("Production")
    productionTabButton:SetScript("OnClick", function() JAP:SetPage("production") end)

    local auctionWatchTabButton =
        CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    self.auctionWatchTabButton = auctionWatchTabButton
    auctionWatchTabButton:SetWidth(100)
    auctionWatchTabButton:SetHeight(22)
    auctionWatchTabButton:SetPoint(
        "LEFT",
        productionTabButton,
        "RIGHT",
        8,
        0
    )
    auctionWatchTabButton:SetText("My Auctions")
    auctionWatchTabButton:SetScript(
        "OnClick",
        function() JAP:SetPage("auction-watch") end
    )

    self.recipeControls = {}
    self.materialControls = {}
    self.missingControls = {}
    self.productionControls = {}
    self.auctionWatchControls = {}

    local auctionWatchCheckButton = self:CreateButton(
        frame,
        "Check My Auctions",
        145,
        20,
        -78,
        function() JAP:StartAuctionWatch() end
    )
    self.auctionWatchCheckButton = auctionWatchCheckButton
    table.insert(self.auctionWatchControls, auctionWatchCheckButton)
    auctionWatchCheckButton:Hide()

    local auctionWatchCancelSelectedButton = self:CreateButton(
        frame,
        "Cancel Selected",
        120,
        175,
        -78,
        function() JAP:CancelAuctionWatchSelected() end
    )
    self.auctionWatchCancelSelectedButton =
        auctionWatchCancelSelectedButton
    table.insert(
        self.auctionWatchControls,
        auctionWatchCancelSelectedButton
    )
    auctionWatchCancelSelectedButton:Hide()

    local auctionWatchCancelUndercutButton = self:CreateButton(
        frame,
        "Cancel Undercut",
        125,
        305,
        -78,
        function() JAP:CancelAuctionWatchUndercut() end
    )
    self.auctionWatchCancelUndercutButton =
        auctionWatchCancelUndercutButton
    table.insert(
        self.auctionWatchControls,
        auctionWatchCancelUndercutButton
    )
    auctionWatchCancelUndercutButton:Hide()

    local auctionWatchHint =
        frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    auctionWatchHint:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        20,
        -111
    )
    auctionWatchHint:SetWidth(500)
    auctionWatchHint:SetJustifyH("LEFT")
    auctionWatchHint:SetText(
        "Check live listings, cancel one selected product type, or cancel all undercut types."
    )
    table.insert(self.auctionWatchControls, auctionWatchHint)
    auctionWatchHint:Hide()

    local productionTemplateLabel =
        frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    productionTemplateLabel:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        20,
        -76
    )
    productionTemplateLabel:SetText("Template:")
    table.insert(self.productionControls, productionTemplateLabel)
    productionTemplateLabel:Hide()

    local productionTemplateEdit =
        CreateFrame(
            "EditBox",
            "JAPProductionTemplateEdit",
            frame,
            "InputBoxTemplate"
        )
    self.productionTemplateEdit = productionTemplateEdit
    productionTemplateEdit:SetWidth(145)
    productionTemplateEdit:SetHeight(20)
    productionTemplateEdit:SetPoint(
        "LEFT",
        productionTemplateLabel,
        "RIGHT",
        8,
        0
    )
    productionTemplateEdit:SetAutoFocus(false)
    table.insert(self.productionControls, productionTemplateEdit)
    productionTemplateEdit:Hide()

    local productionTemplateSave = self:CreateButton(
        frame,
        "Save / Update",
        110,
        250,
        -70,
        function() JAP:SaveProductionTemplate() end
    )
    table.insert(self.productionControls, productionTemplateSave)
    productionTemplateSave:Hide()

    local productionTemplateLoad = self:CreateButton(
        frame,
        "Load",
        75,
        370,
        -70,
        function() JAP:LoadProductionTemplateFromField() end
    )
    table.insert(self.productionControls, productionTemplateLoad)
    productionTemplateLoad:Hide()

    local productionTemplatePrevious = self:CreateButton(
        frame,
        "<",
        35,
        455,
        -70,
        function() JAP:CycleProductionTemplate(-1) end
    )
    table.insert(self.productionControls, productionTemplatePrevious)
    productionTemplatePrevious:Hide()

    local productionTemplateNext = self:CreateButton(
        frame,
        ">",
        35,
        495,
        -70,
        function() JAP:CycleProductionTemplate(1) end
    )
    table.insert(self.productionControls, productionTemplateNext)
    productionTemplateNext:Hide()

    local productionTemplateDelete = self:CreateButton(
        frame,
        "Delete",
        75,
        540,
        -70,
        function() JAP:DeleteProductionTemplate() end
    )
    table.insert(self.productionControls, productionTemplateDelete)
    productionTemplateDelete:Hide()

    local productionTemplateShow = self:CreateButton(
        frame,
        "Show Templates",
        115,
        625,
        -70,
        function() JAP:ShowProductionTemplates() end
    )
    table.insert(self.productionControls, productionTemplateShow)
    productionTemplateShow:Hide()

    local productionTargetLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    productionTargetLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -116)
    productionTargetLabel:SetText("Recipe amount:")
    table.insert(self.productionControls, productionTargetLabel)
    productionTargetLabel:Hide()

    local productionTargetPrevious = self:CreateButton(
        frame, "<", 28, 112, -110,
        function() JAP:CycleProductionTargetRecipe(-1) end
    )
    table.insert(self.productionControls, productionTargetPrevious)
    productionTargetPrevious:Hide()

    local productionTargetRecipeName =
        frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.productionTargetRecipeName = productionTargetRecipeName
    productionTargetRecipeName:SetPoint("TOPLEFT", frame, "TOPLEFT", 146, -116)
    productionTargetRecipeName:SetWidth(135)
    productionTargetRecipeName:SetJustifyH("LEFT")
    productionTargetRecipeName:SetText("No recipe")
    table.insert(self.productionControls, productionTargetRecipeName)
    productionTargetRecipeName:Hide()

    local productionTargetNext = self:CreateButton(
        frame, ">", 28, 286, -110,
        function() JAP:CycleProductionTargetRecipe(1) end
    )
    table.insert(self.productionControls, productionTargetNext)
    productionTargetNext:Hide()

    local productionTargetEdit = CreateFrame("EditBox", "JAPProductionTargetEdit", frame, "InputBoxTemplate")
    self.productionTargetEdit = productionTargetEdit
    productionTargetEdit:SetWidth(45)
    productionTargetEdit:SetHeight(20)
    productionTargetEdit:SetPoint("TOPLEFT", frame, "TOPLEFT", 320, -108)
    productionTargetEdit:SetAutoFocus(false)
    productionTargetEdit:SetNumeric(true)
    productionTargetEdit:SetText("0")
    productionTargetEdit:SetScript("OnEnterPressed", function()
        JAP:SetSelectedProductionRecipeTarget()
        this:ClearFocus()
    end)
    productionTargetEdit:SetScript("OnEditFocusLost", function()
        JAP:SetSelectedProductionRecipeTarget()
    end)
    table.insert(self.productionControls, productionTargetEdit)
    productionTargetEdit:Hide()

    local productionRebuild = self:CreateButton(frame, "Set Amount", 90, 375, -110,
        function() JAP:SetSelectedProductionRecipeTarget() end)
    table.insert(self.productionControls, productionRebuild)
    productionRebuild:Hide()

    -- Keep scan/clear on the same row as Recipe amount, but to the far
    -- right so they never overlap recipe selection or the amount editor.
    local productionScan = self:CreateButton(frame, "Scan Missing", 108, 475, -110,
        function() JAP:ScanProductionMaterials() end)
    table.insert(self.productionControls, productionScan)
    productionScan:Hide()

    local productionClear = self:CreateButton(frame, "Clear Queue", 102, 593, -110,
        function() JAP:ClearProduction() end)
    table.insert(self.productionControls, productionClear)
    productionClear:Hide()

    local productionBuy = self:CreateButton(frame, "Buy All Materials", 140, 20, -144,
        function() JAP:ProductionBuyAll() end)
    table.insert(self.productionControls, productionBuy)
    productionBuy:Hide()

    local productionCraft = self:CreateButton(frame, "Craft All", 110, 175, -144,
        function() JAP:ProductionCraftAll() end)
    self.productionCraftButton = productionCraft
    table.insert(self.productionControls, productionCraft)
    productionCraft:Hide()

    local productionPost = self:CreateButton(frame, "Post All", 100, 300, -144,
        function() JAP:ProductionPostAll() end)
    table.insert(self.productionControls, productionPost)
    productionPost:Hide()

    local productionPostStackLabel =
        frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    productionPostStackLabel:SetPoint(
        "TOPLEFT", frame, "TOPLEFT", 430, -150
    )
    productionPostStackLabel:SetText("AH stack:")
    table.insert(self.productionControls, productionPostStackLabel)
    productionPostStackLabel:Hide()

    local productionPostStackEdit =
        CreateFrame(
            "EditBox",
            "JAPProductionPostStackEdit",
            frame,
            "InputBoxTemplate"
        )
    self.productionPostStackEdit = productionPostStackEdit
    productionPostStackEdit:SetWidth(42)
    productionPostStackEdit:SetHeight(20)
    productionPostStackEdit:SetPoint(
        "LEFT", productionPostStackLabel, "RIGHT", 6, 0
    )
    productionPostStackEdit:SetAutoFocus(false)
    productionPostStackEdit:SetNumeric(true)
    productionPostStackEdit:SetScript("OnEnterPressed", function()
        JAP:SetProductionPostStackSize()
        this:ClearFocus()
    end)
    productionPostStackEdit:SetScript("OnEditFocusLost", function()
        JAP:SetProductionPostStackSize()
    end)
    table.insert(self.productionControls, productionPostStackEdit)
    productionPostStackEdit:Hide()

    local productionPostDurationLabel =
        frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    productionPostDurationLabel:SetPoint(
        "LEFT", productionPostStackEdit, "RIGHT", 10, 0
    )
    productionPostDurationLabel:SetText("Duration:")
    table.insert(self.productionControls, productionPostDurationLabel)
    productionPostDurationLabel:Hide()

    local productionPostDurationButton = self:CreateButton(
        frame,
        "6h",
        55,
        605,
        -144,
        function() JAP:CycleProductionPostDuration() end
    )
    self.productionPostDurationButton = productionPostDurationButton
    table.insert(self.productionControls, productionPostDurationButton)
    productionPostDurationButton:Hide()

    local completionSoundButton = self:CreateButton(
        frame,
        "Sound: On",
        82,
        668,
        -144,
        function() JAP:ToggleCompletionSounds() end
    )
    self.completionSoundButton = completionSoundButton
    table.insert(self.productionControls, completionSoundButton)
    completionSoundButton:Hide()

    local missingScanSelected = self:CreateButton(frame, "Scan Selected", 140, 20, -76,
        function() JAP:ScanSelectedMissingRecipes() end)
    self.missingScanSelectedButton = missingScanSelected
    table.insert(self.missingControls, missingScanSelected)
    missingScanSelected:Hide()

    local missingScanAll = self:CreateButton(frame, "Scan All Missing", 140, 175, -76,
        function() JAP:ScanAllMissingRecipes() end)
    self.missingScanAllButton = missingScanAll
    table.insert(self.missingControls, missingScanAll)
    missingScanAll:Hide()

    local missingCancel = self:CreateButton(frame, "Cancel", 90, 330, -76,
        function() JAP:CancelScan("Scan cancelled.") end)
    table.insert(self.missingControls, missingCancel)
    missingCancel:Hide()

    local missingFavoriteAction = self:CreateButton(
        frame,
        "Add Favorite",
        130,
        20,
        -110,
        function() JAP:ToggleMissingRecipeFavorite() end
    )
    self.missingFavoriteActionButton = missingFavoriteAction
    table.insert(self.missingControls, missingFavoriteAction)
    missingFavoriteAction:Hide()

    local missingFavoritesView = self:CreateButton(
        frame,
        "Favorites",
        130,
        165,
        -110,
        function()
            JAP:SetMissingFavoritesOnly(not JAP.missingFavoritesOnly)
        end
    )
    self.missingFavoritesViewButton = missingFavoritesView
    table.insert(self.missingControls, missingFavoritesView)
    missingFavoritesView:Hide()

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
    self.sortLabel = sortLabel
    sortLabel:SetText("")
    sortLabel:Hide()

    local sortDropDown = CreateFrame("Frame", "JAPSortDropDown", frame, "UIDropDownMenuTemplate")
    self.sortDropDown = sortDropDown
    sortDropDown:Hide()

    local addProductionButton = self:CreateButton(
        frame,
        "Add to Production",
        150,
        455,
        -110,
        function() JAP:AddSelectedRecipesToProduction() end
    )
    table.insert(self.recipeControls, addProductionButton)

    local clearRecipesButton = self:CreateButton(frame, "Clear Recipes", 100, 630, -76, function()
        JAP:ClearSavedRecipes()
    end)
    self.clearRecipesButton = clearRecipesButton
    table.insert(self.recipeControls, clearRecipesButton)


    local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.statusText = status
    status:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -174)
    status:SetWidth(710)
    status:SetJustifyH("LEFT")
    status:SetText("Open Alchemy, read recipes, then open the Auction House.")

    local headers = {"Recipe", "Craft cost", "Lowest price", "Profit"}
    local positions = {24, 225, 320, 415}
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
            elseif JAP.currentPage == "missing" and this.missingRecipe then
                local additive = false
                if IsControlKeyDown and IsControlKeyDown() then additive = true end
                if IsShiftKeyDown and IsShiftKeyDown() then additive = true end
                JAP:SelectMissingRecipe(this.missingRecipe, additive)
            elseif JAP.currentPage == "auction-watch"
               and this.auctionWatchItem then
                local additive = false
                if IsControlKeyDown and IsControlKeyDown() then
                    additive = true
                end
                if IsShiftKeyDown and IsShiftKeyDown() then
                    additive = true
                end

                JAP:SelectAuctionWatchItem(
                    this.auctionWatchItem,
                    additive
                )
            elseif JAP.currentPage == "production" and this.productionItem then
                local item = this.productionItem
                local lines = {
                    "|cffffd100" .. item.name .. "|r",
                    "",
                    "Needed total: " .. item.needed,
                    "In bags: " .. item.inBags,
                    "Still missing: " .. item.missing,
                    ""
                }

                table.insert(lines, "|cffffd100Used for:|r")
                local i
                for i = 1, table.getn(item.recipeNames or {}) do
                    local recipeName = item.recipeNames[i]
                    local amount = item.neededByRecipe[recipeName] or 0
                    table.insert(lines,
                        "  - " .. amount .. "x for " .. recipeName)
                end

                table.insert(lines, "")
                if item.liveBuyPrice then
                    table.insert(lines,
                        "|cff55ff55Current verified purchase: " ..
                        moneyToText(item.liveBuyPrice) ..
                        (item.liveBuyStack and
                            (" for stack x" .. item.liveBuyStack) or "") ..
                        "|r")
                elseif item.unitPrice then
                    table.insert(lines,
                        "Cheapest preview unit price: " ..
                        moneyToText(item.unitPrice))
                else
                    table.insert(lines,
                        "Cheapest unit price: |cffff5555not scanned|r")
                end

                if item.estimatedCost then
                    table.insert(lines,
                        "Estimated purchase cost: " ..
                        moneyToText(item.estimatedCost))

                    if item.estimateMode == "whole-stacks" then
                        table.insert(lines,
                            "Stacks to buy: " ..
                            (item.purchaseAuctions or 0) ..
                            " auction(s), " ..
                            (item.purchaseQuantity or item.missing) ..
                            " item(s) total")

                        if item.purchaseOverage
                           and item.purchaseOverage > 0 then
                            table.insert(lines,
                                "|cffffff66Unavoidable overbuy: +" ..
                                item.purchaseOverage .. " item(s)|r")
                        end

                        table.insert(lines,
                            "|cffaaaaaaExact sum of the cheapest complete AH stacks from the latest Production scan.|r")
                    elseif item.source == "vendor-fallback" then
                        table.insert(lines,
                            "|cffaaaaaaStatic vendor estimate; AH price not scanned yet.|r")
                    elseif item.source == "auction" then
                        table.insert(lines,
                            "|cffaaaaaaFallback estimate based on the cheapest scanned unit price.|r")
                    end
                elseif item.estimateMode == "insufficient-auctions" then
                    table.insert(lines,
                        "Estimated purchase cost: |cffff5555not enough auctions|r")
                    table.insert(lines,
                        "Available in scanned auctions: " ..
                        (item.estimatedAvailableQuantity or 0) ..
                        " / " .. item.missing)
                    table.insert(lines,
                        "Cost of available stacks: " ..
                        moneyToText(item.estimatedPartialCost or 0))
                elseif item.missing > 0 then
                    table.insert(lines,
                        "Estimated purchase cost: |cffff5555unknown|r")
                end

                JAP:SetDetailText(table.concat(lines, "\n"))
            end
        end)
        row:SetScript("OnEnter", function()
            if this.recipe or this.material
               or this.missingRecipe
               or this.auctionWatchItem then
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
            elseif JAP.currentPage == "missing" then
                if not JAP:IsMissingRecipeSelected(this.missingRecipe) then
                    this.highlight:Hide()
                end
            elseif JAP.currentPage == "auction-watch" then
                if not JAP:IsAuctionWatchSelected(this.auctionWatchItem) then
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
    self.detailBox = detailBox
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

    local detailScrollFrame =
        CreateFrame("ScrollFrame", "JAPDetailScrollFrame", detailBox)
    self.detailScrollFrame = detailScrollFrame
    detailScrollFrame:SetPoint("TOPLEFT", detailBox, "TOPLEFT", 10, -10)
    detailScrollFrame:SetPoint(
        "BOTTOMRIGHT",
        detailBox,
        "BOTTOMRIGHT",
        -24,
        10
    )
    detailScrollFrame:EnableMouse(true)
    detailScrollFrame:EnableMouseWheel(1)
    detailScrollFrame:SetScript("OnMouseWheel", function()
        JAP:ScrollDetail(arg1)
    end)

    local detailScrollChild =
        CreateFrame("Frame", "JAPDetailScrollChild", detailScrollFrame)
    self.detailScrollChild = detailScrollChild
    detailScrollChild:SetWidth(160)
    detailScrollChild:SetHeight(330)
    detailScrollFrame:SetScrollChild(detailScrollChild)

    local detail =
        detailScrollChild:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlightSmall"
        )
    self.detailText = detail
    detail:SetPoint("TOPLEFT", detailScrollChild, "TOPLEFT", 0, 0)
    detail:SetWidth(158)
    detail:SetJustifyH("LEFT")
    detail:SetJustifyV("TOP")
    detail:SetText("No recipe selected.")

    local detailScrollBar =
        CreateFrame(
            "Slider",
            "JAPDetailScrollBar",
            detailBox,
            "UIPanelScrollBarTemplate"
        )
    self.detailScrollBar = detailScrollBar
    detailScrollBar:SetPoint("TOPRIGHT", detailBox, "TOPRIGHT", -2, -20)
    detailScrollBar:SetPoint(
        "BOTTOMRIGHT",
        detailBox,
        "BOTTOMRIGHT",
        -2,
        20
    )
    detailScrollBar:SetMinMaxValues(0, 0)
    detailScrollBar:SetValueStep(28)
    detailScrollBar:SetValue(0)
    detailScrollBar:SetScript("OnValueChanged", function()
        if JAP.updatingDetailScrollBar then return end
        if not JAP.detailScrollChild or not JAP.detailScrollFrame then return end

        JAP.detailScrollOffset = this:GetValue() or 0
        JAP:ApplyDetailScrollOffset()
    end)
    detailScrollBar:Hide()

    self:UpdateDetailScrollRange()

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

        if self.currentPage == "recipes" then
            self:RecalculateLiveResults()
        else
            self:RefreshUI()
        end
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

    if string.sub(lower(message), 1, 12) == "debugrecipe " then
        local value = string.sub(message, 13)
        chat("Recipe comparison key: " .. normalizeRecipeComparisonName(value))
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
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
eventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
eventFrame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
eventFrame:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
eventFrame:RegisterEvent("NEW_AUCTION_UPDATE")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
eventFrame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGOUT" then
        JAP:SaveMissingRecipeFavorites()
        JAP:SaveRecipes()
        JAP:SaveProductionTemplateStatus()
    elseif event == "VARIABLES_LOADED" then
        db()
        JAP:LoadMissingRecipeFavorites()
        JAP:CreateUI()
        JAP:LoadCompletionSoundSetting()
        JAP:LoadProductionPostSettings()
        JAP:LoadSavedProductionTemplateState()
        JAP:LoadProductionTemplateStatus()
        if JAP:LoadSavedRecipes() then
            setStatus("Loaded " .. table.getn(JAP.recipes) .. " saved recipes.")
            chat("Loaded v" .. JAP.version .. " with " .. table.getn(JAP.recipes) .. " saved recipes. Type /jap to open.")
        else
            chat("Loaded v" .. JAP.version .. ". Open Alchemy and click Read Alchemy.")
        end
    elseif event == "TRADE_SKILL_SHOW" then
        -- The trade-skill list is not always fully populated in the same frame.
        -- Schedule exactly one read after the window has settled.
        JAP:ScheduleAutoReadAlchemy(0.60)
    elseif event == "TRADE_SKILL_UPDATE" then
        -- Do not auto-read here. Reading recipes can itself cause this event,
        -- which previously created a rapid refresh loop and could crash the client.
    elseif event == "AUCTION_ITEM_LIST_UPDATE" then
        JAP:ProcessAuctionPage()
    elseif event == "CHAT_MSG_SYSTEM" then
        if JAP.productionPostRunning
           and JAP.productionPostStage ==
               "wait-for-system-confirmation"
           and arg1 == ERR_AUCTION_STARTED then
            JAP:OnProductionAuctionStarted()
        end
    elseif event == "BAG_UPDATE" then
        -- Crafting naturally consumes reagents. Re-evaluating blocked recipes
        -- against the shrinking bag contents here made valid queued recipes look
        -- missing while the batch was actively being crafted.
        if not JAP.productionCraftRunning then
            JAP:ReevaluateBlockedProductionRecipes()
        end

        if JAP.productionCraftRunning then
            JAP:BuildProductionPlan(true)
            JAP:RefreshUI()
            JAP:ProcessProductionCraft()
        elseif JAP.currentPage == "production"
           and JAP.frame and JAP.frame:IsVisible()
           and not JAP.productionPostRunning then
            JAP:BuildProductionPlan(true)
            JAP:RefreshUI()
        end
    elseif event == "AUCTION_OWNED_LIST_UPDATE" then
        if JAP.auctionWatchCancelRunning then
            if not JAP.auctionWatchCancelWaiting then
                JAP.auctionWatchCancelProcessAt = 0
                JAP:ProcessAuctionWatchCancelOwnerList()
            end
        elseif JAP.auctionWatchOwnerScanRunning then
            if not JAP.auctionWatchOwnerRefreshOnly then
                -- Real event arrived before the timer fallback.
                JAP.auctionWatchOwnerRefreshProcessAt = 0
                JAP.auctionWatchOwnerRefreshStage = 0
                JAP:ProcessAuctionWatchOwnerPage()
            end
        end
        -- Production posting progression waits for ERR_AUCTION_STARTED instead.
    elseif event == "NEW_AUCTION_UPDATE" then
        -- Production posting progression waits for ERR_AUCTION_STARTED instead.
    elseif event == "AUCTION_HOUSE_CLOSED" then
        if JAP.scanRunning then
            JAP:CancelScan("Auction House was closed.")
        end
        if JAP.productionBuyRunning then
            JAP:StopProductionBuy("Auction House was closed.")
        end
        if JAP.productionPostRunning then
            JAP:StopProductionPost("Auction House was closed.")
        end
        if JAP.auctionWatchCancelRunning then
            JAP.auctionWatchCancelRunning = false
            JAP.auctionWatchCancelWaiting = false
            JAP.auctionWatchCancelTargets = {}
            JAP.auctionWatchCancelNextRefreshAt = 0
            JAP.auctionWatchCancelProcessAt = 0
            JAP.auctionWatchCancelEmptyPasses = 0
            JAP.auctionWatchCancelBidSkipped = {}
            setStatus(
                "Auction cancellation stopped: Auction House was closed."
            )
        end
        if JAP.auctionWatchOwnerScanRunning
           or (JAP.scanRunning and JAP.scanMode == "auction-watch") then
            JAP.auctionWatchOwnerScanRunning = false
            JAP.auctionWatchOwnerRefreshOnly = false
            JAP.auctionWatchPreservedResults = nil
            JAP.auctionWatchOwnerRefreshProcessAt = 0
            JAP.auctionWatchOwnerRefreshStage = 0
            if JAP.scanRunning and JAP.scanMode == "auction-watch" then
                JAP:CancelScan("Auction House was closed.")
            end
            setStatus("Auction check stopped: Auction House was closed.")
        end
    end
end)

eventFrame:SetScript("OnUpdate", function()
    JAP:ProcessPendingAlchemyRead()
    JAP:SendPendingQuery()
    JAP:ProcessProductionActions()
    JAP:ProcessAuctionWatchCancelRefresh()
    JAP:ProcessAuctionWatchOwnerRefreshFallback()
end)

SLASH_JOCHENSALCHEMYPROFITS1 = "/jap"
SLASH_JOCHENSALCHEMYPROFITS2 = "/jochenalchemy"
SlashCmdList["JOCHENSALCHEMYPROFITS"] = function(message)
    JAP:HandleSlash(message)
end
