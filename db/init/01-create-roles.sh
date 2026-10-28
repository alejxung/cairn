#!/bin/bash
# Creates the three database roles and their permissions the first time the Postgres
# container starts with an empty data volume (the image runs everything in this folder
# once, in filename order). Passwords come from the container's environment, which
# docker-compose.yml fills from .env, so no secret is written in this file.
#
# The roles split power so that a mistake or a misbehaving agent cannot do more than its
# job needs:
#   cairn_owner  owns the schema and its tables; the only role that can change structure.
#   cairn_app    reads and writes rows; used by the API. Cannot change structure.
#   cairn_agent  SELECT only; used by the LLM agents. Cannot write anything, ever.

set -euo pipefail

# The heredoc delimiter is quoted so the shell leaves the SQL alone. Passwords and the
# database name reach SQL as psql variables, and :'name' / :"name" quote them as a
# literal / identifier, so unusual characters cannot break or inject into the statements.
psql -v ON_ERROR_STOP=1 \
  -v owner_pw="$OWNER_PASSWORD" \
  -v app_pw="$APP_PASSWORD" \
  -v agent_pw="$AGENT_PASSWORD" \
  -v db="$POSTGRES_DB" \
  --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'SQL'

CREATE ROLE cairn_owner LOGIN PASSWORD :'owner_pw';
CREATE ROLE cairn_app LOGIN PASSWORD :'app_pw';
CREATE ROLE cairn_agent LOGIN PASSWORD :'agent_pw';

-- Creating an extension needs superuser, so it lives here and not in migrations.
CREATE EXTENSION IF NOT EXISTS vector;

-- Only the owner may create objects in the public schema; app and agent may use it.
ALTER SCHEMA public OWNER TO cairn_owner;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO cairn_app, cairn_agent;

-- Only these roles may connect to the database.
REVOKE ALL ON DATABASE :"db" FROM PUBLIC;
GRANT CONNECT ON DATABASE :"db" TO cairn_owner, cairn_app, cairn_agent;

-- Tables the owner creates later get these grants automatically.
ALTER DEFAULT PRIVILEGES FOR ROLE cairn_owner IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cairn_app;
ALTER DEFAULT PRIVILEGES FOR ROLE cairn_owner IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO cairn_app;
ALTER DEFAULT PRIVILEGES FOR ROLE cairn_owner IN SCHEMA public
  GRANT SELECT ON TABLES TO cairn_agent;

-- Second layer: the agent's transactions are read-only even if a write were granted.
ALTER ROLE cairn_agent SET default_transaction_read_only = on;

SQL
