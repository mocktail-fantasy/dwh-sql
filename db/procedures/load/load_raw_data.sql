-- Individual import procedures
-- Year-based datasets use EXECUTE + format() for dynamic path construction.
-- Static datasets use a direct COPY with a literal path.

CREATE OR REPLACE PROCEDURE import_play_by_play_data(season INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY raw.play_by_play FROM %L WITH (FORMAT csv, HEADER true)',
        '/data/play_by_play/' || season || '.csv');
END;
$$;

CREATE OR REPLACE PROCEDURE import_weekly_data(season INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    path text := '/data/weekly/' || season || '.csv';
    header text;
BEGIN
    -- Detect whether this file includes the game_id column (present in some years).
    -- Files without game_id have 114 columns; files with game_id have 115.
    header := pg_read_file(path, 0, 2000);
    header := split_part(header, E'\n', 1);

    IF position('game_id' IN header) > 0 THEN
        EXECUTE format('COPY raw.weekly FROM %L WITH (FORMAT csv, HEADER true)', path);
    ELSE
        EXECUTE format(
            'COPY raw.weekly (player_id, player_name, player_display_name, position, position_group, headshot_url, season, week, season_type, team, opponent_team, completions, attempts, passing_yards, passing_tds, passing_interceptions, sacks_suffered, sack_yards_lost, sack_fumbles, sack_fumbles_lost, passing_air_yards, passing_yards_after_catch, passing_first_downs, passing_epa, passing_cpoe, passing_2pt_conversions, pacr, carries, rushing_yards, rushing_tds, rushing_fumbles, rushing_fumbles_lost, rushing_first_downs, rushing_epa, rushing_2pt_conversions, receptions, targets, receiving_yards, receiving_tds, receiving_fumbles, receiving_fumbles_lost, receiving_air_yards, receiving_yards_after_catch, receiving_first_downs, receiving_epa, receiving_2pt_conversions, racr, target_share, air_yards_share, wopr, special_teams_tds, def_tackles_solo, def_tackles_with_assist, def_tackle_assists, def_tackles_for_loss, def_tackles_for_loss_yards, def_fumbles_forced, def_sacks, def_sack_yards, def_qb_hits, def_interceptions, def_interception_yards, def_pass_defended, def_tds, def_fumbles, def_safeties, misc_yards, fumble_recovery_own, fumble_recovery_yards_own, fumble_recovery_opp, fumble_recovery_yards_opp, fumble_recovery_tds, penalties, penalty_yards, punt_returns, punt_return_yards, kickoff_returns, kickoff_return_yards, fg_made, fg_att, fg_missed, fg_blocked, fg_long, fg_pct, fg_made_0_19, fg_made_20_29, fg_made_30_39, fg_made_40_49, fg_made_50_59, fg_made_60_, fg_missed_0_19, fg_missed_20_29, fg_missed_30_39, fg_missed_40_49, fg_missed_50_59, fg_missed_60_, fg_made_list, fg_missed_list, fg_blocked_list, fg_made_distance, fg_missed_distance, fg_blocked_distance, pat_made, pat_att, pat_missed, pat_blocked, pat_pct, gwfg_made, gwfg_att, gwfg_missed, gwfg_blocked, gwfg_distance, fantasy_points, fantasy_points_ppr) FROM %L WITH (FORMAT csv, HEADER true)',
            path);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE import_rushing_next_gen_data()
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY raw.rushing_next_gen_stats FROM %L WITH (FORMAT csv, HEADER true)',
        '/data/rushing_next_gen_stats/rushing_next_gen_stats.csv');
END;
$$;

CREATE OR REPLACE PROCEDURE import_receiving_next_gen_data()
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY raw.receiving_next_gen_stats FROM %L WITH (FORMAT csv, HEADER true)',
        '/data/receiving_next_gen_stats/receiving_next_gen_stats.csv');
END;
$$;

