.. _som-conflinux:

Configuración básica de linux (|CLI|)
*************************************

Interfaz |CLI|
==============
Desarrollado en el :ref:`epígrafe sobre entorno de texto <cli>`.

Gestión de *software*
=====================
Debe ser una versión resumida de :ref:`paqueteria` que incluya el
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
