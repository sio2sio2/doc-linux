.. _disk-div:

División del disco
******************
Una de las principales tareas en la instalación de un sistema operativo es el
particionado del dispositivo de almacenamiento, especialmente si la intención es
alojar varios sistemas operativos en él. Pero, antes de comenzar, es
indispensable tener presentes algunos conceptos:

.. rubric:: Definiciones

.. _def-particion:

:dfn:`Partición`
   Una *partición* es cada una de las partes lógicas en que se divide una
   unidad de disco. Cada una de estas divisiones lógicas se registra en la zona
   específica del propio disco dedicada a ese efecto, es independiente de cuál
   sea el sistema operativo o los sistemas operativos instalados, y está
   constituida por sectores contiguos. A este listado almacenado en el disco, se
   le denomina :dfn:`tabla de particiones`. Por lo general, los sistemas
   operativos entienden las divisiones y las tratan como si trataran discos
   independientes.

   El particionado está íntimamente ligado con el proceso de arranque, por lo
   que también lo trataremos bajo este epígrafe.

.. _def-disco-virtual:

:dfn:`Disco virtual` (terminología propia)
   Un *disco virtual* es una unidad virtual constituida por una o varias
   unidades físicas, que se comportan como un todo. En los sistemas *Windows*
   recibe el nombre de :dfn:`volumen distribuido` y en *Linux* el de :dfn:`grupo
   de volúmenes`. Otros sistemas operativos que implemente el concepto pueden
   usar otros nombres.

.. _def-particion-virtual:

:dfn:`Partición virtual` (terminología propia)
   Una *partición virtual es cada una de las divisiones en que se parte un
   disco virtual. Por tanto, una *partición virtual* es a un *disco virtual* lo
   que una partición a un *dispotivo físico*. En *Windows* se denominan
   :dfn:`volúmenes` y en *Linux* :dfn:`volúmenes lógicos`.

Hay pues una analogía entre disco físico/partición y disco virtual/partición
virtual, aunque dos son sus diferencias fundamentales:

- El soporte para las versiones virtuales depende del sistema operativo que
  utilicemos. En consecuencia, un disco físico tiene existencia por sí mismo y
  sus divisiones son independientes y se definen de forma que son vistas por
  cualquier sistema operativo, mientras que para definir discos virtuales y
  volúmenes sobre ellos necesitamos las herramientas que nos proporcione un
  sistema operativo y sólo este tipo de sistema operativo será capaz de entender
  tal virtualización.

- Las divisiones virtuales no exigen que el espacio de disco sea contiguo. Por
  tanto, pueden llevarse a cabo una primera división y a posterior ir aumentando
  el tamaño de las partes que nos interese, incluso aunque estas adiciones se
  encuentren en discos físicos distintos.

Bajo el presente artículo estudiaremos:

- Cómo llevar a cabo la creación de particiones sobre un disco físico.
- Cómo es el proceso de arranque de un ordenador.
- En *Linux*, cómo definir grupos de volúmenes y cómo dividirlos en volúmenes
  lógicos.

.. warning:: Para la creación de particiones y volúmenes el texto se centra
   en exponer aplicaciones de terminal que permiten su definición de modo no
   interactivo (:ref:`sgdisk <sgdisk>` y :ref:`sfdisk <sfdisk>`). Dependiendo
   del perfil del lector, quizás sea más propio utilizar herramientas
   interacticas de terminal como :ref:`gdisk <gdisk.i>` y :ref:`fdisk
   <fdisk>`, o gráficas como Gparted_. Por ello, el uso práctico de las
   herramientas no se mezcla con la exposición de conceptos teóricos.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*


.. _Gparted: https://gparted.org/
