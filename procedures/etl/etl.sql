CREATE OR REPLACE PROCEDURE etl.run_etl()
LANGUAGE plpgsql
AS $$
DECLARE
    log_message TEXT;
BEGIN
    INSERT INTO etl.job_logs (procedure_name, status, message)
    VALUES ('transform_raw_data', 'STARTED', 'Main job initiated');

    BEGIN
        CALL load_from_s3();
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('load_from_s3', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('load_from_s3', 'FAILED', log_message);
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('etl', 'ABORTED', 'Aborted due to critical failure in load_from_s3.');
        RETURN;
    END;

    BEGIN
        CALL insert_derived_odds();
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('insert_derived_odds', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('insert_derived_odds', 'FAILED', log_message);
    END;

    BEGIN
        CALL insert_odds_by_team();
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('insert_odds_by_team', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('insert_odds_by_team', 'FAILED', log_message);
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

    BEGIN
        CALL export_rosters_to_s3();
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('export_rosters_to_s3', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('export_rosters_to_s3', 'FAILED', log_message);
    END;

    BEGIN
        CALL export_players_to_s3();
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('export_players_to_s3', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('export_players_to_s3', 'FAILED', log_message);
    END;

    INSERT INTO etl.job_logs (procedure_name, status, message)
    VALUES ('transform_raw_data', 'COMPLETED', 'Main job finished. Check individual step logs for details.');

END;
$$;