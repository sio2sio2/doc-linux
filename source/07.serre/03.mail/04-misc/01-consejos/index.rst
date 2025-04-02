.. _postfix-consejos:

Consejos de implementación
==========================
La implementación de un servidor de correo real es muy exigente debido,
fundamentalmente, a dos razones:

* Es un servidor muy atacado con el fin de hacerse con alguna cuenta para usarla
  como trampolín para hacer *spam*.
* Debemos tener buena reputación ante el resto de servidores de correo, puesto
  que de lo contrario los correos que mandemos desde nuestro servidor a clientes
  de otros servidores o bien acabarán en el buzón de spam del destinatario
  (malo) o bien será rechazados directamente (mucho peor).

Por ello, es conveniente atender una serie de consejos:

Relativos al **spam**:
   #. El servidor |SMTP| debe exigir **autenticación**, si se usa desde una máquina
      remota, que es precisamente lo que hace la configuración que hemos
      desarrollado. Un servidor con *relay* abierto es posible que no dure más de unas
      pocas horas antes de que algún spammer lo descubra y lo comience a usar para sus
      enfadosos fines. Si a posteriori se quiere comprobar si nuestro servidor está
      abierto, basta con intentar mandar un correo electrónico sin habernos
      autenticado previamente. El modo más sencillo es abrir desde una máquina
      remota una sesión de telnet al servidor e intentar el envío de un mensaje sin
      autenticarnos primero:

      .. code-block:: none
         :emphasize-lines: 18, 20

         $ telnet smtp.mail1.org 25
         Trying 192.168.1.11...
         Connected to mail.maild.org
         Escape character is '^]'.
         220 smtp.midominio.es ESMTP Postfix (Debian/GNU)
         ehlo testing
         250-smtp.maild.org
         250-PIPELINING
         250-SIZE 10240000
         250-VRFY
         250-ETRN
         250-STARTTLS
         250-AUTH PLAIN LOGIN
         250-AUTH=PLAIN LOGIN
         250-ENHANCEDSTATUSCODES
         250-8BITMIME
         250 DSN
         MAIL FROM: <usuario@mail1.org>
         250 2.1.0 Ok
         RCPT TO: <test@example.com>
         554 5.7.1 <test@example.com>: Relay access denied

      Si somos muy vagos, también podemos hacer uso de algunos páginas de internet
      que realizan esta misma prueba por nosotros. Por ejemplo, `mxtoolbox
      <https://mxtoolbox.com/diagnostic.aspx>`_.

   #. Debe dificultarse la posibilidad de obtener un **usuario válido**: resuelto el
      problema del uso indiscriminado del servidor por terceros, es indispensable
      asegurarse de que nadie ajeno al servidor pueda usarlo ilegítimamente. Como se
      ha obligado a la autenticación, la única posibilidad es que un *spammer* obtenga
      un usuario y contraseña válidos. Hay dos métodos complementarios para dificultar
      esto:

      * Una buena política de usuarios que puede consistir en:

        - Separar los usuarios de correo de los usuarios del sistema. Para ello
          podemos recurrir a algunos módulos de pam (como pam-userdb, pam-pwdfile o
          pam-fshadow) o a soluciones más elaboradas como ldap o samba.
        - Forzar a que las contraseñas sean algo complicada, para lo que puede
          usarse el módulo *pam-cracklib*.
        - Establecer una caducidad para las contraseñas.

      * Usar *software* que evite los ataques por fuerza bruta como :ref:`fail2ban
        <fail2ban>` o :ref:`el módulo recent de iptables <ipt-limit>`.

   #. **Limitar el uso intensivo** del servidor (véase :ref:`el control del spam
      <pam>`).

Relativos a nuestra **reputación** ante el resto de servidores |SMTP|
   #. Configurar la **resolución inversa** de la |IP| pública: algunos listas
      negras de internet pueden incluir nuestro servidor como consecuencia de que
      nuestra |IP| no resuelva al nombre del servidor de correo. Además, los sistemas
      de detección de spam que usan los servicios de correo también pueden usar
      este criterio para puntuar negativamente. Por ello, es conveniente asegurarse
      de que funciona correctamente la resolución inversa de nombres, es decir, que
      si poseemos la |IP| pública 80.80.80.80 esta resolverá al nombre de nuestra
      servidor mail.mail1.org, por ejemplo. Sin embargo, a diferencia del dominio
      (que nos pertenece cuando lo registramos a nuestro nombre y podemos
      configurarlo a voluntad), la dirección |IP| pertenece a nuestro |ISP| y sólo él
      es capaz de configurar esta resolución. La solución es ponerse en contacto
      con el |ISP| y que se encargue de ello: si se dispone de |IP| estática no debería
      haber ningún problema.

   #. Asegurarse de que hemos :ref:`acreditado nuestro servidor como remitente
      legítimo <smtp-acreditacion>`.

   #. Comprobación de la **reputación del servidor**: tomadas todas las medidas
      pertinentes no está de más comprobar si hemos sido incluidos en alguna lista
      negra, a fin de que, si es así, podamos analizar la causa y subsanarla. Esto
      puede hacerse a través de, por ejemplo, `rtbl.org <https://www.rbls.org/>`_ p
      `dnsbl.info <https://www.dnsbl.info/>`_

      Pueden también hacerse comprobaciones manuales con :ref:`host <host>` o
      :ref:`dig <dig>` haciendo consultas a la lista y usando la |IP| del servidor
      puesta al revés. Por ejemplo, si la |IP| de nuestro servidor es
      *80.35.60.114*, podemos intentar::

         $ host 114.60.35.80.dyna.spamrats.com
         114.60.35.80.dyna.spamrats.com has address 127.0.0.36
         $ dig +short 114.60.35.80.dyna.spamrats.com
         127.0.0.36
         $ host 114.60.35.80.zen.spamhouse.org
         114.60.35.80.zen.spamhouse.org has address 199.59.242.151

      Si la |IP| está en la lista negra debe devolverse una dirección de
      *127.0.0.X* donde *X* es un número que identifica la causa por la que la |IP|
      está listada.

.. |ISP| replace:: :abbr:`ISP (Internet Service Provider)`
