-- Full historical load. Run manually on first setup or to rebuild from scratch.
-- Assumes all CSV files are present in /data/ from a prior sync initialize run.
CREATE OR REPLACE PROCEDURE backfill_raw_data()
LANGUAGE plpgsql
AS $$
DECLARE
    season INTEGER;
BEGIN

    FOR season IN 1999..2025 LOOP
        CALL import_play_by_play_data(season);
        CALL import_weekly_data(season);
    END LOOP;

    FOR season IN 2018..2025 LOOP
        CALL import_rushing_pro_football_reference_data(season);
        CALL import_receiving_pro_football_reference_data(season);
        CALL import_passing_pro_football_reference_data(season);
    END LOOP;

    FOR season IN 2012..2025 LOOP
        CALL import_snaps_data(season);
    END LOOP;

    FOR season IN 2022..2025 LOOP
        CALL import_ftn_data(season);
    END LOOP;

    FOR season IN 2002..2025 LOOP
        CALL import_rosters_data(season);
    END LOOP;

    CALL import_player_data();
    CALL import_combine_data();
    CALL import_odds_data();
    CALL import_player_ids_data();
    CALL import_rushing_next_gen_data();
    CALL import_receiving_next_gen_data();
    CALL import_passing_next_gen_data();

END;
$$;
