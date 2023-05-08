Gestión de servicios
====================
Se trató bajo un epígrafe anterior :ref:`cómo gestionar de manera básica los
procesos del sistema <procesos>`, en concreto, cómo conocer los que se ejecutan
y cómo pararlos de manera más o menos expeditiva. Para un sistema de escritorio
muy básico, estos conocimientos son suficientes, y, aunque en todo sistema
corren una serie de servicios, estos rara vez son manipulados por el usuario que
se limita a ejecutar sus aplicaciones finales.

Sin embargo, en un sistema de servidor, es imprescidible saber cómo manipular y
gestionar estos servicios, esto es, cómo, cuáles y por qué arrancan, cómo
pararlos de manera ordenada. cómo modificar su arranque y finalmente cómo
volverlos a arrancar. De todo esto, es de lo que trata el presente apartado.

Antes de empezar, no obstante, es conveniente dar una pátina de conocimientos
sobre cuál es la forma en que arrancan los sistemas *UNIX*.

Nada más cargar su *kernel*, los sistemas *UNIX* ejecutan un proceso llamado
tradicionalmente :command:`init` (de **init**\ ialization) con *PID* 1, que es
el encargado de generar el resto de procesos. Este ejecutable tiene dos estilos
para gestionar qué servicios arrancar durante el arranque:

* El estilo :abbr:`BSD (Berkeley Software Distribution)`, en el que un único
  *script* (:file:`/etc/rc`) se encarga de la gestión.
