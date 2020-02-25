Ejercicios sobre manipulación de ficheros
-----------------------------------------

.. note:: Especifique convenientemente si usa el administrador o no.

a. Lleve a cabo las siguienes tareas:

   #. Crear un fichero vacío llamado :file:`estoy.en.blanco` dentro del directorio
      personal del usuario.

   #. Hacer una copia de este fichero en el directorio temporal con nombre
      :file:`sigo.en.blanco`. Use rutas relativas tanto para el origen como para
      el destino.

   #. Hacer un enlace duro en el directorio temporal conservando el nombre.
      ¿Es posible en el sistema en que está trabajando? ¿Por qué?

   #. Crear la siguiente estructura de directorios:

      .. code-block:: none

         /tmp
           +---- DIR1
           |      +------ DIR11
           |      +------ DIR12
           +---- DIR2
           +---- DIR3
             +------ DIR31
             +------ DIR32
             +------ DIR33

   #. Cambiar al directorio temporal usando ruta absoluta.

   #. Mover :file:`sigo.en.blanco` al directorio :file:`DIR33`.

   #. Manteniendo el mismo nombre, hacer un enlace simbólico a
      :file:`sigo.en.blanco` en el directorio personal

   #. Mover el directorio :file:`DIR33` dentro de :file:`DIR12`.

   #. Copiar todo el árbol que cuelga de :file:`DIR1` dentro de :file:`DIR32`.

   #. Borrar todo lo que se ha hecho.

#. Haga esta otra tanda de ejercicios, sabiendo que comienza a hacerlos estando
   en su directorio personal:

   #. Consulte el contenido de :file:`/usr/sbin` usando ruta relativa.

   #. Encuentre los ficheros de extensión :file:`.txt.gz` contenidos dentro
      de la parte del árbol de directorios que cualga de :file:`/usr/share/doc`.

   #. Entre en el directorio temporal usando ruta relativa.

   #. Consulte cuáles son los permisos del directorio raíz. Utilice ruta
      relativa y dos órdenes distintas.

   #. Cree la siguiente estructura de archivos (vacíos) y directorios:

      .. code-block:: none

         + /tmp
             +--- dirA
             |     +-- fichero1.txt
             |     +-- dirAA
             |     |     +-- fichero2.txt
             |     |     +-- fichero3.txt
             |     |
             |     +-- dirAB
             |     +-- dirAC
             |           +-- fichero4.txt
             +--- dirB

   #. Mueva :file:`dirAA` dentro de :file:`dirB`.

   #. Buscar todos los ficheros de texto plano (extensión :file:`.txt`)
      contenidos en el directorio temporal.
             
   #, Hacer en enlace duro dentro de :file:`dirAB` del archivo
      :file:`fichero3.txt`.

   #. Hacer un enlace simbólico en :file:`dirB` de :file:`fichero1.txt` y llamar
      a dicho enlace :file:`unfichero.txt`.

   #. Borrar todo lo creado.
