#!/bin/bash
# Runs once on first container start when pgdata volume is empty.
# Subsequent starts skip this entirely — data persists in the named volume.
set -e

run_sql() {
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$1"
}

run_cmd() {
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "$1"
}

echo ">>> Creating schemas"
run_sql /db/schemas/nfl_schemas.sql

echo ">>> Creating tables"
run_sql /db/tables/raw/create_raw_schema.sql
find /db/tables/games   -name "*.sql" | sort | xargs -I{} psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f {}
find /db/tables/players -name "*.sql" | sort | xargs -I{} psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f {}

echo ">>> Creating functions"
find /db/functions -name "*.sql" | sort | xargs -I{} psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f {}

echo ">>> Creating procedures"
run_sql /db/procedures/etl/logs.sql
run_sql /db/procedures/load/load_raw_data.sql
run_sql /db/procedures/load/backfill.sql
find /db/procedures/transform   -name "*.sql" | sort | xargs -I{} psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f {}
run_sql /db/procedures/etl/etl.sql

echo ">>> Creating views"
find /db/views -name "*.sql" | sort | xargs -I{} psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f {}

echo ">>> Running backfill (initial historical load)"
run_cmd "CALL backfill_raw_data();"

echo ">>> Running initial transforms"
run_cmd "CALL refresh_active_rosters();"
run_cmd "CALL load_weekly_player_stats();"
run_cmd "CALL load_annual_player_stats();"

echo ">>> Initialization complete"
