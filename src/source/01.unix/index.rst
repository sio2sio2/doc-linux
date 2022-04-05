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
:ref:`Debian estable <ramas>`. La redacción
se comenzó en 2016 cuando lo era Jessie_ (la versión **8.0**), aunque por estar
próxima a concluir su ciclo se procuró adaptar el contenido a la versión **9.0**
Stretch_. Desde entonces se han publicado nuevas versiones (Buster_, Bullseye_)
y la redacción de nuevos epígrafes y la revisión de algunos ya escritos se ha
ido procurando adaptar a ellas, pero pueden existir partes que no hayan recibido
revisión y, por tanto, tengan alguna explicación que haya dejado de ser válida.

Fuera de *Debian*, la mayor parte de las explicaciones debería ser válida para
sus distribuciones derivadas.

.. rubric:: Notas al pie

.. [#] El enlace original al gráfico es `éste
   <https://upload.wikimedia.org/wikipedia/commons/7/77/Unix_history-simple.svg>`_

.. [#] Lo que `Eric S. Raymond <https://es.wikipedia.org/wiki/Eric_S._Raymond>`_
   llama *modelo de bazar* en su ensayo clásico `La catedral y el bazar
   <http://softlibre.unizar.es/manuales/softwarelibre/catedralbazar.pdf>`_.

.. |BSD| replace:: :abbr:`BSD (Berkeley Software Distribution)`

.. _Jessie: https://www.debian.org/News/2015/20150426
.. _Stretch: https://www.debian.org/News/2017/20170617
.. _Buster: https://www.debian.org/News/2019/20190706
.. _Bullseye: https://www.debian.org/News/2021/20210814
