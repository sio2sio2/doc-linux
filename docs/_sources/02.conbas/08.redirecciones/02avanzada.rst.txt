Redirección avanzada
====================

.. warning::
   Estos conceptos sobre redirección sólo son realmente útiles cuando se
   pretende hacer *scripts*. Para el uso interactivo de la *shell* basta con los
   conceptos explicados bajo el epígrafe anterior.

Ya se ha expuesto que la *shell* tiene abiertos tres ficheros a los que asigna
los descriptores *0*, *1* y *2*. Ahora bien, pueden usarse otros descriptores y
asociarse a estos descriptores ya existentes o a ficheros.

Pero Antes de ello introduzcamos un par de herramientas más:

.. _read:
.. index:: read

:command:`read`
   Lee de la entrada estándar y guarda la entrada en la variable que se le
   proporciona como argumento. Su sintaxis es::

      read [opciones] <nombre_variable>

   Por ejemplo, la orden::

      $ read MIVAR

   Almacena la cadena introducida por teclado en la variable *MIVAR*. Ahora
   bien, es bastante común añadir la opción :kbd:`-r` para interpretar
   la contrabarra como un carácter normal::

      $ read -r MIVAR
   
   De entre las opciones posibles son muy útiles ``-p`` que permite incluir un
   prompt y ``-s`` que impide que los caracteres escritos tengan eco en la
   pantalla. Así, pues si pidiéramos una contraseña podríamos hacer lo
   siguiente::

      $ read -sp "Password: " PASSWD

   Y veríamos que somos incapaces de ver lo que escribimos, igual que ocurre
   cuando introducimos la contraseñá tras ejecutar un :command:`su`.

   Además, es interesante notar que :command:`read` lee hasta que se encuentra
   un cambio de línea que es el delimitador pedeterminado que tiene definido
   (puede cambiarse con la opción ``-d``). Por ese motivo si probamos a hacer\
   [#]_::

      $ read MIVAR <<EOF
      1
      2
      3
      EOF
      $ echo $MIVAR
      1

   la variable toma, simplemente, el valor **1**, ya que 2 y 3 se encuentran
   después del cambio de línea.

   Esta orden permite, además, dar valor a varias variables a la vez y está muy
   relacionada con la :ref:`variable IFS <sh-ifs>`, que codifica los
   caracteres que para :command:`read` representan un separador de campos. Su
   valor predeterminado es "\\t \\n". Por este motivo\ [#]_::

      $ read x y <<<"1 2"
      $ echo "x=$x -- y=$y"
      x=1 -- y=2

   Y, si cambiamos su valor::

      $ IFS=, read x y <<<"1,2"
      $ echo "x=$x -- y=$y"
      x=1 -- y=2


   .. note:: Obsérvese que hay un modo muy sencillo de separar en distintas
      variables los datos de usuario almacenados en :file:`/etc/passwd`
      aplicando estos conocimientos::

         $ IFS=: read -r user _ uid gid gecos home shell <<<$(getent passwd $USER)
         $ echo $user
         usuario
         $ echo $gid
         1000

   Por último, si hay más variables que campos, las últimas variables quedarán
   sin valor y, si hay más campos que variables, la última variable almacenará
   los úultimos campos::

      $ IFS=: read -r user resto <<<$(getent passwd $USER)
      $ echo $user
      usuario
      $ echo $resto
      x:1000:1000:Usuario pedestre,,,:/home/usuario:/bin/bash

   .. note:: Resetear el valor de *IFS* con :command:`unset` tiene el efecto de
      recuperar su valor predeterminado, mientras que adjudicarle un valor nulo,
      provoca que no exista separador de campos::

         $ IFS=
         $ read x y <<<"1 2"
         $ echo $x
         1 2
         $ unset IFS 
         $ read x y <<<"1 2"
         $ echo $y
         2

.. _exec:
.. index:: exec

:command:`exec`
   Permite remplazar la *shell* por el comando que se indique. Por ejemplo, si
   hacemos::

      $ exec sleep 2

   El comando sleep reemplazará a la *shell*. La consecuencia es que pasados 2
   segundo (el tiempo que tarda en acabar de ejecutarse :command:`sleep`)
   veremos que se cierra la terminal.
   
   Sin embargo, este no es el uso que nos interesa ahora. :command:`exec` tiene
   la particularidad también de que si en vez de un comando se incluye una
   redirección esta afectará a toda la shell. Por ejemplo, si hacemos::

      $ exec 1>/dev/null

   Habremos mandado a :file:`/dev/null` la salida estándar de cualquier comando
   que ejecutemos a continuación en la misma *shell*.

Puesto estos mimbres veamos qué otras cosas podemos hacer.

Una posibilidad es usar un nuevo descriptor conectado a un fichero (si el
fichero no existe se creará)::

   $ exec 3<>/tmp/fichero.txt

De este modo, este descriptor servirá tanto para entrada como para salida.
Puede, si se desea, sólo conectarlo para entrada o sólo para salida. El caso, es
que ahora, cualquier cosa que se envíe a este descriptor, acabará en el
fichero::

   $ echo "Hola" >&3
   $ echo "Adiós" > &3
   $ cat /tmp/fichero.txt
   Hola
   Adiós

Es importante tener en cuenta que la *shell* sabe por dónde *va*, de manera que
si intentamos leer del descriptor::

   $ cat <&3

No obtendremos nada, pues nos encontramos al final del fichero. Cuando deseamos
cerrar el descriptor basta con hacer lo siguiente::

   $ exec 3>&-

y dejará de haber conexión entre el descriptor y el fichero.

Un uso que se hace a veces dentro de los *scripts* es asociar la salida estándar
a un fichero, de manera que no haya que hacer la redirección al fichero en cada
comando. Analicemos el siguiente trozo de código.

.. code-block:: bash
   :linenos:

   exec 3>&1 > /tmp/salida.txt

   echo '**********************'
   ls /
   echo '**********************'

   exec 1>&3 3>&-

   echo "Esto se vuelve a ver por pantalla"

La primera línea logra dos cosas: que el descriptor **3** conecte su salida a donde
la conecta el descriptor **1** (la pantalla) y después que este último se conecte al
fichero :file:`/tmp/salida.txt`. La consecuencia es que a partir de este momento
todas las órdenes usarán como salida estándar el fichero. La línea **7**
restituye la situación inicial, ya que hace que el descriptor 1 conecte su
salida a la del descriptor **3**, o sea, la pantalla y, después, cierra el
conector 3. Por tanto, a partir de ese momento, las órdenes volverán a mostrar
su salida estándar por pantalla.

Menos común, pero también posible es que queramos asociar la entrada estándar a
un fichero:

.. code-block:: bash

   exec 3<&0 </tmp/entrada.txt

   read -r primera  # Esto lee la primera línea del fichero.
   echo "Primera línea: $primera"
   read -r segunda  # Y esto, la segunda.
   echo "Segunda líneaa: $segunda"

   exec 0<&3 3<&-

   read -r -p "Escriba una respuesta: " teclado
   echo "Teclado: $teclado"

.. rubric:: Notas al pie

.. [#] ¡Tenga cuidado! Esto::

         $ echo -e "1\n2\n3" | read MIVAR

       o esto otro::

         $ cat | read MIVAR
         1
         2
         3

      no funcionarán como esperamos, y ni veremos que ``MIVAR`` pase a valer 1.
      La razón es que cuando se hace una tubería el segundo comando se ejecuta
      en una subshell y, consecuentemente, estamos cambiando el valor de la
      variable dentro de la subshell::

         $ echo -e "1\n2\n3" | { read MIVAR ; echo $MIVAR; }
         1

      Sin embargo, al salir de la subshell la asignación se pierde.

.. [#] Hay una razón fundada por la que estos ejemplos usan la redirección no
   estándar de :program:`bash`, en vez de una tubería::

      $ echo "1 2" | read x y

   y es que la tubería provoca que ambas ordenes se ejecuten en sendas
   *subshells* independientes. La consecuencia de esto es que :kbd:`x` e
   :kbd:`y` no existen en la *shell* principal, así que tras ejecutar la orden
   nos encontraremos con que no hemos logrado nada::

      $ echo $x  # No devuelve valor alguno.

