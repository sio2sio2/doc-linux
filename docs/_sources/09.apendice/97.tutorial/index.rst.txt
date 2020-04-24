Tutoriales
**********
Si nuestra intención es ilustrar algún aspecto de la |CLI| de *Linux* y
preferimos crear material audivisual y no escrito una excelente opción es
asciinema_. La herramienta permite:

#. Grabar las acciones que hagamos en una intefaz almacenándolas no un
   formato de vídeo convencional, sino en un formato :file:`.cast` que no es más
   que un archivo |JSON|, qué describe qué hemos escrito o visto y en qué
   instante de tiempo.

#. Reproducir en la máquina local el archivo, o bien, alojarlo en una web y
   reproducirlo en un navegador gracias a la librería Javascript
   asciinema-player_.

#. La reproducción, por su propia naturaleza, carece de sonido, pero haciendo
   uso de algunas estrategias, podemos añadirlo.

La ventaja de estos vídeos frente a los tradicionales que se hacen capturando la
imagen de la pantalla, es que permiten copiar al portapapeles usando el ratón,
lo cual facilita enormemente que un estudiante pueda reproducir las acciones que
observa en el vídeo.

El programa tiene paquete en *Debian*, así que su instalación es sumamente
sencilla::

   # apt install asciinema

Creación
========
Para crear un vídeo basta con hacer::

   $ asciinema rec tutorial.cast

y comenzar a llevar a cabo la sesión tutorizada que queremos grabar. Al salir de
la sesión (con :ref:`exit <exit>`, :ref:`logout <logout>` o cualquier otro
método análogo), se parará la grabación. El resultado será el archivo
:file:`tutorial.cast`.

