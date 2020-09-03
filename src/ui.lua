module(..., package.seeall)

-- Declare UI-specific namespaces

local hx = {}	--! local table for hex-returning functions
local sb = {}	--! local table for status bar strings

toggle = {}

settings = {
	font = package.config:sub(1,1) == "/" and "Purisa" or "Segoe Print",
	font_size = "12px",
	label_font = package.config:sub(1,1) == "/" and "Monospace" or "Consolas",
	mono_font = package.config:sub(1,1) == "/" and "Monospace" or "Consolas",
}

sets = {
	display_tar = false
}

chat = {}
tabs_to_blink = {}
config = {
	status_bar = "prompt"
}
tabs = {}
windows = {}
config.active_colours = {}
config.inactive_colours = {}
use = true
config.timestamp = "HH:mm:ss"
config.timestamp_custom_colour = false
config.timestamp_fg = "red"
config.timestamp_bg = "blue"

config.channels = {
	"All",
	"City",
	"Guild",
	"Clans",
	"Tells",
	"Misc",
	"Combat",
}

config.all_tab = "All"
config.blink = true
config.blink_time = 3
config.blink_from_all = false
config.font_size = 8
config.preserve_background = false
config.gag = false
config.lines = 15
local x, y = getMainWindowSize()
local cwidth = math.floor((x*0.29))
local fwidth, fheight = calcFontSize(config.font_size)
config.width = math.floor(cwidth/fwidth) 

config.active_colours = {
	r = 0,
	g = 55,
	b = 0,
}

config.inactive_colours = {
	r = 60,
	g = 60,
	b = 60,
}

config.window_colours = {
	r = 0,
	g = 0,
	b = 0,
}

config.active_tab_text = "purple"
config.inactive_tab_text = "white"
current_tab = config.all_tab

elem_type = {
	"map",
	"afflictions",
	"wounds",
	"room_items",
	"player_tracking"
}

function set_interface_dynamics()
	local b_dynamic
	if sets.display_tar then
		b_dynamic = 0.08
	else
		b_dynamic = 0.04
	end
	local x, y = getMainWindowSize()
	local l = math.round(x * 0.01)
	local t = math.round(y * 0.04)
	local r = math.round(x * 0.52)
	local b = math.round(y * b_dynamic)
	setBorderLeft(l)
	setBorderTop(t)
	setBorderRight(0)
	setBorderBottom(b)

	local f = {
		["3841"] = "24px",
		["2561"] = "18px",
		["1921"] = "16px",
		["1601"] = "13px",
		["1361"] = "12px",
		["801"]  = "10px",
		["641"]  = "8px"
	}

	local i = 1
	for r, p in pairs(f) do
		if l > tonumber(r) then
			i = i + 1
		else
			settings.font_size = p
			break
		end
	end
end

function draw_containers()
	local on_toggles = {
		"tar"
	}

	for _, disp in ipairs(on_toggles) do
		local toggle = "display_" .. disp
		if not sets[toggle] and containers[disp] then
			containers[disp]:hide()
		end
	end

	containers.main = Geyser.Container:new({
		name = "containers.main",
		x = "0%", y = "0%",
		width = "100%", height = "100%"
	})

	--[[containers.clickers = Geyser.Container:new({
		name = "containers.clickers",
		x = "0%", y = "4%",
		width = "5%", height = "46%"
	}, containers.main)]]

	--[[containers.toggles = Geyser.Container:new({
		name = "containers.toggles",
		x = "0%", y = "50%",
		width = "5%", height = "46%"
	}, containers.main)]]

	containers.header = Geyser.Container:new({
		name = "containers.header",
		x = "0%", y = "0%",
		width = "70%", height = "4%"
	}, containers.main)

	containers.status = Geyser.Container:new({
		name = "containers.status",
		x = "0%", y = "96%",
		width = "100%", height = "4%"
	}, containers.main)

	containers.chat = Geyser.Container:new({
		name = "containers.chat",
		x = "70%", y = "0%",
		width = "29%", height = "40%"
	}, containers.main)

	containers.util_toggle = Geyser.Container:new({
		name = "containers.util_toggle",
		x = "70%", y = "46%",
		width = "29%", height = "4%"
	}, containers.main)

	containers.util = Geyser.Container:new({
		name = "containers.map",
		x = "70%", y = "51%",
		width = "29%", height = "45%"
	}, containers.main)

	if sets.display_tar then
		containers.tar = Geyser.Container:new({
			name = "containers.tar",
			x = "0%", y = "92%",
			width = "100%", height = "4%"
		}, containers.main)
	end
end

