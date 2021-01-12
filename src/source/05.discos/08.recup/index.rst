.. _rec-filesystem:

Recuperación de datos
*********************
Divideros este epígrafe sobre recuperación de datos en tres partes:

* La recuperación de particiones.
* La recuperación de sistemas de archivos.
* La recuperación de archivos borrados, por lo general, accidentalmente.

Particiones
===========
Cuando perdemos las particiones accidentalmente, el sistema será incapaz de
acceder a los sistemas de archivos del disco y, en consecuencia, seremos
incapaces de leer los datos. La solución pasa, entonces, por recuperar las
particiones perdidas lo cual depende de cuál fuera el sistema de particiones que
usáramos:

.. _testdisk:

:ref:`Particiones DOS <part-dos>`
---------------------------------
En este caso, el registro de las particiones se encuentra en el |MBR| y, si se
definieron particiones lógicas, se hace más complejo, porque cada partición
lógica se registra en la partición anterior, por lo que la definición del
esquema de particiones se distribuye a lo largo del disco.

Habitualmente, perder la tabla de particiones se debe a haber manipulado el
|MBR| y no hay copia de ella en otro lugar del disco, por lo que el único
mecanismo para recuperarla es utilizar una herramienta que escanee el disco en
busca de las particiones existentes. Una herramienta muy sencilla es
:command:`testdisk`.

.. todo:: Hacer un pequeño vídeo donde se ilustre la recuperación
   de particiones con :command:`testdisk`.

.. note:: :command:`testdisk` también es útil para :ref:`recuperar archivos
   borrados como veremos más adelante <archivos-rec>`.

:ref:`Particiones GPT <part-gpt>`
---------------------------------
El particionado |GPT| funciona de un modo muy diferente. La definición de la
tabla de particiones se concentra al principio del disco a partir del tercer
sector (1KiB) y ocupa habitualmente 16KiB. Además, existe una copia de la tabla
al final del disco, por lo que si accidentalmente se borra la tala inicial, aún
se puede recuperar la copia.

Por lo general:

- Si se pierde la definición del principio de disco, pero no el |MBR| de
  protección, las herramientas serán capaces de recuperar los datos utilizando
  la copia final.

- Si se pierde el |MBR| de protección, basta con regenerarlo para que se
  aplique el caso anterior.

Para la regeneración de la tabla, puiede también utilizarse :program:`testdisk`.

Sistemas de archivos
====================
.. note:: Este apartado lo centraremos en *ext4*.

Hay diversas circunstancias por las que un sistema de archivos puede quedar
dañado y es precisa su reparación:

a. Cierre sucio del sistema (p.e. un corte súbito del suministro eléctrico).
#. Daño en algún sector del disco que impida su lectura.

.. index:: e2fsck

.. _e2fsck:

Si el problema se debió al **apagado brusco**, pero el sistema dispone de
*journaling* (ext3, ext4), entonces es probable que el sistema detecte el
problema, pero se recupere automáticamente completando las operaciones
pendientes gracias precisamente al *journaling*. En ext2, que carece de él, esto
no sucedía y era preciso recurrir a la comprobación manual del sistema::

   # e2fsck -p /dev/sdz5

suponiendo que :file:`/dev/sdz5` sea la partición en la que queremos hacer la
comprobación y corregir errores.

En cambio, cuando el problema se debe al **daño de un sector físico**, ese
supondrá que habremos perdido la información contenida en él y el sistema se
negará a montarse. Hay que distinguir en este caso:

- Que este daño afecte al superbloque.
- Que este daño afecte a otros bloques.

.. _bloques-datos-dañados:

Bloques dañados
---------------
En este caso deberemos proceder a una reparación manual, aunque se puede perder
información en la operación::

   # es2fsck -y /dev/sdz5

En esta orden, :kbd:`-y` asume que diremos siempre que sí a cualquier sugerencia
de corrección que se nos plantee. Tras la reparación es posible que en el
directorio :file:`lost+found` aparezca archivos recuperados por la operación.

.. _superbloque-dañado:

Superbloque dañado
------------------
Cuando el superbloque está dañado, no hay nada que hacer con el sistema de
archivos, ya que éste contiene la información necesaria para poder entender.
Afortunadamente, como esto supone una gran debilidad, al crearse el sistema de
archivos se hacen varias copias del superbloque en previsión de que éste se
dañoe, y la forma de sortear el problema es recurrir a una de estas copias.

Lo primero es averiguar dónde están esas copias para lo cual podemos fingir que
damos formato a la partición, pero sin llegar a hacerlo realmente (opción
:kbd:`-n`)::

   # mke2fs -n /dev/sdz5
   [...]
   Superblock backups stored on blocks:
   32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208

Tras lo cual, comprobamos y corregimos el sistema con :ref:`e2fsck <e2fsck>`,
pero indicando cuál es la primera copia del superbloque::

   # e2fsck -b 32768 /dev/sdz5

.. note:: Este procedimiento funcionará si al crear el sistema de archivos no se
   intrudujo ninguna opción que modificara las opciones predeterminadas con que
   se crea (p.e. el tamaño de bloque).

.. todo:: Probar :kbd:`mke2fs -B 4k /dev/sdz5` para comprobar si se encuentra la
   copia del superbloque introduciendo el tamaño del bloque.

.. _archivos-rec:

Recuperación de archivos
========================
La regla fundamental para ser capaz de recuperar datos borrados es no escribir
(o al menos escribir lo mínimo) en el sistema de archivos del que se quiere
hacer la recuperación. Cuanto más se haya escrito, menos probabilidades hay de
que puedan recuperarse los datos. Esto se debe a que cuando se borra, los
bloques de datos no se sobrescriben inmediatamente, sino que se borra la
referencia al archivo, de manera que los bloques quedan disponibles para ser
ocupados por nueva información. Si esto último, no ha llegado a producirse,
entonces el archivo es recuperable.

