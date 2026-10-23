# tmux

Prefix is `Ctrl-]` (`Ctrl-b` is unbound).

## Setup

```bash
make packages      # tmux, fzf, fd-find, wl-clipboard / xclip
make sesh          # install/upgrade sesh to the latest release, link ~/.config/sesh/sesh.toml
make config_tmux   # clone tpm, link ~/.tmux.conf, install + update plugins
```

All three are safe to re-run. Re-run `make config_tmux` to update plugins, or
`make install_sesh` to upgrade sesh.

good resource:
https://github.com/tmux-plugins/tmux-sensible

https://www.youtube.com/watch?v=U-omALWIBos

## Examples

create a session named 'MySession':
```bash
tmux new -s MySession
```

detach from a session:
```bash
tmux detach
```

see a  list of sessions:
```bash
tmux ls
```

re-attach to a session:
```bash
tmux attach -t MySession
```

to list the sessions from within tmux:
``` 
prefix + s
```


## Organizing 

Tmux window is a grouping opf split panes. custom mappings make this a littel easier to manage.
prefix t - sesh session picker
prefix s - list sessions
prefix | - split the window vertically
prefix - - split the window horizontally
prefix r - reload ~/.tmux.conf

prefix J - expand pane down
prefix K - expand pane up
prefix H - expand pane left
prefix L - expand pane right

prefix m - toggle maximize pane

copy mode (vi keys): prefix [ , Space to start selecting, y to copy to the system clipboard


## managing plugins with tpm

install plugins:
```bash
prefix + I
```

update plugins ():
```bash
prefix + U
```

remove unlisted plugins:
```bash
prefix + alt + u
```
