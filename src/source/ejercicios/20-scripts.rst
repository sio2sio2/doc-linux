Ejercicios sobre scripts
========================

Ejercicios mínimos
------------------
#. Escriba un programa que pida una frase y la repita en mayúsculas.

#. Lo mismo pero el programa seguirá pidiendo una frase hasta que se escriba
   "fin".

#. Escriba un programa que imprima los 100 primeros números impares.

#. Escriba una función que compruebe si el parámetro suministrado
   es un número entero.

#. Escriba un programa que pida dos números enteros posiitivos y los sume.

#. Escriba un programa que pida dos números enteros, una operación básica
   (sumar, restar, multiplicar o dividir) y realize la operación.

#. Escriba un función que indique si un año es bisiesto o no.

   .. note:: Son bisiestos los años múltiplos de 4, excepto los múltiplos de
      100, si no son múltiplos de 400.

#. Escriba una función que devuelva un número al azar entre dos dados
   cualesquiera.

   .. note:: A menos que usemos la variable no estándar *RANDOM*, la generación
      de números aleatorios en la *shell* no es trivial. Puede usar, no obstante,
      el código de ejemplo incluido al :ref:`explicar los bucles <sh-while>`.
      Observe que la función *random* incluido en él permite obtener números
      hexadecimales de cualquier tamaño simplemente indicándo de cuántos bytes
      es tal número.

Ejercicios
----------
#. Pida un usuario y una contraseña por pantalla, tras lo cual muestre el
   mensaje "*Ha escogido para identificarse NOMBRE_USUARIO/CONTRASEÑA*",
   donde *NOMBRE_USUARIO* y *CONTRASEÑA* es lo tecleado.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/ejB-01.sh>`

#. Pida lo mismo; pero, en vez de mostrar el mensaje por pantalla,
   guarde ambos datos dentro del fichero :file:`vpasswd` en el formato::

      NOMBRE_USUARIO:CONTRASEÑA

   Hágalo de forma que, si se vuelve a ejecutar el *script*, no se borren
   los usuarios ya almacenados.

   En cuanto al directorio en que debe alojarse :file:`vpasswd`.

   * Suponga que no preocupa al escribir el código. ¿Dónde acabará
     almacenado?
   * Suponga que quiere almacenarlo en el directorio personal del usuario.
   * Suponga que quiere almacenarlo en el directorio en que se encuentra el
     propio ejecutable. Esto aún no sabe resolverlo, si no ha visto cómo tratar
     los argumentos pasados al *script*, así que vuelva a esta pregunta más
     adelante.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/ejB-02.sh>`

#. Repita el ejercicio anterior, pero la contraseña no debe almacenarse
   en claro sino codificada tal y como aparece en el fichero
   :file:`/etc/shadow`.

   .. note:: Para codificar la contraseña puede usar :command:`openssl`::

         $ openssl passwd -1 -salt a contraseña

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/ejB-03.sh>`

#. Añada la posibilidad de que la contraseña se cifre o no, mediante la
   inclusión de un argumento en la línea de órdenes. Si se hace::

      $ ./script.sh

   La contraseña no estará cifrada; si se hace::

      $ ./script.sh c

   si lo estará. Si se escribe cualquier otro argumento el programa
   debe fallar devolviendo un **2** al sistema.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/ejB-04.sh>`

#. Mejore el *script* anterior para que se compruebe si no se escribe
   nada al pedir el usuario; y se pregunte una segunda vez la contraseña
   y se compruebe que en ambos casos es la misma. Si no se cumple esto,
   el programa debe acabar con un **1**.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/ejB-05.sh>`

#. Vuelva a escribir el mismo programa pero:

   * Se insiste hasta que el nombre de usuario no esté vacío.
   * Se insiste hasta que las dos contraseñas son iguales.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/ejB-06.sh>`

#. Como en el caso anterior, pero las insistencias se limitan a **3**.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/ejB-07.sh>`

