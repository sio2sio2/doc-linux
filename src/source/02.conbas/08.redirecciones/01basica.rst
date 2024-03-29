.. _ioredirect-bas:

Redirección básica
==================

Para este caso trataremos sólo los tres archivos antes indicados:

================== ==================== ===================
Nombre             Dipositivo           Descriptor asociado
================== ==================== ===================
Entrada estándar   :file:`/dev/stdin`    0
Salida estándar    :file:`/dev/stdout`   1
Salida de errores  :file:`/dev/stderr`   2
================== ==================== ===================

y no haremos redirecciones permanentes.    

La tercera columna, intitulada *Descriptor asociado*, hace referencia al
descriptor de archivo, o sea, al número entero, con el que es posible hacer
referencia al archivo en cuestión.

Salida
------
La redirección de salida consiste en redirigir la salida estándar o la salida
de errores hacia otro archivo que puede ser la otra salida o un archivo
regular.

Consideremos la siguiente orden::

   $ cat

Sabemos ya que el comando leerá de teclado (la entrada estándar) y escribirá en
la pantalla (la salida estándar). Si queremos redirigir la salida hacia un
archivo regular, basta con lo siguiente::

   $ cat > contenedor_de_tonterias
   Esto que escribo, ya no aparece por la pantalla,
   puesto que se redirige la salida estándar
   hacia un archivo llamado 'contenedor_de_tonterias'.


Tal archivo puede o no existir: si no existe, se creará; si existe, se
sustituirá su anterior contenido por lo que escribamos ahora. Es posible también
redirigir al archivo añadiendo en vez de sustituyendo::

   $ cat >> contenedor_de_tonterías
   Añadimos un par de líneas adicionales
   a las que escribimos antes

El resultado es que el archivo contendrá 5 líneas: ls tres anteriores y estas
dos nuevas, en vez de contener sólo estas dos últimas, lo cual habría ocurrido
si hubiéramos usado una redirección simple.

Hay ocasiones en que redirigimos la salida no porque deseemos guardar
resultados, sino porque deseamos no verlos. En este caso, es sumamente útil
el archivo especial :file:`/dev/null`, que se traga todo lo que le echemos sin
dejar rastro::

   $ ls /usr/bin/ > /dev/null

Ahora bien, ¿por qué hemos redirigido la salida estándar y no la salida de
errores? La razón está en que cuando no se indica cuál, se sobreentiende que nos
referimos al descriptor *1*, esto es, a la salida estándar. La sintaxis general
de la redirección es::

   N> destino

donde ``N`` es el número del descriptor. La ausencia de ``N`` implica 1. Para la
redirección doble es exactamente igual. 

Probemos ahora lo siguiente::

   $ sadhgaskjhsa > /dev/null
   sadhgaskjhsa: no se encontró la orden

Como vemos, a pesar de la redirección, hemos visto el mensaje. Esto es debido a
que lo que hemos redirigido es la salida estándar, no la salida de errores, por
lo que esta última sigue saliendo por la pantalla. Para haber evitado ver el
mensaje de error deberíamos haber hecho::

   $ sadhgaskjhsa 2> /dev/null

También es posible redirigir una archivo de salida hacia el otro. Por ejemplo,
esto redirige la salida de errores hacia la salida estándar::

   $ sadhgaskjhsa 2>&1
   sadhgaskjhsa: no se encontró la orden

Volvemos a ver por pantalla el error, pero en esta ocasión se escribe el mensaje
en la salida de errores no en la estándar. De hecho::

   $ sadhgaskjhsa >contenedor_del_error 2>&1

