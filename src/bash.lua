module(..., package.seeall)

-------------------------------------------------------

--! @file
--! @brief Bashing module for Oasis Curing System for Aetolia.

--! @copyright Copyright 2014 Alec DuBois, all rights reserved.

--! http://oasis.interimreality.com/

--! Commented in standardized format Doxygen::Lua.

-------------------------------------------------------

local ac = {}

--! storage for module settings
sets = {
	bash = false,
	ascendril = {
		act = "sc",
	},
	cabalist = {
		act = "d",
	},
	carnifex = {
		act = "hack",
	},
	indorani = {
		act = "bd",
	},
	luminary = {
		act = "sm",
	},
	monk = {
		act = "upc",
	},
	praenomen = {
		act = "f",
	},
	sciomancer = {
		act = "sc",
	},
	sentinel = {
		act = "shb",
	},
	shaman = {
		act = "l",
	},
	shapeshifter = {
		act = "sl",
	},
	syssin = {
		act = "cam",
	},
	templar = {
		act = "dsw",
		sac = "sacrifice"
	},
	teradrim = {
		act = "b",
	},
	zealot = {
		act = "upc",
	}
}

lib = {
	ascendril = {
		sc = {
			name = "Staffcast",
			handle = "sc",
			skill = { "aetherstaff", "elemancy" },
			act = "staffcast dissolution at #",
			cons = { "equilibrium" }
		},
	},

	cabalist = {
		d = {
			name = "Decay",
			handle = "d",
			skill = { "decay", "necromancy" },
			act = "decay #",
			wield = "shield",
			cons = { "equilibrium" }
		},
	},

	carnifex = { 
		bash = {
			name = "Hammer Bash",
			handle = "bash",
			skill = { "bash", "savagery" },
			act = "hammer bash #",
			wield = "warhammer",
			cons = { "balance" }
		},
		db = {
			name = "Hammer Doublebash",
			handle = "db",
			skill = { "doublebash", "savagery" },
			act = "hammer doublebash #",
			wield = "warhammer",
			cons = { "balance" }
		},
		hack = {
			name = "Pole Hack",
			handle = "hack",
			skill = { "hack", "savagery" },
			act = "pole hack #",
			wield = "bardiche",
			cons = { "balance" }
		},
		ssl = {
			name = "Pole Spinslash",
			handle = "ssl",
			skill = { "spinning", "savagery" },
			act = "pole ssl #",
			wield = "bardiche",
			cons = { "balance" }
		}
	},
	
	indorani = {
		bd = {
			name = "Bonedagger",
			handle = "bd",
			skill = { "bonedagger", "necromancy" },
			act = "flick bonedagger at #",
			cons = { "balance" }
		},
		d = {
			name = "Decay",
			handle = "d",
			skill = { "decay", "necromancy" },
			act = "decay #",
			wield = "bonedagger",
			cons = { "equilibrium" }
		},
	},
	
	luminary = {
		l = {
			name = "Lightning",
			handle = "l",
			skill = { "lightning", "illumination" },
			act = "evoke lightning #",
			cons = { "equilibrium" }
		},
		sm = {
			name = "Smite",
			handle = "sm",
			skill = { "smite", "spirituality" },
			act = "smite #",
			wield = "spiritmace",
			cons = { "balance" }
		},
	},
	
	monk = {
		upc = {
			name = "Uppercut",
			handle = "upc",
			skill = { "uppercut", "tekura" },
			act = "combo # sdk upc upc",
			cons = { "balance" }
		},
	},

	praenomen = {
		f = {
			name = "Frenzy",
			handle = "f",
			skill = { "frenzy", "corpus" },
			act = "frenzy #",
			cons = { "balance" }
		},
		
		slash = {
		     name = "Slash",
			 handle = "slash",
			 skill = { "scythe", "hematurgy" },
			 act = "slash #",
			 cons = { "balance" }
			 },
			 
	},

	sciomancer = {
		sc = {
			name = "Staffcast",
			handle = "sc",
			skill = { "voidstaff", "sciomancy" },
			act = "staffcast dissolution at #",
			cons = { "equilibrium" }
		},
	},

	sentinel = {
		shb = {
			name = "Heartbreaker",
			handle = "shb",
			skill = { "heartbreaker", "dhuriv" },
			act = "dhuriv combo # strike heartbreaker",
			cons = { "balance" }
		}
	},

	shaman = {
		l = {
			name = "Lightning",
			handle = "l",
			skill = { "lightning", "primality" },
			act = "commune lightning #",
			cons = { "equilibrium" }
		}
	},

	shapeshifter = {
		sl = {
			name = "Slash",
			handle = "sl",
			skill = { "slashing", "ferality" },
			act = "combo # slash slash",
			cons = { "balance" }
		},
	},

	syssin = {
		cam = {
			name = "Camus",
			handle = "cam",
			skill = { "camus", "venoms" },
			act = "bite # camus",
			cons = { "balance" }
		},
		sum = {
			name = "Sumac",
			handle = "sum",
			skill = { "sumac", "venoms" },
			act = "bite # sumac",
			cons = { "balance" }
		},
		g = {
			name = "Garrote",
			handle = "g",
			skill = { "garrote", "subterfuge" },
			act = "garrote #",
			cons = { "balance" }
		}
	},

	templar = {
		dsk = {
			name = "Doublestrike",
			handle = "dsk",
			skill = { "duality", "battlefury" },
			act = "dsk #",
			wield = { "shortsword", "left", "shortsword", "right" },
			cons = { "balance" }
		},
		dsw = {
			name = "Doubleswing",
			handle = "dsw",
			skill = { "doubleswing", "battlefury" },
			act = "doubleswing #",
			wield = { "bastardsword", "both" },
			cons = { "balance" }
		},
		str = {
			name = "Strike",
			handle = "str",
			skill = { "strike", "battlefury" },
			act = "strike #",
			wield = { "shield", "left", "shortsword", "right" },
			cons = { "balance" }
		}
	},

	teradrim = {
		b = {
			name = "Batter",
			handle = "b",
			skill = { "batter", "terramancy" },
			act = "earth batter #",
			cons = { "balance" }
		}
	},

	zealot = {
		upc = {
			name = "Uppercut",
			handle = "upc",
			skill = { "uppercut", "tekura" },
			act = "combo # sdk upc upc",
			cons = { "balance" }
		},
	},
}

