.. _virtual:

Virtualización
**************
La :dfn:`virtualización`, a grandes rasgos, puede definirse como la recreación
mediante hardware y software de la versión virtual de algún recurso informático:
plataforma de hardware, sistema operativo, dispositivo de almacenamiento, red,
etc.

Dependiendo de cuál sea el **objetivo** de la virtualización podemos distinguir
entre:

**Virtualización de aplicaciones**
   Tiene por propósito crear un entorno virtual para las aplicaciones
   independiente de la plataforma real (*hardware* + sistema operativo) sobre
   la que se pretenden ejecutar. Con ello se logra que una misma aplicación sin
   cambios pueda ejecutarse en todas aquellas plataformas para la que se haga
   esta virtualización. Ejemplos de este tipo de virtualización son la |JVM| o
   la |CLR| de la plataforma *.net*.
   
   Para llevarse a cabo esta virtualización las aplicaciones deben estar
   codificadas en un código intermedio llamado *bytecode* y un *software*
   denominado :dfn:`máquina virtual` se encarga de traducir este código al
   código máquina de la plataforma sobre la cual se ejecuta esta máquina
   virtual.

**Virtualización de recursos**
   Consiste en la creación de un recurso virtual *hardware* (memoria,
   almacenamiento, etc.). Por ejemplo, la memoria virtual es un ejemplo de
   virtualización de memoria principal. En el caso de memoria de
   almacenamiento los sistemas |RAID| también encierran una virtualización de
   recursos, ya que el conjunto de discos físicos que lo constituye se
   virtualiza en un recurso virtual que se comporta como si escribiéramos y
   leyéramos sobre un único disco físico.

**Virtualización de plataforma**
   Tiene por propósito la virtualización de un sistema informático, al que se
   denomina :dfn:`máquina virtual`, constituido por un sistema operativo que
   corre sobre un *hardware* virtual y sobre el que se ejecutan aplicaciones.

   Este tipo de virtualización será el que desarrollaremos en el epígrafe.

.. rubric:: Contenidos

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

.. |JVM| replace:: :abbr:`JVM (Java Virtual Machine)`
.. |CLR| replace:: :abbr:`CLR (Common Language Runtime)`
