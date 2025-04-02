.. _scripts:

Programación de *scripts*
*************************
*UNIX* posee una *shell* con «*potentes*» lenguajes de programación. Entendamos
*potentes* en el sentido de que permiten hacer bastantes cosas y no de que
tengan unas características equiparables a un lenguaje de propósito general\
[#]_.

La *shell* más usada en el mundo *linux* es *bash*, aunque esto es sólo una
verdad a medias. Lo es para el uso interactivo, pero en las derivadas de
*debian*, la *shell* para la ejecución de *script* no interactivos es
:command:`dash`, una variante de `almquist shell
<https://en.wikipedia.org/wiki/Almquist_shell>`_, que se caracteriza por ser
mucho más liviana y no disponer de muchas de las características extendidas\ [#]_.
Entendamos que ambas tienen una base común (el estándar *POSIX*), pero que
:command:`bash` implementa algunas extensiones de las que carece
:command:`dash`, por lo que todo lo que sea escrito para :command:`dash`,
funciona en :command:`bash`, pero no al revés.

Antes de empezar, es importante remarcar que la programación de *scripts* no
tiene excesiva complicación desde el punto de vista de la pura programación: la
programación es estrictamente estructurada, no hay muchas estructuras de control
y las estructuras de datos que podemos crear son bastante escasas\ [#]_. De
hecho, programar un *script* no es más que automatizar una tarea que ya sabemos
de antemano hacer, así que la verdadera dificultad radica en saber hacer esta
tarea, es decir, en conocer suficientemente el sistema. Por ejemplo, en estos
mismo apuntes, para la gestión remota de servidores, se :ref:`propone un script
<ssh-no-interactivo>`, que utiliza la contraseña de usuario proporcionada
durante la autenticación para desbloquear la clave privada de acceso a un un
servidor |SSH| remoto: esto permite conectarse al servidor sin necesidad de
introducir clave adicional alguna. La dificultad del *script* no está tanto en
la programación, que es bastante sencilla, sino en saber que para ello es
necesario manipular el proceso de autenticación en el sistema y saber cómo
hacerlo. es decir, saber :ref:`cómo funciona pam <pam>`. Dicho de otro modo,
para que la *programación de scripts* sea útil es imprescindible primero conocer
más que superficialmente el sistema.

.. warning:: :command:`bash` es una pésima elección para aprender a programar\
   [#]_. Estos apuntes supondrán que se tienen al menos unos conocimientos
   modestos de programación estructurada.

Descompondremos el breve curso en:

.. toctree::
   :glob:
   :maxdepth: 2

   [01][0-5]*
   06.misc/index
   07.ejercicios

.. rubric:: Enlaces de interés

#. `Estándar POSIX <http://pubs.opengroup.org/onlinepubs/9699919799/>`_
#. `Rich’s sh (POSIX shell) tricks <http://www.etalabs.net/sh_tricks.html>`_
#. `Manual de referencia de Bash <https://www.gnu.org/software/bash/manual/html_node/index.html>`_
#. `The Bash Hacker Wiki <http://wiki.bash-hackers.org/start>`_
#. `Guía de programación avanzada con bash
   <http://www.tldp.org/LDP/abs/html/index.html>`_
#. `Greg's wiki <http://mywiki.wooledge.org/>`_, que, además de mucha otra
   información, incluye `una colección de errores habituales
   <http://mywiki.wooledge.org/BashPitfalls>`_ al programar en :program:`bash` la
   mayor parte de los cuales son extensibles a la programación en el estándar
   *POSIX*.

.. rubric:: Notas al pie

.. [#] De hecho, `python <https://www.python.org/>`_ se usa mucho como lenguaje
   de *scripting* entre los administradores de sistemas, cuando el código es
   demasiado complicado como para abordarlo con el lenguaje de la *shell*.
   También es muy socorrido `perl <http://www.perl.org>`_.

.. [#] 
   Efectivamente::

      # readlink -f /bin/sh
      /bin/dash

.. [#] Es más, si necesitamos hacer un *script* que maneje estructuras de
   datos algo complicadas, es mejor olvidarse de la *shell* y programarlo
   directamente en :command:`python`, :command:`perl` u otro lenguaje apropiado.

.. [#] Es más, subcribimos `las palabras con que Rich encabeza su recopilación
   de artimañas <http://www.etalabs.net/sh_tricks.html>`_:

      Creo firmemente que los lenguajes derivados de la Bourne *shell* son, para
      la programación, extremadamente malos, tanto como lo es también *Perl*, y
      estimo que programar en ellos es un sobresfuerzo absolutamente
      errado, si no se persigue escribir un código altamente portable entre
      distintas plataformas.
