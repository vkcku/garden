module "garden" {
  const wallpapers_dir = "~/wallpapers" | path expand;

  def get-wallpapers [] {
    ls $wallpapers_dir | get name 
  }

  # Set the given image as the wallpaper.
  #
  # If no value is provided, then a random one is selected.
  export def "garden wallpaper" [wallpaper?: string@get-wallpapers] {
    let selected_wallpaper = match $wallpaper {
      null => {
        get-wallpapers | shuffle | first
      },
      _ => $wallpaper
    }

    hyprctl hyprpaper reload $",($wallpapers_dir | path join $selected_wallpaper)"
  }
}

use "garden"
