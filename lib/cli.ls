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
  }
}

export list-cli = (host) ->
  if not host?
    console.log "Host is required for list command"
  else
    (list) <- sessions(host)
    list
    |> keys
    |> each (key) ->
      console.log("#{key} #{list[key].length}")

export open-cli = (client, host, session) ->
  (id) <- focused!

  host-name = if host?
  then host
  else id?.host

  session-name = if session?
  then session
  else id?.session

  if not client?
    console.log "Client is required for 'open' command"

  else if not host?
    console.log "Host name is required for 'open' command"

  else if not session-name?
    console.log "Session name is required for 'open' command"

  else
    open(client, host, session-name)

export new-cli  = (client, host, session) ->
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

