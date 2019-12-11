.. _raid:

|RAID|\ s
*********

Introducción teórica
====================
Un |RAID| puede definirse como un sistemas de almacenamiento que, mediante
técnicas *hardware* o *software*, utiliza de manera conjunta varios discos para
distribuir los datos entre todos ellos con la finalidad de:

- Introducir **redundancia** para hacer el sistema tolerante a fallos, de manera
  que aunque falle algún disco, el sistema pueda seguir accediendo a los datos
  sin interrupciones

- Aumentar la **capacidad** de almacenamiento, esto es, constituir una unidad de
  almacenamiento mayor que cada una de los discos físicos por separado.

- Aumentar el **rendimiento** en las lecturas y escrituras.

Dependiendo de cuál sea el |RAID| que se implemente se lograran alcanzar uno o
más de estos propósitos; y el resultado de su implementación será la creación de
un dispositivo virtual sobre el que el sistema operativo podra crear particiones
y sistemas de archivos.

.. rubric:: Tipos de |RAID|\ s

Hay diversos tipos o niveles de |RAID|\ s, para cuyas descripciones llamaremos
:var:`s` a la capacidad del disco físico más pequeño y :var:`n` al número de
discos que lo conforman:

**RAID 0** (o **Volumen dividido**)
   Se forma con dos o más discos entre los cuales se distribuye equitativamente
   la información sin incluir información redudante.

   .. image:: files/RAID0.png

   Es conveniente, como en el resto de tipos, que los discos sean de la misma
   capacidad, ya que sólo es aprovechable cada disco hasta la capacidad del más
   pequeño. En lo referente a los propósitos de |RAID|:

   - El sistema no es tolerante a fallos, puesto que no existe redundancia. En
     consecuencia, no puede romperse ningún disco. Y es más, cuanto mayor sea el
     número de discos, menos fiabilidad tendrá el sistema, ya que aumenta la
     probabilidad de que uno de ellos falle y se desbarate toda la información.
   - La capacidad del conjunto es :math:`c*s`.
   - Mejora el rendimiento tanto en la lectura como en la escritura, ya que se
     puede leer y escribir simultáneamente en los discos.

**RAID 1** (o **Espejo**)
   Se forma con dos o más discos de modo que lo que se escribe en uno se
   replica en todos los demás.

   .. image:: files/RAID1.png

   En este caso, el conjunto es altamente redundante tanto más cuantos más
   discos haya, a costa de sacrificar capacidad:

   - El sistema es capaz de soportar la ruptura de :math:`n-1` discos sin que se
     produzca pérdida de información.
   - No aumenta la capacidad del conjunto que seguirá siendo la capacidad
     individual de uno de los discos, :math:`s`.
   - Aumenta el rendimiento de las lecturas, ya que pueden realizarse lecturas
     simultáneas, pero no el de escritura.

**RAID 0+1** (o **Espejo de divisiones**):
   Es un sistema híbrido formado con un mínimo de cuatro discos, de manera que
   primero se crean dos dispositivos |RAID| 0 que a su vez se toman para
   constituir un |RAID| 1.

   .. image:: files/RAID0+1.png

   Con esta disposición:

   - Hay tolerancia a fallos, aunque sólo pueden fallar discos de un mismo
     |RAID| 0. Si fallan discos de distinto |RAID| 0, el sistema colapsa.
   - Aumenta la capacidad hasta :math:`\frac{n}{2} * s`.
   - Hay mejora en el redimiento de lecturas y escrituras.

**RAID 1+0** (o **Divisiones en espejo** o **RAID 10**):
   El sistema es parecido al anterior, pero se invierten los niveles: primero se
   hacen dos divisiones cada una de las cuales la constituyen discos en
   |RAID| 1 y con estas dos divisiones se forma un |RAID| 0. Como en el caso
   anterior requieren al menos cuatro discos:

   .. image:: files/RAID1+0.png

   Esta disposición sopone:

   - Gran toleracia a fallos, ya que el sistema falla solamente cuando fallan
     todos los discos de una misma división.
   - Se duplica la capacidad individual: :math:`2*s`.
   - Hay mejora en el rendimiento de las lecturas y las escrituras,

