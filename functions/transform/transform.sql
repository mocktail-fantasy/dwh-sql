CREATE OR REPLACE PROCEDURE transform_raw_data() AS $$
BEGIN
    -- Call other stored procedures or functions as needed
    CALL load_from_s3();
    CALL insert_derived_odds();
    CALL insert_odds_by_team();
    CALL refresh_active_rosters();
    CALL load_weekly_player_stats();
    CALL load_annual_player_stats();


END;
$$ LANGUAGE plpgsql;