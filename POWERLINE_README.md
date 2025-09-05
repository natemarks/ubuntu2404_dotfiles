in ubuntu 24.04, I switched to installing powerling with packages.  Then I copied the default config trees :

/usr/share/powerline/config_files/colorschemes
/usr/share/powerline/config_files/themes

into ~/.config/powerline

Finally I added the gitstatus segment into the powerline/themes/shell/default_leftonly.json. That requires color config for gitstatus, so I customized powerline/colorschemes/shell/default.json


## TODO

I may tweak the other extension: ~/.config/powerline/[shell|tmux|vim]

