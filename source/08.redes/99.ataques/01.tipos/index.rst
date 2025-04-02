.. _tipos-ataque:

Tipos
*****
Las redes informáticas están sometidas a innumerables ataques de muy distinta
naturaleza que podemos clasificar del siguiente modo:

**Pasivos**
   Son aquellos que acceden a la información trasmitida sin alterarla en
   absoluto. Dentro de los *ataques pasivos* se encuentran los ataques:

   1. De **intercepción**:
      Son ataques que extraen información de la comunicación sin entorpecerla
      ni, por tanto, causar daño directo. La :ref:`monitorización de tráfico
      <sniffing>` es un típico ataque de **intercepción**.

      .. image:: files/intercepcion.png

**Activos**
   Son aquellos que producen cambios en la información transmitida. Pueden
   distinguirse, dentro de ellos, los siguientes tipos de ataques:

   2. De **interrupción**:
      Son aquellos que provocan la suspensión de un servicio. Suele
      denominárseles ataques |DoS| (ataques de denegación de servicio). Estos
      ataques muy comúmente no parten de una misma máquina, sino de un enjambre
      de ellas por lo que es muy común el uso del termino |DDoS| (|DoS|
      distribuido). Se profundizará :ref:`más adelante en ellos <DoS>`.

      .. image:: files/interrupcion.png

   3. De **modificación**:
      Son ataques en que el atacante se sitúa entre cliente y servidor con el
      propósito de alterar los mensajes que se envían entre ellos a fin de
      obtener un beneficio. Trataremos algunas técnicas :ref:`en un apartado
      posterior <mitm>`.

      .. image:: files/modificacion.png

   4. De **generación**:
      Consiste en generar mensajes fraudulentos desde la máquina atacante que la
      víctima cree que proceden de otra con la que pretende comunicarse. Un
      típico ataque de generación es el :ref:`envenenamiento ARP que estudiaremos
      más adelante <arp-spoofing>`.

      .. image:: files/generacion.png

Por otro lado todos aquellos ataques en que el atacante logra situarse en mitad
de la conversación (o sea, cualquier ataque de *intercepción* o de *modificación* o
uno de generación cuyo objetivo sea provocar que el atacante acabe atrayendo
hacia sí la conversación) reciben el nombre de :dfn:`ataques de intermediario` o
ataque |mitm| (muy comúmente nombrado por sus siglas *MitM*).

.. |DoS| replace:: :abbr:`DoS (Denial of Service)`
.. |DDoS| replace:: :abbr:`DDoS (Distributed Denial of Service)`
.. |MitM| replace:: man-in-the-middle.
