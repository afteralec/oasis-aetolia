module(..., package.seeall)

--! todo: clean this shit up - table of contents
--! todo: clean out deprecated checks

function bal(bal, temp)
	if temp then
		if tmp.bals[bal] then return end
		tmp.bals[bal] = true
	else
		if o.bals[bal] then return end
		o.bals[bal] = true
		fs.release()
	end
end

function nobal(bal, temp)
	if temp then
		if not tmp.bals[bal] then return end
		tmp.bals[bal] = false
		local baltimer = "bal_" .. bal
		if timers[baltimer] then killTimer(timers[baltimer]) end
		timers[baltimer] = tempTimer(0.5, [[tmp.bals.]] .. bal .. [[ = true]])
	else
		if not o.bals[bal] then return end
		o.bals[bal] = false
		fs.release()
	end
end

--! @brief generic check for paused, asleep, stun, and unconscious
function act()
	return not (tmp.paused
		or affs.current.stun
		or affs.current.unconscious
		or affs.current.asleep)
end

--! Curing checks
function clot()
	return (not tmp.paused
		and not tmp.cockblocked
		and not affs.current.unconscious
		and not affs.current.asleep	
		and not affs.current.stun
		and not affs.current.haemophilia
		and not affs.current.blood_fever)
end

function compose()
	return not (tmp.paused
		or affs.current.stun
		or affs.current.unconscious
		or affs.current.asleep)
end

function concentrate()
	return not (tmp.paused
		or affs.current.stun
		or affs.current.unconscious
		or affs.current.asleep
		or affs.current.confusion)
end

function diag()
	return (tmp.bals.balance
		and tmp.bals.equilibrium)
		and not (tmp.paused
		or affs.current.stun
		or affs.current.unconscious
		or affs.current.asleep
		or affs.current.hypochondria)
end

function elixir()
	return not (tmp.paused
		or affs.current.indifference
		or affs.current.anorexia
		or affs.current.stun
		or affs.current.asleep
		or affs.current.unconscious)
end

function fitness()
	return o.bals.fitness
		and defs.lib.fitness.skill_cache
		and not (tmp.paused
		or affs.current.destroyed_throat
		or affs.current.stun
		or affs.current.asleep
		or affs.current.unconscious)
end

function herb()
	return not (tmp.paused
		or affs.current.indifference
		or affs.current.anorexia
		or affs.current.destroyed_throat
		or affs.current.stun
		or affs.current.asleep
		or affs.current.unconscious)
end

function moss()
	return not (tmp.paused
		or affs.current.indifference
		or affs.current.anorexia
		or affs.current.destroyed_throat
		or affs.current.stun
		or affs.current.asleep
		or affs.current.unconscious)
end

function pipe()
	return not (tmp.paused
		or affs.current.limp_veins
		or affs.current.asthma
		or affs.current.stun
		or affs.current.asleep
		or affs.current.unconscious)
end

function salve()
	return not (tmp.paused
		or affs.current.slickness
		or affs.current.sandrot
		or affs.current.stun
		or affs.current.asleep
		or affs.current.unconscious)
end

function shrug()
	return o.bals.shrug
		and _gmcp.has_skill("shrugging", "subterfuge")
		and not (tmp.paused
		or affs.current.stun
		or affs.current.asleep
		or affs.current.unconscious)
end

function stand()
	return o.traits.prone 
		and not (affs.current.unconscious 
		or affs.current.asleep 
		or affs.current.frozen 
		or affs.current.paralysis 
		or affs.current.left_leg_broken
		or affs.current.right_leg_broken
		or affs.current.stun
		or affs.current.writhe_impaled
		or affs.current.writhe_armpitlock
		or affs.current.writhe_webs
		or affs.current.writhe_bind
		or affs.current.writhe_vines
		or affs.current.mob_impaled
		or affs.current.writhe_thighlock
		or affs.current.writhe_necklock
		or affs.current.writhe_ropes
		or affs.current.writhe_transfix
		or tmp.paused)
end

function focus()
	local tobal = (affs.attempted.impatience
		and (affs.attempted.impatience ~= "renew"
			and affs.attempted.impatience ~= "tree"))
		and "to_" .. affs.attempted.impatience or nil
	return not tmp.paused
		and not (affs.current.impatience
			and not (tobal
				and timers[tobal]
				and timers[tobal] <= timers.to_focus
				and not (tobal == "to_herb" and (affs.current.anorexia or affs.current.indifference))))
		and not affs.current.stun
		and not affs.current.asleep
		and not affs.current.unconscious
		and not affs.current.blood_fever
end

--! todo: check writhes

