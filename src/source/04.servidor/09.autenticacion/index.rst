.. _pam:

Autenticación
=============
La autenticación y, más en general, el ingreso de un usuario al sistema está
estandarizado en los sistemas *Linux* gracias a |PAM|. Es importante que
sea así, porque el acceso se puede lograr a través de distintos servicios y
esto facilita que cada servicio no tenga que implementar el mecanismo de acceso,
sino simplemente pasar las credenciales a |PAM| y que este se encargue de
decidir si el usuario debe tener o no acceso.

Como es probable que distintos servicios establezcan distintas políticas de
acceso, |PAM| permite particularizar la configuración según el servicio.

.. warning:: La configuración de la autenticación es bastante delicada, por
   cuanto una mala configuración puede dejarnos sin acceso al sistema. Si se
   piensan hacer modificaciones, quizás convenga instalar :deb:`pamtester`
   que permite comprobar el funcionamiento de la configuración hecha. Por
   ejemplo::

      # pamtester -v login usuario authenticate

   comprueba cómo funciona la autenticación del usuario "usuario" en el servicio
   *login*.

Estructura
----------
La configuración de |PAM|, pues, consiste en definir cuáles son operaciones
que deberá ejecutar cada servicio que requiere autenticación. Para ello puede
usarse un único fichero :file:`/etc/pam.conf`, o una colección contenida en el
directorio :file:`/etc/pam.d`. Si existe este segundo directorio, que es lo
habitual, no se analiza el primer fichero; así que explicaremos este segundo
método de configuración.

Si echamos un vistazo al contenido de :file:`/etc/pam.d` nos toparemos algo
así::

   $ ls /etc/pam.d
   atd             common-auth                    login     runuser-l
   chfn            common-password                newusers  sshd
   chpasswd        common-session                 other     su
   chsh            common-session-noninteractive  passwd    systemd-user
   common-account  cron                           runuser

Se pueden distintiguir tres clases de ficheros:

* Los ficheros :file:`common-*`, que contienen directivas que suelen usarse
  como base para la autenticación en la mayoría de los servicios (véase
  :ref:`pam-auth-update <pam-auth-update>` más adelante). Esto es
  posible debido a que para incluir las directivas de un fichero en otro
  existe la directiva :code:`@include`). 

* Una serie de ficheros que representan distintos programas que requieren
  autenticación (en el listado antes indicado :file:`passwd`, :file:`sshd` o
  :file:`su`, por ejemplo). Los programas usarán su fichero correspondiente
  en caso de que exista.

* El fichero :file:`other` usado por los programas a los que no se les ha
  creado fichero particular.

Funcionamiento
--------------
|PAM| distingue entre cuatro tipo de tareas:

**Autenticación** (``auth``)
   Determina si las credenciales proporcionadas (habitualmente un nombre y una
   contraseña) pertenecen a un usuario existente y son válidas.

**Cuenta** (``account``)
   Determina si el usuario cuya identidad se ha ya comprobado, tiene permiso
   para acceder a la máquina o no (por una limitación horaria, porque no
   pertenezca al grupo adecuado, etc.)

**Password** (``password``)
   Relacionado con la modificación de la contraseña de usuario.

**Sesión** (``session``)
   Tareas que deben realizarse antes de que el usuario abre la sesión o después
   de que la cierre (por ejemplo, crear un directorio personal, montar sistemas
   de ficheros remotos etc.)

Una aplicación que utilice |PAM| puede requerir la realización de uno o varios
tipos de estas tareas. Cada tipo de tarea se divide en módulos, cada uno de los
cuales se encarga de realizar algo. Como se ejecutan secuencialmente según el
orden en el que aparecen en la configuración, todos los módulos de un mismo
tipo, forman una *pila* y devuelven un resultado de éxito o error que contribuye
al resultado global de la pila. Cuando |PAM| devuelve éxito para todas las pilas
que la aplicación ha requerido, ésta permitirá el ingreso del usuario.

Sintaxis
--------
Los ficheros de configuración de |PAM| contienen líneas de tres tipos:

#. Líneas de comentario, que son aquellas que comienzan con almohadilla.
#. Líneas que permiten incluir las directivas de otros ficheros::

      @include common-auth

   donde :file:`common-auth` es el fichero del que se desean incluir las
   directivas.

