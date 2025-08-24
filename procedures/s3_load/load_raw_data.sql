CREATE OR REPLACE PROCEDURE load_from_s3()
LANGUAGE plpgsql
AS $$
DECLARE
    season INTEGER;
BEGIN

  CREATE EXTENSION IF NOT EXISTS aws_s3 CASCADE;

  SELECT EXTRACT(YEAR FROM NOW()) INTO season;

  CALL import_play_by_play_data(season);
  CALL import_weekly_data(season);
  CALL import_injury_data(season);
  CALL import_rushing_next_gen_data(season);
  CALL import_receiving_next_gen_data(season);
  CALL import_passing_next_gen_data(season);
  CALL import_depth_charts_data(season);
  CALL import_rushing_pro_football_reference_data(season);
  CALL import_receiving_pro_football_reference_data(season);
  CALL import_passing_pro_football_reference_data(season);
  CALL import_snaps_data(season);
  CALL import_rosters_data(season);
  CALL import_ftn_data(season);
  CALL import_player_data();
  CALL import_combine_data(season);
  CALL import_odds_data();
  CALL import_player_ids_data();

END;
$$;