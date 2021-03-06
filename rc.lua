awful = require("awful")
require("awful.autofocus")
awful.rules = require("awful.rules")
wibox = require("wibox")
beautiful = require("beautiful")
naughty = require("naughty")
vicious = require("vicious")
blingbling = require("blingbling")
lain = require("lain")

--{{---| Java GUI's fix |---------------------------------------------------------------------------

awful.util.spawn_with_shell("wmname LG3D")

--Transparency
--awful.util.spawn_with_shell("cairo-compmgr &")

--{{---| Error handling |---------------------------------------------------------------------------

if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
	title = "Oops, there were errors during startup!",
	text = awesome.startup_errors })
end
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		if in_error then return end
		in_error = true
		naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, an error happened!",
		text = err })
		in_error = false
	end)
end

--{{---| Theme |------------------------------------------------------------------------------------

home_dir = os.getenv("HOME") or "/home/whyrusleeping"
config_dir = (home_dir .. "/.config/awesome/")
themes_dir = (config_dir .. "/themes")
beautiful.init(themes_dir .. "/powerarrow/theme.lua")

--{{---| Variables |--------------------------------------------------------------------------------

modkey        = "Mod4"
terminal      = "urxvt"
editor        = os.getenv("EDITOR") or "vim"
editor_cmd    = terminal .. " -e " .. editor
browser       = "chromium"

larrow 		= "⮂"
rarrow 		= "⮀"
lthinsep 	= "⮃"
rthinsep 	= "⮁"

---------------------------------------------------------------------------------------------------
--{{---| Solarized Colors|-------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
base03   = "#002b36"
base02   = "#073642"
base01   = "#586e75"
base00   = "#657b83"
base0    = "#839496"
base1    = "#93a1a1"
base2    = "#eee8d5"
base3    = "#fdf6e3"
yellow   = "#b58900"
orange   = "#cb4b16"
red      = "#dc322f"
magenta  = "#d33682"
violet   = "#6c71c4"
blue     = "#268bd2"
cyan     = "#2aa198"
green    = "#859900"

--{{---| Table of layouts |-------------------------------------------------------------------------

layouts = {
	awful.layout.suit.floating,
	lain.layout.uselessfair,
	lain.layout.centerfair,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top
}

--{{---| Tags |-------------------------------------------------------------------------------------

tags = {}
for s = 1, screen.count() do
	tags[s] = awful.tag({ "web", 2, 3, 4, 5, 6, 7, "steam", "chat" }, s, layouts[1])
end

awful.layout.set(awful.layout.suit.tile, tags[1][1])
awful.layout.set(lain.layout.uselessfair, tags[1][2])
--{{---| Menu |-------------------------------------------------------------------------------------

myawesomemenu = {
	{"edit config",           "urxvt -x vim /home/whyrusleeping/.config/awesome/rc.lua"},
	{"edit theme",            "urxvt -x vim /home/whyrusleeping/.config/awesome/themes/powerarrow/theme.lua"},
	{"hibernate",             "sudo pm-hibernate"},
	{"restart",               awesome.restart },
	{"reboot",                "sudo reboot"},
	{"quit",                  awesome.quit }
}

mymainmenu = awful.menu({ items = { 
	{ " @wesome",             myawesomemenu, beautiful.awesome_icon },
	{" calc",                 "/usr/bin/gcalctool", beautiful.galculator_icon},
	{" htop",                 terminal .. " -x htop", beautiful.htop_icon},
	{" file manager",         "spacefm", beautiful.spacefm_icon},
	{" root terminal",        "sudo " .. terminal, beautiful.terminalroot_icon},
	{" terminal",             terminal, beautiful.terminal_icon} 
}
})

mylauncher = awful.widget.launcher({ image = beautiful.clear_icon, menu = mymainmenu })

--
--{{---| Wibox |------------------------------------------------------------------------------------

mysystray = wibox.widget.systray()
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, awful.client.toggletag),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
	if c == client.focus then
		c.minimized = true
	else
		if not c:isvisible() then
			awful.tag.viewonly(c:tags()[1])
		end
		client.focus = c
		c:raise()
	end
end),
awful.button({ }, 3, function ()
	if instance then
		instance:hide()
		instance = nil
	else
		instance = awful.menu.clients({ width=450 })
	end
end),
awful.button({ }, 4, function ()
	awful.client.focus.byidx(1)
	if client.focus then client.focus:raise() end
end),
awful.button({ }, 5, function ()
	awful.client.focus.byidx(-1)
	if client.focus then client.focus:raise() end
end))

clockwidget = wibox.widget.textbox()
vicious.register(clockwidget, vicious.widgets.date, '<span background="#000000" font="Mensch 12" color="'..base01..'">'..larrow..'</span><span background="'..base01..'" font="Mensch 10" color="'..base2..'"> %b %d <span font="Mensh 12">'..lthinsep..'</span> %R </span>', 60)
clockwidget:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(calendar) end)))

cores_graph_conf ={height = 18, width = 8, rounded_size = 0.3}
cores_graphs = {}

cpu_graph = blingbling.line_graph({ height = 18,
width = 200,
show_text = true,
label = "Load: $percent %",
rounded_size = 0.3,
graph_background_color = "#00000033"})
vicious.register(cpu_graph, vicious.widgets.cpu,'$1',2)
blingbling.popups.htop(cpu_graph, { terminal =  terminal })

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
	awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
	awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
	awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
	awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	-- Create the wibox
	mywibox[s] = awful.wibox({ position = "top", screen = s, height = "16" })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(mylauncher)
	left_layout:add(mytaglist[s])
	left_layout:add(mypromptbox[s])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	if s == 1 then right_layout:add(wibox.widget.systray()) end

	right_layout:add(cpu_graph)
	right_layout:add(clockwidget)


	right_layout:add(mylayoutbox[s])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mytasklist[s])
	layout:set_right(right_layout)

	mywibox[s]:set_widget(layout)
end

--{{---| Mouse bindings |---------------------------------------------------------------------------

root.buttons(awful.util.table.join(awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 6, function (c) awful.tag.viewprev() end ),
awful.button({ }, 7, function (c) awful.tag.viewnext() end )))

--{{---| Key bindings |-----------------------------------------------------------------------------

globalkeys = awful.util.table.join(
awful.key({ modkey,           }, "Left",
	awful.tag.viewprev       ),
awful.key({ modkey,           }, "Right",
	awful.tag.viewnext       ),
awful.key({ modkey,           }, "Escape",
	awful.tag.history.restore),
awful.key({ modkey,           }, "j",
	function () awful.client.focus.byidx( 1)
		if client.focus then client.focus:raise() end end),
awful.key({ modkey,           }, "k",
	function () awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end end),
awful.key({ modkey,           }, "w",
	function () mymainmenu:show({keygrabber=true}) end),
awful.key({ modkey, "Shift"   }, "j",
	function () awful.client.swap.byidx(  1)    end),
awful.key({ modkey, "Shift"   }, "k", 
	function () awful.client.swap.byidx( -1)    end),
awful.key({ modkey, "Control" }, "j",
	function () awful.screen.focus_relative( 1) end),
awful.key({ modkey, "Control" }, "k",
	function () awful.screen.focus_relative(-1) end),
awful.key({ modkey,           }, "u", 
	awful.client.urgent.jumpto),
awful.key({ modkey,           }, "Tab",
	function ()
		awful.client.focus.history.previous()
		if client.focus then client.focus:raise() end
	end),
awful.key({ modkey,           }, "Return",
function () awful.util.spawn(terminal) end),  
awful.key({ modkey, "Control" }, "r",
	awesome.restart),
awful.key({ modkey, "Shift",     "Control"}, "r",
	awesome.quit),
awful.key({ modkey, "Control" }, "n",
	awful.client.restore),
awful.key({ modkey },            "r",
	function () mypromptbox[mouse.screen]:run() end),
awful.key({ modkey,           }, "l",
	function () awful.tag.incmwfact( 0.05)    end),
awful.key({ modkey,           }, "h",
	function () awful.tag.incmwfact(-0.05)    end),
awful.key({ modkey, "Shift"   }, "h",
	function () awful.tag.incnmaster( 1)      end),
awful.key({ modkey, "Shift"   }, "l", 
	function () awful.tag.incnmaster(-1)      end),
awful.key({ modkey, "Control" }, "h",
	function () awful.tag.incncol( 1)         end),
awful.key({ modkey, "Control" }, "l",
	function () awful.tag.incncol(-1)         end),
awful.key({ modkey,           }, "space",
	function () awful.layout.inc(layouts,  1) end),
awful.key({ modkey, "Shift"   }, "space",
	function () awful.layout.inc(layouts, -1) end)
)


clientkeys = awful.util.table.join(
awful.key({ modkey,           }, "f",
	function (c) c.fullscreen = not c.fullscreen  end),
awful.key({ modkey,           }, "c",
	function (c) c:kill()                         end),
awful.key({ modkey, "Control" }, "Return",
	function (c) c:swap(awful.client.getmaster()) end),
awful.key({ modkey,           }, "o",
	awful.client.movetoscreen),
awful.key({ modkey, "Shift"   }, "r",
	function (c) c:redraw()                       end),
awful.key({ modkey,           }, "n",
	function (c) c.minimized = true end),
awful.key({ modkey,           }, "m",
	function (c) c.maximized_horizontal = not c.maximized_horizontal
	c.maximized_vertical   = not c.maximized_vertical end)
)

	keynumber = 0
	for s = 1, screen.count() do keynumber = math.min(9, math.max(#tags[s], keynumber)); end
	for i = 1, keynumber do globalkeys = awful.util.table.join(globalkeys,
	awful.key({ modkey }, "#" .. i + 9, function () local screen = mouse.screen
	if tags[screen][i] then awful.tag.viewonly(tags[screen][i]) end end),
	awful.key({ modkey, "Control" }, "#" .. i + 9, function () local screen = mouse.screen
	if tags[screen][i] then awful.tag.viewtoggle(tags[screen][i]) end end),
	awful.key({ modkey, "Shift" }, "#" .. i + 9, function () if client.focus and 
	tags[client.focus.screen][i] then awful.client.movetotag(tags[client.focus.screen][i]) end end),
	awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function () if client.focus and
	tags[client.focus.screen][i] then awful.client.toggletag(tags[client.focus.screen][i]) end end)) end
	clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ }, 6, function (c) awful.tag.viewprev() end ),
	awful.button({ }, 7, function (c) awful.tag.viewnext() end ),
	awful.button({ modkey }, 3, awful.mouse.client.resize))

	--{{---| Set keys |---------------------------------------------------------------------------------

	root.keys(globalkeys)

	--{{---| Rules |------------------------------------------------------------------------------------

	awful.rules.rules = {
		{ rule = { },
		properties = { size_hints_honor = false,
		border_width = 2,
		border_color = beautiful.border_normal,
		focus = true,
		keys = clientkeys,
		buttons = clientbuttons } },
		{ rule = { class = "goldendict" },
		properties = { floating = true } },
		{ rule = { class = "audacious" },
		properties = { floating = true } },
		{ rule = { class = "xwinmosaic" },
		properties = { floating = true } },
		{ rule = { class = "gimp" },
		properties = { floating = true } },
		{ rule = { name = "synapse" },
		properties = { border_width = 0 } },
	}

	--{{---| Signals |----------------------------------------------------------------------------------

									client.connect_signal("manage", function (c, startup)
										-- Add a titlebar
										-- awful.titlebar.add(c, { modkey = modkey })
										c:connect_signal("mouse::enter", function(c) if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
											and awful.client.focus.filter(c) then client.focus = c end end)
											if not startup then if not c.size_hints.user_position and not c.size_hints.program_position then
												awful.placement.no_overlap(c) awful.placement.no_offscreen(c) end end end)
												client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
												client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

												--{{--| Autostart |---------------------------------------------------------------------------------

awful.util.spawn_with_shell("nitrogen --restore")
awful.util.spawn_with_shell("synapse -s &")
--awful.util.spawn_with_shell("kill conky")
--awful.util.spawn_with_shell("conky")
awful.util.spawn_with_shell("xmodmap ~/.xmodmaprc")
												--{{Xx----------------------------------------------------------------------------------------------

