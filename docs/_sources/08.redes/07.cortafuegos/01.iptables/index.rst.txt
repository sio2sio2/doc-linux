.. _iptables:

netfilter (IPtables)
********************
Desde *Woody* a *Stretch* el cortafuegos predeterminado en *Debian* ha venido
siendo :program:`netfilter` que es nombre de la *suite* que engloba el conjunto
de programas de cortafuegos, aunque vulgarmente nos refiramos a todo él como
:program:`iptables`, que es, en realidad, sólo uno de ellos. La suite incluye:

* :program:`iptables` e :program:`ip6tables` para la inspección en capa de red y de
  transporte.
* :program:`ebtables` y :program:`eb6tables` para la inspección en tramas de
  ethernet.
* :program:`arptables` y :program:`arp6tables` para la inspección del tráfico
  |ARP|.

A partir de *Buster*, se sigue incluyendo el soporte en el núcleo, pero los
ejecutables :command:`iptables`, :command:`ebtables` y :command:`arptables` son
en realidad un frontend para :ref:`nftables <nftables>`, conservando la sintaxis
de los originales. Es importante tenerlo presente, porque hay módulos de
:program:`iptables` que ya no existen en :program:`iptables`. Para sintaxis
básica y algunos módulos, sin embargo, son perfectamente funcionales.

Los verdaderos ejecutables de :program:`netfilter` han pasado a renombrarse
añadiendo :kbd:`-legacy`. Así, :program:`iptables-legacy` es el
:program:`iptables` y, por defecto, :program:`iptables` una alternativa que
apunta a :program:`iptables-nft`.

.. warning:: Para seguir las lecciones sobre :program:`netfilter` deberá usar
   *Stretch* o, si usa *Buster*, utilizar las versiones *legacy* o asegurarse de
   usar :program:`update-alternatives` para apuntar a las versiones *legacy*.

.. rubric:: Notas al pie

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

.. |ARP| replace:: :abbr:`APR (Address Resolution Protocol)`
