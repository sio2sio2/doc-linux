.. _adm-rem:

Administración remota
=====================
Es común que el administrador del servidor no se siente físicamente junto a él
para configurarlo, sino que sus tareas de mantenimiento las realice a distancia
sentado sobre un ordenador distinto. Ello hace necesario disponer de una
terminal remota que habilite una sesión interactiva y que ofrezca al
administrador las mismas posibilidades que la terminal física.

Tradicionalmente, esta servicio lo vino desempeñando `telnet
<https://es.wikipedia.org/wiki/Telnet>`_, hasta que la inseguridad de la red lo
volvió poco recomendable y fue sustituido por |SSH|, que cifra la comunicación y
sortea sus problemas de seguridad, amén de tener algunas otras funcionalidades
muy útiles e interesantes.

Aunque el servicio sigue estando disponible (el paquete
`telnetd <https://packages.debian.org/es/stretch/telnetd>`_) no es en absoluto
recomendable instalarlo, dado que adolece de dos **problemas fundamentales de
seguridad**, comunes a todas las comunicaciones no cifradas:

**Intercepción** de la comunicación
   Al establecerse una comunicación no cifrada entre dos extremos, un tercero
   malicioso puede interceptar los paquetes y leerlos, extrayendo la información
   contenida en ellos. Esta información puede, por supuesto, incluir usuario y
   contraseña, que como el resto no van cifrados.

**Suplantación** de identidad
   También existe la posibilidad de suplantar la identidad del servidor, de modo
   que el cliente crea que se está conectado al servidor real, cuando en
   realidad se conecta a uno falso. Esto puede permitir al suplantador obtener
   también las claves de acceso al pedírselas al cliente.

Ambos problemas pueden evitarse mediante técnicas de cifrado híbrido, por lo que
en 1995, un finlandés llamado `Tatu Ylönen
<https://es.wikipedia.org/wiki/Tatu_Yl%C3%B6nen>`_ desarrolló la primera versión
del protocolo |SSH|\ [#]_, en principio, software libre. Apenas dos años después
de su creación, en 1997, el protocolo fue propuesto como estándar de la
:abbr:`IETF (nternet Engineering Task Force)`. La licencia, no obstante, cambio,
por lo que en 1999 el equipo de `OpenBSD
<https://es.wikipedia.org/wiki/OpenBSD>`_ comenzó la implementación más habitual
del servidor, `OpenSSH <https://es.wikipedia.org/wiki/OpenSSH>`_, que es la que
traen las distribuciones de linux en su sistema de paquetería.

El protocolo |SSH| ataja los dos problemas de seguridad gracias a su cifrado
híbrido que supone que:

#. Tras el establecimiento de la comunicación, el servidor envía al cliente su
   clave pública para que este pueda cotejarla y comprobar que no exite
   suplantación de identidad. Por supuesto, cotejarla implica conocerla de
   antemano y esto sólo es posible si el cliente se ha conectado anteriomente
   alguna vez. Si es la primera vez (y no media el crédito de ninguna entidad
   certificadora), el cliente tiene que hacer el acto de fe de creer que el
   servidor es quien dice ser, razón por la cual todos los clientes advierten
   del hecho y obligan al usuario a aceptar implícitamente la clave.

#. Con la clave pública del servidor el cliente cifra una clave simétrica de
   sesión, que envía al servidor. Este al recibirla la descifra y, una vez la
   clave de sesión se halla en ambos extremos, puede comenzarse una comunicación
   absolutamente cifrada que impide sacar provecho de la intercepción de la
   comunicación.

#. Asegurado el cifrado, el cliente se identifica en el servidor, bien a través
   de usuario y contraseña, bien a través del uso de certificado.

Nuestro plan de estudio de este servicio |SSH| incluirá los siguientes aspectos:

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

.. rubric:: Notas al pie

.. [#] Existe una segunda versión del protocolo que es la que se usa en la
    actualidad, ya que esta primer adolecía de un grave problema de seguridad y
    usaba algunos algoritmos bajo patente.
