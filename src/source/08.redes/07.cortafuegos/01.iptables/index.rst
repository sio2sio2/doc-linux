.. _iptables:

IPtables
********
Desde Woody_ a Stretch_ la herramienta de usuario para la definición del
cortafuegos ha venido siendo la suite de programas de :program:`iptables`:

* :program:`iptables` e :program:`ip6tables` para la inspección en capa de red y
  de transporte.
* :program:`ebtables` para la inspección de tramas de ethernet del tráfico
  conmutado (el que atraviesa :ref:`interfaces bridge <bridge>`).
* :program:`arptables` para la inspección del tráfico |ARP|.

En las nuevas versiones, los ejecutables que usan realmente la herramienta
antigua y no ocultamente :program:`nftables` han pasado a añadir al nombre
de programa el sufijo :kbd:`-legacy`. Así, :program:`iptables-legacy` es el
:program:`iptables` y, por defecto, :program:`iptables` una alternativa que
apunta a :program:`iptables-nft`.

.. warning:: Para seguir las lecciones sobre :program:`ipfilter` deberá usar
   Stretch_ o, si usa Buster_, utilizar las versiones *legacy* o asegurarse de
   apuntar con :program:`update-alternatives` a las versiones *legacy*.

.. rubric:: Contenidos

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

.. |ARP| replace:: :abbr:`ARP (Address Resolution Protocol)`
