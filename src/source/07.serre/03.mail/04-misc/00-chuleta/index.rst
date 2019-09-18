.. _smtp-chuleta:

Chuleta de configuración
========================
En estos apuntes se han descrito varias propuestas para la configuración de los
servicios |SMTP|/|IMAP|, por lo que puede resultar un poco caótico realizar una
configuración completa. Esta chuleta pretende establecer una propuesta de
configuración completa enlazando según el orden en que debe realizarse cada
paso:

#. :ref:`Configuración adecuada de la zona DNS <pre-smtp>` según sea el caso:

   * En una prueba local podremos instalar un servidor |DNS| como :ref:`dnsmasq
     <dnsmasq-dns>`.
   * En un servidor real es posible que la configuración debamos hacerla a
     través de la interfaz que nos ofrezca nuestro `agente registrador
     <https://es.wikipedia.org/wiki/Registrador_de_dominios>`_.

#. Instalación básica de :program:`postfix`, que incluye:

   * :ref:`Instalación en sí <postfix-inst>`.
   * :ref:`Configuración del cifrado <postfix-ssl>`.
   * :ref:`Configuración de la autenticación SASL con dovecot
     <postfix-dovecot-sasl>`.
   * :ref:`División del servicio en tres puertos <postfix-25-465-587>`.

#. :ref:`Configuración del servidor IMAP <dovecot-imap>`.

#. :ref:`Configuración de la entrega <postfix-dovecot-mda>`.

#. Configuración de **usuarios virtuales**, que podrá ser:

   * :ref:`Para un único dominio <postfix-usu-virtual-dovecot>`.
   * :ref:`Para varios dominios <postfix-mul-dom>`.

#. :ref:`Acreditación del servidor como remitente legítimo <smtp-acreditacion>`.

#. Repasar los :ref:`consejos de implementación <postfix-consejos>`.

#. Configuración *opcional*:

   * :ref:`Cuotas de usuario <postfix-quota>`.
   * :ref:`Cuentas virtuales <postfix-cue-virt>`.
   * :ref:`Limitación del envío y recepción de mensajes <postfix-flujo>`.
   * :ref:`Limitación de From: a los usuarios propios <postfix-vrfydmn>`.
   * :ref:`Filtro antispam con rspamd <rspamd>`.