Una herramienta interactiva bastante sencilla es el propio :ref:`testdisk
<testdisk>` que puede recuperar ficheros de un sistema de archivos (sin haber
sido montado). Es capaz de recuperar archivos de *EXT4*, pero también de
sistemas *FAT32* o *NTFS*:

.. raw:: html

   <script id="asciicast-ta5Q7TWpmHSmuNfAcU5LuRow3"
   src="https://asciinema.org/a/ta5Q7TWpmHSmuNfAcU5LuRow3.js" async></script>

El vídeo muestra cómo recuperar dos archivos borrados en un sistema *NTFS*. Para
ello, no hay más que marcar aquellos archivos que quieren ser recuperados (con
:kbd:`:` ) de la lista de archivos que :command:`testdisk` reconoce borrados y
escoger en que directorio de otro sistema de archivos quiere almacenarse la
copia. Después podríamos montar el sistema *NTFS* y trasladar a él estas copias.

Si preferimos herramientas no interactivas podemos usar :command:`dosfsck` (con
la opción :kbd:`-u`) o :command:`ntfsundelete` para *FAT* y *NTFS*
respectivamente. Para *EXT4* tenemos varias posibilidades:

.. _extundelete.1:

`extundelete <https://blog.desdelinux.net/extundelete-recupera-archivos-borrados/>`_,
   que tiene el inconveniente de que hay que saber de antemano el nombre del
   directorio o el archivo que se quiere recuperar.

.. _ext3grep.1:

`ext3grep <https://www.tecmint.com/ext3grep-recover-deleted-files-on-ubuntu-debian/>`_,
   que es bastante más versátil que el anterior.

.. _ext4magic:

:command:`ext4magic`
   que será con el que hagamos algunas pruebas en estos apuntes. Para ellas,
   tomemos un archivo y creemos dentro de él un sistema de archivos\ [#]_::

      $ truncate -s 8G /tmp/pruebas.disk
      $ /sbin/mkfs.ext4 -b4k -Eroot_owner="$(id -u):$(id -g)" -L PRUEBAS /tmp/pruebas.disk

   Ahora debemos montar el sistema en el directorio :file:`/mn/josem/PRUEBAS`\ [#]_::

      $ udisksctl loop-setup -f /tmp/pruebas.disk
      Mounted /dev/loop0 at /media/josem/PRUEBAS
      $ udisksctl mount -b /dev/loop0

   Creemos algo de contenido::

      $ mkdir /media/josem/PRUEBAS/{A,B,C}
      $ echo '0123456789' > /media/josem/PRUEBAS/B/numeros.txt
      $ echo 'abcdefghij' > /media/josem/PRUEBAS/B/letras.txt
      $ echo '..........' > /media/josem/PRUEBAS/B/puntos.txt
      $ cp /bin/bash /media/josem/PRUEBAS/C

   Borremos *accidentalmente* algunos archivos::

      $ rm -rf /media/josem/PRUEBAS/{B/puntos,C/bash}

   Pues bien, ahora que hemos descubierto el error debemos proceder
   copiando el *ĵournal* y desmontando el sistema::

      $ /sbin/debugfs -R 'dump <8> /tmp/pruebas.journal' /tmp/pruebas.disk
      $ udisksctl unmount -b /dev/loop0
      $ udisksctl loop-delete -b /dev/loop0     # Esto deshace la asociación entre el fichero y el dispositivo

   No es estrictamente necesario lo primero, pero si copiamos el estado del
   *journal* tendremos más posibilidades de recuperar más datos. Hecho esto,
   puede usarse :command:`ext4magic` para ver cúales son los archivos borrados::

      $ ext4magic /tmp/pruebas.disk -f / -j /tmp/pruebas.journal -l
      Filesystem in use: /tmp/pruebas.disk

      Using external Journal at File /tmp/pruebas.journal
      Inode found ""   2
      Inode 2 is allocated
        100%   B/puntos.txt 
        100%   C/bash 
      ext4magic : EXIT_SUCCESS

   Para recuperar basta con::

      $ ext4magic /tmp/pruebas.disk -f / -j /tmp/pruebas.journal -r
      $ ls RECOVERDIR
      B C

   Si los archivos no son recuperables al 100%, no se recuperarán. En ese caso,
   quizás aún pueda recuperarse con la opción :kbd:`-m`::

      $ ext4magic /tmp/pruebas.disk -j /tmp/pruebas.journal -m

   .. note:: La recuperación no tiene por qué ser siempre producirse.

.. Recuperar con debugfs:
   https://www.cyberciti.biz/tips/linux-ext3-ext4-deleted-files-recovery-howto.html

.. rubric:: Notas al pie

.. [#] Nos aseguramos que el sistema tenga bloques de 4KiB y que el directorio
   raíz pertenezca a nuestro usuario y no a *root*. Según :manpage:`mke2fs(8)`
   el diurectorio raiz debería pertenecer al usuario que crea el sistema de
   archivos, pero tal cosa no parece ocurrir.
.. [#] Por supuesto, podemos esta operación como administrador::

      # mount -o loop /tmp/pruebas.disk /mnt

   pero aprovechamos que tenemos instalado `udisks
   <https://www.freedesktop.org/wiki/Software/udisks/>`_ en el sistema para
   hacer las operaciones como usuario sin privilegios.

.. |MBR| replace:: :abbr:`MBR (Master Boot Record)`
.. |GPT| replace:: :abbr:`GPT (GUID Partition Table)`
