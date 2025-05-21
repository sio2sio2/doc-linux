Ejercicios sobre registros
==========================

Tradicionales
-------------
#. Consulte los accesos fallidos al sistema.

#. Añada una interfaz más a la máquina (*eth1*) e instale :ref:`dnsmasq <dnsmasq>`,
   Configure la interfaz y el servidor para que se sirvan direcciones en la red
   interna de la red *192.168.255.0/24* y añada en la configuración::

      log-facility=local7

   para que marquen los registros que mandan a rsyslog como de la categoría
   *local7*.

#. Haga que los registros del servidor |DHCP| se almacenen EXCLUSIVAMENTE en
   :file:`/var/log/dhcp.log`.

#. Cuente el número de direcciones |IP| a las que se ha proporcionado
   configuración.

#. Muestre la lista de direcciones |IP|\ s concedidas.

SystemD
-------
#. Ver los últimos 20 mensajes generados por el núcleo.

#. Hacer persistentes los registros, pero que no ocupen más de 100MB de espacio
   en disco.

#. Mostrar los mensajes de la última hora.

#. Revisar los mensajes generados por cron en las últimas ocho horas,

#. Contar cuántas |IP|\ s ha concedido el servidor |DHCP| del |ISC| en la última
   hora. **Nota**: Este servidor es el servicio ``dhcpd`` y los mensajes de
   concesión contienen la palabra "``DHCPACK``".
