module(..., package.seeall)

function check()
	if not gmcp then
		e.error("GMCP is not enabled. Please enable it via the settings menu and restart your profile.")
	else
		if not o.gmcp_check then
			--raiseEvent("system fully loaded")
			e.echo("GMCP packet received! System is now active.")
			sendGMCP('Core.Supports.Add ["Comm.Channel 1"]')
			sendGMCP("IRE.Rift.Request")
			o.gmcp_check = true
		end
	end
end

function get_stats()
	if not gmcp.Char or not gmcp.Char.Status then
		return e.echo("Awaiting a GMCP status packet.")
	end

	local stats = {
		"unread_msgs",
		"guild",
		"explorer",
		"class",
		"unread_news",
		"bank",
		"order",
		"race",
		"name",
		"gold",
		"status",
		"level",
		"city",
		"spec",
		"fullname"
	}

	tmp.gold = gmcp.Char.Status.gold
	tmp.messages = gmcp.Char.Status.unread_msgs
	tmp.mounted = gmcp.Char.Vitals.mounted == "0" and "No" or "Yes"
		
	if tmp.got_gmcp_status == false then
		local charname = gmcp.Char.Status.fullname
		local class = gmcp.Char.Status.class
		local font_size = "12px"
		local out = [[<p style="font-size: ]] .. font_size .. [[; font-family: ']] .. ui.settings.font .. [[';"><b><font color="brown">> Oasis for Aetolia v<font color="#00B2EE">]] .. o.version ..[[ <font color="brown">  |   Name:<font color="#00B2EE"> ]] .. charname .. [[<font color="brown">   |   Class:<font color="#00B2EE"> ]] .. class .. [[</font></p>]]
		tmp.got_gmcp_status = true
		ui.labels.header:echo(out)
	end

	for _, key in ipairs(stats) do
		if o.stats.last[key] ~= o.stats[key] then
			ui:update_status_bar()
		end

		o.stats.last[key] = o.stats[key]
	end

	for _, key in ipairs(stats) do
		o.stats[key] = gmcp.Char.Status[key]
	end

	o.stats.class = o.stats.class:lower()
	o.stats.status = o.stats.status:lower():gsub("vampire", "undead")
end


function get_vitals()
	if not gmcp.Char or not gmcp.Char.Vitals then
		return e.echo("Awaiting a GMCP vitals packet.")
	end

	local bals = {
		"balance",
		"right_arm",
		"equilibrium",
		"left_arm",
		"pipe",
		"elixir",
		"focus",
		"tree",
		"moss",
		"renew",
		"herb",
		"salve",
		"affelixir"
	}

	for _, key in ipairs(bals) do
		if not o.bals[key] and gmcp.Char.Vitals[key] == "1" then
			if stopwatch[key] then
				stopwatch[key] = nil
			end
			tmp.bals[key] = true
			fs.release()
		end
		o.bals[key] = gmcp.Char.Vitals[key] == "1" and true or false
		if o.bals[key] then
			local used = key .. "_used"
			local tobal = "to_" .. key
			timers[tobal] = 0
			timers[used] = 0
			stopwatch[key] = nil
		end
	end

	o.bals.sync = (o.bals.balance and o.bals.equilibrium) and true or false

	local vitals = {
		"wield_right",
		"class",
		"status",
		"wield_left",
		"mutated",
		"sandstorm"
	}

	for _, key in ipairs(vitals) do
		o.vitals[key] = gmcp.Char.Vitals[key]
	end

	local _defs = {
		"blind",
		"deaf",
		"fangbarrier",
		"cloak",
		"burrowed",
		"mounted"
	}

	for _,key in ipairs(_defs) do

		local def = key:gsub("blind", "blindness"):gsub("deaf", "deafness")
		if not defs.active[def] and tonumber(gmcp.Char.Vitals[key]) == 1 then
			cecho("\n<indian_red>You have gained the <gold>" .. def .. " <indian_red>defense.")
			fs.release()
		elseif defs.active[def] and tonumber(gmcp.Char.Vitals[key]) == 0 then
			cecho("\n<indian_red>Your <gold>" .. def .. " <indian_red>defense has been stripped.")
			fs.release()
		end

		defs.active[def] = gmcp.Char.Vitals[key] == "1" and true or false
	end

	local numbered = {
		"wp",
		"soul",
		"devotion",
		"maxhp",
		"xp",
		"blood",
		"maxep",
		"maxmp",
		"residual",
		"ep",
		"hp",
		"maxwp",
		"spark",
		"mp",
		"bleeding",
		"nl",
		"maxxp"
	}

	for _,key in ipairs(numbered) do
		o.vitals[key] = tonumber(gmcp.Char.Vitals[key])
	end

	local traits = {
		"deaf",
		"prone",
		"cloak",
		"blind",
		"flying",
		"fangbarrier",
	}

	for _, key in ipairs(traits) do
		if (not o.traits[key] and gmcp.Char.Vitals[key] == "1") or (o.traits[key] and gmcp.Char.Vitals[key] == "0") then
			fs.release()
		end

		o.traits[key] = gmcp.Char.Vitals[key] == "1" and true or false
	end

	if o.vitals.mutated == "no"
		or not o.vitals.mutated then
		o.stats.class = tmp.last_class_switch or o.stats.class
	else
		o.stats.class = "shapeshifter"
	end

	tmp.last_wielded = (o.vitals.wield_left == "" and o.vitals.wield_right == "") and "None" or o.vitals.wield_left:gsub("%d+", ""):title()
	if tmp.last_wielded ~= tmp.wielded then send(" ") tempTimer(0.3, [[ui:update_status_bar()]]) end
	tmp.wielded = (o.vitals.wield_left == "" and o.vitals.wield_right == "") and "None" or o.vitals.wield_left:gsub("%d+", ""):title()
