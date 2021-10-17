.. _procmail:

:program:`procmail` (|MDA|)
===========================
:program:`procmail` es un |MDA| tradicional en los sistemas *UNIX*. Lleva muchos
años sin mantenerse (desde 2001) y tiene algunos *bugs* conocidos. Hay otros
agentes más modernos como `maildrop <http://maildrop.cc>`_ o *software* basado
en el `lenguaje sieve
<https://en.wikipedia.org/wiki/Sieve_(mail_filtering_language)>`_ (:rfc:`5228`).
No obstante, se explicará bajo el epígrafe, porque apenas tiene dependencias y
tradicionalmente se incluía en la instalación básica\ [#]_

Preliminares
------------
El |MDA| es necesario bien cuándo descargamos mensajes de un servidor remoto
haciendo uso de un |MRA|, bien cuando nuestro |MTA| recibe o genera un mensaje y
su destinatario es local. Por ello puede invocarlo:

#. El |MRA| (:ref:`fetchmail <fetchmail>` en nuestro caso) directamente.
#. El |MTA| explícitamente.
#. Complementariamente, el |MDA| interno del |MTA|, si quiere hacer algo más que
   dejar mensajes en un buzón.

En los primeros casos, la invocación es debida a que así se indica en los
ficheros de configuración\ [#]_, mientras la última a que cada usuario en
particular haya creado un fichero :file:`~/.forward` que contenga la siguiente
línea::

   "|IFS=' ' && exec /usr/bin/procmail || exit 75"

Configuración
-------------
Se realiza dentro del fichero :file:`.procmailrc` que tiene esta estructura::

   # Definición de variables
   DEFAULT=$HOME/Maildir/
   MAILDIR=$DEFAULT
   SHELL=/bin/sh
   RCD=$HOME/.procmail/rc.d
   LOGFILE=$HOME/.procmail/log

   # Configuración modular
   INCLUDERC=$RCD/spam.rc
   INCLUDERC=$RCD/listas.rc

   # Todo mensaje que llegue al final
   # de la configuración se entregará en $DEFAULT.

.. note:: Si nuestra configuración fuera muy pequeña, podríamos prescindir de la
   modularidad y haber escrito los bloques de filtro (*recetas* con la
   terminología de :program:`procmail`) según se explicarán a continuación,
   dentro de este mismo fichero.

La configuración es, básicamente, un conjunto de recetas que se ejecutan en el
orden en que aparecen escritas. Las recetas pueden ser de dos tipos:

* De *entrega*, que son aquellas que provocan la entrega del mensaje y, en
  consecuencia, que se cese el procesamiento. Son de este tipo, las recetas que
  dejan el mensaje en un buzón, que lo reenvían a una dirección de correo o que
  hacen que sea absorbido por un programa.

* De *paso*, que no entregan el mensaje, por lo que se continuarán revisando
  recetas. Son de este tipo aquellas que actúan como *filtro* haciendo que el
  mensaje pase a través de un programa y las que introducen un bloque anidado

Por su parte cada receta tiene esta estructura::

   :0 [flags]
   * Condición 1
   * Condición 2
   * etc...
   Acción

o sea, una línea que abre la receta; ninguna, una o varias líneas que expresan
condiciones; y una línea final que indica la acción a realizar con el mensaje en
caso de que se cumplan todas las condiciones.

Encabecamiento
""""""""""""""
La forma más fácil de escribir el encabezamiento es simplemente::

   :0

que determinará que la receta analice en las condiciones siguientes la
cabecera del mensaje (pero no el cuerpo), y que la receta sea de entrega o no,
dependiendo del carácter de la acción. Ahora bien, pueden añadirse uno o varios
indicadores que permiten alterar este comportamiento predeterminado. Algunos
son:

``B``
   permite comprobar en las condiciones el cuerpo. Si se quiere comprobar
   cabecera y cuerpo, puede añadirse ``HB``.

``A``/``a``
   Hace que la receta se compruebe sólo si se ejecutó la anterior. La
   diferencia es que ``a`` exige, además, que la acción acabara con éxito.

``E``
   Hace que la receta se compruebe si la anterior no lo hizo.

``e``
   Tiene el efecto contrario a ``a``: se comprueba la receta sólo si la anterior
   se ejecutó y falló.

``f``
   Considera la receta como un filtro. Para que esto sea así, la acción debe ser
   un programa que tomará el mensaje y lo alterará de algún modo. La salida será
   el mensaje resultante que seguirá comprobando el resto de recetas.

``c``
   Crea una copia de carbón del mensaje, de manera que, aunque la receta sea de
   entrega, una copia del mensaje continuará siendo procesada.

``w``
   Espera a que el filtro o programa acabe y comprueba cuál es su valor de
   salida, antes de seguir procesando.

.. note:: Tras los indicadores pueden añadirse, además, dos puntos ("*:*") para
   generar un fichero de bloqueo que impida que procmail intente escribir
   simultáneamente en dos ficheros a la vez. Si los buzones son de tipo *mbox*
   es fundamental que esto no suceda; pero en nuestro caso usaremos buzones
   *maildir* con lo que cada mensaje acabará en un fichero distinto.

Condiciones
"""""""""""
Las condiciones se notan empezándolas siempre con un asterisco (\*) y, en
principio, consisten en :ref:`expresiones regulares extendidas <regex>` que
comprueban las líneas de la cabecera (o del cuerpo, si se incluye el indicador
adecuando en el encabezamiento). Estas expresiones regulares, además, no
atienden a mayúsculas o minúsculas. 

Antes de la condición, no obstante, puede incluirse un carácter que modifica su
sentido:

``!``
   Invierte el sentido de la expresión regular.

``?``
   En vez del resultado de una expresión regular, usa el código de salida de un
   programa externo. Por ejemplo, la condición de esta receta se cumpliría
   siempre, ya que :ref:`true <true>` siempre tiene éxito::

      :0
      * ? true
      .TodosAcabanAqui/

   El programa obtiene por la entrada estándar la cabecera del mensaje (o el cuerpo
   o ambos, si se usó ``B`` o ``HB`` en la línea de encabezamiento), a fin de
   que pueda servir como filtro.

``<``
   Comprueba si el tamaño del mensaje es menor en bytes que el número que se
   proporcione.

``>``
   Comprueba si el tamaño del mensaje es mayor en bytes que el número que se
   proporcione.

Acciones
""""""""
La acción más habitual es entregar el mensaje en un buzón para lo cual sólo
se necesita la ruta del buzón. Para que :command:`procmail` considere que el
buzón tiene formato *maildir* el nombre debe acabar en "*/*". Además, si se
incluyen rutas relativas, se consideran relativas al directorio indicado por la
variable *MAILDIR*.

Ahora bien, puede añadirse un carácter al principio de la línea de acción para
alterar la acción habitual:

``!``
   Manda el mensaje a la dirección de correo indicada a continuación.

``|``
   Ejecuta el programa indicado a continuación, que obtiene de su entrada
   estándar el mensaje de correo. Para ello se usa la *shell*
   definida en la variable *SHELL*. Por lo general, el programa absorbe el
   mensaje, pero si se incluye en el encabezamiento el indicador "*f*", entonces
   la receta es un filtro y lo que supuestamente hará el programa es modificar
   el mensaje y el resultado pasarlo a la siguiente receta de la configuración.

``{``
   Abre un bloque de recetas, de manera que el mensaje que cumpla con las
   condiciones comenzará la comprobación de estas recetas. La llave
   debe encontrarse sola en la línea y cerrar el bloque de recetas con
   un ``}`` aislado.

Testeo
------
Para comprobar una configuración que hayamos hecho para :command:`procmail`
podemos usar la siguiente orden::

   $ procmail VERBOSE=on configuracion.rc < mensaje.txt

donde :file:`mensaje.txt` es un mensaje de correo que incluye cabecera y cuerpo
y :file:`configuracion.rc` la configuración que queremos comprobar. Ejecutada la
orden podríamos comprobar si el mensaje ha acabado en el buzón que esperamos.

Ejemplos
--------
#. Los correos dirigidos a nuestra cuenta del trabajo, los mandamos al buzón de
   trabajo\ [#]_::

      :0
      * ^TOcuenta_trabajo@mi_empresa.org
      .trabajo/

#. Transformar un *digest* en correos individuales::

      :0
      * List-Id:
      * Subject:.*DIGEST.*
      | formail +1 -ds procmail

   Esto haría\ [#]_ que cada correo individual se entregará, a su vez, a través
   de :program:`procmail`, a fin de que éste los deje en el buzón adecuado. Por
   tanto, debería haber otra receta distinta que hiciera tal cosa. Por ejemplo::
   
      :0
      * List-Id:.*lista@example.net
      .ListaDeEjemplo/


.. rubric:: Notas al pie

.. [#] Pero no desde que ha desaparecido el |MTA| de ella.

.. [#] Véase el epígrafe sobre :ref:`entrega con postfix <postfix-entrega>`.

.. [#] Al final de la página de manual :manpage:`procmailrc(5)` se enumeran
   algunas expresiones que se sustituyen por expresiones regulares antes de
   realizar la comprobación: ``^TO`` es una de ellas y permite asegurarnos de
   que tal dirección no sólo esté en el campo ``To:``.

.. [#] :command:`formail` es un programa que proporciona el propio
   :program:`procmail` y que permite manipular mensajes de correo (alterar
   cabeceras, etc.)

.. |MDA| replace:: :abbr:`MDA (Mail Delivery Agent)`
.. |MTA| replace:: :abbr:`MTA (Mail Transport Agent)`
.. |MRA| replace:: :abbr:`MRA (Mail Retrieval Agent)`
