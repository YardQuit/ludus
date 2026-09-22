-- ~/.config/hypr/hyprland.lua - Hyprland, set up to feel like COSMIC.
--
-- Seeded into every new account from /etc/skel; from then on it is yours to
-- edit. Hyprland reloads it on save. The stock example it started from is at
-- /usr/share/hypr/hyprland.lua, and every option is on
-- https://wiki.hypr.land/Configuring/
--
-- Keybindings follow COSMIC's defaults (Super-based, vim keys and arrows
-- alike), plus Super+C for an Emacs frame and kitty as the terminal. The
-- colours are the ao-dark palette used everywhere else on this desktop.


-----------------
---- COLOURS ----
-----------------

-- ao-dark, from the Ao Emacs theme (YardQuit/ao).
local ao = {
    bg        = "080d15", -- deep-abyss
    bg_alt    = "1f2937", -- nightfall-blue
    fg        = "dadada", -- ao-white
    fg_dim    = "838a97", -- slate-gray
    accent    = "ff9000", -- blaze-orange
    selection = "7533bd", -- light-purple
    blue      = "2c5484", -- twilight-blue
}


------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local launcher = "hyprlauncher"
local editor   = "emacsclient -c -a ''" -- starts the Emacs daemon if none runs


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- COSMIC's tiling look: thin gaps, a 2px hint around the active window and
-- small corner radii.
hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 0,

        border_size = 2,

        col = {
            active_border   = "rgb(" .. ao.accent .. ")",
            inactive_border = "rgb(" .. ao.bg_alt .. ")",
        },

        resize_on_border = true,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 2,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = { enabled = false },
        blur   = { enabled = false },
    },

    group = {
        col = {
            border_active   = "rgb(" .. ao.accent .. ")",
            border_inactive = "rgb(" .. ao.bg_alt .. ")",
        },
        groupbar = {
            font_family         = "JetBrainsMono Nerd Font",
            text_color          = "rgb(" .. ao.fg .. ")",
            col = {
                active   = "rgb(" .. ao.blue .. ")",
                inactive = "rgb(" .. ao.bg_alt .. ")",
            },
        },
    },

    -- COSMIC lays workspaces out vertically, so they slide up and down.
    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    -- COSMIC's "cursor follows focus": the pointer jumps to the window that
    -- keyboard focus moves to.
    cursor = {
        no_warps = false,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        background_color        = "rgb(" .. ao.bg .. ")",
    },
})

hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "default", style = "slidevert" })


---------------
---- INPUT ----
---------------

-- The same keyboard as COSMIC here: US, and US AltGr-international second.
-- Super+Space switches between them.
hl.config({
    input = {
        kb_layout  = "us,us",
        kb_variant = ",altgr-intl",
        kb_model   = "pc105",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "vertical",
    action    = "workspace",
})


---------------------
---- KEYBINDINGS ----
---------------------
--
-- COSMIC's defaults, action for action where Hyprland has one. Not carried
-- over, for want of an equivalent: Super+W (workspace overview), Super+Y
-- (toggle auto-tiling for a workspace), Super+U / Super+I (focus the parent
-- or child of a tiling group), Super+Alt+S (screen reader) and
-- Super+Ctrl+Escape (compositor debug overlay).

local mod = "SUPER"

local bind = hl.bind

-- Session
bind(mod .. " + Escape",         hl.dsp.exec_cmd("loginctl lock-session"))
bind(mod .. " + SHIFT + Escape", hl.dsp.exec_cmd("hyprshutdown"))
bind(mod .. " + ALT + Escape",   hl.dsp.exit())

-- Close
bind(mod .. " + Q", hl.dsp.window.close())
bind("ALT + F4",    hl.dsp.window.close())

-- Focus and move, by arrow or by h/j/k/l
local directions = {
    { "left",  "h", "l" },
    { "down",  "j", "d" },
    { "up",    "k", "u" },
    { "right", "l", "r" },
}

for _, d in ipairs(directions) do
    local arrow, vim, dir = d[1], d[2], d[3]
    for _, key in ipairs({ arrow, vim }) do
        bind(mod .. " + " .. key,               hl.dsp.focus({ direction = dir }))
        bind(mod .. " + SHIFT + " .. key,       hl.dsp.window.move({ direction = dir }))
        bind(mod .. " + ALT + " .. key,         hl.dsp.focus({ monitor = dir }))
        bind(mod .. " + SHIFT + ALT + " .. key, hl.dsp.window.move({ monitor = dir }))
    end
end

-- Workspaces 1-9; 0 is COSMIC's "last workspace", the empty one after the
-- rest, which here is the first empty workspace on this monitor.
for i = 1, 9 do
    bind(mod .. " + " .. i,         hl.dsp.focus({ workspace = tostring(i) }))
    bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
bind(mod .. " + 0",         hl.dsp.focus({ workspace = "emptym" }))
bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "emptym" }))

