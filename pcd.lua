-- PCD start
local pcdVersion = "1.010"
pcdUpdateFromSpellId = nil
pcdShowMinimapButton = nil
local pcdIsLoaded = nil

local LDB = LibStub:GetLibrary("LibDataBroker-1.1");
local PCDLDBIcon = LibStub:GetLibrary("LibDBIcon-1.0")

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
        if PcdDb and PcdDb["settings"] and not (PcdDb["settings"]["UpdateFromSpellId"] == "n") then
            pcdUpdateFromSpellId = true
            logIfLevel(2, "update from spell id set to true")
        end
        if PcdDb and PcdDb["settings"] and not (PcdDb["settings"]["ShowMinimapButton"] == "n") then
            pcdShowMinimapButton = true
            logIfLevel(2, "show mini map button set to true")
        end
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
    InitDbTable()
    GetCooldownsFromSpellIds()
end

local lootMsgFrame = CreateFrame("Frame")
lootMsgFrame:RegisterEvent("CHAT_MSG_LOOT")
lootMsgFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "CHAT_MSG_LOOT" then
        UpdateAndRepaintIfOpen()
        logIfLevel(2, "Creation message event fired. Calling update at: ")
        logIfLevel(1, GetTime())
    end
end)

local profNamesToConsider = { 
    ["Alchemy"] = true,
    ["Tailoring"] = true,
    ["Leatherworking"] = true,
    ["Jewelcrafting"] = true
}

function initProfessionIfNeeded(profName)
    local charName = UnitName("player")
    if not PcdDb[charName] then 
        PcdDb[charName] = {}
    end
    if not PcdDb[charName]["professions"] then
        PcdDb[charName]["professions"] = {}
    end
    if not PcdDb[charName]["professions"][profName] then
        PcdDb[charName]["professions"][profName] = {}
    end
    if not PcdDb[charName]["professions"][profName]["cooldowns"] then
        PcdDb[charName]["professions"][profName]["cooldowns"] = {}
    end
end

local debugLevel = 3
function logIfLevel(dbLevel, text)
    if debugLevel <= dbLevel then
        print (text)
    end
end

local lastcalled = nil
function internalGetProfessionCooldowns()
    if lastcalled and GetServerTime() - lastcalled < 1 then
        logIfLevel (1, "SKIP internalGetProfCd cause called too early. diff only: " .. (GetServerTime() - lastcalled))
        return
    else
        lastcalled = GetServerTime()
    end
    local charName = UnitName("player")
    logIfLevel(1, "getting prof cd for " .. charName)
    for i = 1, GetNumTradeSkills() do
        local secondsLeft = GetTradeSkillCooldown(i);
        if (secondsLeft and secondsLeft > 60) then
            local skillName = GetTradeSkillInfo(i);
            if (skillName) then
                local professionGuess = getProfessionName(skillName)
                if not professionGuess then
                    logIfLevel (3, "PCD Error: Uknown profession skill found, with name: " .. skillName)
                    return
                end
                logIfLevel (1, "prof guess : " .. professionGuess)
                initProfessionIfNeeded(professionGuess)
                local hoursLeft = secondsLeft / 3600
                local doneAt = GetServerTime() + secondsLeft
                logIfLevel (1, "calculate done at as: " .. (doneAt / 3600000))
                logIfLevel (1, "hours left is " .. hoursLeft)
                if (IsVanillaTransmute(skillName) or IsTransmuteTBC(skillName)) then
                    skillName = "Transmute"
                end
                PcdDb[charName]["professions"][professionGuess]["cooldowns"][skillName] = doneAt
                logIfLevel(2, "saved " .. skillName .. ": " .. string.format("%.2f", hoursLeft) .. " from now.")
            end
        end
    end
end

function UpdateTo0103()
    if PcdDb and PcdDb["settings"] and not PcdDb["settings"]["version"] then
        for charName, profs in pairs(PcdDb) do
            if PcdDb[charName]["professions"] and PcdDb[charName]["professions"]["Alchemy"] then
                local lastReadyAt
                if PcdDb[charName]["professions"]["Alchemy"]["cooldowns"]["Transmute (Vanilla)"] then
                    lastReadyAt = PcdDb[charName]["professions"]["Alchemy"]["cooldowns"]["Transmute (Vanilla)"]
                    PcdDb[charName]["professions"]["Alchemy"]["cooldowns"]["Transmute (Vanilla)"] = nil
                end
                local lastReadyAtTbc
                if PcdDb[charName]["professions"]["Alchemy"]["cooldowns"]["Transmute (TBC)"] then
                    lastReadyAtTbc = PcdDb[charName]["professions"]["Alchemy"]["cooldowns"]["Transmute (TBC)"]
                    PcdDb[charName]["professions"]["Alchemy"]["cooldowns"]["Transmute (TBC)"] = nil
                    lastReadyAt = math.max(lastReadyAt, lastReadyAtTbc)
                end
                PcdDb[charName]["professions"]["Alchemy"]["cooldowns"]["Transmute"] = lastReadyAt
            end 
        end
        PcdDb["settings"]["version"] = "1.03"
        logIfLevel(2, "Updated PCD data to version 1.03")
    end
