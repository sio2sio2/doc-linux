.. _ej-rutas:

Ejercicios sobre rutas
----------------------

.. note:: Observe las siguientes reglas:

   #. No cambie de usuario, si no se se especifica expresamente
      o es necesario para realizar la operación requerida.

   #. Escriba siempre la orden anteponiendo como *prompt* un almohadilla
      (**#**), si el usuario es *root*, o un dólar (**$**), si es cualquier
      otro.

   #. No cambie de directorio, si no se le ordena.

Usando el usuario del sistema sin privilegios:

1. Vaya al directorio general de configuraciones.
#. Sin salir de ese directorio, consulte el contenido del directorio :file:`/`
   usando una ruta relativa.
#. Usando una ruta relativa, pase al directorio *home* dentro del cual se
   encuentran los datos personales de los usuarios.
#. Consulte el contenido del subdirectorio personal :file:`.config`. ¿Qué ruta
   es más corta? ¿La relativa o la absoluta? **Nota**: *El directorio puede no
   existir si el sistema no se ha utilizado mucho*.
#. Compruebe cuál es el directorio actual de trabajo.
#. Pásase al directorio :file:`local` dentro de :file:`usr`.
#. Suponiendo que el administrador del sistema respete el estándar, ¿hay
   algún ejecutable en el sistema que haya instalado él manualmente sin usar
   ningún gestor de paquetes?
#. Con ruta relativa, volver al directorio personal.
#. Listar el contenido del directorio raíz usando ruta relativa.
#. Suponiendo que los directorios personales de usuario estén en su ubicación
   habitual, obtenga la lista de tales directorios a fin de estimar cuántos
   usuarios físicos tiene definidos el sistema. **Nota**: *Esto sólo es una
   aproximación hasta que aprendamos cómo consultar usuarios*.
