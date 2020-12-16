.. _som-virtual:

Virtualización de plataforma
****************************
Completado el estudio teórico sobre los sistemas operativos, lo pertinente es
abordar su estudio práctico: su instalación, su configuración y su
administración. Los |SSOO|, no obstante, tienen la particularidad de necesitar
la dedicación completa del equipo, por lo que acceder a su testeo no es tan
sencillo como el testeo de cualquier otra aplicación, para la cual basta
instalarla en nuestro sistema habitual. Muy al contrario necesitan que la
máquina arranque con el sistema operativo a estudiar y beso supone alterar la
organización del propio equipo.

Las estrategias habituales para no afectar al sistema instalado han sido dos:

+ Utilizar un segundo disco sobre el que se instalaran todos los sistemas
  operativos objeto del estudio. Para ello solían colocarse una bahía que
  permitieran extraer el disco dusco y sustituir el disco de nuestro sistema
  habitual por el disco para pruebas.

+ Desde que los procesadores empezaron a incluir instrucciones para mejorar su
  rendimiento, la virtualización de plataforma, cuyo estudio es el objeto de
  este pequeño tema.

Tipos de virtualización
=======================
La **virtualización de plataforma** y, en concreto, la **virtualiación
completa** es sólo uno de los tipos de virtualización que existen. Es
conveniente, pues, echar un vistazo al concepto de virtualización.

Como texto de este epígrafe se puede usar el :ref:`apéndice sobre virtualización
<virtual>`.

Virtualbox
==========
De todo el *software* de Virtualbox disponible, nos centraremos en *Virtualbox*
por cuatro motivos principales:

+ Es sencillo de utilizar.
+ Funciona razonablemente bien.
+ Es multiplataforma.
+ Tiene licencia libre y carece de coste.

Las pautas principales y no tan evidentes para su uso se encuentran también
dentro del apéndice anterior en el subapartado dedicado a :ref:`Virtualbox
<virtualbox>`.

.. include:: /guias/01.som/99.ejercicios/030.virt.rst
