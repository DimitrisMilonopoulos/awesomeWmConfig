-- wibar.lua
-- Wibar (top bar)
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local icon_theme = "sheet"
local icons = require("icons")
local weather_widget = require("awesome-wm-widgets.weather-widget.weather")

local systray_margin = (beautiful.wibar_height - beautiful.systray_icon_size) /
                           2

-- Helper function that changes the appearance of progress bars and their icons
-- Create horizontal rounded bars
local function format_progress_bar(bar)
    bar.forced_width = dpi(100)
    bar.shape = gears.shape.rounded_bar
    bar.bar_shape = gears.shape.rounded_bar
    bar.background_color = beautiful.xcolor8
    return bar
end

-- Awesome Panel -----------------------------------------------------------

-- Init music, panel, and cal
-- local mpd = require("widgets.mpd")
local panelPop = require('bloat.pop.panel')
local calPop = require('bloat.pop.cal')

local awesome_icon = wibox.widget {
    {widget = wibox.widget.imagebox, image = icons.awesome, resize = true},
    margins = 5,
    layout = wibox.container.margin
}

-- Weather widget

awesome_icon:connect_signal("mouse::enter",
                            function() panelPop.visible = true end)


awesome_icon:buttons(gears.table.join(awful.button({}, 1, function()
    panelPop.visible = true
    awesome_icon.bg = beautiful.xbackground
end)))

panelPop:connect_signal("mouse::leave", function()
    panelPop.visible = false
    awesome_icon.bg = beautiful.xcolor0
end)

-- Notifs Panel ---------------------------------------------------------------

local notifPop = require("bloat.pop.notif")
local notif_icon = wibox.widget {
    widget = wibox.widget.imagebox,
    image = icons.notif,
    resize = true
}

notif_icon:connect_signal("mouse::enter", function() notifPop.visible = true end)
notifPop:connect_signal("mouse::leave", function() notifPop.visible = false end)

-- Battery Bar Widget ---------------------------------------------------------

local battery_bar = require("widgets.battery_bar")

local battery = format_progress_bar(battery_bar)

-- Time Widget ----------------------------------------------------
local timetray = wibox.widget.textclock('<span color="#7dbba8" font="SF Display 12">%H:%M</span>')

local timetray_container = {
    timetray,
    left = dpi(4),
    right = dpi(4),
    screen = 1,
    widget = wibox.container.margin
}
-- Systray Widget -------------------------------------------------------------

local mysystray = wibox.widget.systray()
mysystray:set_base_size(beautiful.systray_icon_size)

local mysystray_container = {
    mysystray,
    left = dpi(8),
    right = dpi(8),
    screen = 1,
    widget = wibox.container.margin
}

