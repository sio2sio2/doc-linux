Clientes
========

Configurado el servidor, toca ver cómo añadir clientes al dominio. Dependiendo
del sistema operativo del cliente, deberemos actuar.

.. warning:: Recuérdese que nuestro servidor lo hemos hecho participar en dos
   redes y que es *controlador de dominio* en la ``192.168.255.0/24``. Por
   tanto, cualquier cliente que queramos añadir deberá pertenecer a esta red.

.. warning:: Es conveniente configurar el servidor como un cliente linux, lo que
   implica configurar para él *sssd* y |PAM|, tal como se hace en el cliente.
   Para lo primero siga esta guía justamente a partir de cuando se crea :ref:`el
   keytab de la máquina <smb-keytab>` y para lo segundo siga lo indicado para la
   :ref:`configuración de los perfiles móviles en linux <smb-perfmov>`.

.. warning:: Los clientes deben tener sincronizada su hora con el servidor.

Linux
-----

Antes de empezar, es **indispensable** hacer varias cosas:

* Configurar el nombre del equipo (*hostname*) y el dominio tal como ya
  :ref:`hicimos en el servidor <smb-hostname>`. Denominaremos a este cliente
  *clienteL*.
 
* Asegurarnos de que el servidor de nombres del cliente es el controlador del
  dominio, cosa que así será si recibe *ip* de forma dinámica.

* Sincronizar su hora con el controlador de dominio. Para ello, o bien,
  instalamos otr servidor de hora en el cliente y lo configuramos para que se
  sincronice con ``dc``, o bien, instalamos el cliente de hora `ntpdate
  <https://packages.debian.org/stable/ntpdate>`_ y nos aseguramos que usará el
  controlador de dominio como servidor y que durante el arranque del sistema se
  realiza una sincronización.

