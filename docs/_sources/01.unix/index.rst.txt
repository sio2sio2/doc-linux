.. _qué-es:

¿Qué es linux?
==============
En puridad, deberíamos empezar por el principio, esto es, por *UNIX*

UNIX
----
*UNIX* nació como sistema operativo en 1969 en los `Laboratorios Bell de AT&T
<https://es.wikipedia.org/wiki/Bell_Labs>`_ de la mano de `Ken Thompson
<https://es.wikipedia.org/wiki/Ken_Thompson>`_ y
`Dennis Ritchie <https://es.wikipedia.org/wiki/Dennis_Ritchie>`_. Este último
fue, además, el creador del `lenguaje de programación C
<https://es.wikipedia.org/wiki/C>`_, diseñado precisamente para el desarrollo de
*UNIX*. La implementación en **C** permitió portar *UNIX* a distintas
plataformas de manera mucho más sencilla que si se hubiera escrito en
ensamblador (como se hizo en un principio) y esa circunstancia fue parte de su éxito.

*UNIX* consta de un núcleo, un sistemas de ficheros, una serie de pequeñas
utilidades y una *shell* que permite combinar estas utilidades para realizar
labores más complejas.

AT&T distribuyó inicialmente *UNIX* a algunas universidades que podían
estudiarlo, adaptarlo y hacerle sus propios añadidos. Una de las licenciatarias
fue la `Universidad de Berkeley`, que hizo importantes aportaciones (p.e. la
adición del protocolo *TCP/IP* para comunicaciones) y desarrollo una versión
propia basada en la versión 4 de *UNIX* llamada |BSD| a la que con el tiempo se
le retiró todo rastro del código original para evitar problemas de licencias. La
última version desarrollada por Berkeley fue la *4.4* a partir de la cual se
desarrollaron las principales distribuciones |BSD| existentes en la actualidad:
`FreeBSD <https://es.wikipedia.org/wiki/FreeBSD>`_, `NetBSD
<https://es.wikipedia.org/wiki/NetBSD>`_ o `OpenBSD
<https://es.wikipedia.org/wiki/OpenBSD>`_.

No obstante, el problema de licencias con AT&T, provocó que durante un periodo
de dos años hasta que el pleito quedó resuelto en 1992 no se desarrollaran
versiones libres de |BSD|, lo que propició en 1991 la aparición de *Linux*.

Por cortesía de wikipedia\ [#]_, este es la historia esquemática de los
distintos unices:

.. image:: files/Unix_history-simple.svg

Actualmente hay tres grandes familias de sistemas *UNIX*:

* Los derivados de `UNIX System V <https://es.wikipedia.org/wiki/System_V>`_,
  fundamentalmente, `AIX de IBM <https://es.wikipedia.org/wiki/AIX>`_, `HP-UX de
  Hewlett-Packard <https://es.wikipedia.org/wiki/HP-UX>`_ y `Solaris de Sun
  Mycrosystem <https://es.wikipedia.org/wiki/Solaris_(sistema_operativo)>`_ (y
  ahora Oracle). Todos son propietarios.

* Los derivados de |BSD| ya citados anteriormente, libres por lo general con la
  gran excepción de `Mac Os X <https://es.wikipedia.org/wiki/MacOS>`_.

* Linux.

Linux
-----
*Linux* es un sistema operativo libre que emula el `comportamiento de UNIX
aunque no es UNIX <https://es.wikipedia.org/wiki/Unix-like>`_, pues no está
certificado como tal. No deriva del *UNIX* de los Laboratorios Bell, sino que es
creación original de `Linus Torvald
<https://es.wikipedia.org/wiki/Linus_Torvalds>`_, que, en 1991, siendo aún
estudiante en la universidad de Helsinki deseaba tener un *UNIX* para
`ordenadores PC <https://es.wikipedia.org/wiki/Compatible_IBM_PC>`_ y no estaba
del todo satisfecho con la licencia de `MINIX
<https://es.wikipedia.org/wiki/MINIX>`_, otro clon de sistemas *UNIX*
desarrollado por `Andrew S. Tanenbaum
<https://es.wikipedia.org/wiki/Andrew_S._Tanenbaum>`_, que sólo permitía su uso
educativo.

En puridad *Linux* es sólo el núcleo del sistema, mientras que el resto de
programas (*shell*, compilador, pequeñas aplicaciones) proceden en su mayoría
del `proyecto GNU <https://es.wikipedia.org/wiki/Proyecto_GNU>`_, que aun
habiendo desarrollado desde 1983 muchas de las aplicaciones del *UNIX* original
aún carecía en 1991 de un núcleo operativo.

Aunque el creador original de *Linux* fue Torvald, pronto adoptó un desarrollo
colaborativo a través de internet\ [#]_ y en la actualidad es desarrollado por
voluntarios y empleados de grandes empresas con interés en el desarrollo del
sistema como `IBM <https://es.wikipedia.org/wiki/IBM>`_, `Google
<https://es.wikipedia.org/wiki/Google>`_ o `Red Hat
<https://es.wikipedia.org/wiki/Red_Hat>`_.

.. note:: Por lo general, cuando usemos el término *Linux* en este documento nos
   referiremos al sistema completo, no sólo al *kernel*.

Distribución de referencia
--------------------------
La distribución de referencia para la elaboración de los apuntes es la
`Debian <http://www.debian.org>`_ estable disponible en el momento de la
redacción, esto es, la versión **9** `Stretch
<https://www.debian.org/News/2017/20170617>`_, aunque se ha procurado revisar la
sucesora `Buster <https://www.debian.org/releases/buster/index.html>`_. 

Para el uso de cualquier otra distribución quizás sea necesaria en algunos casos
la adaptación. En particular, para `Ubuntu <https://www.ubuntu.com>`_ las dos
principales diferencias son:

#. La ausencia de contraseña para el administrador y el uso predeterminado de
   :ref:`sudo <sudo>` para escalar privilegios.

#. La configuración de la red que desde la versión 17 se hace con `netplan
   <https://netplan.io/>`_ en vez de con el `paquete ifupdown
   <https://packages.debian.org/search?keywords=ifupdown>`_ que lee la
   configuración de :file:`/etc/network/interfaces`.

.. rubric:: Notas al pie

.. [#] El enlace original al gráfico es `éste
   <https://upload.wikimedia.org/wikipedia/commons/7/77/Unix_history-simple.svg>`_

.. [#] Lo que `Eric S. Raymond <https://es.wikipedia.org/wiki/Eric_S._Raymond>`_
   llama *modelo de bazar* en su ensayo clásico `La catedral y el bazar
   <http://softlibre.unizar.es/manuales/softwarelibre/catedralbazar.pdf>`_.

.. |BSD| replace:: :abbr:`BSD (Berkeley Software Distribution)`