end

function to_sync()
	local bal_used = timers.balance_used and timers.balance_used or 0
	local eq_used = timers.equilibrium_used and timers.equilibrium_used or 0
	if bal_used and stopwatch.balance and not o.bals.balance then
		timers.to_balance = bal_used - getStopWatchTime(stopwatch.balance)
	end
	if eq_used and stopwatch.equilibrium and not o.bals.equilibrium then
		timers.to_equilibrium = eq_used - getStopWatchTime(stopwatch.equilibrium)
	end
	if (timers.to_balance and not o.bals.balance) and (timers.to_equilibrium and not o.bals.equilibrium) then
		timers.to_sync = timers.to_balance > timers.to_equilibrium and timers.to_balance or timers.to_equilibrium
	elseif timers.to_balance and not o.bals.balance then
		timers.to_sync = timers.to_balance
	elseif timers.to_equilibrium and not o.bals.equilibrium then
		timers.to_sync = timers.to_equilibrium
	else
		timers.to_sync = 0
	end
end

function get_skillsets()
	if not gmcp or not gmcp.Char or not gmcp.Char.Skills then return end

	o.skills = {}

	for _, set in ipairs(gmcp.Char.Skills.Groups) do
		local skills = string.format("Char.Skills.Get %s", yajl.to_string({ group = set.name }))
		sendGMCP(skills)
	end
	send("\n")
end

function populate_skill_tree()
	if not gmcp or not gmcp.Char or not gmcp.Char.Skills then return end

	local group = gmcp.Char.Skills.List.group
	local list = gmcp.Char.Skills.List.list
	local newlist = {}
	for i, val in ipairs(list) do
		list[i] = val:gsub("* ", ""):lower()
	end

	if group then
		o.skills[group] = list
	end

	defs.build()										--! this function populates the defense library by gmcp skill flag
end

function has_skill(skill, ab)
	if not gmcp or not gmcp.Char or not gmcp.Char.Skills then return end
	if not o.skills then return end

	if ab and o.skills[ab] then
		if not o.skills[ab] then
			--! todo: debug
		end
		return table.contains(o.skills[ab], skill)
	else
		return false
	end
end

function has_ab(ab)
	if not gmcp or not gmcp.Char or not gmcp.Char.Skills or not gmcp.Char.Skills.Groups then return end

	for k, v in pairs(gmcp.Char.Skills.Groups) do
		display(v.name)
		if v.name:lower() == ab then
			return true
		end
	end

	return false
end

