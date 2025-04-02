#!/bin/sh
#
# Accede al servicio SSH, tocando primero

TOC="11111 22222 33333"

get_server() {
   ssh -G "$@" | awk '$1=="hostname" {print $2}'
}

server=$(get_server "$@")
for p in $TOC; do
   printf "toc... "
   echo "x" | nc -u -q1 "$server" "$p"
done
echo
ssh "$@"
