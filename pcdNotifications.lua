-- show draggable small window - with all active CDs
--/script for k, v in pairs(GetAllNamesAndCdsOnAccount()) do print (v[1] .. ", " .. v[2] ..", " .. v[3]) end

--/script for k, v in pairs(GetAllNamesAndCdsOnAccount()) do print (GetTextBefore(v[1], ":") .. ", " .. GetCdNameFromSpellId(v[2]) ..", " .. GetCooldownText(v[3]).text) end

function AddIconToFiltersFrame(index, itemId, spellId)
    local posX = GetFilterIndexPosX(index)
    if itemId == nil then itemId = "null" end
    logIfLevel(1, "getting icon for index " .. index .. " item id " .. itemId)
    local myIcon = GetItemIcon(itemId)

    return AddIconToFrame(pcdFiltersFrame, "TOPLEFT", posX, -50, 28, 28, myIcon, spellId)
end

local pcdNotificationsFrame = CreateFrame("Frame", "PCDNotificationsFrame", UIParent)
function createPcdNotificationsFrame()
    pcdNotificationsFrame:ClearAllPoints()
    pcdNotificationsFrame:Hide()
    InitDbTable()
    local charNameSpellIdRemaining = GetAllNamesAndCdsOnAccount()
    for k, v in pairs(charNameSpellIdRemaining) do print (GetTextBefore(v[1], ":") .. ", " .. GetCdNameFromSpellId(v[2]) ..", " .. GetCooldownText(v[3]).text) end
    local height = 50
    local width = 50 * #charNameSpellIdRemaining
    pcdNotificationsFrame:SetSize(width, height)
    pcdNotificationsFrame:Show()
    pcdNotificationsFrame:SetPoint("CENTER", UIParent, "CENTER")
end