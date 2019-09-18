.. _mutt:

:command:`mutt` (|MUA|)
***********************
.. warning:: El epígrafe desarrolla la configuración del :program:`mutt`,
   lo cual sólo tiene interés si se pretende usar el programa como |MUA|. Si no
   es así, puede saltarse la lectura, ya que no añade gran cosa al conocimiento
   general de cómo funciona el envío y recepción del correo.

.. note:: El epígrafe no es un tutorial de uso, sino la descripción de cómo
   ordenar una configuración compleja. Además, se explica cómo configurar
   :command:`mutt` para que sea capaz de :ref:`firmar con el certificado digital
   <mutt-fnmt>` de la |FNMT|.

El |MUA| para la interfaz de línea de comandos más ampliamente utilizado es
`el programa mutt <http://www.mutt.org>`_. Es muy configurable, cumple muy
satisfactoriamente su labor y además:

* Desde la versión *1.5* incluye un |MSA| interno lo que evita el uso de uno
  externo como el :ref:`servidor local <postfix-msa>` o un |MSA| puro
  como :ref:`msmtp <msmtp>`.
* Soporta la gestión de buzones |IMAP| remotos, pero no descarga mensajes, esto
  es, no incluye un |MRA|.
  
Traeremos aquí (y comentaremos) una configuración que permite:

* Hacer modular la configuración, de manera que cada aspecto se almacene
  en un lugar distinto.

* Gestionar buzones locales, cuyos mensajes se han obtenido a través de un
  |MRA|; y buzones remotos.

* Al arrancar :command:`mutt` gestionaremos los buzones locales y tendremos
  la posibilidad de acceder a la gestión de los buzones remotos.

