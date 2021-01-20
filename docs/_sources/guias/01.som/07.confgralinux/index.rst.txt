.. _som-confgralinux:

Configuración básica de *Linux*
*******************************
El estudio de *Linux* es radicalmente distinto al de *Windows* 10, por dos
motivos: 

#. así como *Windows* está pensado para ser utilizado y administrado en sus
   aspectos menos avanzados a través de una interfaz gráfica y sólo una
   administración que se escapa a los propósitos de este módulo requiere el uso
   de una interfaz |CLI|, *Linux* es todo lo contrario: está pensado para ser
   gestionado y administrado a través de la línea de órdenes, por lo que no
   todos los aspectos básicos tienen un modo gráfico de gestionarse o, aunque lo
   tengan, puede ser precario.

#. *Linux* es un ecosistema muy variado de *software*, lo cual incluye también
   el entorno gráfico: hay multitud de de entornos gráficos distintos entre sí y
   que ofrecen herramientas gráficas para gestionar aspectos de la configuración
   o administración que son distintas entre sí. Por lo general, las
   distribuciones suelen decantarse por uno de ellos (véase el `gráfico de
   Alphanse Eylenburg
   <https://maps-and-tables.blogspot.com/2020/05/standard-desktop-environments-for-linux.html>`_),
   aunque permiten instalar otro distinto. Incluso hay distribuciones, como el
   caso de *Ubuntu* que tienen distintos sabores según se haya decidido usar uno
   u otro entorno gráfico como el predeterminado:

   ============ =========
   Ubuntu        GNOME
   Xubuntu       XFCE
   Kubuntu       KDE
   Lubuntu       LDE
   ============ =========

Así pues, al nivel en que nos movemos, aunque se puede prescindir
completamente de la |CLI| de *Windows* (:program:`cmd` o mejor aún la más nueva
y potente :program:`PowerShell`) en *Linux* eso es imposible y, además,
inapropiado, ya que lo que pudiéramos aprender a configurar al cambiar de
entorno gráfico podría tener que hacerse de un modo completamente distinto. La configuración y administración mediante |CLI|, en cambio, es más universal ya que suelen cambiar únicamente aspectos implementados por la propia distribución como la gestión de *software*.

En consecuencia, nuestro plan de estudios será el siguiente:

#. Revisaremos en esta unidad algunos aspectos de configuración básica usando un
   entorno gráfico.
#. En :ref:`la siguiente <som-conflinux>`, trataremos casi todos los aspectos de
   configuración utilizando la |CLI|.
#. En :ref:`la tercera  <som-admlinux>` trataremos los aspectos de
   administración utilizando también la interfaz de texto.
#. :ref:`La última unidad <som-prolinux>` se centrará en algunos aspectos algo
   más avanzados de uso y que pueden mejorar nuestra productividad.

para lo cual usaramos lo siguiente:

- Para el sistema con entorno gráfico una *Ubuntu* normal, esto es, la que
  viene con GNOME.
- Para la interfaz de texto, una terminal de la propia *Ubuntu* o, simplemente,
  una *Debian* cuyas diferencias con la primera al nivel en que nos movemos son
  dos: la gestión de la red (a partir de Ubuntu *18.04*) y la escalada de
  privilegios.

Entornos gráficos
=================
Ya se ha explicado que *Linux* dispone de múltiples entornos gráficos que se
utilizan según sea la distribución que se escoja. Hay, no obstante, diversos
términos que se usan al tratar sobre ellos:

**Servidor gráfico**
   Es la parte encargada de interactuar con los dispositivos de entrada y salida
   como el ratón o la pantalla. En *Linux* el servidor de ventanas más utilizado
   es el denominado *Sistema de ventanas X* (*X-Window System*, en inglés), muy
   comúmente llamado simplemente "*las X*". Hay diversas implementaciones de
   este servidor, pero el usado en prácticamente todas las distribuciones
   modernas de *Linux* es X.Org_.

   Otro servidor gráfico es Wayland_, más moderno y eficiente que el anterior y
   que guarda compatibilidad con las aplicaciones escritas para *X*. Algunas
   distribuciones como *Red Hat* o *Debian* lo usan ya por defecto. Es
   previsible que acabe en un futuro sustituyendo por completo a las *X*, aunque
   la migración sea lenta.

   En cualquier caso, el servidor es una capa que pasa inadvertida para el
   usuario, ya que no interactúa con él.

**Gestor de ventanas**
   Es el *software* encargado de controlar la gestión, la ubicación y el aspecto
   de las ventanas. Actúa, pues, por encima del servidor gráfico. En *Linux* hay
   infinidad de gestores de ventanas más o menos usados, entre ellos:

   + Openbox_
   + Fluxbox_
   + Enlightment_
   + FVWM_

**Escritorio**
   Un entorno de escritorio es una solución gráfica completa que proporciona no
   solamente un modo de gestionar las ventanas, sino también las utilizades
   gráficas más socorridas (iconos de escritorio, barra de tareas, explorador de
   archivos, gestión de pantalla y monitores, gestión de red, gestión de
   volúmnes, etc.). Los
   principales escritorios en *Linux* son:

   + GNOME_.
   + KDE_.
   + XFCE_.
   + LXDE_.

Lo habitual es que los usuarios finales de *Linux* utilicen un entorno de
escritorio integrado (como GNOME_), pero no son raros los que optan por
un gestor de ventanas al que añaden algunas utilidades gráficas\ [#]_.

Descripción del entorno gráfico
===============================
Describir las posibilidades del entorno de GNOME tal como se hice con el
entorno de *Windows*.

Configuración de la red
=======================
Tratar :program:`NetworkManager` para configurar la red de forma gráfica.

Explorador de archivos
======================
+ Introducir muy por encima la estructura jerárquica de los sistemas *UNIX* (se
  profundizará en la siguiente unidad).
+ Uso del explorador.

.. rubric:: Notas al pie

.. [#] En el :ref:`epígrafe dedicado a las interfaces GUI <ssoo-gui>` confiesa
   el autor cuál es su entorno gráfico y se basa en esta última solución.

.. |CLI| replace:: :abbr:`CLI (Command Line Interface)`

.. _Gparted: https://gparted.org/
.. _X.Org: https://es.wikipedia.org/wiki/X.Org_Server
.. _Wayland: https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)
.. _Enlightment: https://www.enlightenment.org/
.. _Openbox: http://openbox.org/wiki/Main_Page
.. _Fluxbox: http://www.fluxbox.org/
.. _FVWM: https://github.com/fvwmorg/fvwm
.. _GNOME: http://gnome.org/
.. _KDE: https://kde.org/
.. _LXDE: http://www.lxde.org/
.. _XFCE: https://www.xfce.org/
