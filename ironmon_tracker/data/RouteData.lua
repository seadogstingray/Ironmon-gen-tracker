RouteData = {}

-- key: mapId (mapLayoutId)
-- value: name = ('string'),
--        encounterArea = ('table')
RouteData.Info = {}

RouteData.AvailableRoutes = {}

RouteData.EncounterArea = {
	LAND = "Walking", -- Max 12 possible
	SURFING = "Surfing", -- Max 5 possible
	UNDERWATER = "Underwater", -- Max 5 possible(?)
	STATIC = "Static",
	ROCKSMASH = "RockSmash", -- Max 5 possible
	SUPERROD = "Super Rod", -- Max 10 possible between all rods
	GOODROD = "Good Rod",
	OLDROD = "Old Rod",
	TRAINER = "Trainer", -- Eventually want to show trainer info/teams per area
}

RouteData.OrderedEncounters = {
	RouteData.EncounterArea.LAND,
	RouteData.EncounterArea.SURFING,
	RouteData.EncounterArea.UNDERWATER,
	RouteData.EncounterArea.STATIC,
	RouteData.EncounterArea.ROCKSMASH,
	RouteData.EncounterArea.SUPERROD,
	RouteData.EncounterArea.GOODROD,
	RouteData.EncounterArea.OLDROD,
	RouteData.EncounterArea.TRAINER,
}

-- Used for looking up the gen3 pokedex number (index) based on the Pokemon's national dex number
RouteData.NatDexToIndex = {
	[252] = 277, [253] = 278, [254] = 279, [255] = 280, [256] = 281, [257] = 282, [258] = 283, [259] = 284,
	[260] = 285, [261] = 286, [262] = 287, [263] = 288, [264] = 289, [265] = 290, [266] = 291, [267] = 292, [268] = 293, [269] = 294,
	[270] = 295, [271] = 296, [272] = 297, [273] = 298, [274] = 299, [275] = 300, [276] = 304, [277] = 305, [278] = 309, [279] = 310,
	[280] = 392, [281] = 393, [282] = 394, [283] = 311, [284] = 312, [285] = 306, [286] = 307, [287] = 364, [288] = 365, [289] = 366,
	[290] = 301, [291] = 302, [292] = 303, [293] = 370, [294] = 371, [295] = 372, [296] = 335, [297] = 336, [298] = 350, [299] = 320,
	[300] = 315, [301] = 316, [302] = 322, [303] = 355, [304] = 382, [305] = 383, [306] = 384, [307] = 356, [308] = 357, [309] = 337,
	[310] = 338, [311] = 353, [312] = 354, [313] = 386, [314] = 387, [315] = 363, [316] = 367, [317] = 368, [318] = 330, [319] = 331,
	[320] = 313, [321] = 314, [322] = 339, [323] = 340, [324] = 321, [325] = 351, [326] = 352, [327] = 308, [328] = 332, [329] = 333,
	[330] = 334, [331] = 344, [332] = 345, [333] = 358, [334] = 359, [335] = 380, [336] = 379, [337] = 348, [338] = 349, [339] = 323,
	[340] = 324, [341] = 326, [342] = 327, [343] = 318, [344] = 319, [345] = 388, [346] = 389, [347] = 390, [348] = 391, [349] = 328,
	[350] = 329, [351] = 385, [352] = 317, [353] = 377, [354] = 378, [355] = 361, [356] = 362, [357] = 369, [358] = 411, [359] = 376,
	[360] = 360, [361] = 346, [362] = 347, [363] = 341, [364] = 342, [365] = 343, [366] = 373, [367] = 374, [368] = 375, [369] = 381,
	[370] = 325, [371] = 395, [372] = 396, [373] = 397, [374] = 398, [375] = 399, [376] = 400, [377] = 401, [378] = 402, [379] = 403,
	[380] = 407, [381] = 408, [382] = 404, [383] = 405, [384] = 406, [385] = 409, [386] = 410,
}

-- Maps the rodId from 'gSpecialVar_ItemId' to encounterArea
RouteData.Rods = {
	[262] = RouteData.EncounterArea.OLDROD,
	[263] = RouteData.EncounterArea.GOODROD,
	[264] = RouteData.EncounterArea.SUPERROD,
}

-- Allows the Tracker to verify if data can be updated based on the location of the player
RouteData.Locations = {
	CanPCHeal = {},
	CanObtainBadge = {}, -- Currently unused for the time being
	IsInLab = {},
	IsInHallOfFame = {},
}

function RouteData.initialize()
	local maxMapId = 0
	RouteData.setupRouteInfoAsGSC()

	RouteData.populateAvailableRoutes(maxMapId)

	-- At some point we might want to implement this so that wild encounter data is automatic
	-- RouteData.readWildPokemonInfoFromMemory()
end

function RouteData.populateAvailableRoutes(maxMapId)
	maxMapId = maxMapId or 0
	RouteData.AvailableRoutes = {}

	if maxMapId <= 0 then return end

	-- Iterate based on mapId order so the list is somewhat organized
	for mapId=1, maxMapId, 1 do
		local route = RouteData.Info[mapId]
		if route ~= nil and route.name ~= nil then
			for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
				if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
					table.insert(RouteData.AvailableRoutes, route.name)
					break
				end
			end
		end
	end
end

function RouteData.hasRoute(mapId)
	return mapId ~= nil and RouteData.Info[mapId] ~= nil and RouteData.Info[mapId] ~= {}
end

function RouteData.hasRouteEncounterArea(mapId, encounterArea)
	if encounterArea == nil or not RouteData.hasRoute(mapId) then return false end

	return RouteData.Info[mapId][encounterArea] ~= nil and RouteData.Info[mapId][encounterArea] ~= {}
end

function RouteData.verifyPID(pokemonID)
	-- Convert from national dex to gen3 dex (applies to ids > 251)
	if RouteData.NatDexToIndex[pokemonID] ~= nil then
		return RouteData.NatDexToIndex[pokemonID]
	else
		return pokemonID
	end
