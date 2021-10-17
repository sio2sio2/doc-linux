Ejercicios sobre permisos
-------------------------
.. note:: Es obligatorio usar el usuario sin privilegios si para hacer el
   ejetcicio concreto no es necesario ser administrador.

#. Mejorar la privacidad de nuestro usuario para que
   solamente él pueda ver los archivos contenidos en su espacio personal.

#. Volver a dejar el directorio personal como estaba y crear dentro un
   subdirectorio al que no puedan acceder los usuarios que no pertenezca a mi
   grupo principal.

#. Crear un directorio propiedad de *root* al que solo puedan acceder
   los usuarios del grupo "netdev" (además del propio *root*).

#. Crear un directorio :file:`D`, dentro un fichero :file:`f` y permitir que
   todos puedan ver el contenido del fichero :file:`f`, pero impedir que alguien
   (incluido uno mismo) lo pueda borrar.

#. Cambiar el grupo del directorio :file:`D` a *plugdev*. ¿Es posible? ¿Y a
   *disk*? ¿Por qué?

#. Hacer que de forma predeterminada cada vez que creo un archivo sólo yo pueda
   leerlo.

#. Supongamos que creo el siguiente script en mi directorio personal:

   .. code-block:: bash

      #!/bin/sh

      rm /home/usuario -rf

   Lo guardo con el nombre de :file:`limpiar.sh` en mi directorio personal y le
   doy los siguientes permisos::

      $ chmod 4755 limpiar.sh

   ¿Qué implicaciones tiene lo que he hecho?

#. Supongamos que creamos un directorio :file:`/srv/ftp` al que queremos
   que todos los usuarios por |FTP| puedan subir ficheros, pero no queremos que
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

   a) Resuélvase de forma expeditiva (solución sencilla)
   #) Resuélvase de forma que se pretenda dar envidia, es decir, los
      usuarios que no son mis amigos. podrán ver que tengo fotos y cuáles
      son ("Viaje a las islas griegas", "Yo en Cancún"), pero no abrirlas.

      .. note:: O sea, mire lo que ocurre en un sistema bien resuelto de esta
         segunda forma:::

            $ ls -l /tmp/Fotos
            ls: no se puede acceder a '/tmp/Fotos/MiFotoEnElCaribe.jpg': Permiso denegado
            ls: no se puede acceder a '/tmp/Fotos/ZanganeandoEnMadagascar.jpg': Permiso denegado
            ls: no se puede acceder a '/tmp/Fotos/EscalandoElHimalaya.jpg': Permiso denegado
            total 0
            -????????? ? ? ? ?            ? EscalandoElHimalaya.jpg
            -????????? ? ? ? ?            ? MiFotoEnElCaribe.jpg
            -????????? ? ? ? ?            ? ZanganeandoEnMadagascar.jpg

         Y si prueba a copiar alguna foto fuera del directorio, verá que es
         imposible.
