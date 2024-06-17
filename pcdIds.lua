-- local allVanillaTransmuteIds = {
allTransmuteIds = {
    -- vanilla transmutes with 1 day cd
    17560, -- Fire to Earth
    11479, -- Iron to Gold
    11480, -- Mithril to Truesilver
    17559, -- Air to Fire
    17561, -- Earth to Water
    17562, -- Water to Air
    17563, -- Undeath to Water
    17564, -- Water to Undeath
    17565, -- Life to Earth
    17566, -- Earth to Life
    17187, -- Arcanite (no cd after classic)
    25146, -- Elemental Fire (low cd)
-- }
-- local allTbcTransmuteIds = {
    28566, -- Primal Air to Fire
    28567, -- Primal Earth to Water
    28568, -- Primal Fire to Earth
    28569, -- Primal Water to Air
    28581, -- Primal Water to Shadow
    28582, -- Primal Mana to Fire
    28583, -- Primal Fire to Mana
    28584, -- Primal Life to Earth
    28585, -- Primal Earth to Life
    28580, -- Primal Shadow to Water
    29688, -- Primal Might (no cd after tbc)
    32765, -- Earthstorm Diamond
    32766, -- Skyfire Diamond
    -- }
    -- wotlk
    60350, -- Titanium (no cd)
    53784, -- Eternal Water to Fire
    53783, -- Eternal Water to Air
    53782, -- Eternal Earth to Shadow
    53781, -- Eternal Earth to Air
    53780, -- Eternal Shadow to Life
    53779, -- Eternal Shadow to Earth
    53777, -- Eternal Air to Earth
    53776, -- Eternal Air to Water
    53775, -- Eternal Fire to Life
    53774, -- Eternal Fire to Water
    53773, -- Eternal Life to Fire
    53771, -- Eternal Life to Shadow
    66659, -- Cardinal Ruby
    66664, -- Eye of Zul
    66663, -- Majestic Zircon
    66662, -- Dreadstone
    66660, -- King's Amber
    66658, -- Ametrine
    57427, -- Earthsiege Diamond (no cd)
    57425, -- Skyflare Diamond (no cd)
    
    -- allCataTransmutes
    78866, -- living elements
    80244, -- Pyrium Bar
    80243, -- Truegold
}
-- vanilla
moonclothId = 18560
moonclothItemId = 14342
saltShakerItemId = 15846
transmuteId = 17562 -- just some transmute id from classic, that shares the cooldown
transmuteItemId = 12360 -- arcanite OG item id
-- tbc 
-- all cooldowns have a cd start period and a cd end period
-- example: transmute arcanite starts in vanilla / era, and ends in TBC: start = 1 - end = 2
-- some cooldowns share same item icon. Show the difference with a border color.
-- eg. dream of azshara should have a 'water' border color.
-- transmutes are all kind of similar. no reason to specify them further, when not relevant.

-- vanilla
-- salt shaker
-- mooncloth cd
-- any transmute

-- tbc
primalMightId = 29688
primalMightItemId = 23571

primalMoonclothId = 26751
primalMoonclothItemId = 21845

spellclothId = 31373
spellclothItemId = 24271

shadowclothId = 36686
shadowclothItemId = 24272

brilliantGlassId = 47280
brilliantGlassItemId = 35945

prismaticSphereId = 28027
prismaticSphereItemId = 22460

voidSphereId = 28028
voidSphereItemId = 22459

-- wotlk - all on separate cooldowns
spellweaveId = 56003
spellweaveItemId = 41595

moonshroudId = 56001
moonshoudItemId = 41594

ebonweaveId = 56002
ebonweaveItemId = 41593

minorInscriptionResearchId = 61288
minorInscriptionResearchItemId = 39469 -- using moonglow ink icon

northrendInscriptionResearchId = 61177
northrendInscriptionResearchItemId = 44680 -- Assorted Writings

icyPrismId = 62242
icyPrismItemId = 44943

titanSteelId = 55208
titanStellItemId = 37663

glacialBagId = 56005
glacialBagItemId = 41600

northrendAlchemyId = 60893
northrendAlchemyItemId = 7810

-- cataclysm
firePrismId = 73478
firePrismItemId = 52304

livingElementsItemId = 30183 -- nether vortex

dreamOfAzsharaId = 75146 -- volatile water
dreamOfSkywallId = 75141 -- volatile air
dreamOfRagnarosId = 75145 -- volatile fire
dreamOfDeepholmId = 75142 -- volatile earth
dreamOfHyjalId = 75144 -- volatile life
dreamClothItemId = 54440

forgedDocumentsHordeId = 86654
forgedDocumentsAllianceId = 89244
forgedDocumentsItemId = 63276

forgedDocumentsId = forgedDocumentsHordeId -- just to fetch name

