Correo electrónico
==================
El correo electrónico es un servicio que permite el intercambio de mensajes
electrónicos entre ordenadores y sus orígenes datan de los inicios de internet
(y aun antes). Actualmente, aunque sean más, se basa fundamentalmente en el uso
de dos protocolos dístintos

#. Un protocolo para el intercambio de mensajes entre ordenadores, el protocolo
   |SMTP|.
#. Como por lo general el usuario no tiene acceso físico al servidor, un
   *protocolo de buzón* que permite al usuario acceder a los mensajes que quedan
   almacenados en el servidor destinatario en el que se tiene cuenta de correo.
   Los protocolos más habituales para esta operación son |POP3| e |IMAP|.

Un aspecto importante del correo es el formato con el que se definen las
cuentas::

   cuenta@dominio

en que se puede distinguir, un nombre de la cuenta, el caracter separador
:kbd:`@` y el dominio al que está asociado el servidor. Obsérvese, porque es muy
importante, que las cuenta está asociada a un dominio y no a una máquina
concreta. Esto distingue el servicio de otros en los que, cuando se hace una
conexión, se expresa exactamente cuál es la máquina en la que se encuentra el
servidor. Por ejemplo, el protocolo |HTTP|::

   http://www.google.es

Cuando se escribe en la barra de direcciones del navegador esto, se pide la
conexión con la máquina *www.google.es*. Por ese motivo, en las conexiones
|HTTP| puede prescindirse de los nombres y usar directamente la dirección |IP|.
En cambio, cuando un cliente de correo envía un mensaje a la cuenta
:code:`paco@hotmail.com``, no se especifica cuál es el servidor de correo en el
que hay que dejar el mensaje, sólo el dominio. Eso exige que exista un registro
*MX* para la zona |DNS| que define el dominio  que identifique cuál es la
máquina que se encarga del servicio de correo.

.. seealso:: Tenga presente :ref:`las lecciones sobre DNS <dns>`, porque antes
   de comenzar la instalación hay que configurar el |DNS| a fin de definir para
   la red cuál será el servidor de correo.

.. warning:: Los contenidos son bastente prolijos y no pretenden ser una guía
   paso a paso de como configurar por completo un servidor de correo. Presentan
   distintos conceptos y proponen configuraciones, algunas redundantes y otras
   que no tienen por qué llevarse a cabo. Para seguir una instalación ordenada
   recurra a :ref:`nuestra chuleta <smtp-chuleta>`.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*/index

.. todo:: Es necesario investigar sobre:

   * :ref:`Filtros de buzón en el servidor <dovecot-sieve>`.
   * :ref:`rspamd <rspamd>`: puede integrarse como *milter* y suporta, además,
     :ref:`SPF <spf>`, :ref:`DKIM <dkim>` y :ref:`DMARC` con lo que quizás
     pueda sustitutir a todo el *software* descrito en esos apartados. Tiene,
     por lo que parece un módulo para `ARC
     <https://blog.returnpath.com/how-to-explain-authenticated-received-chain-arc-in-plain-english-2/>`_,
     que supera los problemas de DKIM con las listas de distribución.

   * Profundizar en la instalación de :ref:`roundcube <roundcube>` (información
     de la cuota, cambio de contraseña, creación de filtros de buzón).

.. |POP3| replace:: :abbr:`POP3 (Post Office Protocol v3)`
