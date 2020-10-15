.. _segavanz:

Seguridad de la información
===========================
Ya se ha tratado el modo básico de gestionar la seguridad de ficheros y
directorios a través de :ref:`usuarios y permisos <permusu>`. Ello supone usar
el sistema de permisos |POSIX| sobre un mecanismo de control de accesos |DAC|, lo
cual es posible que resulte aún palabrería técnica ininteligible. Por esto,
antes de pasar a exponer cómo ampliar la gestión de la seguridad de los
archivos, introduciremos algunos conceptos relativos a ella.

Hay tres filosofías distintas para implementar el mecanismo de control de
accesos:

.. _control-dac:

#. Control de accesos discrecional (|DAC|)

   Es el mecanismo más habitual en que la seguridad se basa en la identidad de
   los usuarios y en los permisos que se otorgan a éstos sobre los distintos
   objetos del sistema. En él cada objeto tiene por propietario a un usuario y
   es éste el que tiene potestad para conceder, a discreción, permisos sobre su
   propiedad al resto de los usuarios. En consecuencia, el control de la
   seguridad no está centralizado, sino que cada usuario decide sobre la
   seguridad de los objetos que le pertenecen.

   Es el mecanismo que suelen implementar de serie los sistemas operativos
   (*Windows*, *Linux*, etc.), y presentan dos aproximaciones distintas para la
   definición de estos permisos discrecionales:

   - El tradicional en los sistemas *UNIX* es el sistema |POSIX|, conocido también
     como |UGO|, que define para cada objeto del sistema de ficheros un usuario
     propietario y un grupo propietario, de suerte que se definen tres grados de
     accesibilidad (permisos) distintos: para el propietario, para los usuarios
     pertenecientes al grupo propietario y para el resto de usuarios. Esa es la
     razón de su nombre y a esta técnica dedicamos :ref:`la definición elemental
     de permisos <permusu>`.

   - Las listas de control de accesos (|ACL|) que consisten en poder definir
     para cada objeto los conjuntos de permisos para cualesquiera usuarios y
     cualesquiera grupos. Por lo general se define un conjunto de permisos por
     defecto, que serán los que tengan los usuarios que no aparezcan en la lista
     o no pertenezcan a alguno de los grupos incluidos en la lista. Este es el
     método que usa *Windows*, aunque en los sistemas *UNIX* modernos se puede
     habilitar como complemento del anterior para aquellos objetos en los que no
     sea suficiente el sistema |POSIX|, que es menos granular. Este será uno de
     los aspectos avanzados que tratemos.

#. Control de accesos obligatorio (|MAC|)

   Este mecanismo se caracteriza porque el control está centralizado. El
   mecanismo se basa en la definición de etiquetas sobre los objetos que indican
   su nivel de sensibilidad (p.e. desclasificado, restringido, confidencial,
   secreto y alto secreto) y la definición de etiquetas sobre los sujetos que
   indican su nivel de acceso, de manera que el sujeto podrá actuar sobre el
   objeto sólo si tiene un nivel de acceso superior al de la sensibilidad del
   objeto.

   Todas estas políticas de acceso se definen de forma centralizada, sin que
   ningún usuario de forma discrecional pueda conceder a otros privilegios.

   En *Linux* hay posibilidad de implementar este mecanismo de
   seguridad a través de SELinux_, que usa entre otras RedHat, o :ref:`Apparmor
   <apparmor>`, que usan SuSE, Ubuntu o Debian (a partir de su versión 10). De
   hecho, es normal que en los linux modernos, este mecanismo esté habilitado
   por defecto.

#. Control de accesos basado en roles (|RBAC|)

   En este mecanismo se predefinen una serie de roles, a cada uno de los cuales
   se le asigna una serie de privilegios. Un administrador asignará a cada
   usuario uno o varios roles, de modo que los privilegios del usuario
   dependerán de cuál sea el rol o los roles que desempeñe.

   En cierta medida, es equivalente a un modelo |DAC| con |ACL|\ s en el que se
   asignan permisos exclusivamente a grupos de usuarios, no a usuarios
   particulares.

   Aunque no sea el ejemplo de un sistema operativo, la plataforma Moodle_
   implementa un control de accesos basado en roles.
   
Trataremos en más profundidad:

.. rubric:: Contenidos

.. toctree:: 
   :glob:
   :maxdepth: 1

   [0-9]*

.. |DAC| replace:: :abbr:`DAC (Discretionary Access Control)`
.. |UGO| replace:: :abbr:`UGO (User-Group-Others)`
.. |MAC| replace::  :abbr:`MAC (Mandatory Access Control)`
.. |RBAC| replace::  :abbr:`RBAC (Role-Based Access Control)`
.. |POSIX| replace::  :abbr:`POSIX (Portable Operating System Interface for uniX)`

.. _SELinux: https://es.wikipedia.org/wiki/SELinux
.. _Moodle: https://www.moodle.org