function draw_labels()
	if o.stats.unread_msgs then tmp.messages = o.stats.unread_msgs end
	if (o.paused and tmp.paused) then o.status = "Paused" elseif (tmp.cockblocked) then o.status = "LOCKED" elseif (tmp.paused and not o.paused) then o.status = "Channeling" else o.status = "Active" end
	labels.header = Geyser.Label:new({
		name = "labels.header",
		x = "0%", y = "0%",
		width = "100%", height = "100%",
		fgColor = "dark_orchid",
		message = [[<p style="font-size: ]] .. ui.settings.font_size .. [[; font-family: ']] .. ui.settings.font .. [[';"><b><font color="brown">> Oasis for Aetolia v<font color="#00B2EE">]] .. o.version ..[[ <font color="brown">  |   Name:<font color="#00B2EE"> ]] .. "..." .. [[<font color="brown">   |  Class:<font color="#00B2EE"> ]] .. "..." .. [[</font></p>]]
	}, containers.header)

	labels.status = Geyser.Label:new({
		name = "labels.status",
		x = "0%", y = "0%",
		width = "100%", height = "100%",
		fgColor = "dark_orchid",
		callback = "ui.update_status_bar",
		message = [[<p style="font-size: ]] .. ui.settings.font_size .. [[; font-family: ']] .. ui.settings.font .. [[';"><b><font color="brown">* Target:<font color="#00B2EE"> ]] .. tmp.target:title() .. [[ <font color="brown">  |  Status:<font color="#00B2EE"> ]] .. o.status .. [[ <font color="brown"> ]] .. tmp.extra_info .. [[ <font color="brown"> |  Gold:<font color="#00B2EE"> ]] .. tmp.gold .. [[ <font color="brown"> |  Messages:<font color="#00B2EE"> ]] .. tmp.messages .. [[ <font color="brown"> |  Mounted:<font color="#00B2EE"> ]] .. tmp.mounted .. [[ <font color="brown"> |  Wielded:<font color="#00B2EE"> ]] .. tmp.wielded .. [[<font color="brown"> |  Current Clan:<font color="#00B2EE"> ]] .. prm.clan_channel .. [[</font></p>]]
	}, containers.status)

	if sets.display_tar then
		labels.tar = Geyser.Label:new({
			name = "labels.tar",
			x = "0%", y = "0%",
			width = "100%", height = "100%",
			fgColor = "dark_orchid",
			callback = "ui.update_status_bar",
			message = [[<p style="font-size: ]] .. ui.settings.font_size .. [[; font-family: ']] .. ui.settings.font .. [[';"><b><font color="brown">* Target:<font color="#00B2EE"> ]] .. tmp.target:title() .. [[ <font color="brown">  |  Status:<font color="#00B2EE"> ]] .. o.status .. [[ <font color="brown"> ]] .. tmp.extra_info .. [[ <font color="brown"> |  Gold:<font color="#00B2EE"> ]] .. tmp.gold .. [[ <font color="brown"> |  Messages:<font color="#00B2EE"> ]] .. tmp.messages .. [[ <font color="brown"> |  Mounted:<font color="#00B2EE"> ]] .. tmp.mounted .. [[ <font color="brown"> |  Wielded:<font color="#00B2EE"> ]] .. tmp.wielded .. [[<font color="brown"> |  Current Clan:<font color="#00B2EE"> ]] .. prm.clan_channel .. [[</font></p>]]
		}, containers.tar)
	end

	labels.util_toggle = Geyser.Label:new({
		name = "labels.util_toggle",
		x = "0%", y = "0%",
		width = "100%", height = "100%",
		fgColor = "dark_orchid",
		callback = "ui.cycle_util_element",
		message = [[<p style="font-size: ]] .. ui.settings.font_size .. [[; font-family: ']] .. ui.settings.font .. [[';"><b><center><font color="brown">]] .. tmp.current_toggle .. [[</b></center></font></p>]]
	}, containers.util_toggle)

	labels.afflictions = Geyser.Label:new({
		name = "labels.afflictions",
		x = "0%", y = "0%",
		width = "100%", height = "100%",
		callback = "ui.clear_aff_window",
	}, containers.util)

	labels.wounds = Geyser.Label:new({
		name = "labels.wounds",
		x = "0%", y = "0%",
		width = "100%", height = "100%"
	}, containers.util)

	labels.player_tracking = Geyser.Label:new({
		name = "labels.player_tracking",
		x = "0%", y = "0%",
		width = "100%", height = "100%"
	}, containers.util)

	labels.room_items = Geyser.Label:new({
		name = "labels.room_items",
		x = "0%", y = "0%",
		width = "100%", height = "100%"
	}, containers.util)
end

function reset()
	local x, y = getMainWindowSize()
	local h = (y * 0.04)
	tab_box = Geyser.HBox:new({
		x = 0,
		y = 0,
		width = "100%",
		height = h,
		name = "tab_box",
	}, containers.chat)
end

function draw_chat()
	reset()
	local r = config.inactive_colours.r
	local g = config.inactive_colours.g
	local b = config.inactive_colours.b
	local winr = config.window_colours.r
	local wing = config.window_colours.g
	local winb = config.window_colours.b
	local x, y = getMainWindowSize()
	local h = (y * 0.04)

	for i, tab in ipairs(config.channels) do
		tabs[tab] = Geyser.Label:new({
			name = string.format("tab%s", tab),
		}, tab_box)

		local out = [[<p style="font-size: 13px; font-family: ']] .. ui.settings.font .. [[';"><b><center><font color="#D0D0D0">]] .. tab .. [[</b></center></p>]]
		tabs[tab]:echo(out)
		tabs[tab]:setColor(r, g, b)
		tabs[tab]:setStyleSheet([[
			QLabel{
				background-color: rgb(25, 25, 25);
				border-width: 1px;
				border-style: solid;
				border-color: rgb(0, 0, 0);
				text-align: center;
			}

			QLabel::hover{
				background-color: rgb(25, 25, 25);
				border-width: 1px;
				border-style: solid;
				border-color: rgb(100, 178, 238);
				text-align: center;
			}
		]])
		tabs[tab]:setClickCallback("ui.chat_switch", tab)

		windows[tab] = Geyser.MiniConsole:new({
			x = 0,
			y = 35,
			height = "100%",
			width = "100%",
			name = string.format("win%s", tab),
		}, containers.chat)

		windows[tab]:setFontSize(config.font_size)
		windows[tab]:setColor(winr, wing, winb)
		windows[tab]:setWrap(config.width) -- problem is here
		windows[tab]:hide()
	end

	local showme = config.Alltab or config.channels[1]
	chat_switch(showme)

	if config.blink and not blink_timer_on then
		blink()
	end
