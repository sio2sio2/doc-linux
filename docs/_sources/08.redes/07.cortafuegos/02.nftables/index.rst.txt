.. _nftables:

nftables
********
Es el nuevo cortafuegos de *Linux* con una sintaxis totalmente diferente
inspirada en :ref:`tcpdump <tcpdump>`. Pese a ello, resulta muy útil el
conocimiento previo de :program:`netfilter` debido a que:

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

.. https://wiki.nftables.org/wiki-nftables/index.php/Main_Page
   https://www.redeszone.net/tutoriales/seguridad/nftables-firewall-linux-configuracion/
   https://wiki.archlinux.org/index.php/Nftables_(Espa%C3%B1ol)
