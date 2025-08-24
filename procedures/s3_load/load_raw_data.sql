CREATE OR REPLACE PROCEDURE load_from_s3()
LANGUAGE plpgsql
AS $$
DECLARE
    league_year INTEGER;
    playing_season INTEGER;
    log_message TEXT;
BEGIN
  INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('load_from_s3', 'STARTED', 'S3 load process initiated');

  league_year := get_nfl_league_year();
  playing_season := get_nfl_playing_season();

  CREATE EXTENSION IF NOT EXISTS aws_s3 CASCADE;

  BEGIN
      CALL import_play_by_play_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_play_by_play_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_play_by_play_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_weekly_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_weekly_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_weekly_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_injury_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_injury_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_injury_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_rushing_next_gen_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_rushing_next_gen_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_rushing_next_gen_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_receiving_next_gen_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_receiving_next_gen_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_receiving_next_gen_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_passing_next_gen_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_passing_next_gen_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_passing_next_gen_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_depth_charts_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_depth_charts_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_depth_charts_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_rushing_pro_football_reference_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_rushing_pro_football_reference_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_rushing_pro_football_reference_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_receiving_pro_football_reference_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_receiving_pro_football_reference_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_receiving_pro_football_reference_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_passing_pro_football_reference_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_passing_pro_football_reference_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_passing_pro_football_reference_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_snaps_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_snaps_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_snaps_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_rosters_data(league_year);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_rosters_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_rosters_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_ftn_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_ftn_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_ftn_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_player_data();
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_player_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_player_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_combine_data(playing_season);
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_combine_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_combine_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_odds_data();
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_odds_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_odds_data', 'FAILED', log_message);
  END;

  BEGIN
      CALL import_player_ids_data();
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_player_ids_data', 'COMPLETED', 'Success');
  EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
      INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_player_ids_data', 'FAILED', log_message);
  END;

END;
$$;