function define(class, def)
	if not ac[class] then
		e.error("No bashing entry for " .. class .. " detected.", true, false)
		sets.bash = false
		return
	end

	if not def then
		display_header("Bashing actions available for " .. class:title())
		for k, v in pairs(lib[class]) do
			display_entry(v.name, v.handle, true, false)
		end
		e.echo("Do <deep_sky_blue>\'SET BASH \<SHORTCUT\>\' to set bashing action.", true, true)
		display_footer()
		return
	end

	if not lib[class][def] then
		e.error("The bashing attack \'" .. def .. "\' is not registered for " .. class .. ". Use 'set bash' with no arguments to see the available sets.", true, false)
		return
	end

	local skill, ab = unpack(lib[class][def].skill)
	if not _gmcp.has_skill(skill, ab) then
		e.error("You don't have the skill for that bashing attack.", true, false)
		return
	end

	sets[class].act = def
	e.echo("Will now bash with " .. lib[class][def].name .. " in " .. class .. ".", true, false)
end

function execute()
	if not can.reqbaleq() then return end
	if not sets.bash then return end
	local class = o.stats.class

	if not ac[class] then
		e.error("No bashing entry for " .. class .. " detected.", true, false)
		sets.bash = false
		return
	end

	local data = ac[class]()

	for _, def in ipairs(data.defs) do
		if not defs.preserve[def] then
			defs.keep(def, true)
		end
	end

	local w, s, w_2, s_2 = unpack(data.wield)
	if w and s then inv.wield(w, s, w_2, s_2) end

	for _, a in ipairs(data.act) do
		local a = a:gsub("#", tmp.target)
		table.insert(prompt.q, a)
	end

	for _, cn in ipairs(data.cons) do
		can.nobal(cn, true)
	end
end

