.. _roundcube:

Servicio de webmail
===================
Si disponemos también un :ref:`servidor web <n-ginx>`, es bastante sencillo habilitar una
interfaz web que permita la consulta y envío de correo a nuestros usuarios.

Partiremos de la siguiente base:

* Hemos montado en el mismo servidor de correo un *servidor
  web* :program:`nginx` que es capaz de generar contenido dinámico con |PHP|
  apoyándose en *MySQL*.
* Hemos reservado el nombre ``correo.mail1.org`` para el acceso a esta interfaz
  web.
* Instalaremos la `aplicación roundcube <https://roundcube.net/>`_ para ofrecer
  una interfaz de correo amable y atractiva.

Configuración de :program:`roundcube`
-------------------------------------
*debian* ofrece un paquete, así que instalar no es más que\ [#]_::

   # apt-get install roundcube libapache2-mod-php7.0-

La configuración se hace editando el fichero
:file:`/etc/roundcube/config.inc.php` y, para que funcione con nuestra
configuración, basta con asignar valor para estas tres variables::

   $config['default_host'] = 'localhost'
   $config['smtp_server'] = 'localhost'
   $config['mail_domain'] =  '%d'   // Opcional

Las dos primeras variables existen en el fichero, mientras que la última debe
añadirse:

* La primera identifica al servidor |IMAP|.
* La segunda, al servidor |SMTP|.
* La tercera es el dominio de correo. :kbd:`%d` es el dominio que se extrae
  de la dirección web a través de la que se accede a la página. Por tanto,
  ``mail1.org`` en este caso. Esta opción, no obstante, evita sólo que tengamos
  que añadir el nombre de dominio al autenticarnos en la aplicación web.

Configuración de :program:`nginx`
---------------------------------
Para ello basta con incluir un nuevo sitio con :download:`este contenido
<files/webmail>`:

.. literalinclude:: files/webmail
   :language: nginx

Configuración adicional
-----------------------

.. todo:: Tiene interés:

   - Plugin para el cambio de contraseña cuando el usuario es virtual.
   - Creación de filtros de correo.

.. rubric:: Notas al pie

.. [#] :program:`roundcube` necesita un servidor web para funcionar y, si las
   si las dependencias no están satisfechas, prefiere :program:`apache` a
   :program:`nginx`, así que asegurarse de que no instalará :program:`apache`.
   La manera más sencilla es evitar explicitamente que se instale la dependencia
   que desencadena que se instale apache.

.. |PHP| replace:: :abbr:`PHP (PHP Hypertext Preprocessor)`
