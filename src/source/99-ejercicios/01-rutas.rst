Ejercicios sobre rutas
----------------------

.. note:: Observe las siguientes reglas:

   #. No cambie de usuario, si no se se especifica expresamente
      o es necesario para realizar la operación requerida.

   #. Escriba siempre la orden anteponiendo como *prompt* un
      dólar (**$**), si el usuario es *root*, o una almohadilla
      (**#**), si es cualquier otro.

   #. No cambie de directorio, si no se le ordena.

Usando el usuario del sistema sin privilegios:

1. Ir al directorio *etc* que se encuentra dentro del directorio
   :file:`/`.

2. Sin salir de ese directorio, consultar el contenido del directorio :file:`/`
   usando una ruta relativa.

3. Usando una ruta relativa, pasar al directorio *home* que almacena los datos
   de los usuarios del sistema.

4. Consultar el contenido del subdirectorio personal :file:`.config`. ¿Qué ruta
   es más corta? ¿La relativa o la absoluta?

5. Comprobar cuál es el directorio actual de trabajo.

6. Pasarse al directorio :file:`local` dentro de :file:`usr`.

7. Suponiendo que el administrador del sistema respete los estándares, ¿hay algún
   ejecutable instalado en el sistema que haya instalado él y no forme parte de la
   distribución?

8. Con ruta relativa, volver al directorio personal.

9. Listar el contenido del directorio raíz usando ruta relativa.

10. Listar las interfaces de red mirando en el directorio apropiado, no
    usando comandos como :command:`ip` o :command:`ifconfig`.

    .. note:: Deberá averiguar cuál es este directorio donde el sistema muestra
       las interfaces de red detectadas.