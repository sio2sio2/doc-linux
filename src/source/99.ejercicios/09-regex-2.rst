Ejercicios aplicados de regex
-----------------------------

.. note:: Los ejercicios requieren el uso de expresiones regulares con la
   herramienta adecuada (:command:`grep`, :command:`cut`, :command:`expr`,
   :command:`sed`, :command:`awk`, :command:`tr`).

#. ¿Cuántos sistemas de ficheros que se monten durante el arranque usan *ext4*?

#. Liste los nombres de usuarios inactivos (con aquellos a cuya contraseña se
   antecede con un signo "!").

#. Saque un listado de IPv4 contenidas en /etc/hosts con el número de
   máquinas a las que está asociada tal |IP|. Por ejemplo, a partir de esto::

      127.0.0.1      localhost localhost.localdomain
      192.168.1.1    router
      192.168.1.5    nas nas.localdomain almacen

   obtener esto otro::

      127.0.0.1 2
      192.168.1.1 1
      192.168.1.1 3

#. Compruebe si el módulo "nbd" está cargado en el sistema.

   .. note:: Los módulos cargados se listan en :file:`/proc/modules`. 

#. Generar un nuevo fichero :file:`/etc/services` sin comentarios.

#. Obtener el listado de nombres de usuario y las *shells* que usan:

      root: /bin/bash
      daemon: /usr/sbin/nologin

#. Obtener la dirección MAC de la tarjeta de red a partir de la
   salida de la orden :command:`ip`.

#. Usando forzosamente "ls", devuelva la lista de subdirectorios de /etc (o
   sea, no deben aparecer los ficheros).

#. Devuelva el listado de direcciones IPv4 que se resuelven gracias
   al fichero /etc/hosts.

#. Obtener el UID a partir d3el cual :command:`adduser` crea cuentas para
   usuarios humanos.

   .. note:: La información se encuentra en un fichero dentro de /etc.

#. Determine cuál es la versión del núcleo de linux que está corriendo
   en su sistema operativo. No muestre más de dos niveles: 2.16, 3.20, etc.

   .. note:: Investigue la orden :command:`uname`.

#. Mostrar sólo las líneas relevantes del fichero de configuración del
   servidor |SSH|.

   .. note:: Las líneas relevantes son aquellas que no están en blanco ni
      comentadas.