CREATE OR REPLACE PROCEDURE import_passing_next_gen_data()
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY raw.passing_next_gen_stats FROM %L WITH (FORMAT csv, HEADER true)',
        '/data/passing_next_gen_stats/passing_next_gen_stats.csv');
END;
$$;

CREATE OR REPLACE PROCEDURE import_rushing_pro_football_reference_data(season INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY raw.rushing_pro_football_reference FROM %L WITH (FORMAT csv, HEADER true)',
        '/data/rushing_pro_football_reference/' || season || '.csv');
END;
$$;

CREATE OR REPLACE PROCEDURE import_receiving_pro_football_reference_data(season INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY raw.receiving_pro_football_reference FROM %L WITH (FORMAT csv, HEADER true)',
        '/data/receiving_pro_football_reference/' || season || '.csv');
END;
$$;

CREATE OR REPLACE PROCEDURE import_passing_pro_football_reference_data(season INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY raw.passing_pro_football_reference FROM %L WITH (FORMAT csv, HEADER true)',
        '/data/passing_pro_football_reference/' || season || '.csv');
END;
$$;

CREATE OR REPLACE PROCEDURE import_snaps_data(season INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY raw.snaps FROM %L WITH (FORMAT csv, HEADER true)',
        '/data/snaps/' || season || '.csv');
END;
$$;

CREATE OR REPLACE PROCEDURE import_ftn_data(season INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY raw.ftn FROM %L WITH (FORMAT csv, HEADER true)',
        '/data/ftn/' || season || '.csv');
END;
$$;

CREATE OR REPLACE PROCEDURE import_rosters_data(season INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY raw.rosters FROM %L WITH (FORMAT csv, HEADER true)',
        '/data/rosters/' || season || '.csv');
END;
$$;

CREATE OR REPLACE PROCEDURE import_player_data()
LANGUAGE plpgsql AS $$
BEGIN
    COPY raw.players FROM '/data/players/players.csv' WITH (FORMAT csv, HEADER true);
END;
$$;

CREATE OR REPLACE PROCEDURE import_combine_data()
LANGUAGE plpgsql AS $$
BEGIN
    COPY raw.combine FROM '/data/combine/combine.csv' WITH (FORMAT csv, HEADER true);
END;
$$;

CREATE OR REPLACE PROCEDURE import_odds_data()
LANGUAGE plpgsql AS $$
BEGIN
    COPY raw.odds FROM '/data/odds/odds.csv' WITH (FORMAT csv, HEADER true);
END;
$$;

CREATE OR REPLACE PROCEDURE import_player_ids_data()
LANGUAGE plpgsql AS $$
BEGIN
    COPY raw.player_ids FROM '/data/player_ids/player_ids.csv' WITH (FORMAT csv, HEADER true);
END;
$$;


-- Orchestrator: loads current season data into raw tables.
-- Called by etl.run_etl() on each manual refresh.
CREATE OR REPLACE PROCEDURE load_raw_data()
LANGUAGE plpgsql
AS $$
DECLARE
    league_year    INTEGER;
    playing_season INTEGER;
    log_message    TEXT;
BEGIN
    INSERT INTO etl.job_logs (procedure_name, status, message)
    VALUES ('load_raw_data', 'STARTED', 'Raw data load initiated');

    league_year    := get_nfl_league_year();
    playing_season := get_nfl_playing_season();

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
        CALL import_ftn_data(playing_season);
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_ftn_data', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_ftn_data', 'FAILED', log_message);
    END;

    BEGIN
        CALL import_rosters_data(league_year);
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_rosters_data', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_rosters_data', 'FAILED', log_message);
    END;

    BEGIN
        CALL import_player_data();
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_player_data', 'COMPLETED', 'Success');
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS log_message = MESSAGE_TEXT;
        INSERT INTO etl.job_logs (procedure_name, status, message) VALUES ('import_player_data', 'FAILED', log_message);
    END;

    BEGIN
        CALL import_combine_data();
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
