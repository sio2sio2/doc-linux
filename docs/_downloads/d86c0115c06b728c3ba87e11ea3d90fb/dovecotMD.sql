CREATE TABLE domains (
   domain      VARCHAR(128)   PRIMARY KEY NOT NULL,
   transport   VARCHAR(255)
);

CREATE TABLE users (
   userid   VARCHAR(128)   NOT NULL,
   domain   VARCHAR(128),
   password VARCHAR(64)    NOT NULL,
   uid      INTEGER,
   gid      INTEGER,
   home     VARCHAR(255),
   active   CHAR(1)        DEFAULT 'Y' NOT NULL,
   quota    VARCHAR(20),   -- Límite de la cuota: 2G, 100M, 200K.
   CONSTRAINT pk_us  PRIMARY KEY(userid, domain),
   CONSTRAINT fk_dom FOREIGN KEY(domain) REFERENCES domains(domain)
      ON DELETE CASCADE ON UPDATE CASCADE
);

-- Opcional para almacenar alias de los usuarios

CREATE TABLE aliases (
   address     VARCHAR(255)      NOT NULL,
   goto        VARCHAR(255),  -- Para usuarios que no son de la base de datos
   userid      VARCHAR(128),
   domain      VARCHAR(128),
   active      CHAR(1)           DEFAULT 'Y' NOT NULL,
   CONSTRAINT pk_al PRIMARY KEY(address),
   CONSTRAINT fk_us_al FOREIGN KEY(userid, domain) REFERENCES users(userid, domain)
      ON DELETE CASCADE ON UPDATE CASCADE
);
