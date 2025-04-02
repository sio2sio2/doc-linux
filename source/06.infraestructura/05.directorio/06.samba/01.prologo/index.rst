Preliminares
============

Antes de instalar *samba*, debe tenerse convenientemente configurado el
servidor.

Red
---

Dado que queremos montar el servidor en la red interna, dejaremos in fichero
:file:`/etc/network/interfaces` con este aspecto:

.. include:: files/interfaces
   :literal:

.. _disable-dhclient-resolv:

Obsérvese que se ha dejado que la interfaz externa reciba su configuración de un
servidor *DHCP*. Puede también configurarse de modo estático (que además sería
lo más normal), pero si se hace como se propone aquí nos encontraremos con el
inconveniente de que la configuración dinámica alterará el fichero
:file:`/etc/resolv.conf` en que se define el dominio de búsqueda y los
servidores *DNS* que se usan. Nuestra intención es evitarlo así que podemos
añadir a :file:`/etc/dhcp/dhclient.conf` las siguientes líneas::

   # cat >> /etc/dhcp/dhclient.conf
   interface "eth0" {
       supersede domain-name "iespjm.domus";
       supersede domain-search "iespjm.domus";
       supersede domain-name-servers 127.0.0.1;
   }

que forzarán a que sean esos los datos incluidos en :file:`/etc/resolv.conf`.

.. note:: Como el cliente *dhclient* no estaba configurado de este modo en el
   momento de obtener *ip*, si echamos un vistazo al fichero, veremos que no tiene
   los valores adecuados. No importa y, además, es necesario que siga así, puesto
   que como aún no tenemos servidor *DNS* seríamos incapaces de descargar paquetes.

.. _smb-hostname:

Hostname
--------

El nombre del controlador de dominio pretendemos que sea *dc*, de modo que
debemos hacer lo siguiente::

   # hostname dc
   # hostname > /etc/hostname

Además deberíamos dejar así en :file:`/etc/hosts` la línea referida a la propia
máquina::

   192.168.255.1     dc.iespjm.domus  dc

Hecho esto, debería ocurrir lo siguiente::

   $ hostname
   dc
   $ hostname -d
   iespjm.domus

Sistema de ficheros
-------------------

Hay que asegurarse de que el sistema de ficheros que compartiremos con samba\
[#]_ soporta :ref:`atributos extendidos de usuarios <xattr>` y
:ref:`permisos ACL <acls>`. Lo habitual en *linux* es que usemos *ext4* y este
ya tiene habilitadas estas dos características por defecto. De todos modos,
podemos cercionarnos revisando las opciones de montaje de la partición
:file:`/dev/VGserver/samba`, que es en la que se supone que almacenaremos los
ficheros que compartamos mediante el servidor::

     $ grep -E '(acl|user_xattr)' /proc/fs/ext4/$(basename `readlink /dev/VGserver/samba`)/options
     user_xattr
     acl

Si no aparecen las dos opciones, habrá que corregirlo modificando la
entrada en :ref:`/etc/fstab <fstab>`.

.. note:: La razón de que la orden se haya complicado de tal manera es
  debido a que en nuestro servidor de pruebas no tenemos particiones, sino
  volúmenes lógicos. Si el sistema de ficheros hubiera estado sobre una
  partición normal como ``sda4`` la ruta habría tan simple como
  :file:`/proc/fs/ext4/sda4/options`.

Servidor de hora
----------------

Es absolutamente indispensable que todos los ordenadores de la red tengan
sincronizada su hora, por lo que es inevitable instalar un :ref:`servidor de
hora <ntp>`. No entraremos aquí a analizar concienzudamente cómo se configura
uno, pero indicaremos una configuración que puede valernos:

   .. literalinclude:: files/ntp.conf
      :linenos:

La únicas novedades de esta configuración son dos:

* La línea 8 que permite comunicar mediante *socket* al servidor de hora con
  *samba*\ [#]_. Permanecerá comentada hasta que dispongamos de este último.

* La directiva *restrict* para las red interna (línea 20) que ha añadido
  *mssntp* porque los clientes exigen que los paquetes de hora vayan firmados.

Servidor DHCP
-------------

Este servicio no tiene relación alguna con *samba*, pero es común que se
encuentre habilitado en una red local, así que lo instalaremos también según
:ref:`lo estudiado en el epígrafe correspondiente <dhcp>`. La configuración es
muy sencilla y basta con crear un :file:`/etc/dhcp/dhcpd.conf`:

.. include:: files/dhcpd.conf
   :literal:

.. rubric:: Notas al pie

.. [#] En este epígrafe se considera que hemos reservado una partición
   independiente (en realidad, un volumen lógico) para incluir en él los
   directorios que compartiremos con samba. :ref:`Más adelante <smb-part-indep>` se
   explica cómo crear un nuevo volumen lógico y hacer que este se monte sobre
   :file:`/srv/samba`.

.. [#] ¡Ojo! En la línea se expresa el *directorio*, no el *socket*, que está
   dentro de él.
