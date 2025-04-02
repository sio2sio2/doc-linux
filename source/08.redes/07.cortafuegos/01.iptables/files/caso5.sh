#!/bin/sh
 
# Limpiamos todas las tablas
iptables -F
iptables -t nat -F
iptables -t mangle -F
 
# Políticas predeterminadas
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
 
# Tráfico local interno, permitido
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

##
#Enmascaramiento
##
# Salida
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 172.22.0.2
# WEB (interno)
iptables -t nat -A PREROUTING -i eth0 -p tcp -m multiport --dports 80,443 -j DNAT --to-destination 192.168.255.100
 
##
# Acceso al cortafuegos
##
# SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
 
# Respuesta
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
 
##
# Tráfico a través del cortafuegos
##
# DNS
iptables -A FORWARD -o eth0 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -o eth0 -p tcp --dport 53 -j ACCEPT
# WEB (Navegación)
iptables -A FORWARD -o eth0 -p tcp -m multiport --dport 80,443 -j ACCEPT
# WEB (interno)
iptables -A FORWARD -m conntrack --ctstate DNAT -j ACCEPT
 
# Respuesta a los servicios anteriores
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
