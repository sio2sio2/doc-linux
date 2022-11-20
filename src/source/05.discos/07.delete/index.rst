.. _remove-data:

Eliminación de datos
********************
La eliminación efectiva de los datos es fundamental cuando hemos almacenado
datos sensibles en un dispositivo y lo sustituimos por otro. Antes de empezar,
sin embargo, tengamos presentes dos cosas:

- El borrado de archivos con las herramientas básicas del sistema operativo
  (:ref:`rm <rm>` en *Linux*) no borra realmente los datos, simplemente marca
  los bloques que éstos ocupaban como reutilizables\ [#]_.
- Si habíamos decidido cifrar los datos, su eliminación efectiva no tiene
  importancia alguna: los datos serán absolutamente inaccesibles sin la clave
  con que se cifraron.

Sabido esto, si nuestra intención es eliminar realmente los datos del disco,
tenemos dos opciones:

#. **Destruir físicamente el disco**, a fin de que quede inservible y sus datos
   sean absolutamente ilegibles. A este respecto, es muy interesante `este
   artículo de Xataka
   <https://www.xataka.com/especiales/como-destruir-un-disco-duro-definitivamente-para-que-no-se-pueda-recuperar-la-informacion>`_.

#. Utilizar **técnicas de borrado efectivo** de los datos, que será a lo que
   propiamente dediquemos el epígrafe.

.. warning:: Si realmente se dispone de datos sensibles, cífralos. Eso evitará
   problemas cuando quiera prescindir del dispositivo de almacenamiento, pero
   también durante su vida útil.

Sobrescrituras
==============
.. warning:: No use estas técnicas con dispositivos |SSD|. En realidad, tampoco
   son recomendables para discos magnéticos (|HDD|) modernos por las razones que
   se expondrán a continuación. Son más recomendables las :ref:`técnicas basadas
   en el firmware <borrado-firmware>`.

Estas técnicas consisten, simplemente, es sobrescribir los datos usando métodos
de escritura estándar. Son técnicas **nada recomendables**, puesto que:

- Son extremadamente lentas.
- Si no se hacen las suficientes sobrescrituras, la información podría llegar a
  recuperarse.
- Avejentan el dispositivo y recordemos que los discos |SSD| tienen unos ciclos
  limitados de lectura y escritura.
- En los sistemas de archivos con *journaling* puede quedar información sensible
  en el registro.
- En los discos |SSD| estas técnicas usadas para eliminar archivos concretos son
  inútiles sea cual sea el sistema de archivos, puesto que todos los |SSD|
  modernos utilizan una funcionalidad llama :dfn:`wear leveling` (*nivel de
  desgaste*), que consiste en procurar ir distribuyendo equitativamente las
  escrituras entre todos los bloques. Por ese motivo, cuando se pida
  sobrescribir un archivo lo más probable es que el *firmware* del disco elija
  escribir otros bloques distintos a los que ocupa el archivo y los bloques en
  que se encontraban éstos, simplemente, los marque como vacíos.

:ref:`dd <dd>`  (o :ref:`cat <cat>`)
   Ya se ha explicado su uso. Ambas herramientas nos servirían para
   sobrescribir con ceros (o con caracteres arbitrarios si sustituimos
   :file:`/dev/zero` por :file:`/dev/urandom`) un dispositivo completo (o una
   partición en su defecto). Por ejemplo, si quisiéramos sobrescribir con ceros
   el disco *sdz* completo::

      #  dd < /dev/zero > /dev/sdz bs=1M status=progress

   o bien::

      # cat < /dev/zero > /dev/sdz

   Sólo sobrescribimos una vez: las otras herramientas permiten escrituras más
   seguras.

.. _shred:
.. index:: shred

:manpage:`shred`
   Es una orden básica incluida en las :deb:`coreutils`, que permite borrar
   ficheros de manera segura, esto es, asegurándose de que el fichero no puede
   recuperarse. En realidad, se limita a hacer tres pasadas escribiendo datos
   aleatorios y una cuarta opcional para rellenar finalmente con ceros.  Si
   suponemos que tenemos un fichero llamado "datos_secretos.txt", podremos
   borrarlo del siguiente modo::

      # shred -uvz datos_secretos.txt

   donde la opción :kbd:`-u` elimina el fichero tras borrar su contenido,
   :kbd:`-v` nos ofrece información de cada pasada y :kbd:`-z` hace una pasada
   adicional rellenando con ceros. Además, podemos hacer más de tres
   pasadas, utilizando la opción :kbd:`-n`. Sin embargo, no hay opción para
   borrado recursivo, por tanto, si queremos borrar todo el contenido de un
   directorio que incluye subdirectorios, tendremos que recurrir al uso de
   :ref:`find <find>` para generar la lista de archivos.

   Un uso alternativo de :command:`shred` es el de borrar dispositivos enteros,
   lo cual evita este último inconveniente y, además, es útil si nuestra
   intención es borrar toda la información. Así, si quisiéramos borrar todo lo
   que contiene el dispositivo :file:`/dev/sdz`, podríamos arrancar desmontar
   todo sistema de ficheros asociado a particiones de este dispositivo (si se
   encuentra en él el sistema raíz, podrías arrancar el *linux* de un dispositivo
   extraíble) y hacer::

      # shred -vz /dev/sdz

   donde en este caso, no tiene sentido usar la opción :kbd:`-u`.

.. _nwipe:

:manpage:`nwipe`
   Es una orden derivada de DBAN_ (una conocida aplicación para eliminación de
   datos) que implementa siete métodos estandarizados de borrado (`DoD
   5220.22-M`_, Guttmann_, etc.). Su uso es bastante sencillo::

      # nwipe -m dod /dev/sdz

   donde la opción :kbd:`-m` permite indicar qué método quiere usarse (en su
   página de manual puede consultar todos los posibles).

.. _secure-delete:
.. _srm:
.. _sfill:
.. _sswap:
.. _sdmem:

:manpage:`secure-delete`
   Es una *suite* con unas cuantas herramientas especializadas en el borrado de
   información utilizando el método Guttmann_:

   - :command:`srm`, que borra ficheros.
   - :command:`sfill`, que borra el espacio libre.
   - :command:`sswap`, que borra la memoria de intercambio.
   - :command:`sdmem`, que borrar la memoria |RAM|.

   La instalación es trivial::

      # apt install secure-delete

   El borrado estándar que lleva a cabo hace cerca de 40 pasadas y puede acabar
   con una pasada adicional que rellena con ceros. Borrar un fichero se hace
   así::

      $ srm -vz datos_secretos.txt

   A diferencia de :ref:`shred <shred>`, sí tiene una opción :kbd:`-r` para
   borrado recursivo.

   Por su parte, borrar el espacio libre de un sistema de ficheros, se nace
   utilizando :command:`sfill` sobre el punto de montaje. Por ejemplo::

      # sfill -vz /home

   Si se usa con la opción :kbd:`-l` sólo hará dos pasadas con número aleatorios
   y si se duplica la opción :kbd:`-ll` solamente una.

.. seealso:: Hay un excelente `artículo sobre estas herramientas de borrado en
   howtogeek
   <https://www.howtogeek.com/425232/how-to-securely-delete-files-on-linux/>`_.

.. _borrado-firmware:

Firmware del dispositivo
========================

.. blkdiscard, hdparm.

.. https://grok.lsu.edu/article.aspx?articleid=16716
   https://linuxhint.com/securely-delete-files-from-my-ssd/
   https://www.tomshardware.com/how-to/secure-erase-ssd-or-hard-drive  --> para windows
   https://tinyapps.org/docs/wipe_drives_hdparm.html

   + Explica cómo usar hdparm para borrar discos PATA/SATA (sean HDD o SSD).
   + Investigar también nwipe (que usa dban y sirve para discos magnéticos).
   + Investigar Erase Secure Command, que es la funcionalidad del firmware de los
     discos que permite su borrado. Hay dos modalidades:

     - Normal: Que equivale a  sobrescribir con 0.
     - Mejorada: Que debería servir para borrar datos de forma segura.

   - ¿Y cambiar la clave de cifrado? ¿A qué equivale eso? ¿Cómo se consulta si
     el disco lo soporta?

.. https://unix.stackexchange.com/questions/659931/how-secure-is-blkdiscard
   https://blog.elcomsoft.com/2019/01/life-after-trim-using-factory-access-mode-for-imaging-ssd-drives/
   https://geekland.eu/trim-debemos-activarlo-ssd/
   https://www.zeitgeist.se/2014/09/07/enabling-ata-security-on-a-self-encrypting-ssd/

.. Herramientas de borrado:
   https://www.genbeta.com/herramientas/siete-herramientas-gratis-para-borrar-de-forma-segura-tus-discos-duros-hdd-o-ssd

.. rubric:: Notas al pie

.. [#] De ahí, que existan :ref:`aplicaciones para recuperar archivos
   <archivos-rec>`.

.. |SSD| replace:: :abbr:`SSD (Solid-State Drive)`
.. |HDD| replace:: :abbr:`HDD (Hard Disk Drive)`
.. |RAM| replace:: :abbr:`RAM (Random Access Memory)`

.. _DBAN: https://hipertextual.com/2018/12/borrado-seguro-disco-dban
.. _DoD 5220.22-M: https://www.bitraser.com/article/DoD-5220-22-m-standard-for-drive-erasure.php
.. _Guttmann: https://en.wikipedia.org//wiki/Gutmann_method
