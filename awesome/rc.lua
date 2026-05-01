-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- ─────────────────────────────────────────
--  Catppuccin Mocha Palette
-- ─────────────────────────────────────────
local c = {
    base      = "#1e1e2e",
    mantle    = "#181825",
    crust     = "#11111b",
    surface0  = "#313244",
    surface1  = "#45475a",
    surface2  = "#585b70",
    overlay0  = "#6c7086",
    text      = "#cdd6f4",
    subtext0  = "#a6adc8",
    lavender  = "#b4befe",
    blue      = "#89b4fa",
    sapphire  = "#74c7ec",
    sky       = "#89dceb",
    teal      = "#94e2d5",
    green     = "#a6e3a1",
    yellow    = "#f9e2af",
    peach     = "#fab387",
    maroon    = "#eba0ac",
    red       = "#f38ba8",
    mauve     = "#cba6f7",
    pink      = "#f5c2e7",
    flamingo  = "#f2cdcd",
    rosewater = "#f5e0dc",
}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- ─────────────────────────────────────────
--  Apply Catppuccin Mocha theme overrides
-- ─────────────────────────────────────────
beautiful.font                  = "JetBrainsMono Nerd Font 10"
beautiful.bg_normal             = c.base
beautiful.fg_normal             = c.text
beautiful.bg_focus              = c.surface0
beautiful.fg_focus              = c.lavender
beautiful.bg_urgent             = c.red
beautiful.fg_urgent             = c.base
beautiful.border_width          = 0
beautiful.border_normal         = c.surface1
beautiful.border_focus          = c.mauve
beautiful.wibar_bg              = c.mantle
beautiful.wibar_height          = 36
beautiful.tasklist_bg_focus     = c.surface0
beautiful.tasklist_fg_focus     = c.lavender
beautiful.tasklist_bg_normal    = c.mantle
beautiful.tasklist_fg_normal    = c.subtext0
beautiful.taglist_bg_focus      = c.mauve
beautiful.taglist_fg_focus      = c.base
beautiful.taglist_bg_occupied   = c.surface1
beautiful.taglist_fg_occupied   = c.text
beautiful.taglist_bg_empty      = c.mantle
beautiful.taglist_fg_empty      = c.overlay0
beautiful.taglist_bg_urgent     = c.red
beautiful.taglist_fg_urgent     = c.base
beautiful.tooltip_bg            = c.surface0
beautiful.tooltip_fg            = c.text

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = "micro"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
}
-- }}}

-- {{{ Menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- ─────────────────────────────────────────
--  Wibar Helpers
-- ─────────────────────────────────────────

-- Rounded pill container
local function pill(widget, bg_color, fg_color, pad)
    return wibox.widget {
        {
            {
                widget,
                left   = pad or 10,
                right  = pad or 10,
                top    = 4,
                bottom = 4,
                widget = wibox.container.margin,
            },
            bg     = bg_color or c.surface0,
            fg     = fg_color or c.text,
            shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 8) end,
            widget = wibox.container.background,
        },
        left   = 3,
        right  = 3,
        widget = wibox.container.margin,
    }
end

-- Icon + text pair
local function icon_label(icon, label_widget)
    return wibox.widget {
        {
            text   = icon .. " ",
            font   = "JetBrainsMono Nerd Font 11",
            widget = wibox.widget.textbox,
        },
        label_widget,
        layout = wibox.layout.fixed.horizontal,
    }
end

-- Subtle separator
local function make_sep()
    local s = wibox.widget {
        text   = "│",
        align  = "center",
        valign = "center",
        widget = wibox.widget.textbox,
    }
    s:set_markup("<span foreground='" .. c.surface2 .. "'>│</span>")
    return wibox.widget {
        s,
        left   = 4,
        right  = 4,
        widget = wibox.container.margin,
    }
end

-- ─────────────────────────────────────────
--  RAM Widget
-- ─────────────────────────────────────────
local ram_text = wibox.widget {
    text   = "...",
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}

awful.widget.watch(
    "bash -c \"free -m | awk '/^Mem:/{printf \"%dM / %dM\", $3, $2}'\"",
    5,
    function(widget, stdout)
        widget:set_markup_silently(
            "<span foreground='" .. c.teal .. "'>" .. (stdout ~= "" and stdout or "N/A") .. "</span>"
        )
    end,
    ram_text
)

local ram_pill = pill(icon_label("󰍛", ram_text), c.surface0, c.text)

-- ─────────────────────────────────────────
--  Clock & Date Widgets
-- ─────────────────────────────────────────
local time_text = wibox.widget {
    format = "<span foreground='" .. c.blue .. "'>%H:%M</span>",
    align  = "center",
    valign = "center",
    widget = wibox.widget.textclock,
}

local date_text = wibox.widget {
    format = "<span foreground='" .. c.yellow .. "'>%a %d %b</span>",
    align  = "center",
    valign = "center",
    widget = wibox.widget.textclock,
}

local time_pill = pill(icon_label("󰥔", time_text), c.surface0, c.text)
local date_pill = pill(icon_label("󰃭", date_text), c.surface0, c.text)

-- ─────────────────────────────────────────
--  Arch Linux Logo
-- ─────────────────────────────────────────
local arch_icon = wibox.widget {
    {
        {
            text   = "󰣇",
            font   = "JetBrainsMono Nerd Font 12",
            align  = "center",
            valign = "center",
            widget = wibox.widget.textbox,
        },
        left   = 8,
        right  = 8,
        top    = 5,
        bottom = 5,
        widget = wibox.container.margin,
    },
    bg     = c.mauve,
    fg     = c.base,
    shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 8) end,
    widget = wibox.container.background,
}

local arch_pill = wibox.widget {
    arch_icon,
    left   = 3,
    right  = 6,
    widget = wibox.container.margin,
}

-- ─────────────────────────────────────────
--  Tag & Tasklist Button Bindings
-- ─────────────────────────────────────────
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then client.focus:toggle_tag(t) end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function(cl)
        if cl == client.focus then
            cl.minimized = true
        else
            cl:emit_signal("request::activate", "tasklist", { raise = true })
        end
    end),
    awful.button({ }, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({ }, 4, function() awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function() awful.client.focus.byidx(-1) end)
)

