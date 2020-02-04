#!/bin/sh
#
# Constituye el puente necesario para que el túnel VPN
# sea compartido con el resto de dispositivos de la red.
# 
# Uso:
#
# + en el servidor:
#
#     up   bin/bridge.sh eth0 vpn
#     down bin/bridge.sh eth0 vpn
#
#   donde:
#     - eth0, interfaz física que pertenece al túnel.
#     - vpn, nombre del puente.
#
# + en el cliente:
#
#     up   bin/bridge.sh eth0 eth1 vpn
#     down bin/bridge.sh eth0 eth1 vpn
#
#   donde:
#     - eth0, interfaz que conecta con el router de la red remota.
#     - eth1, interfaz física que pertenece al túnel.
#     - vpn, nombre del puente.


#
# Determina si el script se ejecuta en un servidor o en un cliente.
#
get_type() {
   if [ $# -eq 2 ] || [ "$3" = "$dev" ]; then
      echo "server"
   else
      echo "client"
   fi
}


#
# Obtiene la IP/MASCARA de una interfaz
#
get_config() {
   ip -o addr show | awk '$2 == "'$1'" && $3 == "inet" {print $4}'
}


#
# Obtiene todas las puerta de enlace asociadas a una interfaz.
#
get_gateway() {
   ip route show dev $1 | awk '$2 == "via" {print $1, $2, $3}'
}


type=$(get_type "$@")
if [ "$type" = "client" ]; then
   eth=$1
   shift
   addr_dev=$dev  # dev es una variable de entorno que contiene la interfaz que crea openvpn
   no_addr_dev=$1
else
   addr_dev=$1
   no_addr_dev=$dev
fi

br=$2
tap=$3
mtu=$4

case $script_type in
   up)
      address=$(get_config $addr_dev)
      [ -n "$address" ] || exit 1
      gateways=$(get_gateway $addr_dev)
      ip link add name $br type bridge
      ip link set $br addr $(cat /sys/class/net/$no_addr_dev/address) up
      ip addr del dev $addr_dev $address
      ip link set dev $addr_dev mtu $mtu promisc on up
      ip link set $addr_dev master $br
      ip addr add dev $br $address
      echo "$gateways" | while read entry; do
         ip route add $entry
      done
      ip link set $no_addr_dev master $br
      ip link set dev $no_addr_dev mtu $mtu promisc on up

      if [ "$type" = "client" ] && which ebtables > /dev/null; then
         # Como la puerta de enlace de los clientes remotos es el router
         # de la red local, hay que convertir los paquetes conmutados que
         # generan los clientes remotos en encaminados, excepto los que
         # éstos envían con ip de origen 0.0.0.0 (DHCP).
         ebtables -t broute -A BROUTING -i $no_addr_dev -p ipv4 --ip-src ! 0.0.0.0/32 -j redirect --redirect-target DROP
         iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE
      fi
      ;;
   *)
      address=$(get_config $br)
      gateways=$(get_gateway $br)
      ip addr del dev $br $address
      ip link set $no_addr_dev nomaster
      ip link set $addr_dev nomaster
      ip link del $br
      ip addr add dev $addr_dev $address
      echo "$gateways" | while read entry; do
         ip route add $entry
      done

      if [ "$type" = "client" ] && which ebtables > /dev/null; then
         ebtables -t broute -D BROUTING -i $no_addr_dev -p ipv4 --ip-src ! 0.0.0.0/32 -j redirect --redirect-target DROP
         iptables -t nat -D POSTROUTING -o $eth -j MASQUERADE
      fi
      ;;
esac

