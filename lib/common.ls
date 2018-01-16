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
    spawn
    exec
  }
  'util' : {
    inspect
  }
}

MOSH  = \mosh
SM    = \abduco
SHELL = \dvtm
SSH   = \ssh
SC    = \#

export dmenu-cmd = (prompt) ->
  [ '-p', "'#{prompt}'" ]

export create-cmd = (client, host, session, index) ->
  name = "#{session}#{SC}#{index}"
  title = "#{host}#{SC}#{name}"
  {
    mosh : [ '-T', title, '-e', MOSH, host, '--', SM,   '-c', name, SHELL ]
    ssh :  [ '-T', title, '-e', SSH, host, '-t', '--', SM, '-c', name, SHELL ]
  }[client]

export open-cmd = (client, host, session, index) ->
  name = "#{session}#{SC}#{index}"
  title = "#{host}#{SC}#{name}"
  {
    mosh : [ '-T', title, '-e', MOSH, host, '--', SM,   '-a', name ]
    ssh :  [ '-T', title, '-e', SSH, host, '-t', '--', SM, '-a', name ]
  }[client]

export list-cmd = (host) ->
  "ssh #{host} 'abduco -l'"


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
    (id-list) <- windows!

    session
    |> filter (window) ->
      not (id-list |> any (id) ->
        id.host == host and
        id.session == window.name and
        id.index == window.index)
    |> each (window) ->
      spawn(
        'st',
        open-cmd(client, host, window.name, window.index),
        {detached: true, stdio:'ignore'}
      ).unref!

