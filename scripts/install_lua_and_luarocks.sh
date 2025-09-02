#!/usr/bin/env bash
# installs /usr/local/bin/lua and /usr/local/bin/luarocks

LUA_VERSION="5.4.7"
LUA_ROCKS_VERSION="3.11.1"

curl -JLO "http://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz"
tar -zxf "lua-${LUA_VERSION}.tar.gz"
cd "lua-${LUA_VERSION}" || exit 1

make linux test
sudo make install

curl -JLO "http://luarocks.github.io/luarocks/releases/luarocks-${LUA_ROCKS_VERSION}.tar.gz"
tar -xzvf "luarocks-${LUA_ROCKS_VERSION}.tar.gz"
cd "luarocks-${LUA_ROCKS_VERSION}" || exit 1