end

function UpdateTo0104()
    RemoveCdInDb("Alchemy", "Transmute: Primal Mana to fIRE")
    RemoveCdInDb("Alchemy", "Transmute: Primal Water to Shadow")
    RemoveCdInDb("Tailoring", "Mooncloth")
    if PcdDb and PcdDb["settings"] and PcdDb["settings"]["version"] == "1.03" then
        PcdDb["settings"]["version"] = "1.04"
        logIfLevel(2, "Updated PCD data to version 1.04")
    end
end

function UpdateTo0107()
    if PcdDb then
        if PcdDb and PcdDb["settings"] and PcdDb["settings"]["version"] == "1.04" then
            for charName, profs in pairs(PcdDb) do
                if PcdDb[charName]["professions"] and PcdDb[charName]["professions"]["Jewelcrafting"] then
                    PcdDb[charName]["professions"]["Jewelcrafting"]["cooldowns"] = {}
                end
            end
            PcdDb["settings"]["version"] = "1.07"
        logIfLevel(2, "Updated PCD data to version 1.07")
        end
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

function ShouldShowCdForCharacter(charName, cdName)

end

function GetProfessionCooldowns()
    InitDbTable()
    internalGetProfessionCooldowns()
    UpdateSaltShakerCd()
end

function UpdateSaltShakerCd()
    local charName = UnitName("player")
    local lw = PcdDb[charName]["professions"]["Leatherworking"]
    if lw and lw["skill"] >= 250 then
        local startTime, duration, _ = GetItemCooldown(15846)
        local secondsLeft = GetCooldownLeftOnItem(startTime, duration)
        if (secondsLeft > 0) then
            PcdDb[charName]["professions"]["Leatherworking"]["cooldowns"] = { ["Salt Shaker"] = secondsLeft + GetServerTime() }
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

local primalMightId = 29688
local primalMoonclothId = 26751
local spellclothId = 31373
local shadowclothId = 36686
local brilliantGlassId = 47280
local allTransmuteIds = {
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
    29688, -- Primal Might
    32765, -- Earthstorm Diamond
    32766, -- Skyfire Diamond
-- Below has no cd.
--    17187, -- Arcanite
--    25146, -- Elemental Fire
}

function GetCooldownsFromSpellIds()
    logIfLevel(2, "updating from spell id")
    logIfLevel(1, GetTime())
    if not pcdUpdateFromSpellId then
        logIfLevel (2, "update from spell id called, but is disabled.")
    end
    InitDbTable()
    local charName = UnitName("Player")
    if PcdDb and PcdDb[charName] and PcdDb[charName]["professions"] then
        if PcdDb[charName]["professions"]["Alchemy"] then
            logIfLevel(1, "alchemy found")
            if PcdDb[charName]["professions"]["Alchemy"]["skill"] >= 225 then
                local highestTransmuteCd = GetTransmuteCd()
                if highestTransmuteCd > 0 then
                    SetCooldownForSpell("Transmute", "Alchemy", highestTransmuteCd)
                end
            end
        end
        if PcdDb[charName]["professions"]["Tailoring"] then
            logIfLevel(1, "Tailoring found")
            if PcdDb[charName]["professions"]["Tailoring"]["skill"] >= 350 then
                SetCooldownForSpell("Primal Mooncloth", "Tailoring", primalMoonclothId)
                SetCooldownForSpell("Spellcloth", "Tailoring", spellclothId)
                SetCooldownForSpell("Shadowcloth", "Tailoring", shadowclothId)
            end
        end
        if PcdDb[charName]["professions"]["Jewelcrafting"] then
            logIfLevel(1, "Jewelcrafting found")
            if PcdDb[charName]["professions"]["Jewelcrafting"]["skill"] >= 350 then
                SetCooldownForSpell("Brilliant Glass", "Jewelcrafting", brilliantGlassId)
            end
        end
    end
end

