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

**Limitaciones**:

- Establece la |VPN| sólo en capa 3.
- No se admite identificación del cliente con usuario y contraseña.
- Lo que podríamos denominar *falta de anonimato*, aunque el administrador
  del servidor no tenga intención de querer identificar al cliente. Esto es
  debido a que, por un lado, a los clientes debe asignárseles una |IP| fija en
  su extremo del túnel y, a que por otro, la asociación entre |IP| real
  del cliente y su correspondiente |IP| en el túnel no se registra sin más en
  un fichero de registro (que podría ser :file:`/dev/null` para evitar el
  registro efectivo), sino que es permanentemente consultable a través de la
  orden :code:`wg show`. Esta circunstancia, no obstante, movió a AzireVPN_
  a `contratar al desarrollador de Wireguard un módulo que asegure el anonimato
  <https://www.azirevpn.com/blog/2017-11-15/wireguard-privacy-enhancements>`_,
  esto es, que evite que el administrador pueda llegar a averiguar la
  correspondencia entre ambas |IP|\ s. El resultado es el módulo
  `blind_operator_mode <https://git.zx2c4.com/blind-operator-mode/about/>`_.

Está experimentando un rápido desarrollo y, si se desea contratar un servicio
externo, son cada vez más `los proveedores que lo soportan
<https://vladtalks.tech/vpn/list-wireguard-vpn-providers>`_. Es
particularmente interesante, además, la lectura de este completo `artículo sobre
el estado de Wireguard en junio de 2019
<https://restoreprivacy.com/wireguard/>`_.

.. note:: En caso de que utilicemos *Buster*\ [#]_, no dispondremos aún del
   *software* en el repositorio, así que tendremos que echar mano de la rama
   *backports*::

      # echo "deb http://ftp.fr.debian.org/debian/ buster-backports main" > /etc/apt/sources.list.d/backports.list
      # apt update

   Además, el módulo pertinente no forma parte del núcleo por lo que hay que
   generarlo y para ello se requieren las cabeceras del núcleo que se esté
   usando y que probablemente no estén instaladas. Si esto es así y se instala
   antes :program:`wireguard` que las cabeceras el módulo no se generará
   automáticamente durante la instalación; y habrá, después de haberlas
   instalado, que generar el módulo a mano::

      # dpkg-reconfigure wireguard-dkms

Para acceder al *software*, basta con instalarlo::

   # apt install wireguard

.. rubric:: Contenidos

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

.. rubric:: Enlaces de interés

* `Elocuente tutorial sobre configuración del wireguard
  <https://angristan.xyz/how-to-setup-vpn-server-wireguard-nat-ipv6/>`_.
* `Documentación no oficial sobre Wireguard <https://github.com/pirate/wireguard-docs>`_
* `Tunelizando Wireguard con Websockets
  <https://kirill888.github.io/notes/wireguard-via-websocket/>`_.

.. rubric:: Notas al pie

.. [#] :program:`Wireguard` se implementó como núcleo de *Linux* desde un
   principio, pero sólo `entró como módulo oficial con la versión 5.6 del kernel
   <https://www.genbeta.com/linux/wireguard-vpn-open-source-admirado-linus-torvalds-sera-parte-kernel-linux>`_.
   Por ese motivo, en cualquier distribución de *Linux* con un núcleo anterior
   se deberá instalar el módulo de algún modo. Las distribuciones suelen tener
   un mecanismo medianamente automatizado en su paquetería para generar módulos
   basado en `DKMS
   <https://es.wikipedia.org/wiki/Dynamic_Kernel_Module_Support>`_.

.. |UDP| replace:: :abbr:`UDP (User Datagram Protocol)`

.. _AzireVPN: https://www.azirevpn.com
