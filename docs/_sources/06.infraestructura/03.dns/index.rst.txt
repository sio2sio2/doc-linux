.. _dns:

DNS
===
En los protocolos |TCP|/|IP| cada máquina está identificada por su dirección
|IP| que es una dirección numérica de 32 *bytes*\ [#]_. Este modo de identificar
máquinas, no obstante, no es natural al ser humano, que es capaz de recordar más
fácilmente palabras. Por este motivo, desde un principio se previno un modo de
asociar nombres a las direcciones numéricas. En los orígenes de Internet el
mecanismo era muy sencillo: un fichero que listaba en cada una de sus líneas la
relación entre cada dirección |IP| y cada nombre. Este fichero, sigue existiendo
en los sistemas operativos modernos, se llama :file:`hosts` y se corresponde en
los sistemas *UNIX* con :file:`/etc/hosts` y con
:file:`C:\\Windows\\System32\\drivers\\etc\\hosts` en los sistemas *Windows*. En
estos orígenes las máquinas no era muchas y bastaba con que los equipos
intercambiaran este fichero.

Su sintaxis es muy sencilla. Cada línea consta de un primer campo con la
dirección |IP| y uno o más campos que contienen todos los nombres asociados a
dicha dirección. Para separar las campos puede usarse uno o más espacios o
tabulaciones::

   127.0.0.1      localhost.localdomain     localhost
   192.168.0.1    router.lan.info           router

Además,se permiten líneas de comentarios (las que empiezan con almohadilla).
Gracias a esto, la orden::

   $ ping localhost

es equivalente a::

   $ ping 127.0.0.1

El problema de esta solución tan simple es que cuando empezaron a proliferar las
máquinas, se volvió inviable y surgió |DNS|. Los sistemas operativos, no
obstante, siguen consultando el fichero :file:`hosts` antes de recurrir al
servidor |DNS| (merced a lo definido en :file:`/etc/nsswitch`), por lo que si se
hace algo como::

   127.0.0.1      localhost.localdomain      localhost      www.google.es

al hacer un ping a *www.google.es* no responderá el servidor de Google_, sino
nuestra propia máquina.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*


.. |TCP| replace:: :abbr:`TCP (Transmission Control Protocol)`

.. rubric:: Notas al pie

.. [#] en IPv4, claro está. En IPv6, las direcciones constan de 128 *bytes*.

.. _Google: https://about.google/
