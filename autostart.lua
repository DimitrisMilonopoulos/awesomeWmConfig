-- autostart.lua
-- Autostart Stuff Here
local awful = require("awful")

local function run_once(cmd)
    local findme = cmd
    local firstspace = cmd:find(' ')
    if firstspace then findme = cmd:sub(0, firstspace - 1) end
    awful.spawn.with_shell(string.format(
                               'pgrep -u $USER -x %s > /dev/null || (%s)',
                               findme, cmd), false)
end

-- Network Manager Applet
awful.spawn.with_shell("nm-applet")

-- Sound Applet
awful.spawn.with_shell("killall pa-applet; sleep 1; pa-applet")

-- Disable Bell
awful.spawn.with_shell("xset -b")

-- Bluetooth
awful.spawn.with_shell("blueman-applet")

-- Multilanguage 
awful.spawn.with_shell("setxkbmap -option grp:alt_shift_toggle us,gr")

-- Compositor
awful.spawn.with_shell("picom --experimental-backends")

-- Spotify server
awful.spawn.with_shell("/home/dim/Desktop/init_music.sh")

-- Mpd Cleanup
run_once([[
    ps aux | grep "mpc idleloop player" | grep -v grep | awk '{print $2}' | xargs kill
    ]])



return autostart

-- EOF ------------------------------------------------------------------------