Para permitir que el cliente acceda a los usuarios del *controlador de dominio*
usaremos *sssd* con el provisor *ad* que exige que la máquina sea miembro del
dominio y se disponga de un fichero :file:`/etc/krb5.keytab`. Existen otras
alternativas, que no requieron esto\ [#]_.

Instalemos lo necesario::

   # apt-get install samba krb5-user smbclient sssd

.. todo:: Asegurarse de que no se necesita winbind en el cliente.

Y paramos los servicios de samba::

   # invoke-rc.d smbd stop
   # invoke-rc.d nmbd stop

..   # invoke-rc.d winbind stop

para configurar como miembro del dominio este equipo creando un
:file:`/etc/samba/smb.conf` mínimo así:

.. include:: files/smb.conf
   :literal:

Ahora reiniciamos un par de servicios::

   # invoke-rc.d smbd start
   # invoke-rc.d nmbd start

Y, pidiendo las credenciales del administrador::

   # kinit Administrator@IESPJM.DOMUS

Añadimos el equipo al dominio::

   # net ads join -k
   Joined 'CLIENTEL' to dns domain 'iespjm.domus'

.. Por último, levantamos el servicio restante::

..    # invoke-rc.d winbind start

.. _smb-keytab:

Finalmente creemos un fichero :file:`/etc/krb5.keytab` que usará el demonio
*sssd*, encargado de posibilitar el uso de usuarios y grupos definidos en el
servidor::

   # net ads keytab create -k

.. note:: Si se está creando la *keytab* en el propio *controlador* debe hacer
   lo siguiente::

      # samba-tool domain exportkeytab /etc/krb5.keytab --principal=DC$

   donde :kbd:`DC` es el nombre que se le ha dado al *controlador de domino*.

Por último, es necesario que el cliente reconozca los usuarios definidos en el
servidor. Para ello hay que influir en |PAM| (que es el servicio que permite la
autenticación) y *nss* que permite reconocer los usuarios y obtener sus
propiedades (*uid*, etc.). La instalación de *sssd* facilita esto y. de hecho,
si se echa un vistazo a :file:`/etc/nsswitch.conf` y se ejecuta
:command:`pam-auth-update`, se comprobará que el instalador de paquetes ya se ha
encargado de añadir *sss* a su configuración. Lo único que queda es crear una
configuración a este demonio a través de :file:`/etc/sssd/sssd.conf`. Para esta
configuración tenemos dos alternativas:

#. Que los usuarios tengan definido en el propio directorio de *samba* su
   *UID* y el *GID* de su grupo principal para lo cual podemos hacer esto:

   .. include:: files/sssd.1.conf
      :literal:

   Hemos fijado que los usuarios que adminitiremos son aquellos que tiene UID
   entre 1500 y 10000. Cualquier usuario de *samba* cuyo *UID* exceda estos
   límies, simplemente, no existirá para el cliente.

#. Que no se encuentre ese dato en el directorio y que *sssd* genere una
   traducción partiendo del *SID* (el número de identificación que se usa en
   *windows* para usuarios y grupos). Para ello basta sustituir la línea::

      ldap_id_mapping = False

   por estas otras::

      # sssd traducirá el SID del usuario o grupo
      # a un UID o GID de UNIX. Se obliga a que este
      # número esté entre 1500 y 10000.
      ldap_id_mapping = True

      ldap_idmap_range_min = 1500
      ldap_idmap_range_max = 10000
      ldap_idmap_range_size = 8500

   obsérvese que estos límites coinciden con *min_id* y *max_id*.

   .. note:: En el presente documento usaremos esto segundo.

.. warning:: Si se arranco el servicio con un método y después se cambia al
   otro, es necesario parar el servicio, cambiar la configuración y, antes de de
   reiniciar, borrar las base de datos que crea :command:`sssd`::

      # rm -f /var/lib/sss/db/*

Una vez creada la configuración, puede arrancarse el servidor::

   # invoke-rc.d sssd start

.. note:: *sssd* usa una caché que almacena los usuarios del directorio activo
   que se acreditan, lo que le permite autenticar a un usuario cacheado, aunque el
   controlador esté caído. Sin embargo, esto puede impidir que, si se realiza un
   cambio en el servidor, el cliente lo refleje. Para borrar la caché es
   necesario ejecutar la orden (del paquete *sssd-tools*)::

      # sss_cache -E

Tras todo esto, tendremos un cliente *linux* que es miembro del dominio y que es
capaz de reconocer los usuarios que se creen en el servidor.

.. note:: Para completar la configuración del cliente *linux*, si se desean
   perfiles móviles, aun falta por :ref:`configurar estos <smb-perfmov>`.

Windows
-------

La condición fundamental para poder añadir el sistema al dominio es que el
servidor |DNS| de la máquina sea el *controlador de dominio*. Si la red de
pruebas es la que se ha sugerido aquí y se recibe *ip* dinámica, debería ser
así. No obstante, se puede comprobar abriendo una consola y comprobando la
configuración::

   C:> ipconfig /all

En cualquier caso, no es muy complicado configurar los servidores |DNS| y se
presupondrá que el lector sabe hacerlo.

La adición al dominio es sumamente sencilla, elegir en el menú contextual de
*Equipo* el ítem *Propiedades*:

.. image:: images/equipo_propiedades.jpg
   :alt: Localización de las propiedades de "Equipo" en windows7

y en la ventana emergente escoger *Cambiar configuración*, tras lo cual se
escogerá cambiar el nombre que dará paso a una ventana en la que podemos escoger
el nombre del equipo (*ClienteW*) y el dominio en el que queremos ingresar:

.. image:: images/adddom.jpg
   :alt: Adición del equipo al dominio de windows.

Se nos pedirá qe nos acreditemos como algún usuario del dominio con tal poder
(*Administrator*) y tras poco se nos informará de que se nos ha agregado al
dominio y deberemos reiniciar el sistema. A partir de este momento podremos
entrar en el equipo tanto con la cuenta local que se usó en la instalación como
con cualquier otra cuenta del dominio. Ahora bien, cuando se introduce un nombre
de usuario a secas, se sobrentiende que es un nombre de usuario del dominio y
estará definido en el *controlador* dicho de otro modo *Administrador* equivale
a *IESPJM\\Administrator*. En cambio, si se quiere acceder a una cuenta local,
deberá añadirse antes el nombre de la propia máquina (*CLIENTEW7\\usuario*, por
ejemplo):

.. image:: images/ingreso.jpg
   :alt: Ingreso en windows7 con un usuario local

.. rubric:: **Enlaces de interés**

* `SSSD and Active Directory <https://help.ubuntu.com/lts/serverguide/sssd-ad.html#sssd-ad-join>`_

.. Aspectos no analizados
   + Restringir el accesos de los usuarios a ciertos clientes. Parece que se
     puede hacer con access_provider = ldap y ldap_access_order = host. También
     hay otra directiva ldap_user_authorized_host = host?
     Ver: http://sssd-users.fedorahosted.narkive.com/PcKz2Dk2/does-ldap-access-order-host-support-jokers
     Por lo entendido parece que la cosa funciona así:
     - ldap_access_order = host, indica que como criterio se van a usar "host"
       para negar o denegar accesos.
     - ldap_user_authorized_host = nombre_atributo indica el atributo que se
       consultará en la base de datos para comprobar el acceso. (Por defecto es
       "host"). Parece ser que puede haber valores !host (para denegar acceso),
       host (para habilitarlo) y * (todos permitidos). Pueden indicarse varios???
   + Quizás es mejor opción "ad_gpo_access_control" (ver man sssd-ad), pero
     ¿Cómo se definen esas políticas GPO?
     Ver también: https://wiki.samba.org/index.php/Managing_local_groups_on_domain_members_via_GPO_restricted_groups
     https://msdn.microsoft.com/en-us/library/bb742376.aspx
     http://freyes.svetlian.com/GPOS/GPOS.htm

.. rubric:: Notas al pie

.. [#] Por ejemplo, *sssd* con el provisior |LDAP| que aprovecha que el
   directorioa activo es compatible con |LDAP|, o *libpam-ldapd* y *libnss-ldapd*
   con *nslcd*.
