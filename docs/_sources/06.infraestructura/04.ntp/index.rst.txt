.. _ntp:

Servicio de hora
================

.. Para clientes ahora se usa:

   # timedatectl set-ntp true
   
   yq que esté activo el servicio:

   # systemctl status systemd-timesyncd

   cuya configuración está en /etc/systemd/timesyncd.conf