**RAID 5**
   Es un sistema de al menos tres discos fisicos, de manera que la información
   se distribuye en todos ellos, excepto en uno en el que se incluye información
   de paridad, por lo que es posible recuperar la información ante el fallo de
   uno de los discos. La base del cálculo de la paridad es la operación lógica
   *XOR* que se caracteriza porque cuando el número de **1** en los operandos es
   impar el resultado es **1** y, cuando es par, **0**. En consecuencia,
   suponiendo que los operandos sean *bits*, obtenemos la siguiente tabla:

   .. table::
      :class: xor

      ==== ==== ==== =========================
       O1   O2   O2   O1\ |xor|\ O2\ |xor|\ O3
      ==== ==== ==== =========================
      0     0     0   0
      0     0     1   1
      0     1     0   1
      0     1     1   0
      1     0     0   1
      1     0     1   0
      1     1     0   0
      1     1     1   1
      ==== ==== ==== =========================

   en la que podremos darnos cuenta, que tapemos la columna que tapemos, podemos
   deducir sus valores aplicando la operación *XOR* a los valores de las
   columnas aún visibles. En un |RAID| 5 el cálculo de la paridad es más
   complejo, ya que tal cálculo  se hace a nivel de bloques y el bloque de
   paridad se distribuye equitativamente entre todos los discos físicos.

   .. image:: files/RAID5.png

   En este tipo:

   - Es tolerante a fallos en la medida, en que la paridad permite que se pueda
     estropear un único disco.
   - Aumenta la capacidad, ya que la paridad sólo ocupa el equivalente a un
     disco físico. Por tanto, obtendremos una capacidad de :math:`(n-1)*s`.
   - No hay mejora en el rendimiento de las escrituras, y hay una penalización
     en las escrituras, ya que una escritura implica leer datos del resto de
     discos para generar la paridad y escribir ésta.

   Variantes de este nivel son:

   - El |RAID| 4 en que la información de paridad se almacena siempre en el
     mismo disco.
   - El |RAID| 3 en que ocurre lo mismo, pero además, los datos se dividen en
     *bytes* y no en bloques.
   - El |RAID| Z, que es implementado por el sistema de fichero |ZFS| y es
     semejante al |RAID| 5, pero que añade variantes para mejorar el rendimiento
     en las escrituras.

**RAID 6**
   Es parecido a un |RAID| 5, pero genera dos bloques de paridad y no uso sólo.
   Por tanto, el número mínimo de discos para constituirlo es 4. En él, se
   sacrifica la capacidad por el aumento de fiabilidad, ya que pueden fallar
   hasta dos discos:

   - Tolera que fallen hasta dos discos.
   - Aumenta la capacidad, hasta :math:`(n-2)*s`.
   - Presenta los mismos incovenientes de rendimiento que su primo hermano el
     |RAID|\ 5: no mejora las operaciones de lectura y penaliza las de
     escritura.

   .. image:: files/RAID6.png

.. rubric:: Particularidades

Sea cuál sea la implementación y el nivel del |RAID|, hay una serie de
particularidades que comparten todos los sistemas |RAID|:

#. Al constituirlos es necesario que se creen una serie de **estructuras de
   metadatos** a semejanza de lo que ocurre con los sistemas de ficheros.

#. Habilitan algún mecanismo para advertir al administrador de la **rotura de
   disco**, a fin de que este sea diligente en su sustitución. Estos mecanismos
   pueden ser muy variados (pitidos, leds), pero suelen incluir el envío de un
   correo electrónico de aviso.

#. Al reemplazarse un dispositivo defectuoso por uno nuevo, se desencadena un
   **proceso de recuperación** para volver a la situación previa a la rotura.

   .. _hot-spare:

#. Para minimizar el tiempo de sustitución de un disco defectuoso, algunos
   sistemas incorporan un **dispositivo de reserva** (*hot spare*) que se
   encuentra conectado pero inactivo, por lo que no forma parte efectiva del
   |RAID|. En el momento en que se detecta una avería, el disco de reserva se
   incorpora al |RAID| y comienza inmediatamente el *proceso de recuperación*.
   La labor del administrador consistirá en añadir al sistema un nuevo disco de
   reserva.

.. rubric:: Técnicas de implementación

Hay tres estrategias para la implementación de un sistema |RAID|:

Mediante **controladora hardware**
   Por lo general, a una tarjeta de expansión que hace las veces de controladora
   de disco se le conectan los discos físicos que consituirán el |RAID|. En este
   caso, la configuración se establece mediante un firmware particular de la
   propia controladora y se carga con anterioridad al arranque del sistema
   operativo, por lo que para el sistema operativo sólo tiene conocimiento de la
   existencia del dispositivo virtualizado.

   Es la solución más costosa, pero la más eficiente al dedicarse a ella
   *hardware* específico.

Mediante **firmware**
   También denominado :dfn:`RAID híbrido` o :dfn:`fakeRAID`, que es una solución
   barata en la que no hay ninguna controladora específica dedicada a la
   constitución del |RAID|, sino que el chip de la controladora de disco
   incluye *firmware* específico para la definición del |RAID|. Como en el caso
   anterior, la configuración del |RAID| se hace con anterioridad a la carga del
   sistema operativo, por la que éste sólo detecta el dispositivo virtual.

   Aunque aparentemente es una solución similiar, al no existir *hardware*
   expecífico dedicado, su rendimiento es peor y, por lo general, es conveniente
   una solución *software* pura.


Mediante **software**
   esto es, mediante aplicaciones que provee el propio sistema operativo o
   porque sea una característica que soporta el sistema de ficheros. En este
   caso, el sistema operativo verá tanto los dispositivos físicos como el
   dispositivo virtual resultado de haber constituido el |RAID|.

   Los sistemas operativos comunes traen herramientas para la creación de
   |RAID|\ s:

   - *MasOs*, *FreeBSD*, *NetBSD* o *OpenBSD* cada uno con sus respectivas
     herramientas.
   - *Windows* gracias a `Logical Disk Manager
     <https://en.wikipedia.org/wiki/Logical_Disk_Manager>`_ y en las versiones modernas
     de servidor a `Sorage Spaces
     <https://en.wikipedia.org/wiki/Features_new_to_Windows_8#Storage>`_.
   - *Linux* mediante su herramienta :command:`md`, que será a la que dediquemos
     el resto del epígrafe.

   Por su parte, algunos sistemas de ficheros soportan directamente la
   constitución de dispositivos |RAID| como |ZFS| o |BtrFS|.

