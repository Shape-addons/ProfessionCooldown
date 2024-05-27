-- local allVanillaTransmuteIds = {
allTransmuteIds = {
    -- vanilla transmutes with 1 day cd
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
    17187, -- Arcanite (no cd after classic)
    25146, -- Elemental Fire (low cd)
-- }
-- local allTbcTransmuteIds = {
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
    29688, -- Primal Might (no cd after tbc)
    32765, -- Earthstorm Diamond
    32766, -- Skyfire Diamond
    -- }
    -- wotlk
    60350, -- Titanium (no cd)
    53784, -- Eternal Water to Fire
    53783, -- Eternal Water to Air
    53782, -- Eternal Earth to Shadow
    53781, -- Eternal Earth to Air
    53780, -- Eternal Shadow to Life
    53779, -- Eternal Shadow to Earth
    53777, -- Eternal Air to Earth
    53776, -- Eternal Air to Water
    53775, -- Eternal Fire to Life
    53774, -- Eternal Fire to Water
    53773, -- Eternal Life to Fire
    53771, -- Eternal Life to Shadow
    66659, -- Cardinal Ruby
    66664, -- Eye of Zul
    66663, -- Majestic Zircon
    66662, -- Dreadstone
    66660, -- King's Amber
    66658, -- Ametrine
    57427, -- Earthsiege Diamond (no cd)
    57425, -- Skyflare Diamond (no cd)
    
    -- allCataTransmutes
    78866, -- living elements
    80244, -- Pyrium Bar
    80243, -- Truegold
}

-- vanilla
moonclothId = 18560
moonclothItemId = 14342

saltShakerItemId = 15846

arcaniteItemId = 12360 -- icon for classic transmutes

-- tbc 
-- all cooldowns have a cd start period and a cd end period
-- example: transmute arcanite starts in vanilla / era, and ends in TBC: start = 1 - end = 2
-- some cooldowns share same item icon. Show the difference with a border color.
-- eg. dream of azshara should have a 'water' border color.
-- transmutes are all kind of similar. no reason to specify them further, when not relevant.

-- vanilla
-- salt shaker
-- mooncloth cd
-- any transmute

-- tbc
primalMightId = 29688
primalMightItemId = 23571

primalMoonclothId = 26751
primalMoonclothItemId = 21845

spellclothId = 31373
spellclothItemId = 24271

shadowclothId = 36686
shadowclothItemId = 24272

brilliantGlassId = 47280
brilliantGlassItemId = 35945

voidSphereId = 28028
voidSphereItemId = 22459

-- wotlk - all on separate cooldowns
spellweaveId = 56003
spellweaveItemId = 41595

moonshroudId = 56001
moonshoudItemId = 41594

ebonweaveId = 56002
ebonweaveItemId = 41593

minorInscriptionResearchId = 61288
minorInscriptionResearchItemId = 39469 -- using moonglow ink icon

northrendInscriptionResearchId = 61177
northrendInscriptionResearchItemId = 44680 -- Assorted Writings

icyPrismId = 62242
icyPrismItemId = 44943

titanSteelId = 55208
titanStellItemId = 37663

glacialBagId = 56005
glacialBagItemId = 41600

northrendAlchemyId = 60893
northrendAlchemyItemId = 7810

-- cataclysm
firePrismId = 73478
firePrismItemId = 52304

livingElementsItemId = 30183 -- nether vortex
dreamOfAzsharaId = 75146 -- volatile water
dreamOfSkywallId = 75141 -- volatile air
dreamOfRagnarosId = 75145 -- volatile fire
dreamOfDeepholmId = 75142 -- volatile earth
dreamOfHyjalId = 75144 -- volatile life
dreamClothItemId = 54440

local function GetBorderColorFromSpellIdInternal(spellId) 
    if spellId == dreamOfHyjalId then return 61, 191, 31
    elseif spellId == dreamOfDeepholmId then return 188, 93, 29
    elseif spellId == dreamOfSkywallId then return 168, 203, 222
    elseif spellId == dreamOfRagnarosId then return 216, 32, 0
    elseif spellId == dreamOfAzsharaId then return 20, 70, 193
    else return nil
    end
end

function GetSpellColorFromSpellId(spellId)
    local r, g, b = GetBorderColorFromSpellIdInternal(spellId)
    if not r then return nil
    else return r / 255, g / 255, b / 255
    end
end

function GetItemIconFromSpellId(spellId)
    if allTransmuteIds[spellId] then return primalMightItemId end
    if spellId == northrendAlchemyId then return northrendAlchemyItemId end
    if spellId == minorInscriptionResearchId then return northrendInscriptionResearchItemId end
    if spellId == northrendInscriptionResearchId then return northrendInscriptionResearchItemId end
    
    if spellId == firePrismId then return firePrismItemId end
    if spellId == icyPrismId then return icyPrismItemId end
    if spellId == brilliantGlassId then return brilliantGlassItemId end
    
    if spellId == glacialBagId then return glacialBagItemId end
    if spellId == primalMoonclothId then return primalMoonclothItemId end
    if spellId == spellclothId then return spellclothItemId end
    if spellId == shadowclothId then return shadowclothItemId end
    if spellId == spellweaveId then return spellweaveItemId end
    if spellId == ebonweaveId then return ebonweaveItemId end
    if spellId == moonshroudId then return moonshroudItemId end
    if spellId == moonclothId then return moonclothItemId end
    if spellId == dreamOfAzsharaId or 
    spellId == dreamOfSkywallId or 
    spellId == dreamOfRagnarosId or 
    spellId == dreamOfDeepholmId or 
    spellId == dreamOfHyjalId then return dreamClothItemId end
    
    if spellId == titanSteelId then return titanStellItemId end
    if spellId == voidSphereId then return voidSphereItemId end
    if spellId == saltShakerItemId then return saltShakerItemId end
end
