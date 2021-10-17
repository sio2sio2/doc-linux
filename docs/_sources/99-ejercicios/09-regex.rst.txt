Ejercicios sobre regex
----------------------

.. note:: Para comprobar la validez de su solución puede utilizar la orden
   :ref:`grep <grep>`:

   * Sin opción específica podrá ensayar |BRE|::

      # grep '\<\(p\|P\)alabra\>' <<<"Esto es una palabra aislada."

   * Con la opción ``-E`` (o :command:`egrep`) podrá ensayar |ERE|::

      # grep -E '\b(?p|P)alabra\b' <<<"Esto es una palabra aislada."

   * Con la opción ``-P`` podrá ensayar |PCRE|::

       # grep -P '\b(:?p|P)alabra\b' <<<"Esto es una palabra aislada."

#. Usando únicamente los patrones básicos de los apuntes, indique las
   expresiones regulares que:

   a. Concuerdan con dos "e" separadas por un caracter cualquiera.
   #. Concuerdan con dos "e" separadas por tres o cuatro caracteres cualquiera.
   #. Concuerdan con frases que tiene al menos tres "e".
   #. Concuerdan con frases que contiene la palabra "bola" ó "bolo".
   #. Concuerdan con frases que empiezan por "a", tienen al menos una "J" y
      acaban en "e".
   #. Concuerdan con frases que contiene al menos dos veces la palabra "bola".
   #. Concuerdan con frases que empiezan por "11" y acaban por "99".
   #. Concuerdan con frases de tres palabras (considérese que no hay comas ni
      puntos).
   #. Concuerdan con frases de menos de 100 caracteres.
   #. Concuerdan con frases que sólo tienen vocales.

   .. note:: Algunas soluciones, si nos restringimos al uso de los patrones
      básicos, serán algo definicientes aún.

#. Repase las soluciones anteriores para mejorarlas usando también los patrones
   avanzados.

#. Indique una expresión regular que:

   a. contenga tres vocales seguidas.
   #. contega tres vocales.
   #. concuerde con una sucesión de números y caracteres asimilables al espacio.
   #. concuerde con dos palabras.
   #. concuerde con una frase de entre 20 y 30 caracteres.
   #. contenga tres signos de interrogación.
   #. contenga dos "a" seguidas y dos "e" seguidas en cualquier orden.

#. Para la configuración de un servidor :ref:`nginx <n-ginx>` necesitamos
   utilizar un patrón que concuerde con rutas que **no** empiezan por
   :file:`/uploads` y que sí acaban por *.php*. Por tanto, concordará con rutas
   tales como::

      /scripts/01/index.php
      /plugins/users.php

   pero no con rutas como::

      /plugins/readme.txt
      /uploads/2009/01/script.php


.. |BRE| replace:: :abbr:`BRE (Basic Regular Expressions)`
.. |ERE| replace:: :abbr:`ERE (Extended Regular Expressions)`
.. |PCRE| replace:: :abbr:`PCRE (Perl-Compatible Regular Expressions)`
