CREATE USER messaggio WITH password '100200300';
ALTER ROLE messaggio WITH LOGIN;
CREATE database messaggio  WITH OWNER messaggio;
GRANT ALL PRIVILEGES ON DATABASE messaggio to messaggio;

CREATE OR REPLACE FUNCTION public.generate_uuid (
)
RETURNS uuid AS
$body$
DECLARE
    v_ts      TIMESTAMP DEFAULT clock_timestamp();
    v_ms      double precision DEFAULT EXTRACT(SECOND FROM (v_ts));
    v_uuid    VARCHAR(32) DEFAULT '';
    v_objtype VARCHAR(4)  DEFAULT '0000';
    v_apptype VARCHAR(2)  DEFAULT '00';
BEGIN

    -- Compile UUID in format TTTTTTTT-SSSS-SSAA-OOOO-RRRRRRRRRRRR
    --- T - Timestamp segment (4 bytes)
    --- S - Microseconds with .0000 precission
    --- A - Application type segment  (2 bytes)
    --- O - Object type segment (2 bytes)
    --- 0 - Empty segment (2 bytes)
    --- R - Random segment (4 bytes)
    v_uuid := v_uuid || to_hex(EXTRACT(EPOCH FROM v_ts)::integer)::text
             || lpad(to_hex((trunc(v_ms * 1000000) - trunc(v_ms) * 1000000)::integer)::text,6,'0')
             || v_apptype
             || v_objtype
             || lpad(to_hex((random()*65535)::bigint),4,'0')
             || lpad(to_hex((random()*65535)::bigint),4,'0')
             || lpad(to_hex((random()*65535)::bigint),4,'0');
    RETURN v_uuid::uuid;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

ALTER FUNCTION public.generate_uuid ()
  OWNER TO messaggio;

create schema message;

CREATE TABLE message.items (
  id UUID DEFAULT generate_uuid() NOT NULL,
  sender VARCHAR,
  subject VARCHAR NOT NULL,
  "to" VARCHAR [] NOT NULL,
  message VARCHAR NOT NULL,
  status BOOLEAN,
  created TIMESTAMP(0) WITH TIME ZONE DEFAULT now() NOT NULL,
  CONSTRAINT message_id_pk PRIMARY KEY(id)
)
WITH (oids = false);

CREATE INDEX items_idx ON message.items
  USING btree (created);

ALTER TABLE message.items
  OWNER TO messaggio;