.. _som-conflinux.2:

Configuración administrativa de *Linux*
***************************************
Esta unidad se reserva para algunos aspectos de configuración muy comúnmente
realizados por el propio administrador del sistema.

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

Recuperación del sistema
========================
En *Linux* puede restaurarse el sistema a un punto anterior mediante el uso de
:ref:`instantáneas de volúmenes lógicos <lvm-snapshots>`. Esto, sin embargo,
excede con mucho el propósito del módulo de conocer cómo se configura a nivel
básico un sistema *Linux*, así que centraremos nuestro estudio en la creación de
copias de seguridad. Por tanto, el epígrafe persigue cónocer cuáles son las
herramientas habituales de compresión y empaquetado, lo cual supone estudiar
todo este epígrafe de :ref:`copias de seguridad <backup-simple>`. La relación de
ejericios es la que se encuentra al final de ese epigrafe:

* :ref:`Ejercicios sobre compresión y empaquetado <ej-compr-paq>`.

Automatización de tareas
========================
Estudiaremos este aspecto sólo haciendo uso del :ref:`método clásico <cronat>`
con :command:`at` y :program:`crontab`. La relación de ejercicios
correspondiente es ésta:

* :ref:`ej-cronat`

.. rubric:: Notas al pie

.. [#] En *Ubuntu*, por ejemplo, las ramas son siempre los nombres de las
   versiones (de hecho se puede hacer en *Debian*, utilizando el nombre *buster*
   en vez de *stable* si es que *Buster* es en ese momento la distribución
   estable) y los componentes son *main*, *universe*, *multiverse* y
   *restricted*.

.. |CLI| replace:: :abbr:`CLI (Command Line Interface)`

.. _Debian: https://www.debian.org
.. _RedHat: https://www.redhat.com
.. _Ubuntu: https://www.ubuntu.com
.. _CentOs: https://www.centos.org
.. _Fedora: https://getfedora.org
.. _Suse: https://www.suse.com
.. _ArchLinux: https://archlinux.org
.. _Gentoo: https://gentoo.org
.. _Slackware: http://www.slackware.com
