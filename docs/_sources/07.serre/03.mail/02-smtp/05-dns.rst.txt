.. _smtp-acreditacion:

Acreditación del remitente
**************************
En los mensajes de correo hay dos remitentes que pueden coincidir o no:

**Remitente del sobre** (*Envelope sender*)
   Es el remitente cuya dirección se declara durante el envío del correo a
   través del comando ``MAIL FROM``. Esta es la dirección a la que el servidor
   destinatario contestara en caso de que se haya producido un problema en la
   entrega. Por tanto, no forma parte del mensaje original, pero el servidor la
   añade a través del campo de cabecera ``Return-Path:``.

**Dirección del mensaje**
   Es la dirección que aparece en el campo de cabecera ``From:``. Por lo
   general, es tomada por el lector final del mensaje como la dirección del
   remitente, ya que el campo ``Return-Path:`` rara vez se muestra en los
   clientes de correo.

El protocolo de correo, por su propio diseño, se presta a que un malicioso
(frecuentemente un *spammer*) falsee cualquiera de las dos direcciones, port lo
que para detectar estas falsificaciones, se han desarrollado una serie de
protocolos que, si no los observamos en nuestro servidor, pueden levantar en
otros servidores la desconfianza sobre nuestros mensajes. 

.. _spf:

|SPF|
=====
Concepto
--------
Este protocolo, desarrollado en el :rfc:`7208`, permite al dueño de un dominio
definir cuáles son los servidores que utiliza para **enviar** mensajes de correo
de tal dominio\ [#]_. La información se publica a través de un registro |DNS|
que se describirá más adelante.

Con este protocolo, los servidores destinatarios comprueban si la |IP| del
servidor remitente es alguna de las acreditadas a través del registro |SPF|
correspondiente al dominio de la dirección del *remitente del sobre*.
Trasladando esta explicación a un ejemplo, podríamos ilustrarlo del siguiente
modo:

El dueño de la cuenta *pepe@gmail.com* usará los mecanismos que le
proporciona su proveedor de correo (|SMTP| o el *webmail* `gmail.google.com
<http://gmail.google.com>`_) para enviar un mensaje a *paco@example.com*.
Esto implica que sea una máquina de *Gmail* la que se encargue de entregar el
mensaje al servidor *smtp.example.com*. Éste, al recibir el mensaje,
registrará la |IP| de la máquina remitente y, como la dirección del sobre
es *pepe@gmail.com*, para certificar que realmente
tal |IP| es de una máquina de *Gmail*, realizará las siguientes consultas
|DNS|:

* ¿Quiénes son las máquinas que se encargan de enviar mensajes del dominio
  *gmail.com*?

  ::

   # dig +nocmd +noall +answer gmail.com TXT
   gmail.com.              176     IN      TXT     "v=spf1 redirect=_spf.google.com"

  Bien, la respuesta no es concluyente. El registro nos dice, simplemente,
  que lo que diga otro registro.

* Vale. Pues, ¿qué es lo que dice este registro?

  ::

   # dig +nocmd +noall +answer _spf.google.com TXT
   _spf.google.com.        299     IN      TXT     "v=spf1 include:_netblocks.google.com include:_netblocks2.google.com include:_netblocks3.google.com ~all"
   
  La respuesta sigue sin ser del todo concluyente. Nos informa de que las
  máquinas seran las incluidas en alguno de esos tres registros.

* Vale. Pues, ¿qué dicen esos registros?

  ::

   # dig +nocmd +noall +answer _netblocks.google.com TXT
   _netblocks.google.com.  2480    IN      TXT     "v=spf1 ip4:35.190.247.0/24 ip4:64.233.160.0/19 ...mas_ips... ~all"

Ahí sí están referidos todos los rangos de |IP| de máquinas autorizadas para
enviar mensajes del dominio *gmail.com*. La |IP| de la máquina que contactó
al servidor *smtp.example.net* debería estar incluida en uno de esos rangos.

.. seealso:: Esta misma averiguación podríamos haberla hecho más visualmente
   desde `este enlace <https://stopemailfraud.proofpoint.com/spf/>`_.

Hay, no obstante, que hacer dos puntualizaciones respecto a las consultas que
permiten acreditar el remitente. Por un lado, no pueden requerirse más de 10
consultas para la obtención de una respuesta. En este caso, han sido un máximo
de 5. Por otro lado, el texto de las respuestas no puede contener más de 255
caracteres y esa es la razón por la que los rangos de |IP| se han dividido en
tres registros distintos.

.. note:: Observe que esta técnica no previene ninguna suplantación de la
   *dirección del mensaje*.

Conocido cómo funciona el protocolo, ¿qué podemos hacer respecto a él con nuestro
servidor? Básicamente, dos cosas:

#. Asegurarnos de incluir en el |DNS| el registro |SPF| que acredita nuestro
   servidor como la máquina emisora de mensajes del dominio. De no existir tal
   información, podríamos levantar suspicacias en servidores destinatarios y
   acabar nuestros mensajes en el buzón de *spam*. Conviene que lea al completo
   todo el epígrafe siguiente, pero puede saltar :ref:`directamente a la propuesta
   de registro <postfix-dns-spf>`.

#. Incorporar a :program:`postfix` *software* que comprueb con |SPF|
   el remitente de los mensajes entrantes. :ref:`Más adelante <postfix-spf>`
   trataremos cómo hacerlo.

Registro
--------
Los registros de |SPF| no son un tipo especial de registro |DNS|, sino un tipo
*TXT* que incluye en la cadena información sobre la aceptación o rechazo::

   mail1.org      IN    TXT      "v=spf1 test1 test2 test3 ... testN"

El registro de ejemplo será consultado al recibir mensajes cuyo *remitente del
sobre* sea *pepe@mail1.org*, *usuario@mail1.org* o cualquier otra cuenta del
dominio *mail1.org*. La cadena comienza siempre por la definición de la versión
del protocolo usada (la versión 1) y una serie de pruebas que se realizan
utilizando la |IP| del remitente como entrada.

Cada prueba consta de:

* Un **cualificador** que puede ser:

  ============ ================================================================
  Cualificador   Significado
  ============ ================================================================
  \+             *PASS*, la concordancia devuelve éxito.
  ?              *NEUTRAL*, la concordancia no devuelve nada concluyente.
  ~              *SOFTFAIL*, la concordancia provoca su marcado como *spam*.
  \-             *FAIL*, la concordancia provoca que se rechace el correo.
  ============ ================================================================

  Cuando no se especifica cualificador, se sobreentiende "+".

* Un *mecanismo* que puede ser:

  ============ ================================================= ======================
  Mecanismo     Significado                                       Ejemplo
  ============ ================================================= ======================
   all          Concordancia universal                            -all
   a            Concordancia con el nombre especificado           a:smtp.mail1.org
   ip4          Concordancia con el rango de IPv4 indicado        ip4:33.34.35.36
   ip6          Ídem pero para IPv6
   mx           Concordancia con los servidores de correo         mx:mail1.org
   include      Concordancia con las pruebas de otro registro     include:otromail.org
  ============ ================================================= ======================

  Cuando con *a* o *mx* no se especifica nombre, se sobreentiende el mismo que
  el del dominio. En nuestro ejemplo, ``a`` equivale ``a:mail1.org`` y ``mx`` a
  ``mx:mail1.org``. Además, la última prueba implica siempre el mecanismo *all*,
  para que siempre haya una prueba que devuelva concordancia.

  .. note:: También existe, aunque obsoleto, el mecanismo ``ptr`` que concuerda
     si el nombre asociado a la |IP| del cliente (resolución inversa) está en el
     dominio proporcionado y tal nombre resuelve a la |IP| del cliente.

Además de lo anterior podemos usar el **modificador** *redirect* (véase el
ejemplo ilustrativo del epígrafe anterior) que remite a que se use la política
de otro registro.

Por ejemplo, si el registro es::

   mail1.org      IN    TXT      "v=spf1 ip4:123.12.0.0/16 mx include:_spf.google.com ~all"

Se obtendría *PASS* (éxito en la comprobación) si la |IP| del remitente es de la
red *126.12.0.0/16*, si coincide con la de alguno de los servidores de correo
definidos para el dominio *mail1.org* o si es una de las máquinas que remite
correo de *Google*. Si no es el caso, la última prueba supone que devolvemos
*SOFTFAIL* y el mensaje debería identificarse como posible *spam*. Nótese que
la segunda y la tercera prueba requieren consultas |DNS| ulteriores para llegar
a obtener una dirección |IP| numérica.

.. _postfix-dns-spf:

Para el caso de un servidor modesto como el nuestro, que envía y recibe
mensajes, es más que suficiente::

   mail1.org      IN       TXT      "v=spf1 mx ~all"

y si tuviéramos algún otro dominio asociado a este servidor::

   mail3.org      IN       TXT      "v=spf1 redirect=mail1.org"
   ml.mail1.org   IN       TXT      "v=spf1 redirect=mail1.org"

.. seealso:: En `kitterman.com <https://www.kitterman.com/spf/validate.html>`_,
   podemos hacer comprobaciones de registros |SPF|.

.. _postfix-spf:

Verificación
------------
.. note:: Como alternativa al método explicado aquí, podemos habilitar
   la verificación |SPF| del remitente tanto con :ref:`spamassassin
   <spamassassin>` como con :ref:`rspamd <rspamd>`.

Nuestra intención es incluir en la :ref:`política de aceptación de mensajes de
postfix <postfix-accept>` el mecanismo |SPF|, para lo cual debemos instalar::

   # apt install postfix-policyd-spf-python

.. warning:: La comprobación |SPF| requiere la realización de una ingente
   cantidad de consultas |DNS|, de modo que sería conveniente la instalación de
   un |DNS| en el propio servidor, si no hay ya uno instalado en la red local.

Hecho esto, debemos añadir a :file:`/etc/postfix/master.cf`::

   policyd-spf  unix  -       n       n       -       0       spawn
       user=policyd-spf argv=/usr/bin/policyd-spf

y añadir a :file:`/etc/postfix/main.cf` una línea para aumentar la temporización
del agente |SPF|:

.. code-block:: apache

   policyd-spf_time_limit = 3600

y dejar en las :ref:`políticas de acceso para el puerto 25 <postfix-25-465-587>`
lo siguiente:

.. code-block:: apache

   port25_recipient_restrictions = permit_mynetworks,
                                   reject_unauth_destination,
                                   check_policy_service unix:private/policyd-spf,
                                   reject_rbl_client zen.spamhaus.org

El agente genera para todos los mensajes procesados un campo de cabecera
``Received-SPF:`` con el resultado de la verificación.

.. note:: Si preferimos no rechazar los mensajes, aun cuando la verificación
   genera *FAIL*, podemos editar :file:`/etc/postfix-policyd-spf-python/policyd-spf.conf`
   y dejar:

   .. code-block:: apache 

      HELO_reject = False
      Mail_From_reject = False

Para comprobar la configuración, podemos utilizar :program:`msmtp` desde un
cliente local que se conecte al puerto **25**, para lo cual podemos
reaprovechar la :ref:`configuración anteriomente propuesta para este cliente
<postfix-25-465-587>` y añadir una línea para falsear la dirección del sobre:

.. code-block:: apache
   :emphasize-lines: 6

   [...]

   account vm25
      auth off
      tls_starttls on
      from spammer@gmail.com

El mensaje puede enviarse ahora::

   $ msmtp -a vm25 -t
   From: spammer@gmail.com
   To: usuario@mail1.org
   Subject: Mensaje fraudulento...
   
   Nos hacemos pasar por alguien con cuenta en Gmail

.. _dkim:

|DKIM|
======

Concepto
--------
El mecanismo de |DKIM|, descrito en el :rfc:`6376`, permite saber al servidor
destinatario que el mensaje proviniente de la *dirección del mensaje* fue
autorizado por el dueño del dominio al que pertenece dicha dirección. Para ello
el servidor |SMTP| remitente aplica :ref:`firma digital <firma-digital>` a los
mensajes que envía, la cual será verificada en el servidor de destino.

.. seealso:: Si no tiene claro el concepto, consulte la sección dedicada a la
   :ref:`firma digital <firma-digital>`. Ahora bien, en este caso la firma es
   absolutamente transparente para los usuarios finales y es sólo un mecanismo
   que aplican los servidores para juzgar la fiabilidad de los mensajes.

De manera muy resumida el proceso es el siguiente:

* Con anterioridad, el dueño del dominio debe publicar través de un registro
  |DNS| de tipo *TXT* la clave pública asociada a la clave privada con la que se
  firman los mensajes.

* El remitente añade un campo ``DKIM-Signature:`` con la firma digital. Para
  la creación de la firma se usan claves asociadas al dominio de la *dirección
  del mensaje*. El campo tiene el siguiente aspecto::

   DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=mail1.org; s=mail;
           t=1545467652; bh=s8zLfuQdHGkvCXnndlQQO/EjIoJDdA+FodZEaFvU2X4=;
           h=From:To:Subject:Date:From;
           b=NIpT52OFx8ty/0/krkt9MtJIN83TVNcoxWkcLtTWEBD1VOzlgHuTtcoJVOsKkBqbU
            YPC9sI4zwQ9mcL4Mr0yNXskXmeAJ6bVMJzgWkKgfkCO6V20Z5pjZ/OPFHV+T3x43US
            cpTYzpwRVtLepxpQ2SJv19KYXnXIGKqIA157GGBC16qc2lwhCGSUY/g6bkmc0b+WpI
            vh8daZPnmKSQqEIEkv3jBADsJ3KlSe/dz3vx1fCbK0azOu2AWNeEZ/mVjSgMLIGaoZ
            BvXY09OqM/v94A8hseGi5HUB0Bxz90bh0Y3U9W9TMk1/wORWmgY5NIAnu3H0PdZtnu
            Qy07Eat+80AeQ==

* El servidor receptor toma el campo anterior, obtiene a través de una consulta
  |DNS| la clave pública necesaria, y realiza la comprobación de la firma. El
  resultado se añade a un campo ``Authentication-Results`` con este aspecto::

      Authentication-Results: smtp.mail2.org;
              dkim=pass (2048-bit key; unprotected) header.d=mail1.org header.i=@mail1.org header.b="NIpT52OF";
              dkim-atps=neutral

.. nota:: Observe que en este caso la verificación obra sobre la *dirección del
   mensaje* y no sobre la dirección del *remitente del sobre*.

Implementación
--------------
Para implementar |DKIM| en el correo saliente con :program:`postfix`,
podemos usar el *milter* `OpenDKIM <http://opendkim.org/>`_::

   # apt install opendkim{,-tools}

La configuración en :file:`/etc/opendkim.conf` debe quedar del siguiente modo:

.. code-block:: apache

   Syslog               yes
   UMask                007

   Canonicalization     relaxed/simple

   # Socket dentro de la jaula de postfix.
   Socket               local:/var/spool/postfix/var/run/opendkim.sock
   PidFile              /var/run/opendkim/opendkim.pid

   OversignHeaders      From

   # Para habilitar DNSSEC
   #TrustAnchorFile       /usr/share/dns/root.key

   UserID               opendkim

   KeyTable             /etc/opendkim/keytable
   SigningTable         /etc/opendkim/signingtable

   # El software no respeta lo indicado en /etc/resolv.conf,
   # por lo que no usará un servidor local para las resoluciones.
   # Si hacemos pruebas internas con dominios inventados
   # es indispensable declarar el servidor DNS local.
   NameServers          127.0.0.1

.. seealso:: Puedo consultar que significa la normalización |DKIM|
   (*Canonicalizaion*) en `este artículo
   <https://wordtothewise.com/2016/12/dkim-canonicalization-or-why-microsoft-breaks-your-mail/>`_.

Dado que necesitamos poder escribir dentro de la jaula de :program:`postfix`,
debemos preparar en ella un subdirectorio :file:`var/run/` según lo :ref:`mostrado aquí
<postfix-aux>`.

Dado que *opendkim* necesita firmar, debemos generar las claves::

   # opendkim-genkey -D /etc/dkimkeys -r -s mail -d mail1.org
   # chown opendkim:opendkim /etc/dkimkeys/mail.*

Esta orden genera las claves para el dominio *mail1.org*, aunque dentro de la
propia clave no está expresado el propio dominio, con lo que podremos reusar la
misma clave en otros dominios que gestionemos. Además, está asociada al selector
*mail*, que es un nombre arbitraro. La existencia de selectores permite definir
varias claves asociadas a un mismo dominio. Por última, con la opción ``-r``
hemos restringido el uso de la clave a la firma del servicio de correo, y no
otros servicios.

Para terminar la configuración del servicio debemos crear los ficheros
:file:`/etc/opendkim/signingtable` y :file:`/etc/opendkim/keytable`. El primero
relaciona las direcciones de correo con el identificador de su clave
correspondiente::

   # mkdir /etc/opendkim
   # cat > /etc/opendkim/signingtable
   mail1.org          mail._domainkey.mail1.org

y el segundo al identificador con la clave en sí::

   # cat > /etc/opendkim/keytable
   mail._domainkey.mail1.org     mail1.org:mail:/etc/dkimkeys/mail.private

donde la parte derecha es "*dominio:selector:ruta*". Hecho esto, reiniciamos el
servicio::

   # invoke-rc.d opendkim restart

Ahora debemos añadir el registro |DNS| que publica la clave pública. Su
expresión se encuentra dentro de :file:`/etc/dkimkeys/mail.txt`::

   mail._domainkey IN      TXT     ( "v=DKIM1; h=sha256; k=rsa; s=email; "
             "p=MIIBI ... a+"
                       "g2B8aHwc3 ... DAQAB")  ; ----- DKIM key mail for mail1.org

.. note:: La adición dependerá de dónde la hagamos. En :program:`dnsmasq` bastaría con
   añadir una línea como esta::

      txt-record=mail._domainkey.mail1.org,"v=DKIM1; h=sha256; k=rsa; s=email; p=MIIBI ... ag2B8aHwc3 ... DAQAB+"

Convendría probar si somos capaces de resolver el registro y, por último,
comprobar si funciona la clave::

   # host -t txt mail._domainkey.mail1.org
   # opendkim-testkey -d mail1.org -s mail -vvv
   opendkim-testkey: using default configfile /etc/opendkim.conf
   opendkim-testkey: checking key 'mail._domainkey.mail1.org'
   opendkim-testkey: key not secure
   opendkim-testkey: key OK

.. warning:: Tenga presente que la comprobación de la clave no funcionará si
   :program:`opendkim` no es capaz de resolver el registro con la clave.

.. note:: Se indica que la clave no es segura porque no hay forma de verificarla
   con *DNSSEC*.

Completada la configuración de :program:`opendkim`, resta hacer que
:program:`postfix` haga uso de él, para lo cual habrá que añadir a
:file:`/etc/postfix/main.cf` unas líneas:

.. code-block:: apache

   # DKIM
   milter_default_action = accept
   smtpd_milters = unix:var/run/opendkim.sock
   non_smtpd_milters = unix:var/run/opendkim.sock

e incluir el usuario *postfix* dentro del grupo *opendkim* para que pueda leer
en el *socket*::

   # adduser postfix opendkim

Con esta configuración, el servidor de correo se encargará de firmar los
mensajes que envíe, añadiendo un campo ``DKIM-Signature:`` a la cabecera del
correo; y verificará los mensajes entrantes que hayan sido firmados por
servidores de otros dominios, añadiendo un campo ``Authentication-Results`` que
incorpore el resultado.

.. _dmarc:

|DMARC|
=======
Concepto
--------
|SPF| incide en la verificación del remitente del sobre y |DKIM| en la dirección
del mensaje. Ambas verificaciones son independientes y provocan resultados
independientes. |DMARC| es un mecanismo que analiza los resultados de ambos
métodos y se encarga de dos tareas:

#. En función del resultado, tomar la decisión de aceptar, poner en cuarentena
   y rechazar el mensaje.

#. Enviar informes a los responsables de los dominios que han implementado
   |DMARC| de las falsificaciones que hayan llegado al servidor procedentes de
   sus dominios.

.. seealso:: La `página oficial de DMARC <https://dmarc.org/>`_ tiene una
   `introducción sobre DMARC <https://dmarc.org/overview/>`_ bastante
   elocuente.

Registro
--------
|DMARC| también exige la publicación de un registro |DNS| que informa al
servidor destinatario de:

* Qué debe hacer con los mensajes que fallan la verificación. Obviamente, el
  hecho de que el dueño del dominio indique a se acepten mensajes, no implica
  que los servidores destinatarios deban aceptarlo sin más. Lo más probable es
  que implementen ulteriores filtros de *spam* que puntúen negatiamente el
  resultado fallido de la comprobación y que en consecuencia, enviando los
  mensajes a los buzones de *spam* de los usuarios.

* Cuál es la dirección a la que deben remitirse los informes.

Los registros tienes este aspecto::

   _dmarc.mail1.org     IN    TXT   "v=DMARC1; campo1=valor1; ...; campoN=valorN"

El primer campo ``v`` identifica la versión y junto a ``p`` es el único
obligatorio. Alguno de los campos restantes son:

========== ======================================================= ==================================
Campo       Significado                                             Ejemplo
========== ======================================================= ==================================
``p``       Política a seguir (*none*, *quarantine*, *reject*).     ``p=none``
``rua``     |URI| a la que remitir los informes agregados.          ``rua=mailto:dmarc\@mail1.org``
``ruf``     |URI| a la que remitir informes individualizados        ``ruf=mailto:forense\@mail1.org``
``pct``     Porcentaje de mensajes al que aplicar |DMARC|.\ [#]_    ``pct=50``         
``aspf``    Alineamiento |SPF|. Por defecto, ``r``.                 ``aspf=s``
``adkim``   Alineamiento |DKIM|. Por defecto, ``r``.                ``adkim=s``
========== ======================================================= ==================================

Los alineamientos que refiere la tabla relacionan la dirección que autentica el
mecanismo con la dirección que no autentica (recordemos que hay dos direcciones
que definen el origen del mensaje). El :dfn:`alineamiento SPF` obliga a que el
dominio de la *dirección del mensaje* coincida del la del *remitente del sobre*,
si es estricto (``s``), o a que sea al menos un subdominio, si es relajado
(``r``). Por su parte el :dfn:`alineamiento DKIM` obliga a que el dominio de la
dirección del *remitente del sobre* coincida con el de la *dirección del
mensaje*, si es estricto (``s``); o a que al menos sea un subdominio, si es
relajado (``r``).

.. seealso:: Para una descripción detallada del registro visite la `descripción
   de zytrax.com <http://www.zytrax.com/books/dns/ch9/dmarc.html>`_.

Un posible registro podría ser el siguiente::

   _dmarc.mail1.org        IN    TXT      "v=DMARC1; p=none; rua=mailto:dmarc@mail1.org"

aunque deberíamos hacer que los mensajes dirigidos a la cuenta acabaran en el
buzón de algún usuario real.

Implementación
--------------
Es obvio que la implementación exige necesariamente que se hayan implementdo
previamente :ref:`SPF <spf>` y :ref:`DKIM <dkim>`. Una vez completado lo
anterior podemos::

   # apt install opendmarc

En el fichero de configuración podemos modificar algunas líneas:

.. code-block:: apache

   AuthservID smtp.mail1.org
   #RejectFailures true
   Socket local:/var/spool/postfix/var/run/opendmarc.sock

La directiva ``RejectFailures``, puesta a *true*, tiene el efecto de rechazar
los mensajes cuya comprobación falla y cuya política |DMARC| del dominio
prescribe que se rechacen (``p=reject``). Si está comentada o puesta a *false*,
los mensajes jamás se rechazarán, aunque la política lo prescriba.

Por último, toca configurar *postfix* para que lo ejecute como *milter*, tras
:program:`opendkim`:

.. code-block:: apache

   milter_default_action = accept
   smtpd_milters = unix:var/run/opendkim.sock, unix:var/run/opendmarc.sock
   non_smtpd_milters = unix:var/run/opendkim.sock, unix:var/run/opendmarc.sock

Además, deberemos añadir el usuario *postfix* al grupo *opendmarc* para poder
leer y escribir en el socket::

   # adduser postfix opendmarc

.. rubric:: Comprobación

Podemos hacer una prueba configurando en un servidor de correo (*mail1.org*)
|SPF|, |DKIM| y |DMARC| por entero; y para otro (*mail2.org*) definiendo
únicamente los registros |SPF| y |DMARC| en el |DNS|. Hecho esto, podemos probar
a enviar desde una tercera máquina un correo en que el remitente sea
aparentemente un usuario del servidor *mail2.org*. La comprobación |SPF| debería
fallar y, en consecuencia, |DMARC| también. Si configuramos que la politica para
*mail2.org* fuera de rechazo y ``RejectFailures`` a *true*, el servidor debería
rechazar el mensaje.

.. rubric:: Notas al pie

.. [#] Obsérvese que los registros ``MX`` definen los servidores encargados de
   **recibir** mensajes para ese dominio.

.. [#] Por defecto, se aplica a todos.

.. |SPF| replace:: :abbr:`SPF (Sender Policy Framework)`
.. |DKIM| replace:: :abbr:`DKIM (Domain Keys Identified Mail)`
.. |DMARC| replace:: :abbr:`DMARC (Domain Message Authentication Reporting & Conformance)`
.. |URI| replace:: :abbr:`URI (Uniform Resource Identifier)`
