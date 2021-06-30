-- PCD start
local pcdVersion = "1.04"
pcdUpdateFromSpellId = nil
local pcdIsLoaded = nil
local profCdTrackerFrame = CreateFrame("Frame")
profCdTrackerFrame:RegisterEvent("TRADE_SKILL_SHOW")
profCdTrackerFrame:RegisterEvent("TRADE_SKILL_UPDATE")
profCdTrackerFrame:RegisterEvent("TRADE_SKILL_CLOSE")
profCdTrackerFrame:RegisterEvent("ADDON_LOADED")
profCdTrackerFrame:SetScript("OnEvent", function(self, event, arg1, ...)
    if (event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE" or event == "TRADE_SKILL_CLOSE") then
        GetProfessionCooldowns()
        if pcdFrame and pcdFrame:IsShown() then
            pcdFrame:Hide()
            CreatePCDFrame()
        end
    elseif not pcdIsLoaded and ((event == "ADDON_LOADED" and arg1 == "ProfessionCooldown") or event == "PLAYER_LOGIN") then
        pcdIsLoaded = true
        if PcdDb and PcdDb["settings"] then
            pcdUpdateFromSpellId = PcdDb["settings"]["UpdateFromSpellId"]
        end
    end
end)

local lootMsgFrame = CreateFrame("Frame")
lootMsgFrame:RegisterEvent("CHAT_MSG_LOOT")
lootMsgFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "CHAT_MSG_LOOT" then
        if (arg1:find("^You create:") ~= nil) then
            if pcdFrame and pcdFrame:IsShown() then
                pcdFrame:Hide()
                if not pcdUpdateFromSpellId then
                    GetProfessionCooldowns()
                else 
                    GetCooldownsFromSpellIds()
                end
                CreatePCDFrame()
            end
        end
    end
end)

function getProfessionName(abilityName)
    if string.find(abilityName, "Transmute") then
        return "Alchemy"
    elseif string.find(abilityName, "Cloth") or string.find(abilityName, "cloth") then
        return "Tailoring"
    elseif string.find(abilityName, "Brilliant Glass") then
        return "Jewelcrafting"
    end
    -- todo: would it make sense to add JC stuff here? there is the brilliant glass thing..
    return nil
end

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
                    logIfLevel (3, "ERROR: UNKNOWN PROFESSION!! Skill name was: " .. skillName)
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
    end
end

function UpdateTo0104()
    RemoveCdInDb("Alchemy", "Transmute: Primal Mana to fIRE")
    RemoveCdInDb("Alchemy", "Transmute: Primal Water to Shadow")
    RemoveCdInDb("Tailoring", "Mooncloth")
    PcdDb["settings"]["version"] = "1.04"
end

function RemoveCdInDb(prof, name)
    if PcdDb then
        for charName, profs in pairs(PcdDb) do
            if PcdDb[charName]["professions"] and PcdDb[charName]["professions"][prof] and PcdDb[charName]["professions"][prof]["cooldowns"] then
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

-- function GetCooldownLeftOnSpell(spellId)
--     local start, duration, enabled, x = GetSpellCooldown(spellId) -- only primal might has to be checked.
--     -- local getTimeValue = GetTime()
--     -- local getServerTimeValue = GetServerTime()
--     -- local offset = GetServerTime() - GetTime()
--     -- print ("start is " .. start + offset)
--     -- print ("duration is " .. duration)
--     -- return GetCooldownLeftOnItem(start + offset, duration)
--     -- print ("start is: " .. start)
--     -- print ("duration is: " .. duration)
--     -- local leftOnSpell = GetCooldownLeftOnItem(start, duration)
--     -- print ("left is: " .. leftOnSpell) -- is equal to seconds left.
--     -- local doneAt = leftOnSpell + GetServerTime()

--     -- return doneAt
-- end

