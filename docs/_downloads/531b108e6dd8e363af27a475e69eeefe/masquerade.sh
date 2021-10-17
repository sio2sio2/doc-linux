#!/bin/sh
#
# Uso:
# up bin/masquerade.sh eth1 eth2
# plugin /usr/lib/openvpn/openvpn-plugin-down-root.so
# "/etc/openvpn/bin/masquerade.sh eth1 eth2"
#
# Para servidores VPN que NO son las puertas de enlace de
# las redes a las que pertenece, enmascara el tráfico
# procedente de los clientes VPN, a fin de que éstos se
# puedan comunicar con el resto de dispositivos locales
# de red.
#

# En el arranque, la variable de ambiente script_type vale "up".
[ "${script_type}" = "up" ] && A=A || A=D

# En el arranque, se añaden otros argumentos, el primero de los
# cuales, es la propia interfaz tun que crea el servidor.
ifaces=""
while [ $# -gt 0 ] && [ "$1" != "${dev}" ]; do
   [ -L "/sys/class/net/$1" ] && ifaces="$ifaces $1"
   shift
done 

for i in $ifaces; do
   iptables -t nat -$A POSTROUTING -s ${ifconfig_local}/${ifconfig_netmask} -o $i -j MASQUERADE
done
