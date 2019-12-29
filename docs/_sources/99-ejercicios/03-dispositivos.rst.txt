Ejercicios sobre dispositivos
-----------------------------

#. Enchufar un disco de 4G a la máquina virtual.
#. Crear tres particiones primarias en el disco duro de:

   #) 1G
   #) 2G
   #) 1G

#. Formatear las particiones con las siguientes características:

   #) ext4, etiqueta=PRIMERA
   #) xfs, etiqueta=SEGUNDA
   #) ntfs, etiqueta=WINDOWS

#. Mountar la partición (1) como sólo lectura.

#. Crear una entrada en :file:`fstab` para montar automáticamente la partición
   *WINDOWS* en :file:`/home/windows-data`.

#. Investíguese si hay alguna forma de sólo los usuarios pertenecientes
   al grupo *windoseros* puedan escribir en la partición anterior.

#. Compruebe si puede desmontar o no el sistema de ficheros montado
   sobre :file:`/home`.

#. Hacer una copia byte a byte de *WINDOWS* en :file:`/dev/null`.

#. ¿Cuánto espacio hay ocupado en :file:`/home`?

#. Remontar *WINDOWS* como sólo lectura.
