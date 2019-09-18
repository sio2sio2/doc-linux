Ejercicios sobre manipulación de ficheros
-----------------------------------------

.. note:: Especifique convenientemente si usa el administrador o no.

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

6. Mover :file:`sigo.en.blanco` al directorio :file:`DIR33`.

7. Manteniendo el mismo nombre, hacer un enlace simbólico a
   :file:`sigo.en.blanco` en el directorio personal

8. Mover el directorio :file:`DIR33` dentro de :file:`DIR12`.

9. Copiar todo el árbol que cuelga de :file:`DIR1` dentro de :file:`DIR32`.

10. Borrar todo lo que se ha hecho.