end

function chat_switch(chan)
	local r = config.inactive_colours.r
	local g = config.inactive_colours.g
	local b = config.inactive_colours.b
	local newr = config.active_colours.r
	local newg = config.active_colours.g
	local newb = config.active_colours.b
	local oldchat = current_tab
	if current_tab ~= chan then
		windows[oldchat]:hide()
		tabs[oldchat]:setColor(r, g, b)
		tabs[oldchat]:setStyleSheet([[
			QLabel{
				background-color: rgb(25, 25, 25);
				border-width: 1px;
				border-style: solid;
				border-color: rgb(0, 0, 0);
				text-align: center;
			}

			QLabel::hover{
				background-color: rgb(25, 25, 25);
				border-width: 1px;
				border-style: solid;
				border-color: rgb(0, 0, 0);
				text-align: center;
			}
		]])

		local out = [[<p style="font-size: 13px; font-family: ']] .. ui.settings.font .. [[';"><b><center><font color="#D0D0D0">]] .. oldchat .. [[</b></center></p>]]
		tabs[oldchat]:echo(out)
		if config.blink and tabs_to_blink[chan] then
			tabs_to_blink[chan] = nil
		end
		if config.blink and chan == config.all_tab then
			tabs_to_blink = {}
		end
	end

	tabs[chan]:setColor(newr, newg, newb)
	tabs[chan]:setStyleSheet([[
		QLabel{
			background-color: rgb(0, 178, 238);
			border-width: 1px;
			border-style: solid;
			border-color: rgb(0, 0, 0);
			text-align: center;
		}

		QLabel::hover{
			background-color: rgb(0, 178, 238);
			border-width: 1px;
			border-style: solid;
			border-color: rgb(0, 0, 0);
			text-align: center;
		}
	]])

	local out = [[<p style="font-size: 13px; font-family: ']] .. ui.settings.font .. [[';"><b><center><font color="LightCyan">]] .. chan .. [[</b></center></p>]]
	tabs[chan]:echo(out)
	windows[chan]:show()
	current_tab = chan
end

function capture_comms()
	local channels = {
		["congregation"] = "Misc",
		["newbie"] = "Misc",
		["market"] = "Misc",
		["ct"] = "City",
		["gt"] = "Guild",
		["gts"] = "Guild",
		["gnt"] = "Guild",
		["wt"] = "Combat",
		["web"] = "Combat",
		["tell"] = "Tells",
		["says"] = "Misc",
		["clt"] = "Clans",
		["ot"] = "Misc",
		["guidet"] = "Misc"
	}

	local ch = gmcp.Comm.Channel.Start

	for c, t in pairs(channels) do
		if ch:find(c) then
			tmp.last_chan = t
			break
		end
	end

	enableTrigger("comms capture")
end

function append(self, chan)
	local r = config.window_colours.r
	local g = config.window_colours.g
	local b = config.window_colours.b
	selectCurrentLine()
	local ofr, ofg, ofb = getFgColor()
	local obr, obg, obb = getBgColor()
	if config.preserve_background then
		setBgColor(r, g, b)
	end
	copy()
	if config.timestamp then
 		local timestamp = getTime(true, config.timestamp)
 		local tsfg = {}
 		local tsbg = {}
 		local color_leader = ""
 		if config.timestamp_custom_colour then
			if type(config.timestamp_fg) == "string" then
				tsfg = color_table[config.timestamp_fg]
			else
				tsfg = config.timestamp_fg
			end
      
			if type(config.timestamp_bg) == "string" then
				tsbg = color_table[config.timestamp_bg]
			else
				tsbg = config.timestamp_bg
			end
  
			color_leader = string.format("<%s,%s,%s:%s,%s,%s>", tsfg[1], tsfg[2], tsfg[3], tsbg[1], tsbg[2], tsbg[3])
		else
			color_leader = string.format("<%s,%s,%s:%s,%s,%s>", ofr, ofg, ofb, obr, obg, obb)
		end

		local fullstamp = string.format("%s%s", color_leader, timestamp)
		windows[chan]:decho(fullstamp)
		windows[chan]:echo(" ")
		if config.all_tab then 
			windows[config.all_tab]:decho(fullstamp)
			windows[config.all_tab]:echo(" ")
		end
	end
 
	windows[chan]:append()
	if config.gag then 
		deleteLine()
		tempLineTrigger(1, 1, [[if isPrompt() then deleteLine() end]])
	end

	if config.all_tab then appendBuffer(string.format("win%s", config.all_tab)) end
	if config.blink and chan ~= current_tab then 
		if (config.all_tab == current_tab) and not config.blink_on_all then
			return
		else
			tabs_to_blink[chan] = true
		end
	end
end

function draw_map()
	local types = {
		"afflictions",
		"wounds",
		"room_items",
		"player_tracking"
	}

	for _, v in ipairs(types) do
		labels[v]:hide()
	end

	map = Geyser.Mapper:new({
		name = "map",
		x = 0, y = 0,
		width = "100%",
		height = "100%",
	}, containers.util)
end

function cycle_util_element()
	cycle_utility_label()
end

