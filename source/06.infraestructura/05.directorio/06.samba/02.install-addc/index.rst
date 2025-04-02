.. _smb-addc:

Controlador de dominio
======================

Bajo este epígrafe recogeremos todas las acciones que permiten convertir nuestro
servidor en un *controlador de dominio para directorio activo* y las pruebas que
nos asegurarán que lo es.

El *directorio activo* exige |DNS|. *samba* proporciona un servidor |DNS|
interno que puede usarse para ello. Otra opción, si ya se dispone de servidor
DNS, es usar *bind9* y hacer que éste use la base de datos de *samba*.

.. warning:: Para el directorio activo es indistinto el uso de mayúsculas y
   minúsculas. Así pues, «*Administrator*», «*administrator*» o
   «*ADMINISTRATOR*» son el mismo usuario.

Instalación
-----------

Son necesarios tres paquetes y opcionalmente otros dos::

   # apt-get install samba winbind sssd smbclient krb5-user acl

Desglosadamente:

**samba**
   Es el paquete que permite instalar el servidor en el sistema.

**winbind**
   Necesario para poder autenticarse usando la base de datos de samba.

**sssd**
   Permite que los usuarios y grupos de samba pueden usarse para la autenticación
   (*libpam-sss*) y en el servicio *nss* configurado con :ref:`/etc/nsswitch.conf
   <nsswitch>` (*libnss-sss*). Además, permite guarda una caché, lo que permite
   que el usuario pueda validarse incluso cuando se halle caído el servidor.
   
**smbclient**
   Es un cliente de línea de comandos para *samba*. No es necesario, pero puede
   ayudarnos en las comprobaciones.

**krb5-user**
   Contiene una serie de programas que permite ser clientes de un servidor
   *kerberos*. Como en el caso anterior, no es necesario, pero nos permite
   realizar comprobaciones.

**acl**
   Las herramientas para manejar los permisos basados en |ACL|. Son útiles si se
   crean a mano los perfiles de los usuarios.

.. note:: Es importar estar atento a los mensajes del proceso de
   *post-instalación*::

      Samba is not being run as an AD Domain Controller, masking samba-ad-dc-service.
  
   La configuración predeterminada no es la de un
   *controlador de dominio para directorio activo*, sino la de un servidor
   *samba* *independiente* (*standalone*). Esto hace que se habiliten los servicios
   *smbd* y *nmbd*; y se deshabilite (y enmascare) *samba-ad-dc*, que es el que
   nos interesa.

.. note:: La instalación de *krb5-config* (dependencia de *krb5-user*) nos
   obliga a configurar el cliente *kerberos*. No tiene demasiada importancia lo
   que respondamos, ya que la configuración de *samba* nos proporcionará el
   fichero de configuración adecuado.

Configuración
-------------

Trataremos bajo este epígrafe como transformar el servidor *samba* en un
controlador de dominio para directorio activo. La instalación presupone que lo
utilizaremos como servidor independiente, así que debemos desechar los
*scripts* de arranque habilitados::

   # invoke-rc.d smbd stop
   # invoke-rc.d winbind stop
   # invoke-rc.d nmbd stop
   # systemctl mask smbd
   # systemctl mask nmbd
   # systemctl mask winbind

Además, debemos deshacernos del fichero de configuración antiguo para no tener
problemas al generar la nueva configuración::

   # mv /etc/samba/smb.conf{,.dpkg-dist}

Como servidor |DNS| cabe la posibilidad de usar el básico que facilita *samba* o
usar *bind9*.

