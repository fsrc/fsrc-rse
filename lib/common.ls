require! {
  'prelude-ls': {
    any
    filter
    each
    tail
    initial
    map
    lines
    group-by
    keys
    maximum-by
    drop
  }
  'child_process': {
    spawn : spawn2
    exec
  }
  'util' : {
    inspect
  }
  './config'
}

MOSH       = config.mosh.cmd
SSH        = config.ssh.cmd

SM         = config.session-manager.cmd
SM-LIST    = config.session-manager.list-args

SHELL      = config.shell
SC         = config.separator

TERMINAL   = config.terminal.cmd
TERM-TITLE = config.terminal.title-arg
TERM-EXEC  = config.terminal.execute-arg
TERM-ARGS  = config.terminal.args

# MOSH     = \mosh
# SM       = \abduco
# SHELL    = \zsh
# SSH      = \ssh
# SC       = \#
# TERMINAL = <[ terminator --profile=fsrc.pw ]>

spawn = (term, args) ->

  options = if config.debug
    { detached: false, stdio:'inherit' }
  else
    { detached: true, stdio:'ignore' }

  if config.debug
    console.error ...

  proc = spawn2( term, args, options )


  if not config.debug
    proc.unref!

  else
    proc.on \close, (code, signal) ->
      console.error \CLOSED
      console.error \CODE:, code
      console.error \SIGNAL:, signal

    proc.on \error, (err) ->
      console.error 'SUB PROCESS ERROR:'
      console.error err

    proc.on \exit, (code, signal) ->
      console.error \EXIT
      console.error \CODE:, code
      console.error \SIGNAL:, signal

  proc

export dmenu-cmd = (prompt) ->
  [ '-p', "'#{prompt}'" ]

export create-cmd = (term-args, client, host, session, index) ->
  name = "#{session}#{SC}#{index}"
  title = "#{host}#{SC}#{name}"
  {
    mosh : term-args ++ [ TERM-TITLE, title, TERM-EXEC, "#MOSH #host -- #SM -c #name #SHELL" ]
    ssh :  term-args ++ [ TERM-TITLE, title, TERM-EXEC, "#SSH #host -t -- #SM -c #name #SHELL" ]
  }[client]

export open-cmd = (term-args, client, host, session, index) ->
  name = "#{session}#{SC}#{index}"
  title = "#{host}#{SC}#{name}"
  {
    mosh : term-args ++ [ TERM-TITLE, title, TERM-EXEC, "#MOSH #host -- #SM -a #name" ]
    ssh :  term-args ++ [ TERM-TITLE, title, TERM-EXEC, "#SSH #host -t -- #SM -a #name" ]
  }[client]

export list-cmd = (host) ->
  "#SSH #{host} '#SM #SM-LIST'"


export window-name-to-id = (name) ->
  [host, session, index] = name.
    replace('\n', '').
    split(SC)

  host: host
  session: session
  index: parseInt(index)

export dmenu = (prompt, list, callback) ->
  cp = spawn('dmenu', dmenu-cmd(prompt))

  cp.stdin.write(Buffer.from(list.join("\n")))
  cp.stdin.end!

  cp.stdout.on('data', (d) ->
    choice = d.to-string!.replace(\\n, '')
    callback(choice))

export focused = (callback) ->
  (err, stdout, stderr) <- exec('xtitle')

  id = window-name-to-id(stdout)

  if not id.index?
  then callback(null)
  else callback(id)

export windows = (callback) ->
  (err, stdout, stderr) <- exec('wmctrl -l')
  id-list = stdout
  |> lines
  |> map (line) ->
    words = line.split(' ')
    window-name-to-id((words |> drop 4).join(' '))
  |> filter (id) ->
    id.host? and id.session? and id.index?

  callback(id-list)

export sessions = (host, callback) ->
  (err, stdout, stderr) <- exec(list-cmd(host))
  if err?
    console.log err.message
  else
    stdout
    |> lines |> tail |> initial
    |> map (line) ->
      columns       = line.split(\\t)
      [name, index] = columns.2.split(SC)
      active : columns.0.0 == '*'
      date   : new Date(columns.1)
      name   : name
      index  : parseInt(index)
    |> group-by (.name)
    |> callback

export next-index = (sessions, session) ->
  if not sessions[session]?
  then 0
  else
    index = (
      sessions[session]
      |> maximum-by (.index)
    ).index + 1

export create-new = (client, host, session, index) ->
  spawn(TERMINAL, create-cmd(TERM-ARGS, client, host, session, index))

export open = (client, host, session-name) ->
  (list) <- sessions(host)
  session = list[session-name]
  if not session?
    console.log "Creating session #{session-name}"
    create-new(client, host, session-name, 0)
  else
    console.log "Open existing"
    (id-list) <- windows!

    session
    |> filter (window) ->
      not (id-list |> any (id) ->
        id.host == host and
        id.session == window.name and
        id.index == window.index)
    |> each (window) ->
      spawn(TERMINAL, open-cmd(TERM-ARGS, client, host, window.name, window.index))

