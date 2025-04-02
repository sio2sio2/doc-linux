.. _serv-directorio:

Servicio de directorio
======================

En una red real se encuentran por lo común varios equipos (que pueden no tener
idéntico sistema operativo), varios usuarios y varios recursos (impresoras, por
ejemplo). En ella, si imperase la desorganización, los equipos apenas serían
capaces de acceder a Internet (basta con *dejarse hacer por el router*) y el
resto sería un completo caos:

* Sólo se podría imprimir desde algunos equipos
* Cada ordenador tendría sus propios usuarios, porque el que habitualmente se
  sienta en él lo convirtió en su pequeño cortijo, con lo que podría darse el
  caso de que otro individuo desconociera cómo poder entrar en él
  para usarlo en caso de que se hubiera estropeado el suyo o recuperar algún
  fichero.
* Compartir ficheros consistiría en un ir y venir de memorias |USB| o en un
  envío de ficheros a través de correo electrónico que implica subir a
  internet y bajar de ella, cuando los dos equipos se encuentran a tres
  metros de distancia.

Para evitar todos estos inconvenientes existen los llamados servicios de
directorio cuya misión es:

#. Centralizar la información sobre usuarios de la red.
#. Organizar los recurso de red (ficheros, impresoras).
#. Gestionar el acceso de los usuarios a tales recursos.

Gracias a ellos, se podría llegar a tener una red:

#. En que los usuarios son compartidos por toda la red, de manera que
   cualquier cuenta es válida en cualquier equipo.
#. Los usuarios podrán almacenar su directorio personal en el servidor,
   para que esté disponible con independencia del equipo frente al que se
   siente.
#. Existen directorios de ficheros accesibles desde la red en los que los
   usuarios podrán dejar ciertos documentos para que otros puedan
   obtenerlos.
#. Se podrán imprimir desde cualquier punto de la red.
#. Tanto el acceso a los directorios compartidos como a la impresión estarán
   fiscalizados de manera que habrá políticas de acceso que definen quiénes y
   cómo pueden usar esos recursos.

Los tres servicios de directorio más utilizados son `Novell eDirectory
<https://www.netiq.com/products/edirectory/>`_, el `Directorio Activo
<https://es.wikipedia.org/wiki/Active_Directory>`_ de *Microsoft* (:abbr:`AD
(Active Directory)` por sus siglas en inglés) y `OpenLDAP
<https://es.wikipedia.org/wiki/OpenLDAP>`_, habitual en los sistemas *UNIX*. Los
tres servicios de directorio son compatibles con el estándar |LDAP|.

Trataremos aquí Open\ |LDAP|, que es una excelente alternativa cuando la red se
compone exclusivamente de clientes *UNIX*, y `Samba <https://www.samba.org/>`_,
que lo es cuando interoperan sistemas *UNIX* con *Windows*, ya que es una
implementación libre del *Directorio Activo* de *Microsoft*.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*/index

.. |USB| replace:: :abbr:`USB (Universal Serial Bus)`
