Linux como cliente
==================
El epígrafe no esta dedicado propiamente al papel de linux como servidor de
correo, sino como una máquina en la que uno o varios usuarios consultan sus
mensajes. Este papel, por tanto, es más propio de una máquina de escritorio que
de una máquina servidor, pero por su relación con el asunto y porque intervienen
en él :ref:`los agentes ya citados <agentes-correo>`, es conveniente
desarrollarlo.

Dato que cliente y servidor se hayan en lugares distantes, es necesaria un
*envío de correo* y una *recepción de correo*. Partimos de lo siguiente:

* El usuario tiene cuenta en uno o varios servidores de correo remotos
  (*gmail.com*, *hotmail.com*, etc).

* Suele existir, a pesar de todo, un servidor de correo (|MTA|) para entrega
  local, ya que muchas aplicaciones lo usan para enviar avisos al administrador
  (:command:`apt`, :program:`cron`, etc.).

El  **envío** es, más o menos, como sigue:

* Algunos |MUA| tienen incorporado un cliente |SMTP| (o sea, un |MSA|)
  con lo que pueden comunicarse directamente con el servidor de correo y hacer el envío.

* Los clientes que no tiene esta posibilidad, o bien usan un |MSA| externo
  (por ejemplo, :ref:`msmtp <msmtp>`) o bien, si existe, usan el |MTA| local
  convenientemente configurado para enviar correo a otro servidor.

La **recepción** es algo más compleja y puede describirse así:

* El usuario requiere rescatar de los servidores de correo remotos sus mensajes,
  gracias a que el |MAA| los hace accesibles, para lo cual puede optar por dos
  soluciones:
  
  #. Consultar directamente los mensajes (en especial, si el protocolo es |IMAP|).
  #. Descargar los mensajes con un |MRA| como :ref:`fetchmail <fetchmail>`.

* Si opta por la segunda opción, tras la descarga debe usarse un |MDA| para
  poder entregarse en buzones locales el correo descargado. La aplicación de
  descarga puede optar por entregar los correos al |MTA|, si existe,
  informándole de cuál es el usuario destinatario para que éste, a su vez, use
  un |MDA| externo o el suyo propio; o bien, puede entregarlo directamente a un
  |MDA| como :program:`procmail` o :program:`maildrop`.
  
* El último eslabon de la cadena es el |MUA|, el cliente de correo, que permite
  leer de forma cómoda los mensajes de los buzones locales, o de los buzones
  remotos si se optó por no descargarlos en un paso anterior. El cliente de
  correo en consola por antonomasia es `mutt <http://www.mutt.org/>`_.

.. image:: files/cliente-recepción.png

.. note:: Cuando el |MUA|, esto es, *el cliente de correo es gráfico*, lo
   habitual es que éste incorpore un |MRA| y descargue directamente el correo;
   permita establecer filtros para repartir el correo en distintos buzones
   (asumiento también el papel del |MDA|); y disponga de las funciones de |MSA|.
   Por tanto, todas las labores requeridas en el cliente las puede realizar él y
   no es necesario otro *software*.

Estudiemos por separado cada uno de los agentes:

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*

.. warning:: Para ilustrar las configuraciones, hemos usado una cuenta de Gmail_.
   Sin embargo, desde junio de 2022 Gmail_ impide la autenticación usando la simple
   contraseña con lo que los ejemplos de configuración que se encuentran en
   algunos de los epígrafes no funcionarán precisamente si se usan cuentas de
   este servidor. El :ref:`último apartado <oauth2-gmail>` ilustra cómo
   autenticar cuentas de Gmail_ en algunas de las aplicaciones usadas en los
   epígrafes anteriores.

.. |POP3| replace:: :abbr:`POP3 (Post Office Protocol v3)`
.. |MTA| replace:: :abbr:`MTA (Mail Transport Agent)`
.. |MUA| replace:: :abbr:`MUA (Mail User Agent)`
.. |MDA| replace:: :abbr:`MDA (Mail Delivery Agent)`
.. |MAA| replace:: :abbr:`MAA (Mail Access Agent)`
.. |MSA| replace:: :abbr:`MSA (Mail Submission Agent)`
.. |MRA| replace:: :abbr:`MRA (Mail Retrieval Agent)`

.. _Gmail: https://gmail.google.com

