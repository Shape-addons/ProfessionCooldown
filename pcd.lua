-- PCD start
local pcdVersion = 118
pcdShowMinimapButton = nil
local pcdIsLoaded = nil
-- local pcdShowOldCds = nil

local LDB = LibStub:GetLibrary("LibDataBroker-1.1");
local PCDLDBIcon = LibStub:GetLibrary("LibDBIcon-1.0")
local userLocale = GetLocale()
local mainFrameBordersEnabled = true


pcdSettings = {}
pcdDefaults = {}
pcdDefaults.spacing = 14
pcdDefaults.entrySize = 11
pcdDefaults.titleSize = 20

function LoadPcdSettings()
    pcdSettings.spacing = pcdDefaults.spacing
    pcdSettings.entrySize = pcdDefaults.entrySize
    pcdSettings.titleSize = pcdDefaults.titleSize
end

local profCdTrackerFrame = CreateFrame("Frame")
profCdTrackerFrame:RegisterEvent("TRADE_SKILL_SHOW")
profCdTrackerFrame:RegisterEvent("TRADE_SKILL_UPDATE")
profCdTrackerFrame:RegisterEvent("TRADE_SKILL_CLOSE")
profCdTrackerFrame:RegisterEvent("ADDON_LOADED")

profCdTrackerFrame:SetScript("OnEvent", function(self, event, arg1, ...)
    if (event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE" or event == "TRADE_SKILL_CLOSE") then
        UpdateAndRepaintIfOpen()
    elseif not pcdIsLoaded and ((event == "ADDON_LOADED" and arg1 == "ProfessionCooldown") or event == "PLAYER_LOGIN") then
        pcdIsLoaded = true
        InitDbTable()
        LoadPcdSettings()
        if PcdDb and PcdDb["settings"] and not (PcdDb["settings"]["ShowMinimapButton"] == "n") then
            pcdShowMinimapButton = true
            logIfLevel(2, "show mini map button set to true")
        end
        UpdateCds()
        CreateBroker()
    end
end)

function UpdateAndRepaintIfOpen()
    UpdateCds()
    RepaintIfOpen()
end

function RepaintIfOpen()
    if pcdFrame and pcdFrame:IsShown() then
        pcdFrame:Hide()
        CreatePCDFrame()
    end
end

function UpdateCds()
    logIfLevel(2, "Called update cds")
    GetCooldownsFromSpellIds()
end

local lootMsgFrame = CreateFrame("Frame")
lootMsgFrame:RegisterEvent("CHAT_MSG_LOOT")
lootMsgFrame:RegisterEvent("CHAT_MSG_SYSTEM")
lootMsgFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "CHAT_MSG_LOOT" then
        if (arg1:find("^You create:") ~= nil or arg1:find("^You have learned")) then
            UpdateAndRepaintIfOpen()
            logIfLevel(2, "Creation message event fired. Calling update at: ")
            logIfLevel(1, GetTime())
        end
    elseif event == "CHAT_MSG_SYSTEM" and arg1:find("^You have learned") ~= nil then
        UpdateAndRepaintIfOpen()
    end
end)

local tbcCdNamesToConsider = {
    ["primal mooncloth"] = true,
    ["spellcloth"] = true,
    ["shadowcloth"] = true,
    -- ["transmute (TBC)"] = true,
    -- ["transmute (Vanilla)"] = true,
    ["brilliant glass"] = true,
    ["void sphere"] = true,
}

local northrendCdNamesToConsider = {
    ["minor inscription research"] = true,
    ["northrend inscription research"] = true,
    ["smelt titansteel"] = true,
    ["icy prism"] = true,
    ["moonshroud"] = true,
    ["ebonweave"] = true,
    ["spellweave"] = true,
    ["glacial bag"] = true,
    ["northrend alchemy research"] = true,
    ["transmute"] = true,
    -- ["Transmute (Wrath)"] = true,
}

function GetCdNamesToConsider()
    -- if PcdDb["settings"]["ShowOldCds"] == "y" then
    local concatTable = {}
    for n,v in pairs(tbcCdNamesToConsider) do
        concatTable[n] = v
    end
    for n,v in pairs(northrendCdNamesToConsider) do
        concatTable[n] = v
    end
    return concatTable
    -- else
    --     return northrendCdNamesToConsider
    -- end
end

local STD_WHITE = "|cffffffff"
local classColors = {
    [1] = "|cffC69B6D", -- warrior
    [2] = "|cfff48cba", -- paladin
    [3] = "|cffaad372", -- hunter
    [4] = "|cfffff468", -- rogue
    [5] = "|cffffffff", -- priest
    [6] = "|cffc41e3a", -- death knight
    [7] = "|cff0070DD", -- shaman
    [8] = "|cff3fc7eb", -- mage
    [9] = "|cff8788ee", -- lock
    [11]= "|cffff7c0a", -- druid
    [10]= "|cff00ff98", -- monk
    -- [12] = "|cffa330c9", -- demon hunter
}

local debugLevel = 3
function logIfLevel(dbLevel, text)
    if debugLevel <= dbLevel then
        print (text)
    end
end

function RemoveCdInDb(prof, name)
    if PcdDb then
        for charName, profs in pairs(PcdDb) do
            if profs and type(profs) == "table" and profs[prof] and profs[prof]["cooldowns"] and profs[prof]["cooldowns"][name] then
                PcdDb[charName]["professions"][prof]["cooldowns"][name] = nil
            end
        end
    end