**Con DNS interno**
   El primer paso es constituir la base de datos (un *LDAP* interno)::

      # samba-tool domain provision  --host-ip=192.168.255.1 --use-rfc2307 --interactive
      Realm [IESPJM.DOMUS]:
       Domain [IESPJM]:
       Server Role (dc, member, standalone) [dc]:
       DNS backend (SAMBA_INTERNAL, BIND9_FLATFILE, BIND9_DLZ, NONE) [SAMBA_INTERNAL]:
       DNS forwarder IP address (write 'none' to disable forwarding) [80.58.61.250]:
      Administrator password:
      Retype password:
      [...]
      Server Role:           active directory domain controller
      Hostname:              dc
      NetBIOS Domain:        IESPJM
      DNS Domain:            iespjm.domus
      DOMAIN SID:            S-1-5-21-967385316-1535922226-3155704407

   ..  Existe la opción --use-xattrs=yes para almacenar las ntacls en el sistema
      de ficheros: probar su uso.

   Como ya hemos preparado el servidor, basta con aceptar todas las opciones.
   Obsérvese que se ha elegido como servidor |DNS| el interno. Esta elección
   conlleva que se nos pregunte el *forwarder* que usará tal servidor interno
   para resolver las direcciones que no sean del dominio propio. Se sugiere el
   servidor que se esté usando, con lo que debería bastar con aceptarlo. Nótese
   que se ha incluido la *IP* por la que queremos prestar el servicio y a cuya
   red queremos asociar el dominio, ya que en nuestro sistema hay dos ips
   distintas.

   .. warning:: No vale cualquier contraseña. *samba* tiene habilitadas unas
      reglas para evitar contraseñas demasiado sencillas. Para estas pruebas se
      ha introducido «:kbd:`Passw0rd`» (la letra *o* se susutituye por el
      dígito *0*), que la acepta sin problemas.

**Con bind9**
   Si queremos usar *bind* es obvio que lo debemos tener instalado ya (véase
   :ref:`cómo <dns>`) y elegir :kbd:`BIND9_DLZ` al generar la configuración.
   Además, a la instalación estándar de *bind* habría que hacer simplemente
   dos cambios:
  
   #. Incluir en el bloque :code:`options` de
      file:`/etc/bind/named.conf.options` la línea::

         tkey-gssapi-keytab "/var/lib/samba/private/dns.keytab";

   #. Incluir en :file:`/etc/bind9/named.conf` la línea::

         include "/var/lib/samba/private/named.conf";

   Ambas ficheros deben poder ser leídos por *bind*, pero en ambos casos es así.

   .. warning:: Con *bin9* no se debe generar configuración para la zona
      **iespjm.domus**, ya que de ello se encargar el propio samba.