#. Tomando toda la casuística del supuesto anterior, use el fichero
   :file:`vpasswd` del siguiente modo:

   * La contraseña siempre se almacenará cifrada (con lo que puede prescindir
     del análisis del parámetro ``c``).
   * Si el fichero ya existe, se pide el usuario mostrando el que había
     almacenado y, si el usuario lo deja en blanco, se conserva el usuario
     antiguo.
   * Si la contraseña se deja en blanco y el usuario no cambió, la contraseña
     tampoco varía. Si el usuario cambió, entonces no se conserva la contraseña,
     aunque se deje en blanco.
   * Se actualiza el fichero para que almacene exclusivamente el nuevo usuario y
     contraseña.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/ejB-08.sh>`

#. Se desea crear un script para automatizar la creación de usuarios para el
   servidor |FTP|, de manera que:

   * Los usuarios son usuarios reales (aparecen en :file:`/etc/passwd`).
   * Sus directorios personales son :file:`/srv/ftp/NOMBRE_USUARIO`.
   * Su grupo principal es *ftpusers*.
   * Si el usuario ya existe, se genera un error.

   Además, si se añade el argumento ``--no-password``, no se pide contraseña
   y el usuario se crea con la contraseña deshabilitada.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/ejB-09.sh>`

#. Modifique el ejercicio anterior para que ee cree con contraseña deshabilitada
   cuando se deja en blanco al pedirla.

#. Enriquezca el ejercicio anterior para que se admita como primer
   argumento el nombre de usuario y como segundo la contraseña, pero
   ambos argumentos son opcionales. El programa preguntará de modo
   interactivo sólo aquellos datos que no se le han pasado como argumentos.

#. Defina una función llamada *netaddr* que calcula la dirección de red a partir
   de cualquier dirección de equipo expresada en notación :abbr:`CIDR ()`.
   Deberá poder usarse así:

   .. code-block:: bash

      netaddr 192.168.25.4/23

   .. note:: El estándar *POSIX* define la `calculadora bc
      <http://pubs.opengroup.org/onlinepubs/9699919799/utilities/bc.html>`_ que
      le puede servir para hacer cambios de base muy fácilmente. Sin embargo,
      esta orden no tiene por qué estar disponible en el sistema. En *debian* no
      forma parte de la instalación mínima y :program:`busybox` no tiene la
      implementada.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/netaddr.sh>`

#. Modifique el ejecicio anterior para que:

   * Cuando no se incluye la máscara, se sobreentienda que es la predeterminada.
   * La función, además, de admitir un único argumento (|IP| en notación CIDR),
     admita dos que representen respectivamente la dirección y la máscara (en
     forma de dirección |IP|):

     .. code-block:: bash

        netaddr 192.168.25.4 255.255.254.0

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/netaddr.v2.sh>`

