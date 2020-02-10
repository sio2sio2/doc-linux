.. _wireguard:

Wireguard
*********
:program:`wireguard` es una solución alternativa a :ref:`OpenVPN <openvpn>` que,
además, a partir de la versión 5.6 del núcleo de *Linux*, estará integrada
oficialmente como módulo. 

**Ventajas**:

- La configuración es bastante sencilla.
- Tiene mucho mejor rendimiento.
- No usa certificados, sino parejas de claves (como |SSH|).

**Inconvenientes**:

- Establece la |VPN| sólo en capa 3.
- Por ahora, sólo permite la asignación estática de direcciones a los clientes.
- No se admite identificación del cliente con usuario y contraseña.

Está experimentando un rápido desarrollo y, si se desea contratar un servicio
externo, son cada vez más `los proveerdores que lo soportan
<https://greycoder.com/a-list-of-wireguard-supporting-vpns-in-2019/>`_. Es
particularmente interesante, además, la lectura de este completo `artículo sobre
el estado de Wireguard en junio de 2019
<https://restoreprivacy.com/wireguard/>`_.

.. note:: En caso de que utilicemos *Buster*, no dispondremos aún del *software*
   en el repositorio, así que tendremos que echar mano de la versión de pruebas.
   Para ello, podemos añadirla como repositorio::

      # cat > /etc/sources.list.d/bullseye.list
      deb http://ftp.fr.debian.org/debian/ bullseye main

   y modificar las preferencias para seguir usando como repositorio prinicipal el
   de la versión estable::

      # cat > /etc/apt/preferences.d/bullseye
      Package: *
      Pin: release a=testing
      Pin-Priority: 90

Para acceder al *software*, basta con instalarlo::

   # apt install wireguard

.. rubric:: Contenidos

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*

.. rubric:: Enlaces de interés

* `Elocuente tutorial sobre configuración del wireguard
  <https://angristan.xyz/how-to-setup-vpn-server-wireguard-nat-ipv6/>`_.
* `Documentación no oficial sobre Wireguard <https://github.com/pirate/wireguard-docs>`_
* `Tunelizando Wireguard con Websockets
  <https://kirill888.github.io/notes/wireguard-via-websocket/>`_.

.. |UDP| replace:: :abbr:`UDP (User Datagram Protocol)`
