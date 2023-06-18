local lib = LibStub("CustomNames")

lib:RegisterCallback("Name_Added", function(event, name, customName)
	print("Added: " .. name .. " is now Renamed to " .. customName)
end)

lib:RegisterCallback("Name_Removed", function(event, name)
	print("Deleted: " .. name .. " is no longer Renamed")
end)

lib:RegisterCallback("Name_Update", function(event, name, customName, oldCustomName)
	print("Edited: " .. name .. " is now Renamed to " .. customName .. " (was " .. oldCustomName .. ")")
end)

local Translit = LibStub("LibTranslit-1.0")
local translitMark = "!"
local E, L, V, P, G = unpack(ElvUI)
local category = 'CustomNames'

for textFormat, length in pairs({ veryshort = 5, short = 10, medium = 15, long = 20 }) do
	-- health deficite percent
	local HealthDeficitTagName = format('health:deficit-percent:CustomName-%s', textFormat)
	E:AddTag(HealthDeficitTagName, 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE', function(unit)
		local cur, max = UnitHealth(unit), UnitHealthMax(unit)
		local deficit = max - cur

		if deficit > 0 and cur > 0 then
			return _TAGS['health:deficit-percent:nostatus'](unit)
		else
			return _TAGS[format('CustomName:%s', textFormat)](unit)
		end
	end)
	E:AddTagInfo(HealthDeficitTagName, category, format("Displays the health deficit as a percentage and the name of the unit (limited to %s letters)",length), nil, not E.Retail)
	-- name abbreviated
	local NameAbbreviatedTagName = format('CustomName:abbrev:%s', textFormat)
	E:AddTag(NameAbbreviatedTagName, 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local name = lib.UnitName(unit)
		if name and strfind(name, '%s') then
			name = E.TagFunctions.Abbrev(name)
		end

		if name then
			return E:ShortenString(name, length)
		end
	end)
	E:AddTagInfo(NameAbbreviatedTagName, category, format("Displays the name of the unit with abbreviation (limited to %s letters)",length), nil, not E.Retail)
	-- name
	local NameTagName = format('CustomName:%s', textFormat)
	E:AddTag(NameTagName, 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local name = lib.UnitName(unit)
		if name then
			return E:ShortenString(name, length)
		end
	end)
	E:AddTagInfo(NameTagName, category, format("Displays the name of the unit (limited to %s letters)",length), nil, not E.Retail)
	-- name status
	local StatusTagName = format('CustomName:%s:status', textFormat)
	E:AddTag(StatusTagName, 'UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_HEALTH INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
		local name = lib.UnitName(unit)
		if status then
			return status
		elseif name then
			return E:ShortenString(name, length)
		end
	end)
	E:AddTagInfo(StatusTagName, category, format("Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to %s letters)",length), nil, not E.Retail)
	-- name translit
	local TranslitTagName = format('CustomName:%s:translit', textFormat)
	E:AddTag(TranslitTagName , 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local name = Translit:Transliterate(lib.UnitName(unit), translitMark)
		if name then
			return E:ShortenString(name, length)
		end
	end)
	E:AddTagInfo(TranslitTagName , category, format("Displays the name of the unit with transliteration for cyrillic letters (limited to %s letters)",length), nil, not E.Retail)
	-- name target
	local TargetTagName = format('CustomNameTarget:%s', textFormat)
	E:AddTag(TargetTagName, 'UNIT_TARGET', function(unit)
		local targetName = lib.UnitName(unit..'target')
		if targetName then
			return E:ShortenString(targetName, length)
		end
	end)
	E:AddTagInfo(TargetTagName, category, format("Displays the current target of the unit (limited to %s letters)",length), nil, not E.Retail)
	-- name target translit
	local TargetTranslitTagName = format('CustomNameTarget:%s:translit', textFormat)
	E:AddTag(TargetTranslitTagName, 'UNIT_TARGET', function(unit)
		local targetName = Translit:Transliterate(lib.UnitName(unit..'target'), translitMark)
		if targetName then
			return E:ShortenString(targetName, length)
		end
	end)
	E:AddTagInfo(TargetTranslitTagName, category, format("Displays the current target of the unit with transliteration for cyrillic letters (limited to %s letters)",length), nil, not E.Retail)
end
