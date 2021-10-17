Ejercicios sobre uso avanzado de |CLI|
======================================

1. Listar todas las fotos (se supone con extensión **jpg**) que existen en el
   directorio temporal.

#. Listar todos los ejecutables dentro de :file:`/usr/bin` que empiecen por "u"
   y acaben por "s".

#. Encontrar un archivo en el sistema de archivos del que sólo recordamos que
   tiene en alguna parte de su nombre "alter".

#. Listar los ejecutables en :file:`/usr/bin` que tengan cuatro caracteres.

#. Lo anterior, pero saque la lista en formato largo (con expresión de
   permisos, propietario, etc.) y, como el listado es demasiado largo, pagine.

#. Los dispositivos de disco (en realidad, los discos |SATA|) se representan en
   el sistema dentro del directorio :file:`/dev` con nombres :file:`sdX` donde
   la :kbd:`X` es una letra minúscula. Por ejemplo, el primer disco es
   :file:`/dev/sda`, :file:`/dev/sdb` el segundo, etc... Sabido esto, liste
   los dispositivos |SATA| de disco presentes en su sistema.

#. Situado en el directorio personal, cree con una sola orden lo más corta
   posible los directorios "a", "b", "c" y "d" dentro del directorio temporal.

#. Cree un archivo llamado :file:`maxima.txt` con la frase "pulchrum est
   paucorum hominum".

#. Cree (sin usar un editor) un archivo llamado :file:`yo.txt` en cuya primera
   línea aparezca su nombre y en la segunda sus apellidos.

   a. En dos órdenes, una para la primera línea y otra para añadir la segunda.
   b. En una única orden.

#. ¿Cuántos ejecutables de cuatro caracteres hay en :file:`/usr/bin`? Debe
   obtener el número haciendo que el ordenador los cuente por usted. Pista:
   :manpage:`wc`.

.. |CLI| replace:: :abbr:`CLI (Command Line Interface)`
.. |SATA| replace:: :abbr:`SATA (Serial ATA`
