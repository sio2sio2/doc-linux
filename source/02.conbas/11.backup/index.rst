.. _backup-simple:

Copias de seguridad
===================

No es propósito de este apartado abordar las copìas de seguridad del sistema, lo
cual como propio de la administración del servidor se dejará para más adelante,
sino presentar las herramientas que permiten empaquetar y comprimir ficheros.

No se entrará, pues, en discutir sobre estrategias de copia ni sobre copias
completas o incrementales o diferenciales.

En el mundo *unix* se distingue entre la acción de :dfn:`comprimir`, esto es,
conseguir que mediante ciertos algoritmos un determinado fichero ocupe menos sin
perder información [#]_; y :dfn:`empaquetar`, que consiste en reunir varios
ficheros en uno solo. En el mundo *windows* estas dos tareas suelen realizarse
juntas, de ahí que a partir de varios ficheros podas construir un único archivo
``zip`` comprimido.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

.. rubric:: Notas al pie

.. [#] En realidad, se puede comprimir perdiendo información: es lo que ocurre
   cuando un fichero crudo de audio se convierte a formato *mp3*. Sin embargo, a
   efectos de lo que nosotros tratamos, la compresión se hace siempre sin
   pérdida.