#. Líneas de directiva, que son aquellas que definen la ejecución de un
    y que requieren una explicación detallada::

      <tipo> <control> <modulo> [<opciones>]

   Las líneas de directiva se evalúan en el orden en que se leen y sus
   componentes son los siguientes:

   **Tipo**
     El tipo de módulo del que ya se discutió bajo el epígrafe anterior. Por
     tanto, define la pila en la que se ejecuta el módulo.

   **Control**
      Determina cómo contribuye el resultado de la ejecución del módulo
      al resultado global de la pila.
      directiva y cómo influirá esto en el proceso global de autenticación.
      Hay cuatro indicadores básicos de control:

      ``required``
         Exige que tenga éxito la directiva, pero no interrumpe la ejecución
         de la pila de módulos.

      ``requisite``
         Como ``required``, pero interrumpe la ejecución de la pila
         provocando un error.

      ``sufficient``
         Su éxito es suficiente, así que interrumpe la ejecución de la pila
         devolviendo éxito.

      ``optional``
         El éxito o fracaso no influye en el resultado de la pila.

      Alternativamente a estos términos, se puede utilizar una sucesión
      de parejas resultado/acción, que permiten un control más preciso. Los
      resultados son muy variados:

      ======================= ====================================================================
      Parámetro               Significado
      ======================= ====================================================================
      abort                   Error crítico.           
      acct_expired            La cuenta de usuario ha expirado.
      auth_err                Fallo en la autenticación.
      authinfo_unavail        No puede accederse a la información de autenticación.
      authtok_disable_aging   Authentication token aging disabled.
      authtok_err             Error en la manipulación del token de autenticación.
      authtok_expired         Token de autenticación caducado.
      authtok_lock_busy       Ocupado el bloqueo del token de autenticación.
      authtok_recover_err     No puede recuperarse la información de autenticación.
      bad_item                Item incorrecto.
      buf_err                 Error en el *buffer* de memoria.
      conv_again              Conversation function is event driven and data is not available yet.
      conv_err                Error en la conversación.
      cred_err                Error al fijar las credenciales de usuario.
      cred_expired            Credenciales de usuario caducadas.
      cred_insufficient       Sin acceso a los datos de autenticación por falta de credenciales.
      cred_unavail            Credenciales de usuario no disponibles.
      default                 Cualquier valor no mencionado implícitamente.
      ignore                  No considerar el módulo.
      incomplete              Reiniciar el módulo para que se complete.
      maxtries                Máximo número de intentos.
      module_unknown          El módulo no existe o no se conoce.
      new_authtok_reqd        Se requiere un nuevo token de autenticación.
      no_module_data          Módulo sin datos.
      open_err                El módulo no debe cargarse.
      perm_denied             Permiso denegado.
      service_err             Error de servicio en el módulo.
      session_err             Error de sesión.
      success                 Acaba con éxito
      symbol_err              Símbolo no encontrado.
      system_err              Error de sistema.
      try_again               Preliminary check by password service.
      user_unknown            Usuario desconocido.
      ======================= ====================================================================

      Los valores que pueden adoptar estos resultados son los siguientes:

      ======= ====================================================================
      Valor   Significado
      ======= ====================================================================
      ignore   El resultado del módulo no afecta al resultado global del proceso.
      bad      El resultado supone fallo del módulo.
      die      Como el anterior, pero no se siguen comprobando módulos.
      ok       El módulo acaba con éxito.
      done     Se acaba con éxito y no se siguen comprobando más módulos.
      reset    Se resetea el resultado global del proceso de autenticación.
      N        Número de directivas siguientes que se saltarán.
      ======= ====================================================================

      Los indicadores básicos de control equivalen a lo siguiente:

      * ``required``: :code:`[success=ok new_authtok_reqd=ok ignore=ignore default=bad]`
      * ``requisite``: :code:`[success=ok new_authtok_reqd=ok ignore=ignore default=die]`
      * ``sufficiente``: :code:`[success=done new_authtok_reqd=done default=ignore]`
      * ``optional``: :code:`[success=ok new_authtok_reqd=ok default=ignore]`

      Obsérvese que los valores se ajustan a la definición que se ha dado de
      los indicadores. Por ejemplo, un módulo con el indicador ``requisite``
      acaba inmediatamente la ejecución de la pila. Esto es debido a que el
      valor predeterminado es *die*.

      En el caso de que se use como valor un número, este indicará el número
      e directivas de |PAM| que se saltarán. Es importante tener en cuenta
      que no se verá afectado el resultado de la línea: si acabó con éxito la
      línea contribuirá al resultado global de la autenticación con un éxito;
      y, si acabó con fracasó, contribuirá con un frcaso. Este valor es
      bastante útil cuando tenemos varias fuentes para la obtención de las
      credenciales. Por ejemplo, un servicio :abbr:`LDAP (Lightweight
      Directory Access Protocol)` y los ficheros locales ya vistos
      (:file:`/etc/passwd`, etc.). Como es obvio que para que el usuario sea
      válido sólo debe estar en una de las fuentes, podemos encontrarnos con
      configuraciones como la que sigue::

         auth     [success=2 default=ignore]    pam_unix.so nullok_secure
         auth     [success=1 default=ignore]    pam_ldap.so use_first_pass minimum_uid=1000 debug
         auth     requisite            pam_deny.so
         auth     required          pam_permit.so

      O sea, si el usuario es local y la autenticación ha tenido éxito, se
      saltan las dos siguientes directivas y se ejecuta la cuarta, que
      incluye un módulo que, simplemente, tiene siempre éxito. Si falla, en
      cambio, nos descuidamos del fallo (:code:`default=ignore`) y se analiza
      si el usuario está definido en la base *ldap* y sus credenciales son
      correctas. SI es así, saltamos una directiva, con lo que acabaremos en
      el módulo *promiscuo* que siempre permite acceso. Por contra, si falla,
      desatendemos el error (:code:`default=ignore`), pero caemos en la
      siguiente directiva, que siempre falla y, además, está como *requisite*,
      con lo que la autenticación fallará inmediatamente.

   **Módulo**
      Módulo que se usa en la directiva. |PAM| está constituido por un
      conjunto de módulos, cada uno de los cuales se encarga de un aspecto
      distinto. Por ejemplo, :file:`pam_unix.so` es el módulo que se
      encarga de hacer comprobaciones usando la información de
      :file:`/etc/passwd` y :file:`/etc/shadow`.

      Bajo el epígrafe siguiente describiremos el uso de los más habituales.

   **Opciones**
      Opciones con las que se ejecuta el módulo. Por ejemplo
      :file:`pam_unix.so` no permite acceder al servicio si el usuario tiene
      una contraseña vacía. Sin embargo, si se incluye la opcion
      :kbd:`nullok`, sí podrá.

