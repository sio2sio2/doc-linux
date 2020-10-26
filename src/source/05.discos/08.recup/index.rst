.. _rec-filesystem:

Recuperación de datos
*********************
Divideros este epígrafe sobre recuperación de datos en tres partes:

* La recuperación de particiones.
* La recuperación de archivos borrados accidentalmente.
* La recuperación de sistemas de archivos.

.. note:: Los dos últimos apartados los centraremos en ext4.

Particiones
===========
.. todo:: Tratar de la recuperación de particiones con testdisk.

Archivos borrados
=================
.. todo:: Recuperar fichero borrados accidentalmente (extundelete, ext4magic,
   ext3grep)

Sistemas de archivos
====================
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

Bloques dañados
---------------
En este caso deberemos proceder a una reparación manual, aunque se puede perder
información en la operación::

   # es2fsck -y /dev/sdz5

En esta orden, :kbd:`-y` asume que diremos siempre que sí a cualquier sugerencia
de corrección que se nos plantee. Tras la reparación es posible que en el
directorio :file:`lost+found` aparezca archivos recuperados por la operación.

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
