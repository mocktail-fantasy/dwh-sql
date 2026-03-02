CREATE OR REPLACE PROCEDURE etl.run_etl()
LANGUAGE plpgsql
AS $$
DECLARE
    log_message TEXT;
BEGIN
    INSERT INTO etl.job_logs (procedure_name, status, message)
    VALUES ('etl', 'STARTED', 'Main job initiated');

    BEGIN
        CALL load_raw_data();
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('load_raw_data', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('load_raw_data', 'FAILED', log_message);
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('etl', 'ABORTED', 'Aborted due to critical failure in load_raw_data.');
        RETURN;
    END;

    BEGIN
        CALL refresh_active_rosters();
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('refresh_active_rosters', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('refresh_active_rosters', 'FAILED', log_message);
    END;

    BEGIN
        CALL load_weekly_player_stats();
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('load_weekly_player_stats', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('load_weekly_player_stats', 'FAILED', log_message);
    END;

    BEGIN
        CALL load_annual_player_stats();
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('load_annual_player_stats', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('load_annual_player_stats', 'FAILED', log_message);
    END;

    INSERT INTO etl.job_logs (procedure_name, status, message)
    VALUES ('etl', 'COMPLETED', 'Main job finished. Check individual step logs for details.');

END;
$$;
