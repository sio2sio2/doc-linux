.. _virtual:

Virtualización
**************
La :dfn:`virtualización`, a grandes rasgos, puede definirse como la recreación
mediante hardware y software de la versión virtual de algún recurso informático:
plataforma de hardware, sistema operativo, dispositivo de almacenamiento, red,
etc.

Dependiendo de cuál sea el **objetivo** de la virtualización podemos distinguir
entre:

**Virtualización de plataforma**
   Tiene por propósito la virtualización de un sistema informático, al que se
   denomina :dfn:`máquina virtual`, constituido por un sistema operativo que
   corre sobre un *hardware* virtual y sobre el que se ejecutan aplicaciones.

   La introducción a este tipo de virtualización es el objetivo de la primera
   parte de esta unidad.

**Virtualización de aplicaciones**
   Tiene por propósito crear un entorno virtual para las aplicaciones
   independiente de la plataforma real (*hardware*\ + sistema operativo) sobre
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

Virtualización de plataforma
============================
Dado nuestro propósito, centraremos el resto del epígrafe en la virtualización
de plataforma cuyos tipos pueden resumirse en el siguiente esquema:

.. image:: files/virtualizacion.png

Antes de empezar, no obstante, hay que introducir cuatro conceptos:

* :dfn:`Máquina virtual`, que es el sistema informático virtualizado, esto es,
  el conjunto de un sistema operativo y las aplicaciones que corren sobre un
  *hardware* virtual.
* :dfn:`Hipervisor`, que es la plataforma software que controla la
  virtualización de las distintas máquinas virtuales.
* :dfn:`Sistema anfitrión`, que es aquel sobre el que se realiza la virtualización.
* :dfn:`Sistema huésped`, que es aquel que se ejecuta dentro de la máquina virtual.

