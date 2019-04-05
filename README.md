# rse
Remote sessions with multiple local WM terminal windows (optimized for i3)

# Background

I do most of my work in a terminal on a VPS. This allows me to switch between different work machines, as long as I have a Internet connection.

RSE manages my different work sessions/projects on remote machines. 

I thought that it might be useful to others, so I extracted the personal settings into a config-file (JSON) and published it.

# Components/Dependencies


* xtitle
* wmctrl

* SSH
* MOSH
* terminal (ex: urxvt, xterm, st, terminator or your prefered terminal)
* session manager (ex: abduco, detach, tmux, screen)
* shell (ex: zsh, bash, sh)
* dmenu (or rofi)

# How does it work?

rse opens a new terminal and executes mosh to the server within it. rse forwards a session creation or attachment to what ever session manager you are using.

The terminal window title will be named <server>#<session>#<window-number>. The session in the session manager will be named <session>#<window-number>.

rse uses window titles and session names to manage state.

# Installation

Install cli command

  npm install fsrc-rse

# Usage

Get instructions by executing

  rse


