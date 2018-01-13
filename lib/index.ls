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
}

say = console.log

args = process.argv |> tail
exec = args |> head
args = args |> tail

commands = <[ help list open new ]>

help = """
Usage: #{exec} #{commands.join(\|)} [host] [session]

Commands:
  help    Display this help page
  list    List available sessions on host
  open    Open or create session on host
  new     Create new window in session

Example:

"""

command = args |> head
host = args.1
session = args.2
client = 'ssh'

switch command
case \help then say help
case \list then list-cli(host)
case \open then open-cli(client, host, session)
case \new  then new-cli(client, host, session,  index)
default say help

