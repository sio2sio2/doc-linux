.. _n-ginx:

nginx
=====

Los principales servidores *web* en la actualidad son *software* libre: `apache
<http://apache.org/>`_, que empezó su desarrollo en 1995, y `nginx
<http://nginx.org/>`_, que lo empezó en 2002 y que surgió como respuesta al
`problema C10k <https://es.wikipedia.org/wiki/Problema_C10k>`_ en los
servidores *web*.

Desde muy pronto, :program:`apache` ha gozado de una gran cuota de mercado (y
en ciertos momentos, abrumadora), pero :program:`nginx` ha ido `aproximándose
en uso
<https://news.netcraft.com/archives/2018/01/19/january-2018-web-server-survey.html>`_ y, si la tendencia, continúa es que acabe por superarlo\ [#]_.

Para una comparativa entre ambos servidores que explica cuáles son sus
diferencias, puede consultarse `el siguiente enlace en castellano
<https://www.1and1.es/digitalguide/servidores/know-how/apache-vs-nginx-una-comparativa-de-servidores-web/>`_.
Las más significativas son:

* El modo en que se procesan las conexiones.
* La configuración centralizada de :program:`nginx` frente a la descentralizada
  de :program:`apache` a través de los ficheros :file:`.htaccess`.
* La ejecución de contenido dinámico: :program:`apache` tiene mòdulos para posibilitar
  la ejecución de *script* (en |PHP|, en *Python*, en *Perl*, etc) que generan el 
  contenido dinámico; mientras que :program:`nginx`, no: hace de proxy para
  el intérprete adecuado y se limita a servir el contenido resultante\ [#]_.

En estos apuntes, explicaremos la configuración de :program:`nginx`.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*
   [0.9]*/index

.. rubric:: Notas al pie

.. [#] De hecho, en los servidores con más tráfico de internet ya es así.
.. [#] En 2017, el equipo de :program:`nginx` ha empezado a desarrollar
    `unit <https://unit.nginx.org/>`_ para posibilitar la interpretación de
    distintos lenguajes.

.. |SSL| replace:: :abbr:`SSL (Security Socket Layer)`
.. |PHP| replace:: :abbr:`PHP (PHP Hypertext Preprocesor)`
