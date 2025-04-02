.. _ioredirect:

Redirección de E/S
==================

En la *shell* hay tres archivos abiertos de modo predeterminado:

#. La entrada estándar (*stdin*), que es el teclado.
#. La salida estándar (*stdout*), que es la pantalla.
#. La salida de errores (*stderr*), que también es la pantalla.

Por ejemplo, cuando usamos :ref:`cat <cat>` de forma normal::

   $ cat archivo
   [... El contenido del archivo ...]

este lee el archivo y devuelve su contenido por la salida estándar, porque es
su salida natural. Consecuentemente, vemos aparecer el contenido por la
pantalla. Si, en cambio, no le damos ningún  argumento, esto es,
no le decimos de qué archivo queremos que lea, :command:`cat` pasa a esperar
recibir el contenido por la entrada estándar; y al ser esta el teclado, queda
esperando a que escribamos algo por teclado::

   $ cat
   Esto esta escrito por teclado...
   Esto esta escrito por teclado...
   cada vez que pulso <Enter> cat lee la línea
   cada vez que pulso <Enter> cat lee la línea
   y, como su salida natural es la salida estándar,
   y, como su salida natural es la salida estándar,
   la escupe por la pantalla.
   la escupe por la pantalla.
   La forma de culminar una entrada
   La forma de culminar una entrada
   es escribir solo en una línea Ctrl+D.
   es escribir solo en una línea Ctrl+D.

Con esto ya hemos probado la entrada y salida estándares. Paa probar la
salida de errores basta con cometer uno::

   $ sadhgaskjhsa
   sadhgaskjhsa: no se encontró la orden

Aparentemente, parece la salida estándar, pero no es así, es la salida de
errores que se escribe sobre el mismo dispositivo: la pantalla. Ya
demostraremos más adelante que esto es así.

**Contenidos**

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*
