CREATE OR REPLACE FUNCTION load_from_s3()
RETURNS void AS $$
DECLARE
    season INTEGER;
BEGIN

	SELECT EXTRACT(YEAR FROM NOW()) INTO season;

  PERFORM import_play_by_play_data(season);
  PERFORM import_weekly_data(season);
  PERFORM import_injury_data(season);
  PERFORM import_rushing_next_gen_data(season);
  PERFORM import_receiving_next_gen_data(season);
  PERFORM import_passing_next_gen_data(season);
  PERFORM import_depth_charts_data(season);
  PERFORM import_rushing_pro_football_reference_data(season);
  PERFORM import_receiving_pro_football_reference_data(season);
  PERFORM import_passing_pro_football_reference_data(season);
  PERFORM import_snaps_data(season);
  PERFORM import_rosters_data(season);
  PERFORM import_ftn_data(season);
  PERFORM import_player_data();
  PERFORM import_combine_data(season);
  PERFORM import_odds_data();
  PERFORM import_player_ids_data();

END;
$$ LANGUAGE plpgsql;