.. _oauth2-gmail:

Autenticación OAuth2 para *Gmail*
*********************************
Desde junio de 2022 `Google no permite la autenticación simple con usuario y
contraseña <https://support.google.com/accounts/answer/6010255?hl=en>`_, lo que
inutiliza algunas de las configuraciones expuestas si se utiliza *Gmail* como
servidor de correo.

Para que la autenticación sea válida, debe realizarse desde una aplicación
confiable que haya sido registrada como tal en *Google*. Tal es el caso, por
ejemplo, del cliente gráfico Thunderbird_. Sin embargo, muchas de las
aplicaciones indicadas aquí no son aplicaciones confiables, lo que nos obliga a
hacer una configuración adicional, que básicamente consiste en 

+ Obtener unas credenciales válidad de autenticación a través de la consola de
  desarrollo que proporciona Google.
+ Configurar la aplicación que queremos usar para que use tales credenciales.

Obtención de credenciales
=========================
Antes de configurar las aplicaciones, nuestro objetivo es obtener una
credenciales apropiadas, para lo cual debemos acceder con nuestro usuario de
*Gmail* a la `consola de desarrollador <https://console.developers.google.com>`_
y seguir los siguientes pasos:

#. En la sección de "Biblioteca" habilitar la |API| para *Gmail*:

   .. image:: files/00-api.png

#. A continuación debemos definir una pantalla de consentimiento para *OAuth2*,
   que nos pedirá que creemos antes un nuevo proyecto, si aún no hemos creado
   ninguno:

   .. image:: files/01-OAuth.png

   .. image:: files/02-proyecto.png

#. Completar la definición de la pantalla de consentimiento, lo cual no tiene
   excesiva dificultad:

   .. image:: files/03-consentimiento.png

   .. image:: files/04-consentimiento.png

   .. image:: files/05-consentimiento.png

   Eso sí, habrá que definir los permisos que se conceden y deberemos habilitar 
   los relativos a *Gmail*:

   .. image:: files/06-cons-permisos.png

   Y, finalmente, habrá que incluir como usuario de prueba el usuario con el
   que deseamos autenticarnos:

   .. image:: files/07-cont-usuario.png

#. Crear propiamente las credeanciales para "ID de cliente de OAuth":

   .. image:: files/08-credenciales.png

   .. image:: files/09-credenciales.png

   .. image:: files/10-credenciales.png

Como resultado, obtenemos las credenciales que deberemos usar en la
configuración de nuestras aplicaciones.

Configuración de aplicaciones
=============================
El método de configuración, obviamente, es particular para cada aplicación.

.. _mutt-oauth2:

:program:`mutt`
---------------
:program:`mutt` requiere la autenticación tanto para el envío de mensajes a
través del servidor |smtp| como para el acceso |imap| interactivo. para
llevarlo a cabo, el paquete :deb:`mutt` provee un *script* escrito en
:program:`python`: :file:`/usr/share/doc/mutt/examples/mutt_oauth2.py`.
asi que empezaremos por copiar este *script* en un lugar adecuado::

   $ mkdir -p .config/mutt
   $ install -m750 /usr/share/doc/mutt/examples/mutt_oauth2.py ~/.config/mutt/

La estrategia del *script* es almacenar el *token* de acceso en un archivo
cifrado para lo cual en principio usa |GPG| (véase :ref:`GNUpg <gnupg>` para más
detalles sobre las órdenes siguientes). Como en *Debian* es una dependencia del
propio :program:`mutt` no será necesaria ninguna instalación adicional.

Ilustremos cómo usar |GPG| para cifrar el archivo. Lo primero es generar una
clave::

   $ gpg --gen-key
   Nombre y apellidos: Mutt Oauth2
   Dirección de correo electrónico: pericodelospalotes@token

