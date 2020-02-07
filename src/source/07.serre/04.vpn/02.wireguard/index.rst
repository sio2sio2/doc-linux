.. _wireguard:

Wireguard
=========
:program:`wireguard` es una solución alternativa a :ref:`OpenVPN <openvpn>` que,
además, a partir de la versión 5.6 del núcleo de *Linux*, estará integrada
oficialmente como módulo. 

**Ventajas**:

- La configuración es bastante sencilla.
- Tiene mucho mejor rendimiento.

**Inconvenientes**:

- Establece la |VPN| sólo en capa 3.
- Por ahora, sólo permite la asignación estática de direcciones a los clientes.
- Sólo utiliza el protocolo |UDP|, así que no puede usarse el puerto *TCP/443*
  para evitar restricciones (al menos de modo sencillo).

.. https://github.com/pirate/wireguard-docs
   https://www.linode.com/docs/networking/vpn/set-up-wireguard-vpn-on-ubuntu/
   https://wiki.debian.org/Wireguard

.. https://kirill888.github.io/notes/wireguard-via-websocket/
   Wireguard via Websocket.

   Primero debe probarse websocket y una comunicación tonta udp. Por ejemplo:
   netcat -ulp 12345
   netcat -u IP 12345
