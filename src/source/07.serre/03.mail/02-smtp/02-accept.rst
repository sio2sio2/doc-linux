Aceptación de mensajes
**********************

.. _postfix-accept:

Políticas de aceptación
=======================

.. seealso:: Para completar la información bajo este epígrafe pueden consultarse
   los enlaces:

   * `Restricciones de acceso en Postix
     <http://www.universidaddecordoba.eu/servicios/informatica/sistemas/doc_ccc/postfix/restricciones.html>`_.
   * `Otra de controles de acceso en Postfix
     <http://desdelaconsola.es/controles-de-acceso-en-postfix/>`_

Control de accesos
------------------
:program:`postfix` tiene la habilidad de aceptar o rechazar mensajes dependiendo
de múltiples criterios. Cuando recibe un mensaje a través de una comunicación
|SMTP|, esta pasa por fases (véase la :ref:`descripción de cómo se lleva a
cabo esta comunicación <smtp-trans>`) y en cada una de ellas pueden operar estas
restricciones de acceso:

+---------------+-------------------------------------+
| Momento       |  Directiva                          |
+===============+=====================================+
| Conexión      | smtpd_client_restrictions_          |
+---------------+-------------------------------------+
| ``EHLO``      | smtpd_helo_restrictions_            |
+---------------+-------------------------------------+
| ``MAIL FROM`` | smtpd_sender_restrictions_          |
+---------------+-------------------------------------+
| ``RCPT TO``   | | smtpd_recipient_restrictions_     |
|               | | smtpd_relay_restrictions_         |
+---------------+-------------------------------------+

.. note:: Ante un comando ``RCPT_TO`` se consultan
   smtpd_recipient_restrictions_ o smtpd_relay_restrictions_ dependiendo
   de cuál sea la dirección del destinatario. Si el destinatario es una cuenta
   del propio servidor se aplican las primeras; y, si no, las segundas. Además,
   si smtpd_relay_restrictions_ está vacía, se usa
   smtpd_recipient_restrictions_ para cualquier destinatario.

.. note:: Existen más restricciones, que se relacionan `en la documentación de
   postfix <http://www.postfix.org/SMTPD_ACCESS_README.html#lists>`_

Las restricciones de cada fase (clases de restricciones en la terminología de
:program:`postfix`) las define el administrador entre todas las que ofrece
:program:`postfix` y están constituidas por un conjunto de pruebas cada una de
las cuales, esencialmente, puede devolver tres respuestas:

+ Una *respuesta de aceptación*, que supone que se abandonen las pruebas
  faltantes y se considere que el mensaje ha superado las restricciones de esa
  fase.
+ Una *respuesta de rechazo*, que supone que se abandonen las pruebas faltantes,
  se considere que el mensaje no ha superado las restricciones de la fase y, en
  consecuencia, el mensaje sea definitivamente rechazado.
+ *Ninguna respuesta concluyente*, que supone que se pase a la siguiente prueba.
  En caso de que la prueba fuese la última de la fase, se considera que el
  mensaje ha superado las restricciones de esa fase.

Para ilustrarlo, supongamos esta directiva:

.. code-block:: apache

   smtpd_client_restrictions = reject_unknown_client_hostname
                               check_client_access hash:/etc/postfix/tb/client_access