local function GetBorderColorFromSpellIdInternal(spellId) 
    if spellId == dreamOfHyjalId then return 61, 191, 31
    elseif spellId == dreamOfDeepholmId then return 123, 74, 18
    elseif spellId == dreamOfSkywallId then return 168, 203, 222
    elseif spellId == dreamOfRagnarosId then return 216, 32, 0
    elseif spellId == dreamOfAzsharaId then return 20, 70, 193
    else return nil
    end
end

function GetSpellColorFromSpellId(spellId)
    local r, g, b = GetBorderColorFromSpellIdInternal(spellId)
    if not r then return nil
    else return r / 255, g / 255, b / 255
    end
end

function GetItemIconFromSpellId(spellId)
    if ListContains(spellId, allTransmuteIds) then return transmuteItemId
    elseif spellId == northrendAlchemyId then return northrendAlchemyItemId

    elseif spellId == minorInscriptionResearchId then return minorInscriptionResearchItemId
    elseif spellId == northrendInscriptionResearchId then return northrendInscriptionResearchItemId
    
    elseif spellId == brilliantGlassId then return brilliantGlassItemId
    elseif spellId == icyPrismId then return icyPrismItemId
    elseif spellId == firePrismId then return firePrismItemId
    
    elseif spellId == moonclothId then return moonclothItemId
    
    elseif spellId == primalMoonclothId then return primalMoonclothItemId
    elseif spellId == spellclothId then return spellclothItemId
    elseif spellId == shadowclothId then return shadowclothItemId
    
    elseif spellId == glacialBagId then return glacialBagItemId
    elseif spellId == spellweaveId then return spellweaveItemId
    elseif spellId == ebonweaveId then return ebonweaveItemId
    elseif spellId == moonshroudId then return moonshroudItemId
    
    elseif spellId == dreamOfAzsharaId or spellId == dreamOfSkywallId or spellId == dreamOfRagnarosId or spellId == dreamOfDeepholmId or spellId == dreamOfHyjalId
    then return dreamClothItemId
    
    elseif spellId == titanSteelId then return titanStellItemId

    elseif spellId == voidSphereId then return voidSphereItemId
    elseif spellId == prismaticSphereId then return prismaticSphereItemId

    elseif spellId == saltShakerItemId then return saltShakerItemId
    elseif spellId == forgedDocumentsAllianceId or spellId == forgedDocumentsHordeId then return forgedDocumentsItemId
    else logIfLevel(2, "GetItemIconFromSpellId - not found " .. spellId) end
end

function IsNotNullTable(item)
    return item ~= nil and type(item) == "table"
end

function ListContains(value, list)
    if not IsNotNullTable(list) then return false end

    for _,v in pairs(list) do
        if v == value then
          return true
        end
    end
    return false
end

function GetAllTextBeforeSeparator(text, separator)
    return string.match(text, "([^" .. separator .."]+)")
end
function GetAllTextAfterSeparator(text, separator)
    return string.match(text, "[^" .. separator .. "]+[" .. separator .. "](.+)")
end

allTailoringIds = {
    moonclothId,
    -- tbc
    spellclothId,
    shadowclothId,
    primalMoonclothId,
    -- wotlk
    spellweaveId,
    ebonweaveId,
    moonshroudId,
    glacialBagId,
    -- cata
    dreamOfAzsharaId,
    dreamOfSkywallId,
    dreamOfRagnarosId,
    dreamOfDeepholmId,
    dreamOfHyjalId
}

allJewelcraftingIds = {
    brilliantGlassId, -- tbc
    icyPrismId, -- wotlk
    firePrismId -- cata
}

allEnchantingIds = {
    prismaticSphereId,
    voidSphereId
}

allInscriptionIds = {
    minorInscriptionResearchId,
    northrendInscriptionResearchId,
    forgedDocumentsAllianceId,
    forgedDocumentsHordeId
}

allMiningIds = {
    titanSteelId
}

allLeatherWorkingIds = {
    saltShakerItemId
}

function GetProfessionNameForSpellId(spellId)
    if (ListContains(spellId, allMiningIds)) then
        return "mining"
    elseif ListContains(spellId, allInscriptionIds) then
        return "inscription"
    elseif ListContains(spellId, allEnchantingIds) then
        return "enchanting"
    elseif ListContains(spellId, allJewelcraftingIds) then
        return "jewelcrafting"
    elseif ListContains(spellId, allTailoringIds) then
        return "tailoring"
    elseif ListContains(spellId, allTransmuteIds) or spellId == northrendAlchemyId then
        return "alchemy"
    elseif ListContains(spellId, allLeatherWorkingIds) then
        return "leatherworking"
    else logIfLevel (2, "GetProfessionNameForSpellId - not found" .. spellId)
    end
end

