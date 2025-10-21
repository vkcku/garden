$env.config = {
  buffer_editor: "hx"
  footer_mode: "auto"
  show_banner: false
};

$env.config.history = {
  file_format: "sqlite"
  isolation: false
};

$env.config.datetime_format.normal = "%Y/%m/%d %I:%M:%S %p"
$env.config.table.show_empty = false;
$env.config.cursor_shape.emacs = "line";

load-env {
  EDITOR: "hx"
}

# Same as `save` but will also create the directories if they do not exist.
def supersave [
  path: string
  --force (-f)
] {
  mkdir ($path | path expand | path dirname)
  save --force=$force $path
}
