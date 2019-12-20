.. _inst-servidor:

Instalación del servidor
************************

El tema expone cómo instalar una *debian* sobre una máquina virtual con el
propósito de montar el servidor en ella antes de trasladarlo a la máquina real.

Se discutirá cómo particionar el disco y llevar a cabo este particionado
mediante `volúmenes lógicos <http://www.noexite.xxx/enlace_por_definir.html>`_;
y cómo crear un `RAID 1 <http://www.noexite.xxx/enlace_por_definir.html>`_
para asegurar mejor los datos frente al fallo fortuito de un disco.

.. todo:: Describir la instalación.

.. Pasos rápidos:

   # sgdisk -a 8 -n "0:40:2047" -t "0:0xef02" -c "0:BOOTBIOS" \
         -a 2048 -n "0:2048:+50M" -t "0:0xef00" -c "0:EFI" \
                 -N 0 -t "3:0xfd00" -c "3:RAID" /dev/nbd0
   # mdadm --create /dev/md0 --metadata=1 --homehost=any --name=0 --verbose \
     --level=1 --raid-devices=1 --force --assume-clean /dev/nbd0p3
   # vgcreate VGbuster /dev/md0
   # lvcreate --thin-pool pool -l 98%VG VGbuster
   # lvcreate -n swap -l 100%FREE -C y VGbuster

   # lvcreate -T -n raiz -V 4G VGbuster/pool
   # lvcreate -T -n log -V 1G VGbuster/pool
   # lvcreate -T -n srv -V 15G VGbuster/pool
   # lvcreate -T -n mysql -V 10G VGbuster/pool
   # lvcreate -T -n home -V 100G VGbuster/pool
