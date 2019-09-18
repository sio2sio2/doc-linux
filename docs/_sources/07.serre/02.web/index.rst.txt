.. _web:

Web
===
El servicio web (y su protocolo asociado, |HTTP|) se ha convertido en el
servicio ofertado más importante de internet. Las causas son diversas: su desempeño
como medio para compras electrónicas, gestiones administrativas u operativa
bancaria; la aparición de redes sociales y la asunción de funciones que previamente ya
ofertaban otros servicios\ [#]_. De hecho, los navegadores se han convertido
en entornos capaces de ejecutar aplicaciones bastantes complejas (procesadores,
hojas de calculo, etc.)

Sin embargo, todo esto no fue en principio así. En los años ochenta, `Tim Berners-Lee
<https://es.wikipedia.org/wiki/Tim_Berners-Lee>`_ trabajaba en el `CERN <Conseil
Européen pour la Recherche Nucléaire>`_ y le surgió la idea de crear lo que él
llamó :dfn:`hipertexto`. Cualquier publicación científica requiere siempre una
ingente cantidad de referencia a publicaciones anteriores y la consulta de estos
textos es engorrosa, ya que hay que tomar la referencia bibliográfica y acudir a
una biblioteca, buscar el libro y leer la fuente. Así que pensó una forma de que
hacer fácilmente disponible todo este conocimiento común y llegó a la idea del
:dfn:`hiperenlace`: pulsar sobre él lleva directamente a la referencia citada y
hace la divulgación científica infinitamente más sencilla y accesible.

Así pues, esta fue la idea original en la que se basó el servicio web: buscar
un servicio que permitiera enlazar entre sí textos estáticos distribuidos a lo
largo del mundo. Es importante tener esto presente, porque tal concepción
influyó en la definición del protocolo |HTTP|.

Con todo esto en mente, *Tim Berners-Lee* diseñó en 1989 el protocolo |HTTP| y
desarrolló para él el primer navegador web (llamado `WorldWideWeb
<https://es.wikipedia.org/wiki/WorldWideWeb>`_) y el primer servidor web (`httpd
<https://en.wikipedia.org/wiki/CERN_httpd>`_). Además se requirió la creación
de un lenguaje de marcas, |HTML|, que permitiera la escritura del *hipertexto*.
El 6 de agosto de 1991 se puso en linea la primera página web en la dirección
`http://info.cern.ch/hypertext/WWW/TheProject.html
<http://info.cern.ch/hypertext/WWW/TheProject.html>`_.

Desde entonces el concepto de la *World Wide Web* ha evolucionado muchísimo y,
tras un comienzo bastante anárquico con una incesante carrera por añadir
extensiones a los estándares (véase la `Guerra de los navegadores
<https://es.wikipedia.org/wiki/Guerra_de_navegadores>`_), se ha acabado por
imponer la fidelidad a éstos, que publica el |W3C|.

EL protocolo |HTTP| se basa en la comunicación entre clientes (los llamados
*navegadores web*) y servidores, que escuchan en el puerto *80/TCP*. Como
ocurrió con otros protocolos, la necesidad de asegurar la información, provocó
la aparición del |HTTP|\ s, esto es, del protocolo |HTTP| encapsulado en
|SSL|/|TLS|.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*/index

.. rubric:: Notas al pie

.. [#] Por ejemplo, los foros cumplen la misma función que las listas de correo
   o los `grupos de noticias <https://es.wikipedia.org/wiki/Grupo_de_noticias>`_.
   Asimismo, las interfaces *web* para consulta de correo han ocupado gran parte
   del nicho de los clientes de correo.
   
.. |HTML| replace:: :abbr:`HTML (HyperText Mark-up Language)`
.. |W3C| replace:: :abbr:`W3C (World Wide Web Consortium)`
.. |SSL| replace:: :abbr:`SSL (Secure Sockets Layer)`
.. |TLS| replace:: :abbr:`TLS (Transport Layer Security)`
