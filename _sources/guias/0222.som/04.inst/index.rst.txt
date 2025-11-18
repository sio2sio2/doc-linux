.. _som-inst:

*********************
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
************
El contenido de este epígrafe está desarrollado en el :ref:`epígrafe sobre
particiones de Linuxnomicón <particionado>`. En el se describen los dos sistemas
de particionado que nos interesa conocer: |GPT| y |DOS|.

Arranque
********
Para instalar sistemas operativos y, sobre todo, si quieren instalarse varios en
el equipo, es indispensable entender cómo arranca éste y qué espera encontrar en
en los discos. Sobre estos asuntos asuntos versa el :ref:`epígrafe sobre
arranque del manual de Linux <arranque>`.

.. note:: No es el propósito de este epígrafe analizar ningún gestor de arranque
   concreto, de modo que no profundice en ninguno de los descritos en los citados
   en el enlace facilitado (:ref:`GRUB <grub>`, :ref:`rEFInd <refind>`).

Instalación
***********
Se enumeran algunos aspectos a tener en cuenta en la instalación tanto de
*Windows* como de *Linux*.

Windows
=======
Los sistemas *Windows* para ordenadores tienen dos grandes líneas: la destinada
a servidores (apellidadas "*Server*"), que no trataremos en este módulo; y la
destinada a clientes.

.. rubric:: Ediciones y versiones

Dentro de la línea para clientes, *Microsoft* saca cada cierto tiempo nuevas
versiones numeradas (**7**, **8**, **10** y el reciente **11**) que a su vez
tienen distintos sabores (:dfn:`ediciones` según la propia terminología de
Microsoft) en que, en esencia, son el mismo sistema, pero con más o menos
limitaciones. Las ediciones disposibles son:

* **Home**: es la edición, pensada para el usuario doméstico estándar, más
  barata, pero con menos prestaciones. Si se es un usuario avanzado, puede
  echarse en falta la ausencia de administración remota (tiene cliente, pero no
  servidor), de Hyper-V para virtualización, o de *BitLocker* (para cifrar el
  sistema).

* **Professional** (o, simplemente, **Pro**): es la edición recomendada para
  usuarios avanzados e incorpora características ausentes en la *Home*.

* **Enterprise**: es muy parecida a la *Pro*, pero destinada al uso empresarial,
  de ahí que *Microsoft* sólo permita su adquisión a través de licencias por
  volumen.

* **Education**: es la edición *Enterprise* para instituciones educativas.

.. seealso:: Para más información, puede consultarse `este artículo de Softzone
   <https://www.softzone.es/windows/como-se-hace/windows-10-home-vs-pro-vs-enterprise-vs-education/>`_.

Además, las ediciones pueden presentar variantes sobre su forma original:

* |LTSC|: es una variante de la *Enterprise* con soporte extendido que aseguran
  el mantenimiento y las actualizaciones de seguridad durante al menos 10 años.
  Son, por tanto, el equivalente de las versiones |LTS| de las distribuciones de
  *Linux*.

* **N**: son variantes que carecen de reproductor multimedia preinstalado (en
  concreto, el `Windows Media Player
  <https://es.wikipedia.org/wiki/Reproductor_de_Windows_Media>`_)

.. note:: Microsoft permite la `evaluación durante 90 días de la edición
   Enterprise
   <https://www.microsoft.com/es-xl/evalcenter/evaluate-windows-10-enterprise>`_.

.. rubric:: Requisitos

Como cualquier otro sistema operativo, *Windows* exige un *hardware* mínimo
(que puede consultarse `aquí
<https://www.microsoft.com/es-es/windows/windows-10-specifications#primaryR2>`_),
aunque estas exigencias mínimas no permiten más que arrancar el sistema y
utilizar con cierta pesadez la interfaz. Para un uso habitual en el que se usan
aplicaciones, el *hardware* debe ser mucho mejor. Para virtualizar el sistema y
realizar las prácticas del curso basta con crear una máquina virtual que cumpla
los requisitos mínimos (2GiB de memoria RAM), aunque si podemos es preferible
darle dos núcleos al procesador en vez de 1.