La directiva implica que, tras la conexión del cliente, el servidor hará la
prueba reject_unknown_client_hostname_, que responderá *rechazo* si la |IP| del
cliente no tiene nombre asignado\ [#]_, y nada concluyente en caso contrario. En
el primer caso, las restricciones de esta fase acabarán con un resultado de
rechazo y no habrá nada más que hacer ni será necesario comprobar las
restricciones de fases ulteriores. En el segundo caso, aún hay otra prueba que
hacer: check_client_access_. Esta segunda comprobación hace uso de una `tabla
access`_ que en este caso determina a
partir de la |IP| o el nombre del cliente qué acción se toma. Imaginemos que su
contenido es el siguiente::

   # Cliente         # Acción
   192.168.255.4     REJECT Banned client
   192.168.2         REJECT 192.168.2.0/24 banned network
   spammer.dhns.org  REJECT Banned client
   spammers.org      REJECT Banned domain

En ese caso, se comprueba por orden la tabla y si el cliente es 192.168.255.4,
pertenece a la red 192.168.2.0/24, es *spammer.dhns.org* o su nombre pertenece
al dominio *spammers.org*, se rechazará la conexión. En cualquier otro caso, la
prueba no devuelve una respuesta concluyente y al no haber más pruebas en esta
fase se pasará a comprobar las restricciones de la siguiente fase
(smtpd_helo_restrictions_).

Aunque lo lógico es que las restricciones de cada fase se aplicaran nada más
completarse esta (p.e. las que nos han servido para ilustrar deben efectuarse
nada más completarse la conexión y antes de que el cliente pueda saludar con
``EHLO``), :program:`postfix` deja que el cliente complete todas las fases hasta
el comando ``DATA`` y, entonces es cuando aplica las restricciones de todas las
fases secuencialmente. Este comportamiento puede alterarse usando la directiva:

.. code-block:: apache

   smtpd_delay_reject = no

Aunque cada prueba de las que provee :program:`postfix` es propia de una fase de
la comunicación |SMTP| (p.e. la ilustrada check_client_access_ de la fase de
conexión), se permiten usar cualquiera de ellas en las restricciones de
cualquier fase. Por esa razón, al presentar la configuración básica incluimos
una prueba propia de la conexión como reject_rbl_client_ en
smtpd_recipient_restrictions_. Ahora bien, es obvio que si, incorporando la
directiva anterior, hacemos que las restricciones se apliquen en su momento
respectivo y no al final, sólo podrán aplicarse las pruebas correspondientes a
la propia fase o a fases previas. En concreto, para smtpd_helo_restrictions_
sólo podremos aplicar pruebas propias de la fase de conexión o de la fase de
saludo, ya que aún se desconocen el emisor y los destinatarios.

.. warning:: Es importante tener presente que, si se usan restricciones de fases
   anteriores a la de recepción (``RCTP TO``), normalmente sólo tiene sentido
   utilizar pruebas para el rechazo y no para la aceptación, ya que la
   aceptación de la fase, no implica que se acepte el correo, sino que se pase a
   la fase siguiente. Para entenderlo observemos que;

   .. code-block:: apache

      smtpd_client_restrictions = permit_sasl_authenticated
      smtpd_recipient_restrictions = reject_unauth_destination

   no es equivalente a:

   .. code-block:: apache

      smtpd_recipient_restrictions = permit_sasl_authenticated
                                     reject_unauth_destination

   con la segunda configuración cualquier cliente autenticado podrá usar el
   servidor de *relay* (enviar correos a cuentas que no son de nuestro propio
   servidor), mientras que en el primer caso, no.
   
.. rubric:: Restricciones de usuario

Además de las clases de restricciones predefinidas (smtpd_client_restrictions_,
etc.), el administrador puede definir las suyas propias que pueden usarse como
alias para definir grupos de pruebas en las clases predefinidas o como valor en
la segunda columna de una `tabla access`_\ [#]_.

Por ejemplo, si quisiéramos que los clientes de nuestra red sólo envíen mensajes
con cuentas de nuestra red, podríamos hacer lo siguiente:

.. code-block:: apache

   smtpd_restriction_classes = emisor_propio_restriction
   emisor_propio_restriction = check_sender_access hash:/etc/postfix/tb/cue_propias, reject
   smtpd_sender_restrictions = check_client_access hash:/etc/postfix/tb/cli_propios


donde :file:`/etc/postfix/tb/cli_propios` es::

   mail1.org         emisor_propio_restriction

y :file:`/etc/postfix/tb/cue_propias`::

   mail1.org         OK

.. note:: Si el primero de los ficheros lo hubieras definido así::

      mail1.org         check_sender_access hash:/etc/postfix/tb/cue_propias, reject

   nos habíamos ahorrado definir la clase propia.

.. _postfix-vrf-recipient:

Control de destinatario
-----------------------
Por defecto, el valor de smtpd_reject_unlisted_recipient_::

   # postconf -d smtpd_reject_unlisted_recipient
   smtpd_reject_unlisted_recipient = yes

provoca que :program:`postfix` compruebe durante la comunicación |SMTP| cuál
será el receptor del mensaje y lo rechace en los siguientes casos:

* Si el destinatario pertenece a alguno de los dominios listados en
  mydestination_, pero no se encuentra listado en local_recipient_maps_ (y
  local_recipient_maps_ no está vacío).

* Si el destinatario pertenece a alguno de los dominios listados en
  virtual_alias_domains_, pero no se encuentra referido en virtual_alias_maps_.

* Si el destinatario pertenece a alguno de los dominios listados en
  virtual_mailbox_domains_, pero no se encuentra listado en
  virtual_mailbox_maps_.

* Si el destinatario pertenece a alguno de los dominios listado en
  relay_domains_, pero no se encuentra referido en relay_recipient_maps_ (y
  relay_recipient_maps_ no está vacío).

:program:`postfix` obra así, porque esto evita que, ante un envío indiscriminado
hacia nuestro servidor de cuentas generadas aleatoriamente, se llene nuestra
cola de salida con mensajes de que la cuenta no existe.

.. note:: Existe una politica de aceptación llamada
   reject_unlisted_recipient_ que sirve exactamente para lo mismo, pero sólo
   tiene sentido usarla si se modifica el valor de
   smtpd_reject_unlisted_recipient_.

.. seealso:: Para más información, consulte el `artículo oficial sobre la
   verificación del destino <http://www.postfix.org/ADDRESS_VERIFICATION_README.html>`_

.. _postfix-access-body:

Control del contenido del mensaje
---------------------------------
Las restricciones al acceso anteriores no se aplican al contenido del mensaje,
sea la cabecera o el cuerpo. Si nuestra intención es rechazar mensajes según el
contenido podemos recurrir a header_checks_ y body_checks_.

.. warning:: Estos mecanismos de filtro no deberían sustituir a *software*
   específico de filtrado (p.e. *software* antispam), porque su rendimiento es
   pobre y sólo deben usarse para resolver casos muy concretos.

Un ejemplo de uso puede ser este::

   header_checks = regexp:/etc/postfix/tb/reject_rules

y dentro de tal fichero::

   /^Subject: .*VIAGRA.*$/    REJECT Los clientes de este servidor no tienen problemas de erección

Para probar si el filtro funciona, puede usarse la siguiente orden::

   $ postmap -q 'Subject: Vendo VIAGRA barata' regexp:/etc/postfix/tb/reject_rules
   REJECT Los clientes de este servidor no tienen problemas de erección

.. _postfix-vrfydmn:

Campo ``From:``
---------------
.. seealso:: Conviene que eche un vistazo a la introducción del epígrafe
   dedicado a la `acreditación del remitente <smtp-acreditacion>`_ para que
   tenga claros los conceptos de *remitente del sobre* y *dirección del
   mensaje*, que se usarán aquí.

El propósito de este epígrafe es estudiar cómo evitar que nuestros usuarios
usen direcciones arbitrarias como *direccion del mensaje*, bien rechazando
aquel mensaje en que no coincide ésta con el *remitente del sobre*, bien
sustituyendo la *dirección del mensaje* por la del *remitente del sobre* antes
de remitirlo a su destinatario.

.. note:: La tarea inversa de descubrir falsificaciones en el remitente o de
   facilitarla sobre nuestros mensajes a servidores ajenos se desarrolla
   en la `acreditación del remitente <smtp-acreditacion>`_.

:program:`postfix` no tiene ningún mecanismo para llvar a cabo este propósito
pero existe un software de terceros con paquete en *debian*, `vrfydmn
<https://github.com/croessner/vrfydmn>`_, que funciona como `milter
<https://es.wikipedia.org/wiki/Milter>`_::

   # apt install vfrydmn

La mayor dificultad de uso es que el paquete no parece estar perfectamente
integrado en la distribución, y es necesario modificar su arranque para que nos
funcione con :program:`postfix`.

Lo primero es cambiar el fichero :file:`/etc/default/vrfydmn` para que quede
con este contenido:

.. code-block:: bash

   DAEMON_OPTS=""
   SOCKET=local:/var/spool/postfix/var/run/vrfydmn.sock
   USER=vrfydmn
   GROUP=vrfydmn
   PIDFILE=/var/run/vrfydmn/vrfydmn.pid
   FILE=/etc/postfix/tb/vrfydmn

y crear el fichero
:file:`/etc/systemd/system/vrfydmn.service.d/10_override.conf` que sobreescriba
la configuración para :ref:`systemd <systemd>`, a fin de que se use el fichero
anterior:

.. code-block:: ini

   [Service]
   EnvironmentFile=/etc/default/vrfydmn
   ExecStart=
   ExecStart=/usr/sbin/vrfydmn -s $SOCKET -u $USER -g $GROUP -p $PIDFILE --file $FILE $DAEMON_OPTS

.. _postfix-aux:

Para que se pueda crear el *socket* dentro de la jaula de :program:`postfix`,
crearemos un directorio :file:`var/run/` en el que puedan escribir todos los
usuarios, pero con bit *pegajoso*::

   # mkdir -m1777 /var/spool/postfix/var/run

Por último es necesario crear el fichero :file:`/etc/postfix/tb/vrfydmn` que
debe ser una tabla semejante a relay_domains_ o virtual_mailbox_domains_ en la que la
primera columna contiene los dominios para los que :program:`vrfydmn` no
realizará comprobaciones, y la segunda es indiferente\ [#]_::

   mail1.org            importa_poco_que_se_ponga_aqui
   # Resto de dominios que gestionemos

Con estos cambios, ya podemos recargar la configuración de :program:`systemd` y
reiniciar el servicio::

   # systemctl daemon-reload
   # invoke-rc.d vrfydmn restart

Además, debemos indicarle a :program:`postfix` que use el *milter*:

.. code-block:: apache

   smtpd_milters = unix:var/run/vrfydmn.sock

.. nota:: Es conveniente que aplique el *milter* en los :ref:`puertos dedicados
   a la escucha de clientes <postfix-25-465-587>` (**465** y **587**), así que
   la línea anterior debería aplicarla sólo al servicio *smtpd* que escuche en
   esos puertos. Así pues, no incluya la línea en :file:`/etc/postfix/main.cf`,
   sino de forma adecuada en :file:`/etc/postfix/master.cf`::

      urd       inet  n       -       y       -       -       smtpd
         -o smtpd_tls_wrappermode=yes
         -o smtpd_milters=unix:aux/vrfydmn
      submission inet n       -       y       -       -       smtpd
         -o smtpd_milters=unix:aux/vrfydmn

Además, el usuario *postfix* debería pertenecer al grupo *vrfydmn*.

Tal como se ha configurado :program:`vrfydmn`, éste se comporta de modo que
permite cualquier *dirección del mensaje* siempre que sea de un dominio
incluido en el fichero. Si no es así, el mensaje se rechaza.

Una alternativa a lo anterior, es indicarle a :program:`vrfydmn` que en vez de
rechazar el correo, lo acepte, pero modificando el campo ``From:`` para que lo
haga coincidir con la dirección indicada en ``MAIL FROM``. Para ello, habría que
modificar :file:`/etc/default/vrfydmn` para dejar esta línea:

.. code-block:: bash

   DAEMON_OPTS="-F"

.. _spam:

Spam
====
El *correo indeseado* o *spam* puede afectar a nuestro servidor de correo de dos
maneras:

* Como **emisor** del *spam*, porque el servidor se use para enviar ingentemente
  correo a otras cuentas.

* Comp **receptor** del *spam* por algunas de nuestras cuentas lo reciban de
  otros servidores.

.. _postfix-flujo:

Control del flujo
-----------------
Por lo general, los *spammers* se dedican a enviar miles y decenas de miles de
mensajes, por lo que una manera de controlar el *spam* es el limitar la
recepción o emisión de mensajes.

.. rubric:: Emisor

El servidor de correo puede convertirse en un emisor de *spam* si alguna de sus
cuentas se usa para tal fin. Puede deberse tanto a la existencia de un usuario
malintencionado o como al robo de alguna contraseña.

Para el primer caso (o bien cuando el segundo ya se ha consumado) es útil
limitar la capacidad de nuestros usuarios para enviar correos\ [#]_::

   # Mensajes simultáneos que se pueden enviar a un mismo dominio.
   smtp_destination_concurrency_limit = 2
   # Lapso entre dos envíos a un mismo dominio.
   smtp_destination_rate_delay = 1s
   # Número máximo de destinatarios por mensaje.
   smtp_extra_recipient_limit = 10

Para el segundo, es necesario habilitar algun mecanismo que obstaculice los
robos de contraseña. Algunas veces estos robos se deben a ataques de fuerza
bruta efectuados contra el servidor. Para evitarlos es conveniente disponer
:ref:`algún mecanismo contra ellos <contra-bruta>`.

.. rubric:: Receptor

Para limitar los efectos del *spam* entrante, podemos limitar la recepción de
mensajes, si es que nuestras cuentas están recibiendo masivamente *spam* de
alguna fuente\ [#]_::

   # Número de conexiones entrantes por cliente.
   smtpd_client_connection_count_limit = 5
   # Número de conexiones que un cliente puede hacer en un intervalo (fijado por anvil_rate_time_unit)
   smtpd_client_connection_rate_limit = 10
   # Número de mensajes entregados por cliente en un intervalo (anvil_rate_time_unit)
   smtpd_client_message_rate_limit = 2
   # Número de destinatarios a los que un cliente puede enviar mensajes en un intervalo (anvil_rate_time_unit)
   smtpd_client_recipient_rate_limit = 15

Filtro *antispam*
-----------------
Los :dfn:`filtros antispam` analizan los mensajes recibidos con la intención
de detectar los que son *spam* y desecharlos o, al menos, marcarlos como
indeseados.

.. seealso:: Otras técnicas para detectar *spam* están relacionadas con los
   mecanismos que acreditan al remitente del mensaje, que se explican en
   :ref:`su epígrafe correspondiente <smtp-acreditacion>`.

.. _spamassassin:

Spamassassin
'''''''''''''
El *software* más extendido encargado de esta tarea es :program:`spamassassin`
(`página oficial <https://spamassassin.apache.org/>`_), que tiene fácil
instalación en *debian*::

   # apt-get install spamassassin spamc

Puede, además tocarse la configuración de :file:`/etc/default/spamassassin` para
alterar la prioridad del proceso::

   NICE="--nicelevel 15"

Por último, es necesario habilitar el servicio ya que viene deshabilitado por
defecto\ [#]_::

   # systemctl enable spamassassin
   # systemctl start spamassassin

El siguiente paso es hacer que :program:`postfix` haga pasar los correos por
:program:`spamassassin` para que este los analice, lo cual requiere editar el
fichero :file:`/etc/postfix/master.cf` y dejar la primera línea que empieza por
``smtp`` así::

   smtp      inet  n       -       -       -       -       smtpd -o content_filter=spamfilter

además de añadir al final del fichero en qué consiste este filtro::

   spamfilter unix  -       n       n       -       -       pipe
      flags=Rq user=debian-spamd argv=/usr/local/bin/spamfilter.sh -oi -f ${sender} ${recipient}

El usuario *debian-spamd* lo crea la propia instalación de
:program:`spamassassin` y el *script* mencionado lo debemos crear nosotros en la
ruta señalada con :download:`este contenido <files/spamfilter.sh>`:

.. literalinclude:: files/spamfilter.sh
   :language: bash

.. warning:: Recuérdese que habrá que dar permisos de ejecución al *script*::

      # chmod 755 /usr/local/bin/spamfilter.sh

A partir de ahora, todo tráfico que sea considerado *spam* por
:program:`spamassassin` contendrá una cabecera\ [#]_\ [#]_::

   X-Spam-Flag: YES

Para tratar la cabecera podemos seguir dos estrategias.

+ Utilizar header_checks_ para desecharlo, según lo :ref:`expuesto anteriormente
  <postfix-access-body>`. En este caso, el filtro podría ser::

   /^X-Spam-Flag:\s+YES$/    DISCARD  Mensaje de spam

  .. note:: Lo prudente ante el *spam* es descartar el mensaje silenciosamente,
     no rechazarlo.

+ Postergar y delegar la decisión en un |MDA| externo, que podrá desecharlo
  o mandarlo al buzón de *spam*.

.. _rspamd:

rspamd
''''''
.. todo:: :program:`spamassassin` tiene el problema de que es un poco monstruoso
   y no es la solución más rápida del mundo. Como alternativas pueden tentarse:

   * `bogofilter <http://bogofilter.sourceforge.net/>`_ según lo explicado `aquí
     <https://www.tinslave.co.uk/blog/index.php?pos>`_. Tiene el inconveniente
     de que usa exclusivamente filtros bayesiano y no reglas de puntuación.

   * `Rrspamd <https://rspamd.com/>`_. que sí se basa en reglas Hay `una guía
     completa de cómo integrarlo con postfix
     <https://thomas-leister.de/en/mailserver-debian-stretch/>`_. También es
     interesante `es enlace
     <https://workaround.org/ispmail/stretch/filtering-out-spam-with-rspamd>`_

.. rubric:: Notas al pie

.. [#] En realidad, la comprobación es algo más complicado. Puede ver los
   términos exactos en la explicación de la documentación oficial.
.. [#] De hecho, también pueden usarse las clases predefinidas o, incluso,
   las pruebas (reject_unauth_destination_, etc.)
.. [#] También puede usarse una consulta |LDAP| o una consulta |SQL|, aunque
   en este último caso el *backend* sólo puede ser *MySQL*.
.. [#] Véase al respecto `esta entrada de steam.io
   <http://steam.io/2013/04/01/postfix-rate-limiting/>`_
.. [#] Véase la `información al respecto de la documentación de postfix
   <http://www.postfix.org/TUNING_README.html#conn_limit>`_
.. [#] En versiones antiguas de *debian* sin :program:`systemd`, se habilitaba
   en el fichero de configuración::

      ENABLED=1

.. [#] En realidad, se añade algún campo de cabecera más, como uno que explica
   por qué :program:`spamassassin` ha considerado *spam* el mensaje.

.. [#] Es posible modificar el comportamiento editando
   :file:`/etc/spamassassin/local.cf`. Por ejemplo::

      rewrite_header Subject *****SPAM***** [_SCORE_]
      report_safe 0
      required_score 4.0

   La primera directiva reescribirá el asunto del mensaje, la segunda no
   modificaría el cuerpo del mensaje y la última bajará la puntuación para la que
   un mensaje se considere *spam* (por defecto es 5).

.. |MDA| replace:: :abbr:`MDA (Mail Delivery Agent)`
.. |SQL| replace:: :abbr:`SQL (Structured Query Language)`
.. _smtpd_client_restrictions: http://www.postfix.org/postconf.5.html#smtpd_client_restrictions
.. _smtpd_helo_restrictions: http://www.postfix.org/postconf.5.html#smtpd_helo_restrictions
.. _smtpd_relay_restrictions: http://www.postfix.org/postconf.5.html#smtpd_relay_restrictions
.. _smtpd_recipient_restrictions: http://www.postfix.org/postconf.5.html#smtpd_recipient_restrictions
.. _smtpd_sender_restrictions: http://www.postfix.org/postconf.5.html#smtpd_sender_restrictions
.. _reject_unknown_client_hostname: http://www.postfix.org/postconf.5.html#reject_unknown_client_hostname
.. _reject_unauth_destination: http://www.postfix.org/postconf.5.html#reject_unauth_destination
.. _check_client_access: http://www.postfix.org/postconf.5.html#check_client_access
.. _reject_rbl_client: http://www.postfix.org/postconf.5.html#reject_rbl_client
.. _tabla access: http://www.postfix.org/access.5.html
.. _header_checks: http://www.postfix.org/postconf.5.html#header_checks
.. _body_checks: http://www.postfix.org/postconf.5.html#body_checks
.. _relay_domains: http://www.postfix.org/postconf.5.html#relay_domains
.. _virtual_mailbox_domains: http://www.postfix.org/postconf.5.html#virtual_mailbox_domains
.. _smtpd_reject_unlisted_recipient: http://www.postfix.org/postconf.5.html#smtpd_reject_unlisted_recipient
.. _reject_unlisted_recipient: http://www.postfix.org/postconf.5.html#reject_unlisted_recipient
.. _local_recipient_maps: http://www.postfix.org/postconf.5.html#local_recipient_maps
.. _relay_recipient_maps: http://www.postfix.org/postconf.5.html#relay_recipient_maps
.. _relay_domains: http://www.postfix.org/postconf.5.html#relay_domains
.. _virtual_mailbox_maps: http://www.postfix.org/postconf.5.html#virtual_mailbox_maps
.. _virtual_alias_maps: http://www.postfix.org/postconf.5.html#virtual_alias_maps
.. _virtual_alias_domains: http://www.postfix.org/postconf.5.html#virtual_alias_domains
.. _mydestination: http://www.postfix.org/postconf.5.html#mydestination
