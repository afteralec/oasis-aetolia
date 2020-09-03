-------------------------------------------------------

--! @file
--! @brief Core system file for Oasis Curing System for Aetolia.

--! @copyright Copyright 2014 Alec DuBois, all rights reserved.

--! http://oasis.interimreality.com/

--! Commented in standardized format Doxygen::Lua. 

-------------------------------------------------------

--! author
author = "Alec DuBois"

--! contact
email = "support@interimreality.com"

--! core namespace
o = {
	state = false,
	debug = false,
	config_sep = "\\",
	loaded = {},
	paused = false,
	status = "Active",
	version = "Beta 6.3.3",
	bals = {
		avoidance = true,
		chimera = true,
		contemplate = true,
		fitness = true,
		furor = true,
		howl = true,
		mindburrow = true,
		primary_illusion = true,
		scour = true,
		secondary_illusion = true,
		shadow = true,
		shed = true,
		shrug = true,
		spiritwrack = true,
		vitality = true,
		warhounds = true
	},
	traits = {},
	stats = {
		last = {}
	},
	vitals = {
		last = {}
	},
	skills = {}

}

mode = {}				--! temporary namespace for future management

css = {}				--! used to store UI css stylesheets
containers = {}			--! namespace for GUI containers
labels = {}				--! namespace for GUI labels
hboxes = {}				--! used for UI construction
vboxes = {}				--! used for UI construction

check = {}				--! used in hidden affliction detection

cd = {}					--! used to store cooldowns
timers = {}				--! global namespace for timer storage
stopwatch = {}			--! global namespace for stopwatches

--! global function namespaces
channel = {}
logger = {}

--! used to store permanent data
prm = {
	arti_density = false,
	clan_channel = "Unread"
}

--! temporary data namespace
-- TODO CLEAN THIS SHIT UP
tmp = {
	--! temporary balance table, used to parse attempted actions
	bals = {
		affelixir = true,
		balance = true,
		contemplate = true,
		equilibrium = true,
		fitness = true,
		howl = true,
		primary_illusion = true,
		secondary_illusion = true,
		shadow = true,
		spiritwrack = true,
		vitality = true
	},
	
	gold = 0,
	target = "Nothing",
	messages = 0,
	labels = {},
	roomitems = {},
	invitems = {},
	did_wield = {},
	selfaffs = {},
	enemyaffs = {},
	lockaffs = {},
	mounted = "No",
	wielded = "None",
	extra_info = "",
	got_gmcp_status = false,

	rift = {},

	combat_announce = true,
	current_toggle = "Map",
	setchan = "wt",

	herbs = {"ash","goldenseal","kelp","lobelia","ginseng","bellwort","bloodroot","moss","hawthorn","bayberry"},

	inv_herbs = {

	"prickly ash bark",
	"goldenseal roots?",
	"pieces? of kelp",
	"lobelia seeds?",
	"ginseng roots?",
	"bellwort flowers?",
	"bloodroot lea(f|ves)",
	"irid moss",
	"hawthorn berr(ies|y)",
	"bayberry bark"

	},

	slices = {"bladder","liver","eyeball","testis","ovary","castorite","lung","kidney","heart","stomach"},

	inv_slices = {

	"bladder slice",
	"liver slice",
	"eyeball slice",
	"testis slice",
	"ovary slice",
	"castorite gland slice",
	"lung slice",
	"kidney slice",
	"heart slice",
	"stomach slice"

	},

	themes = {

	"blue",
	"red",
	"green",
	"yellow",
	"purple",
	"white",
	"orange"

	}

}

--! global namespace for grabbing sent actions
sent = {}

--! @brief Pauses or unpauses the system.
--! @param arg Accepts string "un" to unpause the system.
function pause_unpause(arg)
	if arg == "un" then
		o.paused = false
		tmp.paused = false
		tmp.channel = nil
		e.echo("Unpaused.")
		send("qeb")
		send("qe")
		send("qb")
	else
		o.paused = true
		tmp.paused = true
		e.echo("Paused.")
		send("qeb")
		send("qe")
		send("qb")
	end
	ui.update_status_bar()
	fs.release()
end

--! @brief Toggles system paused/unpaused.
function pause_unpause_toggle()
	if o.paused then
		o.paused = false
		tmp.paused = false
		e.echo("Unpaused.")
		send("qeb")
		send("qe")
		send("qb")
	else
		o.paused = true
		tmp.paused = true
		e.echo("Paused.")
		send("qeb")
		send("qe")
		send("qb")
	end
	ui.update_status_bar()
	fs.release()
end

