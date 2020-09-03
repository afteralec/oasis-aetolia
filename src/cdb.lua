module(..., package.seeall)

-------------------------------------------------------

--! @file
--! @brief Character database module for Oasis Curing System for Aetolia.

--! @copyright Copyright 2014 Alec DuBois, all rights reserved.

--! http://oasis.interimreality.com/

--! Commented in standardized format Doxygen::Lua. 

-------------------------------------------------------

--! todo: Character notes.
--! todo: Key character notes and pk cause in by user character name.
--! todo: Build target affliction tracking:
	--! clear shield/rebounding on hit
--! todo: build better display for entries

chars = {}				--! character database entry table
scanning = true			--! a toggle for automatic adding

hl = {}					--! deprecated - highlighted names table
tempscent = {}			--! secondary scent parse table
tempwho = {}			--! secondary who parse table

--! schema for character database entries
schema = {
	last_updated = getTime(true, "hh:mma - dd/MM/yyyy"),	--! indicates the last time the entry was updated from their .json file
	fullname = "null",
	name = "null",
	city = "null",
	class = "null",
	race = "null",
	guild = "null",
	status = "living",
	level = "null",
	xp_rank = "null",
	explore_rank = "null",
	combat_rank = "null",
	last_location = "null",
	pk_reasons = {},
	notes = {},
	affs = {},
	defs = {
		blindness = true,
		clarity = true,
		deafness = true,
		fangbarrier = true,
		rebounding = true,
		insomnia = true,
		instawake = true,
		insulation = true
	},
	limbs = {
		head = 0,
		torso = 0,
		left_arm = 0,
		right_arm = 0,
		right_leg = 0,
		left_leg = 0
	},
	traits = {},
	mana = 100,
	soul = 100
}

--! @brief Adds a character to the character database.
--! @param name Name of the character to add to the character database.
--! @param sup If true, the echo will be suppressed.
function add(name, sup, nodl)
	local s = string.sub(getMudletHomeDir(), 1, 1) == "/" and "/" or "\\"
	local oasis_dir = getMudletHomeDir() .. s .. "oasis"
	local cdb_dir = oasis_dir .. s .. "cdb"
	local name = name:title()
	if not chars[name] then
		chars[name] = table.shallowcopy(schema)
		if not sup then
			e.info("Character database entry added for <SpringGreen>" .. name .. "<grey>.", true, false) 
		end
		if not nodl then get_api_data(name) end
	else
		if not nodl then
			if not sup then 
				e.info("Character database entry for <SpringGreen>" .. name .. " <grey>updated.", true, false)
			end
			get_api_data(name)
		end
	end
end

--! @brief Deletes a character from the character database.
--! @param name Name of the character to delete.
--! @param sup If true, the echo will be suppressed.
function rem(name)
	local name = name:title()
	if chars[name] then
		chars[name] = nil
		if not sup then
			e.info("Character database entry removed for <SpringGreen>" .. name .. "<grey>.", true, false)
		end
	else
		if not sup then
			e.error("No character database entry exists for <SpringGreen>" .. name .. "<grey>.", true, false)
		end
	end
end

--! @brief Updates the specified name's field in the character database.
--! @param name Accepts a titled string as the character database entry to update.
--! @param field Accepts a string as the field in the character database entry to update.
--! @param value Accepts a string as the value to update the field with.
function update(name, field, value)
	local name = name:title()
	if not chars[name] then
		e.error("No character database entry exists for <SpringGreen>" .. name .. "<grey>.", true, false)
	end
	chars[name][field] = value
	e.info("Character database entry for <SpringGreen>" .. name .. " <grey>updated: <orange_red>" .. field:title() .. " <grey>is now <orange_red>\'" .. value .. "\'", true, false)
end

