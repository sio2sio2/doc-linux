Ejercicios sobre compresión y empaquetado
=========================================

#. Crear la siguiente estructura de directorios dentro
   del directorio temporal::

     DIR
      |
      +--- DIRA
      |     |
      |     +--- D1
      |     +--- D2
      |     +--- D3
      +--- DIRB
            +--- Da
            +--- Db

   del modo más conciso posible.

#. Crear los fichero vacíos:
      
   - f1.txt dentro de D1
   - f2.vacio dentro de D3
   - f.zip dentro DIR
   - f3.xxx dentro de Da

#. Copiar el contenido de :file:`/etc/services` en :file:`Db/services`.

#. Comprimir en formato *gzip* y nivel de compresión 8 el fichero
   :file:`Db/services`.

#. Descomprimir el fichero anterior dentro de :file:`D2` poniéndole de nombre
   :file:`copia.services`.

#. Empaquetar (sin comprimir) todo el árbol anterior en el fichero
   :file:`paquete.tar`.

7. Empaquetar comprimiendo con :program:`xz` todo el árbol de directorios
   anterior:

   a) Usando la opción adecuado de tar.
   b) Pasándole el paquete al propio "xz" (y aproveche para que el nivel
      de compresión sea 9)

8. Listar el contenido del paquete anterior.


9. Obtener del paquete anterior el fichero :file:`copia.services` y dejarlo en el
   directorio actual de trabajo.


10. Empaquetar comprimiendo con :program:`gzip` el árbol de directorios
    anterior, pero excluir del paquete los ficheros :file:`services` (todos) y
    :file:`f3.xxx`.