--! @brief Toggles system flag debug.
function debug_toggle()
	if o.debug then
		o.debug = false
		e.echo("Debugging deactivated.")
		send(" ")
	else
		o.debug = true
		e.echo("Debugging activated.")
		send(" ")
	end
end

function set_sep(sep)

	o.config_sep = sep
	e.info("Config separator will now be: " .. sep, true, true)
	e.info("Attempting to reset command separator...", false, true)
	send("config separator off")
	send("config separator " .. o.config_sep)

end

function set_configs()
	e.info("Attempting to reset command separator...", false, true)
	send("config separator off")
	send("config separator " .. o.config_sep)

	local configs = {

		"config affliction_view on",
		"config balance_taken on",
		"config combatmessages on",
		"config damage_change on",
		"config grabcorpses on",
		"config ignoreoffbalcures on",
		"config pagelength 250",
		"config random_fail off",
		"config simple_diag on",
		"config tellsprefix on",
		"config viewtitles off",
		"config wrapwidth 0",

	}

	e.info("Attempting to configure Aetolia-side settings...", false, true)

	for _, config in ipairs(configs) do
		send(config)
	end
end

function set_target(tar, stat, call)
	fs.release()
	local char = tar:title()
	local t = cdb.chars[char]
	tmp.enemyaffs = {}
	tmp.lockaffs = {}
	tmp.target = tar:lower()

	if stat == "u" then stat = "undead" end
	if stat == "l" then stat = "living" end

	e.echo("You are now targeting <navajo_white:firebrick>" .. tmp.target:title() .. "<grey:black>.", true, false)

	if stat then
		cdb.update(char, "status", stat)
	elseif cdb.chars[char] and cdb.chars[char].status and cdb.chars[char].status ~= "null" then
		e.echo("Target read as: <navajo_white:firebrick>" .. t.status:title() .. "<slate_grey:black>.", true, false)
	end

	if ks and ks.sets.reset_target then cdb.reset(tar, true, true, true) end
	if not tmp.paused and tmp.web_calling and (call == nil or call == true) then
		send("wt Target: " .. tmp.target:title())
		send(" ")
	end
end

--! @brief Displays an author-set header for a table.
--! @param title Accepts a string as the title displayed in the header.
function display_header(title)
	local time = getTime(true, "hh:mma - dd/MM/yyyy")
	local tlen = time:len() + 6
	local llen = title:len() + 6
	local replen = 105 - (tlen + llen)
	cecho("\n<light_slate_grey>o<grey>" .. string.rep("-", 5) .. " <deep_sky_blue>(<steel_blue> " .. title:title() .. " <deep_sky_blue>) " .. string.rep("<grey>-", replen) .. " <goldenrod>(<dark_khaki> " .. time .. " <goldenrod>) <grey>" .. string.rep("-", 5) .. "<light_slate_grey>o\n\n")
end

