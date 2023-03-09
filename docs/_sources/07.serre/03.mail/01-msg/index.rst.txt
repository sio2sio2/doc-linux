.. _mensaje-correo:

El mensaje de correo
********************
El contenido del epígrafe describe cuál es la estructura de los mensajes de
correo, ya que el conocimiento de ésta es necesario para la implementación de
filtros en el servidor |SMTP|.

Los mensajes de correo son siempre archivos de texto plano constituidos siempre
por caracteres |ASCII| puros (7 *bits*). Para permitir el uso de otros caracteres
y de adjuntos binarios (fotos, etc.) se creó |MIME|\ [#]_.

Estructura básica
=================
Entendemos por ella la de los mensajes que carecen de archivos adjuntos. En este
caso, en el correo se distinguen dos partes:

#. La **cabecera** (*header* en inglés), constituida por un conjunto de campos
   con la forma::
   
      Nombre: Valor

#. El *cuerpo* de texto (*body* en inglés), que incluye el mensaje que desea
   enviar el emisor al remitente.

Para separar ambas partes, simplemente, se deja una línea en blanco. Un ejemplo
de mensaje es el siguiente:

.. literalinclude:: files/mensaje.txt
   :language: none

Cabecera
--------
Como se puede ver la cabecera es una simple sucesión de campos sin un orden
fijo. Por ejemplo::

   To: paco@mail2.org

es el campo que identifica al destinatario (**To**) del correo. La forma de
escribir la línea es siempre la misma:

* No está sangrada.
* El nombre del campo seguido por dos puntos y un espacio.
* El valor del campo.
* Si la línea es demasiado larga, se puede trocear en varias (véanse, por ejemplo,
  los campos **Received**), pero en este caso, los trozos sí están sangrados
  para que jamás puedan ser considerados un campo independiente.

Los campos pueden ser incluidos en el mensaje por:

* El *cliente de correo* al componer el mensaje. Por ejemplo,
  **Subject** o **From** o **To**.
* Cualquier *servidor de correo* por el que transita o acaba el mensaje. Por ejemplo,
  cada vez que el correo llega a un servidor |SMTP|, se añade un campo
  **Received** que registra su paso por el servidor. 

Todos los campos no está definidos en la norma. Hay campos que sí lo están y
tienen una finalidad predefinida; otros, en cambio, no y los clientes y
servidores pueden añadirlos a voluntad asignándole el significado que consideren
oportuno. En estos el nombre suele empezar por la letra **X-**, aunque no es
obligatorio. En el primer grupo de campos está **Subject** que identifica el
asunto del mensaje; en el segundo grupo. **X-Spam-Flag**, que es una cabecera
que añade el filtro :ref:`spamassassin <spamassassin>` para identificar los
mensajes cuyo contenido ha analizado.

Entre los campos predefinidos, estos son los más importantes:

**From**
   Identifica al remitente del mensaje. La forma más simple es incluir solamente
   la cuenta destinataria del mensaje::

      From: paco@hotmail.com

   Pero también puede añadirse el nombre real del siguiente modo::

      From: Francisco Murillo <paco@hotmail.com>

**Return-Path**
   Cabecera añadida por el servidor para incorporar al remitente del sobre, que
   es distinto al incluido en el campo ``From:``.

   .. seealso:: Échele un ojo a la :ref:`definición de los dos remitentes que
      tiene los mensajes de correo <smtp-acreditacion>`.

**Subject**
   Asunto del mensaje.

**To**
   Identifica al destinatario o destinatarios del correo. Si se indican varios,
   se deben separar por comas. Cada uno de ellos puede expresarse de forma
   simple (sólo la cuenta) o incluyendo el nombre real::

      To: Marta Cabrales <marta@gmail.com>, pepe@telefonica.net

**Delivered-To**
   Usuario final en cuyo buzón se entrega el correo. Podría no coincidir con la
   dirección del campo ``To:`` si esta era una :ref:`cuenta virtual
   <postfix-cue-virt>`.

**Cc**
   Copia de carbón: identifica a los destinatarios secundarios del correo. El
   valor se expresa del mismo modo que en el campo anterior.

**Bcc**
   Copia de carbón oculta: identifica a los destinatarios ocultos del correo.
   La diferencia con el campo anterior es que este campo es eliminado por el
   servidor al transmitir el mensaje, con lo que el resto de destinatarios no
   saben de la existencia de estas copias ocultas.

**Date**
   Fecha y hora de emisión del correo.

**Reply-To**
   Incluye la dirección a la que el destinatario del mensaje debería responder,
   cuando se quiere que lo haga a una dirección distinta a la del emisor.

**Message-ID**
   Identificador único del mensaje.

**In-Reply-To**
   Los mensajes de respuesta contienen este campo para identificar cuál es el
   mensaje al que responde. Su valor es el identificador del mensaje al que
   responder (véase el campo anterior).

**Content-Type**
   Describe de qué tipo es el cuerpo del texto. Lo habitual en un mensaje sin
   adjuntos es que el valor sea::

      Content-Type: text/plain; charset="utf-8"

   es decir, un cuerpo de texto plano codificado en UTF-8 para que pueda
   contener caracteres no ingleses. Volveremos a tratar este campo al tratar la
   estructura con adjuntos.

   .. _tipo-MIME:

   .. note:: El modo en que se expresa el tipo se incluye en el ya citado
      estándar |MIME|, por lo que a esta forma de expresar el tipo se le
      denomina :dfn:`tipo MIME` del archivo. En este caso :kbd:`text/plain` es
      el tipo |MIME| para identificar a los archivos planos de texto. Como el uso
      de tipos |MIME| se ha extendido a otros muchos ámbitos ajenos al servicio
      de correo electrónico, en los sistemas *Linux*\ [#]_, el archivo
      :file:`/etc/mime.types` relaciona los tipos |MIME| más conocidos con las
      extensiones a los que se asocian (p.e.  :kbd:`text/plain` se asocia a la
      extensión :kbd:`.txt`).

   .. note:: En el valor de este campo puede incluirse, además, un subtipo,
      como es el caso del ejemplo en que el subtipo :kbd:`charset="utf-8"`
      expresa que la codificación del texto plano.

**Content-Transfer-Encoding**
   Define cómo se representarán los datos. Consúltese `este documento
   <https://www.w3.org/Protocols/rfc1341/5_Content-Transfer-Encoding.html>`_
   para conocerlo mejor.

**Received**
   Informa de los servidores por los que ha pasado el correo. A diferencia de
   los campos anteriores, sí puede aparecer repetidamente, ya que cada correo
   incluirá un campo para declararse.

Cuerpo
------
Las normas de netiqueta (:rfc:`1855`) suponen que el cuerpo de un
mensaje se escribe siempre en texto plano y, de hecho, dan algunas reglas para su
escritura (\_texto subrayada\_, \*texto resaltado\*, 65 caracteres por línea,
etc.). Con la aparición de clientes gráficos e interfaces web comenzaron a
aparecer cuerpos de otro tipo (``text/rtf`` y sobre todo ``text/html``), lo cual
se ve declarado en el campo **Content-Type** de la cabecera.

Estructura con adjuntos
=======================
Un mensaje con adjuntos tiene la misma estructura de un mensaje sin ellos con
una cabecera y un cuerpo. La argucia que se sigue para cuartear el cuerpo del
mensaje en varios trozos (el cuerpo de texto y los adjuntos) es incluir un
campo::

   Content-Type: multipart/mixed;
      boundary="_009_AM5P189MB053120881316F349597FB906AF580AM5P189MB0531EURP_"

que declara que el correo tiene varias partes y que incluye un identificador
para saber dónde empieza cada parte. De este modo, nada más acabar la cabecera,
y la línea en blanco separadora el cuerpo del mensaje se verá así::

   --_009_AM5P189MB053120881316F349597FB906AF580AM5P189MB0531EURP_
   Content-Type: text/plain; charset="utf-8"
   Content-ID: xxxxx
   Content-Transfer-Encoding: 8bit

   Bla que sea

   --_009_AM5P189MB053120881316F349597FB906AF580AM5P189MB0531EURP_
   Content-Type: image/jpeg; name="IMG_6780.JPG"
   Content-ID: yyyyy
   Content-Transfer-Encoding: base64
   Content-Description: IMG_6780.JPG
   ...

   IMAGEN CODIFICADA EN BASE64

Es decir cada parte del mensaje (la primera es el cuerpo del texto) se marca con
el identificador aparecido en el **Content-Type** de la cabecera y, además se
incluyen unas cuantos campos que definen cuál es el tipo particular de esa
parte. Acabados estos campos, se usa una línea en blanco para separar esta
*cabecera de parte* de los datos de dicha parte y a continuación se incluyen los
datos. La estructura se repite tantas veces como adjuntos haya.

.. _smtp-trans:

Transmisión
===========
Una sesion entre cliente y servidor para la transmisión del mensaje es la
siguiente:

.. code-block:: console
   :emphasize-lines: 8, 21, 23-26, 30-38, 40

   $ openssl s_client -connect smtp.mail1.org:smtp -starttls smtp -quiet
   depth=0 CN = mail.mail1.org
   verify error:num=18:self signed certificate
   verify return:1
   depth=0 CN = mail.mail1.org
   verify return:1
   250 SMTPUTF8
   EHLO localhost
   250-m1.mail1.org
   250-PIPELINING
   250-SIZE 10240000
   250-VRFY
   250-ETRN
   250-STARTTLS
   250-AUTH PLAIN LOGIN
   250-AUTH=PLAIN LOGIN
   250-ENHANCEDSTATUSCODES
   250-8BITMIME
   250-DSN
   250 SMTPUTF8
   AUTH PLAIN dXN1YXJpbwB1c3VhcmlvAHBhc3N3b3Jk
   235 2.7.0 Authentication successful
   MAIL FROM:<usuario@mail1.org>
   RCPT TO:<usuario@mail2.org>
   RCPT TO:<root@mail2.org>
   DATA
   250 2.1.0 OK
   250 2.1.0 OK
   250 2.1.0 OK
   354 End data with <CR><LF>.<CR><LF>
   Date: Sat, 10 Nov 2018 09:02:33 +0100
   From: usuario@mail1.org
   To: usuario@mail2.org
   Cc: root@mail2.org
   Subject: Un mensaje de prueba

   El cuerpo del mensaje...
   .
   250 2.0.0 OK: queued as 157293771
   QUIT
   221 2.0.0 Bye

Cuya explicación es la siguiente:

#. Primero se establece la conexión entre cliente y servidor.
#. La primera acción del cliente suele ser saludar identificándose con el
   comando ``EHLO``.
#. Al saludo, responde el servidor informado de algunas de sus
   características.
#. Si la conexión es autenticada, el cliente se autentica.
   En el ejemplo se usa la autenticación ``AUTH PLAIN`` que veremos más
   adelante.
#. Si la autenticación tiene éxito el cliente utiliza tres comandos:

   * ``MAIL FROM`` para informar de quién es el remitente.
   * ``RCPT TO`` para informar de quién es el destinatario. Si los
     destinatarios son varios, se repetirá varias veces este comando.
   * ``DATA`` para anunciar que desea remitir el mensaje.

   Lo habitual es que, si esta sesión la lleva a cabo un programa de correo, la
   información para los comandos ``MAIL FROM`` y ``RCPT TO`` se obtenga de las
   cabeceras del mensaje que ya ha escrito el usuario. Por ejemplo, los
   destinatarios se obtienen de las cabeceras **To**, **Cc** y **Bcc**. Tras el
   comando ``DATA`` el servidor comprobará que acepta los comandos ``MAIL FROM``
   y ``RCPT TO`` suministrados y, de ser así, se pasará a la siguiente fase:

#. El cliente escribe el mensaje: primero las cabeceras, después una línea en
   blanco y a continuación el cuerpo del mensaje. Para informar de que ha
   acabado por completo envía una última línea que contiene sól un punto. El
   servidor aceptará el mensaje (o podrá no aceptarlo si tiene definido algún
   filtro que analice los datos).
#. El cliente se despide con ``QUIT`` y acaba la comunicación.

.. warning:: Obsérvese que las cabeceras son datos y el servidor no las usa en
   ningún momento para decidir quién envía o recibe el mensaje. Que haya
   correlación entre esto y las cabeceras es responsabilidad exclusiva del
   cliente.

.. note:: Dado que la correlación no tiene por qué producirse, el servidor debe
   añadir al mensaje una cabecera **Return-Path** cuyo valor es el remitente
   incluido en ``MAIL FROM``, y una cabecera **Delivered-To**, que informa de a
   quién se entrega el mensaje.

.. rubric:: Notas al pie

.. [#] Puede consultar la `entrada de la Wikipedia
   <https://es.wikipedia.org/wiki/Multipurpose_Internet_Mail_Extensions>`_ para
   más información.

.. [#] O al menos en las distribuciones derivadas de *Debian*.

.. https://askubuntu.com/questions/16580/where-are-file-associations-stored

.. |MIME| replace:: :abbr:`MIME (Multipurpose Internet Mail Extensions)`