function GetTransmuteCd()
    local best = -1
    for i = 1, #allTransmuteIds do
        local timestamp = GetCooldownTimestamp(allTransmuteIds[i])
        if timestamp > best then
            best = timestamp
        end
    end

    return best
end

function SetCooldownForSpell(cdName, professionName, spellId)
    local charName = UnitName("Player")
    if not PcdDb[charName]["professions"][professionName]["cooldowns"] or not type(PcdDb[charName]["professions"][professionName]["cooldowns"]) == "table" then
        PcdDb[charName]["professions"][professionName]["cooldowns"] = {}
    end
    PcdDb[charName]["professions"][professionName]["cooldowns"][cdName] = GetCooldownTimestamp(spellId)
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

function UpdateCharacterProfessionDb()
    local charName = UnitName("player")
    local profs = {}
    local primaryCount = 0
    local i = 1
    local j = 0
    local section = 0
    for i = 1, GetNumSkillLines() do
        local skillName, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
        if (isHeader and skillName == TRADE_SKILLS) then
            section = 2;
        end
        if (not isHeader and section == 2) then
            logIfLevel (2, "found " .. skillName .. " with primary count " .. primaryCount)
            if (primaryCount < 3 and skillName) and profNamesToConsider[skillName] ~= nil and #profs <= 2 then
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
    if not PcdDb[charName]["filters"] then
        PcdDb[charName]["filters"] = {}
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
    if (not PcdDb["settings"]["UpdateFromSpellId"]) then
        PcdDb["settings"]["UpdateFromSpellId"] = "y"
    end
    if (not PcdDb[charName]["professions"] or #PcdDb[charName]["professions"] < 2) then
        UpdateCharacterProfessionDb()
        logIfLevel(1, "Updated character prof db for " .. charName)
    end
    if not PcdDb["settings"]["ShowMinimapButton"] then
        PcdDb["settings"]["ShowMinimapButton"] = "y"
    end
end

function RegisterFrameForDrag(theFrame)
    theFrame:SetMovable(true)
    theFrame:EnableMouse(true)

    theFrame:RegisterForDrag("LeftButton")
    theFrame:SetScript("OnDragStart", theFrame.StartMoving)
    if (not theFrame.SavePositionAndStopMoving) then
        theFrame.SavePositionAndStopMoving = SavePositionAndStopMoving
    end
    theFrame:SetScript("OnDragStop", theFrame.SavePositionAndStopMoving)

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

function AddTextToFrame(theFrame, text, firstPosition, secondPosition)
    local font = theFrame:CreateFontString(nil, "OVERLAY")
    font:SetFontObject("GameFontHighlight")
    font:SetPoint(firstPosition, theFrame, secondPosition)
    font:SetText(text)
    font:SetFont("Fonts\\FRIZQT__.ttf", pcdSettings.entrySize, "OUTLINE")
    logIfLevel (1, "added test frame stuff")
    return font
end

function AddTextWithCDToFrame(theFrame, leftText, rightText, position, cdColor)
    if (not theFrame.fontStrings) then
        theFrame.fontStrings = {}
    end
    local nameFont
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
    nameFont:SetText(leftText)
    nameFont:SetFont("Fonts\\FRIZQT__.ttf", pcdSettings.entrySize, "OUTLINE")

    cdFont:SetFontObject("GameFontHighlight")
    cdFont:SetText(rightText)
    cdFont:SetPoint("TOPRIGHT", -10, actualPosition)
    cdFont:SetFont("Fonts\\FRIZQT__.ttf", pcdSettings.entrySize, "OUTLINE")
    cdFont:SetTextColor(cdColor[1], cdColor[2], cdColor[3], cdColor[4])

    nameFont:Show()
    cdFont:Show()
end

function GetAllNamesAndCdsOnAccount()
    local charSpellAndCd = {}
    local allOnAccount = PcdDb
    if (not allOnAccount) then
        return
    end
    for charName, pcdProfessions in pairs(PcdDb) do
        if not (charName == "settings") then
            if pcdProfessions ~= nil and type(pcdProfessions) == "table" then
                for profTag, pcdProfs in pairs(pcdProfessions) do 
                    for profName, pcdProfData in pairs(pcdProfs) do
                        if pcdProfData["cooldowns"] ~= nil and type(pcdProfData["cooldowns"]) == "table" then
                            for spellName, doneAt in pairs(pcdProfData["cooldowns"]) do
                                table.insert(charSpellAndCd, {charName, spellName, doneAt} )
                            end
                        else
                            logIfLevel(1, "Cooldown data not found for character " .. charName)
                            logIfLevel(1, "pcd prof data: " .. tostring(pcdProfData["cooldowns"]))
                            logIfLevel(1, "is type " .. type(pcdProfData["cooldowns"]))
                        end
                    end
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
        if PcdDb["settings"]["UpdateFromSpellId"] == "y" then
            EnableUpdateFromSpellId(false)
        end
        if PcdDb["settings"]["ShowMinimapButton"] == "y" then
            EnableMinimapButton(false)
        end
    end

    if not (pcdOptionsFrame.CloseOnEscape) then
        pcdOptionsFrame.CloseOnEscape = CreateFrame("CheckButton", "CloseOnEscape_CheckButton", pcdOptionsFrame, "ChatConfigCheckButtonTemplate")
    end
    if not (pcdOptionsFrame.CloseOnEscapeText) then
        pcdOptionsFrame.CloseOnEscapeText = pcdOptionsFrame:CreateFontString(nil, "OVERLAY")
    end
    if not (pcdOptionsFrame.UpdateFromSpellId) then
        pcdOptionsFrame.UpdateFromSpellId = CreateFrame("CheckButton", "UpdateFromSpellId_CheckButton", pcdOptionsFrame, "ChatConfigCheckButtonTemplate")
    end
    if not (pcdOptionsFrame.UpdateFromSpellIdText) then
        pcdOptionsFrame.UpdateFromSpellIdText = pcdOptionsFrame:CreateFontString(nil, "OVERLAY")
    end
    if not (pcdOptionsFrame.ShowMinimapButton) then
        pcdOptionsFrame.ShowMinimapButton = CreateFrame("CheckButton", "UpdateMiniMap_CheckButton", pcdOptionsFrame, "ChatConfigCheckButtonTemplate")
    end
    if not (pcdOptionsFrame.ShowMinimapButtonText) then
        pcdOptionsFrame.ShowMinimapButtonText = pcdOptionsFrame:CreateFontString(nil, "OVERLAY")
    end

    pcdOptionsFrame.CloseOnEscapeText:SetFontObject("GameFontHighlight")
    pcdOptionsFrame.CloseOnEscapeText:SetPoint("TOPLEFT", 40, -40)
    pcdOptionsFrame.CloseOnEscapeText:SetText("Close on escape (disable requires reload)")
    pcdOptionsFrame.CloseOnEscapeText:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")

    pcdOptionsFrame.UpdateFromSpellIdText:SetFontObject("GameFontHighlight")
    pcdOptionsFrame.UpdateFromSpellIdText:SetPoint("TOPLEFT", 40, -60)
    pcdOptionsFrame.UpdateFromSpellIdText:SetText("Update from spell id")
    pcdOptionsFrame.UpdateFromSpellIdText:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")

    pcdOptionsFrame.ShowMinimapButtonText:SetFontObject("GameFontHighlight")
    pcdOptionsFrame.ShowMinimapButtonText:SetPoint("TOPLEFT", 40, -80)
    pcdOptionsFrame.ShowMinimapButtonText:SetText("Show mini map button")
    pcdOptionsFrame.ShowMinimapButtonText:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")
    
    if PcdDb["settings"]["CloseOnEscape"] == "y" then
        pcdOptionsFrame.CloseOnEscape:SetChecked(PcdDb["settings"]["CloseOnEscape"])
    else
        pcdOptionsFrame.CloseOnEscape:SetChecked(nil)
    end

    if PcdDb["settings"]["UpdateFromSpellId"] == "y" then
        pcdOptionsFrame.UpdateFromSpellId:SetChecked(PcdDb["settings"]["UpdateFromSpellId"])
    else
        pcdOptionsFrame.UpdateFromSpellId:SetChecked(nil)
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

    pcdOptionsFrame.UpdateFromSpellId:SetPoint("TOPLEFT", 350, -54)
    pcdOptionsFrame.UpdateFromSpellId:SetScript("OnClick", 
        function()
            local isChecked = pcdOptionsFrame.UpdateFromSpellId:GetChecked()
            if (isChecked) then
                pcdOptionsFrame.UpdateFromSpellId:SetChecked(true)
                EnableUpdateFromSpellId(true)
            else
                pcdOptionsFrame.UpdateFromSpellId:SetChecked(nil)
                DisableUpdateFromSpellId(true)
            end
        end)

    pcdOptionsFrame.ShowMinimapButton:SetPoint("TOPLEFT", 350, -74)
    pcdOptionsFrame.ShowMinimapButton:SetScript("OnClick",
        function()
            local isChecked = pcdOptionsFrame.ShowMinimapButton:GetChecked()
            if (isChecked) then
                pcdOptionsFrame.ShowMinimapButton:SetChecked(true)
                EnableMinimapButton(true)
            else
                pcdOptionsFrame.ShowMinimapButton:SetChecked(nil)
                DisableMinimapButton(true)
            end
        end)
    
    pcdOptionsFrame.CloseOnEscape:Show()
    pcdOptionsFrame.UpdateFromSpellId:Show()
    pcdOptionsFrame.ShowMinimapButton:Show()
    pcdOptionsFrame.CloseOnEscape.tooltip = "If checked, Pcd frames will close when hitting the escape key"
    pcdOptionsFrame.UpdateFromSpellId.tooltip = "If checked, Pcd data will be updated from spell id on every profession craft."
    SetFrameTitle(pcdOptionsFrame, "PCD options")
    RegisterFrameForDrag(pcdOptionsFrame)
    
    pcdOptionsFrame:Show()
    pcdOptionsFrame:SetPoint("CENTER", UIParent, "CENTER")
    pcdOptionsFrame:SetSize(400, 100)
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
    RegisterFrameForDrag(pcdFrame)
    local charSpellAndCd = GetAllNamesAndCdsOnAccount()
    local frameHeight = 50 + 17 * #charSpellAndCd
    pcdFrame:SetSize(350,frameHeight)
    local sortedProfData = {}
    for i = 1, #charSpellAndCd do
        sortedProfData[i] = charSpellAndCd[i]
    end
    table.sort(sortedProfData, function (lhs, rhs) return lhs[3] < rhs[3] end)

    ClearFontStrings(pcdFrame)
    for i = 1, #sortedProfData do
        if sortedProfData[i] then
            local line = sortedProfData[i]
            local cooldownText = GetCooldownText(line[3])
            AddTextWithCDToFrame(pcdFrame, line[1] .. " - " .. line[2], "" .. cooldownText.text, i, cooldownText.color)
        end
    end
    pcdFrame:Show()
    logIfLevel (1, "PCD frame created")
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
end

function EnableUpdateFromSpellId(shouldPrint)
    pcdUpdateFromSpellId = true
    if PcdDb["settings"] then
        PcdDb["settings"]["UpdateFromSpellId"] = "y"
    end
    if shouldPrint then
        print ('Enabled cooldown updates from spell id (BETA), updated on every craft. Can be manually called by using the "/pcd update" command.')
    end
end

function DisableUpdateFromSpellId(shouldPrint)
    pcdUpdateFromSpellId = nil
    if PcdDb["settings"] then
        PcdDb["settings"]["UpdateFromSpellId"] = "n"
    end
    if shouldPrint then
        print ('Disabled cooldown updates from spell id (BETA). Can still be manually called by using "/pcd update" from macro or chat command.')
    end
end

function DisableCloseOnEscape(shouldPrint)
    if PcdDb and PcdDb["settings"] then
        PcdDb["settings"]["CloseOnEscape"] = "n"
    end
    if shouldPrint then
        print ("Disabled 'Close On Escape' for PCD. Reload UI (/reload) for this to take effect.")
    end
end

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
    print ("/pcd update, triggers a manual update from spell id. This feature is still in development.")
    print("Type /pcd options to open options menu.")
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
        UpdateTo0103()
        UpdateTo0104()
        UpdateTo0107()
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
                InitDbTable()
                UpdateCharacterProfessionDb()
                UpdateCds()
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
		C_Timer.After(0.1, function()
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
            tooltip:AddDoubleLine(line[1].." - " .. line[2], "" .. cooldownText.text, 1, 1, 1, cooldownText.color[1], cooldownText.color[2], cooldownText.color[3])
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

function TogglePcdFrame()
    UpdateDataFormatVersion()
    if pcdFrame and pcdFrame:IsShown() then
        pcdFrame:Hide()
    else
        UpdateCds()
        CreatePCDFrame()
    end
end

function ToggleOptionsFrame()
    InitDbTable()
    if pcdOPtionsFrame and pcdOptionsFrame:IsShown() then
        pcdOptionsFrame:Hide()
    else
        CreatePcdOptionsFrame()
    end
end

SLASH_PCD1 = "/pcd"
SlashCmdList["PCD"] = function(msg)
    if msg == "update" then
        UpdateCds()
    elseif msg == nil or msg == "" then
        TogglePcdFrame()
    elseif msg == "options" then
        ToggleOptionsFrame()
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