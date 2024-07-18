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
pcdLootCreated = "You create"
pcdLearnedRecipe = "You have learned"
pcdReceiveItem = "You receive item"

-- see https://github.com/tekkub/wow-globalstrings
PCDL = {
    ["enUS"] = {
        [alchemy] = alchemy,
        [jewelcrafting] = jewelcrafting,
        [leatherworking] = leatherworking,
        [tailoring] = tailoring,
        [enchanting] = enchanting,
        [inscription] = inscription,
        [mining] = mining,
        [pcdLootCreated] = pcdLootCreated,
        [pcdLearnedRecipe] = pcdLearnedRecipe,
        [pcdReceiveItem] = pcdReceiveItem
    },
    ["deDE"] = {
        ["alchemie"] = alchemy,
        ["juwelierskunst"] = jewelcrafting,
        ["lederverarbeitung"] = leatherworking,
        ["schneiderei"] = tailoring,
        ["verzauberkunst"] = enchanting,
        ["inschriftenkunde"] = inscription,
        ["bergbau"] = mining,
        [pcdLootCreated] = "Ihr stellt her",
        [pcdLearnedRecipe] = "Ihr habt gelernt",
        [pcdReceiveItem] = "Ihr bekommt einen Gegenstand:"
    },
    ["esES"] = {
        ["alquimia"] = alchemy,
        ["joyería"] = jewelcrafting,
        ["peletería"] = leatherworking,
        ["sastrería"] = tailoring,
        ["encantamiento"] = enchanting,
        ["inscripción"] = inscription,
        ["minería"] = mining,
        [pcdLootCreated] = "Creas",
        [pcdLearnedRecipe] = "Has aprendido",
        [pcdReceiveItem] = "Recibes:"
    },
    ["esMX"] = {
        ["alquimia"] = alchemy,
        ["joyería"] = jewelcrafting,
        ["peletería"] = leatherworking,
        ["sastrería"] = tailoring,
        ["encantamiento"] = enchanting,
        ["inscripción"] = inscription,
        ["minería"] = mining,
        [pcdLootCreated] = "Creas",
        [pcdLearnedRecipe] = "Has aprendido",
        [pcdReceiveItem] = "Recibes:"
    },
    ["frFR"] = {
        ["alchimie"] = alchemy,
        ["joaillerie"] = jewelcrafting,
        ["travail du cuir"] = leatherworking,
        ["couture"] = tailoring,
        ["enchantement"] = enchanting,
        ["calligraphie"] = inscription,
        ["minage"] = mining,
        [pcdLootCreated] = "Vous créez",
        [pcdLearnedRecipe] = "Vous avez appris ",
        [pcdReceiveItem] = "Vous recevez l'objet"
    },
    ["itIT"] = {
        ["alchimia"] = alchemy,
        ["oreficeria"] = jewelcrafting,
        ["conciatura"] = leatherworking,
        ["sartoria"] = tailoring,
        ["incantamento"] = enchanting,
        ["runografia"] = inscription,
        ["estrazione"] = mining,
        [pcdLootCreated] = "Hai creato",
        [pcdLearnedRecipe] = "Hai imparato",
        [pcdReceiveItem] = "Hai ricevuto:"
    },
    ["koKR"] = {
        ["연금술"] = alchemy,
        ["보석세공"] = jewelcrafting,
        ["가죽세공"] = leatherworking,
        ["재봉술"] = tailoring,
        ["마법부여"] = enchanting,
        ["주문각인"] = inscription,
        ["채광"] = mining,
        [pcdLootCreated] = "만들었습니다",
        [pcdLearnedRecipe] = "익혔습니다",
        [pcdReceiveItem] = "아이템을 획득했습니다:"
    },
    ["ptBR"] = {
        ["alquimia"] = alchemy,
        ["joalheria"] = jewelcrafting,
        ["couraria"] = leatherworking,
        ["alfaiataria"] = tailoring,
        ["encantamento"] = enchanting,
        ["escrivania"] = inscription,
        ["mineração"] = mining,
        [pcdLootCreated] = "Você cria",
        [pcdLearnedRecipe] = "Você aprendeu",
        [pcdReceiveItem] = "Você recebe o item:"
    },
    ["ruRU"] = {
        ["алхимия"] = alchemy,
        ["ювелирное дело"] = jewelcrafting,
        ["кожевничество"] = leatherworking,
        ["портняжное дело"] = tailoring,
        ["наложение чар"] = enchanting,
        ["начертание"] = inscription,
        ["горное дело"] = mining,
        [pcdLootCreated] = "Вы создаете",
        [pcdLearnedRecipe] = "Вы научились создавать",
        [pcdReceiveItem] = "Вы получаете предмет:"
    },
    ["zhCN"] = {
        ["炼金术"] = alchemy,
        ["珠宝加工"] = jewelcrafting,
        ["制皮"] = leatherworking,
        ["裁缝"] = tailoring,
        ["附魔"] = enchanting,
        ["铭文"] = inscription,
        ["采矿"] = mining,
        [pcdLootCreated] = "你制造了",
        [pcdLearnedRecipe] = "你已经学会了",
        [pcdReceiveItem] = "你获得了物品"
    },
    ["zhTW"] = {
        ["鍊金術"] = alchemy,
        ["珠寶設計"] = jewelcrafting,
        ["製皮"] = leatherworking,
        ["裁縫"] = tailoring,
        ["附魔"] = enchanting,
        ["銘文"] = inscription,
        ["採礦"] = mining,
        [pcdLootCreated] = "你製造了",
        [pcdLearnedRecipe] = "你已經學會了",
        [pcdReceiveItem] = "你獲得了物品"
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