function Add()
	local location = gmcp.Char.Items.Add.location

	if location ~= "inv" and location ~= "room" then
		location = location:match("%d+$")
	end
	local loc = location .. "items"
	local item = gmcp.Char.Items.Add.item

	if not tmp[loc] then
		return
	end

	if location == "inv" then
		tmp.invUpdated = true
	end

	table.insert(tmp[loc], gmcp.Char.Items.Add.item)

	if loc == "invitems" and item.attrib and item.attrib:find("c") then
		sendGMCP("Char.Items.Contents "..item.id)
	end

	if gmcp.Char.Items.Add['location'] == 'room' then
		--get_stuff('add')
	end

	raiseEvent("items update")
	ui:update_room_items()
end

function Remove()
	local location = gmcp.Char.Items.Remove.location

	if location ~= "inv" and location ~= "room" then
		location = location:match("%d+$")
	end

	local loc = location .. "items"
	if not tmp[loc] then
		sendGMCP("Char.Items.Inv")
		return
	end

	if location == "inv" then
		tmp.invUpdated = true
	end

	for k, v in pairs(tmp[loc]) do
		if tostring(v.id) == tostring(gmcp.Char.Items.Remove.item.id) then
			table.remove(tmp[loc], k)
			break
		end
	end

	raiseEvent("items update")
	ui:update_room_items()
end

function List()
	local location = gmcp.Char.Items.List.location  
	if location ~= "inv" and location ~= "room" then
		location = location:match("%d+$")
	end
	local loc = location .. "items"
	tmp[loc] = {}
	for k, v in pairs(gmcp.Char.Items.List.items) do
		table.insert(tmp[loc], v)
		if loc == "invitems" and v.attrib and v.attrib:find("c") then
			sendGMCP("Char.Items.Contents " .. v.id)
		end
	end

	raiseEvent("items update")
	ui:update_room_items()
end

function Update()
	local location = gmcp.Char.Items.Update.location
	if location ~= "inv" and location ~= "room" then
		location = location:match("%d+$")
	end
	local loc = location .. "items"
	local item = gmcp.Char.Items.Update.item
	local updated
	if not tmp[loc] then
		sendGMCP("Char.Items.Inv")
		return
	end

	if location == "inv" then
		tmp.invUpdated = true
	end

	for k, v in pairs(tmp[loc]) do
		if v['attrib'] then
			if string.find(v['attrib'], 'lL') then
				tmp.did_wield['left'] = {['id'] = v['id'], ['name'] = v['name']}
				tmp.did_wield['right'] = {['id'] = v['id'], ['name'] = v['name']}
			elseif string.find(v['attrib'],'l') then
				tmp.did_wield['left'] = {['id'] = v['id'], ['name'] = v['name']}
			elseif string.find(v['attrib'], 'L') then
				tmp.did_wield['right'] = {['id'] = v['id'], ['name'] = v['name']}
			end
		end
	end

	for k, v in pairs(tmp[loc]) do
		if v.id * 1 == gmcp.Char.Items.Update.item.id * 1 then
			tmp[loc][k] = gmcp.Char.Items.Update.item
			updated = true
			break
		end
	end

	if loc == "invitems" and not updated then sendGMCP("Char.Items.Inv") end
	if loc == "invitems" and item.attrib and item.attrib:find("c") then
		sendGMCP("Char.Items.Contents " .. item.id)
	end

	raiseEvent("items update")
	ui:update_room_items()
end

function StatusVars()
	tmp.invitems = {}
	tmp.roomitems = {}

	tempTimer(1.5, [[sendGMCP("Char.Items.Inv")]])
end

function items_events(self, e, arg) 
	local e = e:match("%w+$")
	local func, err = assert(loadstring([[_gmcp:]] .. e .. [[()]]))
	if err then
		e.error("Error in items_events: "..err..".")
	end
	func()
end

function consolidate_inv_items()
	tmp.sorted_inv_items = {}
	for _, key in pairs(tmp.invitems) do
		if not tmp.sorted_inv_items[key.name] then
			tmp.sorted_inv_items[key.name] = {}
		end

		table.insert(tmp.sorted_inv_items[key.name], key.id)
	end
end

