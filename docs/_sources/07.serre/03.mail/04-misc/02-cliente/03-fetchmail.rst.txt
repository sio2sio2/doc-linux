***********************************************
:program:`fetchmail`/:program:`getmail` (|MRA|)
***********************************************

Como |MRA| estudiaremos dos de los más usandos en *Linux*:

* El veterano :ref:`fetchmail <fetchmail>`.
* El más moderno :ref:`getmail <getmail>`, que es quizás más recomendable.

.. _fetchmail:

:command:`fetchmail`
====================
Ya se ha introducido `el programa fetchmail <http://www.fetchmail.info/>`_ como
un *software* que permite descargar a través de |POP|\ 3 o |IMAP| los mensajes
almacenados en buzones remotos\ [#]_. La ventaja de usarlo es que puede
programarse para que, en segundo plano, vaya descargando el correo
periodicamente. Si la presencia de nuevo correo se combina con un aviso visual o
sonoro mediante otro programa, podemos estar siempre informados de la llegada de
nuevo correo\ [#]_.

La instalación es sencilla a través del paquete homónimo::

   # apt-get install fetchmail

Hay dos modos de arrancar :command:`fetchmail`:

#. Como servicio de :program:`systemd` con una configuración centralizada en
   :file:`/etc/fetchmailrc`.
#. Como programa que ejecuta un usuario interesado según su configuración
   incluida en :file:`~/.fetchmailrc`.

Comencemos primero por analizar un :download:`fichero de configuración típico
<files/fetchmailrc>`:

.. literalinclude:: files/fetchmailrc

* :kbd:`set daemon` establece que el programa correrá como demonio e intentará
  la descarga de correo cada 5 minutos (300 segundos). Si no existe, esta sentencia;
  :command:`fetchmail` se ejecuta sólo una vez y acaba\ [#]_.
 
  .. warning:: Si optáramos por ejecutarlo periódicamente con :program:`cron`
     deberíamos prescindir de esta línea.

* Hay un primer bloque introducido con ``defaults`` que establece la
  configuración predeterminada para todos los servidores.
 
* Una opción muy interesante en ese bloque es ``keep`` que no borrará los
  mensajes del servidor. Con la capacidad que tienen los buzones de los modernos
  servidores, arriesgarse a perder un mensaje entra de lleno dentro de la
  cicatería más injustificable. Que los mensajes permanezcan en el servidor, no
  implica que la próxima vez, se vuelvan a descargar: sólo se descargarán los
  nuevos\ [#]_.

* Es posible también incluir la opcion ``mda`` que establece cuál es el |MDA| al
  que se pasarán los mensajes para que este haga la entrega efectiva al usuario.
  Si no especificamos ninguno, se entregarán al |MTA| local y será éste el que
  se encargue de la entrega (quizás a su vez usando un |MDA| externo, todo
  depende de :ref:`cómo hallamos decidido configurarlo <cliente-postfix>`). Véase
  :ref:`el epígrafe dedicado a procmail <procmail>` para conocer la
  configuración de uno.

* Para cada servidor los bloques se introducen con ``poll`` o ``skip``. Estos
  segundos son bloques que :command:`fetchmail` se salta, por lo que pueden
  servir para hacer una definición, pero que temporalmente no usaremos por
  alguna razón.

* El fichero presenta una configuración con |POP|\ 3 y otra con |IMAP|
  aprovechando que *gmail.com* permite descargar por cualquiera de los dos
  protocolos. Eso sí, una la hemos deshabilitado para no revisar estúpidamente
  dos veces.

* Los bloques dedicados a cada servidor son bastante sencillos de entender, pero
  apuntemos algunos particularidades:

  - Usamos protocolo seguro (:kbd:`ssl`) y, además, comprobamos la autenticidad
    del certificado del servidor (:kbd:`sslcertck`). Obviamente, si el servidor
    |IMAP| lo hubiéramos montado nosotros y usáramos :ref:`certificados
    autofirmados <auto-cert>`, la comprobación fallaría y :program:`fetchmail`
    se negaría a proseguir la autenticación.

  - El protocolo |IMAP| se caracteriza porque permite al usuario tener
    organizados sus mensajes en distintos buzones dentro del servidor. Por
    tanto, cuando los descargamos debemos especificar de qué buzón queremos
    hacerlo. Lo habitual es que los correos entrantes acaben en un buzón que se
    llama ``INBOX``, aunque esto depende de cómo se haya configurado el |MDA| en
    el servidor. Por esa razón, el bloque que ilustra una conexión |IMAP|
    incluye la línea::

      folder INBOX

    Si quiéramos descargar de varios buzones no habría más que añadir sus
    nombres\ [#]_::

      folder INBOX
             INBOX.trabajo
             INBOX.cooperativa

    Como en |POP|\ 3 no hay más que un buzón por usuario, esta direciva carece
    de sentido.

  - El bloque acaba especificando a qué usuario local deben entregarse los
    mensajes descargados del servidor en cuestión. Esto es necesario cuando
    tenemos una configuración centralizada y ejecutamos :command:`fetchmail`
    como servicio de :program:`systemd`. En cambio, si cada usuario lo ejecuta
    por su cuenta, podemos prescindir de esta línea, ya que :command:`fetchmail`
    lo entregará al *usuario local que lo ejecute*.

.. nota:: Para probar la configuración podemos hacer::

      $ fetchmail -v -d0

   que irá mostrando los comandos que se ejecutan y evitará la ejecución como
   demonio (el :kbd:`set daemon` incluido en el fichero), pòr lo que después de
   haber revisado todos los servidores y descagados los mensajes pendientes,
   :command:`fetchmail` acabará.

Así, pues, éste es un fichero de configuración válido tanto para la gestión
centralizada (en :file:`/etc/fetchmailrc`) como para la gestión distribuida (en
:file:`~/.fetchmailrc)`. Ahora, si se desea centralizadamente demonizar en el
arranque :program:`fetchmail`, es necesario, además, que
:file:`/etc/default/fetchmail` contenga la línea::

   START_DAEMON=yes

En cambio, si nuestra intención es hacer configuraciones particulares de
usuario, existe un problema: dado que no tenemos un servicio asociado que
ejecute :command:`fetchmail` al arrancar el sistema, cada usuario deberia
arrancarlo explícitamente tras iniciar sesión. Eso... o ser un poco más
inteligente:

a. Podemos eliminar la directiva que lo transforma en un demonio (:kbd:`set
   daemon`) y hacer que se ejecute periódicamente :ref:`editando el contrab del
   usuario <cron>`. Esta alternativa es trivial si se conoce :program:`cron` y
   es precisamente la que se utiliza al configurar más adelante getmail_.

#. Manipular |PAM| para que el arranque de :program:`fetchmail` se haga como
   parte el proceso de autenticación.  Y eso haremos, porque :download:`el
   script <files/pam_fetchmail.sh>` es bastante sencillo: basta con comprobar si
   :file:`~/.fetchmailrc` existe y, si es así, lanzar fetchmail que quedará en
   memoria como demonio si así lo hemos dispuesto:

   .. literalinclude:: files/pam_fetchmail.sh
      :language: bash

   Hecho lo cual, deberíamos hacer que |PAM| lo ejecutase. Lo más elegante es crear
   un fichero de configuración en :file:`/user/share/pam-configs` para
   :command:`pam-auth-update` con el :download:`siguiente contenido
   <files/fetchmail>`:

   .. literalinclude:: files/fetchmail
      :language: bash

.. _getmail:

:program:`getmail`
==================
:program:`getmail` y más concretamente `la versión 6 de getmail
<https://getmail6.org/>`_ es un |MRA| escrito en Python3. Con este *software*
parece no ser posible centralizar la configuración, sino que cada usuario debe
hacer la configuración de sus cuentas de correo. Además, no puede demonizarse
con lo que forzosamente debe echarse mano de :ref:`cron <cron>` para obtener
regularmente los mensajes del servidor.

Empecemos, no obstante, por explicar dónde colocar los archivos de
configuración. Hay dos posibles localizaciones:

* :file:`~/.getmail/`.
* :file:`$XDG_CONFIG_HOME/getmail/`, que habitualmente es
  :file:`~/.config/getmail/`

Dentro de este directorio se buscará el archivo :file:`getmailrc` o en su
ausencia cualquier otro que contenga configuración\ [#]_ y a los que es
convenientemnete poner como nombre la dirección de la cuenta que configuran
(p.e. :file:`pericodelospalotes@gmail.com`), porque es importante tener
presente que un archivo sólo puede contener la información sobre un buzón.

Cada archivo de configuración tendrá un aspecto semejante a este:

.. literalinclude:: files/getmailrc
   :language: ini

en el que hay tres secciones:

:kbd:`[retreiver]`
   que contiene la información de autenticación. En el ejemplo, se usa el
   protocolo |POP|\ 3s para obtener los mensajes del buzón.

:kbd:`[options]`
   que define algunas particularidades de la obtención. En el ejemplo, sólo se
   descargan mensajes nuevos, no se borran del buzón los mensajes y se define un
   archivo para almacenar los registros.

:kbd:`[destination]`
   que define cómo se entregan los mensajes al usuario destinatario. En el
   ejemplo, se ceden los mensajes a un |MDA| externo (:ref:`procmail <procmail>`),
   aunque se podrían:

   a. haber dejado en una archivo (formato *mailbox*)

      .. code:: ini

         [destination]
         type = Mboxrd
         path = ~/inbox

      aunque el archivo :file:`inbox` debe preexistir. Bastará con crear un
      archivo vacío::

         $ touch ~/inbox

   #. en un directorio (formato *maildir*):


      .. code:: ini

         [destination]
         type = Maildir
         path = ~/Mail/

      aunque el directorio debe existir previamente::

         $ mkdir -p ~/Mail/{new,cur,tmp}

   #. haberse cedido a un |MTA| local (que es como se configuró fetchmail_):


      .. code:: ini

         [destination]
         type = MDA_qmaillocal

.. note:: Pueden crearse también secciones para filtrado de mensajes utilizando
   etiquetas :kbd:`[filter-loquesea]`, pero no las abordaremos ya que hemos
   optado por usar :program:`procmail` para ese trabajo.

.. seealso:: Para más información, puede consultarse la `página oficial de
   la documentación <https://getmail6.org/configuration.html>`_.

.. todo:: Documentar la demonización consultando la `wiki de Archilinux
   <https://wiki.archlinux.org/title/Getmail#Fetching_mail_automatically_with_systemd>`_.

.. |POP| replace:: :abbr:`POP (Post Office Protocol)`
.. |MUA| replace:: :abbr:`MUA (Mail User Agent)`
.. |MDA| replace:: :abbr:`MDA (Mail Delivery Agent)`
.. |MRA| replace:: :abbr:`MRA (Mail Retrieval Agent)`
.. |MTA| replace:: :abbr:`MTA (Mail Transport Agent)`

.. rubric:: Notas al pie

.. [#] Como también se ha dicho que esta función a veces la incopora el propio
   |MUA|.
.. [#] Por supuesto también puede haber |MUA|\ s que se puedan dejar residir en
   memoria y hacer toda esta labor de manera integrada.

.. [#] A menos que se use la opción ``-d segundos`` que equivale a :kbd:`set daemon`
   en la configuración de fichero.

.. [#] Si se quieren descargar todos los mensajes de un servidor, incluso los
   descargados anteriormente, se puede añadir la opción :kbd:`fetchall`.

.. [#] El ejemplo ilustra dos buzones más llamados :file:`INBOX.trabajo` e
   :file:`INBOX.cooperativa`. Los nombres son absolutamente arbitrarios y no
   tendrían porquñé haber empezado con *INBOX*.

.. [#] Para otras ubicaciones, aún es posible utilizar la opción :kbd:`-r`
   (incluso repetidamente) al ejecutar :command:`getmail`.