--! @brief Adds or removes an affliction to or from the specified person in the character database.
--! @param name Accepts a string as the name of the character.
--! @param aff Accepts a string as the affliction to be added or removed.
--! @param add Accepts a boolean - true to add the affliction, false to remove it.
function aff(name, aff, bool)
	local name = name:title()
	if not chars[name] then add(name) end
	local t = chars[name]
	if not t.affs[aff] and not bool then return end

	local stack
	local strip
	if ks.lib[aff] then
	 	stack = ks.lib[aff].stack
		strip = ks.lib[aff].strip
		if t.affs[aff] and not (stack or strip) and bool then return end
	end

	fs.release()

	if bool then
		if ks.lib[aff] and ks.lib[aff].def then
			def(name, aff)
			return
		elseif strip and t.defs[strip] then
			def(name, strip)
			return
		elseif stack and t.affs[aff] then
			if ks.lib[aff].def and t.defs[stack] then
				def(name, stack)
				return
			else
				chars[name].affs[stack] = true
				e.t_aff(name, stack, false, false, true, false)
				return
			end
		end
	elseif not bool and affs.lib[aff] and affs.lib[aff].also then
		for _, aff in ipairs(affs.lib[aff].also) do
			if t.affs[aff] then
				chars[name].affs[aff] = nil
				if timers[aff] then killTimer(timers[aff]) end
				e.t_aff(name, aff, true, false, true, false)
			end
		end
	end

	chars[name].affs[aff] = bool
	if not bool and timers[aff] then killTimer(timers[aff]) end
	if bool and ks.lib[aff] then
		if ks.lib[aff].fade then timers[aff] = tempTimer(ks.lib[aff].fade, [[cdb.chars.]] .. name .. [[.affs.]] .. aff .. [[ = nil]]) end
	end

	if bool then
		e.t_aff(name, aff, false, false, true, false)
	else
		e.t_aff(name, aff, true, false, true, false)
	end
end

function trait(name, key, switch)
	local name = name:title()
	if not chars[name] then add(name) end
	local t = chars[name]

	if chars[name].traits[key] == switch then return end

	cdb.chars[name].traits[key] = switch
	e.t_trait(name, key, switch, true, false)
	fs.release()
end

function dam(name, limb, dam, res)
	local name = name:title()
	if not chars[name] then add(name) end
	local t = chars[name]
	local limb = limb:gsub(" ", "_")
	local dam = tonumber(dam)

	if not cdb.chars[name].limbs then cdb.chars[name].limbs = { head = 0, torso = 0, left_arm = 0, right_arm = 0, right_leg = 0, left_leg = 0 } end

	if res then
		cdb.chars[name].limbs[limb] = cdb.chars[name].limbs[limb] - dam
		e.t_dam(name, limb, dam, true, true, false)
	else
		cdb.chars[name].limbs[limb] = cdb.chars[name].limbs[limb] + dam
		e.t_dam(name, limb, dam, false, true, false)
	end
end

function sort_cure(name, cure, lev)
	local name = name:title()
	if not chars[name] then add(name) end
	local t = chars[name]
	if lev then lev = lev:gsub(" ", "_") end
	if affs.lib.to_cure[cure] then
		cure = affs.lib.to_cure[cure]
	end

	if not affs.lib[cure] then return end

	local function blocked(aff)
		if not aff then return false end
		if not affs.lib[aff] then return false end
		if not affs.lib[aff].block then return false end

		for i, v in ipairs(affs.lib[aff].block) do
			if chars[name].affs[v] then return true end
		end

		return false
	end

	tmp.t_lastcured = {}

	if lev then
		for i, v in ipairs(affs.lib[cure][lev]) do
			if t.affs[v] and not blocked(v) then
				aff(name, v, nil)
				table.insert(tmp.t_lastcured, v)
				break
			end
		end
	else
		for i, v in ipairs(affs.lib[cure]) do
			if t.affs[v] and not blocked(v) then
				aff(name, v, nil)
				table.insert(tmp.t_lastcured, v)
				break
			end
		end
	end
end

--! @brief Adds or removes an defense to or from the specified person in the character database.
--! @param name Accepts a string as the name of the character.
--! @param aff Accepts a string as the defense to be added or removed.
--! @param add Accepts a boolean - true to add the defense, false to remove it.
function def(name, def, bool)
	local name = name:title()
	if not chars[name] then add(name) end
	if not chars[name].defs[def] and not bool then return end
	if chars[name].defs[def] and bool then return end
	local t = chars[name]

	fs.release()

	chars[name].defs[def] = bool

	if bool then
		e.t_def(name, def, false, true, false)
	else
		e.t_def(name, def, true, true, false)
	end
end

