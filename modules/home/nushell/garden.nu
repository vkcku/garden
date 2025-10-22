module "garden" {
  const wallpapers_dir = "~/wallpapers" | path expand;

  def get-wallpapers [] {
    ls $wallpapers_dir | get name 
  }

  # Set the given image as the wallpaper.
  #
  # If no value is provided, then a random one is selected.
  export def "wallpaper" [wallpaper?: string@get-wallpapers] {
    let selected_wallpaper = match $wallpaper {
      null => {
        get-wallpapers | shuffle | first
      },
      _ => $wallpaper
    }

    hyprctl hyprpaper reload $",($wallpapers_dir | path join $selected_wallpaper)"
  }

  # Start hyprland if it is not already running on this tty.
  export def "hyprland" [] {
    if "HYPRLAND_INSTANCE_SIGNATURE" in $env {
      return
    }

    uwsm check may-start
    if $env.LAST_EXIT_CODE != 0 {
      error make --unspanned { msg: "uwsm check failed" }
    }

    uwsm start default
  }
}

use "garden"
