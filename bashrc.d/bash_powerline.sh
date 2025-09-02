#!/usr/bin/env bash
export PATH="${HOME}/.local/bin":$PATH
powerline-daemon -q
# shellcheck disable=SC2034
POWERLINE_BASH_CONTINUATION=1
# shellcheck disable=SC2034
POWERLINE_BASH_SELECT=1

# locate the powerline bash source file with this
# find $(python -m site --user-site) -type f -name powerline.sh | grep bash/powerline.sh
# should return something like:
#     /home/nate/.local/lib/python3.9/site-packages/powerline/bindings/bash/powerline.sh

# shellcheck disable=SC1090
# if [ -n "$TMUX" ]; then
#   # switch into the system python to access the powerline
#   . ~/bashrc.d/pyenv.sh
#   pyenv shell system
# fi

# run the powerline bash source file
. /usr/share/powerline/bindings/bash/powerline.sh

# if [ -n "$TMUX" ]; then
#   # switch back to the python version that has powerline
#   pyenv shell 3.10.6
# fi
