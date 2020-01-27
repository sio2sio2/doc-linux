.. _nftables:

nftables
********
Es el nuevo cortafuegos de *Linux* con una sintaxis totalmente diferente
inspirada en :ref:`tcpdump <tcpdump>`. Pese a ello, resulta muy útil el
conocimiento previo de :program:`iptables` debido a que:

- Aunque de antemano no predefine las tablas ni las cadenas, el flujo 
  de paquetes sigue siendo exactamente el mismo, por lo que los puntos
  de enganche de las cadenas siguen estando en los mismos instantes. Por tanto,
  si utilizamos los nombres de tablas y cadenas que se usan en
  :program:`iptables`, recrearemos un sistema de tablas y cadenas equivalente,
- Incorpora una serie de ordenes (:program:`iptables-nft`, etc.) que son
  capaces de procesar la sintaxis de las órdenes de :program:`netfilter` y
  generar las reglas para :program:`nftables`. De hecho, también incluye
  traductores (:program:`iptables-translate`, etc.). Las posibilidades, sin
  embargo, se limitan a la sintaxis básica, por lo que no podremos usar
  sentencias de iptables que incluyan :ref:`extensiones <iptables-ext>`.

Utilizar :program:`nftables` exige un esfuerzo extra en:

- Definir tablas asignando cada una a una familia de tráfico. Con las antiguas
  herramientas el tráfico que tratáramos venía definido por la herramienta que
  usáramos. Por ejemplo, para tráfico conmutado usábamos :program:`ebtables`.

- Definir cadenas para asignar cada una a una familia de tráfico, un tipo de
  cadena y un enganche (esto, en que instante del flujo opera). En las antiguas
  herramientas existían cadenas predefinidas con todo ya completamente definido.
  Por ejemplo, la cadena *INPUT* de la tabla *filter* de :program:`iptables` se
  refiere a la familia *ip*, es de tipo *filter* y su enganche se encuentra tras
  la decisión de encaminamiento y antas de la llegada al proceso local.

- Asociar las cadenas a tablas, lo cual ya se daba hecho antes. Siguiendo con el
  ejemplo de la cadena anterior, ésta ya estaba asociada a la tabla *filter*.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

.. rubric:: Enlaces de interes

* `La wiki de nftables
  <https://wiki.nftables.org/wiki-nftables/index.php>`_.
* `Tutorial de la wiki de Archilinux
  <https://wiki.archlinux.org/index.php/Nftables>`_.
* `Tutorial de la wiki de Gentoo
  <https://wiki.gentoo.org/wiki/Nftables>`_.
* `Presentación de desarrolladores de netfilter en la Cybercamp 2018
  <https://cybercamp.es/sites/default/files/contenidos/videos/adjuntos/cybercamp18_b06_laura_garcia_liebana_0_0.pdf>`_.