end

function RouteData.countPokemonInArea(mapId, encounterArea)
	local areaInfo = RouteData.getEncounterAreaPokemon(mapId, encounterArea)
	return #areaInfo
end

function RouteData.isFishingEncounter(encounterArea)
	return encounterArea == RouteData.EncounterArea.OLDROD or encounterArea == RouteData.EncounterArea.GOODROD or encounterArea == RouteData.EncounterArea.SUPERROD
end

function RouteData.getEncounterAreaByTerrain(terrainId, battleFlags)
	if terrainId < 0 or terrainId > 19 then return nil end
	battleFlags = battleFlags or 4
	local isSafariEncounter = Utils.getbits(battleFlags, 7, 1) == 1

	-- Check if a special type of encounter has occurred, see list below
	if battleFlags > 4 and not isSafariEncounter then -- 4 (0b100) is the default base value
		local isFirstEncounter = Utils.getbits(battleFlags, 4, 1) == 1

		local staticFlags = Utils.bit_rshift(battleFlags, 10) -- untested but probably accurate, likely separate later
		Main.DisplayError("Not Here")
		if Utils.getbits(battleFlags, 3, 1) == 1 then
			return RouteData.EncounterArea.TRAINER
		elseif isFirstEncounter and GameSettings.versiongroup == 1 then -- RSE first battle only
			return RouteData.EncounterArea.STATIC
		elseif staticFlags > 0 then
			return RouteData.EncounterArea.STATIC
		else
			return RouteData.EncounterArea.LAND
		end
	else
		if terrainId == 3 then
			return RouteData.EncounterArea.UNDERWATER
		elseif terrainId == 4 or terrainId == 5 then -- Water, Pond
			return RouteData.EncounterArea.SURFING
		else
			return RouteData.EncounterArea.LAND
		end
	end

	-- Terrain Data, saving here to use later for RSE games and maybe boss trainers
	-- BATTLE_TERRAIN_GRASS        0 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_LONG_GRASS   1 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_SAND         2 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_UNDERWATER   3 -- RouteData.EncounterArea.UNDERWATER
	-- BATTLE_TERRAIN_WATER        4 -- RouteData.EncounterArea.SURFING
	-- BATTLE_TERRAIN_POND         5 -- RouteData.EncounterArea.SURFING
	-- BATTLE_TERRAIN_MOUNTAIN     6 -- RouteData.EncounterArea.LAND ???
	-- BATTLE_TERRAIN_CAVE         7 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_BUILDING     8 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_PLAIN        9 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_LINK        10
	-- BATTLE_TERRAIN_GYM         11 -- returns 8 in Koga's gym
	-- BATTLE_TERRAIN_LEADER      12
	-- BATTLE_TERRAIN_INDOOR_2    13
	-- BATTLE_TERRAIN_INDOOR_1    14
	-- BATTLE_TERRAIN_LORELEI     15
	-- BATTLE_TERRAIN_BRUNO       16
	-- BATTLE_TERRAIN_AGATHA      17
	-- BATTLE_TERRAIN_LANCE       18
	-- BATTLE_TERRAIN_CHAMPION    19

	-- Battle Flags
	-- https://github.com/pret/pokefirered/blob/49ea462d7f421e75a76b25d7e85c92494c0a9798/include/constants/battle.h
	-- BATTLE_TYPE_DOUBLE             (1 << 0)
	-- BATTLE_TYPE_LINK               (1 << 1)
	-- BATTLE_TYPE_IS_MASTER          (1 << 2) // In not-link battles, it's always set.
	-- BATTLE_TYPE_TRAINER            (1 << 3)
	-- BATTLE_TYPE_FIRST_BATTLE       (1 << 4)
	-- BATTLE_TYPE_LINK_IN_BATTLE     (1 << 5) // Set on battle entry, cleared on exit. Checked rarely
	-- BATTLE_TYPE_MULTI              (1 << 6)
	-- BATTLE_TYPE_SAFARI             (1 << 7)
	-- BATTLE_TYPE_BATTLE_TOWER       (1 << 8)
	-- BATTLE_TYPE_OLD_MAN_TUTORIAL   (1 << 9) // Used in pokeemerald as BATTLE_TYPE_WALLY_TUTORIAL.
	-- BATTLE_TYPE_ROAMER             (1 << 10)
	-- BATTLE_TYPE_EREADER_TRAINER    (1 << 11)
	-- BATTLE_TYPE_KYOGRE_GROUDON     (1 << 12)
	-- BATTLE_TYPE_LEGENDARY          (1 << 13)
	-- BATTLE_TYPE_GHOST_UNVEILED     (1 << 13) // Re-use of BATTLE_TYPE_LEGENDARY, when combined with BATTLE_TYPE_GHOST
	-- BATTLE_TYPE_REGI               (1 << 14)
	-- BATTLE_TYPE_GHOST              (1 << 15) // Used in pokeemerald as BATTLE_TYPE_TWO_OPPONENTS.
	-- BATTLE_TYPE_POKEDUDE           (1 << 16) // Used in pokeemerald as BATTLE_TYPE_DOME.
	-- BATTLE_TYPE_WILD_SCRIPTED      (1 << 17) // Used in pokeemerald as BATTLE_TYPE_PALACE.
	-- BATTLE_TYPE_LEGENDARY_FRLG     (1 << 18) // Used in pokeemerald as BATTLE_TYPE_ARENA.
	-- BATTLE_TYPE_TRAINER_TOWER      (1 << 19) // Used in pokeemerald as BATTLE_TYPE_FACTORY.
end

function RouteData.getNextAvailableEncounterArea(mapId, encounterArea)
	if not RouteData.hasRoute(mapId) then return nil end

	local startingIndex = 0
	for index, area in ipairs(RouteData.OrderedEncounters) do
		if encounterArea == area then
			startingIndex = index
			break
		end
	end

	local numEncounters = #RouteData.OrderedEncounters
	local nextIndex = (startingIndex % numEncounters) + 1
	while startingIndex ~= nextIndex do
		encounterArea = RouteData.OrderedEncounters[nextIndex]
		if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
			break
		end
		nextIndex = (nextIndex % numEncounters) + 1
	end

	return encounterArea