function tree()
	local topare = (affs.attempted.paresis and (affs.attempted.paresis ~= "renew" and affs.attempted.paresis ~= "purge")) and "to_" .. affs.attempted.paresis or nil
	local topara = (affs.attempted.paralysis and (affs.attempted.paralysis ~= "renew" and affs.attempted.paralysis ~= "purge")) and "to_" .. affs.attempted.paralysis or nil
	local torab = (affs.attempted.right_arm_broken and (affs.attempted.right_arm_broken ~= "renew" and affs.attempted.right_arm_broken ~= "purge")) and "to_" .. affs.attempted.right_arm_broken or nil
	local tolab = (affs.attempted.left_arm_broken and (affs.attempted.left_arm_broken ~= "renew" and affs.attempted.left_arm_broken ~= "purge")) and "to_" .. affs.attempted.left_arm_broken or nil
	return not (tmp.paused
		or (affs.current.paresis
			and not (topare
				and timers[topare]
				and timers[topare] <= timers.to_tree))
		or (affs.current.paralysis
			and not (topara
				and timers[topara]
				and timers[topara] <= timers.to_tree))
		or affs.current.stun
		or affs.current.asleep
		or affs.current.shell_fetish
		or affs.current.sear
		or ((affs.current.left_arm_broken
		and affs.current.right_arm_broken)
			and not ((torab
				and timers[torab]
				and timers[torab] <= timers.to_tree)
			or (tolab
				and timers[tolab]
				and timers[tolab] <= timers.to_tree)))
		or affs.current.unconscious)
end

function renew()
	return o.bals.renew
		and not (tmp.paused
		or affs.current.stun
		or affs.current.asleep
		or affs.current.unconscious)
end

function purge()
	return _gmcp.has_skill("purge", "deathlore")
		and not cd.deathlore_purge
		and not (tmp.paused
			or affs.current.stun
			or affs.current.asleep
			or affs.current.unsconscious
			or affs.current.paralysis
			or (affs.current.right_arm_broken
				and affs.current.left_arm_broken)
			or o.traits.prone)
end

function rage()
	return (_gmcp.has_skill("rage", "battlefury")
		or _gmcp.has_skill("rage", "chivalry")
		or _gmcp.has_skill("rage", "shapeshifting"))
		and not (tmp.paused
		or affs.current.stun
		or affs.current.asleep
		or affs.current.unconscious)
end

function wake()
	return not (tmp.paused
		or affs.current.stun
		or affs.current.unconscious)
end

function writhe()
	return not (tmp.paused
		or affs.current.stun
		or affs.current.unconscious
		or affs.current.asleep)
		and not o.traits.writhing
end

--! defenses

function celerity()
	if o.stats.class == "shapeshifter" then
		return reqbal()
	else
		return reqbaleq()
	end
end

function illusion()
	return (not tmp.paused
		and not affs.current.unconscious
		and not affs.current.asleep
		and not affs.current.stun
		and (o.bals.primary_illusion
		or o.bals.secondary_illusion)
		and (tmp.bals.primary_illusion
		or tmp.bals.secondary_illusion))
		and true or false	
end

function elicit(el)
	local to_num = {
		fix = { "rafic" },
		link = { "jherza", "yi", "jhako" },
		constitution = { "jherza" },
		recognition = { "jherza", "jhako" },
		veil = { "rafic", "yi" }
	}

	for i, v in ipairs(el) do
		local def = "contemplate_" .. v
		defs.keep(def, false)
	end

	for i, v in ipairs(el) do
		local def = "contemplate_" .. v
		if not defs.active.def then
			return false
		end
	end
end

function contemplate()
	return (not tmp.paused
		and not affs.current.unconscious
		and not affs.current.asleep
		and not affs.current.stun
		and o.bals.contemplate
		and tmp.bals.contemplate)
end

function vitality()
	return (not tmp.paused
		and not affs.current.unconscious
		and not affs.current.asleep
		and not affs.current.stun
		and o.vitals.hp >= o.vitals.maxhp
		and o.vitals.mp >= o.vitals.maxmp
		and o.bals.vitality)
end

function sanguispect()
	return (not tmp.paused
		and not affs.current.unconscious
		and not affs.current.asleep
		and not affs.current.stun
		and o.bals.vitality)
end

function endgame_def()
	return not (defs.active.miasma
		or defs.active.warmth
		or defs.active.safeguard
		or defs.active.ward
		and (o.stats.race == "azudim"
		or o.stats.race == "idreth"
		or o.stats.race == "yeleni"))
end

function sip()
	return (not tmp.paused
		and not tmp.cockblocked
		and not affs.current.unconscious
		and not affs.current.asleep
		and not affs.current.stun
		and not affs.current.anorexia
		and not affs.current.indifference
		and not affs.current.destroyed_throat)
end

