module(..., package.seeall)

-------------------------------------------------------

--! @file
--! @brief Prompt processing module for Oasis Curing System for Aetolia.

--! @copyright Copyright 2014 Alec DuBois, all rights reserved.

--! http://oasis.interimreality.com/

--! Commented in standardized format Doxygen::Lua. 

-------------------------------------------------------

--! todo: parse the entire system to make sure fs.queue is being released smoothly

--! if toggled true, the prompt will be gagged.
gag = false

--! @brief Fires all necessary script on prompt.
function call()
	if not gmcp then
		echo(" [No GMCP data detected]")
		if fs.gmcp_warn then return end
		e.warn("Please go to Mudlet Settings and enable GMCP.", true, true)
		fs.on("gmcp_warn", 15)
		return
	end

	if not gmcp.Char then return end

	_gmcp.to_sync()

	q = {}
	d = {}

	if not gag then
		balances()
		target()
		stat_change()
	end

	affs.clear_lastcures()

	channel.pause(tmp.channel)

	affs.checks()

	defs.defup()
	execute(d, "d")
	affs.cure_all(affs.prio.cures)
	defs.affelixir()

	inv.handle_pipes()
	affs.diagnose()
	--! todo: collapse these into one function
	affs.cure_fitness()
	affs.cure_shrug()
	-- affs.resources()
	defs.defup_q()

	bash.execute()

	if ks and ks.engage and ks.sets and ks.sets.route then ks.engage(o.stats.class, ks.sets.route) end

	queue(q)

	tmp.rebounded = false
	tmp.blockvenom = false
	tmp.t_lastcured = nil

	--! These are all of the variables that we pass from prompt to prompt. This might be worth cleaning up with multiline/AND triggers down the line.
	--[[
	tmp.ignore_loki = false
	tmp.t_lastremaff = false
	]]

end

