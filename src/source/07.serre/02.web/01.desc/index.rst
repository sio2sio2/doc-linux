.. _http:

Descripción del protocolo
*************************
El protocolo |HTTP| es un protocolo sin estado (esto es, un protocolo
en que no se almacena información sobre conexiones anteriores) que consiste en
una petición del cliente y una respuesta del servidor.

La petición del cliente está constituida por:

* Un **método** de petición.
* Una **cabecera**, que contiene campos que informan al servidor de qué
  quiere obtenerse.
* Opcionalmente, un **cuerpo** que permite enviar datos al servidor.

La respuesta del servisdor consta de:

* Un **código**.
* Una **cabecera** constituida por campos que informa al cliente sobre algunos
  aspectos de la información que se proporciona.
* Opcionalmente, un **cuerpo** que contiene la información que pidió el cliente.

Para separar cabecera de cuerpo se usa una línea en blanco.

Hay básicamente tres versiones del protocolo:

* La versión **1.0**, que sólo implementa los métodos ``GET``, ``POST`` y
  ``HEAD``.
* La versión **1.1**, que es la más usada y añade mejoras y más comandos que la
  anterior.
* La versión **2**, que es relativamente reciente y empieza a ser usada en clientes y
  servidores. Añade mejoras en el empaquetado y transporte de datos, pero a
  efectos de la descripciòn hecha aquí no presenta diferencias con respecto a la
  anterior.

Por ejemplo, una conexión |HTTP| puede ser esta:

.. code-block:: console
   :emphasize-lines: 1, 5-7

   $ telnet www.example.com 80
   Trying 80.80.80.80...
   Connected to www.example.com.
   Escape character is '^]'.
   GET / HTTP/1.1
   Host: www.example.net

   HTTP/1.1 200 OK
   Server: nginx/1.10.3
   Date: Fri, 26 Jan 2018 18:30:26 GMT
   Content-Type: text/html
   Content-Length: 112
   Last-Modified: Fri, 19 Jan 2018 17:46:27 GMT
   Connection: keep-alive
   ETag: "5a622ef3-70"

   <!DOCTYPE html>
   <html>
           <head>
                   <title>Homepage</title>
           </head>
           <body>
                   <h1>Home Page</h1>
           </body>
   </html>
   Connection closed by foreign host.

Analicemos con  detenimiento:

* Las tres primeras líneas son un aviso de la orden :command:`telnet` de que
  hemos establecido conexión. Siemnpre son las mismas, así que nada tienen que
  ver con el protocolo que analizamos.

* Las dos siguientes lineas las hemos escrito nosotros y forman la petición::

   GET / HTTP/1.1
   Host: www.example.net

  La primera contiene el método ``GET``, que ya trataremos. Básicamente pide la
  página raíz del servidor e informa de que queremos comunicarnos en la versión
  1.1 del protocolo |HTTP|. La segunda línea es la escueta cabecera de la
  petición. Sólo hay un campo ``Host`` que informa al servidor web de cuál es el
  nombre con el que nos estamos conectando a él\ [#]_. Como el comando ``GET``
  no admite cuerpo, al dejar una línea en blanco acaba la petición.

* La linea::

   HTTP/1.1 200 OK

  es el código de respuesta enviado por el servidor: **200**, que implica que
  nuestra petición ha tenido éxito.

* El resto de líneas hasta la línea en blanco son los campos de cabecera que el
  servidor envía al cliente (típicamente el navegador) y que le proporcionan
  metainformación acerca de los datos que enviará luego en el cuerpo. Por
  ejemplo, ``Content-Type`` le informa al cliente de que lo que se proporciona
  es una página |HTML|.
   
* Tras la línea en blanco se encuentra el cuerpo de la respuesta que en este
  caso es una página web.

* Y, tras la petición y la respuesta, se da por finalizada la conexión.

Analicemos detenidamente cada una de las partes que componen petición y
respuesta y, además, estudiemos el concepto de |URL|

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*

.. rubric:: Notas al pie

.. [#] Obsérvese que el nombre ya se usa al escribir la orden :command:`telnet`,
   pero de ello sólo tiene información el propio :command:`telnet` que lo usa
   para resolver la *ip* numérica. Por tanto, si queremos que el servidor *web*
   reciba información sobre el nombre, debemos incluirlo en una cabecera.

.. |HTML| replace:: :abbr:`HTML (HyperText Markup Language)`
.. |URL| replace:: :abbr:`URL (Uniform Resource Locator)`