function limb(name, limb, num, res, set)
	local name = name:title()
	local num = tonumber(num)
	local _limb = limb:gsub(" ", "_")

	if set then
		chars[name].limbs[_limb] = num
	elseif res then
		chars[name].limbs[_limb] = chars[name].limbs[_limb] - num
		e.t_limb(name, limb, num, true, false, true, false)
	else
		chars[name].limbs[_limb] = chars[name].limbs[_limb] + num
		e.t_limb(name, limb, num, false, false, true, false)
	end
	if chars[name].limbs[_limb] < 0 then chars[name].limbs[limb] = 0 end
	e.t_limb(name, limb, chars[name].limbs[_limb], false, false, true, false)
end

--! @brief Resets the killswitch-specific statistics for the selected Character Database entry.
--! @param name The name of the character to be reset.
--! @param a If true, reset afflictions.
--! @param d If true, reset defenses.
--! @param t If true, reset traits.
function reset(name, a, d, t, e)
	if name == "all" then
		for k, v in pairs(chars) do
			reset(k, a, d, t)
		end
		return
	end

	local name = name:title()
	chars[name].affs = {}
	chars[name].defs = {
		blindness = true,
		clarity = true,
		deafness = true,
		fangbarrier = true,
		insomnia = true,
		insulation = true,
		rebounding = true
	}
	chars[name].limbs = {
		head = 0,
		torso = 0,
		right_arm = 0,
		right_leg = 0,
		left_arm = 0,
		left_leg = 0
	}
	chars[name].traits = {}
	chars[name].mana = 100
	chars[name].restoring = "none"

	local fitness = {
		carnifex = true,
		luminary = true,
		monk = true,
		praenomen = true,
		sentinel = true,
		templar = true
	}
	local class = chars[name].class:lower()
	if fitness[class] then chars[name].defs.fitness = true end
	if class == "monk" then chars[name].defs.immunity = true end
	if class == "indorani" then chars[name].defs.hierophant = true end

	if e then e.echo("Target data reset for <SpringGreen>" .. name .. "<grey>.", true, false) end
end

--! @brief Assumes status on the selected Character Database entries.
--! @param Accepts a string. If "all," will then iterate over the entire Database and assume status for each.
function assume_status(str)
	if str == "all" then
		for k, v in pairs(chars) do
			assume_status(v.name)
		end
	else
		local name = str:title()
		if not chars[name] then
			--! todo: debug script
			return
		end
		local undead_fields = {
			["Praenomen"] = true,
			["Teradrim"] = true,
			["Bloodloch"] = true
		}
		local living_fields = {
			["Ascendril"] = true,
			["Daru"] = true,
			["Duiran"] = true,
			["Enorian"] = true,
			["Luminaries"] = true,
			["Sentaari"] = true,
			["Sentinel"] = true,
			["Sentinels"] = true,
			["Shaman"] = true,
			["Shamans"] = true,
			["Templar"] = true,
			["Templars"] = true,
			["Zealot"] = true
		}
		local city = chars[name].city
		local guild = chars[name].guild
		local class = chars[name].class
		if living_fields[city] or living_fields[guild] or living_fields[class] then
			cdb.update(name, "status", "living")
		elseif undead_fields[city] or undead_fields[guild] or undead_fields[class] then
			cdb.update(name, "status", "undead")
		end
	end
end

--! @brief Shows a character database entry.
--! @param name Name of the character to display information for.
function show(name)
	local name = name:title()

	if not chars[name] then
		e.error("No database entry exists for " .. name .. ".", false, true)

	else

		display_header(chars[name].fullname)

		display_entry("Race", chars[name].race, false, true)
		display_entry("Class", chars[name].class, false, true)
		display_entry("Status", chars[name].status, false, true)
		display_entry("City", chars[name].city, false, true)
		display_entry("Guild", chars[name].guild, false, true)
		display_entry("Level", chars[name].level, false, true)
		display_entry("Experience Rank", chars[name].xp_rank, false, true)
		display_entry("Combat Rank", chars[name].combat_rank, false, true)
		display_entry("Explorer Rank", chars[name].explore_rank, false, true)

		echo("\n")

		display_footer()
	end
end

--! @brief Saves the Character Database to disk.
function save()
	local s = string.sub(getMudletHomeDir(), 1, 1) == "/" and "/" or "\\"
	local oasis_dir = getMudletHomeDir() .. s .. "oasis"
	local data_dir = oasis_dir .. s .. "data"

	for k, v in pairs(chars) do
		chars[k].affs = {}
		chars[k].defs = {
			blindness = true,
			clarity = true,
			deafness = true,
			fangbarrier = true,
			insomnia = true,
			instawake = true,
			insulation = true,
			rebounding = true
		}
		chars[k].mana = tonumber(100)
	end

	table.save(data_dir .. s .. "chardb.lua", chars)
