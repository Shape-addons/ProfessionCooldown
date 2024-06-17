local section = "filters"

function GetCharGlobalFilter(filterNameAndRealm)
    return PcdDb[section][filterNameAndRealm]["global"]
end
function SetCharGlobalFilter(filterNameAndRealm, filterValue)
    PcdDb[section][filterNameAndRealm]["global"] = filterValue
end

function GetSpellGlobalFilter(spellId)
    return PcdDb[section]["global"][spellId]
end
function SetSpellGlobalFilter(spellId, filterValue)
    PcdDb[section]["global"][spellId] = filterValue
end

function GetSpellCharFilter(filterNameAndRealm, spellId)
    return PcdDb[section][filterNameAndRealm][spellId]
end

function SetSpellCharFilter(filterNameAndRealm, spellId, filterValue)
    PcdDb[section][filterNameAndRealm][spellId] = filterValue
end