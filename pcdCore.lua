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

function GetSecondsLeftOnItemCd(itemID)
    local startTime, duration, _ = C_Container.GetItemCooldown(itemID)
    local secondsLeft = GetCooldownLeftOnItem(startTime, duration)
    return secondsLeft
end

function GetCooldownTimestamp(spellId)
    local start, duration, enabled, x = GetSpellCooldown(spellId)
    local leftOnSpell = GetCooldownLeftOnItem(start, duration)
    local doneAt = leftOnSpell + GetServerTime()
    
    return doneAt
end

function HasCurrentCooldown(spellId)
    -- /script print(GetItemInfo(29376))
    -- if item is not null, call item cd function
    if spellId == saltShakerItemId then 
        return GetSecondsLeftOnItemCd(spellId) > 0
    end

    -- else call spell cd function
    return select(1, GetSpellCooldown(spellId)) > 0
end

function GetCharAndRealm()
    return UnitName("Player") .. ":" .. GetRealmName()
end

function SetCooldownForSpellId(spellId)
    local charAndRealm = GetCharAndRealm()

    if not ListContains(charAndRealm, PcdDb) then
        PcdDb[charAndRealm] = {}
    end
    if (ListContains(charAndRealm, PcdDb)) then

        -- pcd db - chars, settings, filters
        -- table insert cooldowns spellId = doneAt
        --PcdDb[charAndRealm]["cooldowns"] 
    end
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