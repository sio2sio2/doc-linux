Ejercicios sobre usuarios y permisos
------------------------------------
#. Crear un usuario llamado moises y obligarle a cambiar la contraseña en el
   primer ingreso.

#. Evitar que cualquier otro usuario pueda espiar el directorio personal de
   moises. ¿Puede hacer el propio moises?

#. Crear un usuario llamado "sara" cuyo grupo prinicpal sea "users". Comprobar,
   además, que este grupo ya existe.

#. Crear un usuario del sistema (o sea, un usuario que no representan a una
   persona física) llamado "ftp". Su directorio personal debe ser /srv/ftp.

#. Hacer que "sara" cree un subdirectorio dentro de su directorio personal
   en el que otros usuarios puedan dejar ficheros, pero que unos usuarios no
   puedan borrar los ficheros dejados por otro.

#. Crear con moises un directorio llamado "PRUEBA" dentro del directorio
   temporal. Intente hacer con moises que el grupo propietario de este
   directorio sea "www-data". ¿Es posible? Justifique la respuesta.

#. Impedir que "sara" pueda acceder al sistema.

#. Escriba en un fichero llamado "script.sh" el siguiente contenido:

   .. code-block:: bash

      #!/bin/sh

      echo "Hola, mundo!!!!"

   a. Permita que se pueda ejecutar.
   #. Ejecútelo.

#. ¿Cuál es el equivalente numérico a los permisos :kbd:`r-xrwxr-x`? ¿Cuál es la
   máscara que debe definirse para que los ficheros de los usuarios se creen con
   permisos :kbd:`rw-------`?

#. Un dispositivo se configura a través de su puerto serie (representando por
   :file:`/dev/ttyS0` en los sistemas *Linux*), por lo que se conecta mediante
   cable nuestro equipo con *Linux*. Si configurar implica poder leer y escribir
   el archivo de dispositivo referido, ¿qué debemos hacer para permitir
   al usuario habitual configurar el dispositivo?
