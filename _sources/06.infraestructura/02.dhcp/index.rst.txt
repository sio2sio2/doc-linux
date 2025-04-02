.. _dhcp:

DHCP
****
|DHCP| (Protocolo Dinámico de Configuración de Equipo) es un protocolo de red
que permite a la máquina obtener una configuración de red sin intervención del
usuario. A esta forma automática de obtener la configuración se la suele
denominar como *configuración automática* frente a la *configuración manual*,
que exige que se introduzcan manualmente los parámetros de red (fundamentalmente
dirección |IP|, máscara, puerta de enlace y servidores |DNS|).

Tuvo su origen en el protocolo :abbr:`BOOTP (BOOTstrap Protocol)`, que se usaba
antiguamente en las máquinas *UNIX* sin disco para que obtuvieran una dirección
|IP| aun antes de arrancar cualquier sistema operativo. De hecho, el modo que
tenían estas máquinas sin disco de obtener el sistema operativo, era gracias a
que después de obtenida la |IP|, descargaba la imagen gracias a un servidor
|TFTP|. Este esquema se sigue utilizando hoy día en el terminales tontas, aunque
se ha susitituido el protocolo por el propio |DHCP|.

.. toctree::
   :maxdepth: 2
   :glob:

   [0-9]*

.. |TFTP| replace:: :abbr:`TFTP (Trivial FTP)`