-- ─────────────────────────────────────────
--  Wallpaper
-- ─────────────────────────────────────────
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)

-- ─────────────────────────────────────────
--  Per-screen wibar setup
-- ─────────────────────────────────────────
awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    -- 5 persistent workspaces with Nerd Font icons
    -- Fallback to plain numbers if Nerd Fonts aren't installed: { "1","2","3","4","5" }
    awful.tag({ "1", "2", "3" }, s, awful.layout.layouts[1])

    -- Prompt box
    s.mypromptbox = awful.widget.prompt()

    -- Layout box
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc( 1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end),
        awful.button({ }, 4, function() awful.layout.inc( 1) end),
        awful.button({ }, 5, function() awful.layout.inc(-1) end)
    ))

    -- Tag list with rounded pill template
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        widget_template = {
            {
                {
                    id     = "text_role",
                    font   = "JetBrainsMono Nerd Font 13",
                    align  = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
                left   = 10,
                right  = 10,
                top    = 4,
                bottom = 4,
                widget = wibox.container.margin,
            },
            id     = "background_role",
            shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 8) end,
            widget = wibox.container.background,
        },
    }

    -- Wrap taglist in a pill background
    local taglist_pill = wibox.widget {
        {
            {
                s.mytaglist,
                left   = 6,
                right  = 6,
                top    = 4,
                bottom = 4,
                widget = wibox.container.margin,
            },
            bg     = c.surface0,
            shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end,
            widget = wibox.container.background,
        },
        left   = 6,
        right  = 0,
        widget = wibox.container.margin,
    }

    -- Task list with icon + title template
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        widget_template = {
            {
                {
                    {
                        id     = "icon_role",
                        widget = wibox.widget.imagebox,
                    },
                    left   = 6,
                    right  = 4,
                    widget = wibox.container.margin,
                },
                {
                    id     = "text_role",
                    align  = "left",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
                right  = 8,
                layout = wibox.layout.fixed.horizontal,
            },
            id     = "background_role",
            shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 6) end,
            widget = wibox.container.background,
        },
    }

    -- System tray
    local systray_pill = pill(wibox.widget.systray(), c.surface0, c.text)

    -- Build the wibar
    s.mywibox = awful.wibar({
        position = "bottom",
        screen   = s,
        height   = 36,
        bg       = c.mantle,
        fg       = c.text,
    })

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,

        -- LEFT: workspaces
        {
            layout = wibox.layout.fixed.horizontal,
            taglist_pill,
        },

        -- MIDDLE: open tasks
        {
            s.mytasklist,
            left   = 8,
            right  = 8,
            widget = wibox.container.margin,
        },

        -- RIGHT: sys tray | ram | date | time | arch logo
        {
            layout = wibox.layout.fixed.horizontal,
            -- systray_pill,
            -- make_sep(),
            -- ram_pill,
            -- make_sep(),
            date_pill,
            make_sep(),
            time_pill,
            -- make_sep(),
            -- arch_pill,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function() mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey }, "space", function()
        awful.spawn("rofi -show drun")
    end, {description = "show rofi", group = "launcher"}),

    awful.key({ modkey }, "p", function()
        awful.spawn("scrot -fs")
    end, {description = "screenshot", group = "launcher"}),

    awful.key({ modkey,           }, "j",
        function() awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}),
    awful.key({ modkey,           }, "k",
        function() awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}),
    awful.key({ modkey,           }, "w",
        function() mymainmenu:show() end,
        {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function() awful.client.swap.byidx(  1) end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function() awful.client.swap.byidx( -1) end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then client.focus:raise() end
        end,
        {description = "go back", group = "client"}),

    -- Standard programs
    awful.key({ modkey,           }, "Return", function() awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function() awful.tag.incmwfact( 0.05) end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function() awful.tag.incmwfact(-0.05) end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function() awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function() awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function() awful.tag.incncol( 1, nil, true) end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function() awful.tag.incncol(-1, nil, true) end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "d",     function() awful.layout.inc( 1) end,
              {description = "select next layout", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function() awful.layout.inc(-1) end,
              {description = "select previous layout", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
        function()
            local cl = awful.client.restore()
            if cl then
                cl:emit_signal("request::activate", "key.unminimize", { raise = true })
            end
        end,
        {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey }, "r",
        function() awful.screen.focused().mypromptbox:run() end,
        {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "a",
        function()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        {description = "lua execute prompt", group = "awesome"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function(cl)
            cl.fullscreen = not cl.fullscreen
            cl:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "x",      function(cl) cl:kill() end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function(cl) cl:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function(cl) cl:move_to_screen() end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function(cl) cl.ontop = not cl.ontop end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function(cl) cl.minimized = true end,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function(cl)
            cl.maximized = not cl.maximized
            cl:raise()
        end,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function(cl)
            cl.maximized_vertical = not cl.maximized_vertical
            cl:raise()
        end,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function(cl)
            cl.maximized_horizontal = not cl.maximized_horizontal
            cl:raise()
        end,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind key numbers to tags (only 5 tags now)
for i = 1, 5 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then tag:view_only() end
            end,
            {description = "view tag #" .. i, group = "tag"}),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then awful.tag.viewtoggle(tag) end
            end,
            {description = "toggle tag #" .. i, group = "tag"}),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:move_to_tag(tag) end
                end
            end,
            {description = "move focused client to tag #" .. i, group = "tag"}),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:toggle_tag(tag) end
                end
            end,
            {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function(cl)
        cl:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(cl)
        cl:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(cl)
    end),
    awful.button({ modkey }, 3, function(cl)
        cl:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(cl)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },
    { rule_any = {
        instance = { "DTA", "copyq", "pinentry" },
        class = {
          "Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin",
          "Sxiv", "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
        },
        name  = { "Event Tester" },
        role  = { "AlarmWindow", "ConfigManager", "pop-up" }
      }, properties = { floating = true }
    },
    { rule_any = { type = { "normal", "dialog" } },
      properties = { titlebars_enabled = true }
    },
}
-- }}}

-- {{{ Signals
client.connect_signal("manage", function(cl)
    if awesome.startup
      and not cl.size_hints.user_position
      and not cl.size_hints.program_position then
        awful.placement.no_offscreen(cl)
    end
end)

-- Titlebars
client.connect_signal("request::titlebars", function(cl)
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            cl:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(cl)
        end),
        awful.button({ }, 3, function()
            cl:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(cl)
        end)
    )

    awful.titlebar(cl):setup {
        { -- Left
            awful.titlebar.widget.iconwidget(cl),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { align  = "center", widget = awful.titlebar.widget.titlewidget(cl) },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(cl),
            awful.titlebar.widget.maximizedbutton(cl),
            awful.titlebar.widget.stickybutton(cl),
            awful.titlebar.widget.ontopbutton(cl),
            awful.titlebar.widget.closebutton(cl),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Focus follows mouse
client.connect_signal("mouse::enter", function(cl)
    cl:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus",   function(cl) cl.border_color = beautiful.border_focus  end)
client.connect_signal("unfocus", function(cl) cl.border_color = beautiful.border_normal end)
-- }}}
