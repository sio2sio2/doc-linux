Recetas
=======
Se exponen aquí algunas recetas para la configuración de aspectos particulares
de :program:`nginx` y la instalación de aplicaciones web habituales.

.. warning:: Para la confección de estas recetas, cuando la configuración exige
   tráfico seguro, se ha usado la :ref:`configuración con certificado
   autofirmado <auto-cert>`, aunque no es la recomendable. Se obra así, porque para
   realizar pruebas de instalación en máquinas virtuales, es lo más cómodo.
   Cambiar la configuración para usar :ref:`certificados confiables
   <nginx-https>` es, no obstante, trivial.

.. toctree::
   :glob:
   :maxdepth: 1

   [0-9]*