end

function RouteData.getPreviousAvailableEncounterArea(mapId, encounterArea)
	if not RouteData.hasRoute(mapId) then return nil end

	local startingIndex = 0
	for index, area in ipairs(RouteData.OrderedEncounters) do
		if encounterArea == area then
			startingIndex = index
			break
		end
	end

	local numEncounters = #RouteData.OrderedEncounters
	-- This fancy formula is due to indices starting at 1, thanks lua
	local previousIndex = ((startingIndex - 2 + numEncounters) % numEncounters) + 1
	while startingIndex ~= previousIndex do
		encounterArea = RouteData.OrderedEncounters[previousIndex]
		if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
			break
		end
		previousIndex = ((previousIndex - 2 + numEncounters) % numEncounters) + 1
	end

	return encounterArea
end

-- Returns a table of all pokemon info in an area, where pokemonID is the key, and encounter rate/levels are the values
function RouteData.getEncounterAreaPokemon(mapId, encounterArea)
	if not RouteData.hasRouteEncounterArea(mapId, encounterArea) then return {} end

	local pIndex = RouteData.getIndexForGameVersion()
	local areaInfo = {}
	-- Eventually fix this by more clearly separating a route's name from its encounters. eg. (encounters.wild)
	---@diagnostic disable-next-line: param-type-mismatch
	for _, encounter in pairs(RouteData.Info[mapId][encounterArea]) do
		local pokemonID
		if type(encounter.pokemonID) == "number" then
			pokemonID = encounter.pokemonID
		else -- pokemonID = {ID, ID, ID}
			pokemonID = encounter.pokemonID[pIndex]
		end
		pokemonID = RouteData.verifyPID(pokemonID)

		local rate
		if type(encounter.rate) == "number" then
			rate = encounter.rate
		else -- rate = {val, val, val}
			rate = encounter.rate[pIndex]
		end

		-- Some version have fewer Pokemon than others; if so, the ID will be -1
		if PokemonData.isValid(pokemonID) then
			table.insert(areaInfo, {
				pokemonID = pokemonID,
				rate = rate or 0,
				minLv = encounter.minLv or 0,
				maxLv = encounter.maxLv or 0,
			})
		end
	end
	return areaInfo
end

-- Different game versions have different Pokemon appear in an encounterArea: pokemonID = {ID, ID, ID}
function RouteData.getIndexForGameVersion()
	if GameSettings.versioncolor == "LeafGreen" or GameSettings.versioncolor == "Sapphire" then
		return 2
	elseif GameSettings.versioncolor == "Emerald" then
		return 3
	else
		return 1
	end
end

-- Currently unused, as it only pulls randomized data and not vanilla pokemon data
function RouteData.readWildPokemonInfoFromMemory()
	GameSettings.gWildMonHeaders = 0x083c9d28 -- size:00000a64

	local landCount = 12
	local waterCount = 5
	local rockCount = 5
	local fishCount = 10
	local monInfoSize = 5
	local headerInfoSize = 2 + landCount * monInfoSize + waterCount * monInfoSize + rockCount * monInfoSize + fishCount * monInfoSize
	local numHeaders = 5

	local mapNone = 0x7F7F
	local mapUndefined = 0xFFFF
	local landOffset = 0x02
	local waterOffset = landOffset + landCount * monInfoSize
	local rockOffset = waterOffset + waterCount * monInfoSize
	local fishOffset = rockOffset + rockCount * monInfoSize

	-- struct WildPokemonHeader
	-- {
	-- 	u8 mapGroup;
	-- 	u8 mapNum;
	-- 	const struct WildPokemonInfo *landMonsInfo;
	-- 	const struct WildPokemonInfo *waterMonsInfo;
	-- 	const struct WildPokemonInfo *rockSmashMonsInfo;
	-- 	const struct WildPokemonInfo *fishingMonsInfo;
	-- };

	-- struct WildPokemonInfo
	-- {
	-- 	u8 encounterRate;
	-- 	const struct WildPokemon[] {u8 minLevel, u8 maxLevel, u16 species};
	-- };

	local headerInfo = {}
	for headerIndex = 1, numHeaders, 1 do
		local headerStart = GameSettings.gWildMonHeaders + (headerIndex - 1) * headerInfoSize
		local landStart = headerStart + landOffset
		local waterStart = headerStart + waterOffset
		local rockStart = headerStart + rockOffset
		local fishStart = headerStart + fishOffset

		headerInfo[headerIndex] = {
			mapGroup = Memory.readbyte(headerStart + 0x00),
			mapNum = Memory.readbyte(headerStart + 0x01),
		}

		-- print(headerInfo[headerIndex])

		headerInfo[headerIndex].landMonsInfo = {}
		for monIndex = 1, landCount, 1 do
			local monInfoAddress = landStart + (monIndex - 1) * monInfoSize
			headerInfo[headerIndex].landMonsInfo[monIndex] = {
				pokemonID = Memory.readword(monInfoAddress + 0x3),
				rate = Memory.readbyte(monInfoAddress),
				minLv = Memory.readbyte(monInfoAddress + 0x1),
				maxLv = Memory.readbyte(monInfoAddress + 0x2),
			}
			-- print(headerInfo[headerIndex].landMonsInfo[monIndex])
		end

		headerInfo[headerIndex].waterMonsInfo = {}

		headerInfo[headerIndex].rockMonsInfo = {}

		headerInfo[headerIndex].fishMonsInfo = {}

		-- local headerBytes = {}
		-- print("----- HEADER " .. headerIndex .. " -----")
		-- for i=1, headerInfoSize, 1 do
		-- 	local byte = Memory.readbyte(headerStart + i - 1)
		-- 	headerBytes[i] = byte
		-- end
		-- print(headerBytes)
	end
