Virtualización
==============

Aunque la virtualización no entre propiamente dentro del propósito del
documento, es una valiosísima herramienta de estudio para montar servidores de
prueba. Es por ello que se incluyen aquí tres alternativas:

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*/index

Cada alternativa tiene ventajas e inconvenientes:

**VirtualBox**
   Es el **más fácil** de utilizar y tiene versiones para que el
   sistema anfitrión\ [#]_ sea cualquiera de los tres sistemas operativos más
   usados (*windows*, *macosx* o *linux*).

   Si no se tienen conocimientos previos de *linux*, es el más recomendable.

**qemu**
   Obliga a que nuestro anfitrión sea *linux*, pero tiene la ventaja de que es
   más versátil que *virtualbox*. Por contra, es bastante más complicado de
   usar, aunque puede hacerse más llevadero si hace a través de `<virt-manager>`.

   Existe la posibilidad de transformar los discos virtuales de *qemu* al
   formato que usa *virtualbox* y al revés.

**LXC**
   .. No es propiamente un sistema de virtualización, sino un sistema que permite
      aislar grupos de procesos, pero si se aisla una familia de procesos que
      derivan todos del proceso *init*, podemos obtener un resultado bastante
      semejante al de un sistema linux virtualizado. Por tanto, lo que se
      obtiene es un *segundo linux* que comparte núcleo con el linux anfitrión.

   Sólo pérmite *virtualizar* sistemas linux dentro de sistemas *linux*, pero
   proporciona la ventaja de ser una alternativa muchísimo más ligera que las
   las anteriores, e incluso de sólo ocupar aquellos recursos que efectivamente
   está consumiento. Dicho de otro modo, podremos asignarle 1G de memoria RAM al
   contenedor, pero este sólo será el límite máximo de memoria que podrá ocupar.
   Si levantamos un sistema qué sólo consume 64MB, esta será la memoria qeu
   efectivamente ocupe. Consecuentemente podremos ejecutar muchísimos más
   sistemas en paralelo.

   Un gran inconveniente de esta solución es que no es en absoluto trivial
   convertir un sistema virtualizado mediante esta solución en un disco de
   *qemu* o *virtualbox*.

.. Enlaces:
   http://mariotello.mx/blog/instalar-qemukvm-libvirt-y-virt-manager-en-ubuntudebian-aka-virtualizacion/
   https://wiki.deimos.fr/LXC_:_Install_and_configure_the_Linux_Containers#Convert.2FMigrate_a_VM.2FHost_to_a_LXC_container
   https://www.stgraber.org/2012/03/04/booting-an-ubuntu-12-04-virtual-machine-in-an-lxc-container/
   https://www.snikt.net/blog/2014/03/22/convert-kvm-image-to-lxc-container/
   http://blog.seljebu.no/2013/05/10/moveconvert-lxclinux-container-to-virtualboxkvmreal-machine/


.. rubric:: Notas al pie

.. [#] :dfn:`Sistema anfitrión` es aquel que originariamente corre la máquina y
   sobre el que se ejecuta la máquina virtual; mientras que :dfn:`sistema
   huésped` es el que se ejecuta dentro de la máquina virtual.
