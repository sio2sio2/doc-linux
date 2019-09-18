.. _samba:

Samba
=====

.. todo:: Explicar qué pretendemos y para qué lo hacemos. También cómo es la
   autenticación con kerberos, etc...

   Para acabar exponer qué se pretende resolver con un dibujo.

   Hay que enumerar también las carencias de la configuración:

   #. Samba4 soporta un único dominio.
   #. Los perfiles móviles en linux se consiguen montando el directorio remoto
      sobre un directorio local, no sincronizando ficheros.

Estableceremos primero con qué parámetros configuraremos el servidor:

.. table:: **Datos del servidor**

   ================== =============================================================
   Parámetros         Valor
   ================== =============================================================
   Tipo               :abbr:`AD-DC (Controlador de dominio de Directorio Activo)`
   Nombre             ``dc``
   Dominio            ``iespjm.domus``\ [#]_
   Grupo de trabajo   IESPJM
   IP                 ``192.168.255.1/24``
   ================== =============================================================

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*/index

.. rubric:: **Enlaces de interés**

* `Sistemas operativos en red <http://somebooks.es/sistemas-operativos-en-red/>`_

.. rubric:: Notas al pie

.. [#] El *reino* de *kerberos* será este dominio en mayúsculas: ``IESPJM.DOMUS``.
