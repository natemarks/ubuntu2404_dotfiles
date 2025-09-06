# tmux

BLOCKED:
tmux throws an errro trying to use site packages from pyenv to configure powerline.  I need to figure out how to get the correct python version to be used in the tmux configuration.

good resource:
https://github.com/tmux-plugins/tmux-sensible

https://www.youtube.com/watch?v=U-omALWIBos

config file:
 - rebind the prefix to CTRL-a
 - unbind the CTRL-b prefix


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
C-a s - list sessions
C-a | - split the window vertically
C-a - - split the window horizontally


C-a j - expand pane down
C-a k - expand pane up
C-a h - expand pane left
C-a l - expand pane right

C-a m - toggle maximize pane


## managing plugins with tpm

install plugins:
```bash
C-a + I
```

update plugins ():
```bash
C-a + U
```

remove unlisted plugins:
```bash
C-a + alt + u
```