-- Song widget ---------------------------------------------------------------
-- Title Widget
local song_title = wibox.widget {
    markup = 'Nothing Playing',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local song_artist = wibox.widget {
    markup = 'nothing playing',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local song_logo = wibox.widget {
    markup = '<span foreground="' .. beautiful.xcolor6 .. '"></span>',
    font = beautiful.icon_font,
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local playerctl_bar = wibox.widget {
    {
        {
            {
                song_logo,
                left = dpi(3),
                right = dpi(10),
                bottom = dpi(1),
                widget = wibox.container.margin
            },
            {
                {
                    song_title,
                    expand = "outside",
                    layout = wibox.layout.align.vertical
                },
                left = dpi(10),
                right = dpi(10),
                widget = wibox.container.margin
            },
            {
                {
                    song_artist,
                    expand = "outside",
                    layout = wibox.layout.align.vertical
                },
                left = dpi(10),
                widget = wibox.container.margin
            },
            spacing = 1,
            spacing_widget = {
                bg = beautiful.xcolor8,
                widget = wibox.container.background
            },
            layout = wibox.layout.fixed.horizontal
        },
        left = dpi(10),
        right = dpi(10),
        widget = wibox.container.margin
    },

    bg = beautiful.xbackground,
    border_width = 2,
    border_color = beautiful.xcolor8,
    shape = helpers.rrect(beautiful.border_radius - 5),
    widget = wibox.container.background
}

playerctl_bar.visible = false

awesome.connect_signal("bling::playerctl::player_stopped",
                       function() playerctl_bar.visible = false end)

-- Get Title 
awesome.connect_signal("bling::playerctl::title_artist_album",
                       function(title, artist, _)

    playerctl_bar.visible = true
    song_title.markup = '<span foreground="' .. beautiful.xcolor5 .. '">' ..
                            title .. '</span>'

    song_artist.markup = '<span foreground="' .. beautiful.xcolor4 .. '">' ..
                             artist .. '</span>'
end)
-- Taglist Widget -------------------------------------------------------------

local taglist_buttons = gears.table.join(
                            awful.button({}, 1, function(t) t:view_only() end),
                            awful.button({modkey}, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end), awful.button({}, 3, awful.tag.viewtoggle),
                            awful.button({modkey}, 3, function(t)
        if client.focus then client.focus:toggle_tag(t) end
    end), awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
                            awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end))

-- Tasklist Widget ------------------------------------------------------------

local tasklist_buttons = gears.table.join(
                             awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", {raise = true})
        end
    end), awful.button({}, 3, function()
        awful.menu.client_list({theme = {width = 250}})
    end), awful.button({}, 4, function() awful.client.focus.byidx(1) end),
                             awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))

-- Create the Wibar -----------------------------------------------------------