#. Un servidor |SSH| tiene dos tipos de usuarios:

   #. Usuarios normales que pueden utilizar el servidor sin restricciones
      especiales.

   #. Unos usuarios a los que se les permite exclusivamente el uso del servidor
      |SSH| para la transferencia de ficheros. Estos usuarios, además, estarán
      enjaulados en su propio directorio personal.
   
   Para llevar a cabo lo anterior se ha decidido:

   - Los usuarios normales se darán de alta en el sistema de modo que se creará
     un grupo exclusivo con su mismo nombre, su información *gecos* coincidirá
     con su nombre de usuario y su directorio será el habitual
     (:file:`/home/$usuario`)

   - Los usuario cuyo acceso se restringe a la transferencia de ficheros tendrá
     todos como grupo principal "losdelftp" y no un grupo exclusivo, su
     información *gecos* será "nombre_usuario (FTP)" y su directorio habitual
     será (:file:`/home/ftp/$usuario`).

   Desarrolle un *script* que permita dar de alta estos dos tipos de usuarios.

   .. note:: Por cuestiones de seguridad, |SSH| sólo permite enjaular usuarios
      dentro de un directorio si todos los directorios que forman parte de la
      ruta de la jaula pertenecen a *root* y el usuario
      enjaulado no tiene permisos de escritura sobre ellos. Deberá tener en
      cuenta esto al crear los usuarios y, además, para el caso de un usuario
      restringido a la transferencia crear un subdirectorio "incoming" dentro de
      su directorio personal en el que tengan permisos de escritura a fin de que
      pueda subir ficheros.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/crear_usuario.sh>`

#. En el servidor de un centro con un ciclo medio de Sistemas Microinformáticos
   y Redes, el profesor encargado de mantenerlo quiere a principios de
   septiembre hacer la transición del curso pasado al actual.

   El servidor está organizado de la siguiente forma:

   + Los alumnos de primero tienen como grupo principal *smr1*.
   + Los alumnos de segundo tienen como grupo principal *smr2*.
   + Los alumnos con módulos de primero matriculados en alguno de segundo
     tienen como grupo principal *smr1* y pertenecen a *smr2*.

   El profesor encargado parte de la configuración del curso pasado y, a la
   vista de las nuevas matriculaciones, debe actualizar la situación de usuarios
   y grupos. Para ello recibe un fichero con la siguiente pinta:

   .. code-block:: none

      Nombre Real1;DNI1;1
      Nombre Real2;DNI2;1+
      Nombre Real3;DNI3;2

   donde aparece los alumnos actualmente matriculados y "1" significa que el
   alumno sólo cursa primero, "2" que sólo cursa segundo y "1+ que está entre
   primero y segundo. El nick del alumno en el sistema se obtiene tomando la
   inicial de su primer nombre, las tres letras iniciales de los dos apellidos y
   las tres últimas cifras del DNI (p.e. Manuel Jesús Vázquez Montalbán pasa
   a mvazmonNNN).

   Se pide crear un programa que tome el listado y

   + Limpie del sistema los alumno que ya no se encuentren matriculados (bien
     por abandono, bien porque hayan acabado). Bórrese también su directorio de
     usuario.

   + Actualice la pertenencia a grupos de los alumnos que ya existieran en el
     sistema.

   + Añada los nuevos alumnos matriculados.

   Sintaxis::

      # matriculacion.sh fichero

   .. note:: Nota: En la información gecos debe añadirse el nombre real del
      alumno (no su DNI) y si repite añadirse tras el nombre la palabra
      "repetidor" entre paréntesis.

   .. note:: Haga el programa para manipular usuarios locales, pero escriba el
      programa de modo que sea fácil cambiar a otro tipo de usuarios.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/matriculacion.sh>`

