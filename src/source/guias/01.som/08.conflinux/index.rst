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
aun usando la interfaz |CLI|, varíe entre distribuciones. Los principales sistemas de empaquetado son:

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

Este epígrafe debe ser una versión resumida de :ref:`paqueteria` que incluya el
:ref:`paq-vistazo` (cómo se organizan los repositorios) y las :ref:`paq-bas`,
pero utilizando más bien :ref:`apt <apt>`. Las relaciones de ejericicios
asociados a este apartado son:

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

Automatización de tareas
========================
Estudiaremos este aspecto sólo haciendo uso del :ref:`método clásico <cronat>`
con :command:`at` y :program:`crontab`. La relación de ejercicios
correspondiente es ésta:

* :ref:`ej-cronat`

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