end

RouteData.BlankRoute = {
	id = 0,
	name = Constants.BLANKLINE,
}


function RouteData.setupRouteInfoAsGSC()
	RouteData.Info = {}

RouteData.Info[1] = { name = "New Bark Town" }
RouteData.Info[2] = { name = "Route 29" }
RouteData.Info[3] = { name = "Cherrygrove City" }
RouteData.Info[4] = { name = "Route 30" }
RouteData.Info[5] = { name = "Route 31" }
RouteData.Info[6] = { name = "Violet City" }
RouteData.Info[7] = { name = "Sprout Tower" }
RouteData.Info[8] = { name = "Route 32" }
RouteData.Info[9] = { name = "Ruins of Alph" }
RouteData.Info[10] = { name = "Union Cave" }
RouteData.Info[11] = { name = "Route 33" }
RouteData.Info[12] = { name = "Azalea Town" }
RouteData.Info[13] = { name = "Slowpoke Well" }
RouteData.Info[14] = { name = "Ilex Forest" }
RouteData.Info[15] = { name = "Route 34" }
RouteData.Info[16] = { name = "Goldenrod City" }
RouteData.Info[17] = { name = "Goldenrod Radio Tower" }
RouteData.Info[18] = { name = "Route 35" }
RouteData.Info[19] = { name = "National Park" }
RouteData.Info[20] = { name = "Route 36" }
RouteData.Info[21] = { name = "Route 37" }
RouteData.Info[22] = { name = "Ecruteak City" }
RouteData.Info[23] = { name = "Bell Tower|Tin Tower" }
RouteData.Info[24] = { name = "Burned Tower" }
RouteData.Info[25] = { name = "Route 38" }
RouteData.Info[26] = { name = "Route 39" }
RouteData.Info[27] = { name = "Olivine City" }
RouteData.Info[28] = { name = "Lighthouse" }
RouteData.Info[29] = { name = "Battle Tower" }
RouteData.Info[30] = { name = "Route 40" }
RouteData.Info[31] = { name = "Whirl Islands" }
RouteData.Info[32] = { name = "Route 41" }
RouteData.Info[33] = { name = "Cianwood City" }
RouteData.Info[34] = { name = "Route 42" }
RouteData.Info[35] = { name = "Mt. Mortar" }
RouteData.Info[36] = { name = "Mahogany Town" }
RouteData.Info[37] = { name = "Route 43" }
RouteData.Info[38] = { name = "Lake of Rage" }
RouteData.Info[39] = { name = "Route 44" }
RouteData.Info[40] = { name = "Ice Path" }
RouteData.Info[41] = { name = "Blackthorn City" }
RouteData.Info[42] = { name = "Dragon's Den" }
RouteData.Info[43] = { name = "Route 45" }
RouteData.Info[44] = { name = "Dark Cave" }
RouteData.Info[45] = { name = "Route 46" }
RouteData.Info[46] = { name = "Mt. Silver" }
RouteData.Info[47] = { name = "Pallet Town" }
RouteData.Info[48] = { name = "Route 1" }
RouteData.Info[49] = { name = "Viridian City" }
RouteData.Info[50] = { name = "Route 2" }
RouteData.Info[51] = { name = "Pewter City" }
RouteData.Info[52] = { name = "Route 3" }
RouteData.Info[53] = { name = "Mt. Moon" }
RouteData.Info[54] = { name = "Route 4" }
RouteData.Info[55] = { name = "Cerulean City" }
RouteData.Info[56] = { name = "Route 24" }
RouteData.Info[57] = { name = "Route 25" }
RouteData.Info[58] = { name = "Route 5" }
RouteData.Info[59] = { name = "Underground Path" }
RouteData.Info[60] = { name = "Route 6" }
RouteData.Info[61] = { name = "Vermilion City" }
RouteData.Info[62] = { name = "Diglett's Cave" }
RouteData.Info[63] = { name = "Route 7" }
RouteData.Info[64] = { name = "Route 8" }
RouteData.Info[65] = { name = "Route 9" }
RouteData.Info[66] = { name = "Rock Tunnel" }
RouteData.Info[67] = { name = "Route 10" }
RouteData.Info[68] = { name = "Kanto Power Plant" }
RouteData.Info[69] = { name = "Lavender Town" }
RouteData.Info[70] = { name = "Lav Radio Tower" }
RouteData.Info[71] = { name = "Celadon City" }
RouteData.Info[72] = { name = "Saffron City" }
RouteData.Info[73] = { name = "Route 11" }
RouteData.Info[74] = { name = "Route 12" }
RouteData.Info[75] = { name = "Route 13" }
RouteData.Info[76] = { name = "Route 14" }
RouteData.Info[77] = { name = "Route 15" }
RouteData.Info[78] = { name = "Route 16" }
RouteData.Info[79] = { name = "Route 17" }
RouteData.Info[80] = { name = "Route 18" }
RouteData.Info[81] = { name = "Fuchsia City" }
RouteData.Info[82] = { name = "Route 19" }
RouteData.Info[83] = { name = "Route 20" }
RouteData.Info[84] = { name = "Seafoam Islands" }
RouteData.Info[85] = { name = "Cinnabar Island" }
RouteData.Info[86] = { name = "Route 21" }
RouteData.Info[87] = { name = "Route 22" }
RouteData.Info[88] = { name = "Victory Road" }
RouteData.Info[89] = { name = "Route 23" }
RouteData.Info[90] = { name = "Indigo Plateau" }
RouteData.Info[91] = { name = "Route 26" }
RouteData.Info[92] = { name = "Route 27" }
RouteData.Info[93] = { name = "Tohjo Falls" }
RouteData.Info[94] = { name = "Route 28" }
RouteData.Info[95] = { name = "S.S. Aqua" }

end