* El estilo `SystemV <https://es.wikipedia.org/wiki/System_V>`_ (también
  denominano *SysV*)\ [#]_, en el que la gestión se hace modular por medio de
  distintos *scripts* almacenados bajo :file:`/etc/rc.d/`.

La mayoría de las grandes distribuciones de *Linux* optó por este segundo
estilo, con la salvedad `Slackware <http://www.slackware.com/config/init.php>`_,
más cercano a la filosofía del estilo *BSD*. La principal limitación del sistema
tradicional es que actúa de manera síncrona, por lo que hasta que no se ha
completado una tarea no se continúa con la siguiente, lo que dilata los tiempos
de arranque.  Hubo tanteos para cambiar este sistema de gestión con irregular
éxito (*Canonical* creó para *Ubuntu* `upstart
<https://es.wikipedia.org/wiki/Upstart>`_), hasta la aparición de :ref:`SystemD
<systemd>`, que ha sido adoptado por la mayoría de las grandes distribuciones,
con las excepciones de *Slackware* y *Gentoo*. *Debian* fue la última de las
mayoritarias en adoptarlo y arrastró con su decisión a *Ubuntu*, que abandonó
:program:`upstart`.

.. _sysv:

SysV
----

.. warning:: SystemV no se usa ya en Debian (la última estable que lo uso fue
   *Wheezy*), de modo que este apartado es meramente informativo y, de hecho, no
   se entrará en absoluto en detalle\ [#]_.

.. _runlevel:

En el sistema de arranque basado en *SystemV* existe un fichero
:file:`/etc/inittab` que controla la configuración para el ejecutable
:command:`init`. Este fichero, entre otros aspectos, indica en qué *nivel de
ejecución* arrancará el sistema. Un :dfn:`nivel de ejecución` (o *runlevel*)
define el modo de operación con que actuará el sistema operativo, lo que se
traduce en cuáles son los servicios que deben cargarse durante el arranque. En
*Linux* los niveles de ejecución típicos son *siete*:

**0**: *Halt*
   Apagado del sistema.

**1**: *single-user mode*
   Modo monousuario. No ejecuta apenas servicios y sólo permite entrar en el
   sistema con la contraseña del administrador (*root*). Es el nivel de
   ejecución en que arranca el ordenador cuando se detecta un problema que exige
   reparación.\ [#]_

**2**: *multi-user mode*
   Modo multiusuario sin funciones de red.

**3**: *multi-user mode with networking*
   Modo multiusuario con funciones de red.

**4**: *user definible*
   Modo sin uso específico, de modo que puede definirlo el usuario como mejor
   convega.

**5**: *multi-user mode with networking and GUI*
   A los servicios cargados en el *runlevel* 3, se añade la carga del servidor
   gráfico.

**6**: *reboot*
   Reinicio del sistema.

Por lo general, en :file:`/etc/inittab` se configura el nivel de ejecución
predeterminado (normalmente 3 ó 5), aunque en :ref:`Grub <grub>` se puede añadir alguna
entrada que cargue un runlevel distinto. Por ejemplo, es relativamente común que
se añada una entrada *recovery mode* (o modo de recuperación) que arranque el
sistema en *runlevel* 1. Para ello basta con incluir el número del *runlevel*
como parámetro en la carga del núcleo.

Para organizar el arranque al estilo *SysV* las distribuciones de *Linux* traen
un directorio :file:`/etc/init.d` dentro del cual incluyen todos los *scripts*
que lanzan o paran los servicios y una serie de directorios :file:`/etc/rcX.d`
donde *X* es el número correspondiente al *runlevel*. El contenido de estos
directorios son enlaces simbólicos a los *scripts* contenidos en
:file:`/etc/init.d` con nombres tales como :file:`S05slim` o :file:`K01slim`.
El final de estos nombres (*slim* en el ejemploi) es el nombre del *script* con
el que enlazan; la *S* o *K* indica si hay que arrancar o parar el servicio; y
el número intermedio el orden en que han de ser arrancados o parados (un número
*01* significa que ese *script* se arrancará antes que uno con número *02*). Lo
habitual es que los *runlevels* de arranque (1-5) tengan enlaces simbólicos con
*S* y los *runlevels* de cierre (0, 6) enlaces simbólicos con *K*. Además hay un
directorio :file:`/etc/rc.S` que sirve para incluir *scripts* que se ejecutan al
término del arranque, sea cual sea el nivel de ejecución (1-5).

En la práctica en *Debian* y derivadas, no se hace distinción entre los
*runlevels* 2-5, de manera que los *runlevels* distintos se reducen a 4 (0, 1,
2-5 y 6).

Para gestionar lo explicado y arrancar y parar a mano durante la ejecución del
sistema algún servicio, *Debian* dispone de algunas herramientas que se
explicarán en la sección `Gestión al modo de Debian`_ y que se han portado a
*SystemD* con lo que siguen siendo válidas, aunque el gestor del sistema haya
cambiado.

.. _systemd:

SystemD
-------

*SystemD* es nuevo gestor de sistema desarrollado a partir de 2009 en principio
para la distribución `Red Hat <https://www.redhat.com/es>`_, pero que ha acabado
siendo adoptado por la mayoría de las distribuciones modernas de *Linux*,
excepto `Slackware <http://www.slackware.com/config/init.php>`_ y `Gentoo
<https://wiki.gentoo.org/wiki/OpenRC>`_.

Utiliza características exclusivas de *Linux* por lo que no es implementable
para otros *unices* y ha recibido `fuertes críticas
<https://www.linuxito.com/gnu-linux/nivel-alto/431-por-que-systemd-es-una-mierda>`_
y hasta hay una *wiki* para reúne información sobre `sistemas linux sin
SystemD <http://without-systemd.org/wiki/index.php/Main_Page>`_ Sea como sea,
se ha convertido en el estándar de facto para el arranque de los sistemas
*Linux* y, por consiguiente, no queda otra que conocerlo\ [#]_. En particular,
nos interesa conocer los siguientes aspectos sobre los servicios\ [#]_:

.. toctree::
   :glob:
   :maxdepth: 1

   systemd/[0-9]*

Enlaces de interés
""""""""""""""""""

* `Información sobre SystemD de la wiki de ArchLinux
  <https://wiki.archlinux.org/index.php/Systemd_(Espa%C3%B1ol)>`_
* Serie de artículos en `linux.com <https://www.linux.com>`_ sobre *SystemD*:
    - `Intro to SystemD
      <https://www.linux.com/learn/here-we-go-again-another-linux-init-intro-systemd>`_.
    - `Understanding and Using SystemD
      <https://www.linux.com/learn/understanding-and-using-systemd>`_.
    - `Intro to SystemD Runlevels and Service Management Commands
      <https://www.linux.com/learn/intro-systemd-runlevels-and-service-management-commands>`_.
* Serie de artículos en `digitalocean.com <https://www.digitalocean.com>`_ sobre *SystemD*:
    - `SystemD Essentials
      <https://www.digitalocean.com/community/tutorials/systemd-essentials-working-with-services-units-and-the-journal>`_
    - `How To Use Systemctl to Manage SystemD Services and Units
      <https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units>`_
    - `Understanding SystemD Units and Unit Files
      <https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files>`_
    - `How To Use Journalctl to View and Manipulate SystemD Logs
      <https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs>`_ (este artículo
      trata la :ref:`monitorización con SystemD <journalctl>`).
* `Epígrafe sobre SystemD de la Guía de configuración de Red Hat
  <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/chap-Managing_Services_with_systemd.html>`_

Gestión al modo de Debian
-------------------------
Aunque de *Wheezy* (*7.0*) a *Jessie* (*8.0*) se cambió la gestión del sistema de
*SystemV* a *SystemD*, *Debian* ha portado también sus herramientas de un
sistema a otro\ [#]_, a fin de que puedan seguirse gestionando los servicios como
hasta la fecha.

La *ventaja* de conocer estas herramientas es que pueden manipularse los
servicios de idéntico modo con independencia de cuál versión de *Debian*
tratemos.  La *desventaja* es que podemos realizar un número reducido de
operaciones.

.. _invoke-rc.d:
.. _service:
.. _update-rc.d:


.. index:: invoke-rc.d
.. index:: service
.. index:: update-rc.d

+-----------------------------------------------+----------------------------------------------------------------------+----------------------+
| SystemD                                       |                           Tradicional                                | Acción               |  
|                                               +--------------------------------------+-------------------------------+                      |
|                                               | Con :code:`invoke-rc.d`              | Con :code:`service`           |                      |
+===============================================+======================================+===============================+======================+ 
|:code:`systemctl start ssh.service`            | :code:`invoke-rc.d ssh start`        |:code:`service ssh start`      | Arrancar servicio    |  
+-----------------------------------------------+--------------------------------------+-------------------------------+----------------------+ 
|:code:`systemctl stop ssh.service`             | :code:`invoke-rc.d ssh stop`         |:code:`service ssh stop`       | Parar servicio       |  
+-----------------------------------------------+--------------------------------------+-------------------------------+----------------------+ 
|:code:`systemctl restart ssh.service`          | :code:`invoke-rc.d ssh restart`      |:code:`service ssh restart`    | Reiniciar servicio   |  
+-----------------------------------------------+--------------------------------------+-------------------------------+----------------------+ 
|:code:`systemctl reload ssh.service`           | :code:`invoke-rc.d ssh reload`       |:code:`service ssh reload`     | Recargar servicio    |  
+-----------------------------------------------+--------------------------------------+-------------------------------+----------------------+ 
|:code:`systemctl reload-or-restart ssh.service`| :code:`invoke-rc.d ssh force-reload` |:code:`service ssh reload`     | Recargar servicio    |  
+-----------------------------------------------+--------------------------------------+-------------------------------+----------------------+ 
|:code:`systemctl status ssh.service`           | :code:`invoke-rc.d ssh status`       |:code:`service ssh status`     | Supervisar servicio  |  
+-----------------------------------------------+--------------------------------------+-------------------------------+----------------------+ 
|:code:`systemctl enable ssh.service`           | :code:`update-rc.d ssh enable`                                       | Habilitar servicio   | 
+-----------------------------------------------+----------------------------------------------------------------------+----------------------+ 
|:code:`systemctl disable ssh.service`          | :code:`update-rc.d ssh disable`                                      | Deshabilitar servicio| 
+-----------------------------------------------+----------------------------------------------------------------------+----------------------+ 

.. Para systemd:
   https://wiki.debian.org/systemd
   https://wiki.debian.org/Teams/pkg-systemd/Integration
   http://unix.stackexchange.com/questions/136481/should-invoke-rc-d-or-service-be-used-to-restart-services

.. rubric:: Notas al pie

.. [#] El nombre deriva de que tal estilo de arranque se creó para la versión
   `System V del UNIX original de AT&T <https://es.wikipedia.org/wiki/System_V>`_.

.. [#] No obstante, tiene su utilidad conocerlo, ya que *Debian* sigue
   incluyendo en sus paquetes los *scripts* para *SysV*. En cualquier caso,
   estos *scripts* no deben ejecutarse directamente. No ahora que la gestión la
   hace *SystemD*, pero tampoco antes puesto que *Debian* dispone de un conjunto
   de utilidades para gestionar el arranque. Estas utilidades siguen siendo
   válidas, puesto que se han portando a *SystemD* y son las que se explican en
   la sección `Gestión al modo de Debian`_.

.. [#] Por ejemplo, si es imposible montar una partición listada en
   :file:`/etc/fstab` que no tenga como opción de montaje *nofail*, se producirá
   un error que provocará que el sistema pase al *runlevel* 1.

.. [#] Aunque el método tradicional de gestión de permisos en *Debian* ya está
   portado a *SystemD*, éste sólo sirve para los servicios ajenos al propio
   *SystemD*. Por ejemplo, el demonio :command:`sshd` que habilita el servidor
   :ref:`SSH <ssh>` puede gestionarse de este modo, puesto que es un servicio
   que gestiona, pero no implementa, *SystemD*. Sin embargo, los servicios
   propios de *SystemD* no hay otra forma de manipularlos que a través de las
   herramientas de *SystemD*.

.. [#] A los cuales habría que añadir la monitorización, de la que también se
   encarga *SystemD*, pero que se trata en bajo :ref:`un epígrafe posterior
   <journalctl>`.

.. [#] En realidad, las herramientas gestionan en paralelo ambos sistemas, ya
   que en *Debian* puede seguirse instalando *SystemV*.
