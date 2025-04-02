.. _syslog:

Archivos de registro
====================

Muchas aplicaciones, en particular aquellas que actúan en segundo plano sin
intervención del usuario, informan al sistema de distintos aspectos de su
funcionamiento, entre ellas el propio núcleo.

En los sistemas *UNIX*, tradicionalmente, esta información se almacena en
ficheros de texto plano incluidos dentro del directorio :file:`/var/log`. En
linux esto ha venido siendo así hasta la aparición de *systemd*, que también ha
querido apropiarse de esta tarea. Peso a ello, dado que muchas aplicaciones de
monitorización basan su funcionamiento en el sistema tradicional, en los linux
gestionados por *systemd* es posible mantener ambas sistemas de registro; y, de
hecho, esta es la configuración predeterminada.

Bajo este epígrafe se explica cómo funcionan y se configuran ambos sistemas de
registro.registro.

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