awful.screen.connect_for_each_screen(function(s)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create layoutbox widget
    s.mylayoutbox = awful.widget.layoutbox(s)

    if s.index == 1 then
        mysystray_container.visible = true
    else
        mysystray_container.visible = false
    end

    -- Create the wibox
    s.mywibox = awful.wibar({position = "top", 
    screen = s,
    ontop = true,
    bg = beautiful.wibar_bg .. "00"
})
    s.mywibox:set_xproperty("WM_NAME", "panel")

    -- Remove wibar on full screen
    local function remove_wibar(c)
        if (c.fullscreen or c.maximized) and c.screen == s then
            s.mywibox.visible = false
        else
            s.mywibox.visible = true
        end
    end

    client.connect_signal("property::fullscreen", remove_wibar)

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        style = {shape = gears.shape.rectangle},
        layout = {spacing = 0, layout = wibox.layout.fixed.horizontal},
        widget_template = {
            {
                {
                    {id = 'text_role', widget = wibox.widget.textbox},
                    layout = wibox.layout.fixed.horizontal
                },
                left = 11,
                right = 11,
                top = 1,
                widget = wibox.container.margin,
                border_width = 2,
                border_color = beautiful.xcolor8,
            },
            id = 'background_role',
            widget = wibox.container.background
        },
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style = {
            bg = beautiful.xbackground,
            shape = helpers.rrect(beautiful.border_radius - 3),
            shape_border_width = 2,
            shape_border_color = beautiful.xcolor8,
            border_width = 2,
            border_color = beautiful.xcolor8,
        },
        layout = {spacing = 10, layout = wibox.layout.fixed.horizontal},
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = 2,
                        widget  = wibox.container.margin,
                    },
                    nil,
                    -- {
                    --    id = 'text_role',
                    --    widget = wibox.widget.textbox,
                    -- },
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = 10,
                right = 10,
                widget = wibox.container.margin,
            },
            id     = 'background_role',
            widget = wibox.container.background,
        },
    }

    -- Add widgets to the wibox
    s.mywibox:setup{
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            layout = wibox.layout.fixed.horizontal,
            {
                {
                    awesome_icon,
                    bg = beautiful.xbackground,
                    widget = wibox.container.background,
                    shape = helpers.rrect(beautiful.border_radius-5),
                    border_width = 2,
                    border_color = beautiful.xcolor8,
                },
                top = dpi(4),
                bottom = dpi(4),
                right = dpi(7),
                left = dpi(10),
                widget = wibox.container.margin
            },
            {
                {
                    s.mytaglist,
                    bg = beautiful.xbackground,
                    shape = helpers.rrect(beautiful.border_radius-5),
                    border_width = 2,
                    border_color = beautiful.xcolor8,
                    widget = wibox.container.background
                },
                top = 4,
                bottom = 4,
                right = 5,
                left = 5,
                widget = wibox.container.margin
            },
            s.mypromptbox,
            {
                    playerctl_bar,
                    margins = dpi(4),
                    widget = wibox.container.margin,
                },
      },
        {
            s.mytasklist,
            top = 4,
            bottom = 4,
            right = 5,
            left = 5,
            widget = wibox.container.margin
            
        },
        {
            {
                {
                    {
                    weather_widget({
                        api_key='0b4886e416a602430bf525cff698b879',
                        coordinates = {37.986498348711635, 23.791046715572477},
                        time_format_12h = true,
                        units = 'metric',
                        font_name = 'SF Display UI',
                        show_hourly_forecast = true,
                        show_daily_forecast = true,
                    }),
                top = 2,
                bottom = 2,
                right = 5,
                left = 5,
                        layout = wibox.container.margin
                    },
                    bg = beautiful.xbackground,
                    shape = helpers.rrect(beautiful.border_radius-5),
                    border_width = 2,
                    border_color = beautiful.xcolor8,
                    widget = wibox.container.background
                },
                top = 4,
                bottom = 4,
                right = 5,
                left = 5,
                widget = wibox.container.margin
            },
            {
                {
                    {
                        battery,
                        top = 0,
                        bottom = 0,
                        right = 13,
                        left = 13,
                        widget = wibox.container.margin
                    },
                    bg = beautiful.xbackground,
                    shape = helpers.rrect(beautiful.border_radius-5),
                    border_width = 2,
                    border_color = beautiful.xcolor8,
                    widget = wibox.container.background
                },
                top = 4,
                bottom = 4,
                right = 5,
                left = 5,
                widget = wibox.container.margin
            },
            nil,
            nil,
            {
                {
                    {
                        timetray_container,
                        layout = wibox.container.margin
                    },
                    bg = beautiful.xbackground,
                    shape = helpers.rrect(beautiful.border_radius-5),
                    border_width = 2,
                    border_color = beautiful.xcolor8,
                    widget = wibox.container.background
                },
                top = 4,
                bottom = 4,
                right = 5,
                left = 5,
                widget = wibox.container.margin
            },
            {
                {
                    {
                        mysystray_container,
                        top = dpi(4),
                        layout = wibox.container.margin
                    },
                    bg = beautiful.xbackground,
                    shape = helpers.rrect(beautiful.border_radius-5),
                    border_width = 2,
                    border_color = beautiful.xcolor8,
                    widget = wibox.container.background
                },
                top = 4,
                bottom = 4,
                right = 5,
                left = 5,
                widget = wibox.container.margin
            },
            {
                {
                    {
                        s.mylayoutbox,
                        top = dpi(4),
                        bottom = dpi(4),
                        right = dpi(7),
                        left = dpi(7),
                        widget = wibox.container.margin
                    },
                    bg = beautiful.xbackground,
                    shape = helpers.rrect(beautiful.border_radius-5),
                    border_width = 2,
                    border_color = beautiful.xcolor8,
                    widget = wibox.container.background
                },
                top = 4,
                bottom = 4,
                right = 5,
                left = 5,
                widget = wibox.container.margin
            },

            {
                {
                    {
                        notif_icon,
                        margins = 2,
                        widget = wibox.container.margin
                    },
                    shape = helpers.rrect(beautiful.border_radius-5),
                    border_width = 2,
                    border_color = beautiful.xcolor8,
                    bg = beautiful.xbackground,
                    widget = wibox.container.background
                },
                top = 4,
                right = 5,
                bottom = 4,
                left = 5,
                widget = wibox.container.margin
            },

            layout = wibox.layout.fixed.horizontal
        }
    }
end)

-- EOF ------------------------------------------------------------------------
