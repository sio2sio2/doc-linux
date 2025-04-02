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

# Enmascaramiento
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 172.22.0.2
 
# Redirección HTTP -> SQUID
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j REDIRECT --to-port 3128
 
##
# Acceso al cortafuegos
##
# SSH
iptables -A INPUT -i eth1 -p tcp --dport 22 -j ACCEPT
# SQUID
iptables -A INPUT -i eth1 -m conntrack --ctstate DNAT -j ACCEPT
 
# DNS
iptables -A INPUT -i eth1 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -i eth1 -p tcp --dport 53 -j ACCEPT
 
# Respuesta
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
 
##
# Tráfico del cortafuegos
##
# DNS
iptables -A OUTPUT -o eth0 -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --dport 53 -j ACCEPT
# HTTP
iptables -A OUTPUT -o eth0 -p tcp --dport 80 -j ACCEPT
 
# Respuesta
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
 
##
# Tráfico a través del cortafuegos
##
# HTTPS
iptables -A FORWARD -o eth0 -p tcp -m multiport --dport 443 -j ACCEPT
 
# Respuesta
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
