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
  (id) <~ focused!

  host-name = if host?
  then host
  else id?.host

  session-name = if session?
  then session
  else id?.session

  if not client?
    console.log "Client is required for open command"

  else if not host?
    console.log "Host is required for open command"

  else if not session?
    console.log "Session is required for open command"

  else
    open(client, host, session)

export new-cli  = (client, host, session, index) ->

