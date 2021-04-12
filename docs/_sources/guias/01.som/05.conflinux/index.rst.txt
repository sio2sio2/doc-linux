.. _som-conflinux:

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

#. Revisaremos primeramente algunos aspectos de configuración básica usando un
   entorno gráfico.
#. A continuación, trataremos casi todos los aspectos de configuración básica
   utilizando la |CLI|.
#. En :ref:`la siguiente unidad  <som-admlinux>` trataremos los aspectos de
   administración utilizando también la interfaz de texto.

para lo cual usaramos lo siguiente:

- Para el sistema con entorno gráfico una *Ubuntu* normal, esto es, la que
  viene con GNOME.
- Para la interfaz de texto, una terminal de la propia *Ubuntu* o, simplemente,
  una *Debian* cuyas diferencias con la primera al nivel en que nos movemos son
  dos: la gestión de la red (a partir de Ubuntu *18.04*) y la escalada de
  privilegios.

Entorno gráfico
===============
Ya se ha explicado que *Linux* dispone de múltiples entornos gráficos que se
utilizan según sea la distribución que se escoja. Hay, no obstante, diversos
términos que se usan al tratar sobre ellos y es conveniente conocerlos.

Terminología
------------
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

Descripción de GNOME_
---------------------
Describir las posibilidades del entorno de GNOME tal como se hice con el
entorno de *Windows*.

Configuración de la red
-----------------------
Tratar :program:`NetworkManager` para configurar la red de forma gráfica.

Explorador de archivos
----------------------
+ Introducir muy por encima la estructura jerárquica de los sistemas *UNIX* (se
  profundizará en la siguiente unidad).
+ Uso del explorador.

Interfaz |CLI|
==============
Desarrollado en el :ref:`epígrafe sobre entorno de texto <cli>`.

Configuración de red
====================
Para interfaz de texto puede usarse el epígrafe de :ref:`configuración mínima de
la red <redminima>`.

* :ref:`ej-redmin`

Sistema de archivos
===================
Desarrollado en los epígrafes que componen:

* :ref:`filesystem`
* :ref:`fic-dir`

aunque es conveniente no dar en tanta profundidad :ref:`find <find>`. Para esta
orden basta con limitarse al uso::

   # find /ruta [-type f|l|d] -iname "nombre-con-comodines"

Dentro de este apartado hay dos relaciones de ejercicios pertinentes:

* :ref:`ej-rutas`
* :ref:`ej-fic`

Órdenes avanzadas
=================
El epígrafe está dedicado a como construir órdenes más complejas en la |CLI|.

Concatenación de órdenes
------------------------
En este apartado toca aprender :ref:`cómo concatenar varias órdenes dentro de
una misma línea <sh-concat>` y cuáles son las :ref:`substituciones en línea
<sh-interp-cl>` que hace la *shell* antes de ejecutar de modo efectivo la
orden. Los conocimientos pueden ponerse a prueba con los ejercicios:

* :ref:`Ejercicios sobre expansiones <ej-exp>`.

Redirecciones de |E/S|
----------------------
Respecto al concepto de :ref:`redirección <ioredirect>` basta con centrarse en
el apartado de :ref:`redirección básica <ioredirect-bas>` **sin** antender a los
conceptos de :ref:`tuberías con nombre <mkfifo>` ni :ref:`process substitution
<bash-process-substitution>`. Es importante los conceptos incluidos en este
apartado porque es la herramienta básica para hacer cooperar las órdenes entre
sí y lograr órdenes conjuntas muy poderosas. Entendidas bien estas ideas,
realice los ejercicios:

* :ref:`Ejercicios sobre redirecciones <ej-redirect>`.

Tratamiento de texto
--------------------
Para este contenido hay desarrollado :ref:`todo un epígrafe en los apuntes
<bash-texto>`, pero la parte dedicada a :ref:`expresiones regulares <regex>` es
denasiado extensa para el nivel de primero del grado medio, por lo que lo
sustituiremos por el siguiente resumen:

#. Generalidades:

   - Las :dfn:`expresiones regulares` son patrones capaces de concordar con
     múltiples cadenas de texto y que se usan para hacer búsquedas con o sin
     substitución dentro de un texto. Por ejemplo, la expresión ':kbd:`^a`'
     significa cualquier texto que empiece por "a".

   - Lo habitual es que las herramientas hagan la búsqueda línea por línea, esto
     es:

     a. Tomen la primera línea del texto.
     #. Comprueben si se encuentra el patrón en la línea.
     #. Informen de la búsqueda.
     #. Pase a la siguiente línea y así sucesivamente hasta que acabe el archivo.

     En consecuencia, la expresión de ejemplo ':kbd:`^a`' concordará con todas
     las líneas que empiecen por "a", ya que cada línea se considera un texto
     diferente.

   - Hay distintos tipos de expresiones regulares, así que nos centraremos en
     las expresiones regulares |ERE| para la que tienen soporte total o parcial
     casi todas las órdenes con la gran excepción de :ref:`expr <expr>`.

   - No deben confundirse las expresiones regulares con los comodines de la
     *shell*, aunque en algunos casos puedan tener un uso confusamente similar.

   - Por lo general, la herramienta no fuerza a que el patrón concuerde con la
     línea completa, sino que basta con que lo haga con una parte. Por ese
     motivo, las expresión ':kbd:`a`' concuerda con cualquier línea que contenga
     una "a" y no sólo con las líneas cuyo contenido es exclusivamente una sola
     "a".

