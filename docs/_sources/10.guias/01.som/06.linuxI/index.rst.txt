Uso básico de *Linux*
*********************
Para las unidades dedicadas a *Linux* nos limitaremos a enlazar con las partes
apropiadas del manual y añadir en su caso alguna aclaración didáctica sobre el
asunto.

*UNIX* y *Linux*
================
Desarrollado en el epígrafe :ref:`¿Qué es Linux? <qué-es>`.

Instalación
===========
El epígrafe sobre :ref:`instalación de un servidor <inst-servidor>` es demasiado
avanzado, así que **no** debe utilizarse. Basta, no obstante, con probar a hacer
una instalación de la última versión estable de *Debian* en modo |BIOS| y
|UEFI|, con o sin particionado previo con Gparted_, a fin de retomar los
:ref:`conceptos sobre particionado <disk-div>`.`

Interfaz |CLI|
==============
Desarrollado en el :ref:`epígrafe sobre entorno de texto <cli>`.

Sistema de archivos
===================
Desarrollado en todos los epígrafes que componen :ref:`acceso a la información
<linux-info>`. Sin embargo, es conveniente no dar en tanta profundidad
:ref:`find <find>`. Para esta orden basta con limitarse al uso::

   # find /ruta [-type f|l|d] -iname "nombre-con-comodines"

Dentro de este apartado deben hacerse dos relaciones de ejercicios:

* :ref:`ej-rutas`
* :ref:`ej-fic`
* :ref:`ej-dev`

Instalación y gestión de programas
==================================
Debe ser una versión resumida de :ref:`paqueteria` que incluya el
:ref:`paq-vistazo` (cómo se organizan los repositorios) y las :ref:`paq-bas`,
pero utilizando más bien :ref:`apt <apt>`. Las relaciones de ejericicios
asociados a este apartado son:

* :ref:`ej-softw`

Interfaz de red
===============
Para interfaz de texto puede usarse el epígrafe de :ref:`configuración mínima de
la red <redminima>`. Ahora bien, sería conveniente cómo configurarla en entornos
gráficos que utilizan otros mecanismos de configuración (p.e `network-manager
<https://es.wikipedia.org/wiki/NetworkManager>`_). Esto último puede hacerse a
través de los ejercicios:

* :ref:`ej-redmin`

.. |BIOS| replace:: :abbr:`BIOS (Basic I/O System)`
.. |UEFI| replace:: :abbr:`UEFI (Unified Extensible Firmware Interface)`
.. |CLI| replace:: :abbr:`CLI (Command Line Interface)`

.. _Gparted: https://gparted.org/
