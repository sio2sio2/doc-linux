.. _openvpn:

OpenVPN
=======
En el estudio trataremos cómo establecer redes |VPN| entre una sede y un equipo
móvil o entre dos sedes; y para ambos casos se implementará la conexión en capa
de enlace y de red. Son, por tanto, cuatro casos posibles. Para no multiplicar
en exceso los casos, implementaremos la autenticación de clientes con
certificado y la generación del certificado de servidor mediante entidad
certificadora, en los casos de conexión entre dos sedes y la autenticación con
usuario y contraseña y certificado de *Let's Encrypt* en los casos de conexión
entre equipo móvil y sede.

.. note:: La configuracion "sede-equipo móvil" implementada en capa 3, por ser
   la primera que se desarrolla tiene la configuración abundantemente comentada.
   Muchos de estos comentarios son pertinentes en las restantes configuraciones,
   pero no se repiten. Échele un ojo a esta configuración, aunque no sea la que
   usted pretende.

Posiblemente, no todos los casos sean igual de pertinentes y nos convendrá
elegir uno u otro según sean nuestras necesidades:

+ Cuando se pretende conectar con la sede central equipos móviles, hacer que el
  estos equipos se encuentren en la misma red no suele aportar nada, pero en
  cambio sí que aumenta el tráfico (p.e. los paquetes de broadcast circularán
  por el túnel). En consecuencia, lo natural es que las conexiones sede-equipo
  móvil sean conexiones en capa de red.

+ Por el contrario en conexiones sede-sede:

  - Si en la sede del servidor se encuentran centralizados todos los servicios,
    de nuevo no aporta gran cosa que la sucursal se encuentre en la misma red,
    por lo que lo lógico es que se estableca el túnel en capa de red.

  - En cambio, si las sucursales también aportan servicios, esto querrá decir
    que necesitaremos acceder desde cualquier máquina a máquinas concretas
    de otras sedes. Para ello, lo más fácil es situar todas las máquinas en la
    misma red y, por tanto, establecer una conexión en capa de enlace.

.. rubric:: Contenidos

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*
