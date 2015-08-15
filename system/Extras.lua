local function _manualMoving()
	if FireHack then
		local a, _ = GetKeyState('65')
		local s, _ = GetKeyState('83')
		local d, _ = GetKeyState('68')
		local w, _ = GetKeyState('87') 
		if a or s or d or w then
			return true
		end
	end
	return false
end

NeP.Extras = {
	dummyStartedTime = 0,
	dummyLastPrint = 0,
	dummyTimeRemaning = 0
}

--[[-----------------------------------------------
** Automated Movements **
DESC: Moves to a unit.

Build By: MTS
---------------------------------------------------]]
function NeP.Extras.MoveTo()
	local _rangeTable = {
		["HUNTER"] = {style = "ranged", Range = 40},
		["WARLOCK"] = {style = "ranged",  Range = 40},
		["PRIEST"] = {style = "ranged",  Range = 40},
		["PALADIN"] = {style = "melee", Range = 5},
		["MAGE"] = {style = "ranged",  Range = 40},
		["ROGUE"] = {style = "melee", Range = 5},
		["DRUID"] = {style = "melee", Range = 5},
		["SHAMAN"] = {style = "ranged",  Range = 40},
		["WARRIOR"] = {style = "melee", Range = 5},
		["DEATHKNIGHT"] = {style = "melee", Range = 5},
		["MONK"] = {style = "melee", Range = 5},
	}
	local _class, _className = UnitClass('player')
	local _classRange = _rangeTable[_className]
	local unitSpeed, _ = GetUnitSpeed('player')
  	if NeP.Core.PeFetch('npconf', 'AutoMove') then
  		if UnitExists('target') then
			if UnitIsVisible('target') and not UnitChannelInfo("player") then
				if NeP.Core.LineOfSight('player', 'target') then
					if not _manualMoving() then
						if FireHack then
							local _Range = _classRange.Range + UnitCombatReach('player') + UnitCombatReach('target')
							-- Stop Moving
							if ((_classRange.style == "ranged" and NeP.Core.Distance("player", 'target') < _Range)
							or (_classRange.style == "melee" and NeP.Core.Distance("player", 'target') < _Range))
							and unitSpeed ~= 0 then 
								MoveTo(ObjectPosition('player'))
							-- Start Moving
							elseif NeP.Core.Distance("player", 'target') > _Range then
								NeP.Alert('Moving to: '..GetUnitName('target', false)) 
								MoveTo(ObjectPosition('target'))
							end
						end
					end
				end
			end
		end
	end
end

--[[-----------------------------------------------
** Automated Facing **
DESC: Checks if unit can/should be faced.

Build By: MTS
---------------------------------------------------]]
function NeP.Extras.FaceTo()
	if NeP.Core.PeFetch('npconf', 'AutoFace') then
		local unitSpeed, _ = GetUnitSpeed('player')
		if not _manualMoving() and unitSpeed == 0 then
			if UnitExists('target') then
				if UnitIsVisible('target') and not UnitChannelInfo("player")then
					if not NeP.Core.Infront('player', 'target') then
						if NeP.Core.LineOfSight('player', 'target') then
							if FireHack then
								NeP.Alert('Facing: '..GetUnitName('target', false)) 
								FaceUnit('target')
							end
						end
					end
				end
			end
		end
	end
end

--[[-----------------------------------------------
** Automated Targets **
DESC: Checks if unit can/should be targeted.

Build By: MTS & StinkyTwitch
---------------------------------------------------]]
function NeP.Extras.autoTarget(unit, name)
	if NeP.Core.PeFetch('npconf', 'AutoTarget') then
		if UnitExists("target") and not UnitIsFriend("player", "target") and not UnitIsDeadOrGhost("target") then
			-- Do nothing
		else
			for i=1,#NeP.ObjectManager.unitCache do
				local _object = NeP.ObjectManager.unitCache[i]
				if UnitExists(_object.key) then
					if (UnitAffectingCombat(_object.key) or _object.dummy) then
						if _object.distance <= 40 then
							NeP.Alert('Targeting: '.._object.name) 
							Macro("/target ".._object.key)
							break
						end
					end
				end
			end
		end
	end
end

