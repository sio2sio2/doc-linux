.. _som-conflinux:

Configuración básica de linux (|CLI|)
*************************************

Interfaz |CLI|
==============
Desarrollado en el :ref:`epígrafe sobre entorno de texto <cli>`.

Gestión de *software*
=====================
Una de las funciones principales de las distribuciones de *Linux* es
seleccionar y empaquetar *software* para ofrecer su instalación sencilla al
usuario. De ahí que la gestión de *software* sea uno de los aspectos que,
aun usando la interfaz |CLI|, varíe entre distribuciones. Los principales
sistemas de paquetes son:

- El de Debian_ (y todas sus derivadas como Ubuntu_) basado en la gestión de
  paquetes ``.deb``. Este será el sistema que trataremos en esta guía.
- El de RedHat_ (y derivadas como Fedora_ o CentOs_) basado en paquetes
  ``.rpm`` y que utiliza como herramienta :command:`yum` (orden equivalente a
  :ref:`apt <apt>` en Debian_).
- El de Suse_ basado en paquetes ``.rpm`` que utiliza como herramienta la orden
  :command:`zypper`.
- El de ArchLinux_ basado en la herramienta :command:`pacman`.
- El de Gentoo_, llamado *Portage*, y gestionado a través de la orden
  :command:`emerge`.
- El de Slackware_ basado en las utilidades :program:`pkgtools`.

Hay, además, sistemas de paquetes universales con una filosofía diferente y que
pueden convivir con el sistema de empaquetado de la propia distribuición. Todos
conceptos se tratan en los :ref:`párrafos instroductorios del epígrafe sobre
gestión de software del manual <paqueteria>` y es conveniente tenerlos claros.

Los contenidos apropiados para esta sección, aparte de lo anterior son:

- Las `ramas y secciones de Debian <paquetes-deb>`_, aunque solamente si se usa
  como base la propia *Debian*. Si se usa otra derivada como *Ubuntu*, debería
  adaptarse el epúgrafe\ [#]_.
- Los :ref:`repositorios <deb-repo>`.
- Las :ref:`operaciones básicas <paq-bas>`.

.. note:: Pueden, además, revisarse someramente las herramientas gráficas de
   instalación como :program:`Synaptic` (instalador gráfico de paquetes web) o
   el agregador :program:`Gnome Software`, que aunque se habrán visto
   superficialmente en la unidad anterior al presentar el entorno gráfico, ahora
   pueden contemplarse con más conocimiento de causa.

Las relaciones de ejericicios asociados a este apartado son:

* :ref:`ej-softw`

Configuración de red
====================
Para interfaz de texto puede usarse el epígrafe de :ref:`configuración mínima de
la red <redminima>`.

* :ref:`ej-redmin`

Sistema de archivos
===================
Desarrollado en los epígrafes que componen:

* :ref:`filesystem`
* :ref:`fic-dir`

aunque es conveniente no dar en tanta profundidad :ref:`find <find>`. Para esta
orden basta con limitarse al uso::

   # find /ruta [-type f|l|d] -iname "nombre-con-comodines"

Dentro de este apartado hay dos relaciones de ejercicios pertinentes:

* :ref:`ej-rutas`
* :ref:`ej-fic`

Órdenes avanzadas
=================
El epígrafe está dedicado a como construir órdenes más complejas en la |CLI|.

Concatenación de órdenes
------------------------
En este apartado toca aprender :ref:`cómo concatenar varias órdenes dentro de
una misma línea <sh-concat>` y cuáles son las :ref:`substituciones en línea
<sh-interp-cl>` que hace la *shell* antes de ejecutar de modo efectivo la
orden. Los conocimientos pueden ponerse a prueba con los ejercicios:

* :ref:`Ejercicios sobre expansiones <ej-exp>`.

Redirecciones de |E/S|
----------------------
Respecto al concepto de :ref:`redirección <ioredirect>` basta con centrarse en
el apartado de :ref:`redirección básica <ioredirect-bas>` **sin** antender a los
conceptos de :ref:`tuberías con nombre <mkfifo>` ni :ref:`process substitution
<bash-process-substitution>`. Es importante los conceptos incluidos en este
apartado porque es la herramienta básica para hacer cooperar las órdenes entre
sí y lograr órdenes conjuntas muy poderosas. Entendidas bien estas ideas,
realice los ejercicios:

* :ref:`Ejercicios sobre redirecciones <ej-redirect>`.

.. rubric:: Notas al pie

.. [#] En *Ubuntu*, por ejemplo, las ramas son siempre los nombres de las
   versiones (de hecho se puede hacer en *Debian*, utilizando el nombre *buster*
   en vez de *stable* si es que *Buster* es en ese momento la distribución
   estable) y los componentes son *main*, *universe*, *multiverse* y
   *restricted*.

.. |CLI| replace:: :abbr:`CLI (Command Line Interface)`
.. |E/S| replace:: :abbr:`E/S (Entrada/Salida)`

.. _Debian: https://www.debian.org
.. _RedHat: https://www.redhat.com
.. _Ubuntu: https://www.ubuntu.com
.. _CentOs: https://www.centos.org
.. _Fedora: https://getfedora.org
.. _Suse: https://www.suse.com
.. _ArchLinux: https://archlinux.org
.. _Gentoo: https://gentoo.org
.. _Slackware: http://www.slackware.com
