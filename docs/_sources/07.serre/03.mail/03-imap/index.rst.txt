.. _dovecot:

Servidor |IMAP|
***************
Si queremos montar un sistema de correo completo, necesitamos configurar un
|MAA|, que haga accesibles los buzones de usuarios a máquinas remotas. Los dos
protocolos más usados son |POP3| e |IMAP|.

|POP3| es un protocolo pensado para que el cliente pueda descargar los mensajes
en su máquina local. |IMAP| en cambio, aunque permite esto, también deja la
posibilidad de gestionar los mensajes directamente en el servidor.

En esta guía instalaremos el servidor |IMAP| :program:`dovecot`.

.. _dovecot-imap:

Instalación
===========

La instalación en *debian* es sencilla::

   # apt-get install dovecot-imapd

La configuración requiere la edición de tres ficheros sitos bajo
:file:`/etc/dovecot`:

:file:`conf.d/10-ssl.conf`
   Debe dejarse la línea::

      ssl = yes

   y descomentar las líneas que señalan cuál es el certificado que se usará para
   la autenticación. Ahora bien, como ya generamos claves aptas también para
   este servicio, conviene usarlas, así que también cambiaremos el valor de las
   directivas\ [#]_::

      ssl_cert = </etc/ssl/certs/ssl-cert-snakeoil.pem
      ssl_key = </etc/ssl/private/ssl-cert-snakeoil.key

:file:`conf.d/10-auth.conf`
   Es recomendable descomentar la línea::

      disable_plaintext_auth = yes

   que obliga a que la conexión sea segura si la autenticación es en texto
   plano. Si en la directiva ``ssl`` del archivo anterior se hubiera fijado
   ``required`` se exigiría conexión segura, fuera cual fuera la autenticación.

   Además, debemos descomentar y dejar la línea::

      auth_username_format = %n

   que elimina el dominio del nombre de usuario, antes de pasar a comprobar si
   este existe, lo cual es fundamental si queremos que funcionen luego :ref:`las
   cuotas <dovecot-quota>`.

:file:`conf.d/10-mail.conf`
   Permite indicar cuál es la ubicación de los buzones. Lo más conveniente es
   que estén en formato :ref:`maildir <maildir>`::

      mail_location = maildir:~/Maildir

   .. note:: Si pretendemos que :ref:`postfix ceda la entrega a dovecot
      <postfix-dovecot-mda>` no es necesario más, pero si es el propio
      :program:`postfix` el que se encarga de ello entonces tendremos que
      definir estos mismos formato y ubicación en :file:`/etc/postfix/main.cf`:

      .. code-block:: apache

         home_mailbox = Maildir/

Opcionalmente, podemos hacer dos cambios más:

:file:`dovecot.conf`
   Podemos dejar la línea:

   .. code-block:: apache

      listen = *

   para escuchar unicamente en IPv4.

:file:`conf.d/10-master.conf`
   :program:`dovecot`, por defecto escuchará en los puertos **143** (|IMAP| con
   *STARTTLS*) y **993** (|IMAP|\ s). Si queremos deshabilitar este último,
   podemos añadir una línea al bloque correspondiente::

      inet_listener imaps {
         port = 0
      }

   Escuchar en el puerto **0**, equivale a deshabilitar el servicio.

Hecho esto, ya se tiene todo preparado para cargar la nueva configuración::

      # invoke-rc.d dovecot restart

Para comprobar el cifrado y, de paso, comprobar si podemos autenticarnos,
podemos hacer\ [#]_:

.. code-block:: console
   :emphasize-lines: 8, 13, 17, 25

   $ openssl s_client -connect localhost:imap -starttls imap -quiet
   depth=0 CN = mail.mail1.org
   verify error:num=18:self signed certificate
   verify return:1
   depth=0 CN = mail.mail1.org
   verify return:1
   . OK Pre-login capabilities listed, post-login capabilities have more.
   T1 LOGIN usuario contraseña
   T1 OK [CAPABILITY IMAP4rev1 LITERAL+ SASL-IR LOGIN-REFERRALS ID ENABLE IDLE SORT SORT=DISPLAY THREAD=REFERENCES
   THREAD=REFS THREAD=ORDEREDSUBJECT MULTIAPPEND URL-PARTIAL CATENATE UNSELECT CHILDREN NAMESPACE UIDPLUS
   LIST-EXTENDED I18NLEVEL=1 CONDSTORE QRESYNC ESEARCH ESORT SEARCHRES WITHIN CONTEXT=SEARCH LIST-STATUS BINARY
   MOVE SPECIAL-USE] Logged in
   T2 LIST "" "*"
   * LIST (\HasNoChildren) "." OtroBuzon
   * LIST (\HasNoChildren) "." INBOX
   T2 OK List completed (0.000 + 0.000 secs).
   T3 EXAMINE INBOX
   * FLAGS (\Answered \Flagged \Deleted \Seen \Draft)
   * OK [PERMANENTFLAGS ()] Read-only mailbox.
   * 0 EXISTS
   * 0 RECENT
   * OK [UIDVALIDITY 1544095512] UIDs valid
   * OK [UIDNEXT 2] Predicted next UID
   T3 OK [READ-ONLY] Examine completed (0.000 + 0.000 secs).
   T4 LOGOUT
   * BYE Logging out
   T4 OK Logout completed (0.000 + 0.000 secs).
   Connection closed by foreign host.

.. note:: Los comandos introducidos por nosotros son lo que empiezan por las
   etiquetas *T1*, *T2* y *T3*, esto es, ``LOGIN``, ``LIST`` y ``LOGOUT``. El
   nombre de tales etiquetas no tiene la menor importancia.

Alternativamente, podríamos instalar un |MUA| como :program:`mutt` y probar el
servicio |IMAP|, así::

   $ mutt -f 'imap://usuario@imap.mail1.org'

lo cual nos mostraría el contenido del buzón **INBOX**. Para acceder al
contenido de **OtroBuzon**, habría que añadirlo a la ruta::

   $ mutt -f 'imap://usuario@imap.mail1.org/OtroBuzon'

.. _dovecot-sasl:

Autenticación |SASL|
====================
:program:`dovecot` dispone de un plugin que implementa |SASL| y permite a
:program:`postfix` autenticar con él. Para habilitarlo basta con buscar el
fichero de configuración :file:`/etc/dovecot/conf.d/10-master.conf` y buscar
el siguiente bloque y adaptar su contenido::

   service auth {
      
      # [...]

      # Postfix smtp-auth
      unix_listener /var/spool/postfix/private/auth {
         mode = 0660
         user = postfix
         group = postfix
      }

      # [ ... ]
   }

y en :file:`conf.d/10-auth.conf` permitir también *AUTH LOGIN*:

.. code-block:: apache

   auth_mechanisms = plain login

Por su parte, en la configuración de :program:`postfix`
(:file:`/etc/postfix/main.cf`) deben añadirse las siguientes líneas:

.. code-block:: apache

   # Autenticación SASL
   smtpd_sasl_type = dovecot
   smtpd_sasl_auth_enable = yes
   smtpd_sasl_path = private/auth
   smtpd_sasl_local_domain = 
   smtpd_sasl_security_options = noanonymous
   broken_sasl_auth_clients = yes

y configurar unas restricciones para que tengan en cuenta la autenticación del
usuario, como las :ref:`propuestas para la autenticación con Cyrus SASL
<postfix-auth-restrict>`. Después de reiniciar ambos servicios, puede comprobar
que funciona la autenticación haciendo :ref:`las pruenas sugeridas para la otra
autenticación <postfix-auth-check>`.

Para comprobar la autenticación puede hacerse::

   # doveadm auth test usuario contraseña
   passdb: usuario auth succeeded
   extra fields:
     user=usuario

.. seealso:: Puede encontrar más información `en la sección de la wiki de
   dovecot <https://wiki2.dovecot.org/HowTo/PostfixAndDovecotSASL>`_

.. _dovecot-quota:

Cuotas
======
Para habilitar las cuotas, es necesario tocar algunos ficheros:

:file:`conf.d/10-mail.conf`:
   Debe cargarse el *plugin* para la cuota, descomentando y completando::

      mail_plugins = quota

:file:`conf.d/20-imap.conf`:
   Debe cargarse el *plugin* que permite informar de la cuota a través de
   |IMAP|::

      protocol imap {
         mail_plugins = $mail_plugins imap_quota
      }

:file:`conf.d/90-quota.conf`:
   Implementaremos una cuota de tipo *count* (aunque también puede usarse una
   cuota basada en la existente en el sistema de ficheros). Para ello::

      mailbox_list_index = yes

      plugin {
         quota = count:User quota
         # Si se añade esto, habrá dos límites de cuota,
         # Pero hay que habilitar las cuotas de disco.
         # mount sirve para indicar cuál es el sistema de ficheros.
         #quota2 = fs:Disk quota:mount=/home
         quota_rule = *:storage=1G
         # Esto permitiría que hubiera 100M más en la basura.
         #quota_rule2 = Trash:storage=+100M

         quota_grace = 10%%
         quota_status_success = DUNNO
         quota_status_nouser = DUNNO
         #quota_status_nouser = "551 5.5.1 User not found"
         quota_status_overquota = "552 5.2.2 Mailbox is full"
         quota_vsizes = yes
      }

      # Habilite esto, sólo si postfix no usa dovecot como MDA
      service quota-status {
          executable = quota-status -p postfix
          inet_listener {
            address = 127.0.0.1
            port = 12340
          }
          client_limit = 1
      }

   Obsérvese que:

   * Si se ha superado la cuota, se genera un error (**552**), que será el
     que se comunique al servidor remitente.
   * Si el usuario no existe, no se genera error. Podría hacerse, pero
     esto provocaría que cualquier *alias* de un usuario existente provocara
     el error.
   * El último bloque habilita un servicio en el puerto *12340* de la interfaz
     de *localhost*, que permite a :program:`postfix` consultar la cuota y sólo
     es necesario en caso de que decidamos no usar :program:`dovecot` para la
     entrega en los buzones locales. Ahora bien, también podría usarse un
     *socket* UNIX del siguiente modo::

      unix_listener /var/spool/postfix/private/quota-status {
         user = postfix
         group = postfix
         mode = 0660
      }

     .. warning:: Si usa este servicio de cuota, deberá configurar
        :program:`postfix` para ello. Revise :ref:`el epígrafe dedicado a la
        cuota en postfix <postfix-quota>`.

Podemos comprobar si se ha configurado la cuenta, realizando la siguiente
consulta::

   # doveadm quota get -u nombre_usuario

.. note:: Cerciórese de que, si ya se han enviado mensajes, estos se
   contabilizan en la estadística mostrada por la orden.

.. _dovecot-mda:

Servicio LMTP con :program:`dovecot`
====================================
:program:`dovecot`, a la hora de encargarse de la entrega en los buzones (o sea,
de hacer la labor de un |MDA|), ofrece dos alternativas:

* `dovecot-lda <https://wiki.dovecot.org/LDA>`_, que se desaconseja y
  permite tanto su uso como tabla virtual_ como su uso como tabla local_, en el
  estadio final de entrega a los buzones locales.

* Un servidor |LMTP|\ [#]_ al que :program:`postfix` entregue el correo y que es
  el método más eficiente y aconsejado por `la propia documentación de dovecot
  <https://wiki.dovecot.org/LMTP>`_.

El epígrafe se dedica únicamente a describir cómo habilitar el servidor |LMTP|,
para lo cual lo primero es instalar el paquete correspondiente::

   # apt install dovecot-lmtpd

La configuración necesaria pasa por modificar tres ficheros distintos:

``conf.d/10-master.conf``
   Aquí debemos indicar cómo escuchará el servicio. Podemos optar por un socket
   *unix* (lo recomendado) o un puerto::

      service lmtp {
         unix_listener /var/spool/postfix/private/dovecot-lmtp {
            mode = 0600
            user = postfix
            group = postfix
         }

         #inet_listener lmtp {
         #   address = localhost
         #   port = 24
         #}
      }

``conf.d/15-lda.conf``
   En este fichero las líneas de configuración pertinentes son las siguientes:

   .. code-block:: apache

      postmaster_address = no-reply@mail1.org
      hostname = smtp.mail1.org
      # La siguiente línea a sí, retendrá el correo en la cola,
      # en espera de que pueda entregarse después. Si se quiere
      # recibir una notificación inmediata, debe dejarse como "no".
      # quota_full_tempfail = yes
      sendmail_path = /usr/sbin/sendmail
      recipient_delimiter = +

``conf.d/20-lmtp.conf``
   Si deseamos que se atienda a la cuota de usuario disponible en el momento de
   la entrega son necesarias las siguientes líneas:

   .. code-block:: apache

      lmtp_save_to_detail_mailbox = yes
      lmtp_rcpt_check_quota = yes

Reiniciado el servidor, ya está listo el servicio para que pueda usarlo
:program:`postfix`, :ref:`previa configuración de éste <postfix-dovecot-mda>`.

.. note:: Utilizar :program:`dovecot` en la entrega, posibilita añadirle un
   :ref:`clasificador de mensajes <dovecot-sieve>` para almacenar los
   mensajes en buzones distintos atendiendo a múltiples criterios, en vez de
   todos en el buzón de entrada.

Usuarios virtuales
==================
:program:`dovecot` permite obtener los usuarios de distintas fuentes (|PAM|,
|LDAP|, |SQL|, etc). Por :dfn:`usuarios virtuales` nos referimos a aquellos que
no son usuarios del sistema y que sólo se reconocen por el servicio de correo.

.. _dovecot-usu-pam:

A través de |PAM|
-----------------
Los usuarios virtuales pudimos generarlos manipulando |PAM|, tal cómo se propuso
en la `configuración de postfix <postfix-usu-virtual>`_. En ese caso, es necesario que
:program:`dovecot`:

* use los mismos mecanismos de autenticación que *postfix*, esto es, que use
  :file:`/etc/pam.d/smtp`.
* si usamos módulos que sólo informan de nombre de usuario y contraseña, se mapeen
  los usuario virtuales a un UID, un GID y un directorio personal a partir de
  cual se defina su buzón.

Para lograr ambas cosas, debe modificarse
:file:`/etc/dovecot/conf.d/auth-system.conf.ext`, para que quede así\ [#]_:

.. code-block:: none
   :emphasize-lines: 4, 9, 10

   passdb {
     driver = pam
     # Hace que se use /etc/pam.d/smtp
     args = smtp
   }

   userdb {
     driver = passwd
     default_fields = uid=500 gid=115 home=/var/spool/mail/vusers/%u
     result_failure = return-ok
   }

La configuración es sencilla: para autenticar basta con consultar |PAM|, pero
para obtener la información de usuario, |NSS| no es suficiente; ya que de parte
de los usuarios la información de la cuenta no existe. Para solucionarlo se
definen unos valores predeterminados para los campos de esta información (que
coinciden con lo establecicdo en :program:`postfix`) y se devuelve éxito, incluso
aunque el usuario no exista para |NSS|.

.. warning:: Con esta configuración, no se le ocurre usar :program:`dovecot`
   como |MDA|, ya que a sus ojos, toda cuenta de usuario siempre existirá.

Para comprobar la autenticación::

   $ doveadm auth test usuario contraseña

.. _dovecot-usu-virtual:

A través de :program:`dovecot`
------------------------------
Además de |PAM|, podemos escoger `otras fuentes
<https://wiki2.dovecot.org/AuthDatabase>`_ de las que extraer información de
usuario y con las que realizar la autenticación. En cualquier caso, no son
excluyentes, sino que pueden usarse varias de ellas secuencialmente, de modo que
sea válido cualquier usuario que se encuentre en una de las fuentes que hayamos
configurado.

.. warning:: Si opta por crear usuario virtuales con :program:`dovecot`, no
   tendrá más remedio que :ref:`usarlo también para la entrega de mensajes
   <dovecot-mda>`.

Principios de funcionamiento
''''''''''''''''''''''''''''
Si echamos un vistazo a la configuración de :program:`dovecot`, comprobaremos
que usa para su autenticación |PAM| y para la obtención de información de
usuario |NSS|\ [#]_::

   $ doveconf -n
   [...]
   passdb {
      driver = pam
   }
   [...]
   userdb {
      driver = passwd
   }

El hecho de que haya dos bloques se debe a que ``passdb`` define la `base de
datos para la autenticación <https://wiki2.dovecot.org/PasswordDatabase>`_ y
``userdb`` define la `base de datos para la obtención de la información de
usuario <https://wiki2.dovecot.org/UserDatabase>`_, que se usa después de que se
haya completado la autenticación.

Para que haya más fuentes de obtención de datos, basta con añadir más bloques
que se irán revisando en orden de aparición. Tanto en autenticación como en
obtención de información de usuario, si un bloque falla, se pasa al siguiente;
Para controlar qué se hace al tener éxito en la búsqueda de un bloque existen
directivas como ``result_success`` o ``result_failure``, y para controlar qué se
hace en función de lo que ocurriera anteriormente, existe la directiva ``skip``.
Por ejemplo::

   userdb {
      driver = passwd
      result_success = return-ok
   }

   userdb {
     driver = static
     args = uid=500 gid=115 home=/var/spool/mail/vhomes/%u mail=maildir:/var/spool/mail/vusers/%u
     # skip = found  # Alternativa al return-ok del bloque anterior
   }

En este caso, se intenta obtener la información de usuario a través de |NSS| y,
si no se logra, se fijará la información que se indica a continuación\ [#]_.
Esta configuración, pues, es un alternativa a la que presentamos bajo el
epígrafe anterior. Otro ejemplo es el siguiente::

   passdb {
      driver = static
      args = user=%n  noauthenticate
   } 

   passdb {
      driver = pam
      skip = authenticated
   }

   # Usamos passwd-file y no passwd, porque el primero permite
   # indicar el formato con el que buscar (username_formart)
   userdb {
      driver = passwd-file
      args =  username_format=%n /etc/passwd
   }

Que permite eliminar el dominio del nombre de usuario, tanto en la autenticación
como en la obtención de información, y es equivalente a la directiva:

.. code-block:: apache

   auth_username_format = %n

La ventaja de este segundo método es que podemos hacer que esta sustitición sólo
opere con los usuarios de sistema, lo que nos permitiría gestionar distintos
dominios.

Una alternativa a la configuración anterior, que logra lo mismo, es dejar
exactamente igual la autenticación y hacer de este modo la obtención de la
información de usuario::

   userdb {
      srive = static
      args = user=%n
      result_success = continue
   }

   userdb {
      drive = passwd
   }

En este caso, el primer bloque sirve simplemente para eliminar el dominio del
nombre de usuario y devuelve ``continue`` para que se obtenga la información de
usuario recurriendo al sistema, si es que el usuario existe. En realidad, ambas
soluciones no son exactamente equivalentes, ya que puede haber usuarios
definidos fuera de :file:`/etc/passwd` (p.e. definidos a través de :ref:`samba
<samba>`). Por tanto, esta segunda opción es más general y será la que preferamos.

SQLite
''''''
Conocido cómo funciona la autenticación y obtención de información sobre
usuarios en :program:`dovecot`, ilustramos cómo lograr definir usuarios
virtuales de un modo sencillo. Una forma es mediante la definición de un archivo
:file:`passwd` alternativo (`driver passwd-file
<https://wiki2.dovecot.org/AuthDatabase/PasswdFile>`_), pero nos decantaremos
por usar sqlite_ que permite una mayor versatilidad manteniendo la idea de
almacenar usuarios en un único fichero. Lo primero es instalar :program:`sqlite`
y el driver de :program:`dovecot` para él::

   # apt install sqlite3 dovecot-sqlite

.. warning:: El driver de :program:`dovecot` para :program:`sqlite` soporta
   únicamente la versión **3**. Tenga presente que en las versiones basadas en
   debian :program:`sqlite` es la versión **2** y :program:`sqlite3`, la versión
   **3**.

El esquema que nos propone `la documentación sobre SQL
<https://wiki2.dovecot.org/AuthDatabase/SQL>`_ es el :download:`siguiente
<files/dovecot.sql>`:

.. literalinclude:: files/dovecot.sql
   :language: sql

al que podríamos añadir una tabla más si quisiéramos almacenar también en ella
las cuentas virtuales que se definen a través de virtual_alias_maps_:

.. literalinclude:: files/alias.sql
   :language: sql

Sea como sea, con el esquema podemos crear la base de datos::

   # sqlite3 /etc/dovecot/private/users.db < /tmp/dovecot.sql

.. note:: Los nombres de los campos en la base de datos son los nombres que
   espera dovecot que tengan los campos de información de usuario. La
   documentación, tan solo, advierte que puede utilizarse "*user*" como la
   combinación de "*userid@domain*".

.. note:: El campo *quota* permite fijar una cuota particular para el usuario.
   Son valores válidos **100K** o **200M** o **2G**. También **0** que implica
   que el usuario no tendrá límite, o *NULL* que remitirá al valor
   predeterminado de la cuota. La expresión de la cuota, en realidad, debe
   llamarse *quota_rule*, pero tiene un valor más complicado, así que se ha
   optado por llamar al campo de distinto modo. Vea más adelante cómo se hace la
   consulta a la base de datos para devolver *quota_rule* y el :ref:`epígrafe
   dedicado a la cuota <dovecot-quota>`, que justifica tal consulta.

Para la configuración, debemos editar :file:`conf.d/10-auth.conf` y descomentar
y adelantar la línea:

.. code-block:: apache

   !include auth-sql.conf.ext
   !include auth-system.conf.ext

de manera que se consulte antes la base de datos que la base de usuarios del
sistema. El fichero :file:`conf.d/auth-sql.conf.ext`, ya está preparado
adecuadamente, aunque podemos añadirle una línea:

.. code-block:: none
   :emphasize-lines: 3, 5

   userdb {
      driver = sql
      default_fields = home=/var/spool/vusers/%n gid=2000
      args = /etc/dovecot/dovecot-sql.conf.ext
      result_success = return-ok
   } 

para establecer los directorios personales que no se hayan fijado en la propia
base de datos. Además, podemos fijar un *GID* predeterminado, que puede ser útil
si queremos que todos los usuarios tengan el mismo grupo principal. Por último,
es necesario modificar :file:`/etc/dovecot/dovecot-sql.conf.ext`, que debe
contener exactamente cómo acceder a los datos de la base |SQL|. En nuestro caso\
[#]_:

.. code-block:: apache

   driver = sqlite
   connect = /etc/dovecot/private/users.db
   password_query = SELECT userid AS user, password \
                    FROM users WHERE userid = '%n' AND active = 'Y'
   user_query = SELECT home, uid, gid, \
                  CASE WHEN quota IS NOT NULL \
                  THEN '*:storage=' || quota \
                  ELSE NULL END AS quota_rule \
                FROM users WHERE userid = '%n'

en que evitamos el uso del dominio, porque configuramos para un único dominio.
Reiniciamos el servidor y listo::

   # invoke-rc.d dovecot restart

Por último deberíamos añadir algún usuario virtual, a fin de comprobar que todo
funciona::

   # echo "INSERT INTO users VALUES ('pepe','mail1.org','$(doveadm pw -p pepe)', 2000, 2000, NULL, 'Y', '20M');" \
      | sqlite3 /etc/dovecot/private/users.db

Obsérvese que las contraseñas no se almacenan en claro, por lo que es necesario
generarlas con :program:`doveadm`.

.. seealso:: Para saber más sobre las contraseñas, consulte la `pagina
   correspondiente en la documentación
   <https://wiki2.dovecot.org/Authentication/PasswordSchemes>`_

Hecha la configuración, podemos probar la autenticación con la orden::

   # doveadm auth test pepe pepe
   passdb: pepe auth succeeded
   extra fields:
     user=pepe
   # doveadm user pepe
   field   value
   uid     2000
   gid     2000
   home    /var/spool/vhomes/pepe
   mail    maildir:~/Maildir
   quota_rule      *:storage=20M

.. _dovecot-buzon-virtual:

Por último, es necesario solucionar el problema de los buzones de correo o, más
exactamente, el problema de que el directorio personal de los usuarios virtuales
no exista a priori, lo cual no es problema para los usuarios reales del
sistema, cuyo directorio suele crearse en el momento de crear el propio usuario.
En nuestra propuesta los directorios de los usuarios virtuales, se incluyen
dentro de :file:`/var/spool/mail/vusers`, que debemos crear a mano::

   # mkdir -p /var/spool/mail/vusers

Ahora bien, en el momento de la entrega el servidor asumirá la identidad del
usuario que recibe correo (esto es, su UID y su GID) y, de no existir, intentará
crear el buzón (:file:`/var/spool/mail/vusers/pepe/Maildir` en nuestro caso),
pero se encontrará con que no puede crear directorios dentro de
:file:`/var/spool/mail/vusers` y la entrega se malogrará. Para evitar este
inconveniente, tenemos dos alternativas:

* Crear a mano su directorio cada vez que añadamos un usuario a la
  base de datos y hacer al usuario propietario::

   # mkdir /var/spool/mail/vusers/pepe
   # chown 2000:2000 /var/spool/mail/vusers/pepe

* Crear un grupo que sea el grupo principal de todos los usuarios virtuales y
  dar a este grupo permisos de escritura sobre el directorio
  :file:`/var/spool/mail/vusers`::

   # addgroup --gid 2000 vmailusers  # Todos los usuarios tendrá este GID.
   # chgrp vmailusers /var/spool/mail/vusers
   # chmod g+w /var/spool/mail/vusers

.. note:: Con la configuración propuesta si se crea un usuario en la base de
   datos con el mismo nombre que un usuario del sistema, el usuario virtual
   prevalecerá sobre el del sistema.

.. _dovecot-mul-dom:

Gestión de varios dominios
==========================
Puede darse el caso de que un mismo servidor gestione varios dominios de correo
distintos. Por ejemplo, que el servidor que gestione los correos de los dominios
*mail1.org* y *mail1bis.org* sea la misma máquina. En ese caso, la primera regla es
tener separados los usuarios según el dominio al que pertenecen, lo que obligará
a que a la hora de autenticar en el servidor el cliente use como nombre
de cuenta *usuario@dominio* y no solamente *usuario* como hasta ahora.

.. warning:: Cerciórese de que en :file:`conf.d/10-auth.conf` **no** existe la
   línea::

      auth_username_format = %n

   como se propugnó cuando creábamos un servidor para un único dominio.

La solución que se propone hará que los usuarios reales estén definidos en todos
los dominios que gestionemos, por lo que se entregaría a *usuario* tanto
mensajes a *usuario@mail1.org* como a *usuario@mail1bis.org*.

Usuarios
--------
Tomemos como base la configuración propuesta para :ref:`soportar usuarios
virtuales con dovecot <dovecot-usu-virtual>` y usemos como soporte una base de
datos de :program:`sqlite`. Como dispondremos distintos dominios y puede ser que
no todos usen el mismo transporte\ [#]_, crearemos dos tablas: una para almacenar
dominios y otra para almacenar usuarios. A estas dos tablas podemos añadir una
tercera para almacenar también en la base de datos alias (o sea cuentas
virtuales) de usuario. El :download:`esquema es el siguiente
<files/dovecotMD.sql>`:

.. literalinclude:: files/dovecotMD.sql
   :language: sql

Debemos, además, cambiar las consultas a la base de datos para tener en cuenta
que la autenticación y la obtención de la información de cuenta deberán incluir
no sólo el nombre de usuario, sino también el dominio, porque es el único modo
de que haya dos usuarios con un mismo nombre en distinto dominio. Por tanto:

.. code-block:: apache

   password_query = SELECT userid || '@' || domain AS user, password \
                    FROM users WHERE userid = '%n' AND domain = '%d' AND active = 'Y'
   user_query = SELECT home, uid, gid, \
                  CASE WHEN quota IS NOT NULL \
                  THEN '*:storage=' || quota \
                  ELSE NULL END AS quota_rule \
                FROM users WHERE userid = '%n' AND domain = '%d'

.. **

Para esta base de datos, deberemos añadir cada dominio que gestionemos:

.. code-block:: sql

   INSERT INTO domains VALUES ('mail1.org', NULL);
   INSERT INTO domains VALUES ('mail1bis.org', NULL);

.. note:: Si dejamos sin definir el transporte (que es lo que hemos hecho), se
   tomará como transporte el valor de mailbox_transport_, que definimos al usar
   :ref:`dovecot como MDA <postfix-dovecot-mda>`.

y, por supuesto, los usuarios necesarios::

   # sqlite3 /etc/dovecot/private/users.db <<EOF
   INSERT INTO users (userid, domain, password, uid) VALUES ('pepe','mail1.org','$(doveadm pw -p pepe)', 2000);
   INSERT INTO users (userid, domain, password, uid) VALUES ('paco','mail1bis.org','$(doveadm pw -p paco)', 3000);
   EOF

Configuración
-------------
.. warning:: Recuerde que debe haber instalado *dovecot-sqlite* en el sistema.

Paralelamente a lo que hacemos para soportar usuarios virtuales con :program:`sqlite`,
debemos:

#. Alterar :file:`conf.d/10-auth.conf` para dejarlo como ya propusimos::

      !include auth-sql.conf.ext
      !include auth-system.conf.ext

   .. warning:: Nótese que hemos adelantado la autenticación con |SQL|.

#. Modificamos el fichero :file:`conf.d/auth-sql.conf.ext` exactamente como
   también propusimos (con un ligero cambio en la ruta del directorio
   personal):

   .. code-block:: none
      :emphasize-lines: 3, 5

      userdb {
         driver = sql
         default_fields = home=/var/spool/mail/vusers/%d/%n gid=2000
         args = /etc/dovecot/dovecot-sql.conf.ext
         result_success = return-ok
      }

   Por supuesto, habrá que resolver :ref:`el problema de los buzones virtuales
   <dovecot-buzon-virtual>`.

#. Dejamos el fichero :file:`dovecot-sql.conf.ext` así:

.. code-block:: sql

   driver = sqlite
   connect = /etc/dovecot/private/users.db
   password_query = ... como expresado arriba ...
   user_query = ... como expresado arriba ...

#. Modificamos :file:`conf.d/auth-system.conf.ext` para que los usuarios
   del sistema eliminen la información del dominio y puedan reconocerse::

      passdb {
         driver = static
         args = user=%n  noauthenticate
      }

      passdb {
         driver = pam
      }

      userdb {
         srive = static
         args = user=%n
         result_success = continue
      }

      userdb {
         drive = passwd
      }

Listo. Reinicie el servidor y compruebe que los usuarios se reconocen y pueden
autenticarse::

   # doveadm auth test pepe@mail1.org pepe
   # doveadm user pepe@mail1.org

Como puede ver, ahora deben indicarse como nombre de usuario la cuenta al
completo. Sólo es posible prescindir del dominio, si el usuario es un usuario
local del sistema.

.. _dovecot-sieve:

Filtros de clasificación
========================
Hasta ahora nos hemos preocupado de que la entrega de mensajes al usuario se
realice en su buzón de entrada. Sin embargo, un servidor |IMAP| permite a un
mismo usuario disponer de múltiples buzones en el servidor. Nuestra intención
ahora es la de habilitar :dfn:`filtros de clasificación` que, dependiendo de
distintos criterios, desvíen los mensajes al buzón correspondiente. Por ejemplo,
un mensaje marcado previamente como *spam* con la cabeceroa ``X-Spam-Flag:``
durante la recepción, podría derivarse a un buzón específico para *spam*.

Estos filtros es muy común que los incluyan los |MUA| que usa el cliente y que
actúen sobre los mensajes que se descargan en la máquina local. La ventaja de
disponerlos en el servidor es que la labor de clasificación se hace directamente
sobre el servidor, lo que posibilita que el usuario pueda consultar directamente
sus mensajes ya clasificados en buzones a través del protocolo |IMAP|, bien
haciendo uso de un |MUA| con soporte para buzones |IMAP|, bien a través de una
interfaz *web*. Esto, sin embargo, implica que sea el propio usuario el que pueda
definir sus filtros, ya que suelen ser distintos para cada usuario.

El epígrafe, pues, se propone:

* Habilitar a :program:`dovecot` para que realice la entrega atendiendo a estos
  filtros.

* Permitir que el usuario pueda definir sus propios filtros a través del
  protocolo |IMAP|.

* Explicar cómo pueden escribirse estos filtros.

Configuración
-------------

.. todo:: Ver cómo actúa el plugin *sieve* (e *imap_sieve*) tal como aconseja
   `este enlace <https://workaround.org/ispmail/jessie/postfix-dovecot>`_. En
   principio, puede usarse para que, desde :ref:`roundcube <roundcube>`, el
   usuario organice automáticamente sus mensajes en buzones (p.e. `este artículo
   <https://www.rosehosting.com/blog/how-to-set-up-server-side-email-filtering-with-dovecot-sieve-and-roundcube-on-a-centos-6-vps/>`_).

Filtros
-------

.. rubric:: Notas al pie

.. [#] :program:`dovecot` trae dentro de :file:`/usr/share/dovecot` un fichero
   de configuración (:file:`dovecot-openssl.cnf`) y un *script*
   (:file:`mkcert.sh`) para generar los certificados en la ubicación original
   que hemos sustituido. No obstante, es mejor utilizar el autofirmado por
   nosotros o, mejor aún, procurarnos uno de *Let's Encrypt*.

.. [#] Si se observa el resultado de la orden ``LIST``, se verá que devuelve dos
   buzones: **INBOX** que es el buzón de correos entrantes que crea el propio
   :program:`dovecot` y otro llamado **OtroBuzon**, que es un correo creado
   *ex profeso*, creado para que la respuesta tuviera algo más de enjundia.
   Consulte en las :ref:`explicaciones del formato maildir <maildir>` cómo crear
   estos buzones adicionales.

.. [#] Un servidor |LMTP| es un protocolo semejante al |SMTP| en el que el
   receptor entrega inmediatamente los mensajes en los buzones locales de
   usuario.

.. [#] Bajo este epígrafe se presenta la configuración como una receta. Si tiene
   curiosidad por entenderla, échele un vistazo a los principios de
   funcionamiento explicados en el :ref:`siguiente apartado
   <dovecot-usu-virtual>`.

.. [#] Según `su documentación
   <https://wiki2.dovecot.org/AuthDatabase/Passwd>`_, el driver ``passwd`` de
   ``userdb`` usa |NSS|, y no sólo :file:`/etc/passwd` para obtener la
   información.

.. [#] Tenga en cuenta que si se actúa así, jamás deberías usar
   :program:`dovecot` como |MDA| puesto que siempre se entregará correo, incluso
   aunque tal usuario no exista.

.. [#] Obsérvese que la consulta devuelve el nombre de usuario en el campo
   "*user*". Esto elimina por completo cualquier mención al dominio, que es lo
   que nos interesa, porque nuestra intención es gestionar un único dominio.

.. [#] La idea es que en :program:`postfix` el contenido de transport_maps_ se
   defina con una consulta a esta misma ase de datos. 

.. |MAA| replace:: :abbr:`MAA (Mail Access Agent)`
.. |MUA| replace:: :abbr:`MUA (Mail User Agent)`
.. |MDA| replace:: :abbr:`MDA (Mail Delivery Agent)`
.. |MTA| replace:: :abbr:`MTA (Mail Transfer Agent)`
.. |POP3| replace:: :abbr:`POP3 (Post Office Protocol v3)`
.. |SASL| replace:: :abbr:`SASL (Simple Authentication and Security Layer)`
.. |SQL| replace:: :abbr:`SQL (Structured Query Language)`
.. |NSS| replace:: :abbr:`NSS (Name Service Switch)`
.. |LMTP| replace:: :abbr:`LMTP (Local Mail Transfer Protocol)`

.. _sqlite: https://www.sqlite.org/index.html
.. _virtual: http://www.postfix.org/virtual.5.html
.. _local: http://www.postfix.org/local.8.html
.. _transport_maps: http://www.postfix.org/postconf.5.html#transport_maps
.. _virtual_alias_maps: http://www.postfix.org/postconf.5.html#virtual_alias_maps
.. _mailbox_transport: http://www.postfix.org/postconf.5.html#mailbox_transport
.. _myorigin: http://www.postfix.org/postconf.5.html#myorigin
.. _mydomain: http://www.postfix.org/postconf.5.html#mydomain
