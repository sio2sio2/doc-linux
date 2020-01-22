.. _firewall:

Cortafuegos
===========
.. seealso:: Para una pequeña introducción teórica sobre el concepto de
   cortafuegos, lea :ref:`el tema homónimo de la guía del módulo de Seguridad
   Informática <seg-firewall>`.

*Linux* ha incluido varios cortafuegos a lo largo de su historia:

* Cortafuegos de filtrado estático (:ref:`firewall stateless <fw-stateless>`):

  + :program:`ipfwadm`, desde la versión 1.2 del núcleo.
  + :program:`ipchains`, en la versión 2.2.

* Cortafuegos de filtrado dinámico (:ref:`firewall stateful <fw-stateful>`):

  + :program:`iptables`, desde la versión 2.4.
  + :program:`nftables`, desde la versión 3.13.

Al ser los cortafuegos piezas críticas para la seguridad del sistema operativo
es común que su sustitución por otro sea paulatina y que durante un tiempo
convivan el *firewall* antiguo y el nuevo, mientras se afinan, los
administradores se acostumbran y las aplicaciones que dependen de ellos se
actualizan. Desde hace unos cuantos años\ [#]_, conviven en las distribuciones
de *Linux* :program:`iptables` y su sustituto :program:`nftables`, programas
ambos que manipulan el *framework* de filtrado de paquetes del núcleo
(:program:`netfilter`), aunque las distribuciones modernas (*Debian* desde
*Buster*) fijan ya :program:`nftables` como el cortafuegos predeterminado.
Trataremos en esta guía ambos.

.. rubric:: Contenidos

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*/index

.. rubric:: Notas al pie

.. [#] La fecha de redacción de este párrafo es enero de 2020 y
   :program:`nftables` se incluyó por primera vez en el núcleo en 2014.