function cycle_utility_label(name)
	if name then
		for _, v in ipairs(elem_type) do
			if v ~= "map" then
				labels[v]:hide()
			end
		end
		map:hide()

		if name == "map" then
			map:show()
		else
			labels[name]:show()
			raiseEvent("utility label toggled", name)
		end
	else
		for _, v in ipairs(elem_type) do
			if v ~= "map" then
				labels[v]:hide()
			end
			map:hide()
		end
		local i = table.remove(elem_type, 1)
		table.insert(elem_type, i)

		if elem_type[1] == "map" then
			labels.util_toggle:echo([[<p style="font-size: ]] .. settings.font_size .. [[; font-family: ']] .. settings.font .. [[';"><b><center><font color="brown">]] .. elem_type[1]:title() .. ((gmcp.Room and gmcp.Room.Info and gmcp.Room.Info.area) and " - (" .. gmcp.Room.Info.area:title() .. ")" or "No area data available") .. [[</b></center></font></p>]])		
			map:show()
			raiseEvent("util toggled", "map")
		else
			labels.util_toggle:echo([[<p style="font-size: ]] .. ui.settings.font_size .. [[; font-family: ']] .. ui.settings.font .. [[';"><b><center><font color="brown">]] .. elem_type[1]:gsub("_", " "):title() .. [[</b></center></font></p>]])		
			labels[elem_type[1]]:show()
			raiseEvent("util toggled", elem_type[1])
		end
	end
end

function hx.resource_level(r, mr)
	local perc = math.round(100*(r/mr))

	if perc > 75 then
		return "#65A954"
	elseif perc <= 75 and perc > 50 then
		return "#f9ea57"
	elseif perc <= 50 and perc > 35 then
		return "#fb9b09"
	elseif perc < 35 then
		return "#f60101"
	end
end

function sb.prompt()
	local p = {
		c = defs.active.cloak and true or false,
		s = defs.active.fangbarrier and true or false,
		d = defs.active.deafness and true or false,
		b = defs.active.blindness and true or false,

		e = o.bals.equilibrium and true or false,
		b = o.bals.balance and true or false,
		l = o.bals.left_arm and true or false,
		r = o.bals.right_arm and true or false
	}

	local d = {}
	for _, field in ipairs({"c", "s", "d", "b"}) do
		d[field] = p[field] and field or ""
	end

	local b = {}
	for _, field in ipairs({"e", "b", "l", "r"}) do
		b[field] = p[field] and field or "-"
	end

	local ws = (p.c or p.s or p.d or p.b) and " " or ""

	local pbracket = d.c .. d.s .. d.d .. d.b .. " " .. b.e .. b.b .. b.l .. b.r

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

	local curebals = h .. s .. p .. " " .. e .. m .. a .. " " .. f .. t .. r

	--! todo: color code this
	local self_affs = {}
	for k, v in pairs(affs.current) do
		table.insert(self_affs, k)
	end
	if #self_affs > 0 then 
		self_affs = table.concat(self_affs, ", ") 
	else
		self_affs = ""
	end

	return [[<p style="font-size: ]] .. ui.settings.font_size .. [[; font-family: ']] .. ui.settings.font .. [[';"><b><font color="brown">H:<font color="]] .. hx.resource_level(o.vitals.hp, o.vitals.maxhp) .. [["> ]] .. tostring(math.round(100*(o.vitals.hp/o.vitals.maxhp))) .. [[% <font color="brown">M:<font color="]] .. hx.resource_level(o.vitals.mp, o.vitals.maxmp) .. [["> ]] .. tostring(math.round(100*(o.vitals.mp/o.vitals.maxmp))) .. [[% <font color="brown">E:<font color="]] .. hx.resource_level(o.vitals.ep, o.vitals.maxep) .. [["> ]] .. tostring(math.round(100*(o.vitals.ep/o.vitals.maxep))) .. [[% <font color = "brown">W:<font color="]] .. hx.resource_level(o.vitals.wp, o.vitals.maxwp) .. [["> ]] .. tostring(math.round(100*(o.vitals.wp/o.vitals.maxwp))) .. [[% <font color="brown"> [<font color="#00B2EE">]] .. curebals .. [[<font color="brown">] [<font color="#00B2EE">]] .. pbracket .. [[<font color="brown">] Affs:<font color="#00B2EE"> ]] .. self_affs .. [[</font></p>]]
end

function update_status_bar()
	if (o.paused and tmp.paused) then o.status = "Paused" elseif (tmp.cockblocked) then o.status = "LOCKED" elseif (tmp.paused and not o.paused) then o.status = "Channeling" else o.status = "Active" end
	if o.stats.unread_msgs then tmp.messages = o.stats.unread_msgs end

	local sbtype = config.status_bar
	
	--local out = [[<p style="font-size: ]] .. ui.settings.font_size .. [[; font-family: ']] .. ui.settings.font .. [[';"><b><font color="brown">* Target:<font color="#00B2EE"> ]] .. tmp.target:title() .. [[ <font color="brown">  |  Status:<font color="#00B2EE"> ]] .. o.status .. [[ <font color="brown"> |  H:<font color="]] .. hx.resource_level(o.vitals.hp, o.vitals.maxhp) .. [["> ]] .. tostring(math.round(100*(o.vitals.hp/o.vitals.maxhp))) .. [[% <font color="brown">M:<font color="]] .. hx.resource_level(o.vitals.mp, o.vitals.maxmp) .. [["> ]] .. tostring(math.round(100*(o.vitals.mp/o.vitals.maxmp))) .. [[% <font color="brown">E:<font color="]] .. hx.resource_level(o.vitals.ep, o.vitals.maxep) .. [["> ]] .. tostring(math.round(100*(o.vitals.ep/o.vitals.maxep))) .. [[% <font color = "brown">W:<font color="]] .. hx.resource_level(o.vitals.wp, o.vitals.maxwp) .. [["> ]] .. tostring(math.round(100*(o.vitals.wp/o.vitals.maxwp))) .. [[% <font color = "brown"> |  Mounted:<font color="#00B2EE"> ]] .. tmp.mounted .. [[</font></p>]]
	local out = sb[sbtype]()
	labels.status:echo(out)
