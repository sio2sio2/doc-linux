.. _smtp:

Servidor |SMTP|
***************
Ya se ha indicado que el protocolo |SMTP| es el dedicado al intercambio de
mensajes entre los servidores de correo. Para ello suelen dejarse escuchando en
el puerto **25/TCP**.

Aunque el servidor tradicional y más extendido de correo es `sendmail
<http://sendmail.org>`_, bajo el epígrafe trataremos la configuración de
`postfix <http://www.postfix.org/>`_. De hecho, los servidores de correo (el
propio :command:`postfix`, :command:`exim4`, :command:`qmail`) suelen tener un
ejecutable llamado :command:`sendmail` que emula las funcionalidades del
ejecutable original y usa las mismas opciones.

Antes de planear la instalacion de :program:`postfix`, es importante considerar
si se instalará también un servidor |IMAP| y si éste será :ref:`dovecot
<dovecot>`. La razón de ello es que :program:`dovecot` nos brinda algunas
posibilidades , al margen del estricto protocolo |IMAP|, que pueden ayudar en el
funcionamiento de :program:`postfix`:

* :program:`postfix` no implementa ningún sistema de autenticación y se limita
  a brindar la posibilidad de usar un servicio |SASL|. :program:`dovecot`, en
  cambio, si implementa distintos mecanismos de autenticación y, además, es
  capaz de levantar un servicio |SASL| para que lo use :program:`postfix`.

* Aunque :program:`postfix` tiene integrado un |MDA| para la entrega de correo
  en los buzones de usuario, podemos ceder esta función a :program:`dovecot`

.. note:: En este fichero, desarrollaremos cómo preparar :program:`postfix`
   para que no requiera :program:`dovecot` en ninguna tarea, y enlazaremos a
   la alternativa con :program:`dovecot` que se desarrolla en la parte dedicada
   a |IMAP|.

Para las pruebas tomaremos dos máquinas virtuales, cada una de las cuales
gestionará el correo de un dominio diferente. La primera se encargará de
gestionar el correo del dominio de *mail1.org* y la segunda el dominio
*mail2.org*. En las explicaciones, no obstante, nos centraremos en la
explicación de la configuración del correo de un sólo dominio, *mail1.org*, ya
que explicar ambos sería duplicar las explicaciones.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

.. |MDA| replace:: :abbr:`MDA (Mail Delivery Agent)`
.. |SASL| replace:: :abbr:`SASL (Simple Authentication and Security Layer)`
