-- quotes.db 
-- % sqlite quotes.db < db_create.sql 
-- sqlite does not have a varchar datatype: VARCHAR(255)
-- 
-- this script is no longer needed, keeping around 'just in case'

.bail on

--NOTE: A column declared INTEGER PRIMARY KEY will autoincrement.

DROP TABLE IF EXISTS quote;

CREATE TABLE IF NOT EXISTS quote (
  attr_id        INTEGER PRIMARY KEY, 
  quote          TEXT,
  rating         REAL
);

DROP TABLE IF EXISTS attribution;

CREATE TABLE IF NOT EXISTS attribution (
  attr_id   INTEGER,
  name      TEXT
);

