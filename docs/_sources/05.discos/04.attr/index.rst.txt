.. _attrs:

Atributos
=========
Los sistemas de archivos permiten asociar a cada archivo un conjunto de
atributos, que tienen diversa utilidad.

.. _xattr:

Atributos extendidos
--------------------
Un :dfn:`atributo extendido` es una pareja clave/valor asociada a un
determinado archivo. La mayor parte de los sistemas de archivos utilizados en
*Linux* los soportan. Existen cuatro tipos (cada uno asociado a un espacio de
nombres distinto):

Atributos extendidos de seguridad (*security*)
   Son atributos que utiliza los módulos de seguridad del kernel como SELinux_.

Atributos extendidos de sistema (*system*):
   Se utilizan para implementar las :ref:`ACL <acls>`, por lo que se manipulan a
   través de las herramientas propias de manipulación de listas de control de
   acceso.

Atributos extendidos de confianza (*trusted*):
   Son atributos solamente accesibles para los procesos que tiene la
   :ref:`capacidad <capabilitites>` *CAP_SYS_ADMIN*.

Atributos extendidos de usuario (*user*):
   Son atributos definidos a volutad por el usuario sobre archivos regulares y
   directorios. Son estos atributos a los que dedicaremos el epígrafe.

.. seealso:: Para más información consulte la página de manual de
   :manpage:`xattr(7)`.

Para poder definidor *atributos extendidos de usuarios* se precisan dos
requisitos:

   + Que el sistema de archivos los soporte y los tenga habilitados (lo cual es
     lo habitual en sistemas de archivos modernos)::

      $ grep xattr /proc/fs/ext4/sda1/options
      user_xattr

   + Tener instalado el paquete *attr*::

      # apt install attr

El paquete proporciona las herramientas básicas para manipular los atributos
extendidos de usuario::

.. _attr:
.. index:: attr

:command:`attr`
   Consulta y define (exclusivamente) archivos extendidos de usuarios::

      $ touch archivo
      $ attr -qs autor -V "Perico de los Palotes" archivo
      $ attr -qs desc -V "Un archivo vacio" archivo

   Esto ha fijado dos atributos: *autor* y *desc* (de descripción). Los
   atributos son arbitrarios, así que pueden usarse cualquier nombre. Podemos
   consultados también con :command:`attr`::

      $ attr -ql archivo
      autor
      desc
      $ attr -qg autor archivo
      Perico de los Palotes

   También pueden borrarse atributos ya creados::

      $ attr -qr autor archivo
      $ attr -ql archivo
      desc

   .. note:: Dado que la orden sólo manipula atributos extendidos de usuario, se
      prescinde por completo de la expresión del espacio de nombres *user*, que
      es dentro del cual se definen este tipo de atributos extendidos

.. _setfattr:
.. _getfattr:

El paquete *attr* también incluye los programas :command:`setfattr` y
:command:`getfattr`, que permiten fijar, borrar y consultar permisos.

.. warning::
   Cuando se usan :command:`setfattr` y :command:`getfattr` a los nombres
   de los atributos se les debe añadir la expresión del espacio de nombres
   *user*: *user.autor*, *user.desc*, etc.

.. _ext4-fattr:

Atributos de archivo
--------------------
Cada archivo de **ext4** tiene asociado un conjunto de *flags*, que reciben el
nombre de :dfn:`atributos de archivo` y que afectan al comportamiento según se
activen o desactiven. No son en modo alguno permisos, aunque alguno de estos
atributos influye en la capacidad del usuario para modificar o eliminar su
información. Para manipularlos es necesario ser *administrador*.

.. _lsattr:
.. index:: lsattr

:command:`lsattr`
   Sirve para comprobar cuáles son los atributos que tiene asignados el
   archivo::

      $ lsattr archivo
      -------------e-- archivo

   Sólo tiene activo el atributo ``e``\ [#]_.

.. _chattr:
.. index:: chattr

:command:`chattr`
   Permite modificar el atributo con un signo ``+`` para activarlo y con un
   signo menos para desactivarlo. Por ejemplo, para hacer inmutable el archivo
   (lo cual implica que sea imborrable)::

      # chattr +i archivo
      # lsaatr archivo
      ----i--------e-- archivo

   Hecho esto, será imposible alterar de forma alguna el archivo, incluso siendo
   administrador::

      # rm archivo
      rm: no se puede borrar «archivo»: Operación no permitida
      # echo "GGGGG" >> archivo
      -su: archivo: Permiso denegado


.. rubric:: Notas al pie

.. [#] Todos los atributos disponibles y su explicación correspondiente se
       encuentran disponibles en la página de manual de :manpage:`chattr`.

.. _SELinux: https://www.redhat.com/es/topics/linux/what-is-selinux
