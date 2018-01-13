module.exports = (exec, commands) -> """
Usage: #{exec} <#{commands.join(\|)}> [host] [session]

Commands:
  help    Display this help page
  list    List available sessions on host
  open    Open or create session on host
  new     Create new window in session

Example:
  rse open myhost.com new-session-name

  rse new myhost.com existing-session-name

Local external dependencies:
  st      Simple Terminal acts as the window host
  ssh     For communication with server
  mosh    For faster visual communication (optional)
  xtitle  Retreives name of active window
  wmctrl  Retreives names of open windows

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

