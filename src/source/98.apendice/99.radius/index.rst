.. _radius:

Servidor |RADIUS|
*****************
|RADIUS| es un protocolo de autenticación y autorización para acceso a la red,
muy utilizado en redes *wifi*, que utiliza para el establecimiento de las
conexiones el puerto 1812/\ |UDP|. Permite que cada solicitante acceda a la red
utilizando una pareja de credenciales (usuario/contraseña) propias.

En el caso que queremos resolver, tenemos tres agentes:

#. Una servidor *Debian* que actúa como servidor |RADIUS|, cuya implementación
   más extendida de código abierto es Freeradius_, La instalación, como es
   habitual cuando existe paquete, es sumamente sencilla::

      # apt install freeradius

   En este servidor deberán almacenarse las credenciales de todos aquellos a los
   que se permite el acceso a la red.

#. El :dfn:`solicitante`, que es el dispositivo inalámbrico que pide acceso a
   la red. Deberá disponer de unas credenciales válidas para poder acceder.

#. Un *punto de acceso* que actúa como :dfn:`autenticador` o |NAS|\ [#]_
   (:dfn:`servidor de acceso a la red`) u que es el que permite acceder a
   *solicitante* consultando con el servidor |RADIUS| sus credenciales. Actúa,
   pues.  como intermediario entre el *solicitante* y el servidor |RADIUS|.
   

.. image:: /guias/02.seg/04.redes/files/radius.png

Para establecer un canal seguro de comunicación sobre el que discurra el
proceso de autenticación y autorización se utiliza |EAP|, que más que un
protocolo es un *framework* para crear protocolos concretos. Los más comunes
son |EAP|/|TLS|, que requiere autenticación con certificados tanto del lado del
servidor como del cliente, y |PEAP|, que sólo requiere certificado en la parte
del servidor.

.. seealso:: Para consultar los principales protocolos creados con |EAP| puede
   consultar `este artículo de Intel
   <https://www.intel.es/content/www/es/es/support/articles/000006999/wireless/legacy-intel-wireless-products.html>`_.

Configuración básica
====================
.. warning:: Antes de empezar la configuración es indispensable cerciorarse de
   que el nombre de la máquina (el que se obtiene con :ref:`hostname <hostname>`)
   es resoluble (p.e. porque se ha incluido en :file:`/etc/hosts`).

Toda la configuración se encuentra en el directorio :file:`/etc/freeradius/3.0/`
y es en él donde tenemos que empezarla. El archivo :file:`clients.conf` contiene
los *controladores de acceso* a los que se permite comunicar con el servidor
para retransmitir las credenciales. Ya tiene definido uno:

.. code-block:: docker

   client localhost {
      # [...]
      ipaddr = 127.0.0.1
      # [...]
      secret = testing123
   }

que nos permitirá :ref:`hacer comprobaciones más adelante <radius-check>`.
Lo interesante es que nos sirve de modelo para definir nuevos *autenticadores*:
basta con indicar qué dirección |IP| tiene y establecer una palabra secreta
arbitraria que habrá luego que trasladar a la configuración de éste:

.. code-block:: docker

   client linksys {
      ipaddr = 192.168.0.10
      secret = clavesecreta
   }

También es posible indicar una red completa:

.. code-block:: docker

   client pas {
      ipaddr = 192.168.0.0/24
      secret = clavesecreta
   }

La segunda parte de la configuración consiste en añadir las credenciales que
permitirán el acceso a los solicitantes. Es posible enumerarlas en el archivo
:file:`users` simplemente añadiendo una línea por credencial:

.. code-block:: none

   usuario1     Cleartext-Password := "contraseña1"
   usuario2     Cleartext-Password := "contraseña2"

