.. _postfix-gest-usu:

Gestión de usuarios
*******************
Hasta ahora nos hemos limitado a utilizar usuarios definidos en el sistema que
tienen todos cuenta en un mismo dominio. Sin embargo, esto es solamente un caso
particular. Por un lado, lo habitual es que los usuarios de correo sea usuarios
exclusivos, reconocibles sólo por este servicio. Por otro, puede darse el caso
de que nuestro servidor gestione distintos dominios y que cada dominio tenga
sus propios usuarios. Ambas situaciones, que generalizan la comnfiguración del
servidor, se estudiaran bajo el prsente epígrafe.

.. seealso:: Es sumamente importante que lea qué se entiende por usuario,
   expuesto en los primeros párrafos del epígrafe dedicado a las :ref:`cuentas
   virtuales <postfix-cue-virt>`.

Usuarios exclusivos
===================
Para que :program:`postfix` reconozca, además, usuarios distintos a los del
sistema tenemos dos posibilidades:

* Manipular la autenticación con el servidor *smtp* de |PAM|.
* Si está disponible, es más recomendable manipular la autenticación de
  :program:`dovecot`, que pasa por haber usado :ref:`el SASL que éste
  proporciona para postfix <postfix-dovecot-sasl>`.

.. _postfix-usu-virtual:

A través de |PAM|
-----------------
.. note:: Bajo este epígrafe se tratará la creación de usuarios exclusivos de manera
   muy simple y que no es en absoluto recomendable cuando se gestiona un gran número
   de este tipo de usuarios. Esto es así, porque si se usan módulos como
   :ref:`pam_userdb <pam_userdb>` o `pam_pwdfile
   <https://github.com/tiwe-de/libpam-pwdfile>`_ sólo existe información sobre
   el nombre de usuario y su contraseña, y no sobre el resto de características
   de la cuenta (el directorio de usuario, por ejemplo). Además, tampoco
   posibilita el cambio de la contraseña.

La habilitación de usuarios exclusivos en :program:`postfix` supone tres
operaciones distintas:

.. _userdb-crear:

Creación de usuarios
''''''''''''''''''''
Necesitaremos el paquete *db-util*::

   # apt-get install db-util

Tras ello, lo primero es crear una base de usuarios que contenga los nombres y
contraseñas de los usuarios exclusivos. Para ello debe crear primero un fichero
de texto plano en que se dispongan alternativamente nombres y contraseñas::

   # cat /etc/postfix/vusers
   pepe
   24iLOKFSxXxdo
   paco
   bKsPsgguh00tU

Las contraseñas se obtienen cifrándolas con :command:`openssl`. Por ejemplo, si
la contraseña de *pepe* es *soypepe*::

   $ openssl passwd -crypt soypepe
   24iLOKFSxXxdo

Hecho esto, debemos generar la base de datos::

   # db_load -T -t hash -f /etc/postfix/vusers /etc/postfix/vusers.db
   # chmod 600 /etc/postfix/vusers.db

Si no se conserva el fichero original, puede consultarse el contenido de la base
de datos, así::

   # db_dump -p /etc/postfix/vusers.db

.. note:: Para añadir usuarios a la base de datos puede usarse un nuevo fichero
   que contenga los nuevos usuarios y la opción ``-n`` de :command:`db_load`::

      # db_load -T -n -t hash -f /etc/postfix/mas_usuarios /etc/postfix/vusers.db
      
   o bien, si es uno sólo leerlo directamente de la entrada estándar sin incluir
   la opción ``-f``::

      # db_load -T -n -t hash /etc/postfix/vusers.db <<EOF
      > jesus
      > $(openssl passwd -crypt soyjesus)
      > EOF
      
Configuración de PAM
''''''''''''''''''''
Es decir, configurar la autenticación para que :command:`postfix` reconozca los
usuarios como válidos. Esto exige modificar (en realidad, crear) el fichero
:file:`/etc/pam.d/smtp` y dejarlo del siguiente modo::

   auth sufficient pam_userdb.so crypt=crypt db=/etc/postfix/vusers
   account sufficient pam_userdb.so crypt=crypt db=/etc/postfix/vusers

   account required pam_succeed_if.so user ingroup mailusers

   @include common-auth
   @include common-account

La configuración propuesta hace, en realidad, dos cosas:

* Permite la autenticación de los usuarios exclusivos.
* Exige a los usuarios reales la pertenencia al grupo *mailusers*, lo cual
  exigirá su creación::

   # addgroup --system mailusers

Para comprobar la configuración basta hacer algo así::

   # testsaslauthd -u pepe -p soypepe -f /var/spool/postfix/var/run/saslauthd/mux -s smtp
   0: OK "Success."

Configuración de los buzones
''''''''''''''''''''''''''''
Antes de continuar es preciso indicar que, aunque los usuarios exclusivos no
existen para el sistema, sí es necesario almacenar en el sistema de ficheros los
mensajes que reciben. Estos ficheros en que se transforman los mensajes, deben
pertenecer a algún usuario y tener un grupo propietario. Sin embargo, los
usuarios exclusivos no tienen nada de eso ya que son, simplemente, un nombre y
una contraseña. Por ese motivo, :command:`postfix` requiere mapear esto usuarios
pra que dispongan de un **uid** y un **gid**. La manera más sencilla de hacerlo
es crear un usuario real y un grupo real (*mailusers* nos vale) y mapear todos
los usuarios exclusivos con ellos dos.

Consecuentemente, debemos crear un usuario\ [#]_::

   # adduser --home /var/spool/mail/vusers --shell /bin/false --ingroup mailusers \
      --gecos "Usuario para usuarios de correo" mailuser --disabled-password --uid=500

La configuración de :command:`postfix` se basa en crear un dominio virtual que
sepamos que no existe, por ejemplo, ``mail1.vusers``, redirigir los mensajes de
los usuarios exclusivos hacia este dominio virtual y, por último, definir los
buzones de éstos.

La configuración a añadir en :file:`/etc/postfix/main.cf` es la siguiente\ [#]_::

   virtual_mailbox_domains = mail1.vusers
   virtual_mailbox_base = /var/spool/mail/vusers
   virtual_alias_maps = hash:/etc/postfix/vusersmap
   virtual_mailbox_maps = hash:/etc/postfix/mailbox_vusers
   virtual_uid_maps = static:500
   # Suponemos que el grupo mailusers tiene GID 115
   virtual_gid_maps = static:115

El fichero :file:`vusersmap` debe contener el mapeo de los usuarios exclusivos
hacia el dominio virtual\ [#]_::

   # cat > /etc/postfix/vusersmap
   pepe@mail1.org    pepe@mail1.vusers
   paco@mail1.org    paco@mail1.vusers

Y el fichero :file:`mailbox_users` la localización de los buzones de éstos\ [#]_::

   # cat > /etc/postfix/mailbox_vusers
   pepe@mail1.vusers    pepe/Maildir/
   paco@mail1.vusers    paco/Maildir/

Lo cual quiere decir que los correos de *pepe* acabarán en
:file:`pepe/Maildir/`, por ejemplo. La ruta es relativa, porque se ha definido
ya la base en el fichero de configuración (virtual_mailbox_base_), por lo que
la ruta completa será :file:`/var/spool/mail/vusers/pepe/`. El hecho de que se
incluya una barra final, implica que se quieren buzones en formato *maildir*.

Por último, debe crearse el directorio que contendrá estos buzones::

   # mkdir -p /var/spool/mail/vusers
   # chown mailuser:mailusers /var/spool/mail/vusers
   # chmod 700 /var/spool/mail/vusers

.. note:: Que la autenticación no proporcione completamente la información sobre
   la cuenta (UID, GID, directorio de usuario) obligará, si se configura
   :program:`dovecot`, a mapear en ella también a estos usuarios exclusivos. Se
   verá :ref:`más adelante <dovecot-usu-pam>`.

.. _postfix-usu-virtual-dovecot:

A través de :program:`dovecot`
------------------------------
.. warning:: Tenga presente quen si configura usuarios exclusivos usando
   :program:`dovecot`, se verá obligado a :ref:`autenticar con dovecot
   <postfix-dovecot-sasl>` y a :ref:`usarlo como MDA <postfix-dovecot-mda>`\
   [#]_.

.. seealso:: Siga las indicaciones del :ref:`para habilitar los usuarios
   virtuales a dovecot <dovecot-usu-virtual>`

Hechas las modificaciones en :program:`dovecot`, aunque queda un escollo en
:program:`postfix`. Dado que no hemos eliminado nuestro dominio *mail1.org* de
mydestination_, :program:`postfix` comprueba que el usuario es un usuario local
para lo cual usa el valor de la directiva local_recipient_maps_::

   # postconf local_recipient_maps
   local_recipient_maps = proxy:unix:passwd.byname $alias_maps

que básicamente comprueba si el nombre se encuentra en :file:`/etc/passwd` o
listado en :file:`/etc/alias`. En consecuencia, cuando se envíe mensaje a un
usuario virtual, se devolverá un error de que el usuario no existe ("*User
unknown in local recipient table*"). Para evitarlo puede redefinirse como vacía
la directiva, que deshabilita la comprobación,pero eso `lo desaconseja
enérgicamente la documentación oficial
<http://www.postfix.org/LOCAL_RECIPIENT_README.html#main_config>`_, así que lo
que haremos es redefinirla para que se busquen también los usuarios en la base
de datos:

.. code-block:: apache

   local_recipient_maps = proxy:unix:passwd.byname $alias_maps sqlite:/etc/postfix/tb/users.cf

.. _postfix-users.cf:

y este fichero :file:`/etc/postfix/tb/users.cf` debe ser el siguiente:

.. code-block:: apache

   dbpath = /etc/dovecot/private/users.db
   query = SELECT 'OK' FROM users WHERE userid || '@' || domain = '%s' AND active = 'Y'

.. note:: Por la forma en que hemos configurado :program:`dovecot`, los mensajes
   enviados al dominio *localhost*, se entregarán si el usuario es un
   usuario real del sistema, pero no si es un usuario exclusivo. No debería ser un
   problema, puesto que sólo tendría sentido usar esas direcciones dentro del
   sistema y los usuarios exclusivos no tienen acceso a él.

.. _postfix-mul-dom:

Usuarios en varios dominios
===========================
.. note:: Cerciórese primero de que el paquete *postfix-sqlite* está instalado
   en el sistema.

Para gestionar varios dominios con :program:`postfix` lo más sencillo es
configurar con :program:`dovecot` :ref:`la autenticación
<postfix-dovecot-sasl>`, la :ref:`entrega de mensajes <postfix-dovecot-mda>` y
la :ref:`gestión de usuarios de los distintos dominios <dovecot-mul-dom>`. A
continuación, debemos rematar la configuración en :program:`postfix`:

.. code-block:: apache

   mydestination = sqlite:/etc/postfix/tb/domains.cf, localhost
   local_recipient_maps = proxy:unix:passwd.byname $alias_maps sqlite:/etc/postfix/tb/users.cf
   mailbox_transport = lmtp:unix:private/dovecot-lmtp
   #transport_maps = sqlite:/etc/postfix/tb/transports.cf
   virtual_alias_maps = sqlite:/etc/postfix/tb/aliases.cf

.. warning:: Recuerde que tendrá que usar :program:`postmap` después de crear
   cada fichero.

:file:`/etc/postfix/tb/users.cf` debe contener :ref:`lo expuesto bajo el
epígrafe anterior <postfix-users.cf>`. De hecho, convendría que leyera tal
epígrafe, si aún no lo ha hecho.

El fichero :file:`/etc/postfix/tb/domains.cf` nos permite obtener los dominios
que gestionamos de la base de datos sin tener que escribirlos directamente:

.. code-block:: apache

   dbpath = /etc/dovecot/private/users.db
   query = SELECT domain FROM domains WHERE domain='%s'

Si definimos *cuentas virtuales* en la base de datos entonces deberemos
obtenerlas consultando en ella, consulta que declara :file:`/etc/postfix/tb/aliases.cf`:

.. code-block:: apache

   dbpath = /etc/dovecot/private/users.db
   query = SELECT 
             CASE WHEN goto IS NULL
               THEN userid || '@' || domain
               ELSE goto
             END AS goto
           FROM aliases WHERE address='%s' AND active = 'Y'

En principio, el único transporte que necesitaremos es el |LMTP| de
:program:`dovecot`, así que transport_maps_ no será necesario, pero en caso
contrario :file:`/etc/postfix/tb/transports.cf` debe quedar así:

.. code-block:: apache

   dbpath = /etc/dovecot/private/users.db
   query = SELECT transport FROM domains WHERE domain='%s'

.. warning:: transport_maps_ se consulta antes de que opere el agente *local*
   de :program:`postfix`. En consecuencia, para los dominios que definan el
   transporte a través de la base de datos, no tendrá validez lo dispuesto para
   este agente (como las definiciones de :file:`/etc/aliases`).

Podemos comprobar cómo resolverá :program:`postfix` las consultas |SQL| del
siguiente modo::

   # postmap -q 'mail1.org' sqlite:/etc/postfix/tb/domains.cf
   mail1.org

.. rubric:: Notas al pie

.. [#] Al usuario se le ha dado el **uid** 500 para separarlo del resto de usuarios
   normales (que tienen **uid** por encima del 1000 en *debian*) y para que cumpla
   la restricción de :program:`dovecot` que exige que los usuarios de correo tenga un
   **uid** a partir de este número.
.. [#] Obsérvese que la configuración incluye la definición de virtual_alias_maps_,
   el cual ya se definió anteriormente para otros propósitos. Si queremos mantenerlos,
   basta con separar con comas todos los ficheros:

   .. code-block:: apache

      virtual_alias_maps = hash:/etc/postfix/vmailbox, regexp:/etc/postfix/desechables, hash:/etc/postfix/vusermaps

.. [#] Desgraciadamente hay que escribir los usuarios uno a uno. Sin embargo, si decidiéramos
   que los usuarios exclusivos cumplieran una regla de nombrado que los distinguiera de los
   usuarios reales, entonces sí sería posible usar una expresión regular. Por ejemplo, si
   decidiéramos, que todos los nombres de usuarios exclusivos acaban en *.vir*, de modo que
   nuestros usuarios son de la forma *pepe.vir*, *paco.vir*, etc. Podríamos hacer lo siguiente:

   .. code-block:: apache

      virtual_alias_maps = regexp:/etc/postfix/vusermaps

   y crear el fichero así::

      # cat > /etc/postfix/vusermaps
      /(.+)\.vir@mail1\.org$/    $1.mail1.vusers

   .. warning:: Téngase en cuenta, en este caso, que eliminar el punto de los nombres
      es un problema, y esto:

      .. code-block:: apache

         virtual_alias_maps = pcre:/etc/postfix/desechables, regexp:/etc/postfix/vusermaps
         
      provocaría que jamás se detectaran los usuarios exclusivos. En este caso, podríamos
      eliminar todos los puntos, excepto aquel que antecede a *.vir*, haciendo uso de
      expresiones regulares de *perl* (de ahí que hayamos escrito ``pcre:`` y no ``regexp:``.
      La línea que deberíamos incluir en el fichero es::

         /(.*)\.(?!vir@)(.*@mail1\.org)$/    $1$2

.. [#] Según la documentación (:manpage:`virtual(8)`), para
   virtual_mailbox_maps_ las substituciones de expresiones regulares están
   deshabilitadas, por lo que no podemos resolver la asignación de buzones con
   ellas.

.. [#] Esto último no es cierto y podrían seguirse entregando los mensajes con
   :program:`postfix` mediante la conversión de los dominios en virtuales y el uso de
   virtual_mailbox_maps_, virtual_uid_maps_ y virtual_gid_maps_ con consultas a
   la base de datos *sqlite* para definir la información de usuario necesaria.
   La solución, no obstante, es más engorrosa y no funcionará del todo bien con
   las :ref:`cuotas <postfix-quota>` definidas en :program:`dovecot`.

.. |SQL| replace:: :abbr:`SQL (Structured Query Language)`
.. |LMTP| replace:: :abbr:`LMTP (Local Mail Transfer Protocol)`
.. _virtual_alias_maps: http://www.postfix.org/postconf.5.html#virtual_alias_maps
.. _virtual_mailbox_domains: http://www.postfix.org/postconf.5.html#virtual_mailbox_domains
.. _virtual_mailbox_maps: http://www.postfix.org/postconf.5.html#virtual_mailbox_maps
.. _virtual_uid_maps: http://www.postfix.org/postconf.5.html#virtual_uid_maps
.. _virtual_gid_maps: http://www.postfix.org/postconf.5.html#virtual_gid_maps
.. _virtual_mailbox_base: http://www.postfix.org/postconf.5.html#virtual_mailbox_base
.. _transport_maps: http://www.postfix.org/postconf.5.html#transport_maps
.. _mydestination: http://www.postfix.org/postconf.5.html#mydestination
.. _local_recipient_maps: http://www.postfix.org/postconf.5.html#local_recipient_maps
