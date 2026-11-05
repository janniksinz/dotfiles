-------------------
--- KEYBINDINGS ---
-------------------

-- Called from hyprland.lua as require("modules.binds")(programs)
return function(programs)
    local mainMod = "SUPER"

    local bind = hl.bind

    -- Custom
    bind(mainMod .. " + F", hl.dsp.window.fullscreen())
    bind(mainMod .. " + B", hl.dsp.exec_cmd("brave"))
    bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))

    -- Hyprlock
    bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

    -- Hyprshot
    bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("hyprshot -m window"))
    bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprshot -m region"))
    bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprshot -m output"))

    -- Core
    bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal))
    bind(mainMod .. " + C",      hl.dsp.window.close())
    bind(mainMod .. " + M",      hl.dsp.exit())
    bind(mainMod .. " + E",      hl.dsp.exec_cmd(programs.fileManager))
    bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
    bind(mainMod .. " + R",      hl.dsp.exec_cmd(programs.menu))
    bind(mainMod .. " + P",      hl.dsp.window.pseudo())
    bind(mainMod .. " + J",      hl.dsp.layout("togglesplit"))

    -- Focus / move windows
    for _, dir in ipairs({ "left", "right", "up", "down" }) do
        bind(mainMod .. " + " .. dir,             hl.dsp.focus({ direction = dir }))
        bind(mainMod .. " + SHIFT + " .. dir,     hl.dsp.window.move({ direction = dir }))
    end

    -- Workspaces / move to workspace (key 0 = workspace 10)
    for i = 1, 10 do
        local key = i % 10
        bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
        bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end

    -- Special workspace
    bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
    bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

    -- Mouse
    bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
    bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
    bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

    -- Media (bindel = locked + repeating, bindl = locked)
    local el = { locked = true, repeating = true }
    local l  = { locked = true }
    bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), el)
    bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      el)
    bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     el)
    bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   el)
    bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       l)
    bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), l)
    bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), l)
    bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   l)
end
