Recuperacion del sistema de archivos
************************************

.. note:: Centraremos las explicaciones en ext4.

Hay diversas circunstancias por las que un sistema de archicos puede quedar
dañado:

- Cierre sucio del sistema (p.e. un corte súbito del suministro eléctrico).
- Daño en algún sector del disco que impida su lectura.

.. index:: e2fsck

.. _e2fsck:

Cuando esto ocurre el sistema queda dañado y es preciso repararlo. Si el
problema se debió al apagado brusco, pero el sistema dispone de *journaling*
(ext3, ext4), entonces es probable que el sistema se recupere detecte el
problema, pero se recupere automática cerrando todo lo pendiente gracias
precisamente al *journaling*. En ext2, que carece de él, esto no sucedía y era
preciso recurrir a la comprobación manual del sistema::

   # e2fsck -py /dev/sda5

suponiendo que :file:`/dev/sda5` sea la partición en la que queremos hacer la
comprobación y corregir errores (:kbd:`-y` asume que diremos siempre que sí a
cualquier sugerencia de corrección que se nos plantee).

Hay, sin embargo, un caso especial en que será imposible hacer una recuperación
(incluso habiendo *journaling*) y es el caso en que el superbloque del sistema
de archivos se haya corrompido. En este caso, el sistema es absoluta inaccesible
y no se puede hacer nada con él. Afortunadamente, al crearse el sistema de
archivos se hacen copias de este superbloque en previsión de que ocurra la
corrupción del superbloque principal y la forma de sortear el problema es
recurrir a una de estas copias.

Lo primero es averiguar dónde están esas copias para lo cual podemos fingir que
damos formato a la partición, pero sin llegar a hacerlo realmente (opción
:kbd:`-n`)::

   # mke2fs -n /dev/sda5
   [...]
   Superblock backups stored on blocks:
   32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208

Tras lo cual, comprobamos y corregimos el sistema con :ref:`e2fsck <e2fsck>`,
pero indicando cuál es la primera copia del superbloque::

   # e2fsck -b 32768 -py /dev/sda5

