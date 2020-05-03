Ejercicios sobre herramientas de texto
--------------------------------------
.. note:: Recuerde que deben usarse expresiones regulares extendidas
   por lo que deberá usar :ref:`grep <grep>` con la opción :kbd:`-E` y
   :ref:`sed <sed>` con la opción :kbd:`-r`. :ref:`awk <awk>` soporta
   este tipo de expresiones de manera predefinida.

.. note:: Las respuestas deben expresar la orden que proporciona el dato
   concreto requerido. Por ejemplo, si se piden los servidores |DNS|,
   no vale con mostrar el contenido del archivo donde están escritos (o
   sea, hacer un simple :ref:`cat <cat>`), sino que es necesario utilizar
   las herramientas de manipulación sobre el fichero para obtener
   exclusivamente la lista de direcciones. Por ejemplo:

   .. code-block:: none

      1.1.1.1
      1.0.0.1

#. Obtenga los usuarios cuyo nombre empieza por "u":

   a. Sólo los usuarios locales y vale con obtener la línea que
      define el usuario y no únicamente su nombre.

   #. Lo mismo, pero todos los usuarios sean locales o remotos.

   #. Como antes, pero ahora sí que hay que obtener los nombres y
      no toda la línea

#. Devolver en mayúsculas los nombres de todos los usuarios.

#. ¿Cuántos son los usuarios anteriores?

#. Obtenga una lista de usuarios ordenados alfabéticamente.

#. ¿Cuántos usuarios utilizan como *shell* :file:`/bin/hash`?

#. Cuando se modifica :file:`/etc/passwd`, antes de llevar a cabo el cambio, el
   sistema crea una copia del archivo llamada :file:`/etc/passwd-`. Muestre
   cuáles son los últimos cambios que llevó a cabo el sistema.

#. Muestre el contenido del fichero de configuración del servidor |SSH|
   (averigue cuál es) eliminando las líneas de comentario

   .. note:: En este fichero, las líneas de comentario son las que empiezan
      por el carácter comodín (:kbd:`#`).

#. ¿Cuántas particiones tiene definidas el disco *sda*? No utilice :ref:`fdisk
   <fdisk>` o herramientas similares de manipulación de discos.

#. ¿Cuántas ejecutables propios del administrador hay disponibles en el sistema?

#. ¿Cuántos ejecutables de los anteriores tienen cuatro letras?

#. Muestre los grupos a los que pertenece algún usuario, pero excluyendo el
   grupo principal.

#. Cuénte los directorios y subdirectorios que contiene su espacio personal.

#. Mostrar la lista de integrantes de cada grupo que no tienen
   al propio grupo como grupo principal. La lista debe tener
   la forma:

   .. code-block:: none

      sudo = usuario1 usuario2
      admin = usuario2 usuario5 usuario3

#. Mostrar los nombres de usuario y su |UID| del siguiente modo:

   .. code-block:: none

      root=0
      daemon=1
      bin=2
      etc.

   .. note:: Puede usar tanto :command:`cut` como :command:`awk`.

#. Muestre exclusivamente las direcciones |IP| de los servidores |DNS| que usa
   el sistema.

#. ¿Cuál es el puerto típico del servicio IMAP (versión 2)?
   
   .. note:: Échele un vistado a :file:`/etc/services`.

.. |UID| replace:: :abbr:`UID (User IDentifier)`