end

--! @brief Loads the Character Database from disk.
function load()
	local s = string.sub(getMudletHomeDir(), 1, 1) == "/" and "/" or "\\"
	local oasis_dir = getMudletHomeDir() .. s .. "oasis"
	local data_dir = oasis_dir .. s .. "data"
	if not lfs.attributes(oasis_dir) then
		e.error("Core directory not detected. Breaking from Player Database load.")
		e.error("Please contact support at:")
		e.cont()
		return
	elseif not lfs.attributes(data_dir) then
		e.error("Data directory not detected. Breaking from Player Database load.")
		e.error("Please contact support at:")
		e.cont()
		return
	end
	if lfs.attributes(data_dir .. s .. "chardb.lua") then
		table.load(data_dir .. s .. "chardb.lua", chars)
		--parse_json_files()
		e.info("Character database loaded.", true, true)
		reset("all", true, true, true)
	else
		e.error("Character database file not found. Breaking from Character Database load.", true, true)
	end
end

--! @brief Iterates over the character database and downloads a new .json file for each entry.
--! @param conf If not "confirm", will issue a warning instead of executing the function.
function refresh(conf)
	local s = string.sub(getMudletHomeDir(), 1, 1) == "/" and "/" or "\\"
	local oasis_dir = getMudletHomeDir() .. s .. "oasis"
	local cdb_dir = oasis_dir .. s .. "cdb"
	if not conf or conf ~= "confirm" then
		e.warn("You are about to refresh the entire character database.", false, true)
		e.warn("This may take a long time, and may noticeably slow your internet connection.", false, true)
		e.warn("Enter 'char refresh confirm' or ", false, false)
		echoLink("click here", [[cdb.refresh("confirm")]], "Click here to confirm Character Database refresh.")
		cecho("<navajo_white> to execute this action.\n")
		return
	end
	e.info("Refreshing Character Database with up-to-date information...", false, true)
	if not lfs.attributes(oasis_dir) then
		e.error("Core directory not detected.")
		return
	elseif not lfs.attributes(cdb_dir) then
		e.error("Character Database directory not detected.")
		return
	end
	for k, v in pairs(chars) do
		get_api_data(k)
	end
	e.info("Character database successfully brought up-to-date with Aetolia API.", false, true)
end

--! @brief Retrieves .json data from Aetolia API and downloads it to cdb.chars[name]
--! @param name Name of the character to download data for.
--! @param update If true, script will update cdb.chars[name].status based on city.
--! Called internally in cdb.add() and cdb.refresh().
function get_api_data(name)
	local s = string.sub(getMudletHomeDir(), 1, 1) == "/" and "/" or "\\"
	local oasis_dir = getMudletHomeDir() .. s .. "oasis"
	local cdb_dir = oasis_dir .. s .. "cdb"
	local name = name:title()

	if not lfs.attributes(oasis_dir) then
		e.error("Core directory not detected.")
		return
	elseif not lfs.attributes(cdb_dir) then
		e.error("Character Database directory not detected.")
		return
	end

	local json = cdb_dir .. s .. name .. ".json"
	downloadFile(json, "http://api.aetolia.com/characters/" .. name .. ".json")
end

--! @brief Parses cdb data for a single json file and saves the character database.
--! @param fname Accepts a string concluding in ".json" as the file to parse.
--! Called internally in oasis_download_event(). Can also be used to open and read any Char.json file.
function parse_api_data(fname)
	local s = string.sub(getMudletHomeDir(), 1, 1) == "/" and "/" or "\\"
	local oasis_dir = getMudletHomeDir() .. s .. "oasis"
	local cdb_dir = oasis_dir .. s .. "cdb"

	if not fname:match(cdb_dir) then
		--! todo: debug script
		return
	end

	local file = assert(io.open(fname, "r"), "Assertion failed for io.open() with argument: " .. fname)
	local p = file:read("*l")
	local r = yajl.to_value(p)

	file:close()

	pop(r)
end

