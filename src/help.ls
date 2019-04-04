module.exports = (exec, commands) -> """
Usage: #{exec} [options] [host] <#{commands.join(\|)}> [session]

Commands:
  help    Display this help page
  list    List available sessions on host
  open    Open or create session on host
  new     Create new window in session

Options:
  -d      Use dmenu for navigation

Arguments:
  host    Which host to connect to. $RSE_HOST for default value.
  session Which session to connect to.

Example:
  rse open myhost.com new-session-name
  rse new myhost.com existing-session-name

Local external dependencies:
  st      Simple Terminal acts as the window host
  ssh     For communication with server
  mosh    For faster visual communication (optional)
  xtitle  Retreives name of active window
  wmctrl  Retreives names of open windows
  dmenu   List sessions in menu

Remote dependencies:
  mosh    (optional)
  ssh     (required)
  abduco  Manages terminal sessions on server (required)

Notes:
  rse can make guesses based on the current active window title.
  This is useful if you configure your window manager to create
  a new rse window on keyboard shortcut. If the active window
  has a title that matches the rse naming convention it will
  create a new window in the active session.

"""