function affelixir()
	return (not tmp.paused
		and not tmp.cockblocked
		and not affs.current.unconscious
		and not affs.current.asleep
		and not affs.current.stun
		and not affs.current.anorexia
		and not affs.current.indifference
		and not affs.current.destroyed_throat)
end

function howl()
	return (not tmp.paused
		and not affs.current.unconscious
		and not affs.current.asleep
		and not affs.current.stun
		and o.bals.howl
		and tmp.bals.howl)
end

function fill()
	return (not tmp.paused
		and not tmp.cockblocked
		and not affs.current.unconscious
		and not affs.current.asleep	
		and not affs.current.stun
		and not affs.current.paralysis
		and not affs.current.writhe_impaled
		and not affs.current.write_transfix
		and not affs.current.writhe_armpitlock
		and not affs.current.writhe_webs
		and not affs.current.writhe_bind
		and not affs.current.writhe_vines
		and not affs.current.writhe_thighlock
		and not affs.current.writhe_necklock
		and not affs.current.writhe_ropes
		and ((o.bals.balance and o.bals.equilibrium) or #prompt.q < 10) and tmp.bals.balance and tmp.bals.equilibrium)
		and true or false
end

function wield()
	return (not tmp.paused
		and not tmp.cockblocked
		and not affs.current.unconscious
		and not affs.current.asleep	
		and not affs.current.stun
		and not affs.current.paralysis
		and not affs.current.writhe_impaled
		and not affs.current.write_transfix
		and not affs.current.writhe_armpitlock
		and not affs.current.writhe_webs
		and not affs.current.writhe_bind
		and not affs.current.writhe_vines
		and not affs.current.writhe_thighlock
		and not affs.current.writhe_necklock
		and not affs.current.writhe_ropes
		and not (affs.current.right_arm_broken and affs.current.left_arm_broken)
		and (o.bals.balance and o.bals.equilibrium))
end

function reqnone()
	return (not tmp.paused
		and not tmp.cockblocked
		and not affs.current.unconscious
		and not affs.current.asleep	
		and not affs.current.stun)
		and true or false
end

function reqbaleqprone()
	return (not tmp.paused
		and not tmp.cockblocked
		and not affs.current.unconscious
		and not affs.current.asleep	
		and not affs.current.stun
		and ((o.bals.balance and o.bals.equilibrium) or #prompt.q < 10) and tmp.bals.balance and tmp.bals.equilibrium)
		and true or false
end

function reqbaleq()
	return (not tmp.paused
		and not affs.current.unconscious
		and not affs.current.asleep	
		and not affs.current.stun
		and not o.traits.writhing
		and ((o.bals.balance and o.bals.equilibrium) or #prompt.q < 10) and tmp.bals.balance and tmp.bals.equilibrium)
		and true or false
end

function reqbal()
	return (not tmp.paused
		and not tmp.cockblocked
		and not affs.current.unconscious
		and not affs.current.asleep	
		and not affs.current.stun
		and not o.traits.writhing
		and ((not o.traits.prone)
			or (table.contains(prompt.q, "stand")
			or table.contains(prompt.q, "kipup")))
		and ((o.bals.balance) or #prompt.q < 10) and tmp.bals.balance)
		and true or false
end

function reqeq()
	return (not tmp.paused
		and not tmp.cockblocked
		and not affs.current.unconscious
		and not affs.current.asleep	
		and not affs.current.stun
		and not o.traits.writhing
		and ((not o.traits.prone)
			or (table.contains(prompt.q, "stand")
			or table.contains(prompt.q, "kipup")))
		and ((o.bals.equilibrium) or #prompt.q < 10) and tmp.bals.equilibrium)
		and true or false
end

function shadow()
	return (not tmp.paused
		and not affs.current.unconscious
		and not affs.current.asleep
		and not affs.current.stun
		and not o.traits.writhing
		and (o.bals.primary_illusion
		and o.bals.secondary_illusion)
		and (tmp.bals.primary_illusion
		and tmp.bals.secondary_illusion))
end


--! special handling

function mana(num, mod)
	local mod = mod/100 or 0
	local manadiff = math.floor(o.vitals.mp-(o.vitals.maxmp*(affs.sets.mfloor+mod)))
	if manadiff < 0 then manadiff = 0 end
	return (num <= manadiff)
end

function outcache()
	return not tmp.paused
		and not affs.current.unconscious
		and not affs.current.asleep	
		and not affs.current.stun
		and not affs.current.writhe_thighlock
		and not affs.current.writhe_transfix
		and not affs.current.writhe_impaled
		and not affs.current.writhe_armpitlock
		and not affs.current.writhe_necklock
		and not affs.current.writhe_webs
		and not affs.current.writhe_bind
		and not affs.current.mob_impaled
		and not affs.current.writhe_ropes
end