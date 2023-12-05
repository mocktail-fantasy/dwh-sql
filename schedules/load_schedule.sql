-- pg_cron must be enabled for this to run
SELECT cron.schedule('daily_load_from_s3', '0 14 * * *', $$CALL load_from_s3()()$$);