--[[----------------------------------------------- 
    ** Utility - Milling ** 
    DESC: Automatic Draenor herbs milling 
    ToDo: Test it & add some kind of button to start instease of using a
    checkbox on the GUI.
    Oh and possivly add more stuff...

    Build By: MTS
    ---------------------------------------------------]]
local _acSpell, _acSpeNum, _acTable = nil, nil, nil
local acCraft_Run = false

function NeP.Extras.autoMilling()
	acCraft_Run = not acCraft_Run
	if acCraft_Run then
		local _Herbs = {
			-- WoD
			{ ID= 109124, Name = 'Frostweed' },
			{ ID= 109125, Name = 'Fireweed' },
			{ ID= 109126, Name = 'Gorgrond Flytrap' },
			{ ID= 109127, Name = 'Starflower' },
			{ ID= 109128, Name = 'Nagrand Arrowbloom' },
			{ ID= 109129, Name = 'Talador Orchid' }
		}
		_acSpell, _acSpeNum, _acTable = 51005, 5, _Herbs
	else
		_acSpell, _acSpeNum, _acTable = nil, nil, nil
	end
end

function NeP.Extras.autoProspect()
	acCraft_Run = not acCraft_Run
	if acCraft_Run then
		local _Ores = {
			-- MoP
			{ ID= 72092, Name = 'Ghost Iron Ore' },
		}
		_acSpell, _acSpeNum, _acTable = 31252, 5, _Ores
	else
		_acSpell, _acSpeNum, _acTable = nil, nil, nil
	end
end

function NeP.Extras.autoCraft(spell, number, _table)
	if acCraft_Run then
		local _craftID = nil
		local _craftName = nil
		local _craftRunning = false
		if IsSpellKnown(spell) then
			for i=1,#_table do
				local _item = _table[i]
				if _craftID == nil then
					if GetItemCount(_item.ID, false, false) >= number then
						_craftID = _item.ID
						_craftName = _item.Name
						_craftRunning = true
						break
					else
						NeP.Core.Print('Stoped crafting, you dont have enough mats.')
						acCraft_Run = false
						break
					end
				end
			end
		else
			NeP.Core.Print('Failed, you dont have the required spell.')
			_craftID = nil
			acCraft_Run = false
		end
		if _craftRunning then
			if GetItemCount(_craftID, false, false) >= number then
				Cast(spell) 
				UseItem(_craftID)
				NeP.Core.Print('Crafting: '.._craftName)
			else	
				NeP.Core.Print('Stoped crafting, you ran out of mats.')
				acCraft_Run = false
			end
		end
	end
end

--[[----------------------------------------------- 
    ** Savage ** 
    DESC: Savge Items

    Build By: SVS
    ---------------------------------------------------]]
function NeP.Extras.OpenSalvage()
	if NeP.Core.PeFetch('npconf', 'OpenSalvage') then
		-- Bag of Salvaged Goods
		if GetItemCount(114116, false, false) > 0 then
			UseItem(114116)
		-- Crate of Salvage
		elseif GetItemCount(114119, false, false) > 0 then
			UseItem(114119)
		-- Big Crate of Salvage
		elseif GetItemCount(114120, false, false) > 0 then
			UseItem(114120)
		end
	end
end

function NeP.Extras.AutoBait()
	if NeP.Core.PeFetch('npconf', 'bait') ~= "none" then
		local _baitsTable = {
			{ ID= 110274, Debuff = 158031, Name = 'Jawless Skulker Bait', Key = 'jsb' },
			{ ID= 110289, Debuff = 158034, Name = 'Fat Sleeper Bait', Key = 'fsb' },
			{ ID= 110290, Debuff = 158035, Name = 'Blind Lake Sturgeon Bait', Key = 'blsb' },
			{ ID= 110291, Debuff = 158036, Name = 'Fire Ammonite Bait', Key = 'fab' },
			{ ID= 110292, Debuff = 158037, Name = 'Sea Scorpion Bait', Key = 'ssb' },
			{ ID= 110293, Debuff = 158038, Name = 'Abyssal Gulper Eel Bait', Key = 'ageb' },
			{ ID= 110294, Debuff = 158039, Name = 'Blackwater Whiptail Bait', Key = 'bwb' }
		}
		for i=1,#_baitsTable do
			local _Bait = _baitsTable[i]
			if NeP.Core.PeFetch('npconf', 'bait') == _Bait.Key then
				if GetItemCount(_Bait.ID, false, false) > 0 and not UnitBuff("player", GetSpellInfo(_Bait.Debuff)) then
					UseItem(_Bait.ID)
				end
			end
		end
	end