end

function define_stylesheets()
	_G.css.default = [[
		QLabel{
			background-color: rgb(25, 25, 25);
			border-width: 1px;
			border-style: solid;
			border-color: rgb(0, 0, 0);
			text-align: center;
		}

		QLabel::hover{
			background-color: rgb(25, 25, 25);
			border-width: 1px;
			border-style: solid;
			border-color: rgb(0, 178, 238);
			text-align: center;
		}
	]]
	_G.css.sbar = [[
		QLabel{
			background-color: rgb(0, 0, 0);
			border-width: 1px;
			border-style: solid;
			border-color: rgb(0, 0, 0);
			text-align: center;
		}

		QLabel::hover{
			background-color: rgb(0, 0, 0);
			border-width: 1px;
			border-style: solid;
			border-color: rgb(0, 178, 238);
			text-align: center;
		}
	]]
end

function set_stylesheets()
	ui.labels.header:setStyleSheet(css.default)
	ui.labels.status:setStyleSheet(css.sbar)
	if sets.display_tar then ui.labels.tar:setStyleSheet(css.sbar) end
	ui.labels.util_toggle:setStyleSheet(css.default)

	local elems = {
		"room_items",
		"player_tracking",
		"afflictions",
		"wounds"
	}

	for _, v in ipairs(elems) do
		labels[v]:setStyleSheet([[
			background-color: black;
			border-radius: 12px;
			border-width: 2px;
			border-style: solid;
			border-color: rgb(25, 25, 25);
		]])
	end
end

function blink()
	if blink_id then killTimer(blink_id) end
	if not config.blink then 
		blink_timer_on = false
		return 
	end

	for tab, _ in pairs(tabs_to_blink) do
		tabs[tab]:flash()
	end
  
	blink_id = tempTimer(config.blink_time, function () blink() end)
end

function cecho(self, chat, message)
	local alltab = config.all_tab
	local blink = config.blink
	cecho(string.format("win%s", chat), message)
	if alltab and chat ~= alltab then 
		cecho(string.format("win%s", alltab), message)
	end
	if blink and chat ~= current_tab then
		if (alltab == current_tab) and not config.blink_on_all then
			return
		else
			tabs_to_blink[chat] = true
		end
	end
end

function decho(self, chat, message)
	local alltab = config.all_tab
	local blink = config.blink
	decho(string.format("win%s", chat), message)
	if alltab and chat ~= alltab then 
		decho(string.format("win%s", alltab), message)
	end
	if blink and chat ~= current_tab then
		if (alltab == current_tab) and not config.blink_on_all then
			return
		else
			tabs_to_blink[chat] = true
		end
	end
end

function hecho(self, chat, message)
	local alltab = config.all_tab
	local blink = config.blink
	hecho(string.format("win%s", chat), message)
	if alltab and chat ~= alltab then 
		hecho(string.format("win%s", alltab), message)
	end
	if blink and chat ~= current_tab then
		if (alltab == current_tab) and not config.blink_on_all then
			return
		else
			tabs_to_blink[chat] = true
		end
	end
end

function echo(self, chat, message)
	local alltab = config.all_tab
	local blink = config.blink
	echo(string.format("win%s", chat), message)
	if alltab and chat ~= alltab then 
		echo(string.format("win%s", alltab), message)
	end
	if blink and chat ~= current_tab then
		if (alltab == current_tab) and not config.blink_on_all then
			return
		else
			tabs_to_blink[chat] = true
		end
	end
end

function prompter(title, message, onyes, onno)
	boxen = { dec = {} }
	local x, y = getMainWindowSize()
	local w = (x / 3)
	local h = (y / 6)
	local bw = (x / 24)
	local bh = (y / 24)

	boxen.dec["yes"] = Geyser.Label:new({
		name="yesbox",
		message="<center>Yes</center>",
		x = (w / 2 - w / 2),
		y = (h / 2 + h / 2),
		width = (w / 2),
		height = bh,
		callback = onyes
	})
        
	boxen.dec["no"] = Geyser.Label:new({
		name = "nobox",
		message = "<center>No</center>",
		x = w / 2,
		y = h / 2 + h / 2,
		width = w / 2,
		height = bh,
		callback = onno
	})

	boxen.dec["frame"] = Geyser.Label:new({
		name = "promptDecision",
		message = "<center>" .. message .. "</center>",
		x = (w / 2 - w / 2),
		y = (h / 2 - h / 2),
		width = w,
		height = h
	})
end

function destroy()
	boxen.dec["frame"]:hide()
	boxen.dec["yes"]:hide()
    boxen.dec["no"]:hide()
end

function onDecYes(self, args)
	display('yes')
        self:destroy()
end

function onDecNo(self, args)
	display('no')
        self:destroy()
end

