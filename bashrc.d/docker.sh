#!/usr/bin/env bash
# exec a command in a running container: dr-cmd abcd1234 cmd...
dr-exec() {
  docker exec -it "$1" "${@:2}"
}

# exec a command using fzf to target a running container: dr-cmd  cmd...
drf-exec() {
  containerId=$(docker ps | grep -E 'CONTAINER ID' | fzf | cut -d" " -f1)
  docker exec -it "$containerId" "${@:2}"
}

# run a new container from an image: dr-run <image>
dr-run() {
  docker run -it "$1"
}

# run a new container from an image: dr-run <image>
drf-run() {
  imageId="$(docker images | fzf | awk \{'print $1":"$2'\})"
  docker run -it "$imageId"
}

# syntax: dr-sh <container>
dr-sh() {
  docker exec -it "$1" sh
}

# syntax: dr-log <container>
dr-log() {
  docker logs -f "$1"
}

# syntax: drf-log
drf-log() {
  containerId=$(docker ps -a | grep -E 'CONTAINER ID' | fzf | cut -d" " -f1)
  docker logs -f "containerId"
}

# syntax: dr-build
dr-build() {
  docker build . -t "$1"
  docker run -p 8080:"$2" "$1"
}

# syntax: dr-reset
dr-reset() {
  containerId=$(docker ps -a | grep "$1" | cut -d" " -f1)
  imageId=$(docker inspect --format='{{.Image}}' "$containerId")
  docker rm "$containerId" -f  && docker rmi "$imageId"
}

# syntax:

# syntax: dr-run-dead
dr-run-dead() {
  docker commit "$1" "$1"-image > /dev/null
  docker run -it "$1-image$*"
}

# syntax: dr-reset-log
dr-reset-log() {
  truncate -s 0 "$(docker inspect --format='{{.LogPath}}' "$1")"
}

# syntax: dr-ps
alias dr-ps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}\t{{.Ports}}"'

# syntax: dr-clean
alias dr-clean='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) && docker rmi $(docker images -a -q)'

# syntax dr-prune-all: delete all images for disk space
alias dr-prune-all='docker image prune -a'

# syntax dr-prune-until: delete all images up to a date
alias dr-prune-until='docker image prune -a --force --filter "until=2021-05-01"'
