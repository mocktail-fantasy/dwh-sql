-- pg_cron must be enabled for this to run
CREATE EXTENSION IF NOT EXISTS pg_cron;
SELECT cron.schedule('daily_load_from_s3', '0 14 * * *', 'CALL etl.run_etl();');

