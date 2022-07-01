.. _oauth2-gmail:

Uso de cuentas de Gmail
***********************
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

:program:`mutt`
---------------
:program:`mutt` requiere la autenticación tanto para el envío de mensajes a
través del servidor |smtp| como para el acceso |imap| interactivo. para
llevarlo a cabo, el paquete :deb:`mutt` provee un *script* escrito en
:program:`python`: :file:`/usr/share/doc/mutt/examples/mutt_oauth2.py`.
asi que empezaremos por copiar este *script* en un lugar adecuado::

   $ mkdir -p .config/mutt
   $ install -m750 /usr/share/doc/mutt/examples/mutt_oauth2.py ~/.config/mutt/

Este *script* nos permitirá obtener un token de acceso que se almacena en una
base de datos gestionada por :ref:`GNUpg <gnupg>`, por lo que necesitaremos
también este *software*. Como en *Debian* es una dependencia del propio
:program:`mutt` no será necesaria ninguna instalación adicional.

Lo que sí debemos hacer es crearlo::

   $ gpg --gen-key

La orden nos pedirá un nombre (podemos usar "Mutt OAuth2", por ejemplo) y una
dirección de correo, que puede ser la dirección de correo de la que estamos
generando la autenticación (p.e. :kbd:`pericodelospalotes@gmail.com`), aunque no
necesariamente. Finalmente deberemos asegurarlo todo con una contraseña, que
deberemos recordar, porque será la que se nos pregunte cada vez que queramos
tener acceso al token.

.. note:: Para que :program:`gpg-agent` sepa por donde pedir la contraseña
   podría ser necesario definir una variable de ambiente persistente:

   .. code-block:: bash

      export GPG_TTY=$(tty)

Generada la clave, debemos editar :file:`~/.config/mutt/mutt_oauth2.py` para:

- En la definición de :kbd:`ENCRYPTION_PIPE` añadir la dirección a la que
  asociamos la clave recién creada.
- Añadir las credenciales :kbd:`client_id` y :kbd:`client_secret` obtenidas
  bajo el epígrafe anterior.

Una vez hecho, podemos obtener el *token* ejecutando la orden::

   $ ~/.config/mutt/mutt_oauth2.py -va --authflow authcode ~/.config/mutt/pericodelospalotes@gmail.com

Esta orden generará una |URL| que habrá que copiar en el navegador y a resultas
de la cual, se generará un código que debemos facilitar al *script* para que
cree el archivo cifrado.

.. note:: La dirección no debe ser necesariamente la dirección de correo
   (podríamos haber usando otra falsa como :kbd:`pericodelospalotes@gmail.com.token`).
   La dirección real debe usarse en la configuración del propio :program:`mutt`
   (véase a continuación) y en la dirección de correo que interactivamente nos
   pregunta la ejecución de :command:`mutt_oauth2.py`

Con esto ya podemos configurar :program:`mutt`, pero antes probemos que el *token* funciona::

   $ ~/.config/mutt/mutt_oauth2.py -vt ~/.config/mutt/pericodelospalotes@gmail.com
   Access token: xxx
   IMAP authentication succeeded
   POP authentication succeeded
   SMTP authentication succeeded

Finalmente, para configurar |SMTP| e |IMAP| la configuración necesaria es la siguiente:

.. code-block:: bash

   set smtp_url = "smtp://pericodelospalotes@gmail.com@smtp.gmail.com:587/"
   set smtp_authenticators = "oauthbearer:xoauth2"
   set smtp_oauth_refresh_command = "~/.config/mutt/mutt_oauth2.py ~/.config/mutt/pericodelospalotes@gmail.com"

   set imap_user="pericodelospalotes@gmail.com"
   set folder = "imap://imap.gmail.com"
   set imap_authenticators=$smtp_authenticators 
   set imap_oauth_refresh_command=$smtp_oauth_refresh_command

.. _getmail-oauth2:

:program:`getmail`
------------------
Debemos crear un archivo :file:`~/.config/provider.json` con este
contenido:

.. literalinclude:: files/provider.json
   :language: json
   :emphasize-lines: 3-5

donde :kbd:`client_id` y :kbd:`client_secret` son las credenciales que hemos
obtenido en el paso anterior. Creado el archivo, podemos obtener el token
necesario ejecutando::

   $ getmail-gmail-xoauth-tokens -i ~/.config/provider.json

que añadirá al archivo los campos :kbd:`access_token` y :kbd:`refresh_token`.
Hecho lo cual, podemos autenticarnos creando una sección :kbd:`[retriever]` en
el archivo de configuración (el resto de puede quedarse tal como :ref:`se expuso
anteriormente <getmail>`):

.. literalinclude:: files/getmailrc-oauth2
   :language: ini

.. note:: El *token* tiene una caducidad por lo que cada 90 días habrá que
   volver a renegerarlos con la orden anterior.

.. seealso:: `Este artículo
   <https://www3.isi.edu/~johnh/OTHER/LINUX/OAUTH2/index.html>`_ documenta el
   soporte de OAuth2 en :program:`getmail`.

.. https://luxing.im/mutt-integration-with-gmail-using-oauth/
.. https://wiki.archlinux.org/title/Getmail



.. _Thunderbird: https://thunderbird.net

.. |API| replace:: :abbr:`API (Application Programming Interface)`
.. |GPG| replace:: :abbr:`GPG (GNU Privacy Guard)`
.. |URL| replace:: :abbr:`URL (Uniform Resource Locator)`
