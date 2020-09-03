module(..., package.seeall)

-------------------------------------------------------

--! @file
--! @brief Inventory handling script module for Oasis Curing System for Aetolia.

--! @copyright Copyright 2014 Alec DuBois, all rights reserved.

--! http://oasis.interimreality.com/

--! Commented in standardized format Doxygen::Lua.

-------------------------------------------------------

--! storage for pipe data
pipes = {
	prio = {
		"elm",
		"valerian",
		"skullcap",
		"light"
	},

	elm = { living = "put elm in emptypipe", undead = "siphon demulcent", outc = "outc elm" },
	valerian = { living = "put valerian in emptypipe", undead = "siphon antispasmadic", outc = "outc valerian" },
	skullcap = { living = "put skullcap in emptypipe", undead = "siphon sudorific", outc = "outc skullcap" },
	light = { living = "light pipes", undead = "flick syringes" },

	empty = {},
	filled = {}
}

weap = {
	venoms = {
		left = {},
		right = {}
	}
}

function side()
	local left = o.vitals.wield_left
	local right = o.vitals.wield_right
	local side = "both"

	if left:match("shield") or left:match("buckler") or left == "" then
		side = "right"
	else
		side = "left"
	end

	return side
end

--! @brief Parses the Tattoos output and auto-inks tat, tattoo on person, person.
--! @param tat The tattoo to be inked.
--! @param person The person the tattoo will be inked on.
function tattoo(tat, person)
	tmp.tattoo = type
	local person = person or o.stats.name

	local comms = {
		firefly = { "outc 1 yellowink" },
		moss  = { "outc 1 yellowink", "outc 1 blueink", "outc 1 redink" },
		feather = { "outc 2 blueink", "outc 1 redink" },
		shield  = { "outc 2 redink", "outc 1 greenink" },
		mindseye = { "outc 1 greenink", "outc 2 blueink" },
		hammer  = { "outc 2 redink", "outc 1 purpleink" },
		cloak  = { "outc 3 blueink" },
		bell  = { "outc 3 blueink", "outc 2 redink" },
		crystal = { "outc 1 greenink", "outc 1 yellowink", "outc 1 purpleink" },
		moon  = { "outc 1 redink", "outc 1 blueink", "outc 1 yellowink" },
		starburst = { "outc 1 blueink" },
		boar  = { "outc 1 purpleink", "outc 2 redink" },
		web   = { "outc 1 greenink", "outc 1 yellowink" },
		tentacle = { "outc 2 greenink", "outc 1 purpleink" },
		hourglass = { "outc 2 yellowink", "outc 1 blueink" },
		owl   = { "outc 1 blueink", "outc 2 redink", "outc 1 purpleink" },
		brazier = { "outc 2 yellowink", "outc 2 redink" },
		prism  = { "outc 1 redink", "outc 1 blueink", "outc 1 yellowink", "outc 1 greenink", "outc 1 purpleink" },
		tree  = { "outc 5 greenink" },
		mountain = { "outc 1 greenink", "outc 1 blueink", "outc 1 goldink" },
		chameleon = { "outc 1 goldink", "outc 1 purpleink", "outc 1 yellowink" },
		flame = { "outc 1 redink", "outc 1 blueink", "outc 1 yellowink", "outc 1 obsidianink" },
		wand = { "outc 1 greenink", "outc 1 goldink", "outc 1 obsidianink" },
		book = { "outc 5 goldink", "outc 3 obsidianink" },
	}

	for k, v in pairs(comms[tat]) do
		send(v)
	end

	tmp.is_inking = true
	if person:lower() ~= o.stats.name:lower() then send("tattoos " .. person) else send("tattoos") end
end

