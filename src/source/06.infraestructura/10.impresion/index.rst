.. _cups:

*********
Impresión
*********
La impresión se lleva a cabo en los linux modernos gracias al servidor
|CUPS|, y a una serie de drivers para las distintas impresoras en
formato ``.ppd``.  De todo ello tratará el presente documento.

Configuración inicial
=====================
Instalación
-----------
La instalación básica es sencilla::

   # apt-get install cups

ya que basta instalar :program:`cups`. Podemos también instalar una impresora
virtual PDF, por si deseamos realizar pruebas y no disponemos de impresora::

   # apt-get install printer-driver-cups-pdf

Ficheros
--------
La configuración del servidor se almacena bajo :file:`/etc/cups`. Tienen
especial relevancia:

* :file:`cupsd.conf`, que es el fichero de configuración del servidor.
* :file:`cupsd-printers.conf`, que es el fichero donde se almacenan las
  impresoras configuradas.

El segundo es recomendable no retocarlo a mano, sino a través de las
herramientas que proporciona :program:`cups`. En el primero pueden tocarse los
permisos para permitir que usen el servidor otras máquinas como clientes. Para
ello es necesario:

#. Sustituir la línea::

      Listen localhost:631

   por la línea::
   
      Port 631

#. Permitir expresamente el acceso en las localizaciones **/**, **/admin** y
   **/admin/config** con una línea del tipo::

      Allow from 192.168.1.0/24

   o semejante que permita el acceso a las redes que nos interesen.

Permisos
--------
En principio hay dos usuarios relacionados con la impresión:

* **lpadmin**, que tiene permisos para la administración.
* **lp**, que tiene permisos para imprimir.

Manejo
------
Hay dos formas de gestionar el servidor:

#. A través de su interfaz web que escucha en el puerto **631**.
#. Mediante la línea de comandos.

La primera es bastante intuitiva y recomendable en la mayor parte de los casos,
así que trataremos aquí la segunda.

