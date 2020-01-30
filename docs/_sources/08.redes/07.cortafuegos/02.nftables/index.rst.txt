.. _nftables:

nftables
********
La nueva herramienta para usar :program:`netfilter` tiene una sintaxis nueva
inspirada en :ref:`tcpdump <tcpdump>`. Esto, junto a que no trae predefinida
ninguna tabla ni cadena son las principales diferencias aparentes, respecto a
:program:`iptables`.

.. note:: Como en el caso de :program:`iptables` nos centraremos en la
   manipulación del tráfico en capa 3 y 4, y dejaremos el trafico a través de
   :ref:`interfaces bridge <bridge>` y el tráfico |ARP| para el final.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

.. |ARP| replace:: :abbr:`ARP (Address Resolution Protocol)`
