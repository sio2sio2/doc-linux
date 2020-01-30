.. _firewall:

Cortafuegos
***********
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
es común que su sustitución sea lenta y los administradores necesiten un tiempo
largo de transición. A partir de la versión *2.4* del núcleo, el *framework*
para manejo de paquetes pasó a ser :program:`netfilter` y como herramienta de
espacio de usuario se creó la familia de aplicaciones de :program:`iptables`
(:command:`iptables`, :command:`ip6tables`, :command:`ebtables` y
:command:`arptables`). En 2009, sin embargo, se lanzó una nueva herramienta de
espacio de usuario llamada :program:`nftables` que promete mejor rendimiento,
mayor claridad de sintaxis y evitar la duplicidad de código. Durante bastantes
años\ [#]_, esta nueva herramienta ha convivido a la sombra de
:program:`iptables`, pero las distribuciones modernas han optado ya por
adoptarla como herramienta oficial (*Debian* desde *Buster*) por lo que su
estudio es, más que aconsejable, obligatorio

El conocimiento de la suite de programas de :program:`iptables`, no obstante, no
es inútil por varias razones:

- Al ser el *framework* el mismo, los conceptos esenciales no cambian.
- :program:`nftables` incorpora una serie de programas cuyo nombre coincide con
  los de la suite de :program:`iptables` con la única diferencia de añadir un
  sufijo *-nft* (por ejemplo, :program:`ebtables-nft` como correspondiente a
  :program:`ebtables`), que permiten escribir la orden usando exactamente la
  misma sintaxis de los programas a los que emulan.
- Salvo módulos algo avanzados\ [#]_, la traducción será posible y el
  administrador será capaz de seguir definiendo las reglas *de siempre* usando
  las herramientas descritas.

Antes de comenzar la explicación de una y otra herramienta, podemos establecer
la parte común a ambas, esto es, los fundamentos de :program:`netfilter`.

.. note:: Es importante tener presente que :program:`netfilter` no sólo sirve
   para filtrar tráfico no autorizado o indeseado, sino para manipularlo en
   general (p.e. cambiando los datos de origen o destino).

.. _netfilter-conceptos:

Conceptos
=========
Para entender cómo funcionamiento el manejo de paquetes en el núcleo de *Linux*
es indispensable tener claros los siguientes conceptos:

.. _netfilter-families:

:dfn:`Familia` (*family*)
   Es el término para indicar el tipo de tráfico manipulado:

   .. table::
      :class: nftables-family

      ========== =============== ==========================================================
       Familia    Gestinado por   Descripción
      ========== =============== ==========================================================
       ip         iptables        |IP|\ v4.
       ip6        ip6tables       |IP|\ v6.
       inet       {ip,ip6}tables  Las dos familias anteriores.
       arp        arptables       Tráfico |ARP|.
       bridge     ebtables        Tráfico que atraviesa interfaces *bridge*.
       netdev     \-              Tráfico que acaba de procesar la tarjeta de red.
      ========== =============== ==========================================================

   Una diferencia evidente entre :program:`nftables` e :program:`iptables` es que
   el primero maneja todos los tipos de tráfico con una única aplicación
   (:command:`nft`), mientras que con el segundo se usa distinto programa según
   el tipo de tráfico.

.. _netfilter-rules:

:dfn:`Regla` (*rule*)
   Es cada una de las sentencias que manipula paquetes. La mayoría son
   condicionales, esto es, establecen las condiciones que las hacen aplicables
   sobre las paquetes. Estas condiciones refieren o bien características
   incluidas en el propio paquete (p.e. la dirección |IP| de origen), o bien
   caracteríticas derivadas del hecho de que el paquete pertenece a una conexión
   (p.e. si ese paquete es el que abre una conexión).

.. _netfilter-chains:

:dfn:`Cadena` (*chain*)
   Es una lista ordenada de reglas de un mismo *tipo*. Cuando un paquete accede
   a una cadena, comprueba las reglas una a una en el orden establecido,
   ejecutando sólo aquellas que le son aplicables. En ocasiones, la regla
   definirá una acción terminal (p.e. desechar el paquete) con lo que la
   comprobación del resto de reglas de la cadena no se llevará a cabo. Si se
   acaban las reglas de la cadena sin que esto suceda, se aplicará la política
   pretederminada: por lo general, o aceptar o desechar el paquetei, esto es. o
   una política de *lista negra* y o una política de *lista blanca*.
 
   Un aspecto importante de las cadenas, apuntado en el párrafo anterior, es la
   causa por la que un paquete accede a ella. Esto puede ser debido a una de
   estas dos razones:

   - Porque en otra cadena una de las reglas ordene acceder a ella. Estas son
     las llamadas :dfn:`cadenas de usuario`.
   - Porque al crear la cadena se asocie a un :ref:`punto de enganche
     <netfilter-hooks>` existente en el flujo de paquetes.` A estas cadenas se
     las llama :dfn:`cadenas base`.
   
   .. _netfilter-prio:

   Ahora bien, en el caso de la *cadenas base*, si hay dos cadenas asociadas a
   un mismo punto de enganche, ¿de cuál se revisan antes las reglas? Para
   determinarlo se define la :dfn:`prioridad`, que es un número entero que
   determina el orden en que dentro de un mismo enganche se comprueban las
   cadenas, de modo que cuanto menor sea este número, mayor será la prioridad.
   Hay unas cuantas prioridades predefinidas\ [#]_:

   .. table::
      :class: iptables-prio

      ========== =========== =================================== =============
       Nombre     Prioridad   Familia                             Enganche
      ========== =========== =================================== =============
       raw          -300      ip, ip6, inet                       Todos
       mangle       -150      ip, ip6, inet                       Todos
       dstnat       -100      ip, ip6, inet                       prerouting
       filter          0      ip, ip6, inet, arp, netdev          Todos
       security       50      ip, ip6, inet                       Todos
       srcnat        100      ip, ip6, inet                       postrouting
      ========== =========== =================================== =============

   Y para la familia *bridge*:

   .. table::
      :class: iptables-prio

      ========== =========== =========== =============
       Tabla      Prioridad   Familia     Enganche
      ========== =========== =========== =============
       dstnat     -300        bridge      prerouting
       filter     -200        bridge      Todos
       out         100        bridge      output
       srcnat      300        bridge      postrouting
      ========== =========== =========== =============

   .. _netfilter-chaintypes:

   El otro aspecto citado en el primer parrafo es que todas laa reglas de una
   misma cadena son del mismo tipo, aunque se dejó sin definir cuáles son estos
   tipos:

   .. table::
      :class: nftables-type

      +--------+---------------+----------+------------------------------------------------+
      | Tipo   | Enganches     | Familias | Propósito                                      |
      +========+===============+==========+================================================+
      | filter | Todos         | Todos    | Filtrar paquetes.                              |
      +--------+---------------+----------+------------------------------------------------+
      | nat    | | preroting,  | | ip,    | Realizar operaciones de |NAT|. Sólo se         |
      |        | | input,      | | ip6,   | se aplica sobre el primer paquete              |
      |        | | output.     | | inet   | de la conexión.                                |
      |        | | postrouting |          |                                                |
      +--------+---------------+----------+------------------------------------------------+
      | route  | | ip,         | output   | Modificar la cabecera o la marca del paquete   |
      |        | | ip6         |          | para afectar a la decisión de encaminamiento   |
      |        |               |          | que se produce tras *output* (sólo             |
      |        |               |          | :program:`nftables`)\ [#]_.                    |
      +--------+---------------+----------+------------------------------------------------+

   Por último, si resumimos las características de una cadena:

   - Una *cadena de usuario* se caracteriza por su nombre y su política
     predeterminada.
   - Una *cadena base* se caracteriza por:

     * Su nombre.
     * El tipo de reglas que contiene.
     * A donde se engancha.
     * Su prioridad.
     * Su política predeterminada.

.. _netfilter-hooks:

:dfn:`Enganche` (*hook*)
   Son los puntos dentro del flujo en los cuales pueden analizarse y
   manipularse paquetes. Tomando como referencia el `diagrama de Craoc
   <https://www.craoc.fr/articles/nftables/#packet-flow>`_ estos son los
   enganches posibles\ [#]_:

   .. image:: files/netfilter-flow.png

   Entiéndase que un paquete puede aparecer:

   - Porque se recibe a través de una interfaz (*PAQUETE ENTRANTE*).
   - Porque lo genera un proceso local (*PAQUETE CREADO*).

   Por tanto, cualquier debate sobre cuál es el camino que sigue un paquete debe
   comenzar en el extremo izquierdo (*PAQUETE ENTRANTE*) o en la etiqueta de
   proceso local (*PAQUETE CREADO*). Partiendo de uno de esos puntos, basta
   con ir respondiendo a las preguntas que se formulan en los puntos de
   bifurcación (*rombos anaranjados*). Por ejemplo, la petición de un navegador
   cliente a nuestro servidor web:

   #. Entrará por la interfaz fisica.
   #. Como no es tráfico |ARP|, pasará por el enganche *ingress*.
   #. Si la interfaz física no estaba asociada a una interfaz *bridge*,
      alcanzará el enganche *prerouting* naranja pálido.
   #. Como somos el destino del paquete (la |IP| de destino coincide con nuestra
      direccion |IP|), el paquete llegará al enganche *input*.
   #. Si no lo filtramos de ninguna manera, alcanzará el proceso local, esto es,
      el servidor web.

   Del mismo modo, la respuesta del servidor web:

   #. Partirá del servidor web (proceso local).
   #. Llegará al enganche *output*, donde (más nos vale) no se filtrará.
   #. Como el cliente es externo, alcanzará el enganche *postrouting*.
   #. Si la interfaz de salida no es un *bridge*, saldrá por ella\ [#]_.

.. _netfilter-tables:

:dfn:`Tabla` (*table*)
   Son, simplemente, conjuntos de cadenas.

Conexión
========
Al ser :program:`netfilter` un :ref:`cortafuegos de filtrado dinámico
<fw-stateful>`, cuando analiza un paquete, es capaz de de tener en cuenta
su contexto, esto es, de tener el cuenta que el paquete forma parte de una
conexión.  En realidad, de los tres protocolos de capa de transporte (|TCP|,
|UDP| e |ICMP|) sólo |TCP| es un protocolo orientado a conexión.
:program:`netfilter`, no obstante, implementa un seguimiento de conexión común a
los tres. A sus ojos, al conectarse un cliente con un servidor ocurre lo
siguiente:

#. El *cliente*, usando un puerto aleatorio por encima del 1024 inicia una
   petición a un puerto prefijado del servidor (el paquete inicial tendrá estado *NEW*).
#. El *servidor*, responde a esa petición usando el mismo canal de comunicación,
   con un paquete de estado *ESTABLISHED*.
#. El resto de paquetes de la conexión son *ESTABLISHED*.

Esquemáticamente, este podría ser un ejemplo:

.. image:: files/conexion.png

En la figura se ha representado el establecimiento de una conexión |TCP|.
Obsérvese que, aunque desde el punto de vista del protocolo, el establecimiento
se logra después de las tres comunicaciones representadas, desde el punto de
vista del cortafuegos  solamente la primera comunicación es *NEW*, todas las
demás se consideran paquetes de una conexión establecida. Para el tráfico |UDP|
e |ICMP|, el esquema es exactamente el mismo: la primera comunicación entre
cliente y servidor es *NEW* y el resto *ESTABLISHED*.

.. https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture

Herramientas de usuario
=======================
Ya se ha indicado que existes dos: la antigua :program:`iptables` y su sustituta
:program:`nftables`. Ambas toman los conceptos anteriores dado que utilizan el
mismo *framework*, por lo que tienen mucho en común, pero difieren en la
sintaxis y en la mayor indefinición inicial de :program:`nftables`.

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*/index

.. rubric:: Enlaces de interes

* `La wiki de nftables
  <https://wiki.nftables.org/wiki-nftables/index.php>`_.
* `Artículo en Craoc Wiki <https://www.craoc.fr/articles/nftables/>`_.
* `Tutorial de la wiki de Archilinux
  <https://wiki.archlinux.org/index.php/Nftables>`_.
* `Tutorial de la wiki de Gentoo
  <https://wiki.gentoo.org/wiki/Nftables>`_.
* `Presentación de desarrolladores de netfilter en la Cybercamp 2018
  <https://cybercamp.es/sites/default/files/contenidos/videos/adjuntos/cybercamp18_b06_laura_garcia_liebana_0_0.pdf>`_.

.. rubric:: Notas al pie

.. [#] La fecha de redacción de este párrafo es enero de 2020 y
   :program:`nftables` se incluyó por primera vez en el núcleo en 2014.

.. [#] De los módulos descritos en estos apuntos, no tiene soporte directo
   *recent* y su funcionalidad debe implementarse directamente usando
   :command:`nft`.

.. [#] La existencia de estas prioridades predefinidas deriva de que en
   en :program:`iptables` las cadenas ya están definidas y, en consecuencia,
   también se encuentan `predefinidas las prioridades de éstas
   <https://wiki.nftables.org/wiki-nftables/index.php/Configuring_chains#Base_chain_priority>`_.
   En :program:`nftables` no es así y puede usarse cualquier número, pero a
   partir de la versión v0.9.1, se han predefinido los nombres que pueden verse
   para representar las prioridades predefinidas existentes en
   :program:`iptables`.  Véase la página de manual de :manpage:`nftables(8)` o
   el `texto que acompaña
   <http://git.netfilter.org/nftables/commit/?id=c8a0e8c90e2d1188e6fcdd8951b295722e56d542>`_
   la aceptación del parche.

.. [#] Es indispensable leer las `aclaraciones de Croac
   <https://www.craoc.fr/articles/nftables/#route-chaine-type>`_.

.. [#] Este diagrama no coincide exactamente con `el que proporciona Jan
   Engelhardt en la Wikipedia
   <https://commons.wikimedia.org/wiki/File:Netfilter-packet-flow.svg>`_,
   pero las pruebas corroboran que es más fiable el redibujado, como el autor
   original advierte en su *wiki*. Para hacer usted mismo las pruebas puede
   tomar un *Linux* con su interfaz física conectada a una interfaz *bridge*,
   cargar :download:`estas reglas <files/nftables-flow>`, y enviar un paquete
   |ICMP| a la máquina y enviar otro desde ella. El orden de paso por las
   cadenas (y en consecuencia por los enganches) debe quedar reflejado en el
   registro del sistema.

.. [#] En *egress qdisc* es el momento de aplicar las políticas de :ref:`calidad de
   servicio <qos>`.

.. |ARP| replace:: :abbr:`ARP (Address Resolution Protocol)`
.. |NAT| replace:: :abbr:`NAT (Network Address Translation)`
.. |ICMP| replace:: :abbr:`ICMP (Internet Control Message Protocol)`
.. |TCP| replace:: :abbr:`TCP (Transmission Control Protocol)`
.. |UDP| replace:: :abbr:`UDP (User Datagram Protocol)`