function GetCooldownsFromSpellIds()
    logIfLevel(2, "updating from spell id")
    InitDbTable()
    local charName = UnitName("Player")
    if PcdDb and PcdDb[charName] and PcdDb[charName]["professions"] then
        logIfLevel(2, "in if")
        if PcdDb[charName]["professions"]["Alchemy"] then
            logIfLevel(1, "alchemy found")
            if not PcdDb[charName]["professions"]["Alchemy"]["cooldowns"] then 
                PcdDb[charName]["professions"]["Alchemy"]["cooldowns"] = {}
            end
            PcdDb[charName]["professions"]["Alchemy"]["cooldowns"]["Transmute"] = GetCooldownTimestamp(primalMightId)
        end
        if PcdDb[charName]["professions"]["Tailoring"] then
            logIfLevel(1, "Tailoring found")
            if not PcdDb[charName]["professions"]["Tailoring"]["cooldowns"] then 
                PcdDb[charName]["professions"]["Tailoring"]["cooldowns"] = {}
            end
            PcdDb[charName]["professions"]["Tailoring"]["cooldowns"]["Primal Mooncloth"] = GetCooldownTimestamp(primalMoonclothId)
            PcdDb[charName]["professions"]["Tailoring"]["cooldowns"]["Spellcloth"] = GetCooldownTimestamp(spellclothId)
            PcdDb[charName]["professions"]["Tailoring"]["cooldowns"]["Shadowcloth"] = GetCooldownTimestamp(shadowclothId)
        end
        if PcdDb[charName]["professions"]["Jewelcrafting"] then
            logIfLevel(1, "Jewelcrafting found")
            if not PcdDb[charName]["professions"]["Jewelcrafting"]["cooldowns"] then
                PcdDb[charName]["professions"]["Jewelcrafting"]["cooldowns"] = {}
            end
            PcdDb[charName]["professions"]["Jewelcrafting"]["cooldowns"] = GetCooldownTimestamp(brilliantGlassId)
        end
    end
end

function GetCooldownTimestamp(spellId)
    local start, duration, enabled, x = GetSpellCooldown(spellId)
    local leftOnSpell = GetCooldownLeftOnItem(start, duration)
    local doneAt = leftOnSpell + GetServerTime()

    return doneAt
end

-- local tbcTransmuteIds = {
--     29688, -- primal might
--     32765, -- earthstorm diamond
--     32766, -- skyfire diamond
--     28566, -- primal air to fire
--     28567, -- primal earth to water
--     28582, -- primal mana to fire
--     28583, -- primal fire to mana
--     28584, -- primal life to earth
--     28585, -- primal earth to life
--     28569, -- primal water to air
--     28581, -- primal water to shadow
--     28580, -- primal shadow to water
--     28568, -- primal fire to earth
-- }

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
            primaryCount = primaryCount + 1;
            if (primaryCount < 3 and skillName) then
                local profData = {
                    profName = skillName
                }
                profData.skillLevel = skillRank
                table.insert(profs, profData)
            end
        end
    end
    for j = 0, 2 do
        if (profs[j]) then
            PcdDb[charName]["professions"][profs[j].profName] = {}
            PcdDb[charName]["professions"][profs[j].profName]["skill"] = profs[j].skillLevel
            logIfLevel (2, "Updated prof for charName: " .. profs[j].profName .. ", " .. profs[j].skillLevel)
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
        PcdDb["settings"]["UpdateFromSpellId"] = "n"
    end
    if (not next(PcdDb[charName]["professions"])) then
        UpdateCharacterProfessionDb()
        logIfLevel(1, "Updated character prof db")
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
    title:SetPoint("CENTER", theFrame, "TOP", 0 ,-20)
    title:SetText(titleText)
    title:SetFont("Fonts\\FRIZQT__.ttf", 20, "OUTLINE")
    theFrame.title = title
end

function AddTextToFrame(theFrame, text, firstPosition, secondPosition)
    local font = theFrame:CreateFontString(nil, "OVERLAY")
    font:SetFontObject("GameFontHighlight")
    font:SetPoint(firstPosition, theFrame, secondPosition)
    font:SetText(text)
    font:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")
    logIfLevel (1, "added test frame stuff")
    return font
end

function AddTextWithCDToFrame(theFrame, leftText, rightText, position, cdColor)
    if (not theFrame.fontStrings) then
        theFrame.fontStrings = {}
    end
    local nameFont
    local cdFont
    if not theFrame.fontStrings[leftText] then

        theFrame.fontStrings[leftText] = { 
            ["L"] = theFrame:CreateFontString(nil, "Overlay"), 
            ["R"] = theFrame:CreateFontString(nil, "Overlay")
        }
    end
    nameFont = theFrame.fontStrings[leftText]["L"]
    cdFont = theFrame.fontStrings[leftText]["R"]

    local actualPosition = -6 -14 * (position + 1)
    nameFont:SetFontObject("GameFontHighlight")
    nameFont:SetPoint("TOPLEFT", 10, actualPosition)
    nameFont:SetText(leftText)
    nameFont:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")

    cdFont:SetFontObject("GameFontHighlight")
    cdFont:SetText(rightText)
    cdFont:SetPoint("TOPRIGHT", -10, actualPosition)
    cdFont:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")
    cdFont:SetTextColor(cdColor[1], cdColor[2], cdColor[3], cdColor[4])