-- https://github.com/pret/pokeemerald/blob/677b4fc394516deab5b5c86c94a2a1443cb52151/include/constants/layouts.h
-- https://www.serebii.net/pokearth/hoenn/3rd/route101.shtml
function RouteData.setupRouteInfoAsRSE()
	-- Ruby/Sapphire has LAYOUT_LILYCOVE_CITY_EMPTY_MAP 108, offset all "mapId > 107" by +1
	local isGameEmerald = (GameSettings.versioncolor == "Emerald")
	local offset = Utils.inlineIf(isGameEmerald, 0, 1)

	RouteData.Locations.CanPCHeal = {
		[54] = true, -- Brendan's house
		[56] = true, -- May's house
		[61] = true, -- Most Pokemon Centers
		[71] = true, -- Lavaridge Town
		[270 + offset] = true, -- Pokemon League
	}
	RouteData.Locations.CanObtainBadge = {
		[65] = true,
		[69] = true,
		[70] = true,
		[79] = true,
		[89] = true,
		[94] = true,
		[100] = true,
		[108] = true,
		[109] = true,
		[110] = true,
	}
	RouteData.Locations.IsInLab = {
		[17] = true, -- Route 101
	}
	if not isGameEmerald then
		-- Ironmon ends after Steven battle, not e4. This is handled by Battle.endCurrentBattle()
		RouteData.Locations.IsInHallOfFame = {
			[298 + offset] = true,
		}
	end

	RouteData.Info = {}

	RouteData.Info[1] = { name = "Petalburg City"}
	RouteData.Info[2] = { name = "Slateport City" }
	RouteData.Info[3] = { name = "Mauville City", }
	RouteData.Info[4] = { name = "Rustboro City", }
	RouteData.Info[5] = { name = "Fortree City", }
	RouteData.Info[6] = { name = "Lilycove City"}
	RouteData.Info[7] = { name = "Mossdeep City"}
	RouteData.Info[8] = { name = "Sootopolis City"}
	RouteData.Info[9] = { name = "Ever Grande City" }
	RouteData.Info[10] = { name = "Littleroot Town", }
	RouteData.Info[11] = { name = "Oldale Town", }
	RouteData.Info[12] = { name = "Dewford Town" }
	RouteData.Info[13] = { name = "Lavaridge Town", }
	RouteData.Info[14] = { name = "Fallarbor Town", }
	RouteData.Info[15] = { name = "Verdanturf City", }
	RouteData.Info[16] = { name = "Pacifidlog Town" }
	RouteData.Info[17] = { name = "Route 101" }
	RouteData.Info[18] = { name = "Route 102" }
	RouteData.Info[19] = { name = "Route 103" }
	RouteData.Info[20] = { name = "Route 104" }
	RouteData.Info[21] = { name = "Route 105"}
	RouteData.Info[22] = { name = "Route 106"}
	RouteData.Info[23] = { name = "Route 107"}
	RouteData.Info[24] = { name = "Route 108" }
	RouteData.Info[25] = { name = "Route 109" }
	RouteData.Info[26] = { name = "Route 110"}
	RouteData.Info[27] = { name = "Route 111"
	}
	RouteData.Info[28] = { name = "Route 112"
	}
	RouteData.Info[30] = { name = "Route 114"
	}
	RouteData.Info[31] = { name = "Route 115"
	}
	RouteData.Info[32] = { name = "Route 116"
	}
	RouteData.Info[33] = { name = "Route 117"
	}
	RouteData.Info[34] = { name = "Route 118"
	}
	RouteData.Info[35] = { name = "Route 119"
	}
	RouteData.Info[36] = { name = "Route 120"
	}
	RouteData.Info[37] = { name = "Route 121"
	}
	RouteData.Info[38] = { name = "Route 122"
	}
	RouteData.Info[39] = { name = "Route 123"
	}
	RouteData.Info[40] = { name = "Route 124"
	}
	RouteData.Info[41] = { name = "Route 125"
	}
	RouteData.Info[42] = { name = "Route 126"
	}
	RouteData.Info[51] = { name = "Route 126 Water"
	}
	RouteData.Info[43] = { name = "Route 127"
	}
	RouteData.Info[52] = { name = "Route 127 Water"
	}
	RouteData.Info[44] = { name = "Route 128",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 320, rate = 0.20, },
			{ pokemonID = 370, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, },
			{ pokemonID = 370, rate = 0.40, },
			{ pokemonID = 222, rate = 0.15, },
		},
	}
	RouteData.Info[53] = { name = "Route 128 Water",
		[RouteData.EncounterArea.UNDERWATER] = {
			{ pokemonID = 366, rate = 0.65, },
			{ pokemonID = 170, rate = 0.30, },
			{ pokemonID = 369, rate = 0.05, },
		},
	}
	RouteData.Info[45] = { name = "Route 129",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.04, },
			{ pokemonID = 321, rate = 0.01, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[46] = { name = "Route 130", -- Mirage Island?
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 360, rate = 1.00, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[47] = { name = "Route 131",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[48] = { name = "Route 132",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, },
			{ pokemonID = 319, rate = 0.40, },
			{ pokemonID = 116, rate = 0.15, },
		},
	}
	RouteData.Info[49] = { name = "Route 133",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, },
			{ pokemonID = 319, rate = 0.40, },
			{ pokemonID = 116, rate = 0.15, },
		},
	}
	RouteData.Info[50] = { name = "Route 134",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, },
			{ pokemonID = 319, rate = 0.40, },
			{ pokemonID = 116, rate = 0.15, },
		},
	}

	RouteData.Info[54] = { name = "Brendan's House 1F", }
	RouteData.Info[55] = { name = "Brendan's House 2F", }
	RouteData.Info[56] = { name = "May's House 1F", }
	RouteData.Info[57] = { name = "May's House 2F", }
	RouteData.Info[58] = { name = "Prof. Birch's Lab", }
	RouteData.Info[61] = { name = Constants.Words.POKEMON .. " Center", }
	RouteData.Info[62] = { name = Constants.Words.POKEMON .. " Center 2F", }
	RouteData.Info[63] = { name = Constants.Words.POKE .. "Mart", }
	RouteData.Info[65] = { name = "Dewford Gym", }
	RouteData.Info[69] = { name = "Lavaridge Gym 1F", }
	RouteData.Info[70] = { name = "Lavaridge Gym B1F", }
	RouteData.Info[71] = { name = "Lavaridge Town PC", }
	RouteData.Info[79] = { name = "Petalburg Gym", }
	RouteData.Info[89] = { name = "Mauville Gym", }
	RouteData.Info[94] = { name = "Rustboro Gym", }
	RouteData.Info[100] = { name = "Fortree Gym", }
	RouteData.Info[108] = { name = "Mossdeep Gym", }
	RouteData.Info[109] = { name = "Sootopolis Gym 1F", }
	RouteData.Info[110] = { name = "Sootopolis Gym B1F", }
	RouteData.Info[111] = { name = "Sidney's Room", }
	RouteData.Info[112] = { name = "Phoebe's Room", }
	RouteData.Info[113] = { name = "Glacia's Room", }
	RouteData.Info[114] = { name = "Drake's Room", }
	RouteData.Info[115] = { name = "Champion's Room", }
	RouteData.Info[125 + offset] = { name = "Meteor Falls 1Fa",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.80, },
			{ pokemonID = {338,337,338}, rate = 0.20, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, },
			{ pokemonID = {338,337,338}, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 1.00, },
		},
	}
	RouteData.Info[126 + offset] = { name = "Meteor Falls 1Fb",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.65, },
			{ pokemonID = {338,337,338}, rate = 0.35, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, },
			{ pokemonID = {338,337,338}, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, },
			{ pokemonID = 340, rate = 0.20, },
		},
	}
	RouteData.Info[127 + offset] = { name = "Meteor Falls 2Fa",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.65, },
			{ pokemonID = {338,337,338}, rate = 0.35, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, },
			{ pokemonID = {338,337,338}, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, },
			{ pokemonID = 340, rate = 0.20, },
		},
	}
	RouteData.Info[128 + offset] = { name = "Meteor Falls 2Fb",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.50, },
			{ pokemonID = {338,337,338}, rate = 0.25, },
			{ pokemonID = 371, rate = 0.25, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, },
			{ pokemonID = {338,337,338}, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, },
			{ pokemonID = 340, rate = 0.20, },
		},
	}
	if isGameEmerald then
		RouteData.Info[431] = { name = "Meteor Falls 2Fc",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 42, rate = 0.50, },
				{ pokemonID = {338,337,338}, rate = 0.25, },
				{ pokemonID = 371, rate = 0.25, },
			},
		}
	end
	RouteData.Info[129 + offset] = { name = "Rusturf Tunnel",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 293, rate = 1.00, },
		},
	}

	RouteData.Info[132 + offset] = { name = "Granite Cave 1Fa",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 296, rate = 0.50, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = 63, rate = 0.10, },
			{ pokemonID = 41, rate = 0.10, },
		},
	}
	RouteData.Info[133 + offset] = { name = "Granite Cave B1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 304, rate = 0.40, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = 63, rate = 0.10, },
			{ pokemonID = 296, rate = 0.10, },
			{ pokemonID = {303,302,302}, rate = 0.10, },
		},
	}
	RouteData.Info[134 + offset] = { name = "Granite Cave B2F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 304, rate = 0.40, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.20, },
			{ pokemonID = 296, rate = 0.10, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 0.70, },
			{ pokemonID = 299, rate = 0.30, },
		},
	}
	RouteData.Info[288 + offset] = { name = "Granite Cave 1Fb",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 296, rate = 0.50, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = 63, rate = 0.10, },
			{ pokemonID = 304, rate = 0.10, },
		},
	}
	RouteData.Info[135 + offset] = { name = "Petalburg Woods",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,261}, rate = 0.30, },
			{ pokemonID = 265, rate = 0.25, },
			{ pokemonID = 285, rate = 0.15, },
			{ pokemonID = 266, rate = 0.10, },
			{ pokemonID = 268, rate = 0.10, },
			{ pokemonID = 276, rate = 0.05, },
			{ pokemonID = 287, rate = 0.05, },
		},
	}
	RouteData.Info[136 + offset] = { name = "Mt. Chimney", }
	RouteData.Info[137 + offset] = { name = "Mt. Pyre 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 1.00, },
		},
	}
	RouteData.Info[138 + offset] = { name = "Mt. Pyre 2F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 1.00, },
		},
	}
	RouteData.Info[139 + offset] = { name = "Mt. Pyre 3F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 1.00, },
		},
	}
	RouteData.Info[140 + offset] = { name = "Mt. Pyre 4F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.90, },
			{ pokemonID = {353,355,355}, rate = 0.10, },
		},
	}
	RouteData.Info[141 + offset] = { name = "Mt. Pyre 5F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.90, },
			{ pokemonID = {353,355,355}, rate = 0.10, },
		},
	}
	RouteData.Info[142 + offset] = { name = "Mt. Pyre 6F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.90, },
			{ pokemonID = {353,355,355}, rate = 0.10, },
		},
	}
	RouteData.Info[143 + offset] = { name = "Aqua Hideout 1F", }
	RouteData.Info[144 + offset] = { name = "Aqua Hideout B1F", }
	RouteData.Info[145 + offset] = { name = "Aqua Hideout B2F", }

	RouteData.Info[147 + offset] = { name = "Seafloor Cavern",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, },
			{ pokemonID = 42, rate = 0.10, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 41, rate = 0.35, },
			{ pokemonID = 42, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[148 + offset] = { name = "Seafloor Cavern 1", }
	RouteData.Info[149 + offset] = { name = "Seafloor Cavern 2", }
	RouteData.Info[150 + offset] = { name = "Seafloor Cavern 3", }
	RouteData.Info[151 + offset] = { name = "Seafloor Cavern 4", }
	RouteData.Info[152 + offset] = { name = "Seafloor Cavern 5", }
	RouteData.Info[153 + offset] = { name = "Seafloor Cavern 6",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 41, rate = 0.35, },
			{ pokemonID = 42, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[154 + offset] = { name = "Seafloor Cavern 7",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 41, rate = 0.35, },
			{ pokemonID = 42, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[155 + offset] = { name = "Seafloor Cavern 8", }
	RouteData.Info[156 + offset] = { name = "Seafloor Cavern 9", }

	RouteData.Info[157 + offset] = { name = "Cave of Origin",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, },
			{ pokemonID = 42, rate = 0.10, },
		},
	}
	RouteData.Info[158 + offset] = { name = "Cave of Origin 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.60, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 42, rate = 0.10, },
		},
	}

	if isGameEmerald then
		RouteData.Info[162] = { name = "Cave of Origin B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {-1,-1,302}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
	else
		RouteData.Info[160] = { name = "Cave of Origin B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
		RouteData.Info[161] = { name = "Cave of Origin B2F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
		RouteData.Info[162] = { name = "Cave of Origin B3F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
		RouteData.Info[163] = { name = "Cave of Origin B4F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = {383,382,-1}, rate = 1.00, },
			},
		}
	end
	RouteData.Info[163 + offset] = { name = "Victory Road 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.25, },
			{ pokemonID = 297, rate = 0.25, },
			{ pokemonID = 41, rate = 0.10, },
			{ pokemonID = 294, rate = 0.10, },
			{ pokemonID = 296, rate = 0.10, },
			{ pokemonID = 305, rate = 0.10, },
			{ pokemonID = 293, rate = 0.05, },
			{ pokemonID = 304, rate = 0.05, },
		},
	}
	RouteData.Info[164 + offset] = { name = "Shoal Cave Lo-1",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[165 + offset] = { name = "Shoal Cave Lo-2",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[166 + offset] = { name = "Shoal Cave Lo-3",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[167 + offset] = { name = "Shoal Cave Lo-4",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.40, },
			{ pokemonID = 361, rate = 0.10, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[168 + offset] = { name = "Shoal Cave Hi-1",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = 363, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[169 + offset] = { name = "Shoal Cave Hi-2",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = 363, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[184 + offset] = { name = "New Mauville 1",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 81, rate = 0.50, },
			{ pokemonID = 100, rate = 0.50, },
		},
	}
	RouteData.Info[185 + offset] = { name = "New Mauville 2",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 81, rate = 0.49, },
			{ pokemonID = 100, rate = 0.49, },
			{ pokemonID = 82, rate = 0.01, },
			{ pokemonID = 101, rate = 0.01, },
		},
	}
	RouteData.Info[238 + offset] = { name = "Safari Zone NW.",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.30, },
			{ pokemonID = 111, rate = 0.30, },
			{ pokemonID = 44, rate = 0.15, },
			{ pokemonID = 84, rate = 0.15, },
			{ pokemonID = 85, rate = 0.05, },
			{ pokemonID = 127, rate = 0.05, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 54, rate = 0.95, },
			{ pokemonID = 55, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.40, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 118, rate = 0.80, },
			{ pokemonID = 119, rate = 0.20, },
		},
	}
	RouteData.Info[239 + offset] = { name = "Safari Zone NE.", -- North in Emerald decomp, as extension is to East
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.30, },
			{ pokemonID = 231, rate = 0.30, },
			{ pokemonID = 44, rate = 0.15, },
			{ pokemonID = 177, rate = 0.15, },
			{ pokemonID = 178, rate = 0.05, },
			{ pokemonID = 214, rate = 0.05, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 1.00, },
		},
	}
	RouteData.Info[240 + offset] = { name = "Safari Zone SW.",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.40, },
			{ pokemonID = 203, rate = 0.20, },
			{ pokemonID = 84, rate = 0.10, },
			{ pokemonID = 177, rate = 0.10, },
			{ pokemonID = 202, rate = 0.10, },
			{ pokemonID = 25, rate = 0.05, },
			{ pokemonID = 44, rate = 0.05, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 54, rate = 1.00, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.40, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 118, rate = 0.80, },
			{ pokemonID = 119, rate = 0.20, },
		},
	}
	RouteData.Info[241 + offset] = { name = "Safari Zone SE.", -- South in Emerald, as extension is to East
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.40, },
			{ pokemonID = 203, rate = 0.20, },
			{ pokemonID = 84, rate = 0.10, },
			{ pokemonID = 177, rate = 0.10, },
			{ pokemonID = 202, rate = 0.10, },
			{ pokemonID = 25, rate = 0.05, },
			{ pokemonID = 44, rate = 0.05, },
		},
	}

	RouteData.Info[243 + offset] = { name = "Seashore House", }
	RouteData.Info[247 + offset] = { name = "Trick House 1", }
	RouteData.Info[248 + offset] = { name = "Trick House 2", }
	RouteData.Info[249 + offset] = { name = "Trick House 3", }
	RouteData.Info[250 + offset] = { name = "Trick House 4", }
	RouteData.Info[251 + offset] = { name = "Trick House 5", }
	RouteData.Info[252 + offset] = { name = "Trick House 6", }
	RouteData.Info[253 + offset] = { name = "Trick House 7", }
	RouteData.Info[254 + offset] = { name = "Trick House 8", }
	RouteData.Info[270 + offset] = { name = Constants.Words.POKEMON .. " League PC", }
	RouteData.Info[271 + offset] = { name = "Weather Institute 1F", }
	RouteData.Info[272 + offset] = { name = "Weather Institute 2F", }
	RouteData.Info[275 + offset] = { name = "City Space Center 1F", }
	RouteData.Info[276 + offset] = { name = "City Space Center 2F", }
	RouteData.Info[285 + offset] = { name = "Victory Road B1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.35, },
			{ pokemonID = 297, rate = 0.35, },
			{ pokemonID = 305, rate = {0.15,0.15,0.25}, },
			{ pokemonID = {308,308,-1}, rate = 0.10, },
			{ pokemonID = {307,307,303}, rate = 0.05, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 0.70, },
			{ pokemonID = 75, rate = 0.30, },
		},
	}
	RouteData.Info[286 + offset] = { name = "Victory Road B2F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.35, },
			{ pokemonID = {303,302,302}, rate = 0.35, },
			{ pokemonID = 305, rate = {0.15,0.15,0.25}, },
			{ pokemonID = {308,308,303}, rate = {0.15,0.15,0.05}, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 1.00, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, },
			{ pokemonID = 340, rate = 0.20, },
		},
	}

	RouteData.Info[291 + offset] = { name = "Southern Island",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = {380,381,381}, rate = 1.00, },
		},
	}
	RouteData.Info[292 + offset] = { name = "Jagged Pass",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 322, rate = 0.55, },
			{ pokemonID = 66, rate = 0.25, },
			{ pokemonID = 325, rate = 0.20, },
		},
	}
	RouteData.Info[293 + offset] = { name = "Fiery Path",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 322, rate = 0.30, },
			{ pokemonID = {109,88,109}, rate = 0.25, },
			{ pokemonID = 324, rate = 0.18, },
			{ pokemonID = 66, rate = 0.15, },
			{ pokemonID = 218, rate = 0.10, },
			{ pokemonID = {88,109,88}, rate = 0.02, },
		},
	}

	RouteData.Info[302 + offset] = { name = "Mt. Pyre Ext.",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = {0.40,0.40,0.60}, },
			{ pokemonID = {307,307,-1}, rate = 0.30, },
			{ pokemonID = 37, rate = {0.20,0.20,0.30}, },
			{ pokemonID = 278, rate = 0.10, },
		},
	}
	RouteData.Info[303 + offset] = { name = "Mt. Pyre Summit",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.85, },
			{ pokemonID = {355,353,353}, rate = 0.13, },
			{ pokemonID = 278, rate = 0.02, },
		},
	}

	RouteData.Info[322 + offset] = { name = "Sky Pillar 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 344, rate = 0.25, },
			{ pokemonID = {356,354,354}, rate = 0.15, },
		},
	}
	RouteData.Info[324 + offset] = { name = "Sky Pillar 3F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 344, rate = 0.25, },
			{ pokemonID = {356,354,354}, rate = 0.15, },
		},
	}
	RouteData.Info[330 + offset] = { name = "Sky Pillar 5F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 344, rate = 0.19, },
			{ pokemonID = {356,354,354}, rate = 0.15, },
			{ pokemonID = 334, rate = 0.06, },
		},
	}
	RouteData.Info[331 + offset] = { name = "Sky Pillar 6F",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 384, rate = 1.00, },
		},
	}

	-- Ruby/Sapphire do not have maps beyond this point
	if not isGameEmerald then return 332 end

	RouteData.Info[336] = { name = "Magma Hideout 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[337] = { name = "Magma Hideout 2Fa",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[338] = { name = "Magma Hideout 2Fb",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[339] = { name = "Magma Hideout 3Fa",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[340] = { name = "Magma Hideout 3Fb",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[341] = { name = "Magma Hideout 4F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[345] = { name = "Battle Frontier E.",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 185, rate = 1.00, },
		},
	}
	RouteData.Info[379] = { name = "Magma Hideout 3Fc",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[380] = { name = "Magma Hideout 2Fc",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[381] = { name = "Mirage Tower 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[382] = { name = "Mirage Tower 2F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[383] = { name = "Mirage Tower 3F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[388] = { name = "Mirage Tower 4F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[389] = { name = "Desert Underpass",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 132, rate = 0.50, },
			{ pokemonID = 293, rate = 0.34, },
			{ pokemonID = 294, rate = 0.16, },
		},
	}
	-- Emerald gets two extra safari zones unlocked to the East after Hall of Fame
	RouteData.Info[394] = { name = "Safari Zone N-Ext.",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 190, rate = 0.30, },
			{ pokemonID = 216, rate = 0.30, },
			{ pokemonID = 165, rate = 0.10, },
			{ pokemonID = 191, rate = 0.10, },
			{ pokemonID = 163, rate = 0.05, },
			{ pokemonID = 204, rate = 0.05, },
			{ pokemonID = 228, rate = 0.05, },
			{ pokemonID = 241, rate = 0.05, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 213, rate = 1.00, },
		},
	}
	RouteData.Info[395] = { name = "Safari Zone S-Ext.",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 179, rate = 0.30, },
			{ pokemonID = 191, rate = 0.30, },
			{ pokemonID = 167, rate = 0.10, },
			{ pokemonID = 190, rate = 0.10, },
			{ pokemonID = 163, rate = 0.05, },
			{ pokemonID = 207, rate = 0.05, },
			{ pokemonID = 209, rate = 0.05, },
			{ pokemonID = 234, rate = 0.05, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 194, rate = 0.60, },
			{ pokemonID = 183, rate = 0.39, },
			{ pokemonID = 195, rate = 0.01, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 223, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 223, rate = 0.59, },
			{ pokemonID = 118, rate = 0.40, },
			{ pokemonID = 224, rate = 0.01, },
		},
	}
	RouteData.Info[400] = { name = "Artisan Cave B1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 235, rate = 1.00, },
		},
	}
	RouteData.Info[401] = { name = "Artisan Cave 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 235, rate = 1.00, },
		},
	}

	RouteData.Info[403] = { name = "Faraway Island",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 151, rate = 1.00, },
		},
	}
	RouteData.Info[404] = { name = "Birth Island",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 386, rate = 1.00, },
		},
	}
	RouteData.Info[409] = { name = "Terra Cave",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 383, rate = 1.00, },
		},
	}
	RouteData.Info[413] = { name = "Marine Cave", -- untested
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 382, rate = 1.00, },
		},
	}
	RouteData.Info[423] = { name = "Navel Rock Top",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 250, rate = 1.00, },
		},
	}
	RouteData.Info[424] = { name = "Navel Rock Bot",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 249, rate = 1.00, },
		},
	}

	return 424
end
