Ejercicios sobre SystemD
========================
#. ¿Qué debemos hacer para que, aunque ese instalado el servidor gráfico,
   la máquina arranque sin él. Justifique convenientemente la respuesta.

#. Comprobar si el servidor |SSH| ha arrancado correctamente.

#. Supongamos que descubrimos que, tras arrancar el sistema, |SSH| **no** ha
   arrancado como esperábamos que hiciera. ¿Qué podemos mirar para diagnósticar
   qué ha fallado? Considere dos posibilidades

   a. Que el servicio no ha arrancado porque falló su arranque.
   b. Que ni siquiera se intentó el arranque.

#. Supongamos que modificamos la configuración de arranque del servicio
   *rsyslog*. Haga que el demonio aplique dicha configuración.

#. Sabemos que :program:`sslh` es un servicio que escucha en el puerto que
   indiquemos (p.e. **443**) y permite redirigir tráfico según el paquete sea de
   un protocolo u otro (p.e |SSH| y |HTTP|\ s). Cuándo lo instalamos, ¿por qué
   pasa a intentar arrancar automáticamente?

#. ¿Es posible que un servicio que se arranca en ``multi-user.target`` no
   arranque el ``graphical.target``?

#. Impida que un servicio pueda arrancar, incluso de forma manual.

#. Consulte el *nivel de ejecucion* predeterminado.

#. Demuestre que *rsyslog* arranca automáticamente en el nivel de ejecución
   anterior.

#. Describa qué ocurre si se hace lo siguiente::

     # apt-get update && apt-get install -y isc-dhcp-server
     # systemctl disable isc-dhcp-server

#. Compruebe si ha fallado el arranque de algún servicio durante el proceso de
   arranque del sistema.

#. ¿Cómo se puede saber si cierto servicio arranca en un determinado nivel de
   ejecución? Se sobreentiende que sin llegar a arrancar la máquina en ese
   nivel de ejecución.
