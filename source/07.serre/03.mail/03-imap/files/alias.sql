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
