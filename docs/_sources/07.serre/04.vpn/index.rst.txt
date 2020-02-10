.. _vpn:

Redes VPN
*********
Una red privada virtual (|VPN|) consiste en la conexión de dos nodos remotos,
(por lo general separados por la internet pública), de manera que ambos se
comporten como una única red local. Esto se logra estableciendo una conexión
virtual punto a punto. Dado que la comunicación atraviesa internet la
comunicación es cifrada y, además, se habilitan mecanismos para poder asegurar
la identidad del otro lado.

Conceptualmente una |VPN| consiste en un protocolo encapsulador que se encarga
de encapsular tráfico de otros protocolos, sin que estos aprecien, en realidad,
que están siendo transportados por el primero. Así, el establecimiento de un
túnel |VPN| genera interfaces virtuales en cliente y servidor que virtualmente
comunican ambos cómo si realmente un cable los comunicara; de manera que para
los protocolos encapsulados el viaje consiste en --aparentemente-- circular
entre estas interfaces.

Implementaciones
================
A diferencia de otros servicios como |HTTP| o |SMTP| en que existe un protocolo
y diversas implementaciones del mismo que, obviamente por principio, son
compatibles entre sí, |VPN| es más bien un concepto de encapsulamiento que
admite implementarse mediante distintos protocolos. Esto provoca que la elección
del servidor, implique qué solo puedan usarse aquellos clientes que implementen
el protocolo de éste.

:abbr:`PPTP (Point to Point Tunneling Protocol)` |VPN|
   Protocolo desarrollado por *Microsoft*, que incluyen todos los sistemas
   *Windows* y la mayoría de dispositivos de red que son capaces de crear
   túneles |VPN|. Es rápido y consume pocos recursos, pero por cuestiones
   de seguridad se desancoseja su uso.

IPSec |VPN|
   Estos protocolos utilizan IPSec (o sea, un cifrado en la capa de red) para
   asegurar el tráfico. Un protocolo muy usando dentro de está familia es `IKE
   v2
   <https://www.vpnunlimitedapp.com/en/info/more-about-vpn/vpn-protocols/ike-protocol>`_.
   
|SSL| |VPN|
   Protocolos |VPN| que usan el protocolo |SSL| de la capa de aplicación para
   lograr el cifrado. Pertenecen a esta familia, :abbr:`SSTP (Secure Socket
   Tunneling Protocol)` de Microsoft, y :ref:`OpenVPN`,  *software* que
   trataremos en estos apuntes.

