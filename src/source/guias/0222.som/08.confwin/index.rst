.. _som-confwin:

Configuración básica de *Windows* 10
************************************

.. note:: El contenido del tema es sólo una sucesión de aspectos a tratar.

Descripción del entorno de trabajo
==================================
+ Pantalla de inicio (:ref:`Práctica 1 <p5.1>`).
+ Barra de tareas.
+ Menú de inicio (:ref:`Práctica 2 <p5.2>`).
+ Temas y aspecto (:ref:`Práctica 2 <p5.2>`): resolución, monitores, etc.
+ Cambios de fecha e idioma.

Gestión del software
====================
+ Actualizaciones del propio sistema operativo: cuál es la política de
  actualizaciones, cómo se llevan a cabo.
+ Adición de características de *Windows*.
+ Instalación y desinstalación de aplicaciones a través de la tienda de
  *Microsoft*.
+ Instalación y desinstalación de programas obtenidos en la web.

Configuración de la red
=======================
Simplemente, se trata de configurar el protocolo |TCP|/|IP| para conectar a la
red (:ref:`Práctica 4e <p5.4>`).

Explorador de archivos
======================
+ Estructura de directorios (:ref:`Práctica 3 <p5.4>`).
+ Extensiones de los archivos: asociación a programas (:ref:`Práctica 4b
  <p5.4>`), visualización de todas las extensiones (:ref:`Práctica 3e <p5.3>`).

Recuperación del sistema
========================
Puntos de restauración
----------------------
*Windows* 10 permite crear puntos de restauración de sistema operativo (no del
sistema de archivos, para lo cual tendríamos que crear copias de seguridad) a
través del programa :program:`SystemPropertiesProtection.exe`, accesible desde
las "Propiedades>Protección del sistema" de "Este Equipo" o la sección
"Seguridad y mantenimiento" del "Panel de Control". La creación de estos puntos
exige primero habilitar la posibilidad reservando una cantidad de espacio en
disco para ello.

.. seealso:: Puede consultar `este artículo de genbeta.com sobre restauración
   <https://www.genbeta.com/paso-a-paso/como-crear-punto-restauracion-windows-10>`_.

Copias de seguridad
-------------------

Automatización de tareas
========================
Para programar tareas futuras, periódicas o que deben ejecutarse al producirse
alguna circunstancia (p.e. al iniciar sesión), debe utilizarse el
:program:`Programador de tareas` accesible a través de las "Herramientas
administrativas".

.. image:: files/programador.png

Crear una *tarea básica* es relativamente sencillo (puede consultar `este enlace
de genbeta sobre cómo programar tareas en Windows 10
<https://www.genbeta.com/paso-a-paso/como-programar-tareas-en-windows-10>`_).
La lista de tareas definidas por el usuario pueden consultarse en la
sección "Biblioteca del Programador de tareas", aunque, si no aparece, habrá que
actualizar la vista con el menú contextual (:ref:`Práctica 5a <p5.5>`).

Por otra parte, en el :program:`Administrador de tareas` hay una pestaña para
indicar qué aplicaciones quieren arrancarse durante el inicio (:ref:`Práctica 5b
<p5.5>`).

.. include:: /guias/0222.som/99.ejercicios/05.winI.rst

.. |TCP| replace:: :abbr:`TCP (Transmission Control Protocol)`
