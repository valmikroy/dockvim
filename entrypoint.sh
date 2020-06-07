#!/usr/bin/env sh

PATH=$GOPATH/bin:$GOROOT/bin:$PATH

reset && clear
cd "${WORKSPACE}" && /usr/local/bin/nvim "$@"
