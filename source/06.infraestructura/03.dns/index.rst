.. _dns:
.. _etchosts:

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

Sea como sea, el problema de :file:`/etc/hosts` surgió cuando empezaron a
proliferar las máquinas, se volvió inviable y surgió |DNS|, que es el servicio
que desarrollaremos durante el epígrafe. Pese a ello, el archivo no está
olvidado. En los sistemas *Linux* el archivo :file:`/etc/nsswitch.conf` define
cuáles son las fuentes para obtener nombres de máquinas::

   $ grep '^hosts:' /etc/nsswitch.conf
   hosts:          files mdns4_minimal [NOTFOUND=return] dns mymachines

Hay cuatro, cuya preferencia viene determinada por el orden en que aparecen:

#. *files*, que se refiere precisamente al archivo :file:`/etc/hosts`.
#. *mdns4_minimal*, que es el protocolo |mDNS| para redes locales (:rfc:`6762`)
   y que no requiere servidor alguno. Sus nombres siempre pertenecen al dominio
   ".local".
#. *dns*, que es precisamente el protocolo |DNS|.
#. *mymachines*, que proporciona :ref:`systemd <systemd>`.

Por tanto, un máquina cuando deba averiguar la dirección de otra revisará antes
de cualquier otra fuente  el archivo :file:`/etc/hosts`. Por ello, si
modificaramos la línea::

   127.0.0.1      localhost.localdomain     localhost   www.google.com

seríamos incapaces de conectar con el servidor de *Google*, porque habríamos
hecho creer al sistema que *Google* es nuestra propia máquina.


.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*


.. |TCP| replace:: :abbr:`TCP (Transmission Control Protocol)`
.. |mDNS| replace:: :abbr:`mDNS (Multicast DNS)`

.. rubric:: Notas al pie

.. [#] en IPv4, claro está. En IPv6, las direcciones constan de 128 *bytes*.

.. _Google: https://about.google/