Escribe el mensaje de error en el archivo. En realidad, se redirigen tanto la
salida estándar como la de errores\ [#]_. No obstante, para esto último, es más
sencillo redirigir ambas salidas a la vez, para lo cual hay un símbolo propio::

   $ ls /y* &> /dev/listado.txt

Téngase en cuenta que esta última notación es propia de :program:`bash` y no
funciona en :program:`dash`.

Entrada
-------

Por su parte, redirigir la entrada consiste en alimentar con una fuente
alternativa a un programa que espera recibir datos desde la entrada estándar,
que en un principio es el teclado. El caso más sencillo es::

   $ cat < archivo
   [ ...Se muestra el contenido del archivo... ]

Como :command:`cat` no tiene argumentos espera recibir datos a través de la
entrada estándar; pero, como con secuencia de la redirección, esta pasa de ser el
teclado a ser el archivo. Consecuentemente, lo que muestra :command:`cat` es el
contenido del archivo. En realidad, esto es equivalente a::

   $ cat 0< archivo

Ya que **0** es el descriptor que representa la entrada estándar. Esta es la base de la redirección de entrada.

.. _sh-here-document:

Otra redirección de entrada que también forma parte del estándar es la llamada
**Here Document** que permite redirigir hacia la entrada estándar un texto largo
de varias líneas. Para ello se define una palabra delimitadora, de manera que
cuando se vuelva a encontrar esta misma palabra delimitadora sola al principio
de línea, se considerará acabado el texto. Por ejemplo, si hacemos que nuestro
delimitador sea :kbd:`EOF`::

   $ cat <<EOF
   > En un país multicolor
   > había una abeja bajo el sol
   > EOF
   En un país multicolor
   había una abeja bajo el sol.

En el texto, la *shell* intentará llevar a cabo sustituciones por lo que::

   $ cat <<EOF
   > 4 * 2 = $((4*2))
   > EOF
   4 * 2 = 8

Ahora bien, si se rodea el delimitador de inicio con comillas dobles o simples,
no se interpretará nada::

   $ cat <<"EOF"
   > 4 * 2 = $((4*2))
   > EOF
   4 * 2 = $((4*2))

Es posible anteponer al primer delimitador un guión para que pueda sangrarse
(exclusivamente con tabulaciones) el texto del *documento* en línea que se
escribe. Es útil cuando se programa y se quiere mantener el código
correctamente sangrado::

   $ cat <<-EOF
      Mi hogar es $HOME
      EOF
   Mi hogar es /home/usuario

.. _bash-here-string:

.. rubric:: Here String

:command:`bash`, además, ofrece esta redirección adicional, que
permite redirigir hacia la entrada estándar una cadena::

   $ cat <<<Hola,\ don\ Pepito.
   Hola, don Pepito.

.. note:: Obsérvese que *Here String* no es más que el caso particular de un
   *Here Document* de una sola línea::

      $ cat <<EOF
      > Hola, don Pepito.
      > EOF
      Hola, don Pepito

   por lo que si al escribir un *script* en que deseamos evitar las extensiones
   de :program:`bash` tenemos necesidad de usar un *Here String*\ [#]_, podemos
   usar un *Here Document*.

.. _pipeline:

Tuberías
--------
Las tuberías (*pipelines* en inglés) son un caso particular de una redirección
de salida junto a una redirección de entrada. Para entender su utilidad
supongamos que, con las herramientas vistas, se nos propone mostrar únicamente
la penúltima línea de :file:`/etc/group`.

Echando mano de la memoria, parece útil :ref:`tail <tail>`, capaz de extraer la
parte final de un documento. En concreto::

   $ tail -n2 /etc/group
   libvirt-qemu:x:116:libvirt-qemu
   qemusers:x:117:josem

muestra las dos últimas líneas. Pero resulta que sólo queremos la penúltima, o
lo que es lo mismo, la primera línea de la salida producida por :command:`tail`.
Pero resulta que :ref:`head <head>` permite extraer los comienzos de archivo, de
modo que si aplicamos un :kbd:`head -n1` a esa salida conseguiremos nuestro
objetivo. Por supuesto es posible hacer::

   $ tail -n2 /etc/group > /tmp/archivo.intermedio
   $ head -n1 < /tmp/archivo.intermedio
   libvirt-qemu:x:116:libvirt-qemu
   $ rm -f /tmp/archivo.intermedio

Pero nos obliga a crear un absurdo archivo intermedio que hay que borrar al
terminar. La solución fetén a nuestro problema son las tuberías (``|``) que
permite redirigir la salida estándar de un programa hacia la entrada estándar
del siguiente::

   $ tail -n2 /etc/group | head -n1 
   libvirt-qemu:x:116:libvirt-qemu

Esta es básicamente la idea de las tuberías: sencilla, pero que abre muchísimas
posibilidades al permitir construir una herramienta más compleja mediante la
cooperación de herramientas más simples.

La tubería, así escrita, sólo redirige la salida estándar. Si se quieren
redirigir tanto la salida estándar como la de errores puede hacerse::

   $ ls /g* 2>&1 | tail -n2

O bien, usar una sintaxis que sólo es admitida por :command:`bash`::

   $ ls /g* |& tail -n2

En lo relativo a redirecciones son muy útiles dos órdenes que las usan:

.. _tee:
.. index:: tee

:command:`tee`
   Desdobla su entrada hacia dos salidas: la estándar y el archivo que se
   indique::

      $ ls / | tee /tmp/listado.txt

   Hecho esto, veremos que el listado aparece en la pantalla, pero también se
   habrá almacenado en :file:`/tmp/listado.txt`.

.. _pv:
.. index:: pv

:command:`pv`
   Este comando, simplemente, cuenta los *bytes* que recibe por la entrada
   estándar y los redirige hacia la salida estándar. Es bastante útil cuando el
   flujo de datos es grande y no sabemos muy bien cuándo acabará. Por ejemplo,
   supongamos que tenemos en el archivo :file:`disco.img.xz` la imagen cruda
   comprimida de un disco y queremos volcarla sobre el disco físico
   :file:`/dev/sdb`. La solución es trivial::

      $ xzcat disco.img.xz > /dev/sdb

   Ahora bien, la descompresión es un proceso lento y la escritura de tantos
   datos en el disco, también. Como consecuencia, no sabemos muy bien ni cuánto
   tardará ni la velocidad ia la que se van escribiendo datos, con lo que nos
   resulta imposible hacernos una idea de cómo va el proceso hasta que
   finalmente acaba. La solución es usar :command:`pv`\ [#]_ como
   intermediario::

      $ xzcat disco.img.xz | pv > /dev/sdb

   De este modo, el proceso de volcado se llevará a cabo igualemente, ya que
   :command:`pv` no altera los *bytes*, pero mostrará información de a qué
   velocidad se lleva a cabo el proceso y cuántos *bytes* han pasado por el
   momento a través de él. No, puede, sin embargo, pronosticarnos cuánto tiempo
   tardará ni decirnos cuál es el porcentaje ya volcado porque ignora el tamaño
   final de aquello que se le pasa. No obstante, si nosotros sabemos cuál es el
   tamaño descomprimido de la imagen, porque recordamos de cuánto era el disco
   del que la hicimos, entonces es posible indicarle a :command:`pv` cuál es la
   cantidad total de bytes que pasará a través de él (``-s``) y pedirle que nos
   muestre una barra de progreso con el porcentaje completado (``-p``)::

      $ xzcat disco.img.xz | pv -ps 250G > /dev/sdb

   No obstante, para este caso particular, :command:`pv` permite también indicar
   en sus argumentos un archivo del que leer, en vez de usar la entrada
   estándar. En este caso, :command:`pv` si es capaz de saber cuántos *bytes*
   leerá, puesto que toma el dato del tamaño del archivo, y esto hace que sea
   innecesario pasar con ``-s`` la cantidad. Así pues, lo anterior, habría sido
   más inteligente haberlo hecho del siguiente modo::

      $ pv -p disco.img.xz | xzcat > /dev/sdb

   .. note:: Nótese que en este último caso la cantidad de *bytes* que pasan por
      :command:`pv` es significativamente menor, ya que no pasa la imagen
      descomprida, sino la comprimida. Por tanto, el total no serán 250GB sino
      solamente quizás 5GB, por decir algo. Sin embargo, como los tres comandos
      tienen que sincronizarse puesto que unos alimentan a otros, el dato del
      tiempo restante y el porcentaje completado es absolutamente verídico. De
      hecho, no están sujetos a la arbitrariedad de nuestra memoria ni que a
      que, posiblemente, el tamaño de disco no sean exactamente 250GB\ [#]_.

Por último, debe tener presente que para que se pueda usar una tubería la salida
de una orden (la "A") sea la entrada de la siguiente ("B")::

   $ ordenA | ordenB

exige que la :program:`ordenA` sea capaz de escribir su resultado en la salida
estándar y la :program:`ordenB` sea capaz de leer de la entrada estándar. Sin
embargo, puede ocurrir que la sintaxis de la :program:`ordenA` sólo nos permita
escribir su resultado en un archivo, no en la salida estándar, o que la sintaxis
de la :program:`ordenB` sólo nos permita leer de un archivo y no de la entrada
estándar. En esas condiciones nos es imposible utilizar la tubería y tendremos
que:

- Utilizar el archivo intermedio, que es la estrategia más grosera. Por ejemplo,
  si la :program:`ordenB` sólo puede leer de un archivo que se le pasa como
  argumento::

      $ ordenA > /tmp/entrada.txt
      $ ordenB /tmp/entrada.txt
      $ rm /tmp/entrada.txt

  La estrategia funciona pero supone que esperemos a que la :program:`ordenA`
  acabe de escribir el resultado y, además, que el resultado tengamos que
  almacenarlo temporalmente en disco.

- Utilizar tuberías con nombre.
- Usar la sintaxis que brinda :program:`bash` llamada en su manual *process
  substitution*.

.. _mkfifo:
.. index:: mkfifo

**Tuberias con nombre**
   Las :dfn:`tuberías con nombre` consisten en crear un archivo especial que
   representa una tubería con la orden :manpage:`mkfifo` y hacer que los dos
   programas involucrados lean y escriban en él, como si se tratara de un
   archivo regular. La ventaja es que la transferencia de datos se lleva a cabo
   del mismo modo que cuando se usan tuberías anónimas normales y por tanto, ambos
   procesos sincronizan la producción y el consumo, por lo que no se
   almacenan datos en disco. De este modo, si es la :program:`ordenB` la que tiene
   que leer de archivo, podemos hacer::

      $ mkfifo /tmp/tuberia
      $ ordenA > /tmp/tuberia & ordenB /tmp/tuberia
      $ rmdir /tmp/tuberia

   y si es la :program:`ordenA` la que solo puede escribir en un archivo::

      $ mkfifo /tmp/tuberia
      $ ordenA /tmp/tuberia & ordenB </tmp/tuberia

.. _bash-process-substitution:

**Process substitution** (extensión de :program:`bash`, incompatible con *POSIX*)
   El primer caso de limitación es que :program:`ordenB` sólo sea capaz de leer de
   archivo, esto es, la sintaxis posible es :kbd:`ordenB archivo-entrada`. Si es
   así, la forma imposible::

      $ ordenA | ordenB

   se puede resolver con::

      $ ordenB <(ordenA)

   mientras que el segundo caso de limitación, que consiste en que
   :program:`ordenA` sólo es capaz de escribir su resultado en un archivo, esto
   es, que la sintaxis posibles es :kbd:`ordenA archivo-salida`, como no puede
   resolverse::

      $ ordenA | ordenB

   se resuelve::

      $ ordenA >(ordenB)

   .. note:: Con *POSIX* puede subsanarse la carencia, aunque utilizando :ref:`técnicas
      de redirección <ioredirect>` algo avanzada. Así la expresión::

         $ ordenB <(ordenB)

      puede lograrse de este modo::

         $ ordenA | ordenB /dev/fd/0

      o de forma más general usando otro descriptor::

         $ ordenA 3<&- | ordenB /dev/fd/3 3<&0

      Por su parte::

         $ ordenA >(ordenB)

      puede emularse con::

         $ ordenA /dev/fd/1 | ordenB

      o de forma más general usando otro descriptor::

         $ ordenA /dev/fd/3 3>&1 | ordenB 3>&-

   .. https://unix.stackexchange.com/a/309594

      cmd1 | { cmd2 3<&- | { diff /dev/fd/3 /dev/fd/4; } 4<&0; } 3<&0

   Para que no quede expresado de forma tan general este apartado supongamos que
   queremos en una misma orden guardar el contenido del directorio raíz y a la
   vez contar cuántos archivos contiene. La solución es la siguiente::

      $ ls / | tee >(wc -l) >/tmp/listado.txt

.. rubric:: Notas al pie

.. [#] ¡Téngase cuidado! No vale cambiar de orden las redirecciones::

      $ sadhgaskjhsa 2>&1 >contenedor_del_error
      sadhgaskjhsa: no se encontró la orden

   ya que en este caso se redirige la salida del descriptor 2 hacia la
   salida del descriptor 1, que en el momento de la redirección sigue
   siendo aún la pantalla.

.. [#] En principio, podemos usar una tubería para emular un *Here String*::

      $ echo "Hola, don Pepito" | cat
      Hola, don Pepito

   pero en ese caso la parte derecha de la tubería se ejecuta dentro de una
   *subshell*, cuyo inconveniente principal es que impide definir o redefinir
   el valor de una variable, ya que lo que se haga en la *subshell*, en la
   *subshell* queda. Por ejemplo, si hiciéramos uso de :ref:`read <read>`, que
   veremos a continuación::

      $ echo "valor" | read -r VAR
      $ echo $VAR

   no habría conseguido dar valor a VAR, porque al salir de la *subshell* queda
   sin ehecto la asignación de valor.

.. [#] No viene instalado de serie en el sistema, por lo que hay que instalar
   el paquete del mismo nombre.

.. [#] Recordemos que los fabricantes de discos utilizan los múltiplos del bytes
   suponiendo que la relación entre ellos es 1000, cuando las unidades que
   maneja el sistema operativo siempre son en múltiplos de 1024.
