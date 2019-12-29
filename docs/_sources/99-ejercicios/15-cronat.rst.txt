Ejercicios sobre :ref:`cron <cron>` y :ref:`at <at>`
----------------------------------------------------

#. Apagar el ordenador dentro de tres horas.

#. Para que no se quede encendido el ordenador por
   la tarde (a partir de las 15:00), asegurarse de que se apagará.

#. Que se actualice la lista de paquetes instalables cada tres horas.

#. Dentro de seis minutos escribir en el fichero :file:`~/tarea_programada` la
   fecha y hora exactas.

   .. note:: Véase la orden :program:`date`.

#. Cada seis minutos escriba en el fichero :file:`~/tarea_periodica` la
   fecha y hora exactas, sin eliminar las escrituras anteriores.

#. Realizar una copia semanal de seguridad de todos los directorios de usuario.

   .. note:: Use :ref:`tar <tar>` para generar el fichero.

#. Ídem, pero la copia no debe realizarse durante los meses de julio y agosto.

#. Dentro de una semana, eliminar el usuario "caducado".

#. Dentro de cinco horas,  apagar el sistema si no quedan usuarios logueados.

#. Generar cada hora, la lista de usuarios logueados y almacenarla en
   /tmp/usuarios_fecha-hora.txt.

#. Apagar el sistema la próxima media noche.

#. Borrar diariamente todos los paquetes descargados con :program:`apt`.
