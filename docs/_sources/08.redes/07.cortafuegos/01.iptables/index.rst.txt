.. _iptables:

IPtables
********
Desde *Woody* a *Stretch* el cortafuegos predeterminado en *Debian* ha venido
siendo :program:`iptables`, aunque en realidad las aplicaciones que nos permiten
tratar con :program:`netfilter` son una suite que engloba todo un conjunto de
aplicaciones:

* :program:`iptables` e :program:`ip6tables` para la inspección en capa de red y
  de transporte.
* :program:`ebtables` para la inspección de tramas de ethernet del tráfico
  conmutado (el que atraviesa :ref:`interfaces bridge <bridge>`).
* :program:`arptables` para la inspección del tráfico |ARP|.

A partir de *Buster*, se sigue incluyendo esta suite (a la que referiremos
simplemente con el nombre de su ejecutable emblema :program:`iptable`), aunque
en realidad como *frontend* de :ref:`nftables <nftables>` que conserva la
sintaxis de los originales. Es importante tenerlo presente, porque si
pretendemos hacer algo un poco complicado (usar extensiones como las referidas
:ref:`bajo su epígrafe <iptables-ext>`), nos toparemos con la imposibilidad de
hacerlo, ya que e *frontend* no llega a tanto grado de traducción.
Para la sintaxis básica, sin embargo, son perfectamente funcionales.

Los verdaderos ejecutables de :program:`iptables` han pasado a renombrarse
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

.. |ARP| replace:: :abbr:`ARP (Address Resolution Protocol)`
