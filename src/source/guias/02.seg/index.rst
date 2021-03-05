Seguridad Informática
=====================
El módulo de **Seguridad Informática**, con código **0226**, pertenece al
segundo curso del Ciclo Formativo de Grado Medio de |SMR| y su currículo se
desarrolla en la `Orden de 7 de julio de 2009
<https://www.juntadeandalucia.es/boja/2009/165/1>`_. Las unidades se han
diseñado atendiendo a los siguientes criterios:

* Que cubran todos los |RRAA|, |CCEE| y contenidos básicos relacionados
  en la `referida orden <https://www.juntadeandalucia.es/boja/2009/165/1>`_.
* Que una misma unidad sólo incluya |CCEE| de un único |RA|.
* Que los trimestres académicos incluyan unidades y |RRAA| completos.
* Las prácticas se desarrollan preferentemente (aunque no exclusivamente) sobre
  sistemas *Linux*, puesto que se toma como apoyo el manual general. 

.. rubric:: Contenidos

.. toctree::
   :maxdepth: 2
   :numbered:
   :glob:

   [0-9]*

.. todo:: Para el próximo curso se adelantan las unidades 4 y 5 a las 2 y 3, y
   se añade tras la unidad 4 una tercera unidad con la seguridad referente al
   entorno físico y el control de accesos.

   .. rubric:: Contenidos

   .. toctree::
      :maxdepth: 1
      :glob:

      01.intro
      04.crypto
      f03.entorno
      05.redes
      02.discos
      03.desktop
      06.ley

.. table:: Relación entre |RRAA| y |UUTT|
   :class: rraa-uutt

   +----------+-----------------------+-----------------+
   |          |  1ª Evaluación        | 2ª Evaluación   |
   |          +-----+-----+-----+-----+-----+-----+-----+
   |          | UT1 | UT2 | UT3 | UT4 | UT5 | UT6 | UT7 |
   +==========+=====+=====+=====+=====+=====+=====+=====+
   | RA1      |   X |     |   X |     |     |     |     |
   +----------+-----+-----+-----+-----+-----+-----+-----+
   | RA2      |     |     |     |     |   X |     |     |
   +----------+-----+-----+-----+-----+-----+-----+-----+
   | RA3      |     |     |     |     |     |   X |     |
   +----------+-----+-----+-----+-----+-----+-----+-----+
   | RA4      |     |   X |     |   X |     |     |     |
   +----------+-----+-----+-----+-----+-----+-----+-----+
   | RA5      |     |     |     |     |     |     |   X |
   +----------+-----+-----+-----+-----+-----+-----+-----+

.. rubric:: Material adicional

Para la realización de algunas de las prácticas del curso se requerirá:

+ Una máquina virtual con la última distribución de *Debian*, ya que varias
  de los ejercicios requieren la práctica de los conceptos teóricos dentro
  de un entorno *Linux*.
+ Puntualmente, un sistema *Windows 10*, preferentemente virtualizado para
  evitar trastocar fatalmente un sistema de trabajo.
+ Algún |SAI|, aunque :ref:`como puede emularse su comportamiento <sin-sai>`, no
  es absolutamente indispensable.
+ Un servidor virtual en internet con |IP| pública\ [#]_ que servirá para:

  + Obtener certificados de servidor.
  + Crear un servidor |VPN|.

.. rubric:: Ejercicios

.. toctree::
   :maxdepth: 1
   :glob:

   99.ejercicios/[0-9]*

.. rubric:: Notas al pie

.. [#] El programa `Azure Dev Tools for Education
   <https://azureforeducation.microsoft.com/devtools>`_, por ejemplo, permite la
   creación de servidores |VPS| a alumnos y profesores

.. |SMR| replace:: :abbr:`SMR (Sistemas Microinformáticos y Redes)`
.. |RRAA| replace:: :abbr:`RRAA (Resultados de Aprendizaje)`
.. |RA| replace:: :abbr:`RA (Resultado de Aprendizaje)`
.. |CCEE| replace:: :abbr:`CCEE (Criterios de Evaluación)`
.. |UUTT| replace:: :abbr:`UUTT (Unidades de Trabajo)`
.. |VPS| replace:: :abbr:`VPS (Virtaul Public Server)`

