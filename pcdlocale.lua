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
local inscription = "inscription"
local mining = "mining"
local engineering = "engineering"
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
        [engineering] = engineering,
        [pcdLootCreated] = pcdLootCreated,
        [pcdLearnedRecipe] = pcdLearnedRecipe,
        [pcdReceiveItem] = pcdReceiveItem
    },
    ["deDE"] = {
        ["alchimie"] = alchemy,
        ["juwelenschleifen"] = jewelcrafting,
        ["lederverarbeitung"] = leatherworking,
        ["schneiderei"] = tailoring,
        ["verzauberkunst"] = enchanting,
        ["inschriftenkunde"] = inscription,
        ["bergbau"] = mining,
        ["ingenieurskunst"] = engineering,
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
        ["ingeniería"] = engineering,
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
        ["ingeniería"] = engineering,
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
        ["ingénierie"] = engineering,
        [pcdLootCreated] = "Vous créez",
        [pcdLearnedRecipe] = "Vous avez appris ",
        [pcdReceiveItem] = "Vous recevez l'objet"
    },
    ["itIT"] = {
        ["alchimia"] = alchemy,
        ["jewelcrafting"] = jewelcrafting,
        ["conciatura"] = leatherworking,
        ["tailoring"] = tailoring,
        ["incantamento"] = enchanting,
        ["runografia"] = inscription,
        ["estrazione"] = mining,
        ["ingegneria"] = engineering,
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
        ["기계공학"] = engineering,
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
        ["engenharia"] = engineering,
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
        ["инженерное дело"] = engineering,
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
        ["工程学"] = engineering,
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
        ["工程學"] = engineering,
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

