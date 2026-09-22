-- Minimal Hyprland config for the SDDM Wayland greeter.
-- SDDM starts the greeter itself after the compositor is ready.
-- From Omarchy. Omarchy is MIT-licensed; its notice is at /usr/share/licenses/ludus/Omarchy-LICENSE.
hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
    background_color = "rgb(080d15)", -- ao-dark deep-abyss, behind the theme
  },

  animations = {
    enabled = false,
  },
})
