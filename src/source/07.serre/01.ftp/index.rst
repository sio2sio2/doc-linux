.. _ftp:

Transferencia de ficheros
=========================
|FTP| (Protocolo de transferencia de ficheros) es un protocolo para la
transferencia de ficheros sobre redes *TCP/IP*. Es un protocolo antiguo, con
casi la misma edad que la propia internet\ [#]_, y con unas complicaciones
adicionales, que han propiciado que se vaya abandonando paulatinamente en favor
de otras soluciones de transferencia\ [#]_.

Es, por tanto, un protocolo obsoleto y que es preferible evitar. En particular,
algunas de las razones para sostener esta afirmación son\ [#]_:

#. La descarga anónimma de ficheros puede llevarse a cabo mediante otros
   protocolos como |HTTP|.
#. Han surgido otros protocolos que explotan algunas necesidades particulares
   como la sincronía entre los datos almacenados en cliente y servidor (p.e.
   `rsync <https://es.wikipedia.org/wiki/Rsync>`_) o el control de versiones
   (p.e. `git <https://en.wikipedia.org/wiki/Git>`_).
#. Pobre soporte de compresión de datos para el ahorro de ancho de banda.
#. El protocolo es ineficiente y requiere transtear con los cortafuegos para
   darle soporte.
#. El servicio no dispone de software de cacheo ni aceleradores,
#. Muchas implementaciones del protocolo reciben ya pocas actualizaciones.

Por estas razones bajo el epígrafe proponemos la configuración de un servidor
|SSH| como sustituto, aunque también describiremos cómo configurar un servidor
|FTP| clásico, :program:`vsftpd`.

El plan de estudio consistirá en lo siguiente:

.. toctree::
   :glob:
   :maxdepth: 2

   [0-9]*

.. rubric:: Notas al pie

.. [#] Tiene su origen en 1971 cuando se desarrolló para transferir ficheros
   entre equipos del :abbr:`MIT (Massachussets Institute of Tecnología)` y su
   forma actual se perfiló en 1973.

.. [#] Cada vez es más difícil encontrar servidores que sigan ofreciendo sus
   servicios de |FTP|. Es interesante, al respecto, `la noticia de kernel.org
   <https://www.kernel.org/shutting-down-ftp-services.html>`_ sobre el cese de
   su servicio de |FTP|, llevado a cabo a comienzos de 2017.

.. [#] Algunas de estas razones están tomadas del enlace anterior.
