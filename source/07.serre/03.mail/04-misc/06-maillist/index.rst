.. _mlmmj:

Listas de correo
================
Una :dfn:`lista de correo` (también :dfn:`lista de distribución`) es un uso
particular del correo electrónico que permite la distribución de mensajes
electrónicos a varios destinatarios a la vez, llamados :dfn:`suscriptores`. Con
ella, cualquier mensaje enviado a la dirección de la lista es dirigido a todas
las direcciones de los suscriptores de la misma. Es, pues, un buen método para
crear foros de debate junto a:

- Los foros *web*.
- Los `grupos de noticias <https://es.wikipedia.org/wiki/Grupo_de_noticias>`_,
  en franco declive desde hace más de una década.

De manera muy resumida una *lista de distribución* ofrece:

* Una dirección de correo (la dirección de la lista) a la cual se envían los
  mensajes que se quiere distribuir a través de ella. Lo habitual es que los
  suscriptores vean en los mensajes la dirección real del remitente.

* Una serie de direcciones asociadas que permiten realizar tareas
  relacionadas con la propia lista: suscripción, desuscripción, pedir ayuda
  sobre el funcionamiento, etc.

* Más o menos libertad para el envío de mensajes: en algunos listas sólo pueden
  enviar mensajes los suscriptores, otras está moderadas y sólo distribuyen
  mensajes tras la aprobación del moderador, etc.

* Tres modos de participación a los que puede optar cada suscriptor:

  + aquel en que todo mensaje es enviado individualmente al suscriptor.
  + aquel en que el suscriptor recibe un solo mensaje que contiene todos los
    mensajes remitidos a la lista en un determinado periodo; modo que suele
    denominarse *modo digest*.
  + aquel en que no se remite mensaje alguno. Por lo general, se habilita algún
    mecanismo adicional de consulta (una página web, por ejemplo) y se espera
    que el suscriptor recurra a él.

* Opcionalmente, un modo de consultar el archivo histórico de mensajes enviados.
  Esto suele hacerse a través de una interfaz web.

En nuestro caso, trataremos la instalación del gestor de listas `mlmmj (Mailing
List Management Made Joyful) <http://mlmmj.org/>`_, que, aunque no es el
software más extendido\ [#]_, no requiere excesivas dependecias (básicamente un
|SMTP| y la librería básica de **C**) y lo usa `la propia Gentoo para dar
soporte a sus usuarios
<https://www.gentoo.org/get-involved/mailing-lists/instructions.html>`_.

