Ejercicios sobre permisos
-------------------------

#. Mejorar la privacidad de nuestro usuario para que
   solamente él pueda ver sus ficheros personales.
   Nota: se supone que no tiene nada fuera de su espacio personal.


#. Crear un directorio al que no puedan acceder los usuarios
   que no pertenezca a mi grupo principal.


#. Crear un directorio propiedad de root al que solo puedan acceder
   los usuarios del grupo "netdev".


#. Crear un directorio D, un fichero f y permitir que todos puedan ver
   el contenido del fichero f, pero impedir que alguien (incluido uno
   mismo) lo pueda borrar.


#. Cambiar el grupo del directorio D a plugdev. ¿Es posible? ¿Y a disk?


#. Hacer que de forma predeterminada sólo yo pueda leer los ficheros
   que creo.

#. Supongamos que creo el siguiente script en mi directorio personal::

      #!/bin/sh

      rm /home/usuario -rf

   Lo guardo con el nombre de :file:`limpiar.sh` en mi directorio personal y le
   doy los siguientes permisos::

      $ chmod 4755 limpiar.sh

   ¿Qué implicaciones tiene lo que he hecho?

#. Supongamos que creamos un directorio :file:`/srv/ftp` al que queremos
   que todos los usuarios por FTP puedan subir ficheros, pero no queremos que
   unos usuarios borren o modifiquen lo que pertenecen a los demás, ¿qué podemos
   hacer?


#. Tomando el caso anterior, supongamos que el directorio es para que
   los estudiantes suban sus trabajos y los profesores puedan
   corregirlos. En esta circunstancia, además, de que unos estudiantes
   no puedan alterar o borrar los trabajos de los demás, queremos que
   no se puedan copiar, ¿cómo lo logramos? Búsquense posibles soluciones

#. Supongamos que tengo un directorio llamado :file:`Fotos` cuyo contenido (incluido
   subdirectorios) solo quiero que sea accesible por mi grupo de amigos. Para
   ello, el administrador ha creado el grupo *amigos_usuario* y me ha metido
   a mí y a mis amigos dentro. ¿Cómo lo hago?

   #) Resuélvase de forma expeditiva (solución sencilla)
   #) Resuélvase de forma que se pretenda dar envidia, es decir, los
      usuarios que no son mis amigos. podrán ver que tengo fotos y cuáles
      son ("Viaje a las islas griegas", "Yo en Cancún"), pero no abrirlas.
