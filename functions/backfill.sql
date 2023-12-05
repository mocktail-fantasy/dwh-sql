CREATE OR REPLACE FUNCTION backfill_from_s3()
RETURNS void AS $$
DECLARE
    season INTEGER;
BEGIN
	
	-- play by play
	-- weekly
  FOR season IN 1999..2022 LOOP
    PERFORM import_play_by_play_data(season);
    PERFORM import_weekly_data(season);
  END LOOP;
  
  -- injury data
  FOR season IN 2009..2022 LOOP
  PERFORM import_injury_data(season);
  END LOOP;

  -- next gen stats
  FOR season IN 2016..2022 LOOP
    PERFORM import_rushing_next_gen_data(season);
    PERFORM import_receiving_next_gen_data(season);
    PERFORM import_passing_next_gen_data(season);
  END LOOP;
  
  -- depth chart data
  FOR season IN 2001..2022 LOOP
    PERFORM import_depth_charts_data(season);
  END LOOP;
  
  -- pro football reference data
  FOR season IN 2018..2022 LOOP
    PERFORM import_rushing_pro_football_reference_data(season);
    PERFORM import_receiving_pro_football_reference_data(season);
    PERFORM import_passing_pro_football_reference_data(season);
  END LOOP;
  
  -- snaps data
  FOR season IN 2012..2022 LOOP
    PERFORM import_snaps_data(season);
  END LOOP;
  

  -- rosters
  FOR season IN 2002..2022 LOOP
    PERFORM import_rosters_data(season);
  END LOOP;
  
  -- ftn data
  PERFORM import_ftn_data(2022);

  -- player data
  PERFORM import_player_data();
      
  -- combine data
  PERFORM import_combine_data(season);

  -- odds
  PERFORM import_odds_data();
  
  -- odds
  PERFORM import_player_ids_data();

END;
$$ LANGUAGE plpgsql;