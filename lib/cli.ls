require! {
  'prelude-ls' : {
    each
    keys
  }
  \./common : {
    create-new
    next-index
    sessions
    focused
    open
    dmenu
  }
}

export list-cli = (options, host) ->
  if not host?
    console.log "Host is required for list command"
  else
    (list) <- sessions(host)
    list
    |> keys
    |> each (key) ->
      console.log("#{key} #{list[key].length}")

export open-cli = (options, client, host, session) ->
  (id) <- focused!

  host-name = if host?
  then host
  else id?.host

  session-name = if session?
  then session
  else id?.session

  if not host-name?
    console.log "Host name is required for 'open' command"
  else
    if not client?
      console.log "Client is required for 'open' command"

    else if not session-name? and not options.dmenu
      console.log "Session name is required for 'open' command"

    else
      if options.dmenu
        (list) <- sessions(host-name)
        (session-name) <- dmenu("Session", keys(list))
        console.log session-name
        open(client, host-name, session-name)
      else
        open(client, host-name, session-name)


export new-cli  = (options, client, host, session) ->
  (id) <- focused!

  host-name = if host?
  then host
  else id?.host

  session-name = if session?
  then session
  else id?.session

  if not host-name?
    console.log "Host name is required for 'new' command"

  else
    (list) <- sessions(host-name)

    if not client?
      console.log "Client is required for 'new' command"

    else if not session-name?
      console.log "Session name is required for 'new' command"

    else if not list[session-name]?
      console.log "Session '#{session-name}' is missing on host '#{host-name}'"

    else
      index = next-index(list, session-name)
      create-new(client, host-name, session-name, index)

