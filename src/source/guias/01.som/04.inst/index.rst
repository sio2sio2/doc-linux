.. _son-inst:

Instalación de |SSOO|
*********************
El proceso de instalación de uno o varios sistemas operativos (sobre todo si son
varios) exige entender completamentamente dos aspectos:

+ Cómo y por qué se particionan discos.
+ Qué ocurre durante el proceso de arranque y cómo puede manipularse éste.

Por consiguiente, los dos primeros apartados de la unidad los dedicaremos a
estos aspectos previos, para en el tercero centrarnos en la instalación de dos
sistemas operativos: *Windows* y *Linux*.

Particionado
============
El contenido de este epígrafe está desarrollado en el :ref:`epígrafe sobre
particiones de Linuxnomicón <particionado>`. En el se describen los dos sistemas
de particionado que nos interesa conocer: |GPT| y |DOS|.

Arranque
========
Para instalar sistemas operativos y, sobre todo, si quieren instalarse varios en
el equipo, es indispensable entender cómo arranca éste y qué espera encontrar en
en los discos. Sobre estos asuntos asuntos versa el :ref:`epígrafe sobre
arranque del manual de Linux <arranque>`.

.. note:: No es el propósito de este epígrafe analizar ningún gestor de arranque
   concreto, de modo que no profundice en ninguno de los descritos en los citados
   en el enlace facilitado (:ref:`GRUB <grub>`, :ref:`rEFInd <refind>`).

Instalación
===========
.. todo:: Este epígrafe debe desarrollar:

   * Principios para la instalación de Windows (cuántas particiones se usan,
     sistema de archivos).
   * Principios para la instalación de Linux (particiones habituales para
     sistemas de escritorio).
   * Descripción de *Windows Boot Manager* y cómo se recupera.
   * Descripción de |GRUB| y como se recupera.

.. include:: /guias/01.som/99.ejercicios/031.part.rst

.. |GPT| replace:: :abbr:`GPT (GUID Partition Table)`