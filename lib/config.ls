require! {
  fs : {
    read-file-sync : read-file
    exists-sync : exists
  }
}

HOME   = process.env.HOME
ROOT   = "#HOME/.rserc"
CONFIG = "#HOME/.config/rse/config"

read = (full-path) ->
  data = read-file(full-path, \utf8)

  try
    JSON.parse(data)
  catch ex
    console.error "ERROR: Could not parse JSON in '#full-path'"
    console.error ex.message
    process.exit(255)

config = if exists ROOT
  read(ROOT)

else if exists CONFIG
  read(CONFIG)

else
  console.error """
  ERROR: Configuration missing
  Use either '#ROOT' or '#CONFIG'
  Template: "
  {
    "mosh":"mosh",
    "sessionManager":"abduco",
    "shell": "zsh",
    "ssh": "ssh",
    "separator": "#",
    "terminal": ["urxvtc", <option>, <option>]
  }
  """

  process.exit(255)

module.exports = config

