NeP.Interface.MonkWw = {
	key = "npconfigMonkWw",
	profiles = true,
	title = '|T'..NeP.Info.Logo..':10:10|t'..NeP.Info.Nick.." Config",
	subtitle = "Monk WindWalker Settings",
	color = NeP.Core.classColor('player'),
	width = 250,
	height = 500,
	config = {
		
		-- General
		{ type = 'rule' },
		{ 
			type = 'header',
			text = "General settings:", 
			align = "center" 
		},
			{ 
				type = "checkbox", 
				text = "SEF", 
				key = "SEF", 
				default = true,
			},

			-- NOTHING IN HERE YET...

		{ type = "spacer" },
		{ type = 'rule' },
		{ 
			type = "header", 
			text = "Survival Settings", 
			align = "center" 
		},
			
			-- Survival Settings:
			
			
	}
}

local n,r = GetSpellInfo('137639')

local _SEF = function()
	for i=1,#NeP.ObjectManager.unitCache do
		local object = NeP.ObjectManager.unitCache[i]
		if UnitGUID('target') ~= UnitGUID(object.key)
		and IsSpellInRange(GetSpellInfo(137639), object.key) then
			if UnitAffectingCombat(object.key) then
				local _,_,_,_,_,_,debuff = UnitDebuff(object.key, GetSpellInfo(137639), nil, "PLAYER")
				if not debuff and NeP.Core.dynamicEval("!player.buff(137639).count = 2") then
					if NeP.Core.Infront('player', object.key) then
						ProbablyEngine.dsl.parsedTarget = object.key
						return true 
					end
				end
			end
		end
	end
	return false
end

local exeOnLoad = function()
	NeP.Splash()
end

local _All = {
	-- Keybinds
	{ "pause", "modifier.shift" },
	{ "119381", "modifier.control" }, -- Leg Sweep
	{ "122470", "modifier.alt" }, -- Touch of Karma
	
	-- Buffs
	{ "116781", { -- Legacy of the White Tiger
		"!player.buff(116781).any", -- Legacy of the White Tiger
		"!player.buff(17007).any", -- Leader of the Pack
		"!player.buff(1459).any", -- Arcane Brilliance
		"!player.buff(61316).any", -- Dalaran Brilliance
		"!player.buff(97229).any", -- Bellowing Roar
		"!player.buff(24604).any", -- Furious Howl
		"!player.buff(90309).any", -- Terrifying Roar
		"!player.buff(126373).any", -- Fearless Roar
		"!player.buff(126309).any" -- Still Water
	}},
	{ "115921", { -- Legacy of the Emperor
		"!player.buff(115921).any", -- Legacy of the Emperor
		"!player.buff(1126).any", -- Mark of the Wild
		"!player.buff(20217).any", -- Blessing of Kings
		"!player.buff(90363).any", -- Embrace of the Shale Spider
		"!player.buff(Blessing of the Forgotten Kings).any"
	}},
	
	-- FREEDOOM!
	{ "137562", "player.state.disorient" }, -- Nimble Brew = 137562
	{ "116841", "player.state.disorient" }, -- Tiger's Lust = 116841
	{ "137562", "player.state.fear" }, -- Nimble Brew = 137562
	{ "116841", "player.state.stun" }, -- Tiger's Lust = 116841
	{ "137562", "player.state.stun" }, -- Nimble Brew = 137562
	{ "137562", "player.state.root" }, -- Nimble Brew = 137562
	{ "116841", "player.state.root" }, -- Tiger's Lust = 116841
	{ "137562", "player.state.horror" }, -- Nimble Brew = 137562
	{ "137562", "player.state.snare" }, -- Nimble Brew = 137562
	{ "116841", "player.state.snare" }, -- Tiger's Lust = 116841
}

local _Cooldowns = {
	{ "115288", "player.energy <= 30"},-- Energizing Brew
	{ "123904"}, -- Invoke Xuen, the White Tiger
}

local _Survival = {
	{ "115072", { "player.health <= 80", "player.chi < 4" }}, -- Expel Harm
	{ "115098", "player.health <= 75" }, -- Chi Wave
	{ "115203", { -- Forifying Brew at < 30% health and when DM & DH buff is not up
		"player.health < 30",
		"!player.buff(122783)", -- Diffuse Magic
		"!player.buff(122278)"}}, -- Dampen Harm
	{ "#5512", "player.health < 40" }, -- Healthstone
}

local _Interrupts = {
	{ "116705" }, -- Spear Hand Strike
	{ "107079", "!target.debuff(116705)" }, -- Quaking Palm when SHS is on CD
	{ "116844", "!target.debuff(116705)" }, -- Ring of Peace when SHS is on CD
	{ "119381", "target.range <= 5" }, -- Leg Sweep when SHS is on CD
	{ "119392", "target.range <= 30" }, -- Charging Ox Wave when SHS is on CD
	{ "115078", { -- Paralysis when SHS, and Quaking Palm are all on CD
		"!target.debuff(116705)", -- Spear Hand Strike
		"player.spell(107079).cooldown > 0", -- Quaking Palm
	}},
}

local _SEF = {
	{ "137639", (function() return _SEF() end) },
	{ "/cancelaura "..n, "target.debuff(137639)", "target"}, -- Storm, Earth, and Fire
}

local _Ranged = {
	{ "116841", "player.moving"},-- Tiger's Lust
	{ "124081", "!target.debuff(124081)"}, -- Zen Sphere
	{ "115098" }, -- Chi Wave
	{ "123986" }, -- Chi Burst
	{ "117952", "!player.moving"}, -- Crackling Jade Lightning
	{ "115072", "player.chi < 4"}, -- Expel Harm
}

local _Melle = {
	-- Tigereye Brew
	{ "116740", {
		"player.buff(125195).count >= 10", 
		"!player.buff(116740)"
	}},

	-- Rotation
	{{ -- infront
		{ "115080", "player.buff(121125)", "target" }, -- Touch of Death, Death Note
		{ "107428", "target.debuff(130320).duration < 3", "target" }, -- Rising Sun Kick
		{ "100784", "player.buff(116768)", "target" },-- Blackout Kick w/tCombo Breaker: Blackout Kick
		{ "100787", "player.buff(118864)", "target" }, -- Tiger Palm w/t Combo Breaker: Tiger Palm
		{ "113656", "!player.moving", "target" },-- Fists of Fury
	}, "target.NePinfront" },
	-- AoE
		{ "101546", (function() return NeP.Lib.SAoE(3, 8) end) }, -- Spinning Crane Kick
	{{ -- infront
		{ "100784", "player.chi >= 3", "target" }, -- Blackout Kick
		{ "100787", "!player.buff(125359)", "target" }, -- Tiger Palm if not w/t Tiger Power
		{ "115698", nil, "target" }, -- Jab
	}, "target.NePinfront" },
}

ProbablyEngine.rotation.register_custom(269, NeP.Core.GetCrInfo('Monk - Windwalker'),
	{ -- In-Combat
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, "target.NePinterrupt"},
		{_Cooldowns, "modifier.cooldowns"},
		{_SEF, (function() return NeP.Core.PeFetch('npconfigMonkWw', 'SEF') end)},
		{{ -- Conditions
			{_Melle, "target.range <= 5"},
			{_Ranged}
		}, {"target.range <= 40", "target.exists"} }
	}, _All, exeOnLoad)