#. Se desea crear un *script* que gestione los ejercicios de programación de
   scripts que han realizados los alumnos con un determinado grupo primario. La
   gestión consistirá en dos posibles tareas, diferentes entre sí:

   #. Generación de un informe que resuma los scripts que han realizado
      los alumnos desde la última vez que se generó informe.

   #. Listado de los scripts realizados por un determinado alumno y recogidos en
      el último informe, así como la comprobación de que el alumno no ha
      hecho modificaciones posteriores.

   La sintaxis de ejecución del script será la siguiente::

      ./vigilante.sh -c alumno|-g grupo

   Las opciones son excluyentes entre sí y, al menos, debe expresarse una de
   ellas. La opcion "-g" provoca que el script realice la primera tarea y la
   opción "-c" que realice la segunda. El script está pensado para ejecutarse
   como "root".

   **Descripción de 1ª tarea**

   Dentro del subdirectorio "Informes" de root, deberán guardarse los informes
   con el nombre "grupo_fechaEjecucion.txt". El fichero deberá al menos contener
   lo siguiente (los comentarios no forman parte del formato y sólo sirven para
   aclarar la línea):

   .. code-block:: none

      %			       # Separador de usuarios.
      usuario1                 # El nick del usuario del que se obtienen scripts
      /path/absoluto/script1   # Lista de scripts posteriores al último informe.
      /path/absoluto/script2
      ... más scripts ...
      %
      usuario2
      /path/absoluto/script1
      /path/absoluto/script2
      ... más scripts ...
      ... resto de usuarios del grupo ...

   .. note:: Es obvio que deberá incluir algo más dentro del informe para poder
      saber si los *scripts* han cambiado al realizar este *script* la segunda
      tarea. Es su tarea determinar qué añade.

   Se considerará que los usuarios que deben incluirse en el informe son aquellos
   que tiene como grupo principal el grupo que se expresa con :kbd:`-g`.

   Los scripts realizados por el usuario se encontrarán siempre dentro de su
   propio directorio personal (lo cual incluiye subdirectorios).

   **Descripción de 2ª tarea**

   Consiste en listar los *scripts* de un usuario que el último informe emitido
   recogió. Junto al nombre debe incluirse la leyenda:

   * *Correcto*: si el *script* no se ha modificado posteriormente
   * *Modificado*: si el *script* se modificó posteriormente. Al darse esta
     circunstancia, el *script* debe finalizar inmediatamente sin seguir revisando
     más *scripts* e imprimir la leyenda: "El alumno ha intentado hacer trampas".
   * *Borrado*: Si el *script* no se encuentra.

   Por ejemplo::

      # ./vigilante.sh -c alumno1
      /path/absoluto/script1       Correcto
      /path/absoluto/script2       Correcto
      /path/absoluto/script3       Borrado
      /path/absoluto/script4       Correcto
      /path/absoluto/script5       Modificado

      El alumno 'alumno1' ha intentado hacer trampas.

   *Bonus track*: Añadir la opción -s NUM, de modo que si NUM=0 se revisa el
   último script; si NUM=1, se revisa el penúltimo y así sucesivamente. No
   indicar la opción, implica NUM=0.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/vigilante.sh>`

Ejercicios prácticos
--------------------
Esta tanda de ejercicios requiere la puesta en práctica de conocimientos sobre
el sistema y las herramientas que existen en él.

#. Retomando la última versión del *script* para crear usuarios de |FTP|,
   modifíquelo para que se creen usuarios reales (lo ya hecho) o virtuales
   legibles con el módulo :ref:`pam_userdb <pam_userdb>`.

#. Se desea vigilar si alguno de los sistemas de ficheros del servidor
   superan el 90% de ocupación para que, si es así, se envíe un mensaje a la
   dirección de correo del administrador. Disponga todo lo necesario
   para que se haga la comprobación una vez al día.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/diskmonitor.sh>`

#. Cree un *script* que permita hacer copias de seguridad de los datos contenidos
   dentro del directorio personal, de manera que:

   + La sintaxis del script será::

      copion [-r referencia] [listado]

   + Aquellos ficheros y directorios que se quiera que formen parte de la copia
     se incluirán dentro de un fichero de listado, uno por línea. Incluir un
     directorio, significa incluirlo a él y a todo su contenido.
   + Las rutas relativas de los ficheros se entenderán relativas al directorio
     personal.
   + Si no se especifica fichero de listado o el fichero de listado es -, se
     esperará tomar la lista de la entrada estándar.
   + Si se incluye una referencia temporal, y el fichero de referencia:

     - No existe, se copiarán todos los ficheros del listado, y al final de
       la copia se creará tal fichero de referencia temporal para usos
       posteriores del *script*.
     - Si existe, sólo se guardarán en la copia los ficheros del listado más
       recientes que esa referencia temporal; y al final de la copia, se
       actualizará la fecha de la referencia para usos posteriores del *script*.

   + Si no se incluye una referencia temporal, se copiarán todos los ficheros
     del listado y no se creará referencia alguna al finalizar.
   + El fichero de backup que se cree deberá nombrarse como
     :file:`nombre_usuario_AAAA-MM-DD.tar.xz`, donde *AAAA-MM-DD* es la fecha de
     creación de la copia de seguridad y la extensión se corresponde con el
     formato real del fichero.

