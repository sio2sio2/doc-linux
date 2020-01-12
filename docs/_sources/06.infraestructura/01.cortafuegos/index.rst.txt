.. _firewall:

Cortafuegos
===========
.. seealso:: Para una pequeña introducción teórica sobre el concepto de
   cortafuegos, lea :ref:`el tema homónimo de la guía del módulo de Seguridad
   Informática <seg-firewall>`.

*Linux* ha incluido varios cortafuegos a lo largo de su historia:

* :program:`ipfwadm`, desde la versión 1.2 del núcleo.
* :program:`ipchains`, en la versión 2.2.
* :program:`iptables`, desde la versión 2.4.
* :program:`nftables`, desde la versión 3.13.

Los dos primeros eran cortafuegos sin contexto de conexión (*firewall
stateless*), mientras que los dos segundos sí son capaces de atender al contexto
de conexión (*firewall stateful*). Al ser los cortafuegos piezas críticas para
la seguridad del sistema operativo es común que su sustitución por otro sea
paulatina y que durante un tiempo convivan el *firewall* antiguo y el nuevo,
mientras se afinan, los administradores se acostumbran y las aplicaciones que
dependen de ellos se actualizan. Desde hace unos cuantos años\ [#]_, conviven en
el núcleo de *Linux* :program:`iptables` y :program:`nftables`, aunque la
mayoría de las versiones modernas (*Debian* desde *Buster*) incluyen ya
:program:`nftables` como el cortafuegos predeterminado. Trataremos en esta guía
ambos.

.. rubric:: Contenidos

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*/index

.. rubric:: Notas al pie

.. [#] La fecha de redacción de este párrafo es enero de 2020 y
   :program:`nftables` se incluyó por primera vez en el núcleo en 2014.
