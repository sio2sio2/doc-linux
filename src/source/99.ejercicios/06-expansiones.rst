Ejercicios sobre expansiones
============================

#. Crear el fichero vacio :file:`captura$1.jpg`.

#. Desde el directorio peronal y Utilizando expansiones, crear el siguiente
   árbol de directorios de la manera más corta posible:

   .. code-block:: none

      /tmp
        |
        +-- D1
        |    +-- D1a
        |    +-- D1b
        |    +-- D1c
        +-- D2
        |    +-- D21
        |    +-- D22
        |    +-- D23
        |    +-- D24
        |    +-- D25
        +-- DIR3

#. Sin cambiar de directorio de trabajo, borrar los directorios :file:`D23` y
   :file:`D25` (hágalo del modo más corto posible).

#. Mostrar por pantalla los directorios hijos de :file:`/` que contengan la
   cadena «*bin*» en cualquier parte de su nombre.

#. Mostrar los programas propios del administrador que contengan tres caracteres.

   .. note:: En los modernos sistemas *Debian* :file:`/sbin` y :file:`/usr/sbin`
      contienen lo mismo.

#. Mostrar los programas propios del administrador que contengan al menos tres
   caracteres.

#. Mostrar los programas propios del administrador que empiecen por «*a*» y
   acaben por cualquier vocal.

#. Mostrar los programas propios del administrador que empiecen por vocal y
   acaben por vocal.

#. Mostrar por pantalla todas las combinaciones con repetición que se pueden
   formar con dos vocales.

#. Suponiendo que no se hayan creado usuarios con directorios personales en
   sitios extraños, ver los directorios personales de usuarios cuyo nombre
   empieza por "u".

#. Comprobar cuántos dispositivos de almacenamiento (discos, memorias usb, ...)
   hay en el sistema.
   
#. Comprobar cuáles son las páginas de manual en español de la primera sección
   que empiezan por la letra «*m*».

   .. note:: No intente resolver este  ejercicio (ni los que hay a continuación)
      directamente con la orden :ref:`man <man>` (p.e. :code:`man -s1 -Les -w
      --wildcard --names-only 'm*'`), porque además de que :command:`man` no
      restringe su búsqueda al idioma (siempre busca también en las de inglés
      americano), la intención es que con :ref:`ls <ls>` utilice comodines en las
      rutas para obtener los archivos de esas páginas.

#. Lo mismo, pero en cualquier sección.

#. Lo mismo, pero en cualquier sección y lengua.

#. ¿Cuántos kernel de linux distintos hay instalados en el sistema?
    
   .. note:: Pruebe a buscarlos en el sistema de archivos; no use el gestor de paquetes.
