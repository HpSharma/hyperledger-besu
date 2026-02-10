-- Create Firefly role (Non-superuser)
CREATE ROLE firefly
  LOGIN
  PASSWORD 'firefly'
  NOSUPERUSER
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION;
  NOBYPASSRLS;

-- Create Firefly database owned by the Firefly role
CREATE DATABASE firefly
  OWNER firefly
  ENCODING 'UTF8';

\connect firefly;

GRANT ALL PRIVILEGES ON SCHEMA public TO firefly;
ALTER SCHEMA public OWNER TO firefly;