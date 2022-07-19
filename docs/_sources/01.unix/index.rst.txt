.. _qué-es:

¿Qué es *Linux*?
================
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

.. rubric:: Concepto

En puridad *Linux* es sólo el núcleo del sistema, mientras que el resto de
programas básicos (*shell*, compilador, pequeñas aplicaciones) proceden en gran
parte del `proyecto GNU <https://es.wikipedia.org/wiki/Proyecto_GNU>`_, que
aun habiendo desarrollado desde 1983 muchas de las aplicaciones del *UNIX*
original aún carecía en 1991 de un núcleo operativo.

Aunque el creador original de *Linux* fue Torvald, pronto adoptó un desarrollo
colaborativo a través de internet\ [#]_ y en la actualidad es desarrollado por
voluntarios y empleados de grandes empresas con interés en el desarrollo del
sistema como `IBM <https://es.wikipedia.org/wiki/IBM>`_, `Google
<https://es.wikipedia.org/wiki/Google>`_ o `Red Hat
<https://es.wikipedia.org/wiki/Red_Hat>`_\ [#]_.

.. note:: Por lo general, cuando usemos el término *Linux* en este documento nos
   referiremos al sistema completo, no sólo al *kernel*.

.. rubric:: Distribuciones

Utilizar directamente el *kernel* descargado de *Linux* es poco menos que
inviable, así que éste se hace accesible a los usuarios a través de lo que se
conoce como una *distribución* (o, coloquialmente, *distro*). Una
:dfn:`distribución` es una colección completa de *software* organizada alrededor
de un núcleo de *Linux* que constituye un sistema operativo funcional y
proporciona un instalador, un :ref:`sistema de gestión de software
<paqueteria>`, una organización de archivos y algunos aspectos básicos más.

Por tanto, "instalar *Linux*" implica en realidad escoger e instalar una
distribución de *Linux*; y "utilizar *Linux*", utilizar una distribución de
*Linux*. Y, aunque gran cantidad del *software* que instalan todas las
distribuciones es común (por ejemplo, las `herramientas GNU
<https://www.gnu.org/software/coreutils/manual/coreutils.html>`_), hay notables
diferencias entre ellas.

.. note:: Los sistemas operativos se distribuyen a menudo junto a un conjunto
   de herramientas que permite instalarlos y utilizarlos cómodamente. Así es,
   por ejemplo, como *Microsoft* distribuye su *Windows*. La diferencia
   fundamental entre la forma en que se distribuye *Windows* y una distribución
   de *Linux* es que estas distribuciones pretenden hacer disponible al usuario
   todas las aplicaciones que pueda necesitar, mientras que *Windows* sólo
   facilita un conjunto muy limitado, y es el usuario el encargado de obtener,
   descargar e instalar el resto de *software*.

Sea como sea, hay centenares de distribuciones, algunas generalistas y otras
orientadas a ciertos nichos. `Distrowatch <https://www.distrowatch.com>`_ es un
buen punto para conocer gran parte de ellas. Sin embargo, no todas las
distribuciones son independientes entre sí: lo habitual es que una distribución
tome su base de otra y añada o modifique ciertos aspectos.

Sin ser muy exhaustivos, las principales distribuciones son:

#. Slackware_, la más veterana superviviente junto a *Debian* y que se
   caracteriza por intentar mantener simple su diseño (`principio KISS
   <https://es.wikipedia.org/wiki/Principio_KISS>`_).
#. Debian_, que es posiblemente la que ha dado lugar a mayor cantidad de
   derivadas. Es muy apreciada su versión estable para servidores:

   - Ubuntu_, que nació en principio para acercar *Linux* al usuario novel. Con
     su popularización ha ido diversificándose y ahora proporciona también
     versiones pensadas para servidor.

     + Mint_. que tiene versiones basadas tanto en *Ubuntu* como en *Debian* y se orienta al usuario novel.

   - `Kali Linux`_, muy usada en auditoría y seguridad informáticas. Es
     básicamente una versión *live*\ [#]_ de *Debian* con *software* adicional
     de auditoría y ataque.

#. RedHat_, que es la distribución desarrollada por la empresa del mismo nombre (y desde 2019 filial de IBM). Formalmente desapareció en 2003, cuando se desdobló en dos: |RHEL| como versión comercial y Fedora como versión comunitaria.

   - Fedora_, que es la versión comunitaria de *Red Hat* (más bien, |RHEL|).
   - CentOS_, que es la versión gratuita de |RHEL|. *Red Hat* sólo distribuye
     las versiones terminadas de |RHEL| para sus suscriptores de pago, pero
     publica el código fuente bajo licencia |GPL|. Los voluntarios de *CentOS*
     toman ese código fuente, eliminan todas las marcas comerciales referentes
     a *Red Hat* y compilan para crear un producto terminado. El proyecto ha
     acabado patrocinado por la propia *Red Hat* y hasta finales de 2020 seguía
     esta filosofía. Sin embargo, en diciembre de ese año, *Red Hat* decidió
     convertir *CentOS* en una :ref:`distribución de liberación continua
     <ciclo-distro>` renombrándola como `CentOS Stream
     <https://www.centos.org/centos-stream/>`_, por lo que su fundador original
     creó `Rocky Linux`_ con el fin de continuar la
     idea original.

#. Suse_, distribución comercial de la empresa alemana del mismo nombre, que
   actualmente es propiedad de Novell. Tiene una versión comunitaria denominada
   OpenSuse_.
#. Gentoo_, cuya particularidad fundamental es no distribuir el *software*
   precompilado, sino su código fuente junto a las reglas necesarias para su
   compilación.
#. Archlinux_, orientada a usuarios avanzados y que persigue el principio |KISS|.

   - Manjaro_, que es una derivada de *Archlinux* enfocada a proporcionar una
     instalación sencilla para usuarios menos avanzados.

#. `Linux from Scratch`_ (o |LFS|), que no es propiamente una distribución,
   sino un conjunto de instrucciones para construir un sistema *Linux* completo
   desde cero.

.. seealso:: `LinuxTimeLine <https://github.com/FabioLolix/LinuxTimeline/tags>`_
   proporciona un gráfico que refleja la aparición de las principales
   distribiciones de *Linux* y cuál es el parentesco entre ellas.

Una diferencia fundamental entre distribuciones estriba en cuál es su filosofía
de actualización, esto es, si liberan periódicamente una *versión estable* o si
por el contrario son de *liberación continua* (ambos términos se tratan :ref:`al
analizar el ciclo de vida de las distribuciones <ciclo-distro>`). Según esta
característica las referidas distribuciones se agrupan así:

.. table::
   :class: ciclo-distros

   ============================== ========================
   Con liberación de versiones     De liberación continua
   ============================== ========================
   Slackware_                      Debian_ (testing, sid)
   Debian_ (estable)               Gentoo_
   Ubuntu_                         Archlinux_
   Mint_                           Manjaro_
   `Kali Linux`_                   `CentOS Stream`_
   |RHEL|
   Fedora_
   CentOS_ (ahora `Rocky Linux`_)
   Suse_/OpenSuse_
   ============================== ========================

.. _Slackware: https://www.slackware.com
.. _Debian: https://www.debian.org
.. _Ubuntu: https://www.ubuntu.com
.. _Mint: https://www.linuxmint.com
.. _Kali Linux: https://www.kali.org
.. _RedHat: https://www.redhat.com
.. _Fedora: https://getfedora.org
.. _CentOS: https://www.centos.org
.. _Suse: https://www.suse.com
.. _Gentoo: https://www.gentoo.org
.. _Archlinux: https://www.archlinux.org
.. _Manjaro: https://manjaro.org
.. _OpenSuse: https://www.opensuse.org
.. _Linux from Scratch: https://www.linuxfromscratch.org
.. _Rocky Linux: https://rockylinux.org

.. rubric:: Distribución de referencia

La *distribución de referencia* para la elaboración de los apuntes es la rama
estable de *Debian* (véanse :ref:`cuáles son sus distintas ramas <ramas>`). La
redacción se comenzó en 2016 cuando lo era Jessie_ (la versión **8.0**), aunque
por estar próxima a concluir su ciclo se procuró adaptar el contenido a la
versión **9.0** Stretch_. Desde entonces se han publicado nuevas versiones
(Buster_, Bullseye_) y la redacción de nuevos epígrafes y la revisión de algunos
ya escritos se ha ido procurando adaptar a ellas, pero pueden existir partes que
no hayan recibido revisión y, por tanto, tengan alguna explicación que haya
perdido validez o requiera alguna pequeña adaptación.

Fuera de *Debian*, la mayor parte de las explicaciones debería ser válida para
sus distribuciones derivadas.

.. rubric:: Notas al pie

.. [#] El enlace original al gráfico es `éste
   <https://upload.wikimedia.org/wikipedia/commons/7/77/Unix_history-simple.svg>`_

.. [#] Lo que `Eric S. Raymond <https://es.wikipedia.org/wiki/Eric_S._Raymond>`_
   llama *modelo de bazar* en su ensayo clásico `La catedral y el bazar
   <http://softlibre.unizar.es/manuales/softwarelibre/catedralbazar.pdf>`_.

.. [#] En realidad, desde 2019 `Red Hat es propiedad de IBM
   <https://newsroom.ibm.com/2019-07-09-IBM-Closes-Landmark-Acquisition-of-Red-Hat-for-34-Billion-Defines-Open-Hybrid-Cloud-Future>`_.

.. [#] Una :dfn:`distribución live` es un sistema operativo completo almacenado
   en un medio extraíble (|CD| o |DVD| tradicionalmente, pero ahora también
   dispositivos de memorias flash) pensado para ejecutarse sin instalación.

.. |BSD| replace:: :abbr:`BSD (Berkeley Software Distribution)`
.. |RHEL| replace:: :abbr:`RHEL (Red Hat Enterprise Linux)`
.. |KISS| replace:: :abbr:`KISS (Keep It Simple, Stupid!)`
.. |LFS| replace:: :abbr:`LFS (Linux From Scratch)`
.. |GPL| replace:: :abbr:`GPL (General Public Licence)`
.. |CD| replace:: :abbr:`CD (Compact Disk)`
.. |DVD| replace:: :abbr:`DVD (Digital Versatile Disc)`

.. _Jessie: https://www.debian.org/News/2015/20150426
.. _Stretch: https://www.debian.org/News/2017/20170617
.. _Buster: https://www.debian.org/News/2019/20190706
.. _Bullseye: https://www.debian.org/News/2021/20210814