.. rubric:: Particiones

*Windows* necesita al menos una :ref:`partición de sistema <tipos-particion>` de
tamaño mínimo de 32GiB formateada en |NTFS| para instalarse. Sin embargo, si le
es posible\ [#]_, la instalación puede crear algunas :ref:`particiones especiales
propias <tipos-particion>`:

a. En sistemas con arranque |EFI|, una pequeña partición |MSR| (partición
   *reservada para sistema de Microsoft*) de 16 MiB que ayuda a la gestión de
   las particiones (véase la `propia información de Microsoft
   <https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/configure-uefigpt-based-hard-drive-partitions?view=windows-11#microsoft-reserved-partition-msr>`_).

#. En sistemas con arranque |BIOS|, una pequeña partición |SRP| de 50 ó 100 MiB
   para almacenar los archivos del gestor de arranque y los que permiten
   arrancar si la partición del sistema se cifró con :program:`BitLocker`\ [#]_.

#. Sea cual sea el sistema de arranque, una partición de recuperación *WinRE*,
   que contiene las herramientas de recuperación de *Windows* que se utilizan
   cuando no se puede arrancar el sistema operativo por algún problema grave.
   En caso deque no sea posible crearla, los archivos se guardan en una ruta
   dentro de la partición del sistema (:file:`%SystemDrive%\Recovery`).

.. seealso:: *Microsoft* desarrolla en dos documentos la descripción de las
   particiones `en sistemas BIOS
   <https://docs.microsoft.com/es-es/windows-hardware/manufacture/desktop/configure-biosmbr-based-hard-drive-partitions>`_
   y `en sistemas EFI
   <https://docs.microsoft.com/es-es/windows-hardware/manufacture/desktop/configure-uefigpt-based-hard-drive-partitions>`_.

.. note:: Por supuesto, en un arranque |EFI| es necesaria la partición |ESP|,
   por exigencia del propio estándar.

Linux
=====
Las sistemas *Linux* son muy variopintos y es imposible en muchos casos dar unas
indicaciones generales.

.. _linux-distribuciones:

.. rubric:: Distribuciones

Los sistemas *Linux* se organizan en :dfn:`distribuciones`, a las que podemos
definir como una colección organizada de aplicaciones basadas en un núcleo de
*Linux* a la que se dota un sistema simple de instalación, gestión y
actualización. Las distribuciones de *Linux* son innumerables (consúltese `esta 
cronología de distribucines
<https://github.com/FabioLolix/LinuxTimeline/releases>`_ para más información)
y, en muchos casos, incomparables entre sí, porque intentan satisfacer demandas
muy dispares.

Sin ánimo de ser exhaustivos (para ello consulte la cronología ya enlazada)
algunas distribuciones importantes son:

* *Históricas*, que nacieron en los años 90 *ex novo* o a partir de otras
  distribuciones que no han sobrevivido:

  + Debian_, que, además de ser aún una de las usadas, es la que más derivadas
    ha generado. Es la distribución de referencia que se usa para este
    manual.
  + Slackware_, que nació de SLS_.
  + RedHat_, que es la versión empresarial desarrollada por la empresa del
    mismo nombre. Tiene, más que derivadas, algunas variantes: Fedora_,
    CentOS_, etc. En el :ref:`epígrafe introductorio sobre Linux del
    manual <linux>` hay información al respecto.
  + SuSE_, cuyas primeras versiones se publicaron como versión alemana de
    Slackware_, pero que se rehizo basándose en Jurix_ para posteriormente
    adoptar algunas características de RedHat_ como el sistemas de paquetes o
    la estructura de archivos. Tiene una versión para la comunidad denominada
    OpenSUSE_.

* *Recientes*, que surgieron *ex novo* posteriormente:

  + Gentoo_.
  + ArchLinux_.

* *Derivadas* de distribuciones existentes:

  + Ubuntu_, derivada de Debian_.
  + `Amazon Linux`_ que usa Amazon_ en algunos de sus servicios en la nube y se
    basa en RedHat_.

* *Especializadas*, que son distribuciones enfocadas a un uso muy concreto:

  + OpenWrt_, enfocada a la instalación en dispositivos de red como
    *routers*.
  + SliTaZ_, una distribución minimalista que intenta mantener un tamaño muy
    reducido.

.. rubric:: Requisitos

Obviamente, el *hardware* mínimo depende de cuál sea la distribución que
elijamos y, aun en una misma distribución, de cuál sea en entorno que deseemos
utilizar: no es lo mismo instalar una distribución sin entorno gráfico que esa
misma con entorno de escritorio. Incluso, dentro de los entornos gráficos, los
hay muy ligeros como Fluxbox_ o Openbox_ o escritorios completos bastante
pesados como KDE_ o Gnome_.

Para un *Linux* generalista con un escritorio pesado es probable que requiramos
un *hardware* semejante al exigido por *Windows*.

.. rubric:: Particiones

En puridad, *Linux* sólo necesita una partición para el sistema raíz
(habitualmente formateada en *ext4*, aunque no necesariamente). Ahora, es común
que se creen otras particiones:

* Partición para la *memoria de intercambio* para cuyo tamaño podemos usar la
  fórmula expresada por :eq:`ram`. También es común que se prescinda de tal
  partición y se use un archivo (con idénticas necesidades de tamaño), ya que a
  partir de la versión *2.6* no hay diferencias de rendimiento.

* Partición para datos de usuario montada sobre :file:`/home`.

* Cualquier otra que aconseje el uso para el que vaya destinado el sistema. En
  el :ref:`epígrafe dedicado a la instalación de un servidor <inst-servidor>` se
  sugieren algunas más de las aquí expuestas.

Recuperación
************
.. todo:: Este epígrafe debe desarrollar:

   * Descripción de *Windows Boot Manager* y cómo se recupera.
   * Descripción de |GRUB| y como se recupera.

.. include:: /guias/0222.som/99.ejercicios/031.part.rst

.. rubric:: Notas al pie

.. [#] Le separá posible crear estas particiones especiales si *Windows* detecta
   espacio libre en el disco que pueda utilizar para su creación.

.. [#] Esta partición no es necesaria en sistemas con arranque |UEFI|, porque el
   arranqe ya exige la existencia de la partición |ESP|.

.. |GPT| replace:: :abbr:`GPT (GUID Partition Table)`
.. |LTSC| replace:: :abbr:`LTSC (Long Term Servicing Channel)`
.. |LTS| replace:: :abbr:`LTS (Long Term Support)`
.. |NTFS| replace:: :abbr:`NTFS (NT File System)`
.. |EFI| replace:: :abbr:`EFI (Extensible Firmware Interface)`
.. |ESP| replace:: :abbr:`ESP (EFI System Partition)`
.. |MSR| replace:: :abbr:`MSR (Microsoft System Reserved)`
.. |SRP| replace:: :abbr:`MSR (System Reserved Partition)`
.. |RAM| replace:: :abbr:`RAM (Random Access Memory)`

.. _Debian: https://www.debian.org
.. _Slackware: https://es.wikipedia.org/wiki/Slackware
.. _SLS: https://es.wikipedia.org/wiki/SLS_Linux_(Softlanding_Linux_System)
.. _Jurix: https://es.wikipedia.org/wiki/Jurix
.. _RedHat: https://www.redhat.com
.. _SuSE: https://www.suse.com/
.. _Gentoo: https://www.gentoo.org/
.. _ArchLinux: https://archlinux.org/
.. _Amazon Linux: https://en.wikipedia.org/wiki/Amazon_Machine_Image#Amazon_Linux_AMI
.. _Ubuntu: https://ubuntu.com
.. _Amazon: https://aws.amazon.com
.. _OpenSUSE: https://www.opensuse.org/
.. _OpenWrt: https://openwrt.org/
.. _SliTaZ: https://www.slitaz.org/
.. _Fedora: https://www.fedora.org
.. _CentOS: https://www.centos.org
.. _Fluxbox: http://www.fluxbox.org
.. _Openbox: http://www.openbox.org
.. _KDE: https://www.kde.org
.. _Gnome: https://www.gnome.org
