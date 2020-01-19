.. _SMART:

Diagnóstico
***********
Todos los discos modernos incluyen |SMART|, una tecnología que permite monitorizarlos
y detectar fallos puntuales de disco antes de que llegue a producirse una falla
completa que inutilice el disco. Para poder hacer efectiva la monitorización se
requiere que el sistema operativo, como es el caso de *Linux*, la soporte.

Instalación
===========
Para instalar las herramientas |SMART| basta con::

   # apt install smartmontools

Uso
===
Hay dos formas de utilizar esta tecnología:

- Manualmente, mediante el comando :command:`smartctl`.
- Monitarizando a través del demonio :command:`smartd`, que se habilita al
  instalar el paquete.

.. _smartctl:
.. index:: smartctl

:command:`smartctl`
   Podemos obtener la lista de dispositivos mediante::

      # smartctl --scan
      /dev/sda -d scsi # /dev/sda, SCSI device
      /dev/sdb -d scsi # /dev/sdb, SCSI device
      /dev/sdd -d usbjmicron # /dev/sdd [USB JMicron], ATA device
      /dev/sde -d usbjmicron # /dev/sde [USB JMicron], ATA device

   En este caso hay cuatro distintos, de cada uno de los cuales podemos obtener
   información::

      # smartctl -i /dev/sda
      smartctl 7.1 2019-12-30 r5022 [x86_64-linux-5.4.0-2-amd64] (local build)
      Copyright (C) 2002-19, Bruce Allen, Christian Franke, www.smartmontools.org

      === START OF INFORMATION SECTION ===
      Model Family:     Silicon Motion based OEM SSDs
      Device Model:     Intenso  SSD Sata III
      Serial Number:    AA000000000000003422
      LU WWN Device Id: 5 000000 000000000
      Firmware Version: P0510E
      User Capacity:    120.034.123.776 bytes [120 GB]
      Sector Size:      512 bytes logical/physical
      Rotation Rate:    Solid State Device
      Device is:        In smartctl database [for details use: -P show]
      ATA Version is:   ACS-2 (minor revision not indicated)
      SATA Version is:  SATA 3.1, 6.0 Gb/s (current: 6.0 Gb/s)
      Local Time is:    Sun Jan 19 10:13:22 2020 CET
      SMART support is: Available - device has SMART capability.
      SMART support is: Enabled

   En este caso, tenemos un disco |SSD| de 120GB que tiene soporte para |SMART|
   y lo tiene activo. Si no lo tuviera activo, podríamos activarlo con::

      # smartctl -s on /dev/sda

   Pasemos a hacer pruebas con una máquina virtual, ya que Los discos virtuales
   de :ref:`QEmu <qemu>` también suportan la tecnología::

      # smartctl -i /dev/sda
      smartctl 6.6 2017-11-05 r4594 [x86_64-linux-4.19.0-6-amd64] (local build)
      Copyright (C) 2002-17, Bruce Allen, Christian Franke, www.smartmontools.org

      === START OF INFORMATION SECTION ===
      Device Model:     QEMU HARDDISK
      Serial Number:    QM00001
      Firmware Version: 2.5+
      User Capacity:    3.221.225.472 bytes [3,22 GB]
      Sector Size:      512 bytes logical/physical
      Device is:        Not in smartctl database [for details use: -P showall]
      ATA Version is:   ATA/ATAPI-7, ATA/ATAPI-5 published, ANSI NCITS 340-2000
      Local Time is:    Sun Jan 19 10:38:09 2020 CET
      SMART support is: Available - device has SMART capability.
      SMART support is: Enabled

   Para comprobar el rendimiento mecánico y eléctrico del dispositivo pueden
   llevarse a cabo varios exámenes:

   * *short*, que lleva a cabo comprobaciones que detectan fallos de disco.
   * *long*, que comprueba más exhaustivamente la superficie del disco.
   * *conveyance*, que identifica daños que se producen durante el transporte.

   Es interesante conocer cuáles son las capacidad |SMART| de nuestro disco::

      # smartctl -c /dev/sda
      smartctl 6.6 2017-11-05 r4594 [x86_64-linux-4.19.0-6-amd64] (local build)
      Copyright (C) 2002-17, Bruce Allen, Christian Franke, www.smartmontools.org

      === START OF READ SMART DATA SECTION ===
      General SMART Values:
      Offline data collection status:  (0x82) Offline data collection activity
                                              was completed without error.
                                              Auto Offline Data Collection: Enabled.
      Self-test execution status:      (   0) The previous self-test routine completed
                                              without error or no self-test has ever 
                                              been run.
      Total time to complete Offline 
      data collection:                (  288) seconds.
      Offline data collection
      capabilities:                    (0x19) SMART execute Offline immediate.
                                              No Auto Offline data collection support.
                                              Suspend Offline collection upon new
                                              command.
                                              Offline surface scan supported.
                                              Self-test supported.
                                              No Conveyance Self-test supported.
                                              No Selective Self-test supported.
      SMART capabilities:            (0x0003) Saves SMART data before entering
                                              power-saving mode.
                                              Supports SMART auto save timer.
      Error logging capability:        (0x01) Error logging supported.
                                              No General Purpose Logging support.
      Short self-test routine 
      recommended polling time:        (   2) minutes.
      Extended self-test routine
      recommended polling time:        (  54) minutes.


   donde vemos que no podremos hacer el tercero de los exámenes. Probemos el
   corto::

      # smartctl -t short /dev/sda
      [...]
      Please wait 2 minutes for test to complete.
      [...]
   
   Y pasado el tiempo podremos comprobar el resultado del test::

      # smartctl -l selftest /dev/sda
      [...]
      === START OF READ SMART DATA SECTION ===
      SMART Self-test log structure revision number 1
      Num  Test_Description    Status                  Remaining LifeTime(hours)  LBA_of_first_error
      # 1  Short offline       Completed without error       00%      4660        -

   y podemos conocer el estado del disco con::

      # smartctl -H /dev/sda
      [..]
      === START OF READ SMART DATA SECTION ===
      SMART overall-health self-assessment test result: PASSED

   donde *PASSED* es buena señal. También son interasante los errores que hayan
   podido producirse durante el funcionamiento del disco::

      # smartctl -l error

   que mostrará los últimos cinco de ellos. por último es conveniente echar un
   vistazo a los atributos |SMART| con::

      # smartctl -A /dev/sda
      [...]
      === START OF READ SMART DATA SECTION ===
      SMART Attributes Data Structure revision number: 1
      Vendor Specific SMART Attributes with Thresholds:
      ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
        1 Raw_Read_Error_Rate     0x0003   100   100   006    Pre-fail  Always       -       0
        3 Spin_Up_Time            0x0003   100   100   000    Pre-fail  Always       -       16
        4 Start_Stop_Count        0x0002   100   100   020    Old_age   Always       -       100
        5 Reallocated_Sector_Ct   0x0003   100   100   036    Pre-fail  Always       -       0
        9 Power_On_Hours          0x0003   100   100   000    Pre-fail  Always       -       1
       12 Power_Cycle_Count       0x0003   100   100   000    Pre-fail  Always       -       0
      190 Airflow_Temperature_Cel 0x0003   069   069   050    Pre-fail  Always       -       31 (Min/Max 31/31)

   En este caso, son pocos por tratarse de un disco virtual. En un disco de un servidor real::

      # smartctl -HA /dev/sdb
      [...]
      === START OF READ SMART DATA SECTION ===
      SMART overall-health self-assessment test result: PASSED

      SMART Attributes Data Structure revision number: 16
      Vendor Specific SMART Attributes with Thresholds:
      ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
        1 Raw_Read_Error_Rate     0x002f   200   200   051    Pre-fail  Always       -       0
        3 Spin_Up_Time            0x0027   133   115   021    Pre-fail  Always       -       6333
        4 Start_Stop_Count        0x0032   100   100   000    Old_age   Always       -       254
        5 Reallocated_Sector_Ct   0x0033   200   200   140    Pre-fail  Always       -       0
        7 Seek_Error_Rate         0x002e   200   200   000    Old_age   Always       -       0
        9 Power_On_Hours          0x0032   054   054   000    Old_age   Always       -       34125
       10 Spin_Retry_Count        0x0032   100   100   000    Old_age   Always       -       0
       11 Calibration_Retry_Count 0x0032   100   100   000    Old_age   Always       -       0
       12 Power_Cycle_Count       0x0032   100   100   000    Old_age   Always       -       253
      192 Power-Off_Retract_Count 0x0032   200   200   000    Old_age   Always       -       145
      193 Load_Cycle_Count        0x0032   127   127   000    Old_age   Always       -       221570
      194 Temperature_Celsius     0x0022   115   100   000    Old_age   Always       -       32
      196 Reallocated_Event_Count 0x0032   200   200   000    Old_age   Always       -       0
      197 Current_Pending_Sector  0x0032   200   200   000    Old_age   Always       -       0
      198 Offline_Uncorrectable   0x0030   200   200   000    Old_age   Offline      -       1
      199 UDMA_CRC_Error_Count    0x0032   200   200   000    Old_age   Always       -       0
      200 Multi_Zone_Error_Rate   0x0008   200   200   000    Old_age   Offline      -       1
      
   Para conocer cuál es el significado de estos atributos puede recurrise a la
   `página de la wikipedia
   <https://en.wikipedia.org/wiki/S.M.A.R.T.#Known_ATA_S.M.A.R.T._attributes>`_.
   Hay algunos marcados como críticos (5, 10, 184, 187, 188, 196, 197, 198 y
   201) y que anuncian un fallo definitivo del disco. Nuestro disco está en la
   cuerda floja (198)\ [#]_.

   .. note:: Los valores de estos atributos se leen de disco sin que se requiera
      un examen previo para ello

.. _smartd:

:command:`smartd`
   Es un demonio que permite periódicamente comprobar los atributos |SMART|, el
   estado de salud del disco o llevar a cabo exámenes. Si como resultado de
   ello, se detecta algún problema se envía un correo electrónico de aviso al
   administrador.

   La configuración es simple, y la propia instalación habilita el servicio. Hay
   que antender a dos archivos:

   :file:`/etc/default/smartmontools`
      para el que sólo tiene interés la variable *smartd_opts* si usamos
      :ref:`systemd <systemd>`. En principio, si no se llevan a cabo cambios,
      :program:`smartd` realizará lecturas cada 30 minutos.

   :file:`/etc/smartd.conf`
      Que define los discos que se monitorizan, qué se realiza sobre ellos
      y cómo se llevan a cabo los avisos. Su contenido predefinido es::

         DEVICESCAN -d removable -n standby -m root -M exec /usr/share/smartmontools/smartd-runner

      que:

      * Escanea y comprueba todos los discos conectados
      * Obtiene la información equivalente a usar :kbd:`-a` con :ref:`smartctl
        <smartctl>`. Esto es debido a que no se usa ninguna opción en particular
        y se sobrentiende :kbd:`-a`. No se hace ningún examen adicional.
      * No se genera un error si algún disco desaparece.
      * Comprueba el disco a menos que esté en estado *SLEEP* o *STANDBY*.
      * Usa como cuenta para avisos la del administrador.
      * En vez de avisar con un mensaje de correo, ejecuta el script
        :file:`/usr/share/smartmontools/smartd-runner`, que en *Debian* implica
        ejecutar todos los *scripts* contenidos en :file:`/etc/smartmontools/run.d/`, uno
        de los cuales es enviar el mensaje de correo.

      El efecto de la configuración es que se envían un mensaje de aviso cada
      vez que se detecta un fallo y, si no se corrige,  se repite diariamente el
      mensaje. Esta comportamiento puede alterarse añadiendo :file:`-M
      diminishing` a la línea que ira espaciando al doble del intervalo anterior
      los mensajes (al día siguiente, a los dos días, a los cuatro, etc.)

      .. seealso:: Eche un vistazo a :manpage:`smartd.conf(5)`, para alterar
         esta configuración

.. rubric:: Enlaces de interés

* `Artículo de Wikipedia sobre la tecnología SMART
  <https://en.wikipedia.org/wiki/S.M.A.R.T.>`_.
* `What SMART Stats Tell Us About Hard Drives
  <https://www.backblaze.com/blog/what-smart-stats-indicate-hard-drive-failures>`_.
* `Artñiculo de la Wiki de Archlinux sobre SMART
  <https://wiki.archlinux.org/index.php/S.M.A.R.T.>`_.
* `Corrección de sectores defectuosos con smartctl y hdparm
  <https://hiddenc0de.wordpress.com/2015/06/12/how-to-fix-bad-sectors-or-bad-blocks-on-hard-disk/>`_.


.. rubric:: Notas al pie

.. [#] En los comentarios a `este artículo sobre predicción de fallos
   <https://www.backblaze.com/blog/what-smart-stats-indicate-hard-drive-failures/#comment-2938093635>`_,
   alguien afirma que el que aparezca un error de este supone muy probablemente
   que el disco se muere dentro de los 3 meses siguientes.

.. |SMART| replace:: :abbr:`SMART (Self-Monitoring, Analysis and Reporting Technology)`
.. |SSD| replace:: :abbr:`SSD (Solid-State Drive)`