end

function GetAllNamesAndCdsOnAccount()
    local charSpellAndCd = {}
    local profNamesToConsider = { "Alchemy", "Tailoring", "Leatherworking", "Blacksmithing", "Jewelcrafting" }
    local allOnAccount = PcdDb
    if (not allOnAccount) then
        return
    end
    for charName, professions in pairs(PcdDb) do
        if not (charName == "settings") then
            for profTag, profs in pairs(professions) do 
                for profName, profData in pairs(profs) do
                    if profData["cooldowns"] then
                        for spellName, doneAt in pairs(profData["cooldowns"]) do
                            table.insert(charSpellAndCd, {charName, spellName, doneAt} )
                        end
                    end
                end
            end
        end
    end
    return charSpellAndCd
end

pcdOptionsFrame = CreateFrame("Frame", "PcdOptionsFrame", UIParent)
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
            EnableUpdateFromSpellId(true)
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

    pcdOptionsFrame.CloseOnEscapeText:SetFontObject("GameFontHighlight")
    pcdOptionsFrame.CloseOnEscapeText:SetPoint("TOPLEFT", 40, -40)
    pcdOptionsFrame.CloseOnEscapeText:SetText("Close on escape (disable requires reload)")
    pcdOptionsFrame.CloseOnEscapeText:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")

    pcdOptionsFrame.UpdateFromSpellIdText:SetFontObject("GameFontHighlight")
    pcdOptionsFrame.UpdateFromSpellIdText:SetPoint("TOPLEFT", 40, -60)
    pcdOptionsFrame.UpdateFromSpellIdText:SetText("Update from spell id")
    pcdOptionsFrame.UpdateFromSpellIdText:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")
    
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
                PcdDb["settings"]["UpdateFromSpellId"] = "y"
                EnableUpdateFromSpellId(true)
            else
                pcdOptionsFrame.UpdateFromSpellId:SetChecked(nil)
                PcdDb["settings"]["UpdateFromSpellId"] = "n"
                DisableUpdateFromSpellId(true)
            end
        end)
    
    pcdOptionsFrame.CloseOnEscape:Show()
    pcdOptionsFrame.UpdateFromSpellId:Show()
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
    for i = 1, #sortedProfData do
        if sortedProfData[i] then
            local line = sortedProfData[i]
            local cdText = ""
            local secondsLeft = line[3] - GetServerTime()
            logIfLevel (1, "secs left: " .. secondsLeft)
            local hoursLeft = secondsLeft / 3600
            local cdColor
            if line[3] and hoursLeft <= 0 then
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
            AddTextWithCDToFrame(pcdFrame, line[1] .. " - " .. line[2], "" .. cdText, i, cdColor)
        end
    end
    pcdFrame:Show()
    logIfLevel (1, "PCD frame created")
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
    print ('Enabled cooldown updates from spell id (BETA), updated on every craft. Can be manually called by using the "/pcd update" command.')
end

function DisableUpdateFromSpellId(shouldPrint)
    -- pcdUpdateFromSpellId = nil
    if PcdDb["settings"] then
        PcdDb["settings"]["UpdateFromSpellId"] = "n"
    end
    print ('Disabled cooldown updates from spell id (BETA). Can still be manually called by using "/pcd update" from macro or chat command.')
end

function DisableCloseOnEscape(shouldPrint)
    if PcdDb and PcdDb["settings"] then
        PcdDb["settings"]["CloseOnEscape"] = "n"
        if (shouldPrint) then
            print ("Disabled 'Close On Escape' for PCD. Reload UI (/reload) for this to take effect.")
        end
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


function UpdatePcdDb()
    if ShouldPcdUpdate() then
        UpdateTo0103()
        UpdateTo0104()
    end
end



SLASH_PCD1 = "/pcd"
SlashCmdList["PCD"] = function(msg)
    if msg == "update" then
        GetCooldownsFromSpellIds()
        if pcdFrame and pcdFrame:IsShown() then
            CreatePCDFrame()
        end
    elseif msg == nil or msg == "" then
        UpdatePcdDb()
        if pcdFrame and pcdFrame:IsShown() then
            pcdFrame:Hide()
        else
            if not pcdUpdateFromSpellId then
                GetProfessionCooldowns()
            else 
                GetCooldownsFromSpellIds()
            end
            CreatePCDFrame()
        end
    elseif msg == "options" then
        InitDbTable()
        CreatePcdOptionsFrame()
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
    elseif msg == "help" then
        PrintHelp()
    end
end 