Utilicemos *bind9* o el servidor interno\ [#]_, toca tras la configuración, echar a
andar el servidor, pero antes añadiremos a la sección :code:`[global]` de
:file:`/etc/samba/smb.conf` la siguiente directiva, que permite usar las
herramientas del paquete *ldap-tools* para hacer consultas::

   ldap server require strong auth = No

Hecho lo cual, sí podemos reiniciar (y habilitar de paso el servicio para que
arranque automáticamente durante el inicio)::

   # systemctl unmask samba-ad-dc.service
   # systemctl enable samba-ad-dc.service
   # invoke-rc.d samba-ad-dc start
   # wbinfo -D iespjm.domus
   Name              : IESPJM
   Alt_Name          : iespjm.domus
   SID               : S-1-5-21-967385316-1535922226-3155704407
   Active Directory  : Yes
   Native            : Yes
   Primary           : Yes


Y, ahora que ya tenemos servidor |DNS|, modificar :file:`/etc/resolv.conf` para
que sea la propia máquina el servidor de nombres::

   domain iespjm.domus
   search iespjm.domus
   nameserver 127.0.0.1

Además, *samba* ha generado una configuración para el cliente *kerberos*
apropiada, que debemos usar::

   # ln -sf /var/lib/samba/private/krb5.conf /etc

Debemos tocar, además, rematar la configuración del servidor de hora y
descomentar la línea que dejamos comentada::

   ntpsigndsocket /var/lib/samba/ntp_signd

Hecho esto, es necesario cambiar el grupo propietario de
:file:`/var/lib/samba/ntp_signd` para que el demonio pueda leer el *socket*::

   # chgrp ntp /var/lib/samba/ntp_signd

Y reiniciar el servicio::

   # invoke-rc.d ntp restart

Finalmente, silo deseamos podemos añadir la zona para la resolución inversa al
servidor |DNS| interno, aunque *samba* no actualiza esta zona como sí hace con
la directa::

   $ samba-tool dns zonecreate localhost 255.168.192.in-addr.arpa -U Administrator
   Zone 1.168.192.in-addr.arpa created successfully

En principio, todo debería marchar, pero conviene cerciorarnos de que es así.
Sin embargo, antes, vamos a eliminar la complejidad de las contraseñas a fin de
que la configuración a partir de ahora, nos sea menos molesta::

   # samba-tool domain passwordsettings set --min-pwd-length 4
   # samba-tool domain passwordsettings set --complexity off
   # samba-tool domain passwordsettings set --min-pwd-age 0
   # samba-tool domain passwordsettings show
   Password informations for domain 'DC=iespjm,DC=domus'

   Password complexity: off
   Store plaintext passwords: off
   Password history length: 24
   Minimum password length: 4
   Minimum password age (days): 0
   Maximum password age (days): 42
   Account lockout duration (mins): 30
   Account lockout threshold (attempts): 0
   Reset account lockout after (mins): 30

Obsérvese que las contraseñas, además, tienen una caducidad de 42 días. Ahora
podemos simplifcar nuestra contraseña de administrador de *samba*, cuyo nombre
es *Administrator* (en inglés)::

   # samba-tool user setpassword Administrator
   New Password:
   Retype Password:
   Changed password OK

.. warning:: Lo que se acaba de hacer, NO SE DEBE HACER JAMÁS en un servidor en
   producción. Las contraseñas, en ese caso, debe ser cuanto más seguras mejor;
   y es muy aconsejable obligar al usuario a que así las elija.

.. note:: Tenga en cuenta que, si como se aconseja, no se hace lo indicado las
   contraseñas tendrán un vida mínima de un día, con lo que no podremos hacer
   pruebas repetidas de ir cambiando la contraseña a un mismo usuario.

.. _smb-part-indep:

Es más que probable que, en algún momento, queramos crear usuarios que tengan
ficheros almacenados en el servidor, así que lo más recomendable es dedicar a
ello una partición (en nuestro caso, un volumen lógico para el grupo de
volúmenes *VGserver*)\ [#]_::

   # lvcreate -L250M VGserver -n samba
   # mkfs.ext4 -L SAMBA /dev/VGserver/samba

Además deberemos añadir la entrada al fichero :file:`/etc/fstab` para que se
monte automáticamente con cada arranque::

   # echo "/dev/mapper/VGserver-samba   /srv/samba  ext4  defaults   0  2" >> /etc/fstab

y, finalmente, montarlo::

   # mount /srv/samba

Comprobaciones
--------------

Preguntemos algo de información a nuestro servidor recién configurado::

   $ samba-tool domain info 127.0.0.1
   Forest           : iespjm.domus
   Domain           : iespjm.domus
   Netbios domain   : IESPJM
   DC name          : dc.iespjm.domus
   DC netbios name  : DC
   Server site      : Default-First-Site-Name
   Client site      : Default-First-Site-Name

Bien, según lo que pretendíamos. Echemos un vistazo a qué los usuarios que hay
en nuestra base::

   # samba-tool user list
   Administrator
   krbtgt
   Guest

y a los grupos, que son unos cuantos::

   # samba-tool group list
   [...]

Esto es lo mínimo para que el controlador de dominio funcione como tal. También
podemos comprobar cómo se ha creado nuestro |DNS|::

   $ samba-tool dns serverinfo localhost -U Administrator
   Password for [IESPJM\Administrator]:
   [...]

Y cuáles son las zonas que gestionamos::

   $ samba-tool dns zonelist localhost -U Administrator
   Password for [IESPJM\Administrator]:
     3 zone(s) found

     pszZoneName                 : 1.168.192.in-addr.arpa
     Flags                       : DNS_RPC_ZONE_DSINTEGRATED DNS_RPC_ZONE_UPDATE_SECURE
     ZoneType                    : DNS_ZONE_TYPE_PRIMARY
     Version                     : 50
     dwDpFlags                   : DNS_DP_AUTOCREATED DNS_DP_DOMAIN_DEFAULT DNS_DP_ENLISTED
     pszDpFqdn                   : DomainDnsZones.iespjm.domus

     pszZoneName                 : iespjm.domus
     Flags                       : DNS_RPC_ZONE_DSINTEGRATED DNS_RPC_ZONE_UPDATE_SECURE
     ZoneType                    : DNS_ZONE_TYPE_PRIMARY
     Version                     : 50
     dwDpFlags                   : DNS_DP_AUTOCREATED DNS_DP_DOMAIN_DEFAULT DNS_DP_ENLISTED
     pszDpFqdn                   : DomainDnsZones.iespjm.domus

     pszZoneName                 : _msdcs.iespjm.domus
     Flags                       : DNS_RPC_ZONE_DSINTEGRATED DNS_RPC_ZONE_UPDATE_SECURE
     ZoneType                    : DNS_ZONE_TYPE_PRIMARY
     Version                     : 50
     dwDpFlags                   : DNS_DP_AUTOCREATED DNS_DP_FOREST_DEFAULT DNS_DP_ENLISTED
     pszDpFqdn                   : ForestDnsZones.iespjm.domus

Obsérvese que se incluye la zona de resolución inversa que creamos antes. Por
último, comprobemos si el servidor |DNS| resuelve convenientemente::

   $ host dc
   dc.iespjm.domus has address 192.168.1.20
   $ host -t srv _ldap._tcp.iespjm.domus
   _ldap._tcp.iespjm.domus has SRV record 0 100 389 dc.iespjm.domus.
   $ host -t srv _kerberos._udp.iespjm.domus
   _kerberos._udp.iespjm.domus has SRV record 0 100 88 dc.iespjm.domus.

También podemos conectarnos con el cliente :program:`smbclient` para ver los
recursos compartidos::

   $ smbclient -L localhost -U Administrator
   Enter Administrator's password:
   Domain=[IESPJM] OS=[Windows 6.1] Server=[Samba 4.5.2-Debian]

           Sharename       Type      Comment
           ---------       ----      -------
           netlogon        Disk
           sysvol          Disk
           IPC$            IPC       IPC Service (Samba 4.5.2-Debian)
   Domain=[IESPJM] OS=[Windows 6.1] Server=[Samba 4.5.2-Debian]

           Server               Comment
           ---------            -------

           Workgroup            Master
           ---------            -------
           WORKGROUP            DC

O entrar en una de las unidades compartidas::

   $ smbclient //localhost/sysvol -U Administrator
   Enter Administrator's password:
   Domain=[IESPJM] OS=[Windows 6.1] Server=[Samba 4.5.2-Debian]
   smb: \> ls
     .                                   D        0  Tue Dec 27 18:49:29 2016
     ..                                  D        0  Tue Dec 27 20:46:47 2016
     iespjm.domus                           D        0  Tue Dec 27 18:49:27 2016

                   1733064 blocks of size 1024. 673972 blocks available
   smb: \> 

.. _kinit:
.. index:: kinit

Aún, sin embargo, no hemos usado la autenticación con *kerberos*, para lo cual
primero hay que conseguir un *ticket*::

   $ kinit Administrator@IESPJM.DOMUS
   Password for Administrator@IESPJM.DOMUS:
   Warning: Your password will expire in 41 days on mar 07 feb 2017 19:09:36 CET

.. _klist:
.. index:: klist

Ahora ya tenemos credenciales para *Administrator*\ [#]_::

   $ klist -l
   Principal name                 Cache name
   --------------                 ----------
   Administrator@IESPJM.DOMUS        FILE:/tmp/krb5cc_0

Así que podremos usar :command:`samba-tool` o :command:`smbclient` sin indicar
usuario, ya que este será aquel del que tenemos la credencial. Con el primero::

   $ samba-tool dns zonelist dc.iespjm.domus
   [...]

Obsérvese que no se usa *localhost*, sino el nombre de la máquina, aunque
podríamos habernos ahorrado el dominio::

   $ samba-tool dns zonelist dc

Con :program:`smbclient` debemos tener la precaución de añadir la opción ``-k``
que indica que usaremos *kerberos*::

   $ smbclient -L dc -k
   [...]

O bien, si preferimos acceder al disco::

   $ smbclient //DC/sysvol -k
   smb: \>


Aún podemos hacer más pruebas, porque el *directorio activo* se caracteriza por
ser una implementación compatible con *LDAP*. Por tanto, podremos hacer
consultas con las herramientas del paquete *ldap-utils* (que se debe haber
intalado como dependencia). Usando la autenticación con contraseña, podemos
consultar los atributos del administrador::

   $ ldapsearch -LLL -h dc -D 'cn=Administrator,cn=Users,dc=iespjm,dc=domus' -W \
      -b 'dc=iespjm,dc=domus' cn=Administrator
   Enter LDAP Password:
   dn: CN=Administrator,CN=Users,DC=iespjm,DC=domus
   objectClass: top
   objectClass: person
   objectClass: organizationalPerson
   objectClass: user
   cn: Administrator
   description: Built-in account for administering the computer/domain
   instanceType: 4
   whenCreated: 20161228130519.0Z
   uSNCreated: 3545
   name: Administrator
   objectGUID:: VPawBTKfx0+sCWj1mZtipw==
   userAccountControl: 512
   badPwdCount: 0
   codePage: 0
   countryCode: 0
   badPasswordTime: 0
   lastLogoff: 0
   primaryGroupID: 513
   objectSid:: AQUAAAAAAAUVAAAA7Wn7kfRzi7GK+ngk9AEAAA==
   adminCount: 1
   accountExpires: 9223372036854775807
   sAMAccountName: Administrator
   sAMAccountType: 805306368
   objectCategory: CN=Person,CN=Schema,CN=Configuration,DC=iespjm,DC=domus
   isCriticalSystemObject: TRUE
   memberOf: CN=Administrators,CN=Builtin,DC=iespjm,DC=domus
   memberOf: CN=Group Policy Creator Owners,CN=Users,DC=iespjm,DC=domus
   memberOf: CN=Enterprise Admins,CN=Users,DC=iespjm,DC=domus
   memberOf: CN=Schema Admins,CN=Users,DC=iespjm,DC=domus
   memberOf: CN=Domain Admins,CN=Users,DC=iespjm,DC=domus
   pwdLastSet: 131274042783321350
   lastLogonTimestamp: 131274042965165270
   whenChanged: 20161228131136.0Z
   uSNChanged: 3774
   lastLogon: 131274275990954850
   logonCount: 10
   distinguishedName: CN=Administrator,CN=Users,DC=iespjm,DC=domus

Y si tenemos las credenciales del administrador, con *kerberos*::

   $ ldapsearch -h dc -LLLQY GSSAPI -b 'dc=iespjm,dc=domus' cn=Administrator
   [...]

.. rubric:: **Enlaces de interés**

* `AD Samba4 <http://wiki.eri.ucsb.edu/stadm/AD_Samba4>`_
* `Setting up Samba as an Active Directory Domain Controller <https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller>`_

.. rubric:: Notas al pie

.. [#] Si en algún momento, se desea cambiar entre uno y otro, se puede usar
   :command:`samba_dnsupgrade`::

      # samba_upgradedns --dns-backend=BIND9_DLZ

   nos permitiría cambiar del servidor interno a *bind9*. Habría que cerciorarse
   también de cuál es el valor de la directivo ``server services`` para que no
   incluya el |DNS|. Puede obtenerse más información `aquí
   <https://wiki.samba.org/index.php/Changing_the_DNS_Back_End_of_a_Samba_AD_DC>`_.

   .. samba_dnsupdate -v: Mirar a ver qué hace exactamente.

.. [#] El tamaño del volumen lógico es ridículamente pequeño. De hecho. este es
   un sistema de ficheros en el que presumiblemente se almacenarán muchos datos.
   Pero esto sólo es una prueba y nuestro sistema es una máquian virtual.
.. [#] Si queremos eliminar estas credenciales basta con hacer::

   # kdestroy
