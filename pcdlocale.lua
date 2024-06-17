-- PCDL= {
--     ["alchemy"] = {
--         ["enUS"] = "alchemy",
--         ["deDE"] = "alchimie",
--         ["esES"] = "alquimia",
--         ["frFR"] = "alchimie",
--         ["itIT"] = "alchemy",
--         ["ptBR"] = "alquimia",
--         ["ruRU"] = "Алхимия",
--         ["koKR"] = "연금술",
--         ["zhCN"] = "炼金术",
--     },
--     ["tailoring"] = {
--         ["enUS"] = "tailoring",
--         ["deDE"] = "schneiderei",
--         ["esES"] = "sastrería",
--         ["frFR"] = "couture",
--         ["itIT"] = "tailoring",
--         ["ptBR"] = "alfaiataria",
--         ["ruRU"] = "Портняжное дело",
--         ["koKR"] = "재봉술",
--         ["zhCN"] = "裁缝",
--     },
--     ["jewelcrafting"] = {
--         ["enUS"] = "tailoring",
--         ["deDE"] = "juwelenschleifen",
--         ["esES"] = "joyería",
--         ["frFR"] = "joaillerie",
--         ["itIT"] = "jewelcrafting",
--         ["ptBR"] = "joalheria",
--         ["ruRU"] = "Ювелирное дело",
--         ["koKR"] = "보석세공",
--         ["zhCN"] = "珠宝加工",
--     },
--     ["leatherworking"] = {
--         ["enUS"] = "leatherworking",
--         ["deDE"] = "lederverarbeitung",
--         ["esES"] = "peletería",
--         ["frFR"] = "travail du cuir",
--         ["itIT"] = "leatherworking",
--         ["ptBR"] = "couraria",
--         ["ruRU"] = "Кожевничество",
--         ["koKR"] = "가죽세공",
--         ["zhCN"] = "制皮",
--     },
--     ["enchanting"] = {
--         ["enUS"] = "enchanting",
--         ["enUS"] = "verzauberkunst",
--     }
-- }

local alchemy = "alchemy"
local jewelcrafting = "jewelcrafting"
local leatherworking = "leatherworking"
local tailoring = "tailoring"
local enchanting = "enchanting"
local inscription = "incscription"
local mining = "mining"

PCDL = {
    ["enUS"] = {
        [alchemy] = alchemy,
        [jewelcrafting] = jewelcrafting,
        [leatherworking] = leatherworking,
        [tailoring] = tailoring,
        [enchanting] = enchanting,
        [inscription] = inscription,
        [mining] = mining,
    },
    ["deDE"] = {
        ["alchemie"] = alchemy,
        ["juwelenschleifen"] = jewelcrafting,
        ["lederverarbeitung"] = leatherworking,
        ["schneiderei"] = tailoring,
        ["verzauberkunst"] = enchanting,
        ["inschrift"] = inscription,
        ["bergbau"] = mining,
    },
    ["esES"] = {
        ["alquimia"] = alchemy,
        ["joyería"] = jewelcrafting,
        ["peletería"] = leatherworking,
        ["sastrería"] = tailoring,
        ["encantamiento"] = enchanting,
        ["inscripción"] = inscription,
        ["minería"] = mining,
    },
    ["frFR"] = {
        ["alchimie"] = alchemy,
        ["joaillerie"] = jewelcrafting,
        ["travail du cuir"] = leatherworking,
        ["couture"] = tailoring,
        ["enchentement"] = enchanting,
        ["calligraphie"] = inscription,
        ["minage"] = mining,
    },
    ["itIT"] = {
        ["alchimia"] = alchemy,
        ["oreficeria"] = jewelcrafting,
        ["conciatura"] = leatherworking,
        ["sartoria"] = tailoring,
        ["incantamento"] = enchanting,
        ["runografia"] = inscription,
        ["estrazione"] = mining,
    },
    ["ptBR"] = {
        ["alquimia"] = alchemy,
        ["joalheria"] = jewelcrafting,
        ["courearia"] = leatherworking,
        ["alfaiataria"] = tailoring,
        ["encantamento"] = enchanting,
        ["escrivania"] = inscription,
        ["mineração"] = mining,
    },
    ["ruRU"] = {
        ["алхимия"] = alchemy,
        ["ювелирное дело"] = jewelcrafting,
        ["кожевничество"] = leatherworking,
        ["портняжное дело"] = tailoring,
        ["наложение чар"] = enchanting,
        ["начертание"] = inscription,
        ["горное дело"] = mining,
    },
    ["koKR"] = {
        ["연금술"] = alchemy,
        ["보석세공"] = jewelcrafting,
        ["가죽세공"] = leatherworking,
        ["재봉술"] = tailoring,
        ["마법부여"] = enchanting,
        ["주문각인"] = inscription,
        ["채광"] = mining,
    },
    ["zhCN"] = {
        ["炼金术"] = alchemy,
        ["珠宝加工"] = jewelcrafting,
        ["制皮"] = leatherworking,
        ["裁缝"] = tailoring,
        ["附魔"] = enchanting,
        ["铭文"] = inscription,
        ["采矿"] = mining,
    }
}

-- PCDL= {
--     ["enUS"] = {
--         [alchemy] = alchemy,
--         [jewelcrafting] = jewelcrafting,
--         [leatherworking] = leatherworking,
--         [tailoring] = tailoring,
--         [enchanting] = enchanting,
--         [inscription] = inscription,
--         [mining] = mining,
--     },
--     ["deDE"] = {
--         ["alchimie"] = alchemy,
--         ["juwelenschleifen"] = jewelcrafting,
--         ["lederverarbeitung"] = leatherworking,
--         ["schneiderei"] = tailoring,
--         ["verzauberkunst"] = enchanting,
--         [inscription] = inscription,
--         [mining] = mining,
--     }

--     ["alchemy"] = {
--         ["deDE"] = "alchimie",
--         ["esES"] = "alquimia",
--         ["frFR"] = "alchimie",
--         ["itIT"] = "alchemy",
--         ["ptBR"] = "Alquimia",
--         ["ruRU"] = "Алхимия",
--         ["koKR"] = "연금술",
--         ["zhCN"] = "炼金术",
--     },
--     ["tailoring"] = {
--         ["enUS"] = "tailoring",
--         ["deDE"] = "Schneiderei",
--         ["esES"] = "Sastrería",
--         ["frFR"] = "Couture",
--         ["itIT"] = "Tailoring",
--         ["ptBR"] = "Alfaiataria",
--         ["ruRU"] = "Портняжное дело",
--         ["koKR"] = "재봉술",
--         ["zhCN"] = "裁缝",
--     },
--     ["jewelcrafting"] = {
--         ["enUS"] = "tailoring",
--         ["deDE"] = "juwelenschleifen",
--         ["esES"] = "joyería",
--         ["frFR"] = "joaillerie",
--         ["itIT"] = "jewelcrafting",
--         ["ptBR"] = "joalheria",
--         ["ruRU"] = "Ювелирное дело",
--         ["koKR"] = "보석세공",
--         ["zhCN"] = "珠宝加工",
--     },
--     ["leatherworking"] = {
--         ["enUS"] = "leatherworking",
--         ["deDE"] = "lederverarbeitung",
--         ["esES"] = "peletería",
--         ["frFR"] = "travail du cuir",
--         ["itIT"] = "leatherworking",
--         ["ptBR"] = "couraria",
--         ["ruRU"] = "Кожевничество",
--         ["koKR"] = "가죽세공",
--         ["zhCN"] = "制皮",
--     },
-- }