|VPN| basada en *Noise*
  `Noise <http://www.noiseprotocol.org/>`_ es un *framework* para construir
  protocolos seguros a medida para la aplicación que se desea crear. Esto, en
  teoría, permite crear protocolos |VPN| más eficientes\ [#]_ que los basados en
  |SSL|. Uno de estos |VPN| es :ref:`Wireguard`,
  desarrollado en torno a *Linux* y que se incluirá oficialmente dentro de su
  núcleo `a partir de su versión 5.6
  <https://www.techradar.com/news/wireguard-vpn-protocol-will-ship-with-linux-kernel-56>`_.
  Dispone, además, de versiones para otros sistemas operativos como *Windows* o
  *MacOs*.

.. seealso:: Para más informacion puede echarse un ojo a `este enlace de ExpressVPN
   <https://www.expressvpn.com/es/what-is-vpn/protocols>`_ o `este otro de
   vpnMentor
   <https://es.vpnmentor.com/blog/comparacion-de-protocolos-de-vpn-pptp-vs-l2tp-vs-openvpn-vs-sspt-vs-ikev2/>`_.

Generalidades
=============

Definiciones
------------
Como comienzo es conveniente establecer una serie de terminos que usaremos a lo
largo de este documento.

:dfn:`Túnel VPN`
   Es la conexión punto a punto que se establece gracias al protocolo |VPN|.

:dfn:`Servidor VPN`
   Es la máquina configurada para quedar perennemente a la espera de las
   peticiones de establecimiento de túneles |VPN|.

:dfn:`Red local`
   Es la red en la que se encuentra el servidor |VPN|.

:dfn:`Cliente VPN`
   Es la máquina configurada para solicitar en cualquier momento el
   establecimiento del túnel |VPN|.

:dfn:`Red remota`
   Es la red a la que pertenece el cliente |VPN|.

Tipos
-----
Podemos hacer varias clasificaciones atendiendo a distintos criterios:

#. Según la naturaleza del cliente:

   :dfn:`Acceso remoto` o conexión :dfn:`sede-cliente móvil`
      Es la conexión que se establece entre una red y un dispotiivo remoto
      individual. En esta conexión la red dispone de un servidor |VPN|
      permanentemente accesible desde internet y el equipo remoto se conectará de
      modo intermitente a menudo desde distintas localizaciones. iEn la jerga
      habitual suele referirse el equipo remoto como *road warrior*.

      .. image:: 01.openvpn/files/roadwarrior.png

   Conexión :dfn:`sede-sede`
      Es la conexión permanente que se establece entre dos redes remotas en una de
      las cuales un dispositivo hace el papel de servidor y en la otra, otro el de
      cliente. Por lo general, estos dispositivos se corresponden con el router u
      otro disposivo en la red perimetral.

      .. image:: files/sede-sede.png

#. Según la capa de implementación:

   :dfn:`VPN en capa 2`
      Es aquella que establece el enlace en capa 2, por lo que ambos extremos
      del túnel se encontrarán en la mismna red lógica.

   :dfn:`VPN en capa 3`
      Es aquella que establece el enlace en capa 3, por lo que cada extremo del
      túnel se encontrará en una red lógica distinta y el propio túnel
      constituirá una tercera.

Encaminamiento
--------------
Antes de entrar en harina, es conveniente entender qué supone establecer un
túnel |VPN| entre cliente y servidor. Cuando se arranca el servicio en el
servidor, éste crea una interfaz virtual con una |IP| la cual es con la que
*virtualmente* establece comunicación con los clientes. Por su parte, cuando un
cliente negocia con éxito el establecimiento de un túnel, crea también una
interfaz virtual con otra |IP| de la misma red. Por tanto, es como si
*virtualmente* hubiéramos tendido un cable entre ambas máquinas y hubiéramos
conectado con él las dos interfaces virtuales.

Es obvio que los paquetes, en realidad, seguirán saliendo y llegando por las
interfaces reales y que cada máquina los enviará a las puertas de enlace
respectivas. Pero toda esta realidad es absolutamente transparente para el
usuario y el tráfico encapsulado, de manera que si el servidor tiene |IP|
virtual *10.8.0.1* y el cliente |IP| virtual *10.8.0.2*, para saber desde el
cliente si el servidor está *ahí* basta con hacer::

   $ ping 10.8.0.1

Es obvio también que, si el cliente quiere alcanzar equipos de la red local al
servidor, lo tiene que hacer a través de la |IP| *10.8.0.1* del servidor y que
si quiere que su comunicación con internet se haga a través del túnel |VPN| su
puerta de enlace será directamente la *10.8.0.1*\ [#]_. Por tanto las tablas de
encaminamiento del cliente deben variar al establecer el túnel.

La entrada para la red del túnel |VPN| (la *10.8.0.0/24* en el ejemplo) se
creará al crear la interfaz, pero cualquier otra debe añadirse mediante
configuración del propio *software* |VPN|.

Estudio práctico
================
Estudiaremos dos implementaciones del concepto:

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*/index

Además de implementar nosotros mismos el servidor, existen distintos servicios
en internet (por lo general de pago) que proporcionan servicio |VPN|, esto es,
servidores |VPN| dispuestos a lo largo del mundo a los que podemos conectar con
un cliente a fin de burlar algún tipo de censura u ocultar la identidad, aunque
el proveedor del servicio |VPN| sí sepa quién somos o, al menos, disponga de
nuestra |IP| para que se pueda llegar a saber quién somos. `VPNbook
<https://www.vpnbook.com/>`_, con el que podemos usar :ref:`OpenVPN <openvpn>`,
ofrece este servicio de forma gratuita.

.. rubric:: Notas al pie

.. [#] En `este repositorio de Github
   <https://github.com/noiseprotocol/noise_spec/wiki/Noise-properties-and-protocol-comparisons>`_
   hay comparaciones con otros protocolos seguros.

.. [#] Con una notable diferencia: alcanzar la |IP| del servidor tendrá que
  seguir haciéndose por la puerta de enlace real. De lo contrario, no funcionará
  nada, ya que recordemos que con túnel o sin túnel los paquetes, en realidad,
  siguen saliendo por la puerta de enlace real.

.. |SSL| replace:: :abbr:`SSL (Secure Sockets Layer)`