pero para evitar el engorro de alterar el archivo, recurriremos a utilizar otro
*backend*. El más sencillo es una base de datos SQLite_, puesto que es probable
que nuestro servidor mínimo ya tenga soporte para ellas\ [#]_. esta opción
requiere habilitar el módulo::

   # cd /etc/freeradius/3.0/mods-enabled
   # ln -s ../mods-available/sql

y debe editarse este archivo para hacer algunos cambios:

.. code-block:: docker
   :emphasize-lines: 4, 5, 8

   sql {
      dialect = "sqlite"

      #driver = "rlm_sql_null"
      driver = "rlm_sql_${dialect}"

      sqlite {
         filename = "/var/cache/radius/users-sqlite.db"
         # [...]
      }

      # [...]
   }

Editado el archivo, es necesario preparar el directorio que albergará la
base de datos::

   # mkdir -m750 /var/cache/radius
   # chown freerad:freerad /var/cache/radius

pero no necesitamos crearla, porque el servidor lo hará por nosotros cuando lo
reiniciemos::

   # invoke-rc.d freeradius restart

aunque, obviamente, no habrá credenciales almacenadas. Para ello debemos
insertar registros en la tabla *radcheck*. Por ejemplo, esto::

   # echo "INSERT INTO radcheck VALUES (NULL, 'cliente', 'Cleartext-Password', ':=', 'nolasabes');" \
      | sqlite3 /var/cache/radius/users-sqlite.db

crea una credenciales *usuario/nolasabes*. Para comprobar que ha ido bien la
configuración basta con ejecutar:

.. _radius-check:

.. code-block:: console
   :emphasize-lines: 2, 9

   # radtest cliente nolasabes localhost 10 testing123
   Sent Access-Request Id 39 from 0.0.0.0:51538 to 127.0.0.1:1812 length 82
           User-Name = "cliente"
           User-Password = "nolasabes"
           NAS-IP-Address = 127.0.1.1
           NAS-Port = 0
           Message-Authenticator = 0x00
           Cleartext-Password = "nolasabes"
   Received Access-Accept Id 39 from 127.0.0.1:1812 to 127.0.0.1:51538 length 20

La orden exige pasarle las credenciales (los dos primeros argumentos), el
servidor (*localhost* porque estamos haciendo una consulta local), un número de
puerto (que debe ser cualquier número entero positivo incluido el cero) y, por
último, la palabra secreta para conectar al servidor (y que ya vimos que de
forma predeterminada es *testing123* para conexión local). Como las credenciales
son válidas (las acabamos de introducir en la base de datos), el cliente debe
recibir un :kbd:`Access-Accept`.

.. note:: Para depurar el funcionamiento, puede ejecutarse directamente el
   servicio con::

      # freeradius -X

.. _radius-pa:

Autenticadores
==============
Para que el punto de acceso actúe como autenticador de nuestro servidores,
necesitamos configurar la seguridad de su red *wireless* del siguiente modo:

.. table:: Parámetros de configuración
   
   ================= =================
    Modo             WPA2-Enterprise
    Servidor radius  192.168.0.1
    Puerto           1812
    secreto          clavesecreta
   ================= =================

donde hemos supuesto que nuestro servidor ocupa la |IP| *192.168.0.1*.

.. todo:: Añadir una captura de la pantalla de configuración de la seguridad de
   un punto de acceso.

Configuración adicional
=======================
Aparte de la configuración básica, pueden interesarnos otras funcionalidades.

Conexiones simultáneas
----------------------

.. http://lists.freeradius.org/pipermail/freeradius-users/2016-April/083292.html
.. http://lists.freeradius.org/pipermail/freeradius-users/2017-January/086105.html
.. http://lists.freeradius.org/pipermail/freeradius-users/2016-March/thread.html#82510
.. https://wiki.freeradius.org/guide/faq#common-problems-and-their-solutions_simultaneous-use-doesn-t-work
.. https://fossies.org/linux/freeradius-server/doc/configuration/simultaneous_use


|LDAP|
------
.. todo:: Configurar |LDAP| como *backend* del servidor |RADIUS|.


|PAM|
-----
.. warning:: La configuración propuesta es incompatible con cualquier otro
   *backend* para almacenar usuarios, por lo que, si usamos esta autenticación,
   deberemos renunciar a cualquier otro *backend*.

La autenticación con |PAM|, que no está recomendada por los desarrolladores
exige:

#. Que el usuario *freeradius* pertenezca al grupo *shadow*, lo cual ya
   previene la instalación del paquete.

#. Que se incluya en :file:`users` la línea:

   .. code-block:: docker

      DEFAULT     Auth-Type=Pam

#. Que habilitemos el módulo de modo semejante a como hicimos con *sql*::

      # cd /etc/freeradius/3.0/mods-enabled
      # ln -s ../mods-available/pam

#. Que descomentemos en :file:`sites-enabled/default` y
   :file:`sites-enabled/inner-tunnel` la línea referente a |PAM|.

Para comprobar la autenticación :program:`freeradius` usa el servicio de |PAM|
*radiusd* que ya viene preparado en el paquete. Para cualquier modificación del
comportamiento predefinido, deberemos tener conocimientos de :ref:`cómo funciona
PAM <pam>`.

.. rubric:: Notas al pie

.. [#] El acrónimo coincide con el de *almacenamiento conectado a red*, con el
   que no debe confundirse y que se revisa dentro de las :ref:`arquitecturas de
   almacenamiento <arq-alm>`.

.. [#] Lo más que probable que varias aplicaciones del servidor usen bases de
   datos de este tipo y, por tanto, se tenga instalado el paquete
   :deb:`libsqlite3-0`. También es probable, no obstante, que no se tenga
   instalado el cliente :deb:`sqlite3`, pero es pequeño y solo se necesita para
   registrar los usuarios.

.. |RADIUS| replace:: :abbr:`RADIUS (Remote Authentication Dial In User Service)`
.. |EAP| replace:: :abbr:`EAP (Extensible Authentication Protocol)`
.. |PEAP| replace:: :abbr:`PEAP (Protected Extensible Authentication Protocol)`
.. |NAS| replace:: :abbr:`NAS (Network Authentication Server)`
.. |TLS| replace:: :abbr:`TLS (Transport Layer Security)`
.. |UDP| replace:: :abbr:`UDP (User Datagram Protocol)`

.. _Freeradius: https://freeradius.org/
.. _SQLite: https://sqlite.org/
