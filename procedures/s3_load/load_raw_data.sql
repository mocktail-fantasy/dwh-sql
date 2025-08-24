CREATE OR REPLACE PROCEDURE load_from_s3()
LANGUAGE plpgsql
AS $$
DECLARE
    league_year INTEGER;
    playing_season INTEGER;
BEGIN

  league_year := get_nfl_league_year();
  playing_season := get_nfl_playing_season();

  CREATE EXTENSION IF NOT EXISTS aws_s3 CASCADE;

  CALL import_play_by_play_data(playing_season);
  CALL import_weekly_data(playing_season);
  CALL import_injury_data(playing_season);
  CALL import_rushing_next_gen_data(playing_season);
  CALL import_receiving_next_gen_data(playing_season);
  CALL import_passing_next_gen_data(playing_season);
  CALL import_depth_charts_data(playing_season);
  CALL import_rushing_pro_football_reference_data(playing_season);
  CALL import_receiving_pro_football_reference_data(playing_season);
  CALL import_passing_pro_football_reference_data(playing_season);
  CALL import_snaps_data(playing_season);
  CALL import_rosters_data(league_year);
  CALL import_ftn_data(playing_season);
  CALL import_player_data();
  CALL import_combine_data(playing_season);
  CALL import_odds_data();
  CALL import_player_ids_data();

END;
$$;