function combat_echo(self, text, colour, width)
	if not text then
		text = tostring(text)
		if not text then
			s:error("Invalid argument #1 to combat_echo(): String expected.")
			return
		end
	end

  text = string.gsub(text, "%a", "%1 "):sub(1, -2)
  text = "+  +  +  " .. text .. "  +  +  +"
	local width = width or 80
	if #text + 4 > width then
		width = #text + 4
	end

	local lindent = math.floor(((width - #text) / 2) - 1)
	local rindent = math.ceil(((width - #text) / 2) - 1)

	local colours = {
		red     = "<black:red>",
		blue    = "<navajo_white:midnight_blue>",
		green   = "<navajo_white:dark_green>",
		yellow  = "<black:gold>",
		purple  = "<navajo_white:DarkViolet>",
		orange  = "<black:dark_orange>",
	}

	local selection = colours[colour] or colours["yellow"]

	_G.cecho("\n" .. selection .. "+" .. string.rep("-", (width - 2)) .. "+")
	_G.cecho("\n" .. selection .. "|" .. string.rep(" ", lindent) .. text .. string.rep(" ", rindent) .. "|")
	_G.cecho("\n" .. selection .. "+" .. string.rep("-", (width - 2)) .. "+")
end

function oecho(self, txt, colour, pleft)
	local colour = colour or "orange"
 	local pleft = pleft or 70
 	local pright = 80 - pleft
 	local left = ui.create_line_gradient(true, pleft - string.len(txt)) .. "[ "
 	local middle = "<" .. colour .. ">" .. txt
 	local right = " |caaaaaa]" .. create_line_gradient(false, pright)
 	_G.hecho("\n" .. left)
 	_G.cecho(middle)
 	_G.hecho(right)
end

function visual_alert(self, text, duration)
	local width, height = getMainWindowSize()
	local strLen = text:len()
	local label = randomString(8, "%l%d")

	tmp.labels[label] = {label = label, text = text, duration = (duration or 3)}
	createLabel(label, 0, 0, 0, 0, 1)
	setLabelStyleSheet(label, [[
		background-color: rgba(255, 255, 255, 100);
		border: 5px double rgb(178, 34, 34);
		border-radius: 12px;
		color: #ff99ff;
		font-size: 12px;
		font-family: Monospace;
		font-style: normal;
		padding: 3px;
	]])
                
	resizeWindow(label, strLen * 25, 70)
	local tabLen, offset = table.count(tmp.labels), 100
	local topPos = (height / 2.0) - (tabLen * 75)
	if topPos > 0 then
		moveWindow(label, (width - (strLen * 18)) / 3, topPos)
	end

	_G.echo(label, [[<p style="font-size:35px"><b><center><font color="yellow"> ]] .. text .. [[</font></center></b></p>]])
	if topPos > 0 then
		showWindow(label)
		table.insert(tmp.displayedLabels, label)
	else
		hideWindow(label)
		table.insert(tmp.labelQueue, label)
	end

	resetFormat()
end

function create_line_gradient(left, width)
	local hex = left and "1" or "a"
	local width = width or 10
	local gradient = ""
	local length = 0
     
	while length < width do
		gradient = gradient .. "|c" .. string.rep(hex, 6) .. "-"
		if left and hex == "9" then
			hex = "a"
		elseif left and hex ~= "a" then
			hex = tostring(tonumber(hex) + 1)
		elseif not left and width - length < 10 and hex == "a" then
			hex = "9"
		elseif not left and width - length < 10 and hex ~= "1" then
			hex = tostring(tonumber(hex) - 1)
		end

		length = length + 1
	end
     
	return gradient
end

function viswarn_loop()
	tmp.labelQueue = tmp.labelQueue or {}
	tmp.displayedLabels = tmp.displayedLabels or {}

	if not tmp.labels then return end
	local toHide = {}
	local needRedraw = false

	for index, label in pairs(tmp.displayedLabels) do
		tmp.labels[label].duration = tmp.labels[label].duration - 0.5
		if tmp.labels[label].duration <= 0 then
			toHide[label] = true
			needRedraw = true
		end
	end
	for i = 1, #(tmp.displayedLabels) do
		if not tmp.displayedLabels[i] then break end
		if toHide[tmp.displayedLabels[i]] then
			hideWindow(tmp.displayedLabels[i])
			tmp.labels[tmp.displayedLabels[i]] = nil
			table.remove(tmp.displayedLabels, i)
			i = i - 1
		end
	end --Note: This loop is because Lua doesn't have true iterators. 
		--This is a hack. Do not remove. I know it is WTF

	local width, height = getMainWindowSize()
	if needRedraw or (#(tmp.displayedLabels) == 0 and #(tmp.labelQueue) > 0) then
		local brk = false
		local iter = 1
		while not brk do
			local topPos = (height / 1.5) - ((iter) * 75)
			if tmp.displayedLabels[iter] then
				local label = tmp.displayedLabels[iter]
				moveWindow(label, (width - (#(tmp.labels[label].text) * 25)) / 3, topPos)
			elseif topPos >= 0 and #(tmp.labelQueue) > 0 then
				local label = table.remove(tmp.labelQueue, 1)
				table.insert(tmp.displayedLabels, label)
				moveWindow(label, (width - (#(tmp.labels[label].text) * 25)) / 3, topPos)
				showWindow(label)
			else
				brk = true
				break
			end
			iter = iter + 1
		end
	end
end

function create()
	-- Now let's do what we need...
	set_interface_dynamics()
	draw_containers()
	--draw_toggles_vbox()
	--draw_clickers_vbox()
	--draw_toggle_icons()
	draw_labels()
	--draw_clickers_icons()
	define_stylesheets()
	set_stylesheets()
	draw_map()
	draw_chat()
end

create()




































































function cycle_theme()
	local i = table.remove(tmp.themes, 1)
	table.insert(tmp.themes, i)
	refresh()
end

function refresh()
end

toggle.state = {
	["visualalerts"] = false,
	["genrunner"] = false,
	["autobasher"] = false,
	["clanannounce"] = false,
	["combatmode"] = false,
	["paused"] = false,
	["webfollowing"] = false,
	["automass"] = false,
	["autorebound"] = false
}

function draw_toggle_icons()
	local togs = {
		["visualalerts"] = "Visual Alerts",
		["genrunner"] = "Genrunner",
		["autobasher"] = "Auto Bashing",
		["webannounce"] = "Web Announce",
		["combatmode"] = "Combat Mode",
		["paused"] = "Pause",
		["automass"] = "Auto Massing",
		["webfollowing"] = "Web Following",
		["autorebound"] = "Auto Rebounding"
	}

	for short, long in pairs(togs) do
		vboxes.tparent[short] = Geyser.Label:new({
      		name = string.format("vboxes.tparent.%s", short),
    	}, vboxes.tparent)
	end

	for short, long in pairs(togs) do
		vboxes.tparent[short]:setStyleSheet([[
			QLabel{
				background-color: rgb(25, 25, 25);
				border-color: rgb(0, 0, 0);	
				border-width: 1px;
				border-style: solid;
				color: rgb(0, 179, 238);
				qproperty-wordWrap: true;
				qproperty-alignment: 'AlignCenter';
			}

			QLabel::hover{
				background-color: rgb(25, 25, 25);
				border-color: rgb(0, 178, 238);	
				border-width: 1px;
				border-style: solid;
				color: rgb(25, 25, 25);
				qproperty-wordWrap: true;
				qproperty-alignment: 'AlignCenter';
			}		
		]])

		local out = [[<p style="font-size: ]] .. ui.settings.font_size .. [[; font-family: 'Constantia';"><b><font color="#FFFFFF">]] .. long:gsub(" ", [[<br>]]) .. [[</font></p>]]
		vboxes.tparent[short]:echo(out)
		vboxes.tparent[short]:setClickCallback("ui.toggle_icon", short)
	end
end

function draw_clickers_icons()
	local togs = {
		["user_label_1"] = "UserLabel",
		["user_label_2"] = "UserLabel",
		["user_label_3"] = "UserLabel",
		["user_label_4"] = "UserLabel",
		["user_label_5"] = "UserLabel",
		["user_label_6"] = "UserLabel",
		["user_label_7"] = "UserLabel",
		["user_label_8"] = "UserLabel",
		["user_label_9"] = "UserLabel"
	}

	for short, long in pairs(togs) do
		vboxes.cparent[short] = Geyser.Label:new({
      		name = string.format("vboxes.cparent.%s", short),
    	}, vboxes.cparent)
	end

	for short, long in pairs(togs) do
		vboxes.cparent[short]:setStyleSheet([[
			QLabel{
				background-color: rgb(25, 25, 25);
				border-color: rgb(0, 0, 0);	
				border-width: 1px;
				border-style: solid;
				color: rgb(0, 179, 238);
				qproperty-wordWrap: true;
				qproperty-alignment: 'AlignCenter';
			}

			QLabel::hover{
				background-color: rgb(25, 25, 25);
				border-color: rgb(0, 178, 238);	
				border-width: 1px;
				border-style: solid;
				color: rgb(25, 25, 25);
				qproperty-wordWrap: true;
				qproperty-alignment: 'AlignCenter';
			}		
		]])

		local out = [[<p style="font-size: ]] .. ui.settings.font_size .. [[; font-family: 'Constantia';"><b><font color="#FFFFFF">]] .. long:gsub(" ", [[<br>]]) .. [[</font></p>]]
		vboxes.cparent[short]:echo(out)
	end
end

--[[function draw_toggles_vbox()
	vboxes.tparent = Geyser.VBox:new({
    	name = "vboxes.tparent",
    	x = "0%", y = "0%",
    	width = "100%", height = "100%"
  	}, containers.toggles)
end]]

--[[function draw_clickers_vbox()
	vboxes.cparent = Geyser.VBox:new({
    	name = "vboxes.cparent",
    	x = "0%", y = "0%",
    	width = "100%", height = "100%"
  	}, containers.clickers)
end]]



function toggle_icon(name)
	toggle.state[name] = not toggle.state[name]
	if toggle.state[name] ~= false then
		vboxes.tparent[name]:setStyleSheet([[
			QLabel{
				background-color: rgb(0, 178, 238); 
				border-color: rgb(0, 178, 238);	
				border-width: 1px;
				border-style: solid;
				qproperty-wordWrap: true;
				qproperty-alignment: 'AlignCenter';
			}

			QLabel::hover{
				background-color: rgb(0, 178, 238);
				border-color: rgb(238, 255, 238);
				border-width: 1px;
				border-style: solid;
				qproperty-wordWrap: true;
				qproperty-alignment: 'AlignCenter';
			}
		]])
		
	else
		vboxes.tparent[name]:setStyleSheet([[
			QLabel{
				background-color: rgb(25, 25, 25); 
				border-color: rgb(0, 0, 0);	
				border-width: 1px;
				border-style: solid;
				qproperty-wordWrap: true;
				qproperty-alignment: 'AlignCenter';
			}

			QLabel::hover{
				background-color: rgb(25, 25, 25);
				border-color: rgb(0, 178, 238);	
				border-width: 1px;
				border-style: solid;
				qproperty-wordWrap: true;
				qproperty-alignment: 'AlignCenter';
			}
		]])
	end

	raiseEvent("toggle changestate", name)
end

function toggle_changestate(self, name)
	if name == "paused" then
		expandAlias("pp")
	elseif name == "webannounce" then
		if toggle.state[name] then
			expandAlias("wc on")
		else
			expandAlias("wc off")
		end
	elseif name == "webfollowing" then
		if toggle.state[name] then
			e.echo("Enable web following for whom?")
			printCmdLine("wl on ")
		else
			expandAlias("wl off")
		end
	elseif name == "autorebound" then
		if toggle.state[name] then
			expandAlias("kdef rebounding")
			send(" ")
		else
			expandAlias("nodef rebounding")
			send(" ")
		end
	elseif name == "automass" then
		if toggle.state[name] then
			expandAlias("kdef density")
			send(" ")
		else
			expandAlias("nodef density")
			send(" ")
		end
	elseif name == "combatmode" then
		if toggle.state[name] then
			e.echo("Combat mode enabled. Go forth and conquer!")
		else
			e.echo("Combat mode disabled.")
		end
	elseif name == "visualalerts" then
		if toggle.state[name] then
			e.echo("Visual alerts will now be displayed.")
		else
			e.echo("Visual alerts will no longer be displayed.")
		end
	end
end

function is_mob(thing)
	local t = {}
	local s = thing:match("[A-Za-z,' ]+")
	if table.contains(t, s) then
		return true
	else
		return false
	end
end

function is_important(thing)
	if thing:find("an elder moonhart tree") then
		return true
	else
		return false
	end
end

function update_room_items()
	local things = {}
	local mobs = {}
	local important = {}
	local other = {}
	if tmp.elem_type[1] == "room_items" then
		_gmcp:consolidate_room_items()
		for item, id in pairs(tmp.sorted_room_items) do
			local numStr = "(" .. #id .. ")"
			local len = math.round(getMainWindowSize() / 47)
			local name = truncate2(item, numStr, len)
			table.insert(things, name)
			if is_mob(name) then
				table.insert(mobs, name)
			elseif is_important(name) then
				table.insert(important, name)
			else
				table.insert(other, name)
			end
		end
		local out = [[<p align="center" style="font-size: ]] .. ui.settings.font_size .. [[; font-family: ']] .. ui.settings.mono_font .. [['">]] .. "<span style=\"color:OrangeRed\">" .. table.concat(mobs, "<br>") .. "<br></span><span style=\"color:gold\">" .. table.concat(important, "<br>") .. "<br></span><span style=\"color:PapayaWhip\">" .. table.concat(other or others, "<br>") .. [[</span></p><br>]]
		labels.room_items:echo(out)
	else
		return
	end
end

function update_affs(self, e, aff)
	local exceptions = {
		"loki",
		"weakvoid",
		"check_focus",
		"asleep",
		"idiocy"
	}

	if e == "oasis gained aff" then
		if not table.contains(tmp.selfaffs, aff) and not table.contains(exceptions, aff) then
			table.insert(tmp.selfaffs, aff)
		end

	elseif e == "oasis cured aff" then
		if table.contains(tmp.selfaffs, aff) then
			for i, v in ipairs(tmp.selfaffs) do
				if aff == v then
					table.remove(tmp.selfaffs, i)
				end
			end
		end

	elseif e == "target gained aff" then
		if not table.contains(tmp.enemyaffs, aff) then
			table.insert(tmp.enemyaffs, aff)
		end

	elseif e == "target cured aff" then
		if table.contains(tmp.enemyaffs, aff) then
			for i, v in ipairs(tmp.enemyaffs) do
				if aff == v then
					table.remove(tmp.enemyaffs, i)
				end
			end
		end
	end

	--tmp.enemyaffs = {} -- To remove one enemy tracking is done.
	--tmp.lockaffs = {} -- To remove one enemy tracking is done.
	update_aff_window()
end

function update_aff_window()
	local out = [[
		<table bordercolor = "#ffffff" align="center">
		<tr>
		<td colspan="30">
		<div align="center">
		<span id = "self_affs" style="color:white;font-size: 18px;align: center">
		SELF:<br />
		</span>
		<span style="color:yellow">]]..table.concat(tmp.selfaffs, "<br /> ")..[[
		<br />	</span></td>
		<td colspan="30">
		<div align="center">
		<span id = "enemy_affs" style="color:white;font-size: 18px;">
		ENEMY:<br />
		</span>
		<span style="color:yellow">]]..table.concat(tmp.enemyaffs, "<br /> ")..[[
		<br />	</span>
		<td colspan="30">
		<div align="center">
		<span id = "lock_affs" style="color:white;font-size: 18px;">
		LOCK:<br /></span>
		<span style="color:yellow">]]..table.concat(tmp.lockaffs, "<br /> ")..[[
		</div>
		</tr>
		</span>
		</table>
]]

	labels.afflictions:echo(out)
end

function clear_aff_window()
	tmp.selfaffs = {}
	tmp.enemyaffs = {}
	tmp.lockaffs = {}
	update_aff_window()
end