--! @brief Sends a list of commands in blocks of ten, separated by a config separator.
--! @param array Accepts a table as the list to concat and send.
function execute(array, lim)
	if not array then return end

	for i, v in ipairs(array) do
		if v:match("queue") then
			send(v)
			table.iremovekey(array, v)
		end
	end

	if o.debug then
		--e.debug("Prompt.execute: " .. lim ..  ": " .. table.concat(array, ", "), true, false)
	end

	if fs[lim] then return end

	if #array == 0 then return end

	local config_sep = o.config_sep

	while #array > 0 do
		local tlen = (#array > 10) and 10 or #array
		send(table.concat(array, config_sep, 1, tlen))
		
		for i=1,tlen do
			table.remove(array, 1)
		end
	end

	fs.on(lim, 2)
end

--! @brief Queues a list of commands in blocks of ten, separated by a config separator using Aetolia's Queueing.
--! @param array Accepts a table as the list to concat and queue.
function queue(array)
	if not array then return end
	if fs.queue then
		if o.debug then
			--! todo: debug
		end
		return
	end

	if can.stand() then
		if _gmcp.has_skill("kipup", "tekura") then
			send("kipup")
		else
			table.insert(prompt.q, "stand")
		end
	end

	if #prompt.q == 0 or not prompt.q then
		fs.on("queue", 60)
	end

	if not tmp.paused then
		table.insert(array, 1, "stand")
		table.insert(array, 1, "touch amnesia")
	end

	local qeb = "q" .. ((o.bals.equilibrium or (ks and ks.engaged)) and "" or "e") .. ((o.bals.balance or (ks and ks.engaged)) and "" or "b") .. (((o.bals.balance and o.bals.equilibrium) or (ks and ks.engaged)) and "eb" or "") .. " "
	
	if qeb == "qeb "  and not tmp.paused then
		table.insert(array, "qe")
		table.insert(array, "qb")
	elseif qeb == "qb " and not tmp.paused then
		table.insert(array, "qeb")
		table.insert(array, "qe")
	elseif qeb == "qe " and not tmp.paused then
		table.insert(array, "qeb")
		table.insert(array, "qb")
	end

	local config_sep = o.config_sep

	if o.debug then
		e.debug("Prompt.q: " .. table.concat(array, ", "), true, false)
	end

	local first = true
		while #array > 0 do
			local qeb = "q"..((o.bals.equilibrium or (ks and ks.engaged)) and "" or "e")..((o.bals.balance or (ks and ks.engaged)) and "" or "b")..(((o.bals.balance and o.bals.equilibrium) or (ks and ks.engaged)) and "eb" or "") .. " "

			local tlen = (#array > 10) and 10 or #array
			local clear = first and qeb or nil
			if clear and not tmp.paused then send(qeb, false) end
			send((first and qeb or "") .. table.concat(array, config_sep, 1, tlen))

			first = false
			for i = 1,tlen do
				table.remove(array, 1)
			end
		end

	fs.on("queue", 60)
end

--! @brief Appends a display for curing balances to the end of each prompt.
function balances()
	if gag then return end
	if not gmcp.Char or not gmcp.Char.Vitals then return end

	local h = o.bals.herb and true or false
	local s = o.bals.salve and true or false
	local p = o.bals.pipe and true or false

	local e = o.bals.elixir and true or false
	local m = o.bals.moss and true or false
	local a = o.bals.affelixir and true or false

	local f = o.bals.focus and true or false
	local t = o.bals.tree and true or false
	local r = o.bals.renew and true or false

	if (affs.current.anorexia or affs.current.indifference or affs.current.destroyed_throat) then h = "x" elseif not h then h = "-" else h = "h" end
	if (affs.current.slickness or affs.current.burnt_skin) then s = "x" elseif not s then s = "-" else s = "s" end
	if ((affs.current.asthma and o.stats.status == "living") or (affs.current.limp_veins and o.stats.status == "undead")) then p = "x" elseif not p then p = "-" else p = "p" end

	if (affs.current.anorexia or affs.current.indifference or affs.current.destroyed_throat) then e = "x" elseif not e then e = "-" else e = "e" end
	if (affs.current.anorexia or affs.current.indifference or affs.current.destroyed_throat) then m = "x" elseif not m then m = "-" else m = "m" end
	if (affs.current.anorexia or affs.current.indifference or affs.current.destroyed_throat) then a = "x" elseif not a then a = "-" else a = "a" end

	if affs.current.impatience then f = "x" elseif not f then f = "-" else f = "f" end
	if (affs.current.paralysis or affs.current.paresis or affs.current.sear or affs.current.shell_fetish) then t = "x" elseif not t then t = "-" else t = "t" end
	if (affs.disrupted and affs.current.confusion) then r = "x" elseif not r then r = "-" else r = "r" end

	cecho(" <reset>[")
	echo(h .. s .. p .. " " .. e .. m .. a .. " " .. f .. t .. r .. "]")
end

--! @brief Appends health and mana changes in percent increase/decrease to the end of each prompt.
function stat_change()
	if gag then return end
	if not gmcp.Char or not gmcp.Char.Vitals then return end

	if affs.count.hidden > 0 then
		cecho(" <reset>[h: <orange_red>" .. affs.count.hidden .. "<reset>]")
	end

	local flathp = 0
	local flatmp = 0
	local perchp = 0
	local percmp = 0

	if affs.blackout then return end

	flathp = tonumber(o.vitals.hp or 0) - tonumber(o.vitals.last.hp or 0)
	flatmp = tonumber(o.vitals.mp or 0) - tonumber(o.vitals.last.mp or 0)

	perchp = math.ceil((flathp/o.vitals.maxhp) * 100)
	percmp = math.ceil((flatmp/o.vitals.maxmp) * 100)

	o.vitals.last.hp = o.vitals.hp
	o.vitals.last.mp = o.vitals.mp

	if (flathp == 0 and flatmp == 0) or ((perchp < 1 and perchp > -1) and (percmp < 1 and percmp > -1)) then return end

	local disp = {}
	cecho("<reset> [")

	-- Health
	if flathp < 0 then
		table.insert(disp, "<firebrick>" .. perchp .. "<slate_grey>%")
	elseif flathp > 0 then
		table.insert(disp, "<medium_sea_green>+" .. perchp .. "<slate_grey>%")
	end

	-- Mana
	if flatmp < 0 then
		table.insert(disp, "<OrangeRed>" .. percmp .. "<slate_grey>%")
	elseif flatmp > 0 then
		table.insert(disp, "<medium_slate_blue>+" .. percmp .. "<slate_grey>%")
	end

	cecho(table.concat(disp, "<reset>] ["))
	cecho("<reset>]")
end

--! @brief If killswitch is active, this appends information on the target to the end of each prompt.
function target()
	if gag then return end
	local t = cdb.chars[tmp.target:title()]
	if not t then return end
	if not tmp.target then return end
	if not t.mana then return end
	
	if (o.stats.class == "luminary"
		or o.stats.class == "bloodborn"
		or o.stats.class == "praenomen") then
		cecho(" <reset>[t:")
		local mp = t.mana
		if mp >= 75 then 
			fg("steel_blue")
		elseif (mp < 75 and mp >= 50) then
			fg("blue_violet")
		elseif mp < 50 then
			fg("violet_red")
		end
		echo(mp)
		cecho("<slate_grey>%<reset>]")
	end
end