**Virtualización completa**
   Es aquella en que el *huésped* corre dentro de un sistema totalmente
   virtualizado de manera que no es consciente de que en realidad se ejecuta
   dentro de una virtualización. En consecuencia, la virtualización debe ofrecer
   a este sistema una plataforma *hardware* virtual completamente funcional.

   Dentro de la virtualización completa, podemos hacer dos distinciones. La
   primera hace referencia al **tipo de hipervisor**:

   #. Virtualización **nativa** o hipervisor de **tipo 1**: es aquella en que
      el hipervisor se ejecuta directamente sobre el *hardware*.

      .. image:: files/tipo1.png

   #. Virtualización **alojada** o Hipervisor de **tipo 2**: es aquella en que
      el hipervisor se ejecuta sobre un sistema operativo.

      .. image:: files/tipo2.png

   La nativa es más eficiente que la alojada, ya que el proceso de
   virtualización se ahorra la intermediación del sistema operativo.

   Por otro lado, a partir del año 2005 las `plataformas x86_64
   <https://es.wikipedia.org/wiki/Virtualizaci%C3%B3n_x86>`_\ [#]_ empezaron a
   incluir en sus procesadores instrucciones que ayudan en la virtualización de
   *hardware* de la misma plataforma (**VT-x** en procesadores Intel y **AMD-V**
   en procesadores AMD), a fin de que los sistemas huéspedes pudieran ejecutar
   instrucciones directamente sobre el procesador sin afectar al anfitrión. Esto
   da lugar a otra clasificación:

   #. Virtualización **acelerada por hardware**, que es aquella que permite a
      los sistemas huéspedes ejecutar instrucciones privilegiadas sobre el
      *hardware* real, siempre que este lo soporte. Obviamente, se debe
      virtualizar un *hardware* del mismo tipo.

   #. **Emulación**, que es aquella en que la virtualización del *hardware* se
      realiza toda mediante *software*. Esto es mucho menos eficiente que la
      aceleración por *hardware*.

**Paravirtualización**
   Es aquella en la que no se construye para el huésped un *hardware* virtual,
   ya que este tiene los controladores adecuados para hacer las peticiones
   directamente al anfitrión. Ello requiere modificar el sistema operativo
   cliente para incorporar estos controladores. Evitando la virtualización del
   *hardware* se mejora el rendimiento, pero a costa de no poder usar cualquier
   sistema operativo, sino sólo aquellos que previamente preparados para su
   paravirtualización.

**Paravirtualización híbrida**
   Es una solución a caballo entre las dos anteriores en que se usa
   paravirtualización exclusivamente para algunos aspectos del *hardware* que
   sea especialmente costoso virtualizarlos como operaciones de E/S y uso
   intensivo de memoria, y para el resto se usa virtualización completa del
   *hardware*.

   Un ejemplo de *hardware* paravirtualizado es el `driver virtIO
   <https://www.linux-kvm.org/page/Virtio>`_ para las tarjetas de red, que puede
   ser usado en sistemas de virtualización completas como :ref:`Virtualbox
   <virtualbox>` o :ref:`QEmu <qemu>`.

.. _contenedores:

**Contenedores**
   La virtualización por sistema operativo la llevan a cabo aquellos sistemas
   operativos capaces de crear varios espacios de usuario completamente aislados
   unos de otros. Cada uno de estos espacios de usuario constituye un
   contenedor y es capaz de ver y manejar aquellos recursos hardware que se le
   han asignado.

   En consecuencia, en este tipo de virtualización no existe ni *hardware*
   virtual, ni sistema operativo huésped, sino sólo aplicaciones (de base o de
   usuario) que corren dentro del contenedor.

   La virtualización puede usarse tanto para constituir un pseudo-sistema como
   para ejecutar un único servicio aislado\ [#]_. Es una virtualización muy en
   boga en los últimos tiempos, sobre todo a partir de la irrupción de Docker_.

   Las ventajas fundamentales de este sistema son su rendimiento y su pequeño
   consumo de recurso frente a las soluciones anteriores. Por contra, tiene la
   desventaja de que al no existir un sistema operativo huésped, las aplicaciones
   huéspedes deben ser aplicaciones hechas para el sistema operativo anfitrión, o
   lo que es lo mismo, para docker en Linux sólo podremos aislar aplicaciones
   hechas para Linux.

   .. image:: files/contenedor.png

Software de virtualización
==========================

.. table::
   :class: virtualizacion

   +--------------------+-----------------+-------------+-----------------------+-------------------+-------------+
   |  *Software*        | Tipo            | Aceleración | Anfitrión             | Huésped           | Licencia    |
   |                    |                 |             +-----------+-----------+-----------+-------+             |
   |                    |                 |             | |CPU|     | |SO|      | |CPU|     | |SO|  |             |
   +====================+=================+=============+===========+===========+===========+=======+=============+
   | VMware Workstation | Completa tipo 2 | Sí          | | x86     | | Windows | Anfitrión | \*    | Propietaria |
   |                    |                 |             | | x86_64  | | Linux   |           |       | (freeware)  |
   +--------------------+                 |             |           +-----------+           |       +-------------+
   | Virtualbox         |                 |             |           | | Windows |           |       | |GPL|       |
   |                    |                 |             |           | | Linux   |           |       |             |
   |                    |                 |             |           | | MacOs   |           |       |             |
   |                    |                 |             |           | | FreeBSD |           |       |             |
   +--------------------+                 |             |           +-----------+           |       +-------------+
   | Parallel           |                 |             |           | MacOs     |           |       | Propietaria |
   +--------------------+-----------------+             |           +-----------+           |       +-------------+
   | VMware ESXi        | Completa tipo 1 |             |           | \-        |           |       | Propietaria |
   +--------------------+                 |             +-----------+-----------+           |       +-------------+
   | |KVM|\ [#]_        |                 |             | | x86     | | Linux   |           |       | |GPL|       |
   |                    |                 |             | | x86_64  | | FreeBSD |           |       |             |
   |                    |                 |             | | IA-64   |           |           |       |             |
   |                    |                 |             | | ARM     |           |           |       |             |
   |                    |                 |             | | PowerPC |           |           |       |             |
   +--------------------+                 |             +-----------+-----------+           +       +-------------+
   | Hyper-V            |                 |             | | x86_64  | Windows   |           |       | Propietaria |
   +--------------------+-----------------+-------------+-----------+-----------+-----------+-------+-------------+
   | QEmu               | Completa tipo 2 | No\ [#]_    | | x86     | | Linux   | \*        | \*    | |GPL|       |
   |                    |                 |             | | x86_64  | | FreeBSD |           |       |             |
   |                    |                 |             | | IA-64   | | Windows |           |       |             |
   |                    |                 |             | | ARM     | | MacOs   |           |       |             |
   |                    |                 |             | | PowerPC | | FreeBSD |           |       |             |
   |                    |                 |             | | MIPS    | | OpenBSD |           |       |             |
   |                    |                 |             | | SPARC   | | Solaris |           |       |             |
   +--------------------+-----------------+-------------+-----------+-----------+-----------+-------+-------------+
   | Xen Project\ [#]_  | | Completa      | Sí          | | x86     | Linux     | Anfitrión | \*    | |GPL|       |
   |                    | | Paravirt.     |             | | x86_64  |           |           |       |             |
   |                    | | Paravirt. híb.|             | | PowerPC |           |           |       |             |
   |                    | | Contenedor    |             | | ARM     |           |           |       |             |
   +--------------------+-----------------+-------------+-----------+-----------+-----------+-------+-------------+
   | OpenVZ             | Contenedores    | \-          | | x86     | Linux     | Anfitrión | \-    | |GPL|       |
   |                    |                 |             | | x86_64  |           |           |       |             |
   |                    |                 |             | | IA-64   |           |           |       |             |
   |                    |                 |             | | PowerPC |           |           |       |             |
   |                    |                 |             | | SPARC   |           |           |       |             |
   +--------------------+-----------------+-------------+-----------+-----------+-----------+-------+-------------+
   | Docker             | Contenedores    | \-          | | x86_64  | | Linux   | Anfitrión | \-    | Apache      |
   |                    |                 |             | | ARM     | | Windows |           |       | (tipo |BSD|)|
   |                    |                 |             |           | | MacOs   |           |       |             |
   +--------------------+-----------------+-------------+-----------+-----------+-----------+-------+-------------+

De los referidos estudiaremos:

.. toctree::
   :maxdepth: 1
   :glob:

   [0-9]*


.. rubric:: Notas al pie

.. [#] Más recientemente la incluyó también la plataforma ARM.
.. [#] Entiéndase que en, este caso, :dfn:`aislado` no significa que no pueda
   comunicarse con el exterior, sino que se ejecuta en un espacio de usuario
   independiente.
.. [#] |KVM| es un módulo de *Linux* que usa como interfaz una versión
   modificada de QEmu_.
.. [#] En arquitecturas x85 y x86_64 sí puede habilitarse la aceleración por hardware.
.. [#] Xen ofrece distintas técnicas de virtualización dependiendo de cuál sea el
   sistema operativo huésped.

.. |JVM| replace:: :abbr:`JVM (Java Virtual Machine)`
.. |CLR| replace:: :abbr:`JVM (Common Language Runtime)`
.. |KVM| replace:: :abbr:`KVM (Kernel-baed Virtual Machine)`
.. |CPU| replace:: :abbr:`CPU (Central Processing Unit)`
.. |SO| replace:: :abbr:`SO (Sistema operativo)`
.. |GPL| replace:: :abbr:`GPL (GNU General Public License)`
.. |BSD| replace:: :abbr:`BSD (Berkeley Software Distribution)`

.. _Docker: https://www.docker.com/
.. _QEmu: https://www.qemu.org/