Administración
==============
Impresoras
----------
Búsqueda
""""""""
Lo primero es localizar cuáles son las impresoras disponibles para ser añadidas
y cuáles son los drivers instalados en el sistema. Para lo primero\ [#]_\ [#]_::

   # lpinfo -v 
   network beh
   file cups-pdf:/
   network ipp
   network ipp14
   serial serial:/dev/ttyS0?baud=115200
   network http
   network https
   network ipps
   network lpd
   network socket
   network socket://172.16.1.241

En este caso, hay disponibles la impresora virtual PDF.(gracias a la
instalación que ya hicimos de su driver)  La consulta de drives disponbles se
hace mediante otra opción::

   # lpinfo -m
   lsb/usr/cupsfilters/Fuji_Xerox-DocuPrint_CM305_df-PDF.ppd Fuji Xerox
   ...

Instalación
"""""""""""
Debe usarse :command:`lpadmin`. Por ejemplo::

   # lpadmin -p PDFVirtual -D "Impresora PDF Virtual" \
     -L "Ninguna" -v "cups-pdf:/" -m "lsb/usr/cups-pdf/CUPS-PDF.ppd"

esto añade la impresora virtual llamada *PDFVirtual* con una descripción
(opción ``-D``) y  una localización (opción ``-L``) asociada al dispositivo
dado con la opción ``-v`` y usando el driver de la opción ``-m``. Los valores de
las últimas opciones se han tomado de las salidas correspondientes de
:command:`lpinfo`.

Una vez hecho esta. se habrá añadido la impresora y podremos verla al listar las
**disponibles**::

   $ lpstat -p
   la impresora PDF está inactiva.  activada desde dom 19 nov 2017 10:35:06 CET
   la impresora PDFVirtual está deshabilitada desde dom 19 nov 2017 11:52:41 CET

La primera de ellas es la impresora virtual que se añade automáticamente al
instalar el paquete que driver. De hecho, nuestra acción ha sido totalmente
inútil, más allá de que sirva para ilustrar cómo agregar. Observemos que
nuestra impresora está deshabilitada. Para habilitarla es necesario\ [#]_::

   # lpadmin -p PDFVirtual -E

También es útil listar las impresoras para que nos diga no su estado, sino el
dispositivo al que están asociadas::

   $ lpstat -v
   dispositivo para PDF: cups-pdf:/
   dispositivo para PDFVirtual: cups-pdf:/

La opción :kbd:`-s` devuelve la misma salida pero añadiendo cuál es la impresora
predeterminada::

   $ lpstat -s
   destino predeterminado del sistema: PDF
   dispositivo para PDF: cups-pdf:/
   dispositivo para PDFVirtual: cups-pdf:/

Si :program:`cups` no dispone del driver adecuado, pero podemos obtener el
fichero ``.ppd``, es posible agregar la impresora con él::

   # lpadmin -p RICOH -D "RICOH Aficio MP 171" -L "Sala de Profesores" \
     -v "socket://172.16.1.241" -P /path/a/MP_171.ppd

Aunque este método no hará disponible el fichero para posteriores agregaciones.
Si queremos que el el archivo ``.ppd`` se agrege a loa driver disponibles, basta
con moverlo a :file:`/usr/share/cups/model/` y reiniciar el servidor::

   # mv /path/a/MP_171.ppdf /usr/share/cups/model/
   # invoke-rc.d cups restart

Hecho esto, el driver aparecerá en la salida de :code:`lpinfo -m` y se podrá
agregar la impresora usando la opción ``-m``.

Gestión
"""""""
Cuando hay varias impresoras, una de ellas es la predeterminada, esto es,
aquella sobre la que se realizará una determinada acción (p.e. imprimir), en
caso de que no se especifique sobre cuál. Podemos conocer cuál está definida
como tal::

   $ lpstat -d
   destino predeterminado del sistema: PDFVirtual

Para cambiarla basta\ [#]_ con usar :command:`lpadmin`::

   # lpadmin -d PDF

Para borrar una impresora, basta con usar la opción ``-x``::

   # lpadmin -x PDFVirtual

Opciones
""""""""
Las impresoras tienen una serie de opciones predeterminadas que pueden cambiarse
mediante la orden :command:`lpoptions`::

   # loptions -p RICOH
   copies=1 device-uri=ipp://172.16.16.241/xxxx finishings=3
   job-cancel-after=10800 job-hold-until=no-hold job-priority=50
   job-sheets=none,none marker-change-time=0 number-up=1
   printer-commands=AutoConfigure,Clean,PrintSelfTestPage printer-info='RICOH
   Aficio MP 171' printer-is-accepting-jobs=false printer-is-shared=true
   printer-location='Sala de Profesores' printer-make-and-model='Ricoh Aficio MP
   171 PXL' printer-state=3 printer-state-change-time=1511091934
   printer-state-reasons=none printer-type=8917204
   printer-uri-supported=ipp://localhost/printers/RICOH

Sin más, muestra las opciones con la que está definida. Estas opciones pueden
alterarse (o añadirse otras) usando la opción ``-o``. Ahora bien, también
podemos crear *instancias* de la impresora que contengan distintas opciones de
impresión. Por ejemplo::

   # lpoptions -p RICOH/doscaras -o sides=two-sided-short-edge

De esta forma, lograremos otro perfil de impresión que incluye de forma
predeterminada la impresión a dos caras. De hecho, si comprobamos las impresoras
disponibles, ahora veremos esto::

   # lpstat -p
   la impresora PDF está inactiva.  activada desde dom 19 nov 2017 10:35:06 CET
   la impresora RICOH está inactiva.  activada desde dom 19 nov 2017 12:45:34 CET
   la impresora RICOH/doscaras está inactiva.  activada desde dom 19 nov 2017 12:45:34 CET

Si lo que se desea es eliminar una opción puede usarse la opción ``-r``::

   # lpoptions -p RICOH/doscaras -r sides

pero entonces nuestro perfiles de dos caras, imprimirá a una y será exactamente
igual que el perfil normal.

Hay un conjunto de opciones que son comunes a todos los drivers y que pueden
consultarse en `la documentación de cups
<https://www.cups.org/doc/options.html#OPTIONS>`_ o en la página de manual de
:manpage:`cups-client/lp(1)`. Otro conjunto, sin embargo, son *particulares* de cada
*driver*, pero pueden consultarse gracias a :command:`lopoptions`::

   $ lpoptions -p RICOH -l
   OptionTray/Option Tray: *NotInstalled 1Cassette 2Cassette
   ColorModel/Color Mode: *Grayscale
   Resolution/Resolution: *600dpi
   PageSize/PageSize: A4 A5 B5 Legal *Letter Statement F Folio ...
   InputSlot/InputSlot: MultiTray 1Tray 2Tray 3Tray *Auto
   Duplex/Duplex: *None DuplexNoTumble DuplexTumble
   Collate/Collate: *False True
   MediaType/Paper Type: *Auto Plain Recycled Special Colored Letterhead
   Preprinted Prepunched Labels Bond Cardstock OHP Thick
   RIPrintMode/Toner Saving: *0rhit 5rhit
   JobType/JobType: *Normal
   UserCode/User Code (up to 8 digits): *None 1001 1002 1003 Custom.PASSCODE

.. _impr-predeterminada:

Con :command:`lpoptions` también puede cambiarse la impresora predeterminada,
incluso a un perfil particular::

   # lpoptions -d RICOH/doscaras

.. warning:: Sin embargo, :command:`lpadmin` y :command:`lpoptions` no actúan
   sobre la misma parte de la configuración (el primero altera
   :file:`/etc/cups/printers.conf` y el segundo crea :file:`/etc/cups/lpoptions`)
   y prevalece lo dispuesto por este segundo. Esto hace que si se ha usado
   :command:`lpoptions` y se ha creado el segundo fichero, :command:`lpadmin`,
   deje de tener efecto. Por tanto, es bastante más recomendable usar
   :command:`lpoptions` siempre para este propósito.

Trabajos
--------
Impresión
"""""""""
Desde línea de comandos es muy sencillo imprimir directamente archivos de texto,
*postscript* o |PDF|::

   $ lp /etc/passwd
   $ ls /usr/bin | lp
   $ lp certificado.pdf

Usado de este modo, imprimiremos en la impresora predeterminada con las opciones
predeterminadas. Si queremos imprimir algún otro tipo de fichero tendremos que
hacer una conversión previa a uno de estos tres tipos. Por ejemplo::

   $ w3m -dump http://www.google.es | lp

imprime la página principal de `Google <http://www.google.es>`_, puesto que la
opción ``-dump`` hace una transformación a texto plano de la página\ [#]_.

Si se desea imprimir con otra impresora puede hacerse a través de la opción
``-d``::

   $ lp -d RICOH certificado.pdf
   $ lp -d RICOH/doscaras certificado.pdf

Para alterar las opciones predeterminadas de impresion, puede incluirse la
opción ``-o``::

   $ lp -d RICOH -o sides=two-sided-short-edge certificado.pdf

Si se quiere redefinir varias opciones, se puede repetir la opción ``-o``
o usar la misma y separar con un espacio::

   $ lp -d RICOH -o sides=two-sided-short-edge -o media=a4 certificado.pdf
   $ lp -d RICOH -o "sides=two-sided-short-edge media=a4" certificado.pdf

Para mandar varias copias a la impresora existe la opción ``-n``::

   $ lp -n2 certificado.pdf

Gestión de colas
""""""""""""""""
La consulta de los trabajos de impresión puede realizarse con
:command:`lpstat`::

   $ lpstat
   PDF-3                   usuario           2048   dom 19 nov 2017 17:59:35 CET
   PDF-4                   usuario           2048   dom 19 nov 2017 18:02:34 CET

La orden muestra los trabajos pendientes y es equivalente a::

   $ lpstat -W not-completed

También pueden listarse los trabajos ya completados (``completed``) o ambos
(``all``). Se puede añadir la opción ``-o`` para sólo mostrar los trabajos de
una impresora. Por ejemplo::

   $ lpstat -W all -o PDF

Cuando no se especifica usuario, se sobrentiende que los trabajos son los
propios del usuario que ejecuta la orden. Puede añadirse ``-u`` para mostrar los
de otros usuarios::

   $ lpstat -W all -o PDF -u usuario,root

Si lo queremos es cancelar trabajos de la cola antes de que la impresora los
cancele, podemos usar :command:``cancel``::

   $ cancel PDF-4

También se pueden cancelar todos los trabajos pendientes de un usuario::

   $ cancel -u usuario

aunque sólo podremos cancelar los del usuario propio si no somos el
administrador. Este, además, puede limpiar por completo la cola de pendientes::

   $ cancel -a

Compartición
============
.. todo:: Por escribir

Profundización
==============
Las impresoras requieren recibir los datos para su impresión escritos en un
|PDL|, esto es, un `lenguaje de descripción de páginas
<https://es.wikipedia.org/wiki/Lenguaje_de_descripci%C3%B3n_de_p%C3%A1ginas>`_,
como |PCL| (cuya versión 6 suele referirse como *PXL*) o `PostScript
<https://es.wikipedia.org/wiki/PostScript>`_. Los programas (editores y
procesadores de texto, visores de |PDF|, etc.), por su parte, generan una salida
hacia impresión *PostScript* junto a las opciones de impresión seleccionadass, que
recoge :program:`cups`. Este servidor de impresión, gracias a las reglas
contenidas en el driver |PPD| se encarga de componer los datos que se envía a la
impresora oara lo cual:

#. Añade al comienzo de los datos las opciones de impresión mediante
   instrucciones |PJL|. Por ejemplo::

      @PJL SET COPIES=2

   le indica a la impresora que debe sacar dos copias del documento, lo cual es
   una traducción de la opción ``-n`` de :command:`lp`.

#. Tras la cabecera se incluye el documento en el |PDL| que soporte la
   impresora. Si este es *PostScript*, no será necesaria hacer ninguna
   transformación. Si en cambio es otro, como |PCL| (*PXL* en particular),
   entonces el |PPD| indicará a :program:`cups` que haga uso de :command:`gs`
   (*ghostscript*), para llevar a cabo la transformación.

Estas acciones que determina hacer el driver |PPD| son las que se denominan
:dfn:`filtros`  y propician la creación del archivo final que se envía a la
impresora.

.. rubric:: tea4cups

`tea4cups <http://www.pykota.com/software/tea4cups>`_ es un *wrapper* para los
drivers de :program:`cups`, que permite interceptar la orden de impresión
después de que se hayan aplicado los *filtros* del controlador :kbd:`.ppd` y
antes de que el fichero sea enviado a la impresora.

El esquema de funcionamiento es el siguiente:

.. image:: files/tea4cups.png
   :alt: Esquema de funcionamiento de cups

Como puede verse, al actuar :program:`tea4cups`, el driver ya ha manipulado
sobre el fichero *postscript* que originariamente había enviado el servidor\
[#]_.

:program:`tea4cups` proporciona tres herramientas para manipular la impresión:

* `filter`, que es la primera que actúa y que únicamente permite alterar el
  flujo de datos. Debe ser un programa que tome por la entrada estándar
  los datos de impresión y devuelva por la salida estándar los datos
  modificados de impresión. No hay más acceso que al contenido de los datos.

* `prehook`, ganchos que actúan a continuación del filtro anterior y antes de
  que se envíen datos a la impresora. Hay disponibles algunas variables de
  ambiente y si acaba con un error 255, cancela la impresión. Es útil para
  hacer una manipulación de última hora sobre los datos que se mandan a la
  impresora (el contenido del archivo :var:`$TEADATAFILE`).

* `posthook`, ganchos que actúan después de que se haya dado la orden de impresión.

Para utilizar el programa son necesarias dos acciones:

#. Indicar qué impresora lo usará. Esto puede hacerse consultando cuál es el
   dispositivo asociado a la impresora::

      $ lpstat -v RICOH
      dispositivo para RICOH: socket://172.16.1.241

   y modificando su expresión, de modo que se preceda con el prefijo
   ":kbd:`tea4cups:`:"::

      $ lpadmin -p RICOH -v 'tea4cups:socket://172.16.1.241'

#. Incluir en el archivo de configuración :file:`/etc/cups/tea4cups.conf` qué
   filtros y ganchos se desea utilizar (consulte el propio archivo para más
   información). Por ejemplo, añadiendo las líneas::

      [RICOH]
      prehook_insertcode: /usr/local/bin/insertcode.sh

   donde el gancho es un *script* de la *shell* que hemos creado para manipular
   los datos que se envían a la impresora :var:`$TEADATAFILE`.

.. seealso:: Para ilustrar su uso se facilita el script
   :download:`pedir_codigo.sh <files/pedir_codigo.sh>` que:

   * Instala :program:`tea4cups` en caso de no estar instalado en el sistema.
   * Instala, si es necesario, el gancho :file:`insercode.sh` que permite
     introducir justo antes de la impresión el código de usuario con que se
     configuran algunas impresoras para controlar las impresiones de sus
     usuarios.
   * Permite seleccionar de entre las instaladas las impresoras con las que se
     quiere usar *tea4cups* aplicando este gancho.

.. rubric:: Notas al pie

.. [#] Se muestra el uso del comando como administrador, pero bien podría ser
   usando por otro usuario que perteneciera al grupo **lpadmin**::

      $ /usr/sbin/lpinfo -v

.. [#] Si se usa además la opción ``-l`` (antes, no después de ``-v``), no
   sólo se listarán los dispositivos, sino también la identificación y
   características del mismo (la misma información que obtiene la detección por
   interfaz web y que le permite mostrar no sólo la conexión, sino también de
   qué modelo de impresora se trata)::

      # lpinfo -l -v

.. [#] La :kbd:`-E` debe situarse **después** de la opción :kbd:`-p`, no antes;
   y podría, además, haberse usado en la orden de instalación anterior.
   También podríamos hacer::

      # cupsenable PDFVirtual
      # cupsaccept PDFVirtual

.. [#] ... o no. Véase :ref:`qué pasa con lpoptions <impr-predeterminada>`.

.. [#] De hecho, si probáramos a pasarle el código |HTML|::

   $ wget -qO - http://www.google.es | lp

   lo que obtendríamos es la impresión del código fuente.

.. [#] El fichero a imprimir se almacena en :file:`/var/spool/cups/` y su nombre
   completo se almacena en la variable *TEADATAFILE*. Hay otra variable
   llamada *TEAINPUTFILE* que contiene el nombre del fichero original, pero
   no en todos los drivers está disponible.

.. |CUPS| replace:: :abbr:`CUPS (Common Unix Printing System)`
.. |HTML| replace:: :abbr:`HTML (HyperText Markup Language)`
.. |PDF| replace:: :abbr:`PDF (Portable Document Format)`
.. |PPD| replace:: :abbr:`PPD (PostScript Printer Description)`
.. |PCL| replace:: :abbr:`PCL (Printer Command Language)`
.. |PDL| replace:: :abbr:`PDL (Printer Description Language)`
.. |PJL| replace:: :abbr:`PJL (Printer Job Language)`