#. Para un determinado módulo de Formación Profesional el profesor entrega a los
   alumnos un disco duro virtual con un sistema linux que servirá de base para
   la realización de gran parte de las prácticas del curso. La intención es que
   en cada una de ellas el alumno coja una copia de este disco y haga en ella
   las instalaciones y configuraciones necesarias para la realización de la
   práctica. Como el disco virtual es muy pesado (en torno a 1GB), el profesor
   ha pensado que, dado que se parte siempre de un mismo sistema base, lo único
   que necesita para recoger la práctica es que cada alumno le pase las
   diferencias. Por ello decide diseñar un *script* para incluirlo dentro del
   sistema base, que pase a un fichero de copia sólo los ficheros que han
   sufrido alguna modificación o han sido instalados, ya que al volcar dicha
   copia sobre otro sistema base, obtendrá el estado en que quedó el sistema del
   alumno al completar la práctica. Las características de esta copia son las
   siguientes:

   * Sólo incluye ficheros modificados o no incluidos en el sistema base.
   * Adicionalmente se quiere que se pueda añadir un límite de tiempo, de manera
     que si un fichero fue modificado a añadido antes de él, no se incluirá en
     la copia, aunque cumpla el precepto anterior. Por ejemplo, si al ejecutar
     el *script* se establece un límite de 2 horas, cualquier modificación o
     adición que se produjera antes de las dos horas anteriores a la ejecución
     del *script* no aparecerá en la copia.
   * La copia nunca incluirá ficheros que se encuentren en directorios cuyos
     cambios o cuyo contenido se consideren irrelevantes para el propósito de la
     copia. Por ejemplo, /proc o /dev. Decida usted cuáles son.
   * Es posible indicar una lista de ficheros que se incluirán en todo caso, a
     pesar de que no cumplan los dos primeros preceptos.
   * El nombre de la copia debe ser de la forma backup_nombre_AAAA-MM-DD.tar.xz,
     donde AAAA-MM-DD es la fecha en la que se ejecuta el script y "nombre" es
     un nombre que se facilita al ejecutar el *script*. Si no se facilita
     ninguno, se toma el nombre de la máquina.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/backup.sh>`

#. En un centro educativo se desea vigilar qué ordenadores de la red se
   quedan encendidos por la noche, con el fin de amonestar a los alumnos
   despistados. Para ello se desea lanzar un *script* desde el servidor que
   inspeccione la red y obtenga las direcciones |MAC| de los equipos
   encendidos y haga llegar la lista de tales equipos mediante correo
   electrónico al administrador. Si ningún equipo quedó encendido, no se enviará
   mensaje.

   Escriba el *script* y explique cómo ejercutarlo para llevar a término el
   objetivo propuesto.

   **Solución propuesta**: Vea el ejercicio siguiente.

#. Mejore el *script* para que:

   - Haya un listado de equipos existentes que asocie a cada |MAC| un nombre
     identificativo (p.e. el nombre del alumno que lo usa habitualmente).
     En el mensaje al administrador, se enviará no sólo la |MAC|, sino también
     este nombre.

   - Puedan existir equipos a los que se les permita permanecer encendidos (p.e.
     una impresora de red) y, por tanto, que deban ser excluidas del listado de
     equipos encendidos.

   .. note:: Tiene total libertad para establecer el formato de este listado y
      la forma en la que notará cuáles deben ser excluidos del informe de
      encendidos.

   .. rst-class:: sol-script

      :download:`Solución propuesta </ejercicios/soluciones/discover.sh>`

.. |MAC| replace:: :abbr:`MAC (Media Access Control)`