function ac.ascendril()
	local lib = lib.ascendril
	local acts = sets.ascendril.act
	local bash = {
		defs = {},
		wield = { "shield", "left" },
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	if acts == "sc" then
		table.insert(bash.wield, 1, "right")
		table.insert(bash.wield, 1, "aetherstaff")
	end
	return bash
end

function ac.cabalist()
	local lib = lib.cabalist
	local acts = sets.cabalist.act
	local bash = {
		defs = {},
		wield = { "shield", "left" },
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	return bash
end

function ac.carnifex()
	local lib = lib.carnifex
	local acts = sets.carnifex.act
	local to_act = tmp.soul_cons and "soul cull" or lib[acts].act
	local to_act = (tmp.soul_cons and defs.active.soul_fracture) and "soul unify" or to_act
	local bash = {
		defs = tmp.soul_cons and {} or { "furor" },
		wield = { lib[acts].wield, "both" },
		act = { "absorb ylem mist", "order loyal follow me", to_act },
		cons = lib[acts].cons
	}
	if tmp.soul_cons then 
		if defs.preserve.soul_fracture then defs.nokeep("soul_fracture", true) end
		table.insert(bash.act, 1, "soul consumption") end
	return bash
end

function ac.indorani()
	local lib = lib.indorani
	local acts = sets.indorani.act
	local bash = {
		defs = {},
		wield = { "shield", "left" },
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	if acts == "bd" then
		table.insert(bash.wield, 1, "right")
		table.insert(bash.wield, 1, "bonedagger")
	end
	return bash
end

function ac.luminary()
	local lib = lib.luminary
	local acts = sets.luminary.act
	local bash = {
		defs = {},
		wield = { "shield", "left" },
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	if acts == "sm" then
		table.insert(bash.wield, 1, "right")
		table.insert(bash.wield, 1, "spiritmace")
	end
	return bash
end

function ac.monk()
	local lib = lib.monk
	local acts = sets.monk.act
	local bash = {
		defs = {},
		wield = {},
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	local wb = _gmcp.has_skill("weaponbelts", "weaponry")
	if o.vitals.wield_left ~= "" then 
		if wb then 
			table.insert(bash.act, 1, "secure left")
		else
			table.insert(bash.act, 1, "unwield left")
		end
	end
	if o.vitals.wield_right ~= "" then
		if wb then 
			table.insert(bash.act, 1, "secure right")
		else
			table.insert(bash.act, 1, "unwield right")
		end
	end
	return bash
end

function ac.praenomen()
	local lib = lib.praenomen
	local acts = sets.praenomen.act
	local bash = {
		defs = {},
		wield = { "shield", "left" },
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	return bash
end

function ac.sciomancer()
	local lib = lib.sciomancer
	local acts = sets.sciomancer.act
	local bash = {
		defs = {},
		wield = { "shield", "left" },
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	if acts == "sc" then
		table.insert(bash.wield, 1, "right")
		table.insert(bash.wield, 1, "voidstaff")
	end
	return bash
end

function ac.sentinel()
	local lib = lib.sentinel
	local acts = sets.sentinel.act
	local bash = {
		defs = {},
		wield = { "dhurive", "both" },
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	return bash
end

function ac.shaman()
	local lib = lib.shaman
	local acts = sets.shaman.act
	local bash = {
		defs = {},
		wield = { "quarterstaff", "right", "shield", "left" },
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	return bash
end

function ac.shapeshifter()
	local lib = lib.shapeshifter
	local acts = sets.shapeshifter.act
	local bash = {
		defs = {},
		wield = {},
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	local wb = _gmcp.has_skill("weaponbelts", "weaponry")
	if o.vitals.wield_left ~= "" then 
		if wb then 
			table.insert(bash.act, 1, "secure left")
		else
			table.insert(bash.act, 1, "unwield left")
		end
	end
	if o.vitals.wield_right ~= "" then
		if wb then 
			table.insert(bash.act, 1, "secure right")
		else
			table.insert(bash.act, 1, "unwield right")
		end
	end
	return bash
end

function ac.syssin()
	local lib = lib.syssin
	local acts = sets.syssin.act
	local bash = {
		defs = {},
		wield = { "whip", "right", "shield", "left" },
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	if o.bals.primary_illusion or o.bals.secondary_illusion then table.insert(bash.act, 1, "conjure darkflood") end
	return bash
end

function ac.templar()
	local lib = lib.templar
	local acts = sets.templar.act
	local sac = lib[acts].act .. " " .. sets.templar.sac
	local bash = {
		defs = {},
		wield = lib[acts].wield,
		act = { "absorb ylem mist", sac, "wipe left", "wipe right" },
		cons = lib[acts].cons
	}
	return bash
end

function ac.teradrim()
	local lib = lib.teradrim
	local acts = sets.teradrim.act
	local bash = {
		defs = {},
		wield = { "flail", "right", "shield", "left" },
		act = { "absorb ylem mist", "order loyal follow me", lib[acts].act },
		cons = lib[acts].cons
	}
	return bash
end

function ac.zealot()
	local lib = lib.zealot
	local acts = sets.zealot.act
	local bash = {
		defs = {},
		wield = {},
		act = { "absorb ylem mist", lib[acts].act },
		cons = lib[acts].cons
	}
	local wb = _gmcp.has_skill("weaponbelts", "weaponry")
	if o.vitals.wield_left ~= "" then
		if wb then 
			table.insert(bash.act, 1, "secure left")
		else
			table.insert(bash.act, 1, "unwield left")
		end
	end
	if o.vitals.wield_right ~= "" then
		if wb then 
			table.insert(bash.act, 1, "secure right")
		else
			table.insert(bash.act, 1, "unwield right")
		end
	end
	return bash
end
