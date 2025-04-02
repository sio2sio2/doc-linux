.. _msmtp:

:command:`msmtp` (|MSA|)
========================
Existe la posibilidad de usar *software* que actúe exclusivamente como
|MSA|, aunque hacerlo no añade ventajas a usar directamente el |MUA| si este
ofrece la oportunidad.

En *linux* es bastante sencillo de usar `el programa msmtp
<http://msmtp.sourceforge.net/>`, ya que existe en los repositorios::

   # apt install msmtp

La configuración se hace creando :file:`~/.msmtprc` del siguiente modo:

.. literalinclude:: files/msmtprc
   :language: none

En el fichero cada bloque representa la configuración para una cuenta, aunque
``defaults`` permite definir directivas que se aplicarán a todos los cuantas (a
menos que se especifique lo contrario).

En el ejemplo, hay definidas dos cuentas que usan negociación *STARTTLS* para
cifrar la comunicación. A la de *gmail.com*, además, se le exige que el
certificado que facilite sea válido.

Por último, se fija como cuenta predeterminada la de *google*.

.. warning:: Como el fichero contiene contraseñas, es indispensable restringir
   la lectura para el resto de usuarios::

      $ chmod 600 ~/.msmtprc

Una vez hecho, podemos enviar un correo de prueba del siguiente modo::

   $ msmtp -t -a example
   From: yo@example.net
   To: destinatario@hotmail.com
   Subject: Un correo de prueba enviado con msmtp

   Nada que añadir en el cuerpo

Con la opción ``-a`` se especifica cuál de las cuentas definidas quiere usarse.
Si se prescinde de ella, se usará la que se definió como predeterminada en el
fichero.

.. |MTA| replace:: :abbr:`MTA (Mail Transport Agent)`
.. |MSA| replace:: :abbr:`MSA (Mail Submission Agent)`
.. |MUA| replace:: :abbr:`MUA (Mail User Agent)`