.. _pam-auth-update:

.. warning:: A pesar de que la configuración consiste en escribir apropiadamente
   las líneas para que el proceso de autenticación sea el adecuado, las
   distribuciones derivadas de *Debian* tienen un :index:`programa
   <pam-auth-update>` llamado :program:`pam-auth-update` que permite mediante
   menú generar automáticamente las líneas de los ficheros :file:`common-*`. De
   esta forma, la instalación de servicios que aportan usuarios y grupos al
   sistema (como :ref:`samba <samba>` u :ref:`openldap <openldap>`).  es
   bastante sencilla\ [#]_. Por ello, es conveniente no modificar los archivos
   :file:`common-*`, por cuanto se regeneran con :command:`pam-auth-update`. Por lo
   general, añadir alguna directiva al final es posible sin que
   :command:`pam-auth-update` plantee problemas. Ahora bien, si lo que se desea
   es modificar argumentos de líneas que genera la utilidad, entonces es
   conveniente modificar los ficheros de los perfiles de
   :command:`pam-auth-update` (en :file:`/usr/share/pam-configs`).

Módulos
-------
Hay muchos módulos para |PAM|. Bajo este epígrafe sólo se comentarán los más
habituales y se explicarán brevemente algunos de sus argumentos. Suelen tener
página de manual, así que es recomendable consultarla.


.. toctree::
   :glob:
   :maxdepth: 1

   pam_modules/[0-9]*

Política de contraseñas
-----------------------
.. seealso:: Consulte los :ref:`criterios para establecer las contraseñas
   <politica-contraseñas>`.

Ejemplo ilustrativo
-------------------

El mejor método para entender cómo actúa |PAM| es tomar algunos de sus ficheros
de configuración reales y analizarlos.

Empecemos con los ficheros *comunes*:

.. literalinclude:: docs/common-auth.txt
.. literalinclude:: docs/common-password.txt
.. literalinclude:: docs/common-account.txt
.. literalinclude:: docs/common-session.txt

Los ficheros los genera automáticamente :ref:`pam-auth-update
<pam-auth-update>`, de ahí que sean algo más complicados de lo que podrían ser.
Los grupos *auth* y *password* tienen una estructura que hace que se prueben
sucesivamente distintos mecanismos de manera que si se tiene éxito se salta al
módulo *pam_permit* y si no se tiene se prueba con el siguiente. El fallo de
todos ellos hace que se acabe entrando en *pam_deny*, que malogra la
autenticación.

Por su parte, :file:`/etc/pam.d/sshd` tiene este contenido:

.. literalinclude:: docs/sshd.txt

.. _nsswitch:

.. _nss:

NSS
---

El servicio :abbr:`NSS (Name Service Switch)` es una herramienta que permite
resolver nombres (de usuarios, de grupos, de máquinas, etc.) a través de
distintos mecanismos. Por ejemplo, en un sistema básico, gracias a este servicio
se obtiene la información sobre usuarios y grupos de los ficheros
:file:`/etc/passwd`, :file:`/etc/group` y :file:`/etc/shadow`. También gracias a
él se resuelven los nombres de máquinas acudiendo primero a :file:`/etc/hosts` y
a continuación a un servidor *dns*, si esta disponible. De hecho, el comando
:ref:`getent <getent>` usa este servicio para devolver sus resultados::

   $ getent passwd usuario
   usuario:x:1000:1000:Usuario pedestre,,,:/home/usuario:/bin/bash
   $ getent hosts choquereta
   127.0.1.1       minilleta.domus minilleta choquereta.domus choquereta
   $ getent hosts www.iescdl.es
   80.32.8.158     www.iescdl.es

No forma parte en absoluto de |PAM| ni de la autenticación, pero está ligado
en la medida en que permite resolver cualquier nombre del sistema. De no
existir, el sistema sería incapaz de saber quiénes somos una vez dentro.

Su configuración se hace a través del fichero :file:`/etc/nsswitch.conf` que
tiene este aspecto:

.. literalinclude:: docs/nsswitch.conf.txt
   :language: none

Obsérvese que se declaran los *objetos* (a la izquierda) y de dónde se obtendrá
su información (a la derecha). Para el caso de los usuarios (*passwd*, *group*,
etc.) la fuente son únicamente los ficheros locales\ [#]_, pero esta fuente no
tiene por qué ser única. Este es un sistema básico, pero incluso en un sistema
básico la resolución de nombres de máquinas tiene una doble fuente: el fichero
:`/etc/hosts` y el servicio *dns*. Por ese motivo, vemos la línea::

   hosts:          files dns

El orden es importante. En este caso se mirará primero en los ficheros (o sea,
en :file:`/etc/hosts`) y si no existe en ellos, se pasará a intentar resolver a
través del servicio *dns*.

.. pam-auth-update
   http://www.nexolinux.com/autenticacion-pam-en-linux-elevando-la-seguridad/
   http://www.makeinstall.es/2011/07/que-es-pluggable-authentication-modules.html
   http://www.rjsystems.nl/en/2100-pam-debian.php

.. rubric:: Notas al pie

.. [#] Para la configuración :command:`pam-auth-update` usa *perfiles* que se
   activan o desactivan a través del menú. Estos perfiles configuran distintos
   aspectos de la configuración. Por ejemplo, la *autenticación unix* o la
   *autenticación con LDAP* son perfiles distintos, de manera que si activamos
   ambos, usaremos ambas fuentes para obtener usuarios válidos. La definición de
   los perfiles se realiza a través de sendos ficheros contenidos en
   :file:`/usr/share/pam-configs`.

.. [#] La razón de que diga :code:`compat` y no :code:`files` es la *compat*\
   ilibidad con una sintaxis particular de los ficheros :file:`/etc/passwd`,
   etc. que permite añadir a los usuarios y grupos locales los definidos a
   través de un servidor `NIS
   <https://es.wikipedia.org/wiki/Network_Information_Service>`_.  Sin embargo,
   esto mismo se puede lograr con :code:`files nis` sin necesidad de tal sintaxis
   y, además, este servidor ha caído en desuso ante soluciones como *LDAP* o *samba*.
