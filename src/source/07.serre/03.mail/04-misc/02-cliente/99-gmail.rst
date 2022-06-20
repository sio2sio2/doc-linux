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

mutt
----

.. _getmail-oauth2:

getmail
-------
Debemos crear un archivo :file:`~/.config/provider.json` con este
contenido:

.. code:: json

   {
      "scope": "https://mail.google.com/",
      "user": "xxx-@example.com",
      "client_id": "xxx.apps.googleusercontent.com",
      "client_secret": "xxx-yyy",
      "token_uri": "https://accounts.google.com/o/oauth2/token",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs"
   }

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

El *token* tiene una caducidad por lo que cada 90 días habrá que volver a
renegerarlos con la orden anterior.

.. https://www3.isi.edu/~johnh/OTHER/LINUX/OAUTH2/index.html
   https://wiki.archlinux.org/title/Getmail


.. _Thunderbird: https://thunderbird.net

.. |API| replace:: :abbr:`API (Application Programming Interface)`
