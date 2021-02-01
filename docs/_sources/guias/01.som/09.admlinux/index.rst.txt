.. _som-admlinux:

Administración básica de *Linux*
********************************
Los aspectos básicos de administración de sistemas *Linux* que incluiremos
dentro de esta unidad de trabajo son:

Gestión de usuarios
===================
Incluye lo desarrollado en :ref:`el epígrafe homónimo <gesusu>` y los
ejercicios:

* :ref:`ej-usu`

Además, es necesario como escalar privilegios. En el manual hay :ref:`un
epígrafe dedicado a esta tarea <escalar-priv>`, pero para nuestro nivel se
requiere saber cómo configurar :ref:`sudo <sudo>`, sino simplemente:

- entender que hay distribuciones que usan preferentemente :ref:`su <su>` y
  otras preferentemente :ref:`sudo <sudo>`.

- que :ref:`su <su>` suele usarse para abrir una sesión interactiva dentro de la
  cual llevar a cabo las instrucciones propias del administrador. La constraseña
  para su uso es la del adminsitrador. Por ejemplo::

   $ whoami
   usuario
   $ su -
   # whoami
   root
   # apt upgrade
   # apt update
   # exit
   $ whoami
   usuario

- que en las distribuciones que configuran en la instalación :ref:`sudo <sudo>`,
  la configuración está pensada para que el usuario lo utilice como "prefijo"
  antes de la orden que requiere privilegios. Se le pedirá la contraseña del
  propio usuario sin privilegios, no la del administrador, la cual no existe::

   $ whoami
   usuario
   $ sudo apt upgrade
   $ sudo apt update
   $ whoami
   usuario

Seguridad
=========

Permisos
--------
Se tratara el :ref:`sistema de permisos POSIX <ugo>` para el cual existe la
relación de ejercicios:

* :ref:`ej-perm`

Monitorización
==============

Gestión de procesos
===================
Comprende el contenido del epígrafe sobre :ref:`gestión de procesos <procesos>`
y la relación de ejercicios:

* :ref:`ej-procesos`

Gestión de recursos
===================
Hardware
--------
Para conocer el *hardware* del que dispone nuestra máquina, existen algunas
órdenes explicadas en el :ref:`epígrafe sobre análisis de hardware <hardware>`.

Discos
------
Su contenido es el incluido en el :ref:`epígrafe sobre dispositivos
<dispositivos>` tras cuya lectura puede realizarse esta relación de ejericios:

* :ref:`ej-dev`

Impresoras
----------
La impresión en *Linux* se controla a través del servidor :program:`cups`, el
cual puede configurarse mediante |CLI| tal como se explica en :ref:`el epígrafe
del manual dedicado a la impresión <cups>`. A este nivel, no obtante, es
preferible la enseñanza mediante la interfaz web que proporciona :program:`cups`
en el puerto **631**.

Compartición de recursos
------------------------

.. |CLI| replace:: :abbr:`CLI (Command Line Interface)`