-- Previous and next workspace on this monitor. COSMIC stacks them
-- vertically, and takes left/up as previous and right/down as next.
for _, key in ipairs({ "left", "up", "h", "k" }) do
    bind(mod .. " + CTRL + " .. key,         hl.dsp.focus({ workspace = "r-1" }))
    bind(mod .. " + SHIFT + CTRL + " .. key, hl.dsp.window.move({ workspace = "r-1" }))
end
for _, key in ipairs({ "right", "down", "l", "j" }) do
    bind(mod .. " + CTRL + " .. key,         hl.dsp.focus({ workspace = "r+1" }))
    bind(mod .. " + SHIFT + CTRL + " .. key, hl.dsp.window.move({ workspace = "r+1" }))
end

bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Tiling
bind(mod .. " + O", hl.dsp.layout("togglesplit"))                 -- orientation
bind(mod .. " + S", hl.dsp.group.toggle())                        -- stacking
bind(mod .. " + G", hl.dsp.window.float({ action = "toggle" }))   -- floating
bind(mod .. " + X", hl.dsp.window.swap({ next = true }))          -- swap

-- Window state
bind(mod .. " + M",   hl.dsp.window.fullscreen({ mode = "maximized" }))
bind(mod .. " + F11", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Resize mode: Super+R grows, Super+Shift+R shrinks; arrows or h/j/k/l
-- pick the edge, Escape or Return leaves it.
local function resize_mode(name, step)
    hl.define_submap(name, function()
        local moves = {
            { "left",  "h", -step, 0 },
            { "right", "l",  step, 0 },
            { "up",    "k", 0, -step },
            { "down",  "j", 0,  step },
        }
        for _, m in ipairs(moves) do
            for _, key in ipairs({ m[1], m[2] }) do
                hl.bind(key, hl.dsp.window.resize({ x = m[3], y = m[4], relative = true }), { repeating = true })
            end
        end
        hl.bind("escape", hl.dsp.submap("reset"))
        hl.bind("return", hl.dsp.submap("reset"))
    end)
end
resize_mode("resize-outwards", 40)
resize_mode("resize-inwards", -40)
bind(mod .. " + R",         hl.dsp.submap("resize-outwards"))
bind(mod .. " + SHIFT + R", hl.dsp.submap("resize-inwards"))

-- Mouse
bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Zoom, in COSMIC's 50% steps
local function zoom(step)
    return function()
        local factor = hl.get_config("cursor.zoom_factor") or 1
        hl.config({ cursor = { zoom_factor = math.max(1, factor + step) } })
    end
end
for _, key in ipairs({ "equal", "period" }) do bind(mod .. " + " .. key, zoom(0.5)) end
for _, key in ipairs({ "minus", "comma" }) do bind(mod .. " + " .. key, zoom(-0.5)) end

-- Applications
bind(mod .. " + T",     hl.dsp.exec_cmd(terminal))
bind(mod .. " + C",     hl.dsp.exec_cmd(editor))
bind(mod .. " + B",     hl.dsp.exec_cmd("xdg-open https://"))
bind(mod .. " + F",     hl.dsp.exec_cmd("xdg-open ~"))
bind(mod .. " + A",     hl.dsp.exec_cmd(launcher))
bind(mod .. " + slash", hl.dsp.exec_cmd(launcher))
bind(mod .. " + SUPER_L", hl.dsp.exec_cmd(launcher), { release = true })
bind(mod .. " + space", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- Window switcher: Alt+Tab and Super+Tab, with Shift for backwards
local function cycle(forward)
    return function()
        hl.dispatch(hl.dsp.window.cycle_next({ next = forward }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    end
end
bind("ALT + Tab",              cycle(true))
bind("ALT + SHIFT + Tab",      cycle(false))
bind(mod .. " + Tab",          cycle(true))
bind(mod .. " + SHIFT + Tab",  cycle(false))

-- Screenshot of a selected area, saved to ~/Pictures/Screenshots and
-- copied to the clipboard
bind("Print", hl.dsp.exec_cmd(
    "d=\"$(xdg-user-dir PICTURES 2>/dev/null || echo \"$HOME/Pictures\")/Screenshots\"; " ..
    "mkdir -p \"$d\"; f=\"$d/Screenshot_$(date +%Y%m%d_%H%M%S).png\"; " ..
    "grim -g \"$(slurp)\" \"$f\" && wl-copy < \"$f\""))

-- Media and hardware keys
local held = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      held)
bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  held)
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  held)
bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    -- Ignore maximize requests from apps; Super+M is how a window maximizes.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})
