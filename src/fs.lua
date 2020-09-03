module(..., package.seeall)

-------------------------------------------------------

--! @file
--! @brief Failsafe timing module for Oasis Curing System for Aetolia.

--! @copyright Copyright 2014 Alec DuBois, all rights reserved.

--! http://oasis.interimreality.com/

--! Commented in standardized format Doxygen::Lua. 

-------------------------------------------------------

timers = {}		--! stores timers for use by failsafe functions

--! @brief Activates a specified limiter for a specified time.
--! @param key Accepts a string as the limiter to activate.
--! @param time Accepts a number as the time to keep the limiter active.
function on(key, time)
	fs[key] = fs[key] or nil

	timers[key] = timers[key] or {nil, time or 1}
	if timers[key][1] then
		killTimer(timers[key][1])
	end
	fs[key] = true
	timers[key][1] = tempTimer(time or timers[key][2], [[fs.off("]] .. key .. [[")]])
end

--! @brief De-activates the specified limiter.
--! @param key Accepts a string as the limiter to de-activate.
function off(key)
	if not fs[key] then return end
	if not timers[key] then return end
	if timers[key][1] then
		killTimer(fs.timers[key][1])
	end
	fs[key] = nil

	if o.debug then
		e.debug("Failsafe killed:" .. key, true, false)
	end
end

function oncd(key, time)
	local timer = "cd_" .. key
	fs[key] = fs[key] or nil

	timers[timer] = timers[timer] or {nil, time or 1}
	if timers[timer][1] then
		killTimer(timers[timer][1])
	end
	cd[key] = true
	timers[timer][1] = tempTimer(time or timers[timer][2], [[fs.offcd("]] .. key .. [[")]])
	fs.release()
end

function offcd(key)
	local timer = "cd_" .. key
	if not cd[key] then return end
	if not timers[timer] then return end
	if timers[timer][1] then
		killTimer(fs.timers[timer][1])
	end
	cd[key] = nil
	fs.release()
end

--! @brief Returned true if specified limiter is active.
--! @param key Accepts a string as the limiter to check.
function check(key)
	return fs[key] and true or false
end

function release(a)
	fs.off("queue")
	fs.off("herb")
	fs.off("pipe")
	fs.off("salve")
	fs.off("tree")
	fs.off("focus")
	fs.off("elixir")
	fs.off("moss")
	fs.off("deathlore_purge")

	if o.debug then e.debug("All failsafes killed.", true, false) end
end