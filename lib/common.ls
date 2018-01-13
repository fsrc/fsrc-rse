require! {
  'prelude-ls': {
    each
    tail
    initial
    map
    lines
    group-by
    keys
    maximum-by
  }
  'child_process': {
    spawn
    exec
  }
  'util' : {
    inspect
  }
}

MOSH  = \mosh
SM    = \abduco
SHELL = \zsh
SSH   = \ssh
SC    = \#

export create-cmd = (client, host, session, index) ->
  name = "#{session}#{SC}#{index}"
  title = "#{host}#{SC}#{name}"
  {
    mosh : [ '-T', title, '-e', MOSH, host, '--', SM,   '-c', name, SHELL ]
    ssh : [ '-T', title, '-e', SSH, host, '-t', '--', SM, '-c', name, SHELL ]
  }[client]

export open-cmd = (client, host, session, index) ->
  name = "#{session}#{SC}#{index}"
  title = "#{host}#{SC}#{name}"
  {
    mosh : [ '-T', title, '-e', MOSH, host, '--', SM,   '-a', name ]
    ssh : [ '-T', title, '-e', SSH, host, '-t', '--', SM, '-a', name ]
  }[client]

export list-cmd = (host) ->
  "ssh #{host} 'abduco -l'"

export focused = (callback) ->
  (err, stdout, stderr) <- exec('xtitle')

  [host, session, index] = stdout.split(SC)

  id = { host: host, session: session, index: index }

  if not index?
  then callback(null)
  else callback(id)


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
  spawn(
    'st',
    create-cmd(client, host, session, index),
    {detached: true, stdio:'ignore'}
  ).unref!

export open = (client, host, session-name) ->
  (list) <- sessions(host)
  session = list[session-name]
  if not session?
    console.log "Creating session #{session-name}"
    create-new(client, host, session-name, 0)
  else
    console.log "Open existing"
    session |> each (window) ->
      spawn(
        'st',
        open-cmd(client, host, window.name, window.index),
        {detached: true, stdio:'ignore'}
      ).unref!

