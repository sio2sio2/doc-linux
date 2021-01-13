.. _som-prolinux:

Profundización en linux
***********************
El tema recoge otros aspectos a tener en cuenta cuando se desea manejar
con soltura y eficacia *Linux* a través de la |CLI| más allá de los elementales
expuestos en el :ref:`uso básico <som-conflinux>`.

Órdenes avanzadas
=================
En este apartado toca aprender :ref:`cómo concatenar varias órdenes dentro de
una misma línea <sh-concat>` y cuáles son las :ref:`substituciones en línea
<sh-interp-cl>` que hace la *shell* antes de ejecutar de modo efectivo la
orden. Los conocimientos pueden ponerse a prueba con los ejercicios:

* :ref:`Ejercicios sobre expansiones <ej-exp>`.

Redirecciones de |E/S|
======================
Respecto al concepto de :ref:`redirección <ioredirect>` basta con centrarse en
el apartado de :ref:`redirección básica <ioredirect-bas>` **sin** antender a los
conceptos de :ref:`tuberías con nombre <mkfifo>` ni :ref:`process substitution
<bash-process-substitution>`. Es importante los conceptos incluidos en este
apartado porque es la herramienta básica para hacer cooperar las órdenes entre
sí y lograr órdenes conjuntas muy poderosas. Entendidas bien estas ideas,
realice los ejercicios:

* :ref:`Ejercicios sobre redirecciones <ej-redirect>`.

Copias de seguridad
===================
El epígrafe persigue cónocer cuáles son herramientas habituales de compresión y
empaquetado, lo cual supone estudiar todo este epígrafe de :ref:`copias de
seguridad <backup-simple>`. La relación de ejericios es la que se encuentra al
final de ese epigrafe:

* :ref:`Ejercicios sobre compresión y empaquetado <ej-compr-paq>`.

Tratamiento de texto
====================
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

Planificación de tareas
========================
Estudiaremos este aspecto sólo haciendo uso del :ref:`método clásico <cronat>`
con :command:`at` y :program:`crontab`. La relación de ejercicios
correspondiente es ésta:

* :ref:`ej-cronat`

Escalada de privilegios
=======================
Hay :ref:`un epígrafe dedicado a esta tarea <escalar-priv>`, pero para nuestro
nivel sólo requiere una lectura superficial que no implique llegar a saber cómo
se configura :ref:`sudo <sudo>`, sino simplemente:

- Entender que hay distribuciones que usan preferentemente :ref:`su <su>` y
  otras preferentemente :ref:`sudo <sudo>`.

- Que :ref:`su <su>` suele usarse para abrir una sesión interactiva dentro de la
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

- Que en las distribuciones que configuran en la instalación :ref:`sudo <sudo>`,
  la configuración está pensada para que el usuario lo utilice como "prefijo"
  antes de la orden que requiere privilegios. Se le pedirá la contraseña del
  propio usuario sin privilegios, no la del administrador, la cual no existe::

   $ whoami
   usuario
   $ sudo apt upgrade
   $ sudo apt update
   $ whoami
   usuario

No se requiere hacer ninguna relación de ejercicios.

.. |CLI| replace:: :abbr:`CLI (Command Line Interface)`
.. |E/S| replace:: :abbr:`E/S (Entrada/Salida)`
.. |ERE| replace:: :abbr:`ERE (Extended Regular Expresions)`