.. note:: Si nuestra intención es acabar añadiéndole sonido por algún método que
   veremos más adelante, entonces deberemos a la vez que comezamos la grabación
   del vídeo, grabar nuestra voz con un micrófono y algún *software* apropiado.
   Una alternativa sencilla para la terminal es ffmpeg_. Si usamos los drivers
   de PulseAudio_, la grabación será algo así\ [#]_::

      $ ffmpeg -f pulse -i 1 -c:a libopus -application:a voip -b:a 8K tutorial.webm

   donde el número que es argumento de :kbd:`-i` debe ser el micro y puede
   variar según el sistema. El número concreto en cada caso puede consultarse
   con::

      $ pacmd list-sources

   Eso sí, no tenemos modo de hacer que las grabaciones de vídeo y audio
   empiecen (y acaben a la vez), por lo que debemos preocuparnos de que así sea
   más o menos, aunque bien es cierto que un pequeño desfase no es muy grave por la
   naturaleza del vídeo y porque, si el audio empezó antes, es muy sencillo
   cortar ese exceso inicial con el propio ffmpeg_.

.. warning:: El fichero recuerda las dimensiones de la consola en la que
   trabajábamos, de modo que nos conviene ajustarla primero a un tamaño
   adecuado.

Creado el vídeo, podemos probar su reproducción con::

   $ asciinema play tutorial.cast

que debería reproducir fielmente lo que hicimos previamente. Si en algún momento
pulsamos :kbd:`Space`, la reproducción se pausará y podremos volverla a reanudar
pulsando la misma tecla. Sin embargo, esta posibilidad se queda un poco corta si
lo que pretendemos es crear un tutorial para terceros.

Publicación
===========
La mejor manera de facilitar el acceso al tutorial es publicarlo y que el
posible alumno pueda acceder a él sin necesidad de tener instalado asciinema_.
Tenemos tres posibilidades:

#. Publicarlo en la página de asciinema_, que es lo más simple.
#. Crear un archivo de vídeo en un formato estándar (p.e. :file:`.mp4`).
#. Alojarlo en una página web propia.

A explicar estas tres alternativas dedicaremos el epígrafe.

Página oficial
--------------
La principal desventaja de este método es que se reproducirá sin posibilidad de
añadirle sonido, lo cual en algunos casos nos podrá resultar inadmisible. Si
este no es el caso, esta es la solución más simple.

Es indispensable que nos demos con una dirección de correo electrónico. Dados ya
de alta, podemos subir nuestro tutorial a esa cuenta del siguiente modo:

* Ejecutamos::

   $ asciinema auth

  que nos proporcionará una |URL| basada en un identificador que se genera la
  primera vez que ejecutamos el programa\ [#]_.

* Visitamos la |URL| e introducimos en la página la dirección de correo con la
  que nos registramos. Eso asociará la cuenta con nuestro identificador,
  además nos enviará un mensaje al correo electroónico con un |URL| que nos
  servirá (si lo deseamos) para ingresar en el sitio vía web (útil, por ejemplo,
  si deseamos añadir alguna descripción al vídeo o borrarlo por no haber quedado
  satisfechos).

* Subimos el video tutorial al sitio asociándolo con nuestra cuenta::

   $ asciinema upload tutorial.cast

Y listo, se nos proporcionará el enlace donde está accesible la reproducción. En
cualquier caso, si accedemos a  nuestra cuenta, podremos revisar todos los
vídeos que hemos subido y acceder también a este enlace.

Vídeo estándar
--------------
Esta estrategia sí nos permite añadir sonido, aunque como el resultado es un
vídeo normal reproducible con cualquier reproductor multimedia:

- El resultado será mucho más pesado.
- Perderemos la posibilidad de copiar al portapapeles.
- Es probable que no nos funcione con vídeos demasiado largos.
- Dado el resultado, ¿no es más sencillo capturar la pantalla y nos ahorramos
  todo este jaleo?\ [#]_

Pese a las evidentes desventajas, expondremos el procedimiento aquí partiendo de
haber creado ya tanto e vídeo (:file:`tutorial.cast`) como su correspondiente
audio grabado simultáneamente (:file:`tutorial.webm`).

Debemos:

* Transformar el formato :file:`.cast` en :file:`.gif` mediante asciicast2gif_.
  Lo más sencillo es usar el contenedor :ref:`Docker <docker>` que ofrecen los
  propios creadores. Si creamos el directorio :file:`/tmp/DATA` y guardamos
  :file:`tutorial.cast` en él, podemos obtener :file:`tutorial.gif` del siguiente modo::

   # docker run --rm -v /tmp/DATA:/data asciinema/asciicast2gif -t asciinema -w80 tutorial.cast tutorial.gif

  .. warning:: Si el video es excesivamente largo, se generarán demasiadas
     imágenes, el programa fallará y no lograremos crear el resultado.

* Utilizar ffmpeg_ para mezclar la imagen y el sonido en un video reproducible::

   # nice ffmpeg -i /tmp/DATA/tutorial.gif -i tutorial.webm -c:a copy -movflags faststart \
         -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -strict -2 tutorial.mp4

El resultado será :download:`un vídeo mp4 comúnmente reproducible
<files/tutorial.mp4>`, pero, como tal, sin brindarnos la posibilidad de copiar
al portapapel las órdenes que se ilustran.

Página propia
-------------
Este último procedimiento es el más recomendable si se requiere sonido, puesto
que mantiene muy pequeño el tamaño del vídeo (será el :file:`.cast` original),
permite copiar al portapapeles las órdenes y, además, es capaz de añadir audio.
Presenta dos limitaciones:

- Requiere que podamos albergar los ficheros en algún espacio web propio.
- asciinema-player_ aún no ha definido ningún evento para capturar el momento
  en que saltamos a otro punto del vídeo (si se implementa alguna vez quizás sea
  timeupdate_). Es útil cuando, por ejemplo, queremos saltarnos un trozo de la
  reproducción y para ello avanzamos el vídeo con la barra inferior del
  reproductor. En consecuencia:

  .. warning:: Mantener la sincronización entre vídeo y audio sólo es posible si
     nos limitamos a arrancar y pausar el vídeo, pero no si saltamos un trozo.

En este caso, partimos ya de haber generado el vídeo :kbd:`tutorial.cast` y el
audio :kbd:`tutorial.webm` y necesitamos una :download:`página html como ésta
<files/tutorial.html>` en que inscrustarlo:

.. literalinclude:: files/tutorial.html
   :language: html

.. warning:: La página debe estar alojada en un servidor, si intenta usarla
   cargándola como un fichero en el navegador, le será imposible cargar el vídeo
   y el audio.

.. rubric:: Notas al pie

.. [#] El formato de salida usa el codec Opus_ con unos parámetros que harán
   perfectamente inteligible el audio y a la vez bastante pequeño. Podríamos
   también usar un formato como :file:`.mp3`, pero no es lo más recomentable::

      $ ffmpeg -f pulse -i 1 tutorial.mp3
   
.. [#] El identificador se almacena en :file:`~/.config/asciinema`

.. [#] El propio ffmpeg_ permite capturar la pantalla (mientras se graba el sonido)::

      # RES=$(xrandr | awk '/\*/ {print $1}')
      # ffmpeg -video_size "$RES" -f x11grab -i "$DISPLAY" -f pulse -i 2 \
         -c:a libopus -application:a voip -b:a 8K -strict -2 tutorial.mp4

   Con esto grabaríamos toda la superficie de la pantalla, aunque puede grabarse
   una superficie más reducido. Véase `el apartado dedicado a captura en
   la página oficial de ffmpeg
   <https://trac.ffmpeg.org/wiki/Capture/Desktop>`_.

.. _asciinema: https://asciinema.org
.. _timeupdate: https://developer.mozilla.org/es/docs/Web/API/HTMLMediaElement/timeupdate_event
.. _asciinema-player: https://github.com/asciinema/asciinema-player
.. _asciicast2gif: https://github.com/asciinema/asciicast2gif
.. _ffmpeg: https://www.ffmpeg.org/
.. _PulseAudio: https://www.freedesktop.org/wiki/Software/PulseAudio/
.. _Opus: http://opus-codec.org/

.. |CLI| replace:: :abbr:`CLI (Command Line Interface)`
.. |JSON| replace:: :abbr:`JSON (JavaScript Object Notation)`
.. |URL| replace:: :abbr:`URL (Uniform Resource Locator)`