.. _raid-linux:

|RAID|\ s en *Linux*
====================

Preliminares
------------
Es obvio que para nuestras pruebas necesitaremos los discos físicos que
constituyen el |RAID|. Para evitarlos usaremos ficheros que emulen estos discos
físicos::

   # truncate -s 500M disco1.raw
   # losetup /dev/loop0 disco1.raw
   # truncate -s 500M disco2.raw
   # losetup /dev/loop1 disco1.raw

De modo que nuestros dispositivos físicos serán :file:`/dev/loop0` y
:file:`/dev/loop1` en vez de :file:`sda`, :file:`sdb`, etc.

.. warning:: Tenga presente que está manipulando directamente dispositivos de
   disco, por lo que si confunde las unidades y realiza la operación sobre el
   disco que contiene su sistema operativo, lo perderá todo. La guía utiliza
   :file:`/dev/loop0` y :file:`/dev/loop1` entre otras cosas para evitar que un
   *corta y pega* irreflexivo, provoque una catástrofe en su sistema.

No obstante, los preparativos no acaban aquí. En el |RAID| no debemos incluir
dispositivos físicos, sino particiones, así que necesitamos particionar los
discos. Si pretendemos que nuestro disco contenga el sistema operativo y sea
arrancable, entonces tendremos que dejar el arranque fuera del |RAID|.
Suponiendo que utilicemos particionado |GPT| y el disco sea compatible con
arranques |BIOS| y |UEFI|\ [#]_::

   # sgdisk -a 8 -n "0:40:2047" -t "0:0xef02" -c "0:BOOTBIOS" \
            -a 2048 -n "0:2048:+50M" -t "0:0xef00" -c "0:EFI" \
                    -N 0 -c "3:RAID" -t "3:0xfd00" /dev/loop0

o bien::

   # sgdisk -a 8 -n "0:40:2047" -t "0:0xef02" -c "0:BOOTBIOS" \
            -a 2048 -n "0:2048:+50M" -t "0:0xef00" -c "0:EFI" \
                    -N 0 -c "3:LVM" -t "3:0x8e00" /dev/loop0

donde ambas tablas tienes dos particiones de arranque y una última partición
para sistemas y datos en la que sólo cambia el etiquetado y tipo dependiendo de
cuál se la implementación de linux (:ref:`mdadm <mdadm>` o :ref:`lvm <lvmraid>`)
que pretendeamos usar.

.. warning:: Lo conveniente es que los discos sean del mismo tamaño. Es común,
   sin embargo, que si los discos son de diferente fabricante no contengan
   exactamente el mismo número de sectores. Asegúrese de hacer esta operación
   sobre el disco con menos sectores.

Podemos llevar a cabo la misma operación sobre :file:`/dev/loop1`, pero es
más cómodo y más conveniente, simplemente, copiar la tabla de particiones en el
otro disco::

   # sgdisk -R /dev/loop1 /dev/loop0
   # sgdisk -G /dev/loop1

Hecho lo cual, ya podemos exponer las particiones de ambos discos::

   # partx -a /dev/loop0
   # partx -a /dev/loop1

Implementaciones
----------------
El núcleo de linux dispone de un driver llamado |MD| para el soporte de
volúmenes |RAID|. Como herramientas de usuario para la creación y gestión de
estos dispositivos hay dos posibilidades:

* :ref:`mdadm <mdadm>`, que es una herramienta exclusiva para la creación de
  estos dispositivos y que nos permite un control más preciso sobre lo que
  nyestra configuración.
* :ref:`lvm <lvm>` que, desde su versión 2, permite la definición de volúmenes
  lógicos que sean a su vez dispositivos |RAID|, para lo cual el grupo de
  volúmenes deberá haberse construido sobre dos o mas volúmenes físicos,
  obviamente.

Estudiaremos ambas posibilidades.

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*

.. rubric:: Notas al pie

.. [#] Véase la discusión sobre :ref:`particionado GPT para UEFI <part-gpt-uefi>`.

.. |RAID| replace:: :abbr:`RAID (Redundant Array of Independent Disks)`
.. |BIOS| replace:: :abbr:`BIOS (Basic I/O System)`
.. |UEFI| replace:: :abbr:`UEFI (Unified Extensible Firmware Interface)`
.. |GPT| replace:: :abbr:`GPT (GUID Partition Table)`
.. |ZFS| replace:: :abbr:`ZFS (Zettavyte File System)`
.. |BtrFS| replace:: :abbr:`BtrFS (B-TRee File System)`
.. |MD| replace:: :abbr:`MD (Multiple Devices)`

.. |xor| unicode:: U+2295 .. CIRCLED PLUS
