CREATE OR REPLACE PROCEDURE transform_raw_data() AS $$
BEGIN
    -- Call other stored procedures or functions as needed
    -- For example:
    -- CALL some_other_stored_procedure();
    -- CALL another_function();
    CALL load_from_s3();
    CALL insert_derived_odds();
    CALL insert_odds_by_team();
    CALL refresh_active_rosters();


END;
$$ LANGUAGE plpgsql;