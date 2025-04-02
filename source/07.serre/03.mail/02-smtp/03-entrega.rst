.. _postfix-entrega:

Entrega
=======
La última fase de la recepción de un mensaje de correo en el servidor es la de
entrega al usuario local, labor realizada por el |MDA|. :command:`postfix`, no
obstante, dispone de unas funciones muy básicas de entrega, que serán las que
tratemos en este apartado.

.. _mbox:
.. _maildir:

Buzones
-------
Antes de empezar, no obtante, es necesario señalar que los buzones de usuario
presentan dos formatos:

**mbox**
   En que el buzón es un único fichero dentro del cual los mensajes se van
   añadiendo uno a continuación del otro. Es el formato tradicional. Por lo
   general, suelen ocupar la ruta :file:`/var/mail/nombre_usuario`.
**maildir**
   En él, cada mensaje ocupa un fichero diferente dentro de un directorio. El
   formato es algo más complicado que un simple directorio, ya que en realidad
   es un directorio que se compone de tres subdirectorios: :file:`new`, que
   almacena los mensajes no vistos; :file:`cur`, que almacena los mensajes ya
   vistos; y :file:`tmp` que almacena temporalmente mensajes que están en
   proceso de ser entregados. Esta estructura, no obstante, es transparente al
   usuario final. Lo habitual es que este tipo de buzón se encuentre en
   :file:`~/Maildir`.

   Para construir un buzón en formato *maildir*, basta con recrear la estructura
   descrita::

      $ mkdir -m 700 -p ~/Maildir/{new,cur,tmp}

   aunque los |MDA| suelen crearlo automáticamente si este no existe. Es común,
   además, disponer de varios buzones de correo para gestionar mejor nuestro
   propio correo. Para crear nuevos buzones, lo que suele hacerse es crear
   directorios ocultos dentro de :file:`~/Maildir` que reproducen la
   estructura\ [#]_::

      $ mkdir -m 700 -p ~/Maildir/.Trabajo/{new,cur,tmp}

   .. note:: En realidad, si planeamos usar :program:`dovecot` como servicio
      |IMAP| o |MDA|, éste usa dentro de cada buzón ficheros adicionales que le
      ofrecen información adicional sobre los buzones. Por esa razón, es más
      recomentable usar la herramienta de creación de buzones::

         # doveadm mailbox create -u usuario@mail1.org INBOX
         # doveadm mailbox create -u usuario@mail1.org Trabajo

      En cualquier caso, los buzones se crean automaticamente al entregar en
      ellos mensajes; y si se crearon artesanalmente con :command:`mkdir`, se
      pueblan al ser utilizados por primera vez.

.. note:: Si se cambia la ruta predeterminada del buzón, el usuario es usuario
   del sistema y se acostumbra a abrir sesiones interactivas en el servidor
   (p.e. a tarvés e |SSH|) el aviso de "*Tiene mensajes en su buzón*" dejará de
   aparecer a menos que manipule la :ref:`autenticación con PAM <pam-mail>`.

.. _postfix-rewrite:

Reescritura de direcciones
--------------------------
:command:`postfix` permite la reescritura de direcciones tanto de las
direcciones de las cabeceras (``From:``, ``To:``, ``Subject:``) como de las
"direcciones del sobre" (o sea, las que acompañan a los comandos ``MAIL FROM`` y
``RCPT TO``).  Estas reescritura es habitual cuando se tiene un dominio
"interno" y un dominio de internet, y no se quiere que desde fuera se vea el
dominio interno inexistente (o al revés).

Hay algunos mecanismos de reescritura automáticos (véase en la documentación
`ADDRESS REWRITING`_) como el que provoca que una dirección constituida sólo por
un nombre de usuario, añada el dominio incluido en la variable myorigin_.
Además, el administrador también puede ordenar reescrituras de los mensajes
recibidos (incluso si llegó a :program:`postfix`, no por |SMTP|, sino con
:command:`sendmail`) a través de las directivas sender_canonical_maps_ y
recipient_canonical_maps_ y canonical_maps_.  La primera sirve para reescribir
las direcciones del emisor (cabecera ``From:`` y ``MAIL FROM``), la segunda para
reescribir las direcciones del receptor (cabeceras ``To:``, ``Cc:`` y ``RCPT
TO``) y la tercera, ambas. Estos mecanismos actuan durante la recepción del
mensaje antes de que operen las redirecciones de virtual_alias_maps_.

.. seealso:: Para el formato de las tablas *canonical* consulte `la documentación
   al respecto <http://www.postfix.org/canonical.5.html>`_.

Para manipular todas las direcciones anteriores en mensajes salientes
exclusivamente a través cliente |SMTP|, puede utilizarse la directiva
smtp_generic_maps_. Por ejemplo:

.. code-block:: apache

   smtp_generic_maps = hash:/etc/postfix/tb/no-dominio-local

e incluimos en el fichero::

   # cat > /etc/postfix/tb/no-dominio-local
   @localhost           @example.net

Si con esta configuración escribimos el siguiente mensaje::

   usuario@servidor:~$ /usr/sbin/sendmail -t
   From: usuario@localhost
   To: pepe@localhost
   Cc: paco.fdez@gmail.com
   Subject: Una prueba de como actua smtp_generic_maps

   s/t

El mensaje llegará tanto al buzón local de *pepe* como a la cuenta externa de
*paco.fdez@gmail.com*, pero sólo en este segundo envío se habrá reflejado el
cambio de dominio. Si para el cambio hubiéramos usado canonical_maps_, ambos
envíos se habría visto modificados.

.. seealso:: Para el formato de las tablas *generic* consulte `la documentación
   correspondiente <http://www.postfix.org/generic.5.html>`_.

.. warning:: La reescritura de la cabecera sólo se lleva a cabo si el cliente
   que se conecta al servidor cumple algunas de las condiciones expresadas con
   la directiva local_header_rewrite_clients_. En caso contrario sólo se llevará
   a cabo la reescritura de la dirección del sobre.

.. _postfix-cue-virt:

Cuentas virtuales
-----------------
Una posibilidad al configurar el servidor es habilitar la existencia de
*cuentas virtuales*. Antes, no obstante, es necesario una disquisición entre los
conceptos de *cuenta* y *usuario*.

Desde el punto de vista del sistema (operativo) podemos definir :dfn:`usuario
real` como aquel que existe para el propio sistema, es decir, aquel del que de
forma práctica obtenemos información a traves de la orden :ref:`getent passwd
<getent>`. El sistema de correo (:program:`postfix` en nuestro caso) puede
tener definidos, sin embargo, :dfn:`usuarios exclusivos`, que son aquellos que
no existen en otro servicio que no sea el servicio de correo. A estos usuarios,
muy comúnmente, se les denomina *usuarios virtuales*. Por su
parte, en :program:`postfix` existen :dfn:`usuarios locales`, que son aquellos
pertenecientes a los dominios listados en mydestination_ y :dfn:`usuarios
virtuales` que son aquellos listados en virtual_mailbox_domains_. Ambos son
usuarios propios para el sistema de correo, pero :program:`postfix`, en
principio, entenderá que los primeros son *usuarios reales* del sistema y los
segundos *exclusivamente* suyos. Visto así, está absolutamente justificado utilizar
como equivalentes los términos *usuario virtual* y *usuario exclusivo*; pero
:program:`postfix` permite manipular los mecanismos de entrega (p.e. :ref:`cediendo la
entrega a dovecot <dovecot-mda>`) lo cual permite tratar a los *usuarios
exclusivos* como *locales*. por esta razón, nosotros al tratar
:program:`postfix` evitaremos referirnos a los *usuarios exclusivos* como
*usuarios virtuales*\ [#]_.

.. seealso:: La definición de usuarios distintos a los usuarios reales del
   sistema, se tratará :ref:`mas adelante <postfix-gest-usu>`.

Por su parte las *cuentas* están asociadas a los usuarios, de manera que cada
usuario (sea de la naturaleza que sea), tiene la suya. Así, si existe el usuario
*pepe*, su cuenta es *pepe@mail1.org*. Es más, si el servidor maneja varios
dominios, tendremos que referirnos forzosamente al usuario como
*pepe@mail1.org*, ya que pueden existir otros "pepe" en otros dominios, con lo
que nombre de usuario y cuenta coinciden. Esta cuenta de la que hablamos es la
:dfn:`cuenta real` del usuario. Ahora bien, a un mismo usuario pueden asociarse
varias cuentas distintas, por lo que se define como :dfn:`cuenta virtual` toda
cuenta distinta a una *cuenta real* de usuario. Por lo general, las cuentas
virtuales está asociadas a usuarios del sistema de correo, pero pueden incluso
asociarse a cuentas externas de otros servidores (p.e. a una supuesta cuenta
*soy_ajeno@gmail.com*). A las cuentas virtuales también se las denomina
:dfn:`alias de correo`.

Para definir *cuentas virtuales* (o *alias de correo*, si se prefiere el
término), se definen tablas que ligan la cuenta virtual con la cuenta
real de usuario (o con una cuenta externa). Tenemos dos alternativas:

.. _postfix-aliases:

**Tablas locales** (en principio, :file:`/etc/aliases`)
   :file:`/etc/aliases` es un fichero heredado del veterano servidor Sendmail_,
   que **sólo se consulta cuando la cuenta es una cuenta local**, es decir,
   cuando el dominio está incluido en el valor de myorigin_ o mydestination_.
   Sus líneas tienen el formato::

      alias:      address

   "*alias*" es el alias que se define, pero **siempre sin la expresión del
   dominio**, ya que por el dominio se entenderá alguno de los referidos en
   mydestination_. En nuestro ejemplo, la línea concordará tanto con
   *alias@mail1.org* como con *alias@localhost*. Por su parte, "*address*" es
   una dirección de correo arbitraria, local o no. Si no se especifica dominio,
   entonces se añade automáticamente el contenido de myorigin_ (*mail1.org* en
   nuestro caso). Las búsquedas, además, son recursivas de modo que, si la
   dirección resultante es local, volverá a buscarse en la tabla hasta que no se
   encuentre entrada\ [#]_.  Pueden, además, deinirse varios resultado::

      alias:     address1, address2, ...

   y en ese caso, el *alias* redirigirá el mensaje a todas esas direcciones.

   Para el muy probable contenido de nuestro :file:`/etc/aliases`::

      postmaster:    root
      root:    usuario

   si se envía un mensaje a *postmaster@mail1.org* (o *postmaster@localhost* o
   simplemente *postmaster*\ [#]_), este se redirigirá a *root@mail1.org*; pero,
   como *root también tiene entrada en la tabla y la búsqueda es recursiva, el
   mensaje acabará en el buzón de *usuario@mail1.org*.

   Siempre que se modifique (o cree) una tabla, es necesario regenerar su *db*
   correspondiente para que tenga efecto en :program:`postfix`::

      # postalias /etc/aliases

   Ademas, pueden añadirse otros ficheros de *aliases* alternativos con el mismo
   formato, manipulando la variable alias_maps_. 

   .. seealso:: El formato es algo mas complejo (p.e. los resultados pueden ser
      ficheros o tuberías y no sólo direcciones). Hay información completa sobre
      esta tabla en la `documentación oficial al respecto de postfix
      <http://www.postfix.org/aliases.5.html>`_.

   .. _postfix-forward:

   En relación con el agente local, aunque no es propiamente una tabla es el
   fichero :file:`~/.forward`. de cada usuario, cuyo contenido actua exactamente
   igual que la columna de resultados de :file:`/etc/aliases`. Esto permite a un
   usuario sin privilegios, pero con acceso a su cuenta del servidor, redirigir
   los mensajes tal como si lo hubiera podido hacer escribiendo en la tabla
   :file:`/etc/aliases`. Por ejemplo:

   * Podría referir una o varias cuentas de correo, lo que provocará que el mensaje se
     reenvíe a ellas::

         usuario usuario_remoto@gmail.com

     dejará una copia del mensaje en el buzón local, pero enviará también una
     copia a la cuenta de *gmail.com* indicada.

   * Podría crear una tubería a un |MDA| externo::

         "|IFS=' ' && exec /usr/bin/procmail || exit 75"

     lo cual permitiría a ese usuario particular hacer uso de los filtros que
     proporciona :ref:`procmail <procmail>` para organizar la entrega del correo
     en distintos buzones.

**Tablas virtuales** (definidas con virtual_alias_maps_)
   Se consultan sea cual sea la dirección de correo, ya que operan en la última
   etapa de la recepción del mensaje, justamente antes de que comience el
   proceso de entrega (véase `ADDRESS REWRITING`_). Por tanto, afecta tanto a
   direcciones locales como a direcciones externas.

   Su formato sigue lo dispuesto `en la documentación sobre virtual
   <http://www.postfix.org/virtual.5.html>`_ y, básicamente, lo podemos
   describir con un ejemplo::

      # cat > /etc/postfix/tb/aliases
      el.holandes.errante     pepe
      bartolo@gmail.com       @yahoo.es
      yo                      yo_tamibien@hotmail.com
      @mail1.org              chismoso
      # postmap /etc/postfix/tb/aliases

   .. warning:: Al crear o modificar una tabla *virtual* siempre es necesario
      regenerar el *db* correspondiente con :program:`postmap`.

   Las reglas para añadir dominio a las direcciones que no lo tienen son
   exactamente las mismas que para el caso de las tablas *alias*, por lo que
   este fichero indique que:

   * Las direcciones *el.holandes.errante@mail1.org* (o
     *el.holandes.errante@localhost*) se redirigen a *pepe@mail1.org*).
   * La dirección *bartolo@gmail.com* redirige a *bartolo@yahoo.es* (ese es el
     efecto de que no haya un usuario en la columna derecha).
   * La direcciones *yo@mail1.org* y *yo@localhost* se redirigen a
     *yo_tambien@hotmail.com*.
   * Finalmente, cualquier cuenta del dominio *@mail1.org* (salvo
     *yo@mail1.org*, por lo indicado antes), se redirige a *chismoso@mail1.org*.

     .. note:: Como en el caso de las tablas anteriores, las búsquedas también
        son recursivas.

   Para que opere una tabla de este tipo es necesario referirla a través de
   virtual_alias_maps_:

   .. code-block:: apache

      virtual_alias_maps = hash:/etc/postfix/tb/aliases

   El prefijo *hash* incluido en la configuración indica que es una base de
   datos de literales. Pueden usarse otros prefijos como *regexp* o *pcre*, que
   permiten expresar los valores de entrada como expresiones regulares. Por ejemplo,
   para emular el comportamiento del servidor *gmail*, cuyos nombre de cuenta ignoran
   los puntos, de modo que *pepe*, *p.epe* o *pe..p.e* acaban todas en el buzón de
   *pepe* podemos definir el siguiente fichero::

      # cat > /etc/postfix/tb/desechables
      /^(.*)\.(.*@mail1\.org)$/     $1$2
      # postmap /etc/postfix/tb/desechables

   .. note:: La exoresión sólo quita un punto del nombre de la dirección, pero
      al ser la búsqueda recursiva, se irán eliminado uno a uno, hasta no quedar
      ninguno.

   Por supuesto, pueden utilizarse ambos ficheros\ [#]_:

   .. code-block:: apache

      virtual_alias_maps = hash:/etc/postfix/tb/aliases regexp:/etc/postfix/tb/desechables

   .. warning:: Tenga presente que, a partir de ahora, no podrá haber cuentas
      finales con algún punto en su nombre, ya que éste se eliminará siempre.

Al margen de las cuentas virtuales, el servidor define un *delimitador de
recipiente*::

   # postconf recipient_delimiter
   recipient_delimiter = +

que propicia que el servidor descuente del nombre de cuenta todos los
caracteres a partir de tal signo y, por tanto, mensajes dirigidos a
*pepe+munoz@mail1.org* o *pepe+munoz+vazquez@mail1.org* acaban todos en el
buzón de *pepe*. A la hora de buscar corcondancias, la extensión (la parte
siguiente al signo) se ignora.

Entrega local
-------------

.. note:: Considere la posibilidad de usar :ref:`dovecot para la entrega local
   <postfix-dovecot-mda>`, especialmente:

   * Si pretende habilitar :ref:`cuotas de usuario <postfix-quota>`.
   * Si desea crear usuarios exclusivos, y piensa :ref:`hacerlo con dovecot
     <postfix-usu-virtual-dovecot>`.

Ya se ha dicho que el encargado de esta labor es el |MDA|. En los sistemas
*linux* los dos más usados son `procmail <http://www.procmail.org>`_ y `maildrop
<https://www.courier-mta.org/maildrop/>`_.

:program:`postfix`, si no se configura, usa un |MDA| interno (véase
:manpage:`local(8)`) bastante simple, aunque pueden pasarse los mensajes a un
|MDA| externo gracias a la directiva ``mailbox_command``::

   mailbox_command = /usr/bin/procmail -f-

o bien::

   mailbox_command = /usr/bin/maildrop

o bien::

   mailbox_command = /usr/lib/dovecot/dovecot-lda -f "$SENDER" -a "$RECIPIENT"

Nosotros, no obstante, prescindiremos de ellos y usaremos el |MDA| local de
:program:`postfix`. En este caso, la directiva interesante es ``home_mailbox``
que permite definir cuál será el buzón de correo. Si no se fija valor alguno,
:program:`postfix` dejará los correos en formato *mbox* dentro de
:file:`/var/mail/nombre_usuario`. Cuando se fija valor deben tenerse en cuenta
dos reglas:

* Las rutas relativas son relativas al directorio personal del usuario.
* Si el valor acaba en barra ("*/*"), :program:`postfix` entenderá que queremos
  crear un buzón en formato *maildir*.

Un valor común para esta directiva es::

   home_mailbox = Maildir/

La entrega local de correo con :program:`postfix` la realiza un |LMTP| interno
y es muy simple: se limitará a dejar el correo en el buzón referido.

.. _postfix-dovecot-mda:

Entrega a través de |LMTP|
--------------------------
Si hemos :ref:`configurado dovecot para que actúe como un LMTP <dovecot-mda>`,
podemos hacer que sea él quien se encargue de realizar las entregas en los
buzones de usuario.

En principio, basta con añadir la línea:

.. code-block:: apache

   mailbox_transport = lmtp:unix:private/dovecot-lmtp
   #mailbox_transport = lmtp:localhost:24

.. seealso:: Si planea crear :ref:`usuarios exclusivos
   <postfix-usu-virtual-dovecot>`, tendrá que añadir una línea más a la
   configuración que se verá más adelante.

La configuración a este respecto está completa, ahora bien, al cambiar el
transporte, ¿siguen siendo válidas las cuentas virtuales definidas a través de
virtual_alias_maps_ y :file:`/etc/aliases`? La respuesta es sí en cualquier caso
para las primeras, y sí para las segundas gracias a que el dominio *mail1.org*
está referido en mydestination_ y a que es el agente *local* de
:program:`postfix`, después de operar, el que usa mailbox_transport_ para ceder
al |LMTP| de :program:`dovecot` la última operación de entrega en los buzones.

.. note:: Por esta última razón, el :ref:`fichero ~/.forward <postfix-forward>`
   de un usuario también es leído y se obra según se disponga en él.

.. _postfix-quota:

Cuotas
------
:program:`postfix` dispone de las directivas ``message_size_limit`` y
``mailbox_size_limit`` la segunda de las cuales sólo es útil si usamos el
formato *mbox*. En realidad, si se quiere implementar un mecanismo de cuotas de
usuario, es necesario hacer uso de herramientas externas, por ejemplo, de
:ref:`dovecot <dovecot>` que usaremos como servidor |IMAP| y que sí las
implementa. Es más, :command:`dovecot` contiene un servicio especialmente
escrito para :program:`postfix` que puede ser utilizado por éste para comprobar
si el usuario tiene agotado su buzón en el momento en que recibe un mensaje de
correo a través de |SMTP|. Esto permite rechazar correos e informar al servidor
remitente del rechazo.

Así pues, habilite las cuotas de correo según los explicado :ref:`en la sección
correspondiente de dovecot <dovecot-quota>`. Si :ref:`entrega los mensajes con
dovecot <postfix-dovecot-mda>`, no necesitará más, aunque puede avanzar hasta el
final del epígrafe para ver cómo enviar mensajes con adjuntos a fin de comprobar
si alcanza la cuota.

.. warning:: Con la configuración propuesta, los usuarios reales del sistema,
   son usuarios locales y, en consecuencia, usan el transporte local antes de
   que se ceda la entrega a :program:`dovecot`. Esta circunstancia permitiría a un
   usuario real con acceso al sistema crear un fichero :file:`~/.forward` que
   evitara la entrega con :program:`dovecot` y, en consecuencia, la aplicación
   de la cuota. Si nos resulta importante esto, podemos optar bien por tratar
   como virtuales todos los dominios salvo *localhost* (lo cual requiere una
   configuración distinta a la propuesta), bien por deshabilitar la lectura de
   este fichero:

   .. code-block:: apache

      forward_path =

Sin embargo, si prefiere que sea el propio :program:`postfix` el que entregue los
mensajes en los buzones locales, entonces deberá asegurarse de activar el
servicio para la consulta de la cuota, tal como se expone en el enlace, y
continuar leyendo el contenido de este epígrafe.

.. warning:: El problema de que :program:`postfix` se encargue de la entrega
   local y nos veamos obligados a usar este servicio de cuota, es que la
   consulta se realiza antes de que hayan operado los mecanismos de entrega, lo
   que impide ponerlo en práctica con cuentas virtuales. Para soslayar este
   problema es necesario que :ref:`dovecot entregue los mensajes <postfix-dovecot-mda>`.

Para lograr que program:`postfix` use el servicio al recibir mensajes, debe
añadir en :file:`/etc/postfix/main.cf`:

.. code-block:: apache

   smtpd_end_of_data_restrictions = check_policy_service inet:127.0.0.1:12340

o, si se optó por escuchar en el socket:

.. code-block:: apache

   smtpd_end_of_data_restrictions = check_policy_service unix:private/quota-status
      
.. note:: La restricción se habilita una vez obtenido el contenido del mensaje,
   porque sólo entonces se conoce cual es su tamaño.

Si deseamos comprobar cómo se comporta el servicio al recibir la consulta de
:program:`postfix` podemos utilizar la escucha a través del puerto y hacer lo
siguiente::

   $ printf "recipient=usuario@example.net\nsize=1000000000\n\n" | netcat -q1 localhost 12340
   action=552 5.2.2 Mailbox is full

El servicio nos contestará con la acción apropiada. Si es *DUNNO*, el mensaje
supera la restricción, pero si la cuota se ha sobrepasado se generará un
error **552**, que se comunicará al servidor remitente.

Si queremos saber exáctamente cuáles son los parámetros que :program:`postfix`
comunica al servicio, podemos utilizar la siguiente argucia::

   $ invoke-rc.d dovecot stop
   $ netcat -l -p 12340

y enviamos el mensaje. :ref:`netcat <netcat>` debería mostrarnos entre otros
muchos datos *recipient* y *size*, que son los que usa el servicio de cuota para
aceptar o rechazar el mensaje.

Por último, a fin de alcanzar la cuota y comprobar que se rechazar mensajes
puede interesarnos enviar mensajes con adjuntos. Un método bastante sencillo es
usar :ref:`mutt <mutt>` en conjunción con :program:`msmtp`, que ya deberíamos
haber configurado al comprobar la instalación de :program:`postfix`. Para ello,
debemos instalar :program:`mutt` y crear un fichero de configuración
:file:`~/muttrc.vm` como este:

.. code-block:: apache

   set sendmail="/usr/bin/msmtp -a vm587"
   set use_from=yes
   set realname="Usuario de MAIL1"
   set from="usuario@mail1.org"

Hecho lo cual, podremos enviar nuestro mensaje con adjunto del siguiente modo\
[#]_::

   $ echo "Este es el cuerpo" | mutt -F ~/mutt.vm -s "Mensaje con adjunto" -a /ruta/fichero_gordo -- usuario@mail1.org

Servidor de respaldo
--------------------
Un :dfn:`servidor de respaldo` es aquel que recibe el correo de un dominio,
cuando el servidor principal es inaccesible. Su función es recibir los
mensajes, almacenarlos en cola durante durante el tiempo que el servidor
principal está caído y remitirlos cuando éste recupera su buen funcionamiento.
Durante este tiempo, intentará conectarse periódicamente al servidor para
entregar los mensajes que tenga en cola.

Antes de entrar a configurar un servidor de este tipo, es indispensable que el
servicio |DNS| identifique a este servidor como servidor de correo menos
prioritario. Por ejemplo, si llamamos a esta tercera máquina
*backup-mx.mail1.org* para que sea servidor de *backup* del servidor de correo
del primer dominio, deberá ocurrir lo siguiente::

   $ host mail1.org
   mail1.org mail is handled by 2 backup-mx.mail1.org.
   mail1.org mail is handled by 1 mail.mail1.org.

y que la nueva máquina tenga una |IP| adecuada (p.e. 192.168.255.10)::

   $ host backup-mx.mail1.org
   backup-mx.mail1.org has address 192.168.255.10

De este modo, cuando otro servidor de correo intente entregar un mensaje
a alguna cuenta de *mail1.org* intentará entregárselo a *mail.mail1.org*, pero
si no puede, porque comprueba que no puede conectar con la máquina, intentará
la entrega a *backup-mx.mail1.org*. 

Para configurar *backup-mx.mail1.org* podemos obrar exactamente igual que cuando
configuramos *mail.mail1.org* en cuanto a instalación y configuración básica y
del cifrado\ [#]_, lo cual nos generará una :ref:`configuración equivalente a la
ya vista en main.cf <postfix-conf-bas-main.cf>`. Esa configuración, no obstante,
no es la definitiva y deberemos hacerle algunos cambios

.. code-block:: apache
   :emphasize-lines: 1-4, 8, 9

   smtpd_relay_restrictions = permit_mynetworks
                              reject_unauth_destination
                              reject_rbl_client zen.spamhaus.org
   myhostname = backup-mx.mail1.org
   alias_maps = hash:/etc/aliases
   alias_database = hash:/etc/aliases
   myorigin = /etc/mailname
   mydestination = localhost
   relayhost = mail.mail1.org
   mynetworks = 127.0.0.0/8
   mailbox_size_limit = 0
   recipient_delimiter = +
   inet_interfaces = all
   inet_protocols = ipv4

Los cambios, básicamente, han sido:

* Modificar la política de restricciones para tráfico de *relay*, ya que nuestro
  servidor hace de *relay* entre el |MTA| del que procede el correo y el |MTA|
  destinatario (*mail.mail1.org*).
* Ajustar convenientemente el nombre del servidor (cosa que también hicimos
  antes a posteriori).
* Definir como destino final para la máquina exclusivamente *localhost* y no el
  dominio *mail1.org*, ya que de lo contrario los mensajes se los quedaría
  esta máquina en vez de pasarlos a la máquina destinataria...
* ... que es la que se indica con relayhost_.

.. warning:: Es sumamente importante que el dominio *mail1.org* no aparezca en
   mydestination_ (ni en virtual_alias_domains_ ni
   virtual_mailbox_domains_)

Debemos, además, completar la configuración añadiendo las siguientes líneas:

.. code-block:: apache

   relay_domains = mail1.org
   relay_recipient_maps =
   # Máximo tiempo en cola
   maximal_queue_lifetime = 5d

que definen *mail1.org* como el dominio válido para el *relay* y mantienen los
mensajes en nuestro servidor hasta cinco días, por lo que ese será el plazo para
que el servidor principal recobre su funcionalidad.

.. note:: Ahora podemos probar nuestra configuración apagando *mail.mail1.org* y
   enviando un correo desde *mail.mail2.org*. Mirando los registros podremos
   observar cómo el correo acaba en *backup-mx.mail1.org* y queda en cola\ [#]_
   hasta que pueda remitirlo al servidor principal. Si encedemos luego éste y
   esperamos un tiempo, comprobaremos cómo finalmente el servidor de *backup*
   acaba por enviar el mensaje al principal. Si nos impacientamos, podemos
   ordenar al servidor de respaldo que pruebe a enviar la cola así::

      # sendmail -q

Con esta configuración, el servidor de *backup* recibe mensajes sin
autenticación de otros servidores |MTA|, pero no es apto para que los clientes
se configuren para enviar los mensajes a través de él.

Conviene, en cualquier caso, asegurarse de que el servidor principal jamás
rechará las conexiones del servidor de respaldo. Para ello, en *mail.mail1.org*
podemos añadir a las restricciones de acceso la siguiente línea:

.. code-block:: apache
   :emphasize-lines: 3

   smtpd_recipient_restrictions = permit_mynetworks,
                                  permit_sasl_authenticated,
                                  check_client_access hash:/etc/postfix/tb/clients
                                  reject_unauth_destination,
                                  reject_unknown_client_hostname,
                                  reject_rbl_client zen.spamhaus.org

y añadir al fichero :file:`/etc/postfix/tb/clients`::

   # cat > /etc/postfix/tb/clients
   backup-mx.mail1.org           OK

   # postmap /etc/postfix/tb/clients  # Necesario para que postfix use la tabla.

.. warning:: La configuración expuesta sólo es válida para servidores puramente
   de respaldo capaces de aceptar correos para sí mismos (los dirigidos a
   *@localhost*) y para el único servidor al que respalda (el del dominio
   *@mail1.org*).
  
La validez de la solución nace de que su comportamiento surge fundamendalmente
de estas líneas de configuración:

.. code-block:: apache

   smtpd_relay_restrictions = permit_mynetworks reject_unauth_destination reject_rbl_client zen.spamhaus.org
   mydestination = localhost
   relayhost = mail.mail1.org
   relay_domains = mail1.org

que introduce tres limitaciones en el comportamiento:

#. El servidor es inservible para gestionar su propio dominio de correo, porque
   aunque añadiéramos un dominio propio a mydestination_::

      mydestination = mail3.org, localhost

   seguiría sin ser apto, ya que estos usuarios sólo podrían enviar mensajes a
   usuarios del propio dominio o de *mail1.org*. Mensajes dirigidos a cuentas de
   otros dominioo serían rechazados debido a la política reflejada en
   smtpd_relay_restrictions_.

#. No envía mensajes a cuentas de servidores distintos a los de *relay*, porque
   aunque hiciéramos la modificación expuesta en el punto anterior y
   nodificáramos la política de *relay*, introduciendo autenticación y
   permitiendo que los usuarios autenticados envíen mensajes a cuentas de
   cualquier dominio, los mensajes continuarían sin llegar a su destino, puesto
   que, al hacer *relay*, todo mensaje se entregaría al servidor
   *mail.mail1.org* y sería este el que se negase a retransmitir los mensajes a
   servidores externos.

#. El servidor puede gestionar varios dominios de *relay*, pero todos esos
   dominios debe gestionarlos un único servidor: el indicado en relayhost_.

Para soslayar estas limitaciones, además de hacer las pertinentes modificaciones
en la configuración (cambiar las políticas de acceso, habilitar la autenticacón,
etc.), es necesario dejar sin configurar relayhost_ y echar mano de
transport_maps_. Un trozo de configuración (al que habría que añadir políticas
de acceso y autenticación) puede ser este:

.. code-block:: apache

   mydestination = mail3.org, localhost
   relayhost =
   relay_domains = mail1.org, mail2.org
   transport_maps = hash:/etc/postfix/tb/relay_domains_maps

y en el fichero :file:`/etc/postfix/tb/relay_domains_maps` deberá indicarse qué
servidor corresponde a cada dominio::

   mail1.org      smtp:[smtp.mail1.org]
   mail2.org      smtp:[smtp.mail2.org]

Sobre esta base sí podríamos construir un servidor que maneja un dominio propio
y que, además, respalda dos dominios de sendos servidores distintos.



.. rubric:: Notas al pie

.. [#] :ref:`dovecot <dovecot>`, el servidor |IMAP| que veremos a continuación
   crea cuatro buzones de correo de manera predeterminada: el principal y tres
   buzones que son subdirectorios: :file:`.Sent` (para almacenar mensajes
   enviados), :file:`.Trash` (para la papelera de mensajes) y :file:`.Drafts`
   para almacenar borradores.
.. [#] No así en :program:`dovecot` para el que sí usaremos ese término, ya que
   no hay posibilidad de confusión.
.. [#] Sin embargo, si la dirección no es local, no se busca en las tablas
   definidas en virtual_alias_maps_. Téngalo en cuenta, porque un alias que
   haya definido en un a tabla *virtual*, no se resolverá y se topará con un
   error de usuario inexistente.
.. [#] A las direcciones sin dominio, se les añade el dominio definido en
   myorigin_.
.. [#] En este caso, el orden de los factores altera el producto. Si invertimos
   el orden, se elimarán antes los puntos y, por tanto, al analizar la segunda
   tabla nunca habrá concordancia con *el.holandes.errante* (pero sí con
   *elholandeserrante*).
.. [#] El mensaje se envía a una cuenta del propio *mail1.org*, porque se ha
   supuesto que ha sido en este servidor donde se ha habilitado la cuota.

.. [#] La configuración de autenticación no la haremos por ahora, porque no es
   estrictamente necesaria.
.. [#] Para saber cuál es el tráfico en cola puede hacerse::

         # mailq

      .. seealso:: En `este artículo
         <https://www.wirehive.com/thoughts/5-top-tips-reviewing-postfix-mail-queue/>`_ se expone cómo investigar
         sobre nuestra cola de mensajes.

.. |MDA| replace:: :abbr:`MDA (Mail Delivery Agent)`
.. |LMTP| replace:: :abbr:`LMTP (Local Mail Transfer Protocol)`
.. |MTA| replace:: :abbr:`MTA (Mail Transmission Agent)`

.. _virtual_alias_maps: http://www.postfix.org/postconf.5.html#virtual_alias_maps
.. _virtual_mailbox_domains: http://www.postfix.org/postconf.5.html#virtual_mailbox_domains
.. _virtual_transport: http://www.postfix.org/postconf.5.html#virtual_transport
.. _mydestination: http://www.postfix.org/postconf.5.html#mydestination
.. _mailbox_transport: http://www.postfix.org/postconf.5.html#mailbox_transport
.. _sendmail: https://www.sendmail.org
.. _ADDRESS REWRITING: http://www.postfix.org/ADDRESS_REWRITING_README.html
.. _smtp_generic_maps: http://www.postfix.org/postconf.5.html#smtp_generic_maps
.. _sender_canonical_maps: http://www.postfix.org/postconf.5.html#sender_canonical_maps
.. _canonical_maps: http://www.postfix.org/postconf.5.html#canonical_maps
.. _recipient_canonical_maps: http://www.postfix.org/postconf.5.html#recipient_canonical_maps
.. _alias_maps: http://www.postfix.org/postconf.5.html#alias_maps
.. _myorigin: http://www.postfix.org/postconf.5.html#myorigin
.. _local_header_rewrite_clients: http://www.postfix.org/postconf.5.html#local_header_rewrite_clients
.. _smtpd_relay_restrictions: http://www.postfix.org/postconf.5.html#smtpd_relay_restrictions
.. _relayhost: http://www.postfix.org/postconf.5.html#relayhost
.. _transport_maps: http://www.postfix.org/postconf.5.html#transport_maps
.. _virtual_alias_domains: http://www.postfix.org/postconf.5.html#virtual_alias_domains
