Ejercicios sobre herramientas de texto
--------------------------------------

#. ¿Cuántas particiones tiene definidas el disco *sda*?
   La orden debe devolver el número.

#. Devolver en mayúsculas los nombres de los usuarios
   definidos en el sistema.

#. Mostrar la lista de integrantes de cada grupo que no tienen
   al propio grupo como grupo principal. La lista debe tener
   la forma:

   .. code-block:: none

      sudo = usuario1 usuario2
      admin = usuario2 usuario5 usuario3

#. Mostrar los nombres de usuario y su UID del siguiente modo:

   .. code-block:: none

      root=0
      daemon=1
      bin=2
      etc.

   .. note:: Puede usar tanto :command:`cut` como :command:`awk`.

#. ¿Cuántas ejecutables básicos propios del administrador hay
   instalados en el sistema?

#. Muestren las direcciones |IP| de los servidores DNS
   que usa el sistema.

#. ¿Cuál es el puerto típico del servicio IMAP (versión 2)?
   
   .. note:: Échele un vistado a :file:`/etc/services`.