--! @brief Populates a Character Database entry from a table.
--! @param Accepts a table as the table to be entered.
--! Called internally in parse_api_data().
function pop(entry)
	if not type(entry) == "table" then
		--! todo: debug script
		return
	end

	for k, v in pairs(entry) do
		if chars[entry.name] then
			local field = k:gsub(" ", "_")
			chars[entry.name][field] = v:gsub("%(%)", "")
		else
			add(name, true, true)
			for k, v in pairs(entry) do
				local field = k:gsub(" ", "_")
				chars[entry.name][field] = v:gsub("%(%)", "")
			end
			break		--! removing this break will cause an infinite asynchronous loop and crash your client
		end
	end

	chars[entry.name].last_updated = getTime(true, "hh:mma - dd/MM/yyyy")
end

--! @brief Called in cdb.show().
--! @return Returns "None" if #chars[name].pk_reasons is 0.
function get_pk_reasons(name)
	local l = #chars[name].pk_reasons
	local t = {}
	if l == 0 then return "None" end
end

--! @brief Claims a reason to kill a character, removing it from the database.
--! @param name Name of the character to claim a PK cause on.
function claim_pk(name)
	if not chars[name] then
		e.error("No database entry exists for " .. name .. ".")
		return
	end
		
	if #chars[name].pk_reasons == 0 then
		e.error("No PK reasons added for that person.")
		return
	else
		header("PK CLAIMED FOR " .. name:upper())
		local t = table.remove(chars[name].pk_reasons, 1)
		cecho("<deep_sky_blue>  Date added   <grey>: <navajo_white>" .. t.when .. "\n")
		cecho("<deep_sky_blue>  Date claimed <grey>: <navajo_white>" .. getTime(true, "hh:mma - dd/MM/yyyy") .. "\n")
		cecho("<deep_sky_blue>  PK Reason    <grey>: <navajo_white>" .. t.cause .. "\n")
		footer()
	end
end

--! @brief Lists all characters from character database with any entry in pk_reasons.
--! @param name If present, lists the pk reasons in detail for person "name."
function pk_list(name)
	
	if not name or name == "" then
		name = nil
	else
		name = string.title(name)
	end

	if name then

		reasons = {}

		for k, v in pairs(chars[name].pk_reasons) do
			table.insert(reasons, v.cause)
		end

		header("PK Cause  (Reasons): " .. name)
		cecho(" <grey>" .. concand(reasons) .. "\n")
		footer()

		return
	end

	local peeps = {}

	for k, v in pairs(chars) do
		if #v.pk_reasons > 0 then
			table.insert(peeps, k)
		end
	end

	header("PK Cause  (Names)")
	cecho(" <grey>" .. concand(peeps) .. "\n")
	footer()

	return
end

--! @brief Adds PK cause to a character database entry.
--! @param name Name of the character to add a PK reason for.
--! @param reason The reason for the PK cause.
function add_pk_reason(name, reason)
	if not chars[name] then
		add(name)
	else
		chars[name].pk_reasons[#chars[name].pk_reasons+1] = { when = getTime(true, "hh:mma - dd/MM/yyyy"), cause = reason}
		e.echo("PK cause for " .. name .. " saved: <goldenrod>" .. reason:title())
	end
end

--! deprecated
function set_default_highlights()
	for k, v in pairs(cdb.chars) do
		if v.city:title() == s.stats.city then
			chars[k].ally = true
			hl[k] = tempTrigger(k, [[selectString("]] .. k .. [[", 1) fg("LimeGreen") resetFormat()]])
		elseif v.city == "spinesreach" then
			chars[k].ally = true
			hl[k] = tempTrigger(k, [[selectString("]] .. k .. [[", 1) fg("orange") resetFormat()]])
		else
			chars[k].enemy = true
			hl[k] = tempTrigger(k, [[selectString("]] .. k .. [[", 1) fg("maroon") resetFormat()]])
		end
	end
end

--! @brief Autopaths to a person with mmapper, using the last known location as a reference.
--! @param person Name of the character to go to.
function goto(person)
	local p = person:title() 
	if not chars[p] then e.warn("Sorry, no last location is stored for " .. p .. ".") return end
	e.echo("pathing to " .. p .. ".")

	if not person then
		if not tmp.target then
			e.warn("Sorry, you do not have a current target set.") return
		else
			local nums = mmp.getnums(chars[tmp.target].last_location, true)
    		mmp.gotoRoom(nums[1])
		end
	else
		local nums = mmp.getnums(chars[p].last_location, true)
		mmp.gotoRoom(nums[1])
	end
end