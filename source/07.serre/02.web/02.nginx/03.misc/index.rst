Recetas
=======
Este apartado de *recetas* se dedica a dar instrucciones de cómo instalar en
:program:`nginx` y configurar mínimamente algunas aplicaciones web escritas en
|PHP|. En cualquier caso, sea cual sea la aplicación, su instalación siempre se
ajusta a un mismo esquema que podemos resumir en los siguientes pasos:

0. **Preparación del servidor web**

   Debemos tener instalado y en funcionamiento :program:`nginx`, |PHP| y un
   |SGBD| (my\ |SQL|, en nuestro caso) y habernos asegurado previamente de que
   es :ref:`capaz de ejecutar código PHP <nginx-php>`.

#. **Instalación de la aplicación**

   Consistirá en obtenerla de internet y dejarla en un directorio adecuado
   (nosotros usaremos un subdirectorio de :file:`/srv/www` para seguir las
   directrices del FHS_)\ [#]_.

#. Configuración de la **base de datos**

   Normalmente hay involucrado un |SGBD|. Las aplicacione suelen soportar varios
   y casi todas ellas my\ |SQL|. En esta configuración podemos distinguir tres
   pasos distintos:

   a. Creación de un usuario con permisos de lectura y escritura.
   #. Creación de la base de datos.
   #. Creación del esquema en la base de datos, esto es, las tablas que la
      componen.

   El primer paso siempre es manual y para my\ |SQL| se reduce a ejecutar en su
   consola:

   .. code:: sql

      GRANT ALL PRIVILEGES ON nombre_base.* TO 'usuario_base'@'localhost' IDENTIFIED BY 'contraseñadificil';

   "*nombre_base*" es el nombre de la base de datos (que en el caso de my| SQL|
   no necesita estar previamente creada), "*usuario_base*", el nombre del
   usuario y "*contraseñadificil*", su contraseña. Deberemos recordar estos tres
   datos porque los necesitaremos más adelante.

   El segundo paso suele ser manual, aunque a veces toca hacerlo también a mano
   en su consola:

   .. code:: sql

      CREATE DATABASE nombre_base;

   El tercer paso, en cambio, suelen hacerlo las propias aplicaciones en su
   configuración manual. En algunas más simples no es así, y proporcionan un
   guión |SQL| para que lo ejecutemos nosotros mismos en la terminal::

      # mysql nombre_base < guion.sql

#. **Configuración del servidor web**

   esto es, crear en :file:`/etc/nginx/sites-available` un archivo de
   configuración adecuado. Por lo general, es una variante de :ref:`nuestro ejemplo
   mínimo <nginx-php-minimo>` al que la complejidad de la aplicación exigirá
   añadir más o menos líneas. Lo habitual es que nos proporcione información la
   propia documentación oficial o encontremos ejemplos de este archivo en
   tutoriales de internet.

#. **Configuración inicial** de la aplicación.

   Tal configuración suele limitarse a acceder a la aplicación a través de la
   web (para lo cual habrá que haber hecho el paso anterior) y al detectar el
   *software* que se accede por primera vez y aún no hay un configuración
   inicial desencadenerá el proceso de configuración en vez de ejecutar
   normalmente la aplicación.

   En algunos casos, antes de este primer acceso, la documentación de la
   aplicación, además, nos exigirá que editemos un archivo de configuración. En
   algunos casos, cuando la aplicación es relativamente sencilla, esta edición
   será la única configuración inicial y al acceder a la aplicación por primera
   vez, se nos mostrará ya funcional.

   Es en la configuración inicial donde deberemos proporcionarle a la aplicación
   los datos de conexión a la base de datos, esto es, el nombre de la base de
   datos y el usuario y contraseña de acceso.

.. note:: Es un buen ejercicio al repasar las recetas que proporcionamos a
   continuación, intentar identificar estos pasos en ellas.

.. warning:: Para la confección de estas recetas, cuando la configuración exige
   tráfico seguro, se ha usado la :ref:`configuración con certificado
   autofirmado <auto-cert>`, aunque no es la recomendable. Se obra así, porque para
   realizar pruebas de instalación en máquinas virtuales, es lo más cómodo.
   Cambiar la configuración para usar :ref:`certificados confiables
   <nginx-https>` es, no obstante, trivial.

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*

.. rubric:: Notas al pie

.. [#] *Debian* tiene paquete para algunas de estas aplicaciones y, por lo
   general, la instalación del paquete correspondiente hará una instalación y
   configuración mínimas automatizadas con el fin de que la aplicación funcione
   sin que el administrador haga nada más allá del :ref:`apt <apt>`. Sin
   embargo, evitaremos esta solución y siempre mostraremos la instalación de la
   aplicación descargada desde su página web.


.. _FHS: https://www.pathname.com/fhs/
.. |PHP| replace:: :abbr:`PHP (PHP Hypertext Preprocessor)`
.. |SQL| replace:: :abbr:`SQL (Structured Query Language)`
.. |SGBD| replace:: :abbr:`SGBD (Sistema Gestor de Bases de datos)`