La orden nos pedirá un nombre y una dirección de correo, que puede ser
directamente la dirección de correo de la que estamos generando la
autenticación, pero no necesariamente\ [#]_. Para demostrar que no tiene por qué ser
así, aquí utilizaremos la dirección ficticia :kbd:`pericodelospalotes@token`.
En cualquier caso, la clave privada se cifra con una contraseña que deberemos
recordar, porque será la que se nos pregunte cuando queramos tener acceso al
token.

.. note:: Para que :program:`gpg-agent` sepa por donde pedir la contraseña
   podría ser necesario definir una variable de ambiente persistente:

   .. code-block:: bash

      export GPG_TTY=$(tty)

Generada la clave, debemos editar :file:`~/.config/mutt/mutt_oauth2.py` para:

- En la definición de :kbd:`ENCRYPTION_PIPE` debemos la dirección de correo
  a la que asociamos la clave recién creada (:kbd:`pericodelospalotes@token`)
- Añadir las credenciales :kbd:`client_id` y :kbd:`client_secret` obtenidas
  bajo el epígrafe anterior (que están referidas a la cuenta real
  :kbd:`pericodelospalotes@gmail.com`).

.. _gen_token_oauth2_mutt:

Una vez hecho, podemos obtener el *token* y almacenar en un archivo ejecutando
la orden::

   $ ~/.config/mutt/mutt_oauth2.py -va ~/.config/mutt/pericodelospalotes@gmail.com.token

Esta orden generará en primera instancia una |URL| que habrá que copiar en el
navegador y a resultas de la cual, se generará un código que debemos facilitar
al *script* para que acabe creando el archivo cifrado. Se nos preguntará por una
dirección de correo que debe ser la dirección real
(:kbd:`pericodelospalotes@gmail.com`) ya que se utiliza para definir qué cuenta
quiere ser autenticada.

Con esto ya podemos configurar :program:`mutt`, pero antes probemos que el *token* funciona\ [#]_::

   $ ~/.config/mutt/mutt_oauth2.py -vt ~/.config/mutt/pericodelospalotes@gmail.com.token
   Access token: xxx
   IMAP authentication succeeded
   POP authentication succeeded
   SMTP authentication succeeded

Finalmente, para configurar |SMTP| e |IMAP| la configuración necesaria es la siguiente:

.. code-block:: bash

   set smtp_url = "smtp://pericodelospalotes@gmail.com@smtp.gmail.com:587/"
   set smtp_authenticators = "oauthbearer:xoauth2"
   set smtp_oauth_refresh_command = "~/.config/mutt/mutt_oauth2.py ~/.config/mutt/pericodelospalotes@gmail.com.token"

   set imap_user="pericodelospalotes@gmail.com"
   set folder = "imap://imap.gmail.com"
   set imap_authenticators=$smtp_authenticators 
   set imap_oauth_refresh_command=$smtp_oauth_refresh_command

.. note:: :ref:`GNUpg <gnupg>` dispone de un agente que recuerda la
   contraseña, por lo que si envíamos varios mensajes sólo deberemos
   introducirla al realizar el primer envío. Por otra parte, :program:`GNUpg`
   también puede integrarse con :ref:`Gnome Keyring <gnome-keyring-ssh>` con lo
   que podríamos lograr que el acceso al sistema desbloquease la clave y no
   hubiera que introducirla más.

.. rubric:: Variantes

Consisten en utilizar métodos alternativos a |GPG| con este mismo *script*:

#. No cifrar el archivo en absoluto. Basta con usar :ref:`cat <cat>` como
   programa de cifrado para lo cual podemos :program:`mutt_oauth2.py` y dejarlo
   así:

   .. code-block:: python

      ENCRYPTATION_PIPE = ['cat']
      DECRYPTATION_PIPE = ['cat']

   Por supuesto, nos ahorramos todo lo relativo a crear la clave |GPG|.

#. Cifrar el archivo con contraseña:

   .. code-block:: python

      ENCRYPTION_PIPE = ['openssl', 'enc', '-aes256', '-pbkdf2', '-a']
      DECRYPTION_PIPE = ['openssl', 'enc', '-aes256', '-pbkdf2', '-a', '-d']

   .. note:: Esta variante se deja como curiosidad, ya que es enormemente
      incómoda: como no hay agente que recuerde la contraseña, habrá que
      introducirla cada vez que se envíe un mensaje.

.. _getmail-oauth2:

:program:`getmail`
------------------
Debemos crear un archivo :file:`~/.config/provider.json` con este
contenido:

.. literalinclude:: files/provider.json
   :language: json
   :emphasize-lines: 3-5

y permisos restringidos de lectura::

   $ chmod 600 ~/.config/provider.json

donde :kbd:`client_id` y :kbd:`client_secret` son las credenciales que hemos
obtenido en el paso anterior. Creado el archivo, podemos obtener el token
necesario ejecutando::

   $ getmail-gmail-xoauth-tokens -i ~/.config/provider.json

que añadirá al archivo los campos :kbd:`access_token` y :kbd:`refresh_token`\ [#]_. 
Hecho lo cual, podemos autenticarnos creando una sección :kbd:`[retriever]` en
el archivo de configuración (el resto de puede quedarse tal como :ref:`se expuso
anteriormente <getmail>`):

.. literalinclude:: files/getmailrc-oauth2
   :language: ini

.. seealso:: `Este artículo
   <https://www3.isi.edu/~johnh/OTHER/LINUX/OAUTH2/index.html>`_ documenta el
   soporte de OAuth2 en :program:`getmail`.

.. https://luxing.im/mutt-integration-with-gmail-using-oauth/
.. https://wiki.archlinux.org/title/Getmail

.. rubric:: Notas al pie

.. [#] Su usamos |GPG| para cifrar y firmar correos electrónicos lo más
   apropiado es utilizar la propia dirección de correo.
.. [#] En realidad, se obtienen dos *tokens*: uno de acceso (*access_token*)
   que tiene una caducidad limitada y uno de refresco (*refresh_token*) sin
   caducidad y que sirve para actualizar al anterior tras cada uso. En
   consecuencia, si se usan periódicamente, no habrá que regenerarlos manualmente;
   pero en caso contrario, habrá que volver a ejecutar la :ref:`orden para
   obtenerlos manualmente <gen_token_oauth2_mutt>`. Tenga presente que en el
   caso de un |MRA| lo habitual es revisar el correo a intervalos regulares de
   tiempo, pero en el de *mutt* puede no darse esta periodicidad (aunque podemos
   incluir en una tarea de *cron* la orden de testeo para remediarlo).
.. [#] :file:`provider.json` queda sin cifrar y, por tanto, lo que hace
   :program:`getmail` a efectos de seguridad equivale a la primera variante que
   :ref:`propusimos para mutt <mutt-oauth2>`.


.. _Thunderbird: https://thunderbird.net

.. |API| replace:: :abbr:`API (Application Programming Interface)`
.. |GPG| replace:: :abbr:`GPG (GNU Privacy Guard)`
.. |URL| replace:: :abbr:`URL (Uniform Resource Locator)`
