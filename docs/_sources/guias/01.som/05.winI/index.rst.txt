Fundamentos de *Windows* 10
***************************
Para realizar las pruebas pueden utilizarse una `versión de evaluación
<https://www.microsoft.com/es-es/evalcenter/evaluate-windows-10-enterprise>`_
para 90 días que proporciona la propia Microsoft.

.. warning:: El documento es sólo un índice de los temas a tratar

Instalación
============
#. Sobre máquina virtual se llevarán a cabo varias instalaciones:

   * **Teoría**

     - Con disco en blanco y *firmware* |BIOS|.
     - Con disco en blanco y *firmware* |UEFI|.
     - Con disco previamente particionado adecuadamente y *firmware* |UEFI|.

   * :ref:`Práctica 1 <p4.1>`:

     a. Configurar una máquina virtual con unos determinados parámetros, entre
        los cuales que la tarjeta de red sea paravirtualizada (virtio-net).
     #. Particionar previamente el disco.
     #. Instalar windows.
     #. Instalar la tarjeta de red para disponer de conexión.
     #. Instalar las "*Guest Additions*".
     #. Comprobar el funcionamiento del ratón y de algunas teclas *Host*.

Uso habitual
============
#. Acceso:

   * **Teoría**: No hay.
   * :ref:`Práctica 2 <p4.2>`: mediante comentarios y capturas hacer el alumno
     explique cuál es la función de la pantalla de acceso y describa
     los distintos componentes e iconos que hay en ella y que información
     proporcionan.

#. Interfaz:

   * **Teoría**: No hay.
   * :ref:`Práctica 3 <p4.3>`: destinada a revisar algunos aspectos
     importantes de la interfaz gráfica.

#. Exploración de ficheros:

   * **Teoría**: Explicación de cómo se organizan el árbol de directorios
     de *Windows*.
   * :ref:`Práctica 4 <p4.4>`: destinana a explicar cómo es la estructura de
     ficheros en *Windows* y a cómo usar el explorador.

#. Configuraciones:

   * **Teoría**: No hay.
   * :ref:`Práctica 5 <p4.5>`: red, instalación y desinstalación de software,
     actualizaciones de *Windows*.

.. |BIOS| replace:: :abbr:`BIOS (Basic I/O System)`
.. |UEFI| replace:: :abbr:`UEFI (Unified Extensible Firmware Interface)`