Configuración base
==================
Mutt dispone de un fichero de configuración general (:file:`/etc/Muttrc`)\ [#]_
y un fichero de configuración particular para cada usuario en :file:`~/-muttrc`.
Si se configura de forma monolítica, este último fichero puede llegar a ser un
monstruo intratable, por lo que nos reduciremos a incluir en él este contenido::

   # Por defecto, gestionamos el correo descargado.
   source ~/.mutt/servers/local.rc

   # Configuración modular.
   source 'cat ~/.mutt/rc.d/*.rc|'

Al hacerlo nuestra intención es la siguiente:

* La configuración, dividida en distintos aspectos, se encontrará dentro del
  subdirectorio :file:`~/.mutt/rc.d`

* Dado que gestionaremos el correo descargado en los buzones locales y, además,
  distintas cuentas remotas directamente en los buzones de sus respectivos
  servidores, crearemos otros subdirectorio llamado :file:`~/.mutt/servers`
  dentro del cual habrá un fichero que configure cada cuenta. La configuración
  para los buzones locales la trataremos como si de otra cuenta se tratara y le
  reservamos el nombre :file:`local.rc`. El resto de ficheros, como desarrollan
  la configuración de una cuenta, contendrán contraseñas, por lo que es
  indispensable evitar que terceros puedan leerlos::

      $ chmod 700 ~/.mutt/servers

* Dentro de :file:`~/.mutt` se encontrará el resto de ficheros relacionados con
  :command:`mutt` (:file:`mailcap`, :file:`aliases`, etc.). Ya se irán tratando.

* El certificado para la firma digital se encuentra dentro de :file:`~/.smime`.

Por lo pronto, :download:`ésta es la configuración modular propuesta
<files/mutt.tar.xz>`, sobre la que pueden ir haciendo recortes y adiciones al
gusto.

Módulos de configuración
========================
Hemos decidido dividir la configuración en diferentes ficheros situados dentro
del directorio :file:`~/.mutt/rc.d`. Cómo se haga esta división puede ser muy
discutible. La mía la he dividido del siguiente modo:

General (:file:`general.rc`)
----------------------------
Contiene la configuración más general sobre el comportamiento de
:command:`mutt`.

Cabeceras (:file:`headers.rc`)
------------------------------
Determina cómo se presentan las cabeceras al ver y editar los mensajes.

Aspecto (:file:`style.rc`)
--------------------------
Controla fundamentemente los colores de la interfaz de mutt. Más o menos, están
configurados para que sean aquellos que presenta el lector de *news* `slrn
<http://slrn.sourceforge.net/>`_.

Macros (:file:`macros.rc`)
--------------------------
Hace algunas redefiniciones de teclas útiles.

Edición (:file:`edition.rc`)
----------------------------
Establece valor para algunas directivas que controlan la edición de mensajes
(p.e. cuál será el editor que usemos\ [#]_). También está definido dentro de él
cómo se genera la firma, no la digital, sino la firma con la que se cierra el
mensaje.

Para esto último se usa un *script* (`~/.mutt/signature/signature.sh`) que
genera una firma aleatoria gracias al programa :command:`fortune`. Éste, por su
parte, las escoge de las citas incluidas dentro del directorio
:file:`~/.mutt/signature/citas`. Dentro de él pueden incluirse varios ficheros
que contengan citas una debajo de otra separadas por el signo "*%*"::

   %
   La juventud es un defecto que se cura con el tiempo
                      --- Enrique Jardiel Poncela ---
   %
   Harto sabe, si me sabe bien.
                     --- Francisco de Quevedo ---

Los ficheros, no obstante, no pueden usarse directamente, sino que se requiere
generar ficheros de índice para acceder a las citas más rápidamente. Para
generarlos, suponiendo que tengamos un fichero llamado :file:`miscitas`::

   $ strfile -c % ~/.mutt/signature/citas/miscitas{,.dat}

Adjuntos (:file:`view_attachment.rc`)
-------------------------------------
Define dos aspectos:

* Cuáles son los adjuntos que se mostrarán directamente al ver el mensaje. Para
  ver los restantes habrá que pulsar "*v*" y seleccionar verlos ("*Enter*") o
  descargarlos ("*s*").

* :file:`mailcap` que es el fichero que asocia las forma en que puede mostrarse
  el contenido de los adjuntos.

Lista de direcciones (:file:`alias.rc`)
---------------------------------------
Define cuál es el fichero que se usará para almacenar las direcciones conocidas
(en nuestro caso, :file:`~/.mutt/aliases`). Las direcciones pueden añadirse
editando directamente el fichero o pulsando "*a*" para añadir la dirección del
remitente del mensaje que se muestra.

Listas de distribución (:file:`lists.rc`)
-----------------------------------------
Es interante tratar los mensajes a listas de forma especial y asignarles un
buzón por lista. La configuración permite gestionarlas de forma cómoda.

.. _mutt-fnmt:

Firma digital (:file:`smime.rc`)
--------------------------------
Fundamentalmente define cómo firmar los correos electrónicos. Lo habitual es usar
`gpg <https://www.gnupg.org/>`_, aunque nosotros usaremos el certificado
expedido por la |FNMT|. Por tal motivo, como dispondremos de un solo certificado
y éste está asociado a una dirección de correo, sólo podremos firmar (y así
haremos) mensajes enviados desde una única dirección de correo.

La configuración del fichero, además, tiene una preparación del certificado que
es preciso explicar. En primer lugar, deberemos ser capaces de obtener nuestro
certificado digital en formato *pcks12*, muy posiblemente, exportándolo del
navegador en que lo tengamos instalado. Supongamos que lo guardamos con el
nombre :file:`micert.p12`.

La mayor dificultad de lograr habilitar el uso de este certificado es que desde
hace un tiempo la |FNMT|, no firma directamente los certificados personales de
usuario con un certificado raíz\ [#]_, sino que lo hace a través de un
certificado intermedio. En cualquier caso, sigamos el rastro y vayámoslo
descubriendo nosotros mismos. Para empezar vamos a cambiar el formato y a
separar el certificado público de la clave privada::

   $ openssl pkcs12 -in /tmp/micert.p12 -nocerts -out /tmp/micert.key
   $ openssl pkcs12 -in /tmp/micert.p12 -clcerts -nokeys -out /tmp/micert.pem

Hecho esto, podemos comprobar con qué certificado se ha firmado nuestro
certificado::

   $ openssl x509 -in /tmp/micert.pem -text -noout
   [...]
   X509v3 Authority Key Identifier:                   
       keyid:B1:D4:4F:C4:23:79:FA:44:05:09:C6:EB:39:CF:E8:35:B0:B8:20:64
                                                                                                                              
   Authority Information Access:
       OCSP - URI:http://ocspusu.cert.fnmt.es/ocspusu/OcspResponder
       CA Issuers - URI:http://www.cert.fnmt.es/certs/ACUSU.crt
   [...]

Ahí tenemos el identificador del certificado que se usó para firmar nuestro
certificado y, lo que es más cómodo, la dirección de la que descargárselo. Por
tanto::

   $ wget -q 'http://www.cert.fnmt.es/certs/ACUSU.crt'

Tal certificado no está en el formato que nos interesa, asi que traducimos::

   $ openssl x509 -in /tmp/ACUSU.crt -inform DER -outform PEM > /tmp/acusu.crt

Y si échamos un vistazo a este otro certificado, veremos que no es un
certificado raíz, sino que está firmado por otro certificado::

   $ openssl x509 -in /tmp/acusu.crt -text -noout
   [...]
   X509v3 Subject Key Identifier:                     
       B1:D4:4F:C4:23:79:FA:44:05:09:C6:EB:39:CF:E8:35:B0:B8:20:64
   Authority Information Access:                      
       OCSP - URI:http://ocspfnmtrcmca.cert.fnmt.es/ocspfnmtrcmca/OcspResponder
       CA Issuers - URI:http://www.cert.fnmt.es/certs/ACRAIZFNMTRCM.crt
   [...]

De modo que descargamos (y traducimos) este otro certificado::

   $ wget -q 'http://www.cert.fnmt.es/certs/ACRAIZFNMTRCM.crt'
   $ openssl x509 -in /tmp/ACRAIZFNMTRCM.crt -inform DER -outform PEM > /tmp/raiz.crt

Si echamos un vistazo a las propiedades del certificado veremos que este sí que
no está firmado por ningún otro (el propio nombre ya nos daba la pista).

Con la cuestión de los certificados averiguada, ya sólo es cuestión de añadirlos
a :command:`mutt` para lo cual hay primero que preparar el directorio :file:`~/.smime`::

   $ smime_keys init

y copiar el certificado raíz dentro\ [#]_::

   $ mv /tmp/raiz.crt ~/.smime/ca-bundle.crt

Por último, debemos añadir nuestro certificado, pero indicando el intermedio::

   $ smime_keys add_chain /tmp/micert.key /tmp/micert.pem /tmp/acusu.crt

   You may assign a label to this key, so you don't have to remember
   the key ID. This has to be _one_ word (no whitespaces).

   Enter label: micert_ceres
   ==> about to verify certificate of f8ecaf67.0

   /home/josem/.smime/certificates/f8ecaf67.0: OK


   certificate f8ecaf67.0 (micert_ceres) for mi_cuenta@gmail.com added.
   added private key: /home/usuario/.smime/keys/f8ecaf67.0 for mi_cuenta@gmail.com

.. note:: Con la configuración incluida en :file:`smime.rc`, se firmarán
   automáticamente los mensajes cuyo emisor sea la cuenta a la que hayamos asociado
   el certificado (en el ejemplo, *mi_cuenta@gmail.com*), excepto aquellos dirigidos
   a listas de distribución. No obstante, justamente antes de enviar el mensaje
   se podrá evitar o incorporar la firma pulsando "*C*".

Declaración de cuentas (:file:`servers.rc`)
-------------------------------------------
Ya se ha adelantado que se quiere usar :command:`mutt` para gestionar tanto
cuentas para las que se descargan sus mensajes como cuentas que lo gestionan
directamente a través de |IMAP|.

La estrategia que se sigue en este caso es la siguiente:

* Los buzones cuyo nombre empieza por punto son buzones locales.
* Los buzones cuyo nombre empieza por *.buzon.* son para cuentas |IMAP|. Cada
  una tendrá un buzón. Ahora bien, estos son sólo buzones auxiliares que no
  contienen mensajes en absoluto y de hecho hay definido un gancho para que al
  entrar en estos buzones :program:`mutt` se redirija directamente al buzón de
  entrada de cada cuenta.
* "*y*" lleva a un índice de buzones en que aparecen los buzones locales y los
  buzones auxiliares remotos.
* "*c*" lleva al índice de buzones asociado a esa cuenta.

El fichero enumera las cuentas, pero no desarrolla la configuración particular
de cada una. Para ello están los ficheros incluidos dentro de
:file:`.mutt/servers` que se describirán a continuación.

Configuración de cuentas
========================
Cada fichero contiene básicamente:

* Identidad y credenciales de la cuenta.
* Los buzones y qué papel desempeñan.
* Cómo se envían mensajes.
* En el caso de cuentas de buzones remotos, cuáles son los datos para la
  conexión |IMAP|. 

.. rubric:: Notas al pie

.. [#] Este fichero, a su vez, llama a los ficheros incluidos dentro del
   directorio :file:`/etc/Muttrc.d`.

.. [#] :program:`vim` como no podía ser de otra forma.

.. [#] Antes lo hacía con el certificado raíz *FNMT Clase 2 CA*.

.. [#] El nombre del directorio y del almacen de certificados acreditadores se
   define en :file:`/etc/Muttrc.d/smime.rc`

.. |MUA| replace:: :abbr:`MUA (Mail User Agent)`
.. |MSA| replace:: :abbr:`MSA (Mail Submission Agent)`
.. |MRA| replace:: :abbr:`MRA (Mail Retreival Agent)`
.. |FNMT| replace:: :abbr:`FNMT (Fábrica Nacional de Moneda y Timbre)`
