require! {
  'prelude-ls' : {
    head
    tail
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

command = args |> head
host = args.1
session = args.2
client = 'ssh'

switch command
case \help then say help-text
case \list then list-cli(host)
case \open then open-cli(client, host, session)
case \new  then new-cli(client, host, session)
default say help-text