function consolidate_room_items()
	tmp.sorted_room_items = {}
	for _, key in pairs(tmp.roomitems) do
		if not tmp.sorted_room_items[key.name] then
			tmp.sorted_room_items[key.name] = {}
		end

		table.insert(tmp.sorted_room_items[key.name], key.id)
	end
end

function rift_change(self, e)
	local change = gmcp.IRE.Rift.Change or ""
	local list = gmcp.IRE.Rift.List or ""

	if e == "gmcp.IRE.Rift.Change" then
		tmp.rift[change.name] = tonumber(change.amount)
		raiseEvent("prerift check")
	elseif e =="gmcp.IRE.Rift.List" then
		for _, item in ipairs(list) do
			tmp.rift[item.name] = tonumber(item.amount)
		end
	end

	local slices = {"pineal", "bone", "bladder", "liver", "eyeball", "testis", "ovary", "castorite", "lung", "kidney", "sulphurite", "tongue", "heart", "stomach", "tumor", "spleen"}

	to_dissect = {}
	for item, amount in pairs(tmp.rift) do
		if table.contains(slices, item) then
			local added = false
			for i, slice in ipairs(to_dissect) do
				if tmp.rift[item] < tmp.rift[slice] then
					table.insert(to_dissect, i, item)
					added = true
					break
				end
			end
			if not added then table.insert(to_dissect, item) end
		end
	end
end

function inv_count(item)
end


-- list.herbs[o.stats.status]

--[[{
  "bladder_slice",
  "liver_slice",
  "eyeball_slice",
  "testis_slice",
  "ovary_slice",
  "castorite_slice",
  "lung_slice",
  "kidney_slice",
  "sulphurite_slice",
  "tongue_slice",
  "heart_slice",
  "stomach_slice",
  "bone_slice",
  "pear"
}]]


-- tmp.invitems strings

-- a stack of 5 castorite gland slices
-- a stack of 5 bone slices
-- a stack of 5 prickly pears

function prerift(self, amt)
	if true then return end
	if not list.herbs[o.stats.status] then return end
		--tmp.invUpdated = true
	local i = {}
	local amt = amt or 5
	if tmp.riftReceived and not tmp.invUpdated then
		local rItem = tmp.riftReceived[1]
		rItem = rItem:match("^(%w+)")
		local rAmt = tmp.riftReceived[2]
		local re = rex.new("^(?:a |an |some )?(?:stack of )?(\\d*)\\s*(?:slices of |pieces? of )?(?:prickly |slippery |black )?(\\w+)\\s*(?:flowers?|berry|berries|bark|roots?|seeds?|leaf|leaves|nuts?|(?:gland )?slices?|gland)?$")
		for k, v in pairs(tmp.invitems) do
			if v.name:find(rItem) then
				local sAmt, sNamen = re:match(v.name)
				if not sAmt then sAmt = 1 end
				sAmt = sAmt + rAmt
				v.name = string.format("a stack of %d %s slice", sAmt, sNamen)
				break
			end
		end
	end
	tmp.riftReceived = nil
	tmp.invUpdated = nil

	for _, v in ipairs(list.herbs[o.stats.status]) do
		i[v] = 0
	end

	for k, v in pairs(tmp.invitems) do
		if v.name:find("slice") or v.name:find("prickly") then
			local re = rex.new("^(?:a |an |some )?(?:stack of )?(\\d*)\\s*(?:slices of |pieces? of )?(?:prickly |slippery |black )?(\\w+)\\s*(?:flowers?|berry|berries|bark|roots?|seeds?|leaf|leaves|nuts?|(?:gland )?slices?|gland)?$")
			local e, f = re:match(v.name)
			e = e or 1
			e = tonumber(e)
			f = f:gsub("pears", "pear")..(f:find("pear") and "" or "_slice")
			i[f] = i[f] + e
		end
	end

	tmp.invcures = i

	if can:outrift() then
		if not fs.check("incall") then
			for k, v in pairs(i) do
				if v < amt then
					if not fs.check("outc_" .. k) then
						send("outc " .. (amt-v) .. " " .. k)
						fs.on("outc_" .. k, 1)
					end
				end
			end
		end
	end
end