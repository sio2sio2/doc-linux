.. _disk-quota:

Cuotas
======
La :dfn:`cuota` de disco permite establecer un límite máximo en el número de
ficheros creados o el espacio ocupado por un usuario (:dfn:`cuota de usuario`) o
por el conjunto de usuarios que pertenecen a un grupo (:dfn:`cuota de grupo`).

Activación
----------

Para hacer uso de ellas es necesario:

#. Instalar el paquete *quota*::

      # apt install quota

#. Cargar el módulo de cuotas::

      # echo "quota_v2" > /etc/modules
      # modprobe quota_v2

   La primera línea posibilita que el módulo se cargue durante cada arranque,
   mientras que el segundo que se cargue en la sesión actual.

#. Añadir la opción *usrquota* (y *grpquota* si se quieren las cuotas de grupo)
   en la línea de :file:`/etc/fstab` correspondiente a cada fichero en el que se
   quiera habilitar las cuotas:

   .. nota:: En sistemas *ext4* que es lo habitual en linux.

   .. code-block:: none

      /dev/sda7   /home       ext4  defaults,usrquota    0    1

   En este caso se ha habilitado sólo para el sistema de ficheros encargado de
   albergar los directorios personales de usuario (:file:`/home`). Para que tome
   efecto, inmediato este cambio habrá que volver a montar la partición::

       # mount -o remount /home

#. Crear el fichero que almacenará las cuotas y llevará la cuenta de cuánto ha
   ocupado cada usuario::

      # quotacheck -cvagu

#. Activar la cuota del sistema (también se puede reiniciar el sistema)::

      # quotaon /home

   o bien, haciendo uso del servicio de *debian*::

      # invoke-rc.d quota restart

Llegados a este punto ya estarán habilitadas las cuotas, lo cual podrá
comprobarse del siguiente modo::

   # quotaon -p /home
   group quota on /home (/dev/sda7) is off
   user quota on /home (/dev/sda7) is on 
   # repquota -v /home
   Report for user quotas on device /dev/mapper/VGserver-home
   Block grace time: 7days; Inode grace time: 7days
                           Block limits                File limits
   User            used    soft    hard  grace    used  soft  hard  grace
   ----------------------------------------------------------------------
   root      --      13       0       0      0       2     0     0      0
   usuario   --      19       0       0      0      11     0     0      0

Es conveniente que periódicamente, por ejemplo una vez a la semana, se
comprueben las cuotas de usuario por lo que sería conveniente añadir a
:ref:`cron <cron>` la siguiente orden::

   quotacheck -vagu

.. warning:: En esta orden para :program:`cron` no añada la opción ``-c``,
   puesto que recrearía el fichero y nos haría perder todas las cuotas ya
   establecidas para los usuarios.

Definición
----------
Habilitadas las cuotas toca establecerlas para los usuarios. Fundamentalmente
hay dos métodos:

.. _setquota:

.. index:: setquota

**setquota**
   Sirve para modificar directamente la cuota en la línea de comandos::

      # setquota -u nombre_usuario  1024  1024   0  0  /home

   Los dos primeros números están expresados en bloques de **1K** y significan
   el límite de ocupación, mientras que los dos segundos expresan el número
   áximo de ficheros que se le permite crear al usuario "nombre_usuario" en el
   sistema de fichero :file:`/home`. El hecho de que existan dos límites se debe
   a que el primero es un límite blando, que puede sobrepasarse durante un
   tiempo de gracia, mientras que el segundo es un límite duro, que no puede
   sobrepasarse en ningún caso.

   En nuestro caso hemos hecho coincidir ambos, pero si hubieras querido hacer
   uso de ambos límites y establecer un tiempo de gracia (en segundos), puede
   usarse a continuación la orden con la opción ``-t`` para fijar un límite
   común a todos los usuarios (o grupos), o ``-T`` para establecerlo
   individualmente para cada usuario (o grupo)::

      # setquota -t -u $((24*60*60)) $((24*60*60)) /home

   o bien::

      # setquota -T -u nombre_usuario $((24*60*60)) $((24*60*60)) /home

   En ambos casos, el primer tiempo (**1h**) es el tiempo de gracia para el
   límite de almacenamiento, y sel segundo para el número límite de ficheros.

   .. note:: Todos estos límites se fijan para la *cuota* de usuario. Si quieren
      establecerse cuotas de grupo, basta con utilizar la opción ``-g`` em vez
      de ``-u``.

   .. note:: Si se usa la opción ``-a`` en sustitución del sistema de ficheros
      las cuotas (o los tiempos de gracia) se modificarán para todos los
      sistemas de ficheros.

.. _edquota:

.. index:: edquota

**edquota**
   El otro modo de establecer las cuotas de usuario es mediante un método
   interactivo que permite editarlas como si de un fichero se tratara::

      # edquota -u usuario

   Que nos presentará con el :ref:`editor predeterminado <sh-EDITOR>` lo
   siguiente:

   .. code-block:: none

      Disk quotas for user usuario (uid 1000):
         Filesystem            blocks       soft       hard     inodes soft     hard
         /dev/sda7                  7          0       2048          4    0        0

   Los significados de los números son exactamente los mismos que para
   :ref:`setquota <setquota>`, aunque en este caso se nos informa también de
   cuál es la ocupación actual (en el ejemplo, **7K** de ocupación y **4** ficheros
   creados).

   Si se quieren modificar los tiempos de gracia puede usarse::

      # edquota -tu

   o::

      # edquota -Tu usuario

   de forma análoga a como se hacía con :ref:`setquota <setquota>`.

   Además de este *sabor* interactivo, :command:`edquota` permite copiar las
   cuotas de un usuario en uno u otros usuarios con la opción ``-p``::

      # edquota -p usuario otro_usuario otro_usuario_mas

Un usuario particular siempre podrá conocer su estado de la *cuota* con la
siguiente consulta::

   $ quota

El administrador, por su parte, podrá conocer también las ajenas con sólo añadir
el nombre de usuario a la orden::

   # quota usuario_limitado

Aunque si quiere un informe de todas las cuotas, entonces es más recomendable::

   # repquota -v /home