--! @brief Displays a single formatted entry.
--! @param field Accepts a string as the field to be displayed.
--! @param entry Accepts a value as the entry to be displayed.
function display_entry(field, entry, lnb, lna)
	if lnb then echo("\n") end 
	cecho("<steel_blue>" .. string.rep(" ", 55-#field) .. field:title() .. " <deep_sky_blue>: ")
	echo("     ")
	cecho("<navajo_white>" .. tostring(entry):title())
	if lna then echo("\n") end
end

--! @brief Displays an author-set footer for a table.
function display_footer()
	cecho("\n<light_slate_grey>o<grey>" .. string.rep("-", 5) .. " <goldenrod>(<dark_khaki> oasis-" .. o.version .. " <goldenrod>)<grey> " .. string.rep("-", 88) .. "<light_slate_grey>o\n")
end

--! @brief Unknown.
function ostime()
	local t = getTime()

	return t.msec
	+ t.sec * 1000
	+ t.min * 1000 * 60
	+ t.hour * 1000 * 60 * 60
end

--! todo: set channel timer based on bal regained
function channel.pause(name)
	if o.paused and tmp.paused then return end
	if o.paused then
		tmp.paused = true
		return
	else
		tmp.paused = false
	end
	if not tmp.channel then return end

local interrupt = {

	behead = {
		"paralysis",
		"paresis",
		"right_arm_broken",
		"left_arm_broken",
		"prone",
		"asleep",
		"disrupted",
		"blackout",
	},

	brainsmash = {
		"paralysis",
		"paresis",
		"right_arm_broken",
		"left_arm_broken",
		"prone",
		"asleep",
		"disrupted",
		"blackout",
	},

	chasm = {
		"paralysis",
		"paresis",
		"right_arm_broken",
		"left_arm_broken",
		"prone",
		"asleep",
		"disrupted",
		"blackout",
	},

	conservation = {},

	earthenform = {},

	kai_trance = {},

	shatter = {
		"paralysis",
		"paresis",
		"right_arm_broken",
		"left_arm_broken",
		"prone",
		"asleep",
		"blackout",	
	},

	control = {
		"asleep",
		"blackout",
	},

	erect = {
		"asleep",
		"blackout",
	},

	judgement = {
		"paralysis",
		"paresis",
		"right_arm_broken",
		"left_arm_broken",
		"prone",
		"asleep",
		"disrupted",
		"blackout",
	},

	phased = {},

	spheres = {}

}

	local int = interrupt[name]

	if not int then int = interrupt.shatter end

	tmp.paused = true

	--! todo: code parse for second tick of behead and shatter to keep going with one arm broken
	for i,v in ipairs(int) do
		if (affs[v]
			or o.traits[v]) then
			tmp.paused = false
			tmp.channel = nil
			e.warn("<dark_orange>Channel interrupted.", true, false)
			break
		end
	end
end

function channel.attempting(name)
	if timers.temp_pause then killTimer(timers.temp_pause) end
	if timers.sent_channel then killTimer(timers.sent_channel) end
	if timers.temp_channel then killTimer(timers.temp_channel) end

	sent.channel = true
	tmp.paused = true
	tmp.channel = name:lower()
	e.warn("<dark_orange>Attempting channel <navajo_white>\'" .. name .. "\'<dark_orange>\.", true, false)

	timers.temp_pause = tempTimer(0.5, [[tmp.paused = false]])
	timers.sent_channel = tempTimer(3.5, [[sent.channel = nil]])
	timers.temp_channel = tempTimer(3.5, [[tmp.channel = nil]])
end

function channel.started()
	if not sent.channel then return end

	tmp.paused = true
	e.warn("<dark_orange>Channel <navajo_white>\'" .. tmp.channel .. "\'<dark_orange> in progress.", true, false)
	--ui:update_status_bar()

	if timers.temp_pause then killTimer(timers.temp_pause) end
	if timers.sent_channel then killTimer(timers.sent_channel) end
	if timers.temp_channel then killTimer(timers.temp_channel) end

	timers.temp_pause = tempTimer(6.5, [[tmp.paused = false]])
	timers.sent_channel = tempTimer(6.5, [[tmp.sent_channel = nil]])
	timers.temp_channel = tempTimer(6.5, [[tmp.channel = nil]])
end

function channel.interrupted()
	if tmp.paused then
		e.warn("<dark_orange>Channel <navajo_white>\'" .. tmp.channel .. "\'<dark_orange> interrupted.", true, false) 
	end

	sent.channel = false
	tmp.paused = false
	tmp.channel = nil
	--ui:update_status_bar()

	if timers.temp_pause then killTimer(timers.temp_pause) end
	if timers.temp_channel then killTimer(timers.temp_channel) end
	if timers.sent_channel then killTimer(timers.sent_channel) end
end

function channel.fulfilled()
	if tmp.paused then
		e.warn("<dark_orange>Channel <navajo_white>\'" .. tmp.channel .. "\'<dark_orange> fulfilled.", true, false) 
	end

	sent.channel = false
	tmp.paused = false
	tmp.channel = nil
	--ui:update_status_bar()

	if timers.temp_pause then killTimer(timers.temp_pause) end
	if timers.temp_channel then killTimer(timers.temp_channel) end
	if timers.sent_channel then killTimer(timers.sent_channel) end
end

--! @brief Concatenates a table of string values into a , and sentence.
--! @param tbl Accepts a table as the table to perform the function on.
--! @return The resulting string list.
function table.concand(tbl)
	if #tbl == 0 or tbl == nil then return "Empty" end

	return #tbl == 1
		and tbl[1]
		or table.concat(tbl, ", ", 1, #tbl - 1) .. " and " ..tbl[#tbl]
end

--! @brief logger.startlogging()
  function logger.startlogging()
    logger.recording_stopwatch = createStopWatch()
    startStopWatch(logger.recording_stopwatch)

    logger.current_data = {[[

<html>
    <head>
    <style>
            /* http://meyerweb.com/eric/tools/css/reset/
               v2.0 | 20110126
               License: none (public domain)
            */
            html, body, div, span, applet, object, iframe,
            h1, h2, h3, h4, h5, h6, p, blockquote, pre,
            a, abbr, acronym, address, big, cite, code,
            del, dfn, em, img, ins, kbd, q, s, samp,
            small, strike, strong, sub, sup, tt, var,
            b, u, i, center,
            dl, dt, dd, ol, ul, li,
            fieldset, form, label, legend,
            table, caption, tbody, tfoot, thead, tr, th, td,
            article, aside, canvas, details, embed,
            figure, figcaption, footer, header, hgroup,
            menu, nav, output, ruby, section, summary,
            time, mark, audio, video {
                    margin: 0;
                    padding: 0;
                    border: 0;
                    font-size: 100%;
                    font: inherit;
                    vertical-align: baseline;
            }
            /* HTML5 display-role reset for older browsers */
            article, aside, details, figcaption, figure,
            footer, header, hgroup, menu, nav, section {
                    display: block;
            }
            body {
                    line-height: 1;
            }
            ol, ul {
                    list-style: none;
            }
            blockquote, q {
                    quotes: none;
            }
            blockquote:before, blockquote:after,
            q:before, q:after {
                    content: '';
                    content: none;
            }
            table {
                    border-collapse: collapse;
                    border-spacing: 0;
            }
            html, body {
                    background: #000;
                    color: silver;
                    margin: 10px;
                    font-size: 13px;
                    font-family: 'Consolas',sans-serif;
            }
            p, h2, pre {
                    padding: 1px;
                    margin: -1px;
                    clear: both;
            }
            A:link, A:visited, A:active {
                    color: #327CE3;
                    text-decoration: none;
            }
            A:hover {
                    color: #fff;
            }
            h1 {
                    font-size: 30px;
                    margin: 0;
                    padding: 0;
            }
            h2 {color: #327CE3;}
            td {vertical-align: top;}
            .clear {clear: both; height: 5px;}
            .break {line-height: 100%; margin: 0; padding:0px; padding: 1px 0;}
            .tnc_bg_default {background: #111;}
            .tnc_default {color: silver;}
            .tnc_bright .tnc_default {color: #fff;}
            .tnc_normal {font-weight:normal;}
            .tnc_bold {font-weight: bold;}
            .tnc_inverse {color: black; background: white;}
            .tnc_black {color: black;}
            .tnc_red {color: #800000;}
            .tnc_green {color: #00b300;}
            .tnc_yellow {color: #808000;}
            .tnc_blue {color: #000080;}
            .tnc_magenta {color: #800080;}
            .tnc_cyan {color: #008080;}
            .tnc_white {color: silver;}
            .tnc_bright .tnc_black {color: #464646;}
            .tnc_bright .tnc_red {color: #ff0000;}
            .tnc_bright .tnc_green {color: #00ff00;}
            .tnc_bright .tnc_yellow {color: #ffff00;}
            .tnc_bright .tnc_blue {color: #0000ff;}
            .tnc_bright .tnc_magenta {color: #ff00ff;}
            .tnc_bright .tnc_cyan {color: #00ffff;}
            .tnc_bright .tnc_white {color: white;}
            .tnc_bg_black {background-color: black;}
            .tnc_bg_red {background-color: #800000;}
            .tnc_bg_green {background-color: #00b300;}
            .tnc_bg_yellow {background-color: #808000;}
            .tnc_bg_blue {background-color: #000080;}
            .tnc_bg_magenta {background-color: #ff00ff;}
            .tnc_bg_cyan {background-color: #008080;}
            .tnc_bg_white {background-color: silver;}
            #options {
                position:fixed;
                top:0;
                left: 0;
                background: #242424;
                border-bottom: 1px solid #464646;
                width: 100%;
                height: 50px;
            }
            #current_time, #save {
                float:right;
                min-width: 150px;
                height: 25px;
                background: #000;
                border: 1px solid #464646;
                margin: 5px;
                padding: 5px;
                padding-top: 10px;
                font-size: 24px;
                text-align: center;
            }
            #buttons {
                margin-left: 10px;
                margin-top: 15px;
            }
            #log {
                padding-top: 55px;
                word-wrap: break-word;
                white-space: pre-wrap;
                font-family: monospace;
            }
            #log p {
              padding: 0px;
              margin: 0px;
              line-height: 120%;
              clear: both;
         }
    </style>
    </head>
    <body>
<script type="text/javascript">
    var log;
    var first_offset = 0;
    var last_index = 0;
    var timer;
    var display_time = function () {
        document.getElementById("current_time").style.color = "white";
        document.getElementById("current_time").innerHTML = parseFloat(log[last_index].offset/1000) + " sec.";
    }
    var pause = function() {
        clearTimeout(timer);
        display_time();
        document.getElementById("current_time").style.color = "red";
    }
    var rewind = function (time)
    {
        current_time = parseInt(log[last_index].offset);
        var target_time = current_time - time;
        var target_index = -1;
        for (var i=0; i<last_index; i++)
        {
            if (parseInt(log[i].offset) <= target_time)
            {
                target_index = i;
            }
        }
        if (target_index == -1)
            target_index = log.length - 1;
        for (var j=target_index; j<log.length; j++)
        {
            remove_segment(j);
        }
        last_index = target_index;
        if (last_index < 0)
            last_index = 0;
        pause();
    }
    var fast_forward = function (time) {
        current_time = parseInt(log[last_index].offset);
        var target_time = current_time + time;
        var target_index = -1;
        for (var i=last_index; i<log.length; i++)
        {
            if (parseInt(log[i].offset) <= target_time)
            {
                target_index = i;
            }
        }
        if (target_index == -1)
            target_index = log.length - 1;
        for (var j=last_index; j<=target_index; j++)
        {
            display_segment(j);
            last_index = j;
        }
        last_index++;
        if (last_index >= log.length)
            last_index = 0;
        pause();
    };
    var replay = function () {
        if (last_index == 0)
            document.getElementById("log").innerHTML = "";
        display_time();
        display_segment(last_index);
        if (last_index < log.length)
            timer = setTimeout("replay()", (log[last_index].offset-log[last_index-1].offset));
        else
            last_index = 0;
    };
    var remove_segment = function (i, no_scroll) {
        var elem = document.getElementById(log[i].offset);
        if (elem)
            elem.parentNode.removeChild(elem);
        if (!no_scroll || no_scroll !== true)
            window.scrollTo(0, document.body.scrollHeight);
    };
    var display_segment = function (i, no_scroll) {
        var elem = document.createElement("div");
        elem.setAttribute("id", log[i].offset);
        elem.innerHTML = "<div>";
        offset = log[i].offset;
        while (i < log.length && log[i].offset == offset)
        {
            elem.innerHTML += "<div>" + log[i].message + "</div>";
            i++;
        }
        last_index = i;
        elem.innerHTML += "</div>";
        document.getElementById("log").appendChild(elem);
        if (!no_scroll || no_scroll !== true)
            window.scrollTo(0, document.body.scrollHeight);
    };
    var build_log_array = function ()
    {
        log = [];
        var elems = getElementsByClassName(document, "log");
        for (i in elems)
        {
    if (log[log.length-1] && log[log.length-1].offset == elems[i].getAttribute("id"))
    {
      log[log.length-1].message += elems[i].innerHTML;
    } else {
      log[log.length] = {offset : elems[i].getAttribute("id"), message: "<div>" + elems[i].innerHTML + "</div>"};
    }
        }
        first_offset = log[0].offset;
    }
    var display_all = function () {
        setTimeout(function () {
            for (var i = 0; i < log.length; i++)
                display_segment(i, true);
        }, 0);
    }
    function add_event(obj, evType, fn){
     if (obj.addEventListener){
       obj.addEventListener(evType, fn, false);
       return true;
     } else if (obj.attachEvent){
       var r = obj.attachEvent("on"+evType, fn);
       return r;
     } else {
       return false;
     }
    }
    function getElementsByClassName(node,classname) {
      if (node.getElementsByClassName) { // use native implementation if available
        return node.getElementsByClassName(classname);
      } else {
        return (function getElementsByClass(searchClass,node) {
            if ( node == null )
              node = document;
            var classElements = [],
                els = node.getElementsByTagName("*"),
                elsLen = els.length,
                pattern = new RegExp("(^|\s)"+searchClass+"(\s|$)"), i, j;
            for (i = 0, j = 0; i < elsLen; i++) {
              if ( pattern.test(els[i].className) ) {
                  classElements[j] = els[i];
                  j++;
              }
            }
            return classElements;
        })(classname, node);
      }
    }
    add_event(window, "load", function () {build_log_array()});
</script>
<div id="options">
    <div id="current_time"></div>
    <div id="buttons">
        <input type="button" onclick="replay()" value="Play Log" />
        <input type="button" onclick="pause()" value="Pause"/>
        <input type="button" onclick="rewind(10000)" value="<<" title="Rewind 10 Seconds"/>
        <input type="button" onclick="rewind(5000)" value="<" title="Rewind 5 Seconds"/>
        <input type="button" onclick="fast_forward(5000)" value=">" title="Fast Forward 5 Seconds"/>
        <input type="button" onclick="fast_forward(10000)" value=">>" title="Fast Forward 10 Seconds"/>
        <p id="save">Press <strong>CTRL-S</strong> to save the log on your computer</p>
    </div>
</div>
<div id="log" class="tnc_default">
]]}

    logger.inbetween = {}

    --enableTrigger("Capture each line")
    --enableTrigger("Record on the prompt")

    if logger.trig then killTrigger(logger.trig) end
    logger.trig = tempRegexTrigger("^", "logger.recordline()")

    e.echo("Logging initiated. Use 'stoplog' to stop.")
  end

--! @brief logger.recordcurrentline()
function logger.recordcurrentline()
  local line_num, cur_line = getLineNumber(), getCurrentLine()

  local output, tc = {}, 1
  local index = 0
  local r, g, b = 0, 0, 0
  local br, bg, bb = 0, 0, 0
  local cbr, cbg, cbb
  local cr, cg, cb
  local tc = 1

  while index < #cur_line do
    index = index + 1

    if moveCursor("main", index, line_num) and selectString(cur_line:sub(index), 1) then
      r,g,b = getFgColor()
      br,bg,bb = getBgColor()
      if cr ~= r or cg ~= g or cb ~= b or cbr ~= br or cbg ~= bg or cbb ~= bb then
        cr,cg,cb = r,g,b
        cbr,cbg,cbb = br,bg,bb
        if tc == 1 then
          output[tc] = string.format("<span style=\'color: rgb(%d,%d,%d);background: rgb(%d,%d,%d);'>%s", r,g,b,br,bg,bb, cur_line:sub(index, index))
        else
          output[tc] = string.format("</span><span style=\'color: rgb(%d,%d,%d);background: rgb(%d,%d,%d);'>%s", r,g,b,br,bg,bb, cur_line:sub(index, index))
        end

        tc = tc +1
      else
        output[tc] = cur_line:sub(index, index)
        tc = tc +1
      end
      cur_line:sub(index, index)
    end
  end

  output[#output+1] = "</span>"
  return table.concat(output)
end

--! @brief logger.stoplogging()
--! @param title Accepts a string as a title for the log.
function logger.stoplogging(lstr)
  local s = string.sub(getMudletHomeDir(), 1, 1) == "/" and "/" or "\\"
  local oasis_dir = getMudletHomeDir() .. s .. "oasis" .. s
  local log_dir = oasis_dir .. s .. "logs" .. s

  disableTrigger("Capture each line")
  disableTrigger("Record on the prompt")

  logger.current_data[#logger.current_data+1] = [[</div>
  </body>
  </html>]]

  local log_title = lstr or getTime(true, "hh_mm_ss")

  local lf = log_dir .. "log_" .. log_title:gsub(" ", "_") .. ".html"
  local fh,err = io.open(lf, "w")

  if err then
    e.error("Error on opening file for writing ("..lf.."): "..err)
    return
  end

  local conversions = {
  }


  local cd = table.concat(logger.current_data)

  for from, to in pairs(conversions) do
    cd = string.gsub(cd, from, to)
  end

  fh:write(cd)
  fh:close()

  collectgarbage("collect")
  e.echo("Logging ended.")
  openUrl(lf)

  logger.current_data = nil
  logger.inbetween = nil
  if logger.trig then killTrigger(logger.trig) end
  logger.trig = nil
  collectgarbage("collect")
end

--! @brief logger.recordline()
function logger.recordline()
  logger.inbetween[#logger.inbetween+1] = logger.recordcurrentline()

  if isPrompt() then
    for i = 1, #logger.inbetween do
      logger.current_data[#logger.current_data+1] = string.format([[<div id="%d" class="log tnc_default"><p>%s</p></div>]], getStopWatchTime(logger.recording_stopwatch)*1000, string.gsub(logger.inbetween[i], '\n', '<br/>'))
    end

    logger.inbetween = {}
  end
end

--! @brief Accurately rounds a function.
--! @param num Any number.
--! @param idp The number of decimal places to round to.
--! @return The rounded result
function math.round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

--! @brief Counts the number of entries in a table.
--! @param source The table to be counted.
--! @return The resulting integer.
function table.count(source)
	if type(source) ~= "table" then return end

	local count = 0
	for _ in pairs(source) do
		count = count + 1
	end

	return count
end

--! @brief Removes a key from a specified table.
--! @param source The table to remove the key from.
--! @param key The key to be removed.
--! @return The resulting table.
function table.removekey(source, key)
	local element = source[key]
	source[key] = nil
	return element
end

--! @brief Removes a key from a specified non-indexed table.
--! @param source The table to rmemove the key from.
--! @param key The key to be removed.
--! @return The resulting table.
function table.iremovekey(source, key)
	if type(source) ~= "table" then return end

	local ktype = type(key)

	if ktype == "string" then
		for i, v in ipairs(source) do
			if v == key then
				table.remove(source, i)
				break
			end
		end
	elseif ktype == "table" then
		for _, entry in ipairs(key) do
			for i, v in ipairs(source) do
				if v == entry then
					table.remove(source, i)
					break
				end
			end
		end
	end

	return source
end

--! @brief Copies a specified indexed table.
--! @param source The table to be copied.
--! @return The copy of the specified table.
function table.icopy(source)
	if type(source) ~= "table" then return end
	local copy = {}

	for i, v in ipairs(source) do
		table.insert(copy, v)
	end

	return copy
end

--! Function originated by lua-users wiki: http://lua-users.org/wiki/CopyTable
--! @brief Copies a specified table and its direct children.
--! @param source The table to be copied.
--! @return The copy of the specified table.
function table.shallowcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else --! number, string, boolean, etc
		copy = orig
	end
	return copy
end

--! Function originated by lua-users wiki: http://lua-users.org/wiki/CopyTable
--! @brief Copies a specified table and all of its sub-indexes, including metatables.
--! @param source The table to be copied.
--! @return The copy of the specified table.
function table.deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = table.deepcopy(orig_value)
		end
		setmetatable(copy, table.deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

--! @brief Replaces the specified key in an indexed table with an entry.
--! @param source The table to be modified.
--! @param key The key to be replaced.
--! @param rep The entry to replace the key with.
--! @return The resulting table.
function table.ireplace(source, key, rep)
	for i, v in ipairs(source) do
		if v == key then
			table.remove(source, i)
			table.insert(source, i, rep)
			break
		end
	end

	return source
end

--! @brief Switches the position of two entries in an indexed table.
--! @param source The table to be modified.
--! @param key The first key to be switched.
--! @param sw The second key to be switched.
--! @return The resulting table.
function table.iswitch(source, key, sw)
	if type(source) ~= "table" then return end
	if type(key) ~= "string" or type(sw) ~= "string" then return end
	if not table.contains(source, sw) or not table.contains(source, key) then return end

	local kpos
	local swpos

	for i, v in ipairs(source) do
		if v == key then
			kpos = i
		end
		if v == sw then
			swpos = i
		end
	end

	if kpos > swpos then
		table.insert(source, swpos, key)
		table.insert(source, kpos, sw)
	else
		table.insert(source, kpos, sw)
		table.insert(source, swpos, key)
	end

	table.iremovekey(source, key)
	table.iremovekey(source, sw)

	return source
end

function table.imove(source, key, pos, plus)
	local ptype = type(pos)
	local ktype = type(key)

	if ktype == "string" then
		table.iremovekey(source, key)
	elseif ktype == "table" then
		for i, v in ipairs(key) do
			table.iremovekey(source, v)
		end
	end

	if ptype == "number" then
		if ktype == "string" then
			table.insert(source, pos, key)
		elseif ktype == "table" then
			for i, v in ipairs(key) do
				table.insert(source, pos, v)
			end
		end
	elseif ptype == "string" then
		for i, v in ipairs(source) do
			if v == pos then
				if plus then i = i + 1 end
				if ktype == "string" then
					table.insert(source, i, key)
				elseif ktype == "table" then
					for _, v in ipairs(key) do
						table.insert(source, i, v)
					end
				end
				break
			end
		end
	end

	return source
end

--! Unknown
function nconc(t, delim, col)
	local delim = delim or 25
	local col = col or "grey"
	local i = 0
	for _, v in ipairs(t) do
		i = i + 1
		local d = ""
		d = d .. v
		if (i - 1)%3 == 0 then
			echo("\n")
		end
		local o = v
		if o:len() < delim and (i - 1)%3 ~= 2 then
			local pad = delim - o:len()
			o = o .. string.rep(" ", pad)
		elseif o:len() > delim then
			o = o:cut(delim)
		end
	cecho("<"..col..">" .. o)
	end
end

--! Unknown
function Geyser.MiniConsole:clear()
	clearWindow(self.name)
end

--! Unknown
function Geyser.MiniConsole:append()
	appendBuffer(self.name)
end


--! @brief Truncates a specified string to the specified length.
--! @param txt The string to be truncated.
--! @param length The length of the new truncated string.
--! @return The truncated string appended by ellipsis.
function truncate(txt, length)
	if not type(txt) == "string" or #txt <= length then return txt end

	return string.sub(txt, 1, length - 3) .. "..."
end

function truncate2(pre, post, len)
	if pre:ends(" ") then end
	local r = pre .. "..." .. post
	if #r == len then
		return r
	elseif #r > len then
		local diff = #r - len
		pre = string.sub(pre, 1, #pre-diff)
		if pre:ends(" ") then
			pre = pre:sub(1, #pre-1) .. "...." .. post
		else
			pre = pre .. "..." .. post
		end

		return pre
	elseif #r < len then
		local diff = string.rep(".", len - #r + 3)
		pre = pre .. diff .. post
		return pre
	end
end

--[[
--! deprecated
function regexItem(item)
	local r = rex.new("(" .. table.concat(tmp.inv_herbs, "|") .. ")")
	local matches = r:match(item)
	if matches then
		local r = rex.new("(" .. table.concat(tmp.herbs, "|") .. ")")
		matches = r:match(matches)
		return matches
	end

	local r = rex.new("(" .. table.concat(tmp.inv_slices, "|") .. ")")
	local matches = r:match(item)
	if matches then
		local r = rex.new("(" .. table.concat(tmp.slices, "|") .. ")")
		matches = r:match(matches)
		return matches
	end
	
	return false
end
]]

function parse_gamefeed_data()
	local s = string.sub(getMudletHomeDir(), 1, 1) == "/" and "/" or "\\"
	local oasis_dir = getMudletHomeDir() .. s .. "oasis"
	local data_dir = oasis_dir .. s .. "data"

	local f = datadir .. s .. "gamefeed.json"

	downloadFile(f, "http://api.aetolia.com/gamefeed.json")

	if not lfs.attributes(f) then
		e.error("Gamefeed file not found.")
	else
		local file = assert(io.open(f, "r"), "Assertion failed for io.open(): Please check folder permissions for your Mudlet profile directory.")
		local p = file:read("*l")
		local r = yajl.to_value(p)

		file:close()

		local out = ""
		local data = {}
		for _, v in ipairs(r) do
			table.insert(data, v.caption)
			table.insert(data, v.description)
			tmp.feed_check = v.id
		end

		if not table.contains(tmp.done_feed, tmp.feed_check) then
			table.insert(tmp.done_feed, tmp.feed_check)
			e.echo(table.concat(data, ": "))
		end
	end
end

--! Function originated by David Kastrup: http://lua-users.org/wiki/DirTreeIterator.
--! @brief Recursively iterates over the files and subdirectories in dir, directory.
--! @param dir Accepts a directory.
function dirtree(dir)
	assert(dir and dir ~= "", "directory parameter is missing or empty")
	if string.sub(dir, -1) == "/" then
		dir = string.sub(dir, 1, -2)
	end
 
	local function yieldtree(dir)
		for entry in lfs.dir(dir) do
			if entry ~= "." and entry ~= ".." and not entry:find("lua") then
				entry = dir .. entry
				local attr = lfs.attributes(entry)
				coroutine.yield(entry,attr)
				if attr.mode == "directory" then
					yieldtree(entry)
				end
			end
		end
	end

	return coroutine.wrap(function() yieldtree(dir) end)
end

--! @brief Generates a random string.
--! @param length Length of the random string generated.
--! @param pattern Characters from which the random string will be pulled.
function randomString(length, pattern)
	local foo = ""
	for loop = 0, 255 do
		foo = foo .. string.char(loop)
	end

	local pattern, random = pattern or '.', ''
	local str = string.gsub(foo, '[^' .. pattern .. ']', '')
	for loop = 1, length do
		random = random .. string.char(string.byte(str, math.random(1, string.len(str))))
	end

	return random
end

--! deprecated
function get_modules()
	local exceptions = {
		"string",
		"package",
		"_G",
		"os",
		"table",
		"math",
		"coroutine",
		"luasql",
		"debug",
		"rex_pcre",
		"lfs",
		"io",
		"luasql.sqlite3",
		"gmod",
		"zip",
		"socket"
	}

	local modules = {}

	for m in pairs(package.loaded) do
		if not table.contains(exceptions, m) then
			table.insert(modules, m)
		end
	end

	return modules
end

--! deprecated
function check_module(name)
	return package.loaded[name] and true or false
end

--! deprecated
function update_check()
	local f = sysdir .. "updates" .. sep .. "update.str"
	downloadFile(f, "http://oasis.interimreality.com/version")
	tempTimer(30, [[check_version()]])
end

--! deprecated
function check_version()
	local f = sysdir .. "updates" .. sep .. "update.str"
	if not lfs.attributes(f) then return end

	local file = assert(io.open(f, "r"), "Assertion failed for io.open()")
	local p = file:read("*l")
	if tonumber(p) > tonumber(s.version) then
		tmp.has_update = true
	else
		tmp.has_update = nil
	end

	file:close()
end

--! @brief Saves relevant namespaces to the data directory, quits, and disconnects.
function qq()
	o.state = false --! indicates that the system is unloaded
	--! todo: unload function and restart on disconnect/reconnect
	e.info("Initiating shutdown sequence...", true, false)
	cdb.save()
	e.info("Character database saved.", true, false)
	e.info("Disconnecting. See you next time!", true, true)
	send("quit")
	disconnect()
end

--! @brief Called in .xml script load_oasis().
function on_oasis_load()
	o.state = true --! indicates that the system is fully present and this function has fired on startup

	--settings:save()
	--settings:load()

	cdb.load()
end