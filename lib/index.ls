require! {
  'prelude-ls' : {
    head
    tail
    filter
    reject
    any
  }
  \./cli : {
    list-cli
    open-cli
    new-cli
  }
  \./help
}

say = console.log

args = process.argv |> tail
exec = args |> head
args = args |> tail

commands = <[ help list open new ]>

help-text = help(exec, commands)

flags = args |> filter (arg) -> arg[0] == '-'
args  = args |> reject (arg) -> arg[0] == '-'

options = {
  dmenu: flags |> any (alt) -> alt == '-d'
}

host    = args |> head
command = args.1
session = args.2
client  = 'mosh'

host = process.env.RSE_HOST if not host?

switch command
case \help then say help-text
case \list then list-cli(options, host)
case \open then open-cli(options, client, host, session)
case \new  then  new-cli(options, client, host, session)
default say help-text

