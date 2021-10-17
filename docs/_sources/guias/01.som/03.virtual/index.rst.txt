.. _som-virtual:

Virtualización de plataforma
****************************
Completado el estudio teórico sobre los sistemas operativos, lo pertinente es
abordar su estudio práctico: su instalación, su configuración y su
administración. Los |SSOO|, no obstante, tienen la particularidad de necesitar
la dedicación completa del equipo, por lo que acceder a su testeo no es tan
sencillo como el testeo de cualquier otra aplicación, para la cual basta
instalarla en nuestro sistema habitual. Muy al contrario necesitan que la
máquina arranque con el sistema operativo a estudiar y eso supone alterar por
completo el funcionamiento del propio equipo.

Las estrategias habituales para no afectar al sistema instalado han sido dos:

+ Utilizar un segundo disco sobre el que se instalaran todos los sistemas
  operativos objeto del estudio. Con este propósito, antes podía colocarse una
  bahía que permitiera extraer sin abrir el chasis un disco |IDE|, con el fin de
  poder intercambiar fácilmente  el disco de nuestro sistema habitual por el
  disco de pruebas. Modernamente, puede utilizarse un disco externo conectado
  a través de |USB| (a partir de su versión 3, las velocidades son bastante
  aceptables) y escoger el dispositivo de arranque.

+ Desde que los procesadores empezaron a incluir instrucciones para mejorar el
  rendimiento de la virtualización de plataforma, utilizar ésta. Téngase en
  cuenta que la virtualización incorpora dos grandes ventajas sobre el método
  anterior:
 
  * no es necesario utilizar *hardware* adicional. 
  * se pueden crear cuantas máquinas virtuales deseemos, que pueden interactuar
    a la vez emulando incluso varios sistemas operativos en red.

Por las ventajas reseñadas, esta segunda estrategia es más apropiada y le
dedicaremos el estudio de esta unidad.

Tipos de virtualización
=======================
La **virtualización de plataforma** y, en concreto, la **virtualiación
completa de plataforma** es sólo uno de los tipos de virtualización que existen.
Es conveniente, pues, echar un vistazo al concepto de virtualización.

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

.. |IDE| replace:: :abbr:`IDE (Integrated Drive Electronics)`
.. |USB| replace:: :abbr:`USB (Universal Serial Bus)`
