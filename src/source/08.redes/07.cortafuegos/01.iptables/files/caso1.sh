#!/bin/sh
 
# Limpiamos todas las tablas
iptables -F
iptables -t nat -F
iptables -t mangle -F
 
# Lista blanca
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
 
# Tráfico local interno, permitido
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Enmascaramiento
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 172.22.0.2
 
# Acceso al servidor SSH (petición y respuesta)
iptables -A INPUT -i eth1 -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
 
# Peticiones DNS (es requisito previo para navegar)
iptables -A FORWARD -o eth0 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -o eth0 -p tcp --dport 53 -j ACCEPT
 
# Peticiones WEB
iptables -A FORWARD -o eth0 -p tcp -m multiport --dport 80,443 -j ACCEPT
 
# Respuestas a los servicios anteriores
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
