CREATE TABLE users (
   userid   VARCHAR(128)   NOT NULL,
   domain   VARCHAR(128),
   password VARCHAR(64)    NOT NULL,
   uid      INTEGER,
   gid      INTEGER,
   home     VARCHAR(255),
   active   CHAR(1)        DEFAULT 'Y' NOT NULL,
   quota    VARCHAR(20)    -- Límite de la cuota: 2G, 100M, 200K.
);