end
 
local function CarpDestruction()
	if NeP.Core.PeFetch('npconf', 'LunarfallCarp') 
		deleteItem(116158, 0)
	end
end

local function _BagSpace()
	local freeslots = 0
	for lbag = 0, NUM_BAG_SLOTS do
		numFreeSlots, BagType = GetContainerNumFreeSlots(lbag)
		freeslots = freeslots + numFreeSlots
	end
	return freeslots
end

local function deleteItem(ID, number)
	if GetItemCount(ID, false, false) > number then
		for bag = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bag) do
				currentItemID = GetContainerItemID(bag, slot)
				if currentItemID == ID then
					PickupContainerItem(bag, slot)
					if CursorHasItem() then
						DeleteCursorItem();
					end
				end
			end
		end
	end
end

--[[----------------------------------------------- 
    ** Dummy Testing ** 
    DESC: Automatic timer for dummy testing
    ToDo: rename/cleanup 

    Build By: MTS
    ---------------------------------------------------]]
function NeP.Extras.dummyTest(key)
	local hours, minutes = GetGameTime()
	local TimeRemaning = NeP.Core.PeFetch('npconf', 'testDummy') - (minutes-NeP.Extras.dummyStartedTime)
	NeP.Extras.dummyTimeRemaning = TimeRemaning
	
	-- If Disabled PE while runing a test, abort.
	if NeP.Extras.dummyStartedTime ~= 0 
	and not ProbablyEngine.config.read('button_states', 'MasterToggle', false) then
		NeP.Extras.dummyStartedTime = 0
		message('|r[|cff9482C9MTS|r] You have Disabled PE while running a dummy test. \n[|cffC41F3BStoped dummy test timer|r].')
		StopAttack()
	end
	-- If not Calling for refresh, then start it.
	if key ~= 'Refresh' then
		NeP.Extras.dummyStartedTime = minutes
		message('|r[|cff9482C9MTS|r] Dummy test started! \n[|cffC41F3BWill end in: '..NeP.Core.PeFetch('npconf', 'testDummy').."m|r]")
		-- If PE not enabled, then enable it.
		if not ProbablyEngine.config.read('button_states', 'MasterToggle', false) then
			ProbablyEngine.buttons.toggle('MasterToggle')
		end
		StartAttack("target")
	end
	-- Check If time is up.
	if NeP.Extras.dummyStartedTime ~= 0 and key == 'Refresh' then
		-- Tell the user how many minutes left.
		if NeP.Extras.dummyLastPrint ~= TimeRemaning then
			NeP.Extras.dummyLastPrint = TimeRemaning
			NeP.Core.Print('Dummy Test minutes remaning: '..TimeRemaning)
		end
		if minutes >= NeP.Extras.dummyStartedTime + NeP.Core.PeFetch('npconf', 'testDummy') then
			NeP.Extras.dummyStartedTime = 0
			message('|r[|cff9482C9MTS|r] Dummy test ended!')
			-- If PE enabled, then Disable it.
			if ProbablyEngine.config.read('button_states', 'MasterToggle', false) then
				ProbablyEngine.buttons.toggle('MasterToggle')
			end
			StopAttack()
		end
	end
end

--[[-----------------------------------------------
** Ticker **
DESC: SMASH ALL BUTTONS :)
This calls stuff in a define time (used for refreshing stuff).

Build By: MTS
---------------------------------------------------]]
C_Timer.NewTicker(0.5, (function()
	if NeP.Core.CurrentCR then
		NeP.Extras.dummyTest('Refresh')
		if NeP.Core.PeConfig.read('button_states', 'MasterToggle', false) then
			if ProbablyEngine.module.player.combat then
				NeP.Extras.MoveTo()
				NeP.Extras.FaceTo()
				NeP.Extras.autoTarget()
			end
			if not ProbablyEngine.module.player.combat then
				if not UnitChannelInfo("player") then
					CarpDestruction()
					if _BagSpace() > 2 then
						NeP.Extras.autoCraft(_acSpell, _acSpeNum, _acTable)
						NeP.Extras.OpenSalvage()
						NeP.Extras.AutoBait()
					end
				end
			end
		end
	end
end), nil)
