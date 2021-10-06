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
    flatten
  }
  'child_process': {
    spawn : spawn2
    exec
  }
  'util' : {
    inspect
  }
  'fsrc-config' : fsrc-config
}

say = -> console.log(it);it

config = fsrc-config(
  \rse,
  {
    "ssh": { "cmd":"ssh" },
    "mosh": { "cmd":"mosh" },
    "sessionManager": {
      "cmd":"dtach",
      "listArg":"-l",
      "createArgs" : ['zsh']
      },
    "shell": "zsh",
    "separator": "#",
    "terminal": { "cmd" : "terminator", "titleArg": "-T", "executeArg": "-e", "args" : [] },
    "debug": true
  })


MOSH       = config.mosh.cmd
SSH        = config.ssh.cmd

SM         = config.session-manager.cmd
SM-LIST    = config.session-manager.list-arg

SHELL      = config.shell
SC         = config.separator

DMENU      = config.dmenu.cmd
DMENU-PROMPT-ARG = config.dmenu.prompt-arg
DMENU-ARGS = config.dmenu.args

TERMINAL   = config.terminal.cmd
TERM-TITLE = config.terminal.title-arg
TERM-EXEC  = config.terminal.execute-arg
TERM-ARGS  = config.terminal.args

spawn = (term, args) ->

  options = if config.debug
    { detached: false, stdio:'inherit' }
  else
    { detached: true, stdio:'ignore' }

  if config.debug
    # Print arguments
    console.error ...
    console.error term, args.join(' ')

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
  DMENU-ARGS ++ [ DMENU-PROMPT-ARG, "'#{prompt}'" ]

if SM != 'dtach'
  export create-cmd = (term-args, client, host, session, index) ->
    name = "#{session}#{SC}#{index}"
    title = "#{host}#{SC}#{name}"
    {
      mosh : term-args ++ [ TERM-TITLE, title, TERM-EXEC, MOSH, host, "--", SM, "-c", name, SHELL ]
      ssh :  term-args ++ [ TERM-TITLE, title, TERM-EXEC, SSH,  host, "-t", "--", SM, "-c", name, SHELL ]
    }[client]

  export open-cmd = (term-args, client, host, session, index) ->
    name = "#{session}#{SC}#{index}"
    title = "#{host}#{SC}#{name}"
    {
      mosh : term-args ++ [ TERM-TITLE, title, TERM-EXEC, MOSH, host, "--", SM, "-a", name ]
      ssh :  term-args ++ [ TERM-TITLE, title, TERM-EXEC, SSH, host, "-t", "--", SM, "-a", name ]
    }[client]

  export list-cmd = (host) ->
    say "#SM"
    "#SSH #{host} '#SM #SM-LIST'"

  export sessions = (host, callback) ->
    (err, stdout, stderr) <- exec(list-cmd(host))
    if err?
      console.log err.message
    else
      say stdout
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

else
  export create-cmd = (term-args, client, host, session, index) ->
    name = "#{session}#{SC}#{index}"
    title = "#{host}#{SC}#{name}"
    {
      mosh : term-args ++ [ TERM-TITLE, title, TERM-EXEC, MOSH, host, "--", "dtach", "-c", "~/.dtach/#name", SHELL ]
      ssh :  term-args ++ [ TERM-TITLE, title, TERM-EXEC, SSH,  host, "-t", "--", "dtach", "-c", "~/.dtach/#name", SHELL ]
    }[client]

  export open-cmd = (term-args, client, host, session, index) ->
    name = "#{session}#{SC}#{index}"
    title = "#{host}#{SC}#{name}"
    {
      mosh : term-args ++ [ TERM-TITLE, title, TERM-EXEC, MOSH, host, "--", "dtach", "-a", "~/.dtach/#name"]
      ssh :  term-args ++ [ TERM-TITLE, title, TERM-EXEC, SSH, host, "-t", "--", "dtach", "-a", "~/.dtach/#name"]
    }[client]

  export list-cmd = (host) ->
    "#SSH #{host} 'ls ~/.dtach'"

  export sessions = (host, callback) ->
    (err, stdout, stderr) <- exec(list-cmd(host))
    if err?
      console.log err.message
    else
      stdout
      |> lines
      |> filter (!= "")
      |> map (line) ->
        [name, index] = line.split(SC)
        name   : name
        index  : parseInt(index)
      |> group-by (.name)
      |> say
      |> callback


export window-name-to-id = (name) ->
  [host, session, index] = name.
    replace('\n', '').
    split(SC)

  host: host
  session: session
  index: parseInt(index)

export dmenu = (prompt, list, callback) ->
  cp = spawn2(DMENU, dmenu-cmd(prompt))

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

