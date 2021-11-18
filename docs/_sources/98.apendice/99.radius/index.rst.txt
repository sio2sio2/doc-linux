.. _radius:

Servidor |RADIUS|
*****************

.. Chuleta

   https://wiki.freeradius.org/guide/HOWTO

   Añadir el punto de acceso en client.conf:

   client ap {
      ipaddr   = IP.DEL.PUNTO.DE.ACCESO
      secret   = clave_secreta
   }

   Añadir usuarios en users:

   usuario1     Cleartext-Password := "contraseña"

   Y ya está. Si se quiere almacenar usuarios en una base de datos sqlite:

   # cd mod-enabled
   # ln -s ../mod-available/sql

   Editar ese archivo:

   sql {
      [...]
      dialect = "sqlite"
      [...]
      #driver = "rlm_sql_null"
      driver = "rlm_sql_${dialect}"
      [...]

      sqlite {
         filename = "/etc/raddb/sqlite.db"
         [..]
      }
   }

   Y crear el directorio para que se cree automáticamente la base de datos:

   # mkdir -m700 /etc/raddb
   # chown freerad:freerad /etc/raddb
   # invoke-rc.d freeradius restart
   # echo "INSERT INTO radcheck VALUES (NULL, 'usuario2', 'Cleartext-Password', ':=', 'nolasabes');" | sqlite /etc/raddb/sqlite.db

.. |RADIUS| replace:: :abbr:`RADIUS (Remote Authentication Dial In User Service)`