Dirección de la lista
---------------------
Antes de empezar la instalación es importante dejar sentado cuáles serán las
direcciones de las listas que gestionaremos\ [#]_. Obviamente, para que el
mensaje llegue a nuestro |SMTP|, la dirección de la cuenta debe pertenecer al
dominio (o dominios, si son varios) que gestione éste. Tenemos tres
posibilidades:

#. Dedicar un dominio exclusivo e independiente para la lista, por ejemplo,
   *nombrelista@mislistas.org*.
#. Dedicar un subdominio exclusivo para la lista que es, básicamente, el mismo
   caso que el anterior, pero sin gastar dinero en contratar un dominio extra.
   Por ejemplo: *nombrelista@ml.mail1.org*.
#. Usar el mismo dominio que dedicamos a cuentas de usuario y reservar ciertas
   direcciones como direcciones de lista. Lo más apropiado en este caso es que
   los nombres de las direcciones de las cuentas sigan un determinado patrón.
   Por ejemplo: *ml-nombrelista@mail1.org*.

Emtre el primero y el segundo caso no hay diferencia alguna de implementación, y
es ciertamente lo conveniente. El tercer caso sólo deberíamos implementarlo si
no tuviéramos posibilidad de crear subdominios en nuestro dominio propio\ [#]_ o
careciéramos de dinero para contratar uno exclusivo.

En realidad, una única lista tiene distintas direcciones de correo:

* *test@ml.mail1.org*, a la que se envían mensajes.
* *test+subscribe@ml.mail1.org*, a la que se envían peticiones de suscripción.
* *test+desubscribe@ml.mail1.org*, a la que se envían las peticiones de baja.
* *test+help@ml.mail1.org*, a la que se piden las |FAQ| de la lista.
* etc.

Para distinguirlas se añade una palabra detrás del signo "+" y, como este signo
suele utilizarlo el servidor de correo como delimitador:

.. code-block:: apache

   recipient_delimiter = +

todas las direcciones está asociadas a la misma cuenta.

Instalación
-----------
Como disponemos de paquete en *debian*::

   # apt install mlmmj

Añadiremos, además, un usuario exclusivo para el programa que no crea
automáticamente la instalación::

   # adduser --system --ingroup nogroup mlmmj

Integración en :program:`postfix`
---------------------------------
Debemos añadir el gestor de listas como un *transporte*, para lo cual
añadiremos al final de :file:`/etc/postfix/main.cf`::

   mlmmj   unix  -       n       n       -       -       pipe
      flags=ORhu user=mlmmj argv=/usr/bin/mlmmj-receive -F -L /var/spool/mlmmj/$nexthop

El último paso es hacer que los correos dirigidos a la lista usen este
transporte. La configuración diferirá ligeramente dependiendo de si hemos
separado las listas en un dominio aparte o no.

.. note:: Debemos confirmar que no hemos cambiado la configuración
   predeterminada::

      # postconf | grep -E '^(recipient_delimiter|propagate_unmatched_extensions)'
      recipient_delimiter = +
      propagate_unmatched_extensions = canonical, virtual

Dominio **separado**
   Basta con añadir el dominio a los dominios virtuales y aplicarle el
   transporte, para lo cual editamos :file:`/etc/postfix/main.cf`:

   .. code-block:: apache

      mlmmj_destination_recipient_limit = 1
      virtual_mailbox_domains = ml.mail1.org
      transport_maps = hash:/etc/postfix/tb/mlmmj-transport
      # Para que se rechacen mensajes a @ml.mail1.org no dirigidos a las listas
      virtual_mailbox_maps = hash:/etc/postfix/tb/mlmm-transport

   donde :file:`/etc/postfix/tb/mlmmj-transport` quedará ahora mismo vacío hasta
   que creemos alguna lista::

      # touch /etc/postfix/tb/mlmmj-transport

   La última directiva tiene la utilidad de hacer que :program:`postfix`
   rechace en la propia comunicación |SMTP| mensajes a cuentas del subdominio
   *ml.mail1.org* que no sean las de las listas de distribución.

En el **mismo** dominio
   Procuraremos que todas las direcciones tengan la forma
   *ml-nombrelista@mail1.org*, aunque no es obligatorio. La configuración es
   esta, suponiendo que *mail1.org* esté incluido en mydestination_:

   .. code-block:: apache

      local_recipient_maps = proxy:unix:passwd.byname $alias_maps hash:/etc/postfix/tb/mlmmj-transport
      mlmmj_destination_recipient_limit = 1
      transport_maps = hash:/etc/postfix/tb/mlmmj-transport
   
   es decir, hemos añadido las direcciones de las listas a local_recipient_maps_
   para que :program:`postfix` no considere que estas direcciones no existen y
   ahora deberíamos definirlas en :file:`/etc/postfix/tb/mlmmj-transport` junto
   al transporte que usará cada una. Por ahora dejaremos vacío el fichero::

      # touch /etc/postfix/tb/mlmmj-transport
      # postmap /etc/postfix/tb/mlmmj-transport

   a la espera de irlo llenando según vayamos creando las listas.

.. note:: Puede usarse en vez de transport_maps_ la directiva
   mailbox_transport_maps_, pero en ese caso las direcciones de la columna
   izquierda en :file:`/etc/postfix/tb/mlmmj-transport` (vea en el siguiente
   epígrafe cómo es su contenido) no podrán contener el dominio, ya que en las
   :ref:`tablas alias <postfix-aliases>` es así. Eso supone que si gestionamos
   varios dominios todas las cuentas con nombre "ml-\*" estarán asociadas a las
   listas con independencia del dominio que se añada a tal nombre, lo cual puede
   interesar o no.

.. seealso:: Tanto `este artículo de blog
   <http://blog.tremily.us/posts/mlmmj/>`_ como el `README oficial de mlmmj
   sobre postfix <http://mlmmj.org/docs/readme-postfix/>`_ exponen una
   configuración alternativa basada en el uso de un dominio virtual interno.

Creación de listas
------------------
Preparado :program:`postfix`, sólo queda definir la lista (o listas) que
gestionará :program:`mlmmj`. Suponiendo que nuestra primera lista se llame
*test*, podemos ejecutar::

        # mlmmj-make-ml -L test -c mlmmj

que creará una lista de tal nombre en el directorio
:file:`/var/spool/mlmmj/test` y hará propietario de ésta al usuario mlmmj.

.. warning:: Tenga en cuenta que, si usa el mismo dominio para definir listas y
   usuarios y ha seguido el consejo de nombrar a las listas con el prefijo
   *ml-*, la dirección de la lista será *ml-test@mail1.org* y no
   *test@mail1.org*. Como la orden anterior sólo nos pregunta cuál es el
   dominio, presupondrá que la dirección es *test@mail1.org* y esa es la que
   escribirá en :file:`/var/spool/mlmmj/test/control/listaddress`. Deberemos, a
   mano, cambiar este valor.

Además es necesario añadir la lista a la tabla de transporte
:file:`/etc/postfix/tb/mlmmj-transport`\ [#]_::

   # cat >> /etc/postfix/tb/mlmmj-transport
   test@ml.mail1.org          mlmmj:test
   # postmap /etc/postfix/tb/mlmmj-transport

o bien, si no usamos un dominio exclusivo::

   # cat >> /etc/postfix/tb/mlmmj-transport
   ml-test@mail1.org         mlmmj:test
   # postmap /etc/postfix/tb/mlmmj-transport

.. note:: En este segundo caso, si la definición del transporte la hicimos con
   mailbox_transport_maps_, deberemos eliminar la expresión del dominio::

      # cat >> /etc/postfix/tb/mlmmj-transport
      ml-test         mlmmj:test
      # postmap /etc/postfix/tb/mlmmj-transport

Configuración mínima
--------------------
En puridad, ya está montada la lista, aunque es posible que nos resulte
conveniente modificar su configuración predeterminada ya que, en principio, es
de suscripción libre, no tiene moderados sus mensajes ni moderadores, etc. La
configuración puede modificarse añadiendo ficheros dentro del subdirectorio
:file:`control/` del directorio que define la lista, y se describe en `la página
al respecto de la documentación de mlmmj <http://mlmmj.org/docs/tunables/>`_.
Una configuración adecuada puede ser la siguiente:

#. Que la lista añada al asunto de todos los mensajes enviados a ella un prefijo
   identificativo::

      # echo "[Test] " >> /var/spool/mlmmj/test/control/prefix

#. Que se elimine la cabecera *Reply-To* del mensaje original, puesto que las
   replicas deberían enviarse a la propia lista::

      # cat > /var/spool/mlmmj/test/control/delheaders
      Reply-To:

#. Que se añada automáticamente un campo *List-Id* que identifica la lista::

      # echo "List-Id: test.ml.mail1.org" > /var/spool/mlmmj/test/control/customheaders

#. Que se añada un pie a todos los mensajes enviados a la lista para que los
   destinatarios conozcan cómo pueden darse de baja, etc::

      # cat > /var/spool/mlmmj/test/control/footer
      -- 
      Para saber cómo usar la lista (darse de baja, pedir mensajes
      anteriores, etc) envíe un mensaje a test+help@ml.mail1.org

#. Que el remitente del mensaje, no reciba una copia de su propio mensaje::

      # touch /var/spool/mlmmj/test/control/notmetoo

#. Que solo puedan escribir a la lista, los suscritos a ella::

      # touch /var/spool/mlmmj/test/control/subonlypost

#. Definir quién es el propietario (o propietarios) de la lista. La creación de
   la lista ya debería haber preguntado por ello y esto no ser necesario::

      # echo 'listadmin-test@mail1.org' >> /var/spool/mlmmj/test/control/owner

   Esta dirección es a la que se remiten los mensajes enviados a
   *test+owner@ml.mail1.org*. Obviamente, tiene que ser una dirección válida
   (p.e. la cuenta virtual de algún usuario).

Gestión
-------
Creada una lista, hay tres formas de gestionarla:

#. A través de la **línea de comandos**, podemos dar de alta o baja usuarios.
   Por ejemplo, esto suscribe a un usuario a la lista::

      # /usr/bin/mlmmj-sub -L /var/spool/mlmmj/test -a interesado@yahoo.es

   .. note:: Se suscribe al usuario a la modalidad en que se recibe
      individualmente cada mensaje enviado a la lista. Para suscribirlo en modo
      *digest*, hay una opción, pero primero sería conveniente que definiera cuál
      es el intervalo de envío y el número máximo de mensajes por envío a través
      de la `configuración con el subdirectorio control/
      <http://mlmmj.org/docs/tunables/>`_.

#. A través de **mensajes a la propia lista**. En este caso, lo más sencillo es
   enviar un mensaje a la dirección *test+help@ml.mail1.org*, que nos informará
   de qué es lo que se puede hacer y qué direcciones se pueden usar para cada
   tarea.

#. A través de una simplicísima **interfaz web**, que puede instalarse con dos
   paquetes:

   * *mlmmj-php-web*, que permite cursar suscripciones y bajas a través de una
     interfaz web.
   * *mlmmj-php-web-admin*, que sirve para administrar la lista via web de forma
     alternativa a lo que se logra creando y borrando ficheros del subdirectorio
     :file:`control/`.

Consulta del histórico
----------------------
En las listas de distribución es extremadamente útil poder consultar el archivo
de los mensajes para repasar antiguas discusiones. Por ello, se almacenan todos
y cada mensaje tiene un identificador númerico consecutivo (**1** para el primer
mensaje enviado, **2** paa el segundo y así sucesivamente). Mediante este
identificador es posible obtener el mensaje enviado un correo a la lista
(*test+get-N@mail1.org*), pero este modo de consulta es impracticable. Lo más
cómodo es acceder al archivo a través de una interfaz web, pero desgraciadamente
:program:`mlmmj` no desarrolla ninguna. Hay, no obstante, alguna interfaz de
terceros como `mlmmj-webarchiver
<https://git.cryptomilk.org/projects/mlmmj-webarchiver.git>`_ que, aunque
bastante deficiente, puede ayudarnos a salir del paso.

En el enlace facilitado puede descargarse el código fuente\ [#]_, aunque hemos
preparado un :download:`paquete deb <files/mlmmj-webarchiver_0.2-0_amd64.deb>`
para facilitar la instalación. Basta, pues, con::

   # dpkg -i mlmmj-webarchiver_0.2-0_amd64.deb
   # apt-get install -f

Para que el archivo de la lista sea accesible vía web es necesario crear un
nuevo fichero bajo :file:`control/` que indique cuál es el directorio raíz del
sitio::

   # echo "/srv/www/mlmmj" > /var/spool/mlmmj/test/control/webarchive

.. note:: El archivo de la lista se almacenará bajo :file:`/srv/www/mlmmj/test`,
   ya que el sitio web está pensado para que se puedan acceder a archivos de
   varias listas distintas. Por tanto, todas las listas que queramos incluir
   en esta interfaz tendrán el mismo contenido para su
   :file:`control/webarchive`.

El funcionamiento del pequeño programa es simple: periódicamente un *script*
escrito en :program:`bash` regenera los mensajes ofrecidos por la interfaz web
tomándolos de los mensajes almacenados por :program:`mlmmj` dentro de
:file:`/var/spool/mlmmj`. El paquete ofrecido programa la ejecución de este
*script* con :ref:`cron <cron>` cada hora, pero si queremos que nuestra
instalación tenga efectos inmediatos, deberemos ejecutarlo nosotros a mano::

   # /usr/bin/mlmmj-webarchiver.sh

.. warning:: Asegúrese de que :file:`/srv/www/mlmmj` **no** existe antes de que
   lo ejecute el *script* por primera vez.

Por supuesto, es también necesario configurar un servidor web. Una configuración
mínima de :ref:`nginx <n-ginx>` a este efecto es la siguiente:

.. literalinclude:: files/nginx.conf
   :language: nginx

.. seealso:: Para más información, consulte :ref:`cómo configurar nginx para
   ejecutar código PHP <nginx-php>`.

.. rubric:: Notas al pie

.. [#] En el mundo del software libre es `mailman
   <http://www.gnu.org/software/mailman/>`_

.. [#] Un gestor, obviamente, permite gestionar múltiples listas de correo.

.. [#] Lo cual no debería ocurrir.

.. [#] Para ventilarnos con una unica línea todas las listas que pudiéramos
   crear, el fichero nos está pidiendo que usemos una expresión regular:

   .. code-block:: none

      /^(.+)@ml.mail1.org$/       mlmmj:$1

   pero el uso de sustituciones en la parte derecha de la tabla está vetado por
   razones de seguridad.

.. [#] Si prueba a instalar directamente el código fuente tenga presenta que el
   script :file:`mlmmj-webarchiver.sh` requiere :program:`bash`, pero su línea
   de *sheebang* cita :program:`sh`.

.. |FAQ| replace:: :abbr:`FAQ (Frequently Answered Questions)`
.. _transport_maps: http://www.postfix.org/postconf.5.html#transport_maps
.. _mailbox_transport_maps: http://www.postfix.org/postconf.5.html#mailbox_transport_maps
.. _mydestination: http://www.postfix.org/postconf.5.html#mydestination
.. _local_recipient_maps: http://www.postfix.org/postconf.5.html#local_recipient_maps
