-- PCD start
local profCdTrackerFrame = CreateFrame("Frame")
profCdTrackerFrame:RegisterEvent("TRADE_SKILL_SHOW")
profCdTrackerFrame:RegisterEvent("TRADE_SKILL_UPDATE")
profCdTrackerFrame:RegisterEvent("TRADE_SKILL_CLOSE")
profCdTrackerFrame:SetScript("OnEvent", function(self, event, ...)
    if (event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE" or event == "TRADE_SKILL_CLOSE") then
        GetProfessionCooldowns()
        if pcdFrame and pcdFrame:IsShown() then
            pcdFrame:Hide()
            CreatePCDFrame()
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
                GetProfessionCooldowns()
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
                if (IsVanillaTransmute(skillName)) then
                    skillName = "Transmute (Vanilla)"
                elseif IsTransmuteTBC(skillName) then
                    skillName = "Transmute (TBC)"
                end
                PcdDb[charName]["professions"][professionGuess]["cooldowns"][skillName] = doneAt
                logIfLevel(2, "saved " .. skillName .. ": " .. string.format("%.2f", hoursLeft) .. " from now.")
            end
        end
    end
end

function GetProfessionCooldowns()
    InitDbTable()
    local charName = UnitName("player")
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
    ["Transmute: Primal Mana to Fire"] = true,
    ["Transmute: Primal Earth to Life"] = true,
    ["Transmute: Primal Shadow to Water"] = true,
    ["Transmute: Skyfire Diamond"] = true,
    ["Transmute: Earthstorm Diamond"] = true,
    ["Transmute: Primal Earth to Water"] = true,
    ["Transmute: Primal Water to Air"] = true,
    ["Transmute: Primal Life to Earth"] = true,
    ["Transmute: Primal Air to Fire"] = true,
    ["Transmute: Primal Fire to Mana"] = true,
    ["Transmute: Primal Fire to Earth"] = true,
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

function CreateTestFrame()
    local testFrame = CreateFrame("Frame", "DragFrame1", UIParent)
    testFrame:SetSize(600,600)
    testFrame:SetPoint("LEFT", UIParent, "LEFT")
    SetFrameTitle(testFrame, "TEST FRAME")
    RegisterFrameForDrag(testFrame)
    testFrame.doubletopleft = AddTextToFrame(testFrame, "TOP LEFT x2", "TOPLEFT", "TOPLEFT")
    testFrame.topleftright = AddTextToFrame(testFrame, "TOP LEFT - RIGHT", "TOPLEFT", "RIGHT")
    testFrame.doublebotleft = AddTextToFrame(testFrame, "BOT LEFT x2", "BOTTOMLEFT", "BOTTOMLEFT")
    testFrame.botleftright = AddTextToFrame(testFrame, "BOT LEFT - RIGHT", "BOTTOMLEFT", "RIGHT")
    testFrame:Show()
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

    local actualPosition = -20 * (position + 1)
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

pcdFrame = CreateFrame("Frame", "PCDOverviewFrame", UIParent)
tinsert(UISpecialFrames, pcdFrame:GetName())
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
    if pcdFrame and pcdFrame:IsShown() then
        pcdFrame:Hide()
    end
    SetFrameTitle(pcdFrame, "Profession CD Tracker")
    RegisterFrameForDrag(pcdFrame)
    local charSpellAndCd = GetAllNamesAndCdsOnAccount()
    local frameHeight = 50 + 20 * #charSpellAndCd
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

function ResetPosition()
    if PcdDb["settings"] and PcdDb["settings"]["position"] then
        PcdDb["settings"]["position"] = {}
    end
end

function PrintHelp()
    print("Profession Cooldown (PCD) tracks your profession cooldowns. type /pcd to toggle the main frame visibility.")
    print("Cooldowns are updated when you open or close the given profession. Cooldowns are only added to the list once they are on cooldown, but will show up after that.")
    print("Drag the window to change its position. Close it by clicking 'X' button or press the Escape key")
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

SLASH_PCD1 = "/pcd"
SlashCmdList["PCD"] = function(msg)
    if msg == nil or msg == "" then
        if pcdFrame and pcdFrame:IsShown() then
            pcdFrame:Hide()
        else
            GetProfessionCooldowns()
            CreatePCDFrame()
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
    elseif msg == "help" then
        PrintHelp()
    end
end 