#. Recetario

   .. table::
      :class: mini-regex

      +-----------+-----------------------------------------------------+
      | Expresión | Descripción                                         |
      +===========+=====================================================+
      | Comodines                                                       |
      +-----------+-----------------------------------------------------+
      | .         | Cualquier carácter                                  |
      +-----------+-----------------------------------------------------+
      | Delimitadores                                                   |
      +-----------+-----------------------------------------------------+
      | ^         | Comienzo del texto                                  |
      +-----------+-----------------------------------------------------+
      | $         | Final del texto                                     |
      +-----------+-----------------------------------------------------+
      | \b        | Comienzo o final de palabra                         |
      +-----------+-----------------------------------------------------+
      | Cuantificadores                                                 |
      +-----------+-----------------------------------------------------+
      | ?         | Una o ningna vez lo expresado anteriormente         |
      +-----------+-----------------------------------------------------+
      | \*        | 0 o más veces lo expresado anteriormente            |
      +-----------+-----------------------------------------------------+
      | \+        | 1 o más veces lo expresado anteriormente            |
      +-----------+-----------------------------------------------------+
      | {x}       | X veces lo expresado anteriormente                  |
      +-----------+-----------------------------------------------------+
      | {X,Y}     | Entre X e Y veces los expresado anteriormente       |
      +-----------+-----------------------------------------------------+
      | Agrupadores                                                     |
      +-----------+-----------------------------------------------------+
      | \(...\)   | Agrupa una parte de la regex                        |
      +-----------+-----------------------------------------------------+
      | Opcionales                                                      |
      +-----------+-----------------------------------------------------+
      | a\|b      | Una de las dos expresiones ("a" o "b").             |
      +-----------+-----------------------------------------------------+
      | [...]     | Cualquiera de los caracteres incluidos dentro.      |
      +-----------+-----------------------------------------------------+
      | [^...]    | Ninguno de los caracteres incluidos dentro.         |
      +-----------+-----------------------------------------------------+

#. Ejemplos.

   Indicar las expresiones regulares que concuerden con texto que:

   i. acabe en "a":

      .. code-block:: none

         a$

   #. acabe en "s" o "n":

      .. code-block:: none

         [sn]$

   #. contenga al menos una palabra que empiece por "e":

      .. code-block:: none

         \be

   #. contenga "hola":

      .. code-block:: none

         hola

   #. contenga la palabra "hola":

      .. code-block:: none

         \bhola\b

   #. contenga exclusivamente "hola":

      .. code-block:: none

         ^hola$

   #. esté vacío (no contenga nada):

      .. code-block:: none

         ^$

   #. sólo contenga letras "b":

      .. code-block:: none

         ^b+$

   #. empiece por "a" y acabe en "b":

      .. code-block:: none

         ^a.*b$

   #. contenga la la palabra "hola" o "adios":

      .. code-block:: none

         \b(hola|adios)\b

   #. no empiece por "a":

      .. code-block:: none

         ^[^a]

.. note:: Para probar que funcionan las expresiones de arriba, lo más sencillo
   es utilizar :ref:`grep <grep>`. Por ejemplo, para ver las líneas de fichero
   :file:`/tmp/mifichero.txt` que acaban en "a" debemos hacer::

      # grep -E 'a$' /tmp/mifichero.txt

Los epígrafes sobre :ref:`herramientas de búsqueda <texto-busqueda>` y :ref:`de
manipulación <texto-manipulación>` sí son pertinentes. Para practicar las
herramientas de manipulación de texto y las expresiones regulares intente la
relación:

* :ref:`ej-texto`

.. |CLI| replace:: :abbr:`CLI (Command Line Interface)`
.. |E/S| replace:: :abbr:`E/S (Entrada/Salida)`
.. |ERE| replace:: :abbr:`ERE (Extended Regular Expresions)`

.. rubric:: Notas al pie

.. [#] En el :ref:`epígrafe dedicado a las interfaces GUI <ssoo-gui>` confiesa
   el autor cuál es su entorno gráfico y se basa en esta última solución.

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