function GetProfessionSortKey(spellId)
    local professionName = GetProfessionNameForSpellId(spellId)
    if (professionName == "alchemy") then return 1
    elseif (professionName == "tailoring") then return 2
    elseif (professionName == "inscription") then return 3
    elseif (professionName == "jewelcrafting") then return 4
    elseif (professionName == "enchanting") then return 5
    elseif (professionName == "mining") then return 6
    elseif (professionName == "leatherworking") then return 7
    else logIfLevel (2, "GetProfessionSortKey - not found " .. professionName)
    end
end

function sortProfession(lhs, rhs)
    local left = GetProfessionSortKey(lhs)
    local right = GetProfessionSortKey(rhs)
    return left < right or (left == right and lhs < rhs)
end

function GetCdNameFromSpellId(spellId)
    local name = GetSpellInfo(spellId)

    -- if the spell is a transmute, the first part of the spell name is description enough
    if ListContains(spellId, allTransmuteIds) then 
        local xmute = string.match(name, "([^:]+)")
        return xmute
    end
    if not name then return "global" end
    return name
end

function IsVersion(x) return x == WOW_PROJECT_ID end
function IsTbcOrLater() return WOW_PROJECT_ID >= WOW_PROJECT_BURNING_CRUSADE_CLASSIC end
function IsWrathOrLater() return WOW_PROJECT_ID >= WOW_PROJECT_WRATH_CLASSIC end
function IsCataOrLater() return WOW_PROJECT_ID >= WOW_PROJECT_CATACLYSM_CLASSIC end

local vanillaNamesToConsider = {
    [saltShakerItemId] = IsVersion(WOW_PROJECT_CLASSIC),
    [moonclothId] = IsVersion(WOW_PROJECT_CLASSIC),
    [transmuteId] = true
}

local tbcCdNamesToConsider = {
    [primalMoonclothId] = IsVersion(WOW_PROJECT_BURNING_CRUSADE_CLASSIC),
    [spellclothId] = IsVersion(WOW_PROJECT_BURNING_CRUSADE_CLASSIC),
    [shadowclothId] = IsVersion(WOW_PROJECT_BURNING_CRUSADE_CLASSIC),
    [brilliantGlassId] = IsVersion(WOW_PROJECT_BURNING_CRUSADE_CLASSIC),
    [voidSphereId] = IsTbcOrLater(),
    [prismaticSphereId] = IsTbcOrLater()
}
    
local northrendCdNamesToConsider = {
    [minorInscriptionResearchId] = IsWrathOrLater(),
    [northrendInscriptionResearchId] = IsWrathOrLater(),
    [titanSteelId] = IsVersion(WOW_PROJECT_WRATH_CLASSIC),
    [icyPrismId] = IsWrathOrLater(),
    [moonshroudId] = IsVersion(WOW_PROJECT_WRATH_CLASSIC),
    [ebonweaveId] = IsVersion(WOW_PROJECT_WRATH_CLASSIC),
    [spellweaveId] = IsVersion(WOW_PROJECT_WRATH_CLASSIC),
    [glacialBagId] = IsWrathOrLater(),
    [northrendAlchemyId] = IsWrathOrLater()
}

local cataCdNamesToConsider = {
    [dreamOfHyjalId] = IsCataOrLater(),
    [dreamOfAzsharaId] = IsCataOrLater(),
    [dreamOfDeepholmId] = IsCataOrLater(),
    [dreamOfRagnarosId] = IsCataOrLater(),
    [dreamOfSkywallId] = IsCataOrLater(),
    [firePrismId] = IsCataOrLater(),
    [forgedDocumentsId] = IsCataOrLater()
}

function GetCdNamesToConsider()
    local concatTable = {}

    local function addIfTrue(n, v)
        if (v) then
            concatTable[n] = v
        end
    end

    for n,v in pairs(vanillaNamesToConsider) do addIfTrue(n, v) end

    if IsTbcOrLater() then
        for n,v in pairs(tbcCdNamesToConsider) do addIfTrue(n, v) end
    end
    if IsWrathOrLater() then
        for n,v in pairs(northrendCdNamesToConsider) do addIfTrue(n, v) end
    end
    if IsCataOrLater() then
        for n,v in pairs(cataCdNamesToConsider) do addIfTrue(n, v) end
    end

    return concatTable
end

PcdCdsToConsider = GetCdNamesToConsider()
function GetSortedProfessions()
    local tkeys = {}
    for k in pairs(PcdCdsToConsider) do table.insert(tkeys, k) end
    table.sort(tkeys, sortProfession)
    local sortedTable = {}
    for k, v in pairs(tkeys) do
        sortedTable[k] = v
    end
    return sortedTable
end
PcdProfessionSortKey = GetSortedProfessions()

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
NumberOfActivePcdCds = tablelength(PcdCdsToConsider)