end
print('wow classic Era project id is ' .. WOW_PROJECT_CLASSIC)
print('wow classic TBC project id is ' .. WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
print('wow classic WOTLK project id is ' .. WOW_PROJECT_WRATH_CLASSIC)
print('wow classic Cata project id is ' .. WOW_PROJECT_CATACLYSM_CLASSIC)

function RenameCdInDb(prof, prevName, updatedName)
    if PcdDb then
        for charName, profs in pairs(PcdDb) do
            if PcdDb[charName]["professions"] and PcdDb[charName]["professions"][prof] then
                local lastReadyAt
                if PcdDb[charName]["professions"][prof]["cooldowns"][prevName] then
                    lastReadyAt = PcdDb[charName]["professions"][prof]["cooldowns"][updatedName]
                    PcdDb[charName]["professions"][prof]["cooldowns"][prevName] = nil
                end
                PcdDb[charName]["professions"][prof]["cooldowns"][updatedName] = lastReadyAt
            end
        end
    end
end

function UpdateSaltShakerCd()
    local charName = UnitName("player")
    local lw = PcdDb[charName]["professions"]["leatherworking"]
    if lw and lw["skill"] >= 250 then
        local startTime, duration, _ = GetItemCooldown(15846)
        local secondsLeft = GetCooldownLeftOnItem(startTime, duration)
        if (secondsLeft > 0) then
            PcdDb[charName]["professions"]["leatherworking"]["cooldowns"] = { ["Salt Shaker"] = secondsLeft + GetServerTime() }
        end
    end
end

-- https://github.com/Stanzilla/WoWUIBugs/issues/47
-- Not sure how this makes sense, let the 4k IQ people handle that.
function GetCooldownLeftOnItem(start, duration)
    -- Before restarting the GetTime() will always be greater than [start]
    -- After the restart, [start] is technically always bigger because of the 2^32 offset thing
    if start < GetTime() then
        local cdEndTime = start + duration
        local cdLeftDuration = cdEndTime - GetTime()
        
        return cdLeftDuration
    end

    local time = time()
    local startupTime = time - GetTime()
    -- just a simplification of: ((2^32) - (start * 1000)) / 1000
    local cdTime = (2 ^ 32) / 1000 - start
    local cdStartTime = startupTime - cdTime
    local cdEndTime = cdStartTime + duration
    local cdLeftDuration = cdEndTime - time
    
    return cdLeftDuration
end

-- /script GetCooldownsFromSpellIds()
function GetCooldownsFromSpellIds()
    logIfLevel(2, "updating from spell id")
    logIfLevel(1, GetTime())
    InitDbTable()
    local charName = UnitName("Player")
    if PcdDb and PcdDb[charName] and PcdDb[charName]["professions"] then
        if PcdDb[charName]["professions"]["alchemy"] then
            logIfLevel(1, "alchemy found")
            if PcdDb[charName]["professions"]["alchemy"]["skill"] >= 225 then
                local highestTransmuteCd = GetTransmuteCd()
                if highestTransmuteCd > 0 then
                    SetCooldownTo("transmute", "alchemy", highestTransmuteCd)
                end
                logIfLevel(2, "highest transmute cd: " .. highestTransmuteCd)
            end
            if PcdDb[charName]["professions"]["alchemy"]["skill"] >= 400 then
                SetCooldownForSpell("northrend alchemy research", "alchemy", northrendAlchemyId)
            end
        end
        if PcdDb[charName]["professions"]["tailoring"] then
            logIfLevel(1, "Tailoring found")
            if PcdDb[charName]["professions"]["tailoring"]["skill"] >= 350 then
                SetCooldownForSpell("primal mooncloth", "tailoring", primalMoonclothId)
                SetCooldownForSpell("spellcloth", "tailoring", spellclothId)
                SetCooldownForSpell("shadowcloth", "tailoring", shadowclothId)
            end
            if PcdDb[charName]["professions"]["tailoring"]["skill"] >= 415 then
                SetCooldownForSpell("moonshroud", "tailoring", moonshroudId)
                SetCooldownForSpell("spellweave", "tailoring", spellweaveId)
                SetCooldownForSpell("ebonweave", "tailoring", ebonweaveId)
            end
            if PcdDb[charName]["professions"]["tailoring"]["skill"] >= 445 then
                SetCooldownForSpell("glacial bag", "tailoring", glacialBagId)
            end
        end
        if PcdDb[charName]["professions"]["jewelcrafting"] then
            logIfLevel(1, "Jewelcrafting found")
            if PcdDb[charName]["professions"]["jewelcrafting"]["skill"] >= 350 then
                SetCooldownForSpell("brilliant glass", "jewelcrafting", brilliantGlassId)
            end
            if PcdDb[charName]["professions"]["jewelcrafting"]["skill"] >= 425 then
                SetCooldownForSpell("icy prism", "jewelcrafting", icyPrismId)
            end
        end
        if PcdDb[charName]["professions"]["enchanting"] then
            logIfLevel(1, "Enchanting found")
            if PcdDb[charName]["professions"]["enchanting"]["skill"] >= 350 then
                SetCooldownForSpell("void sphere", "enchanting", voidSphereId)
            end
        end
        if PcdDb[charName]["professions"]["inscription"] then
            logIfLevel(1, "Inscription found")
            if PcdDb[charName]["professions"]["inscription"]["skill"] >= 75 then
                SetCooldownForSpell("minor inscription research", "inscription", minorInscriptionResearchId)
            end
            if PcdDb[charName]["professions"]["inscription"]["skill"] >= 385 then
                SetCooldownForSpell("northrend inscription research", "inscription", northrendInscriptionResearchId)
            end
        end
        if PcdDb[charName]["professions"]["inscription"] then
            logIfLevel(1, "Mining found")
            if PcdDb[charName]["professions"]["inscription"]["skill"] >= 450 then
                SetCooldownForSpell("smelt titansteel", "inscription", titanSteelId)
            end
        end
    end
end

function GetTransmuteCd()
    local best = -1
    local bestId = -1
    for i = 1, #allTransmuteIds do
        local timestamp = GetCooldownTimestamp(allTransmuteIds[i])
        if timestamp > best then
            best = timestamp
            bestId = allTransmuteIds[i]
        end
    end
    logIfLevel(2, "should set transmute to " .. (best - GetServerTime()) .. " secs from now")
    return best
end

function SetCooldownForSpell(cdName, professionName, spellId)
    local timestamp = GetCooldownTimestamp(spellId)
    SetCooldownTo(cdName, professionName, timestamp)
end

function SetCooldownTo(cdName, professionName, timestamp)
    local charName = UnitName("Player")
    if not PcdDb[charName]["professions"][professionName]["cooldowns"] or not type(PcdDb[charName]["professions"][professionName]["cooldowns"]) == "table" then
        PcdDb[charName]["professions"][professionName]["cooldowns"] = {}
    end
    PcdDb[charName]["professions"][professionName]["cooldowns"][cdName] = timestamp
    logIfLevel(1, "set cooldown timestamp of " .. cdName .. " to " .. PcdDb[charName]["professions"][professionName]["cooldowns"][cdName])
end

function GetCooldownTimestamp(spellId)
    local start, duration, enabled, x = GetSpellCooldown(spellId)
    local leftOnSpell = GetCooldownLeftOnItem(start, duration)
    local doneAt = leftOnSpell + GetServerTime()
    
    return doneAt
end

local classicTransmuteSkillNames = {
    ["Transmute: Arcanite"] = true,
    ["Transmute: Undeath to Water"] = true,
    ["Transmute: Water to Air"] = true,
    ["Transmute: Elemental Fire"] = true,
    ["Transmute: Earth to Water"] = true,
    ["Transmute: Air to Fire"] = true,
    ["Transmute: Iron to Gold"] = true,
    ["Transmute: Earth to Life"] = true,
    ["Transmute: Mithril to Truesilver"] = true,
    ["Transmute: Fire to Earth"] = true,
    ["Transmute: Life to Earth"] = true,
    ["Transmute: Water to Undeath"] = true,
}

local classicTransmuteSkillNamesAfterPatch = {
    ["Transmute: Undeath to Water"] = true,
    ["Transmute: Water to Air"] = true,
    ["Transmute: Earth to Water"] = true,
    ["Transmute: Air to Fire"] = true,
    ["Transmute: Iron to Gold"] = true,
    ["Transmute: Earth to Life"] = true,
    ["Transmute: Mithril to Truesilver"] = true,
    ["Transmute: Fire to Earth"] = true,
    ["Transmute: Life to Earth"] = true,
    ["Transmute: Water to Undeath"] = true,
}

local tbcTransmuteSkillNames = {
    ["Transmute: Primal Might"] = true,
    -- shadow
    ["Transmute: Primal Shadow to Water"] = true,
    -- earth
    ["Transmute: Primal Earth to Life"] = true,
    ["Transmute: Primal Earth to Water"] = true,
    -- water
    ["Transmute: Primal Water to Shadow"] = true,
    ["Transmute: Primal Water to Air"] = true,
    -- life
    ["Transmute: Primal Life to Earth"] = true,
    -- air
    ["Transmute: Primal Air to Fire"] = true,
    -- mana
    ["Transmute: Primal Mana to Fire"] = true,
    -- fire
    ["Transmute: Primal Fire to Mana"] = true,
    ["Transmute: Primal Fire to Earth"] = true,
    -- gems
    ["Transmute: Skyfire Diamond"] = true,
    ["Transmute: Earthstorm Diamond"] = true,
}

local wotlkTransmuteSkillNames = {
    -- gems
    ["Transmute: Ametrine"] = true,
    ["Transmute: Cardinal Ruby"] = true,
    ["Transmute: Dreadstone"] = true,
    ["Transmute: Eye of Zul"] = true,
    ["Transmute: King's Amber"] = true,
    -- shadow
    ["Transmute: Eternal Shadow to Earth"] = true,
    ["Transmute: Eternal Shadow to Life"] = true,
    -- air
    ["Transmute: Eternal Air to Water"] = true,
    ["Transmute: Eternal Air to Earth"] = true,
    -- water
    ["Transmute: Eternal Water to Air"] = true,
    ["Transmute: Eternal Water to Fire"] = true,
    -- fire
    ["Transmute: Eternal Fire to Water"] = true,
    ["Transmute: Eternal Fire to Life"] = true,
    -- life
    ["Transmute: Eternal Life to Shadow"] = true,
    ["Transmute: Eternal Life to Fire"] = true,
    -- earth
    ["Transmute: Eternal Earth to Shadow"] = true,
    ["Transmute: Eternal Earth to Air"] = true,
    -- other
    ["Transmute: Titanium"] = true,
}

function IsVanillaTransmute(skillName)
    if GetAccountExpansionLevel() == 0 then
        return skillName and classicTransmuteSkillNames[skillName]
    elseif GetAccountExpansionLevel() == 1 then
        return skillName and classicTransmuteSkillNamesAfterPatch[skillName]
    end
end

function IsTransmuteTBC(skillName)
    return skillName and tbcTransmuteSkillNames[skillName]
end

function IsTransmuteWrath(skillName)
    return skillName and wrathTransmuteSkillNames[skillName]
end

function UpdateCharacterProfessionDb()
    local charName = UnitName("player")
    local profs = {}
    local primaryCount = 0
    local i = 1
    local j = 0
    local section = 0
    local localizedSkillNames = PCDL[userLocale]
    for i = 1, GetNumSkillLines() do
        local skillName, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
        if (isHeader and skillName == TRADE_SKILLS) then
            section = 2;
        end
        skillName = skillName:lower()
        if (not isHeader and section == 2) then
            logIfLevel (1, "found " .. skillName .. " with primary count " .. primaryCount)
            if (localizedSkillNames[skillName]) then
                logIfLevel(1, "localized skill name: " .. localizedSkillNames[skillName] .. " for user locale " .. userLocale)
            end
            if (primaryCount < 3 and skillName) and localizedSkillNames[skillName] ~= nil and #profs <= 2 then
                logIfLevel(2, "added " .. skillName .. " to PCD database.")
                primaryCount = primaryCount + 1;
                local pcdSkillData = {
                    profName = skillName
                }
                pcdSkillData.skillLevel = skillRank
                table.insert(profs, pcdSkillData)
            end
        end
    end
    for j = 0, 2 do
        if (profs[j]) then
            if not PcdDb[charName]["professions"][profs[j].profName] then
                PcdDb[charName]["professions"][profs[j].profName] = {}
            end
            PcdDb[charName]["professions"][profs[j].profName]["skill"] = profs[j].skillLevel
            logIfLevel (2, "Updated prof for  " .. charName .. ": " .. profs[j].profName .. ", " .. profs[j].skillLevel)
        end
    end
end

function InitFilterIfUndefined(charName, spellName, initValue)
    if PcdDb[charName]["filters"][spellName] == nil then
        PcdDb[charName]["filters"][spellName] = initValue
    end
end

function InitGlobalFilterIfUndefined(spellName)
    if PcdDb["settings"]["filters"][spellName] == nil then
        PcdDb["settings"]["filters"][spellName] = "x"
    end
end

function InitDbTable()
    local charName = UnitName("player")

    if (not PcdDb) then
        logIfLevel (1, "created outer level PcdDb")
        PcdDb = {}
    end
    if (not PcdDb[charName]) then
        PcdDb[charName] = {}
        logIfLevel (1, "created PcdDb[char]")
    end
    if not PcdDb[charName]["class"] then
        PcdDb[charName]["class"] = select(3, UnitClass("Player"))
    end
    for dbCharName, charOptions in pairs(PcdDb) do
        logIfLevel(1, "settings for " .. dbCharName)
        if not PcdDb[dbCharName]["filters"] then
            PcdDb[dbCharName]["filters"] = {}
        end
        local initVal = "y"
        if dbCharName == "settings" then 
            initVal = "x" 
        else 
            InitFilterIfUndefined(dbCharName, "global", "x")
        end
        local cdNamesToConsider = GetCdNamesToConsider()
        for cdName in pairs(cdNamesToConsider) do
            InitFilterIfUndefined(dbCharName, cdName, initVal)
        end
    end
    if not PcdDb[charName]["professions"] then
        PcdDb[charName]["professions"] = {}
        logIfLevel (1, "created PcdDb[char][professions]")
    end
    if (not PcdDb["settings"]) then
        PcdDb["settings"] = {}
        PcdDb["settings"]["version"] = pcdVersion
    end
    if (not PcdDb["settings"]["CloseOnEscape"]) then
        PcdDb["settings"]["CloseOnEscape"] = "y"
    end
    if (not PcdDb["settings"]["filters"]) then
        PcdDb["settings"]["filters"] = {}
    end
    for cdName in pairs(GetCdNamesToConsider()) do
        InitGlobalFilterIfUndefined(cdName)
    end
    if (not PcdDb[charName]["professions"] or #PcdDb[charName]["professions"] < 2) then
        UpdateCharacterProfessionDb()
        logIfLevel(1, "Updated character prof db for " .. charName)
    end
    if not PcdDb["settings"]["ShowMinimapButton"] then
        PcdDb["settings"]["ShowMinimapButton"] = "y"
    end
end

function RegisterFrameForDrag(theFrame, savePos)
    theFrame:SetMovable(true)
    theFrame:EnableMouse(true)

    theFrame:RegisterForDrag("LeftButton")
    theFrame:SetScript("OnDragStart", theFrame.StartMoving)
    if (not theFrame.StopMovingFunc) then
        if (savePos) then
            theFrame.StopMovingFunc = SavePositionAndStopMoving
        else
            theFrame.StopMovingFunc = theFrame.StopMovingOrSizing
        end
    end
    theFrame:SetScript("OnDragStop", theFrame.StopMovingFunc)
end

function SavePositionAndStopMoving(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
    if not PcdDb["settings"] then
        PcdDb["settings"] = {}
    end
    PcdDb["settings"]["position"] = {
        ["Point"] = point,
        ["RelativePoint"] = relativePoint,
        ["XOfs"] = xOfs,
        ["YOfs"] = yOfs
    }
end

function SetFrameTitle(theFrame, titleText)
    local title = theFrame:CreateFontString(nil, "OVERLAY")
    title:SetFontObject("GameFontHighlight")
    title:SetPoint("CENTER", theFrame, "TOP", 0 ,-pcdSettings.titleSize)
    title:SetText(titleText)
    title:SetFont("Fonts\\FRIZQT__.ttf", pcdSettings.titleSize, "OUTLINE")
    theFrame.title = title
end

function AddTextToFrame(theFrame, text, firstPosition, x, y)
    local font = theFrame:CreateFontString(nil, "OVERLAY")
    font:SetFontObject("GameFontHighlight")
    font:SetPoint(firstPosition, x, y)
    font:SetText(text)
    font:SetFont("Fonts\\FRIZQT__.ttf", pcdSettings.entrySize, "OUTLINE")
    logIfLevel (1, "added test frame stuff")
    return font
end

function AddTextWithCDToFrame(theFrame, charName, cdText, rightText, position, cdColor)
    if (not theFrame.fontStrings) then
        theFrame.fontStrings = {}
    end
    local nameFont
    local cdNameFont
    local cdFont
    if not theFrame.fontStrings[position] then
        theFrame.fontStrings[position] = { 
            ["L"] = theFrame:CreateFontString(nil, "Overlay"), 
            ["R"] = theFrame:CreateFontString(nil, "Overlay")
        }
    end
    nameFont = theFrame.fontStrings[position]["L"]
    cdFont = theFrame.fontStrings[position]["R"]

    local topSpacing = -6
    local actualPosition = topSpacing - pcdSettings.spacing * (position + 1)
    nameFont:SetFontObject("GameFontHighlight")
    nameFont:SetPoint("TOPLEFT", 10, actualPosition)
    nameFont:SetFont("Fonts\\FRIZQT__.ttf", pcdSettings.entrySize, "OUTLINE")
    local cColorString = GetClassColorString(charName)
    nameFont:SetText(cColorString .. charName .. STD_WHITE .. " - " .. CamelCase(cdText))

    cdFont:SetFontObject("GameFontHighlight")
    cdFont:SetText(rightText)
    cdFont:SetPoint("TOPRIGHT", -10, actualPosition)
    cdFont:SetFont("Fonts\\FRIZQT__.ttf", pcdSettings.entrySize, "OUTLINE")
    cdFont:SetTextColor(cdColor[1], cdColor[2], cdColor[3], cdColor[4])

    nameFont:Show()
    cdFont:Show()
end

function IsNotNullTable(item)
    return item ~= nil and type(item) == "table"
end

function GetAllNamesAndCdsOnAccount()
    local charSpellAndCd = {}
    local allOnAccount = PcdDb
    if (not allOnAccount) then
        return
    end
    local cdNamesToConsider = GetCdNamesToConsider()
    for charName, charData in pairs(PcdDb) do
        if not (charName == "settings") and IsNotNullTable(charData) and IsNotNullTable(charData["professions"]) then
            for profName, pcdProfData in pairs(charData["professions"]) do
                if IsNotNullTable(pcdProfData) and IsNotNullTable(pcdProfData["cooldowns"]) then
                    for spellName, doneAt in pairs(pcdProfData["cooldowns"]) do
                        if (cdNamesToConsider[spellName]) then
                            table.insert(charSpellAndCd, {charName, spellName, doneAt} )
                        end
                    end
                else
                    logIfLevel(1, "Cooldown data not found for character " .. charName)
                    logIfLevel(1, "pcd prof data: " .. tostring(pcdProfData))
                    logIfLevel(1, "is type " .. type(pcdProfData))
                end
            end
        end
    end
    return charSpellAndCd
end

pcdOptionsFrame = CreateFrame("Frame", "PcdOptionsFrame", UIParent)
pcdOptionsFrame:Hide()
function CreatePcdOptionsFrame()
    if not pcdOptionsFrame.close then 
        pcdOptionsFrame.close = CreateFrame("Button", "$parentClose", pcdOptionsFrame, "UIPanelCloseButton")
    end
    pcdOptionsFrame.close:SetSize(24, 24)
    pcdOptionsFrame.close:SetPoint("TOPRIGHT")
    pcdOptionsFrame.close:SetScript("OnClick", function(self) self:GetParent():Hide(); end)

    if PcdDb and PcdDb["settings"] then
        if PcdDb["settings"]["CloseOnEscape"] == "y" then
            EnableCloseOnEscape(false)
        end
        if PcdDb["settings"]["ShowMinimapButton"] == "y" then
            EnableMinimapButton(false)
        end
        -- if PcdDb["settings"]["ShowOldCds"] == "y" then
        --     EnableShowOldCdsInFilters(false) 
        -- end
    end

    if not (pcdOptionsFrame.CloseOnEscape) then
        pcdOptionsFrame.CloseOnEscape = CreateFrame("CheckButton", "CloseOnEscape_CheckButton", pcdOptionsFrame, "UICheckButtonTemplate")
    end
    if not (pcdOptionsFrame.CloseOnEscapeText) then
        pcdOptionsFrame.CloseOnEscapeText = pcdOptionsFrame:CreateFontString(nil, "OVERLAY")
    end
    if not (pcdOptionsFrame.ShowMinimapButton) then
        pcdOptionsFrame.ShowMinimapButton = CreateFrame("CheckButton", "UpdateMiniMap_CheckButton", pcdOptionsFrame, "UICheckButtonTemplate")
    end
    if not (pcdOptionsFrame.ShowMinimapButtonText) then
        pcdOptionsFrame.ShowMinimapButtonText = pcdOptionsFrame:CreateFontString(nil, "OVERLAY")
    end

    pcdOptionsFrame.CloseOnEscapeText:SetFontObject("GameFontHighlight")
    pcdOptionsFrame.CloseOnEscapeText:SetPoint("TOPLEFT", 40, -40)
    pcdOptionsFrame.CloseOnEscapeText:SetText("Close on escape (disable requires reload)")
    pcdOptionsFrame.CloseOnEscapeText:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")

    pcdOptionsFrame.ShowMinimapButtonText:SetFontObject("GameFontHighlight")
    pcdOptionsFrame.ShowMinimapButtonText:SetPoint("TOPLEFT", 40, -60)
    pcdOptionsFrame.ShowMinimapButtonText:SetText("Show mini map button")
    pcdOptionsFrame.ShowMinimapButtonText:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")
    
    if PcdDb["settings"]["CloseOnEscape"] == "y" then
        pcdOptionsFrame.CloseOnEscape:SetChecked(PcdDb["settings"]["CloseOnEscape"])
    else
        pcdOptionsFrame.CloseOnEscape:SetChecked(nil)
    end

    if PcdDb["settings"]["ShowMinimapButton"] == "y" then
        pcdOptionsFrame.ShowMinimapButton:SetChecked(PcdDb["settings"]["ShowMinimapButton"])
    else
        pcdOptionsFrame.ShowMinimapButton:SetChecked(nil)
    end

    pcdOptionsFrame.CloseOnEscape:SetPoint("TOPLEFT", 350, -34)
    pcdOptionsFrame.CloseOnEscape:SetScript("OnClick", 
        function()
            local isChecked = pcdOptionsFrame.CloseOnEscape:GetChecked()
            if (isChecked) then
                pcdOptionsFrame.CloseOnEscape:SetChecked(true)
                PcdDb["settings"]["CloseOnEscape"] = "y"
                EnableCloseOnEscape(true)
            else
                pcdOptionsFrame.CloseOnEscape:SetChecked(nil)
                PcdDb["settings"]["CloseOnEscape"] = "n"
                DisableCloseOnEscape(true)
            end
        end)

    pcdOptionsFrame.ShowMinimapButton:SetPoint("TOPLEFT", 350, -54)
    pcdOptionsFrame.ShowMinimapButton:SetScript("OnClick",
        function()
            local isChecked = pcdOptionsFrame.ShowMinimapButton:GetChecked()
            if (isChecked) then
                pcdOptionsFrame.ShowMinimapButton:SetChecked(true)
                PcdDb["settings"]["ShowMinimapButton"] = "y"
                EnableMinimapButton(true)
            else
                pcdOptionsFrame.ShowMinimapButton:SetChecked(nil)
                PcdDb["settings"]["ShowMinimapButton"] = "n"
                DisableMinimapButton(true)
            end
        end)
    
    pcdOptionsFrame.CloseOnEscape:Show()
    pcdOptionsFrame.ShowMinimapButton:Show()
    pcdOptionsFrame.CloseOnEscape.tooltip = "If checked, Pcd frames will close when hitting the escape key"
    SetFrameTitle(pcdOptionsFrame, "PCD options")
    RegisterFrameForDrag(pcdOptionsFrame, false)
    AddBorderToFrame(pcdOptionsFrame)

    pcdOptionsFrame:Show()
    pcdOptionsFrame:SetPoint("CENTER", UIParent, "CENTER")
    pcdOptionsFrame:SetSize(400, 120)
end

pcdFrame = CreateFrame("Frame", "PCDOverviewFrame", UIParent)
pcdFrame:Hide()
function CreatePCDFrame()
    pcdFrame:ClearAllPoints()
    pcdFrame:Hide()
    if not pcdFrame.close then
        pcdFrame.close = CreateFrame("Button", "$parentClose", pcdFrame, "UIPanelCloseButton")
    end
    pcdFrame.close:SetSize(24, 24)
    pcdFrame.close:SetPoint("TOPRIGHT")
    pcdFrame.close:SetScript("OnClick", function(self) self:GetParent():Hide(); end)
    
    if PcdDb and PcdDb["settings"] and PcdDb["settings"]["position"] and next(PcdDb["settings"]["position"]) then
        local pos = PcdDb["settings"]["position"]
        pcdFrame:SetPoint(pos["Point"], UIParent, pos["RelativePoint"], pos["XOfs"], pos["YOfs"])
    else
        pcdFrame:SetPoint("CENTER", UIParent, "CENTER")
    end

    if PcdDb and PcdDb["settings"] and PcdDb["settings"]["CloseOnEscape"] == "y" then
        EnableCloseOnEscape(false)
    end
    SetFrameTitle(pcdFrame, "Profession CD Tracker")
    RegisterFrameForDrag(pcdFrame, true)
    local charSpellAndCd = GetAllNamesAndCdsOnAccount()
    local sortedProfData = {}
    for i = 1, #charSpellAndCd do
        sortedProfData[i] = charSpellAndCd[i]
    end
    table.sort(sortedProfData, function (lhs, rhs) return lhs[3] < rhs[3] end)
    
    
    ClearFontStrings(pcdFrame)
    local printedItemCount = 0
    for i = 1, #sortedProfData do
        if sortedProfData[i] then
            local line = sortedProfData[i]
            logIfLevel(1, "should show for " .. line[1] .. " " .. line[2] .. " : " .. tostring(ShouldShowProf(line[1], line[2])))
            if ShouldShowProf(line[1], line[2]) then
                local cooldownText = GetCooldownText(line[3])
                AddTextWithCDToFrame(pcdFrame, line[1], line[2], "" .. cooldownText.text, printedItemCount + 1, cooldownText.color)
                printedItemCount = printedItemCount + 1
            else 
                logIfLevel(1, "skipped " .. line[1] .. " - " .. line[2])
            end
        end
    end
    local frameHeight = 50 + 17 * printedItemCount
    pcdFrame:SetSize(350,frameHeight)
    AddBorderToFrame(pcdFrame)
    pcdFrame:Show()
    logIfLevel (1, "PCD frame created")
end


pcdFiltersFrame = CreateFrame("Frame", "PCDFiltersFrame", UIParent)
pcdFiltersFrame:Hide()
function CreatePcdFiltersFrame() 
    -- char
    pcdFiltersFrame:ClearAllPoints()
    pcdFiltersFrame:Hide()
    InitDbTable()
    if not pcdFiltersFrame.close then
        pcdFiltersFrame.close = CreateFrame("Button", "$parentClose", pcdFiltersFrame, "UIPanelCloseButton")
    end
    pcdFiltersFrame.close:SetSize(24, 24)
    pcdFiltersFrame.close:SetPoint("TOPRIGHT")
    pcdFiltersFrame.close:SetScript("OnClick", function(self) self:GetParent():Hide(); end)
    
    if not (pcdFiltersFrame.CheckButtons) then
        pcdFiltersFrame.CheckButtons = {}
    end

    if not pcdFiltersFrame.CharNames then
        pcdFiltersFrame.CharNames = {}
    end

    if not pcdFiltersFrame.Header then
        pcdFiltersFrame.Header = {}
    end

    AddFiltersHeader(pcdFiltersFrame)

    if not pcdFiltersFrame.CharIndices then
        pcdFiltersFrame.CharIndices = {}
    end
    CreateGlobalCheckButtonForCds()
    local heightMod = addPcdFilterData()
    local widthMod = GetFilterIndexPosX(GetNumberOfActiveCds())

    if PcdDb and PcdDb["settings"] and PcdDb["settings"]["CloseOnEscape"] == "y" then
        EnableCloseOnEscape(false)
    end
    SetFrameTitle(pcdFiltersFrame, "Profession CD Filters")
    RegisterFrameForDrag(pcdFiltersFrame, false)
    AddBorderToFrame(pcdFiltersFrame)
    pcdFiltersFrame:Show()
    pcdFiltersFrame:SetPoint("CENTER", UIParent, "CENTER")
    pcdFiltersFrame:SetSize(widthMod + 50, 45 + heightMod * 30)
end

function GetNumberOfActiveCds()
    return 13
end

function GetSpellIndex(cdName)
    if cdName == "global"           then return 1 end
    if cdName == "transmute"        then return 2 end
    if cdName == "northrend alchemy research" then return 3 end
    if cdName == "spellweave"       then return 4 end
    if cdName == "moonshroud"       then return 5 end
    if cdName == "ebonweave"        then return 6 end
    if cdName == "glacial bag"      then return 7 end
    if cdName == "northrend inscription research" then return 8 end
    if cdName == "minor inscription research" then return 9 end
    if cdName == "icy prism" then return 10 end
    if cdName == "brilliant glass"  then return 11 end
    if cdName == "smelt titansteel" then return 12 end
    if cdName == "void sphere"      then return 13 end
    return -1
end
function GetSpellIconFromId(spellId)
    local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(spellId)
    print(icon)
    return icon
end

function GetSpellIconFromName(cdName)
    if cdName == "transmute"        then return 23571 end -- primal might
    -- if cdName == "transmute"        then return 136222 end -- primal might
    if cdName == "northrend alchemy research" then return 7810 end
    if cdName == "spellweave"       then return 41595 end
    if cdName == "moonshroud"       then return 41594 end
    if cdName == "ebonweave"        then return 41593 end
    if cdName == "glacial bag"      then return 41600 end
    if cdName == "northrend inscription research" then return 43127 end -- snowfall ink
    if cdName == "minor inscription research" then return 39469 end -- moonglow ink
    if cdName == "icy prism" then return 44943 end
    if cdName == "brilliant glass"  then return 35945 end
    if cdName == "smelt titansteel" then return 37663 end
    if cdName == "void sphere"      then return 22459 end
    return -1
end

function GetSpellNameFromIndex(index)
    if index == 1 then return "global" end
    if index == 2 then return "transmute" end
    if index == 3 then return "northrend alchemy research" end
    if index == 4 then return "spellweave" end
    if index == 5 then return "moonshroud" end
    if index == 6 then return "ebonweave" end
    if index == 7 then return "glacial bag" end
    if index == 8 then return "northrend inscription research" end
    if index == 9 then return "minor inscription research" end
    if index == 10 then return "icy prism" end
    if index == 11 then return "brilliant glass" end
    if index == 12 then return "smelt titansteel" end
    if index == 13 then return "void sphere" end
    return "unknown"
end

function addHeader(index, frame)
    local name = GetSpellNameFromIndex(index)
    -- local icon = GetSpellIconFromId(name)
    local icon = GetSpellIconFromName(name)
    if not frame.Header[index] then
        frame.Header[index] = AddIconToFiltersFrame(index, icon)
    end
end

function AddFiltersHeader(frame)
    local filterIndex = 1
    -- TODO: FIX!
    frame.Header[GetSpellIndex("global")] = AddTextToFrame(frame, "Global", "TOPLEFT", 110, -60);
    local numItems = GetNumberOfActiveCds()
    for i = 2, numItems do
        addHeader(i, frame)
    end
end

function GetFilterIndexPosX(index)
    if index == 1 then return 110 end
    if index == 2 then return 170 end
    -- prev max: 310
    return (index - 2) * 35 + 170
end

function AddIconToFiltersFrame(index, itemId)
    local posX = GetFilterIndexPosX(index)
    local myIcon = GetItemIcon(itemId)
    -- local myIcon = GetSpellTexture(itemId)
    -- print (myIcon)
    return AddIconToFrame(pcdFiltersFrame, "TOPLEFT", posX, -50, 28, 28, myIcon)
end

local createBorder = function(self, spellId, point)
	local bc = self.pcdGlow
    local r, g, b = GetSpellColorFromSpellId(spellId)
        if not r then
            return nil
        end
	if(not bc) then
		if(not self:IsObjectType'Frame') then
			bc = self:GetParent():CreateTexture(nil, 'BACKGROUND')
		else
			bc = self:CreateTexture(nil, "BACKGROUND")
		end
        
		bc:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
		bc:SetBlendMode"ADD"
		-- bc:SetAlpha(.8)
        bc:SetColorTexture(r,g,b,1)
		bc:SetWidth(33)
		bc:SetHeight(33)

		bc:SetPoint("CENTER", point or self)
		self.pcdGlow = bc
	end

	return bc
end

function AddIconToFrame(frame, pos, posX, posY, width, height, icon) 
    -- local iconFrame = frame:CreateTexture(icon, "BORDER")
    -- add in spell id
    local iconFrame = CreateFrame("Frame", "BorderFrame" .. icon, frame)

    createBorder(iconFrame, dreamOfHyjalId)
    -- BorderFrameIconLolBg:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0), CreateColor(1, 1, 1, 0))
    iconFrame:SetWidth(width)
    iconFrame:SetHeight(height)
    iconFrame:SetPoint(pos, posX, posY)
    -- if not iconFrame.texture then
    iconFrame.texture = iconFrame:CreateTexture(icon)
    -- end
    iconFrame.texture:SetWidth(width)
    iconFrame.texture:SetHeight(height)
    iconFrame.texture:SetPoint(pos, 0, 0)
    iconFrame.texture:SetTexture(icon)
    -- iconFrame:SetTexture(iconTexture)
    -- AddBorderToFrame(iconFrame)
    return iconFrame
end

function AddBorderToFrame(f)
    if mainFrameBordersEnabled then
        local frameborder=CreateFrame("Frame", "Border_Frame", f)
        frameborder:SetAllPoints(f)
        frameborder:SetFrameStrata("BACKGROUND")
        frameborder:SetFrameLevel(1)
        frameborder.left=frameborder:CreateTexture(nil,"BORDER")
        frameborder.left:SetPoint("BOTTOMLEFT",frameborder,"BOTTOMLEFT",-2,-1)
        frameborder.left:SetPoint("TOPRIGHT",frameborder,"TOPLEFT",-1,1)
        frameborder.left:SetColorTexture(0,0,0,1)
        frameborder.right=frameborder:CreateTexture(nil,"BORDER")
        frameborder.right:SetPoint("BOTTOMLEFT",frameborder,"BOTTOMRIGHT",1,-1)
        frameborder.right:SetPoint("TOPRIGHT",frameborder,"TOPRIGHT",2,1)
        frameborder.right:SetColorTexture(0,0,0,1)
        frameborder.top=frameborder:CreateTexture(nil,"BORDER")
        frameborder.top:SetPoint("BOTTOMLEFT",frameborder,"TOPLEFT",-1,1)
        frameborder.top:SetPoint("TOPRIGHT",frameborder,"TOPRIGHT",1,2)
        frameborder.top:SetColorTexture(0,0,0,1)
        frameborder.bottom=frameborder:CreateTexture(nil,"BORDER")
        frameborder.bottom:SetPoint("BOTTOMLEFT",frameborder,"BOTTOMLEFT",-1,-1)
        frameborder.bottom:SetPoint("TOPRIGHT",frameborder,"BOTTOMRIGHT",1,-2)
        frameborder.bottom:SetColorTexture(0,0,0,1)
    end
end

function addPcdFilterData()
    pcdFiltersFrame.CharIndices = {
        ["global"] = 1,
    }
    local chars = GetAllChars(true)
    local counter = 2
    for charName, charData in pairs(chars) do
        pcdFiltersFrame.CharIndices[charName] = counter
        CreateNameTextForFilter(counter, pcdFiltersFrame, charName)
        for i = 1, GetNumberOfActiveCds() do
            CreateCheckButtonForCharacterFilter(counter, pcdFiltersFrame, charName, GetSpellNameFromIndex(i), i)
        end
        counter = counter + 1
    end
    InitAlphas()
    return counter
end

function GetClassColorString(charName)
    if PcdDb[charName] and PcdDb[charName]["class"] then 
        return classColors[PcdDb[charName]["class"]] 
    else
        return STD_WHITE
    end
end

function CreateNameTextForFilter(index, frame, charName)
    if not frame.CharNames then
        frame.CharNames = {}
    end
    local cColorString = GetClassColorString(charName)
    if not frame.CharNames[index] then
        frame.CharNames[index] = AddTextToFrame(frame, cColorString .. CamelCase(charName), "TOPLEFT", 20, (index - 1) * -20 - 95)
    else
        frame.CharNames[index]:SetText(cColorString .. CamelCase(charName))
    end
end

function GetFiltersForCharacter(charName)
    return PcdDb[charName]["filters"]["global"]
end

function CreateGlobalCheckButtonForCds()
    CreateNameTextForFilter(1, pcdFiltersFrame, "global")
    for cdName in pairs(GetCdNamesToConsider()) do
        local checkedValue = "x"
        if PcdDb["settings"]["filters"][cdName] == "y" then checkedValue = "y" else checkedValue = nil end
        local spellIndex = GetSpellIndex(cdName)
        CreateCheckButton(1, pcdFiltersFrame, spellIndex)
        pcdFiltersFrame.CheckButtons[1][spellIndex]:SetChecked(checkedValue)
        pcdFiltersFrame.CheckButtons[1][spellIndex]:SetScript("OnClick", 
            function()
                local isChecked = pcdFiltersFrame.CheckButtons[1][spellIndex]:GetChecked()
                if (isChecked) then
                    pcdFiltersFrame.CheckButtons[1][spellIndex]:SetChecked(true)
                    SetShouldShowGlobal(cdName, "y")
                else
                    pcdFiltersFrame.CheckButtons[1][spellIndex]:SetChecked(nil)
                    SetShouldShowGlobal(cdName, "n")
                end
                HandleGlobalCdClick(cdName, not isChecked)
                UpdateAndRepaintIfOpen()
            end)
    end
end


function CharacterHasCooldownWithName(charName, cdName)
    local charData = PcdDb[charName]["professions"]
    if IsNotNullTable(charData) then
        for profName, cds in pairs(charData) do
            logIfLevel(1, "CharacterHasCooldownWithName: " .. charName .. " : " .. profName)
            if not PcdDb[charName]["professions"][profName] then PcdDb[charName]["professions"][profName] = {} end
            if not PcdDb[charName]["professions"][profName]["cooldowns"] then PcdDb[charName]["professions"][profName]["cooldowns"] = {} end
            if PcdDb[charName]["professions"][profName]["cooldowns"][cdName] ~= nil then
                return true
            end
        end 
    else
        logIfLevel(1, 'table was null for ' .. charName .. " and " .. cdName)
    end 
    return false
end

function CharacterHasProfessionsCooldowns(charName)
    local charData = PcdDb[charName]["professions"]
    if IsNotNullTable(charData) then
        for profName, cds in pairs(charData) do
            local cdTable = PcdDb[charName]["professions"][profName]["cooldowns"]
            if not cdTable then PcdDb[charName]["professions"][profName]["cooldowns"] = {} end
            cdTable = PcdDb[charName]["professions"][profName]["cooldowns"]
            for cdName, x in pairs(GetCdNamesToConsider()) do
                if PcdDb[charName]["professions"][profName]["cooldowns"][cdName] then
                    return true
                end
            end
            logIfLevel(1, "CharacterHasCooldownWithName: " .. charName .. " : " .. profName .. " num cds: " .. #cdTable)
        end
    else
        logIfLevel(1, 'CharacterHasProfessionsCooldowns: charData table was null for ' .. charName)
    end 
    return false
end

function GetAllChars(filterWithCds)
    local dbData = {}
    for charName, charData in pairs(PcdDb) do
        if not (charName == "settings") then
            if (not filterWithCds) or CharacterHasProfessionsCooldowns(charName) then
                logIfLevel(1, "added " .. charName .. " to dbData")
                dbData[charName] = charData
            end
        end
    end
    return dbData
end


function CreateCheckButton(index, frame, spellIndex)
    if not frame.CheckButtons[index] then
        frame.CheckButtons[index] = {}
    end
    if not frame.CheckButtons[index][spellIndex] then
        frame.CheckButtons[index][spellIndex] = CreateFrame("CheckButton", "Filter_CheckButton_" .. index .. "_" .. spellIndex, pcdFiltersFrame, "UICheckButtonTemplate")
    end
    frame.CheckButtons[index][spellIndex]:SetPoint("TOPLEFT", 100 + spellIndex * 35, (index - 1) * -20 - 80)
    frame.CheckButtons[index][spellIndex]:SetSize(30, 30)
end

function CreateCheckButtonForCharacterFilter(index, frame, charName, spellName, spellIndex)
    CreateCheckButton(index, frame, spellIndex)
    if PcdDb[charName]["filters"][spellName] == "y" then
        frame.CheckButtons[index][spellIndex]:SetChecked(true)
    else
        frame.CheckButtons[index][spellIndex]:SetChecked(nil)
    end
    if spellIndex > 1 and not (CharacterHasCooldownWithName(charName, spellName)) then
        frame.CheckButtons[index][spellIndex]:Disable()
        logIfLevel(1, charName .. " does not have " .. spellName .. " so disabling: [" .. index .. "][" .. spellIndex .. "]")
    elseif spellIndex > 1 then
        frame.CheckButtons[index][spellIndex]:Enable()
    end
    frame.CheckButtons[index][spellIndex]:SetScript("OnClick", 
        function()
            local isChecked = frame.CheckButtons[index][spellIndex]:GetChecked()
            if (isChecked) then
                frame.CheckButtons[index][spellIndex]:SetChecked(true)
                SetShouldShowProf(charName, spellName, "y")
            else
                frame.CheckButtons[index][spellIndex]:SetChecked(nil)
                SetShouldShowProf(charName, spellName, "n")
            end
            if spellIndex == 1 then HandleGlobalCharacterClick(charName, isChecked)
            else HandleSpecificClick(charName, spellName, isChecked) end

            logIfLevel(2, "index: " .. index .. ", char: " .. charName .. ", spell: " .. spellName .. " sindex: " .. spellIndex)
            UpdateAndRepaintIfOpen()
        end)
end

function HandleSpecificClick(charName, spellName, shouldCheck)
    local charIndex = pcdFiltersFrame.CharIndices[charName]
    pcdFiltersFrame.CheckButtons[charIndex][1]:SetAlpha(0.4)
    pcdFiltersFrame.CheckButtons[charIndex][1]:SetChecked(nil)
    pcdFiltersFrame.CheckButtons[1][GetSpellIndex(spellName)]:SetAlpha(0.4)
    pcdFiltersFrame.CheckButtons[1][GetSpellIndex(spellName)]:SetChecked(nil)
    logIfLevel(2, "should be alpha'ed now (")
    PcdDb[charName]["filters"]["Global"] = "x"
    PcdDb["settings"]["filters"][spellName] = "x"
    for i = 2, #pcdFiltersFrame.CheckButtons[charIndex] do
        local button = pcdFiltersFrame.CheckButtons[charIndex][i]
        button:SetAlpha(1)
    end
    for i = 2, #pcdFiltersFrame.CheckButtons do
        local button = pcdFiltersFrame.CheckButtons[i][GetSpellIndex(spellName)]
        button:SetAlpha(1)
    end

end

function HandleGlobalCdClick(cdName, shouldCheck)
    local spellIndex = GetSpellIndex(cdName)
    pcdFiltersFrame.CheckButtons[1][spellIndex]:SetAlpha(1)
    local targetValue
    local checkedValue
    for i = 2, #pcdFiltersFrame.CheckButtons do
        local button = pcdFiltersFrame.CheckButtons[i][spellIndex]
        if button then
            button:SetAlpha(0.4)
        end
    end
end

function HandleGlobalCharacterClick(charName, shouldCheck)
    local charIndex = pcdFiltersFrame.CharIndices[charName]
    local targetValue
    local checkedValue
    if shouldCheck then targetValue = "y" else targetValue = "n" end
    if shouldCheck then checkedValue = true else checkedValue = nil end
    pcdFiltersFrame.CheckButtons[charIndex][1]:SetAlpha(1)
    PcdDb[charName]["filters"]["global"] = targetValue
    for i = 2, #pcdFiltersFrame.CheckButtons[charIndex] do
        local button = pcdFiltersFrame.CheckButtons[charIndex][i]
        -- button:SetChecked(checkedValue)
        button:SetAlpha(0.4)
    end
end

function InitAlphas()
    -- character globals
    local chars = GetAllChars(true)
    for charName, charData in pairs(chars) do
        local charIndex = pcdFiltersFrame.CharIndices[charName]
        local alphaValue
        local button = pcdFiltersFrame.CheckButtons[charIndex][1]
        if PcdDb[charName]["filters"]["global"] == "x" then alphaValue = 0 else alphaValue = 1 end
        button:SetAlpha(alphaValue)
        if alphaValue == 1 then
            for i = 2, #pcdFiltersFrame.CheckButtons do
                logIfLevel(1, "set " .. i .. ", " .. 1 .. " alpha for char globals to 0.4" .. alphaValue)
                button = pcdFiltersFrame.CheckButtons[i][1]
                button:SetAlpha(0.4)
            end
        end
    end
    -- cooldown globals
    for spellIndex = 2, GetNumberOfActiveCds() do
        local alphaValue
        local spellName = GetSpellNameFromIndex(spellIndex)
        if PcdDb["settings"]["filters"][spellName] == "x" then alphaValue = 0.4 else alphaValue = 1 end
        logIfLevel(1, "alpha is " .. alphaValue .. " for " .. spellName .. " with index " .. spellIndex)
        pcdFiltersFrame.CheckButtons[1][spellIndex]:SetAlpha(alphaValue)
        if alphaValue == 1 then
            for charIndex = 2, #pcdFiltersFrame.CheckButtons do
                logIfLevel(1, "set " .. charIndex .. ", " .. spellIndex .. " alpha for cd globals")
                local button = pcdFiltersFrame.CheckButtons[charIndex][spellIndex]
                button:SetAlpha(0.4)
            end
        end
    end
end

function CamelCase(str)
    local function tchelper(first, rest)
        return first:upper()..rest:lower()
     end
     str = str:gsub("(%a)([%w_']*)", tchelper)
     return str
end

function SetShouldShowGlobal(spellName, shouldShow)
    PcdDb["settings"]["filters"][spellName] = shouldShow
end

function SetShouldShowProf(charName, spellName, shouldShow)
    PcdDb[charName]["filters"][spellName] = shouldShow
    PcdDb[charName]["filters"]["global"] = "x"
    PcdDb["settings"]["filters"][spellName] = "x"
end

function ShouldShowProf(charName, spellName)
    local globalVal = PcdDb["settings"]["filters"][spellName]
    local charGlobalVal = PcdDb[charName]["filters"]["global"]
    local specificVal = PcdDb[charName]["filters"][spellName]

    if (globalVal == "y" or charGlobalVal == "y" or specificVal == "y") then return true
    elseif globalVal == "n" or charGlobalVal == "n" or specificVal == "n" then return false
    else return specificVal == "y" end
end

-- /script ClearFontStrings(pcdFrame)
function ClearFontStrings(f)
    if f.fontStrings and type(f.fontStrings) == "table" then
        for i = 1, #f.fontStrings do
            if f.fontStrings[i] then
                if f.fontStrings[i]["R"] then
                    f.fontStrings[i]["R"]:Hide()
                end
                if f.fontStrings[i]["L"] then
                    f.fontStrings[i]["L"]:Hide()
                end
            end
        end
    end
end

function EnableCloseOnEscape(shouldPrint)
    if PcdDb and PcdDb["settings"] then
        PcdDb["settings"]["CloseOnEscape"] = "y"
        if (shouldPrint) then
            print ("Enabled 'Close on escape' for PCD.")
        end
    end
    tinsert(UISpecialFrames, pcdFrame:GetName())
    tinsert(UISpecialFrames, pcdOptionsFrame:GetName())
    tinsert(UISpecialFrames, pcdFiltersFrame:GetName())
end

function DisableCloseOnEscape(shouldPrint)
    if PcdDb and PcdDb["settings"] then
        PcdDb["settings"]["CloseOnEscape"] = "n"
    end
    if shouldPrint then
        print ("Disabled 'Close On Escape' for PCD. Reload UI (/reload) for this to take effect.")
    end
end

-- function EnableShowOldCdsInFilters(shouldPrint)
--     if PcdDb and PcdDb["settings"] then
--         pcdShowOldCdsInFilters = true
--         PcdDb["settings"]["ShowOldCds"] = "y"
--         PCDLDBIcon:Show("PCD")
--     end
--     if shouldPrint then
--         print ("Enabled visibility of old CDs in filters for PCD.")
--     end
-- end

-- function DisableShowOldCdsInFilters(shouldPrint)
--     if PcdDb and PcdDb["settings"] then
--         pcdShowOldCdsInFilters = nil
--         PcdDb["settings"]["ShowOldCds"] = "n"
--         PCDLDBIcon:Show("PCD")
--     end
--     if shouldPrint then
--         print ("Disabled visibility of old CDs in filters for PCD.")
--     end
-- end

function EnableMinimapButton(shouldPrint)
    if PcdDb and PcdDb["settings"] then
        pcdShowMinimapButton = true
        PcdDb["settings"]["ShowMinimapButton"] = "y"
        PCDLDBIcon:Show("PCD")
    end
    if shouldPrint then
        print ("Minimap button visibility enabled for PCD.")
    end
end

function DisableMinimapButton(shouldPrint)
    if PcdDb and PcdDb["settings"] then
        pcdShowMinimapButton = nil
        PcdDb["settings"]["ShowMinimapButton"] = "n"
        PCDLDBIcon:Hide("PCD")
    end
    if shouldPrint then
        print ("Minimap button visibility disabled for PCD.")
    end
end

function ResetPosition()
    if PcdDb["settings"] and PcdDb["settings"]["position"] then
        PcdDb["settings"]["position"] = {}
    end
end

function PrintHelp()
    print("Profession Cooldown (PCD) tracks your profession cooldowns. type /pcd to toggle the main frame visibility.")
    print("Cooldowns are updated when you open or close the given profession. Cooldowns are only added to the list once they are on cooldown, but will show up after that.")
    print("Drag the window to change its position. Close it by clicking 'X' button or press the Escape key")
    print ("/pcd update, triggers a manual update.")
    print("Type /pcd options to open options menu.")
    print("Type /pcd filters to set up filters")
end

function StartsWith(msg, pattern)
    return msg:find("^" .. pattern) ~= nil
end

function GetTextBefore(msg, str)
    if msg and str and string.len(msg) >= string.len(str) then
        local index = string.find(msg, str)
        if index and index > 0 then
            return string.sub(msg, 0, index - 1)
        end
    end
end

function GetTextAfter(msg, str)
    if msg and str and string.len(msg) >= string.len(str) then
        return string.sub(msg, string.len(str) + 1, string.len(msg))
    end
end

function Capitalize(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest) return first:upper()..rest:lower() end)
end

function ResetCharacter(message)
    local charNameToReset = Capitalize(GetTextAfter(message, "reset "))
    if PcdDb and PcdDb[charNameToReset] then
        PcdDb[charNameToReset] = {}
        print ("PCD: Data for '" .. charNameToReset .. "' has been reset.")
        return
    end
    print ("Could not find data for '" .. charNameToReset .. "'.")
end

function FreshInit()
    PcdDb = {}
    InitDbTable()
    UpdateCharacterProfessionDb()
    InitDbTable()
    UpdateCds()
end

function HasVersionData()
    return PcdDb and PcdDb["settings"] and PcdDb["settings"]["version"]
end

function VersionMatchesAddonVersion()
    return pcdVersion == PcdDb["settings"]["version"]
end

function ShouldPcdUpdate()
    return not HasVersionData() or not VersionMatchesAddonVersion()
end

function UpdateVersionInDb(versionNumber)
    PcdDb["settings"]["version"] = versionNumber
end

function UpdateDataFormatVersion()
    if ShouldPcdUpdate() then
        UpdateVersionInDb(pcdVersion)
    end
end

local PCDLDB, doUpdateMinimapButton;
function CreateBroker()
    local data = {
		type = "launcher",
		label = "PCD",
		text = "Profession Cooldowns",
		icon = "Interface\\Icons\\inv_misc_pocketwatch_01",
		OnClick = function(self, button)
			if (button == "LeftButton" and IsShiftKeyDown()) then
				InitDbTable()
                UpdateCharacterProfessionDb()
                UpdateCds()
			elseif (button == "LeftButton") then
				UpdateDataFormatVersion()
                if pcdFrame and pcdFrame:IsShown() then
                    pcdFrame:Hide()
                else
                    UpdateCds()
                    CreatePCDFrame()
                end
			elseif (button == "RightButton" and IsShiftKeyDown()) then
				FreshInit()
			elseif (button == "RightButton") then
				InitDbTable()
                if pcdOptionsFrame and pcdOptionsFrame:IsShown() then
                    pcdOptionsFrame:Hide()
                else 
                    CreatePcdOptionsFrame()
                end
			end
		end,
		OnLeave = function(self, button)
			doUpdateMinimapButton = nil;
		end,
		OnTooltipShow = function(tooltip)
			doUpdateMinimapButton = true;
			UpdateMinimapButton(tooltip, doUpdateMinimapButton);
		end,
		OnEnter = function(self, button)
            UpdateCds()
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
			doUpdateMinimapButton = true;
			UpdateMinimapButton(GameTooltip, true);
			GameTooltip:Show()
		end,
	};
	PCDLDB = LDB:NewDataObject("PCD", data);
    if LDB and PCDLDBIcon and PCDLDB then
        PCDLDBIcon:Register("PCD", data, PcdDb["settings"])
        if not pcdShowMinimapButton then
            logIfLevel(2, "called hide on minimap button from create broker.")
            C_Timer.After(0.5, function()
                PCDLDBIcon:Hide("PCD")
            end)
        end
    end
end

function UpdateMinimapButton(tooltip, usingPanel)
	local _, relativeTo = tooltip:GetPoint();
	if (doUpdateMinimapButton and (usingPanel or relativeTo and relativeTo:GetName() == "LibDBIcon10_PCD")) then
        tooltip:ClearLines()
		tooltip:AddLine("Profession CD Tracker");
        tooltip:AddLine(" ");
        AddCooldownsToTooltip(tooltip)
        tooltip:AddLine(" ");
		tooltip:AddLine("|cFF9CD6DELeft-Click|r Show Cooldowns");
		tooltip:AddLine("|cFF9CD6DERight-Click|r Show Options");
		tooltip:AddLine("|cFF9CD6DEShift Left-Click|r Trigger Manual Update");
		tooltip:AddLine("|cFF9CD6DEShift Right-Click|r Reset All Data");
		C_Timer.After(1, function()
			UpdateMinimapButton(tooltip, usingPanel);
		end)
	end
end

function AddCooldownsToTooltip(tooltip)
    local charSpellAndCd = GetAllNamesAndCdsOnAccount()
    local sortedProfData = {}
    for i = 1, #charSpellAndCd do
        sortedProfData[i] = charSpellAndCd[i]
    end
    table.sort(sortedProfData, function (lhs, rhs) return lhs[3] < rhs[3] end)
    for i = 1, #sortedProfData do
        if sortedProfData[i] then
            local line = sortedProfData[i]

            local cooldownText = GetCooldownText(line[3])
            if ShouldShowProf(line[1], line[2]) then
                local cColorString = GetClassColorString(line[1])
                tooltip:AddDoubleLine(cColorString .. line[1] .. STD_WHITE .. " - " .. CamelCase(line[2]), "" .. cooldownText.text, 1, 1, 1, cooldownText.color[1], cooldownText.color[2], cooldownText.color[3])
            else
                logIfLevel(1, "skipped " .. line[1] .. " - " .. line[2])
            end
        end
    end
end

function GetCooldownText(cooldown)
    local cooldownText = {}
    local cdText = ""
    local secondsLeft = cooldown - GetServerTime()
    logIfLevel (1, "secs left: " .. secondsLeft)
    local hoursLeft = secondsLeft / 3600
    local cdColor
    if cooldown and hoursLeft <= 0 then
        cdText = "Ready"
        cdColor = { 0, 233 / 255, 0, 1}
    else
        if (hoursLeft > 24) then
            cdColor = { 233 / 255, 0, 0, 1}
            cdText = cdText .. math.floor(hoursLeft / 24) .. " d "
        else
            cdColor = { 1, 1, 10 / 255, 1}
        end

        cdText = cdText .. math.floor(hoursLeft % 24) .. " h "
        cdText = cdText .. math.floor((hoursLeft % 1) * 60) .. " m"
    end

    cooldownText["text"] = cdText
    cooldownText["color"] = cdColor
    return cooldownText
end

SLASH_PCD1 = "/pcd"
SlashCmdList["PCD"] = function(msg)
    if msg == "update" then
        UpdateCds()
        -- GetCooldownsFromSpellIds()
        if pcdFrame and pcdFrame:IsShown() then
            CreatePCDFrame()
        end
    elseif msg == "filters" or msg == "filter" then
        UpdateCds()
        CreatePcdFiltersFrame()
    elseif msg == nil or msg == "" then
        UpdateDataFormatVersion()
        if pcdFrame and pcdFrame:IsShown() then
            pcdFrame:Hide()
        else
            UpdateCds()
            CreatePCDFrame()
        end
    elseif msg == "options" or msg == "option" then
        InitDbTable()
        if pcdOptionsFrame and pcdOptionsFrame:IsShown() then
            pcdOptionsFrame:Hide()
        else
            CreatePcdOptionsFrame()
        end
    elseif msg == "reset" then
        ResetPosition()
    elseif msg == "resetalldata" then
        FreshInit()
    elseif StartsWith(msg, "reset") then
        ResetCharacter(msg)
    elseif msg == "db 1" then
        debugLevel = 1
    elseif msg == "db 2" then
        debugLevel = 2
    elseif msg == "db 3" then
        debugLevel = 3
    elseif msg == "help" then
        PrintHelp()
    end
end