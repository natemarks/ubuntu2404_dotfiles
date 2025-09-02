#!/usr/bin/env bash
# I use temp dirs all the time
alias cd_temp='cd $(mktemp -d -t deleteme.XXXXXX --tmpdir=$HOME/tmp)'
alias mk_temp='mktemp -d -t deleteme.XXXXXX --tmpdir=$HOME/tmp'
alias rm_temp='find -L ~/tmp -type d -name "deleteme.*" -print 2> /dev/null | xargs rm -rf'