--! @brief Unwields the necessary items and wields the defined string.
--! @param item Accepts a string as the item to be wielded - note, you can use id numbers here.
--! @param side Accepts a string 'left' or 'right' as the side to wield the weapon.
--! @param both Accepts a boolean value to indicate whether or not the item beind wielded requires both hands.
--! todo: add functionality to switch weapon hands
function wield(w, s, wd, sd)
	local wl = (s == "left")
	local wr = (s == "right")
	local wb = (s == "both")

	local wdl = (sd == "left")
	local wdr = (sd == "right")

	if sd == "both" then
		e.error ("Function inv.wield() cannot accept 'both' as an argument for a second item to be wielded.")
		return
	end

	if not (s == "left" or s == "right" or s == "both") then
		e.error("Function inv.wield() only accepts 'left,' 'right' or 'both' as the second argument.", true, false)
		--! todo: debug
	elseif sd and not (sd == "left" or sd == "right") then
		e.error("Function inv.wield() only accepts 'left' or 'right' as the fourth argument.", true, false)
		--! todo: debug
	end

	local lt = {}
	lt.wield = o.vitals.wield_left:gsub(" ", "")
	lt.is_shield = (lt.wield:match("shield") or lt.wield:match("buckler")) or false
	lt.is_bow = (lt.wield:match("bow")) or false

	local rt = {}
	rt.wield = o.vitals.wield_right:gsub(" ", "")
	rt.is_shield = (rt.wield:match("shield") or rt.wield:match("buckler")) or false
	rt.is_bow = (rt.wield:match("bow")) or false

	if (((wl or wb) and lt.wield:match(w)) or (wr and rt.wield:match(w))) and ((wdl and lt.wield:match(wd)) or (wdr and rt.wield:match(wd))) then
		return
	elseif (wdl and lt.wield:match(wd)) or (wdr and rt.wield:match(wd)) then
		wd = nil
		sd = nil
	elseif ((wl and lt.wield:match(w)) and (wdr and not rt.wield:match(wd))) or ((wr and rt.wield:match(w)) and (wdl and not lt.wield:match(wd))) then
		w = wd
		s = sd
		wd = nil
		sd = nil
	end

	local wl = (s == "left")
	local wr = (s == "right")
	local wb = (s == "both")

	local wdl = (sd == "left")
	local wdr = (sd == "right")

	local qw = _gmcp.has_skill("quickwield", "weaponry") or false
	local ss = _gmcp.has_skill("shieldstance", "weaponry") or false
	local bs = _gmcp.has_skill("bowstance", "weaponry") or false

	local util = {
		"eyesigil",
		"eye",
		"sigil"
	}

	for i, v in ipairs(util) do
		if w:match(v) or (wd and wd:match(v)) then
			can.nobal("balance", true)
			break
		end
	end

	if (lt.is_bow or rt.is_bow) and (wl or wb) then
		if bs then
			table.insert(prompt.q, "wear bow")
		else
			table.insert(prompt.q, "unwield " .. lt.wield)
		end
	elseif lt.is_shield and (wl or wdl or wb) then
		if ss then
			table.insert(prompt.q, "wear " .. lt.wield)
		else
			table.insert(prompt.q, "unwield " .. lt.wield)
			table.insert(prompt.q, "wear " .. lt.wield)
		end
	elseif rt.is_shield and (wr or wdr or wb) then
		if ss then
			table.insert(prompt.q, "wear " .. rt.wield)
		else
			table.insert(prompt.q, "unwield " .. rt.wield)
			table.insert(prompt.q, "wear " .. rt.wield)
		end		
	end

	if s == "both" then
		table.insert(prompt.q, "secure right")
		table.insert(prompt.q, "secure left")
		table.insert(prompt.q, "wield " .. w)
		return
	end
		
	table.insert(prompt.q, "secure " .. s)
	table.insert(prompt.q, "wield " .. w .. " " .. s)
	if wd then
		table.insert(prompt.q, "secure " .. sd)
		table.insert(prompt.q, "wield " .. wd .. " " .. sd)
	end
	--[[else
		if lt.is_bow or rt.is_bow then
			if bs then
				table.insert(prompt.q, "wear bow")
			else
				table.insert(prompt.q, "unwield " .. left)
			end
		elseif lt.is_shield and (wl or wdl) then
			if ss then
				table.insert(prompt.q, "wear " .. lt.wield)
			else
				table.insert(prompt.q, "unwield " .. lt.wield)
				table.insert(prompt.q, "wear " .. lt.wield)
			end
		elseif rt.is_shield and (wr or wdr) then
			if ss then
				table.insert(prompt.q, "wear " .. rt.wield)
			else
				table.insert(prompt.q, "unwield " .. rt.wield)
				table.insert(prompt.q, "wear " .. rt.wield)
			end
		end

		--! todo: handling if you're dual wielding two different types of weapons
		if wd then
			if wd == w then wd = "2." .. wd end
			table.insert(prompt.q, "quickwield both " .. w .. " " .. wd)
		else
			table.insert(prompt.q, "quickwield " .. s .. " " .. w)
		end]]

	--! todo: if no shieldstance/bowstance, track balances
end

function handle_pipes()
	if not can.fill() then return end
	if #pipes.empty == 0 then return end
	local stat = o.stats.status
	
	local act = stat == "living" and "light pipes" or "flick syringes"

	for i, v in ipairs(pipes.empty) do
		table.insert(prompt.q, pipes[v][o.stats.status])
		if pipes[v].outc and stat == "living" and can.outcache() then
			table.insert(prompt.q, pipes[v].outc)
		end
	end
	if not table.contains(pipes.empty, "light") then table.insert(prompt.q, act) end
end

function pipe_empty(item)
	if item == "light" and table.contains(pipes.empty, "light") then return false end
	table.insert(pipes.empty, item)
	table.iremovekey(pipes.filled, item)
	fs.release()
end

function pipe_full(item)
	table.iremovekey(pipes.empty, item)
	if item ~= "light" then table.insert(pipes.filled, item) end
	fs.release()
end