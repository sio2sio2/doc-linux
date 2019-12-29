.. _remove-data:

Eliminación de datos
====================
La eliminación de datos es fundamental si es nuestra deshacernos del dispositivo
físico sobre el que los escribíamos. Hay tres opciones:

- **Cifrar los datos**, lo cual nos ahorra el problema de tener que eliminarlos.

- **Destruir físicamente el disco**, a fin de que quede inservible y sus datos sean
  absolutamente ilegible. A este respecto, es muy intersante `este artículo de
  xataka
  <https://www.xataka.com/especiales/como-destruir-un-disco-duro-definitivamente-para-que-no-se-pueda-recuperar-la-informacion>`_.

- Pero si nuestra intención es reaprovechar los discos o donarlos, entonce es
  necesario usar **técnicas de borrado efectivo** de los datos. Un vistazo a
  herramientas generales se encuentra en `este artículo de genbeta
  <https://www.genbeta.com/herramientas/siete-herramientas-gratis-para-borrar-de-forma-segura-tus-discos-duros-hdd-o-ssd>`_,
  pero dado el propósito de estos apuntes, nos centraremos en herramientas para
  *Linux*.

Antes de empezar es preciso distinguir entre el borrado de discos |SSD| y el
borrado de discos magnéticos. Dado que las técnicas se basan en hacer muchas
sobrescrituras para asegurarse de que el dato original haya desaparecido...

.. warning:: ... no utlice estas herramientas en discos |SSD|. Para ellos
   cada fabricante debería facilitar herramientas específicas.

.. _shred:
.. index:: shred

:command:`shred`
   Es una orden básica incluida en las *coreutils*, que permite borrar ficheros
   de manera segura, esto es, asegurándose de que el fichero no puede
   recuperarse. En realidad, se limita a hacer tres pasadas escribiendo datos
   aleatorios y una cuarta opcional para rellenar finalmente con ceros.
   Si suponemos que tenemos un fichero llamado "datos_secretos.txt", podremos
   borrarlo del siguiente modo::

      # shred -uvz datos_secretos.txt

   donde la opción :kbd:`-u` elimina el fichero tras borrar su contenido,
   :kbd:`-v` nos ofrece información de cada pasada y :kbd:`-z` hace una pasada
   adicional rellenando con ceros. Además, podemos hacer más de tres
   pasadas, utilizando la opción :kbd:`-n`. Sin embargo, hay varios problemas:
   
   - No hay opción para borrado recursivo, por tanto, si queremos borrar todo el
     contenido de un directorio que incluye subdirectorios, tendremos que
     recurrir al uso de :ref:`find <find>` para generar la lista de archivos.
   - Si leemos la documentación, el borrado en los sistemas de ficheros con
     *journaling* o sistemas |RAID| puede ser no todo lo efectivo que
     quiséramos.

   Un uso alternativo de :command:`shred` es el de borrar dispositivos enteros,
   lo cual evita este último inconveniente y, además, es útil si nuestra
   intención es borrar toda la información. Así, si quisiéramos borrar todo lo
   que contiene el dispositivo :file:`/dev/sdz`, podríamos arrancar desmontar
   todo sistema de ficheros asociado a particiones de este dispositivo (si se
   encuentra en él el sistema raíz, podrías arrancar el *linux* de un dispositivo
   extraíble) y hacer::

      # shred -vz /dev/sdz

   donde en este caso, no tiene sentido usar la opción :kbd:`-u`.

.. _secure-delete:
.. _srm:
.. _sfill:
.. _sswap:
.. _sdmem:

**secure-delete**
   Es una *suite* con unas cuantas herramientas especialidas en el borrado de
   información:

   - :command:`srm`, que borra ficheros.
   - :command:`sfill`, que borra el espacio libre.
   - :command:`sswap`, que borra la memoria de intercambio.
   - :command:`sdmem`, que borrar la memoria |RAM|.

   La instalación es trivial::

      # apt install secure-delete

   El borrado estándar que lleva a cabo hace cerca de 40 pasadas y puede acabar
   con una pasada adicional que rellena con ceros. Borrar un fichero se hace
   así::

      $ srm -vz datos_secretos.txt

   A diferencia de :ref:`shred <shred>`, sí tiene una opción :kbd:`-r` para
   borrado recursivo.

   Por su parte, borrar el espacio libre de un sistema de ficheros, se nace
   utilizando :command:`sfill` sobre el punto de montaje. Por ejemplo::

      # sfill -vz /home

   Si se usa con la opción :kbd:`-l` sólo hará dos pasadas con número aleatorios
   y si se duplica la opción :kbd:`-ll` solamente una.

.. seealso:: Hay un excelente `artículo sobre herramientas de borrado en
   howtogeek
   <https://www.howtogeek.com/425232/how-to-securely-delete-files-on-linux/>`_.


.. |SSD| replace:: :abbr:`SSD (Solid-State Drive)`
.. |RAM| replace:: :abbr:`RAM (Random Access Memory)`
