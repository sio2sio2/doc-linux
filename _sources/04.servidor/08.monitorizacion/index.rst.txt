.. _logs:

Monitorización
==============

La :dfn:`monitorización` del sistema operativo consiste en la supervisión de su
funcionamiento con el fin de detectar problemas o adelantarse a ellos\ [#]_.
Hay, pues, dos modos de llevarla a cabo:

* La **reactiva** que consiste en descubrir un problema que **ya** ha
  surgido, con el fin de buscarle una solución apropiada.

* La **proactiva** que consiste en vigilar el funcionamiento del sistema para
  medir su rendimiento, detectar debilidades y adelantarse a los problemas.

Para entender completamente estos dos tipos de monitorización consideremos un
problema real: *que la partición raiz de nuestro sistema se llene por completo*.
Si esta situación ocurre, el sistema empezará a dar visos de ello con mensajes
de que, por ejemplo, no es capaz de escribir en disco. Sospechando que esto
pueda ser el problema, podemos usar :ref:`df <df>` para confirmar que la
ocupación está al 100%. La secuencia de hechos sería la siguiente:

* El sistema deja de funcionar bien.
* Sospechamos que hay algún problema en la escritura de disco.
* Comprobamos con :command:`df` que el disco está lleno.

La labor de monitorización puede que no haya acabado aquí, porque
sabida la causa deberíamos indagar por qué hemos llegado a este punto: si la
causa es que hemos instalado más aplicaciones de las que previmos en un
principio, no nos quedará más remedio que ampliar el tamaño de la partición; si
la causa es que hicimos el mal diseño de mezclar el sistema con los datos y
estos últimos se nos han comido el espacio, podríamos adoptar la solución
anterior, o bien, sacar los datos a una partición aparte; si, por el contrario,
no es ninguna de estas dos causas, entonces aún no hemos acabado de monitorizar,
porque deberemos aún descubrir qué es lo que ha hecho que nos quedemos sin
espacio. En ese caso podríamos usar :command:`du <du>` para descubrir qué parte
del árbol de directorios ha crecido desmesuradamente\ [#]_.

Sea como sea, este es un ejemplo de monitorización *reactiva*: ocurre el
problema y, como consecuencia, intentamos averiguar qué ha ocurrido con todas
las herramientas que nos brinda el sistema.

Sin embargo, podríamos adoptar otra estrategia: en vez de esperar a que ocurre
el problema, podemos escribir un sencillo *script* que con la salida de
:command:`df` compruebe si una partición ha alcanzado más del 90% de ocupación;
y en caso de que eso ocurra, envíe un correo a nuestra dirección de
administrador que revisamos todos los días. Por último, el *script* lo incluimos
en la planificación de *cron* para que se ejecute todos los días. Este es otro
enfoque para el mismo problema: un enfoque *proactivo* ya que, mediante una
supervisión continua, nos adelantamos al problema.

Como los problemas son innumerables, casi cualquier herramienta vista hasta
ahora puede convertirse en una herramienta de monitorización *reactiva*; y casi
con cualquier herramienta podemos construir una *script* para la monitorización
*proactiva*. Algunas son recurrentes en las labores de monitorización como
:ref:`du <du>` o :ref:`df <du>` o las relacionadas con la :ref:`consulta de
procesos <consproc>`. Bajo este epígrafe atenderemos tres aspectos de la
monitorización no estudiados aún:

   .. toctree::
      :glob:
      :maxdepth: 2

      [0-9]*/index


.. rubric:: Notas al pie

.. [#] Por supesto tambien podemos hablar de *monitorización* cuando analizamos
   los paquetes de una conexión de red concreta con el fin de estudiarla para
   bien... o para mal. Esta tarea, que se lleva a cabo con herramientas como
   :command:`tcpdump` o :command:`wiresharp`, queda fuera del propósito de este
   epígrafe.

.. [#] En muchos casos, el culpable de esta situación es el crecimiento
   desmesurado de los ficheros de *log* de los que precisamente trataremos en
   este capítulo.
