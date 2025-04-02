.. _audit:

Auditoría
=========

El servicio de auditoría de *linux* (**audit**) permite vigilar el acceso a
ciertos ficheros y directorios sobre los que deseamos tener control.

Instalación
-----------

Basta con instalar el demonio :command:`auditd`::

   # apt-get install auditd

El comportamiento del servicio puede manipularse (activarse, desactivarse,
habilitarse, deshabilitarse, etc.) tal como :ref:`se ha descrito anteriormente
<invoke-rc.d>`.

La configuración del servicio se guarda bajo el directorio :file:`/etc/audit`.

.. _auditctl:
.. index:: auditctl

Reglas
------

La configuración de la auditoría requiere la definición de sus reglas, esto es,
la indicación de qué ficheros queremos vigilar y cuáles accesos: *r*, lectura;
*w*, escritura; *x*, ejecución; o *a*, atributos (como un cambio de el
propietario). Para esta tarea podemos usar el comando :command:`auditctl`::

   # auditctl -w /srv/ftp -p rwxa

La orden comienza a vigilar el fichero (en realidad, directorio) y registrarán
todos los posibles accesos al directorio\ [#]_. Para comprobar que la regla se
ha apuntado podemos hacer lo siguiente::

   # auditctl -l
   -w /srv/ftp -p rwxa

Si quiésaramos vigilar el uso de algún programa, podríamos hacer lo siguiente::

   # auditctl -w /usr/bin/passwd -p x

Para eliminar alguna regla, debemos escribir la misma línea, pero con la opción
``-W`` en vez de ``-w``::

   # auditctl -W /usr/bin/passwd -p x

Si lo que queremos es eliminar todos las reglas, puede usarse ``-D``::

   # auditctl -D

Cuando se definen reglas es posible indicar una clave (de hasta once letras), de
manera que después se puedan hacer consultas usando tal clave::

   # auditctl -w /srv/ftp -p rwxa -k servicios
   # auditctl -w /srv/www -p rwxa -k servicios

De este modo, podremos comprobar los accesos a ambos lugares a través de la clave
*servicios*.

Junto a todas estas opciones, :command:`auditctl` dispone de ``-F`` que es la
forma general de definir reglas. Por ejemplo, la línea::

   # auditctl -w /srv/ftp -p rwxa -k servicios

equivale a::

   # auditctl -a exit,always -F dir=/srv/ftp -F perm=rwxa -F key=servicio

La opción ``-F`` tiene la ventaja de que permite definir otras condiciones para
las que no existe opción específica. Por ejemplo, quizás nos interesara
registrar sólamente cuándo los alumnos (que supongamos que se encuentran todos
incluidos en el grupo *alumnos*) escriben a través del servicio FTP. Para ello
podríamos hacer lo siguiente::

   # auditctl -w /srv/ftp -p w -F agid=alumnos

El problema de definir de este modo las reglas es que no son permanentes. Si
queremos hacerlas permanentes, debemos escribirlas en algún fichero adecuado.
Para ello basta con crear un fichero dentro de :file:`/etc/audit/rules.d` que
contenga líneas con los argumentos que proporcionamos a :command:`auditctl`::

   # cat > /etc/audit/rules.d/servicios.rules
   -w /srv/ftp -p rwxa -k servicios
   -w /srv/www -p rwxa -k servicios

Esto permitirá hacer las reglas permanentes.

.. note:: Si antes de hacer las reglas permanentes, las probamos escribiendo
   las órdenes con :command:`audictl`, podemos aprovecharlas redireccionando su
   listado::

      # auditctl -l -k servicios > /etc/audit/rules.d/servicios.rules

.. warning:: No edite el fichero :file:`/etc/audit/audit.rules`, puesto que su
   contenido se genera automáticamente a partir de los ficheros modulares
   contenidos en :file:`/etc/audit/rules.d`.

.. _ausearch:
.. index:: ausearch

Consulta
--------

Tan interesante como saber crear las reglas es saber consultar los registros que
dejan. Para ello se usa el comando :command:`ausearch`, con ciertas opciones que
nos permiten filtrar:

:code:`-f`
   Obtiene los registros relacionados con un fichero::

      # ausearch -f /srv/ftp
      [...]
      time->Sat Dec 24 14:53:25 2016
      type=PROCTITLE msg=audit(1482587605.441:71): proctitle=6C73002D2D636F6C6F723D6175746F002F7372762F6674702F
      type=PATH msg=audit(1482587605.441:71): item=0 name="/srv/ftp/" inode=67 dev=fd:01 mode=040755 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL
      type=CWD msg=audit(1482587605.441:71): cwd="/home/usuario"
      type=SYSCALL msg=audit(1482587605.441:71): arch=c000003e syscall=2 success=yes exit=3 a0=564b78df55d0 a1=90800 a2=0 a3=504 items=1 ppid=575 pid=1161 auid=1000 uid=1000 gid=1000 euid=1000 suid=1000 fsuid=1000 egid=1000 sgid=1000 fsgid=1000 tty=pts0 ses=1 comm="ls" exe="/bin/ls" key="servicios"

   Obsérvese que puede conocerse cuándo se accedio, pero también quién lo hizo y
   con qué comando. Si se añade la opción ``-i`` se traduciran los identificadores
   numéricos por el correspondiente nombre.

:code:`-c`
   Obtiene los registros que se generaron por el uso del comando indicado::

      # ausearch -c ls

   Esto devolvería los registros generados por listar directorios. Por supuesto,
   las opciones no son excluyentes::

      # ausearch -f /srv/ftp -c ls

:code:`-x`
   Obtiene los registros que contienen en el campo *exe* (de ejecutable) el valor
   que se proporciona::

      # ausearch -f /srv/ftp -x /bin/ls

:code:`-k`
   Obtiene los registros relacionados con las reglas que se marcaron con la
   clave indicada::

      # ausearch -k servicios

:code:`--start`, :code:`--end`
   Fija los límites temporales para la búsqueda. Pueden usarse palabras
   predefinidas (véase la página de manual) como *today*, *this-waek*, etc. o la
   expresión de la fecha y hora en la lengua expresada por :var:`LC_TIME`::

      # ausearch -f /srv/ftp --start 23/12/16 13:00:00

   Obsérvese que la fecha y la hora se escriben en argumentos distintos, esto
   es, no hay que encerrarlas entre comillas. Los años debe escribirse con dos
   cifras únicamente.

:code:`--ue`, :code:`--ul`, :code:`--ui`, :code:`--ua`
   Filtra según el usuario que realiza la acción: usuario efectivo (``-ue``),
   usuario que efectuó el login (``--ul``) o usuario (``--ui``). Cuando se usa,
   ``-ua`` indicamos que queremos que el usuario pueda ser cualquiera de los
   anteriores. Podemos indicar el nombre de usuario, en vez del *uid*.

:code:`-m`
   Filtra según el tipo de mensaje (el valor de :code:`TYPE=`)::

      # ausearch -f /srv/ftp -m SYSCALL

   Pueden incluirse varios separando por comas. Si se indica un tipo
   desconocido, se muestran los tipos posibles.

.. _aureport:
.. index:: aureport

Informes
--------

El servicio de auditoría dispone de otra herramienta más, :command:`aureport`,
que permite hacer informes (salidas más resumidas) de los registros. El modo más
simple de usar la herramienta es::

   # aureport

que devolverá un resumen general. Se pueden, no obtante, hacer resúmenes de
distintos aspectos como autenticación (``--auth``), acceso a ficheros
(``--files``), etc.::

   # aureport --file

Es posible también pasar la salida de :command:`ausearch` si hemos usado filtros
que han reducido la información registrada::

   # ausearch -f /srv/ftp --start 23/12/16 13:00:00 --raw | aureport --file

Enlaces de interés
------------------

* `Auditd - Tool for Security Auditing on Linux Server <http://linoxide.com/how-tos/auditd-tool-security-auditing/>`_.
* `How To Use the Linux Auditing System on CentOS 7 <https://www.digitalocean.com/community/tutorials/how-to-use-the-linux-auditing-system-on-centos-7>`_.

.. rubric:: Notas al pie

.. [#] Pero también a todos los ficheros y subdirectorios que contienen.
   Si quisiéramos vigilar solamente el directorio sin incluir los subdirectorios
   la regla debería haber sido esta::

      -a exit,always -F path=/srv/ftp -F perm=rwxa

   Sígase avanzando en la lectura para entender esto.
