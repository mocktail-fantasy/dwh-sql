CREATE OR REPLACE PROCEDURE load_annual_player_stats()
LANGUAGE plpgsql
AS $$
DECLARE table_is_empty BOOLEAN;

current_season INT;

BEGIN
SELECT
    NOT EXISTS (
        SELECT
            1
        FROM
            players.annual_regular_season_stats
        LIMIT
            1
    ) INTO table_is_empty;
    
-- If the table hasnt been populated yet then do the initial load otherwise only update current season.

IF NOT table_is_empty THEN
INSERT INTO
    players.annual_regular_season_stats
SELECT
    s.player_id,
    s.player_name,
    s.player_display_name,
    s.position_group,
    s.season,
    COUNT(s.week) as games_played,
    SUM(s.completions) as completions,
    SUM(s.attempts) as attempts,
    SUM(s.passing_yards) as passing_yards,
    SUM(s.passing_tds) as passing_tds,
    SUM(s.interceptions) as interceptions,
    SUM(s.sacks) as sacks,
    SUM(s.sack_yards) as sack_yards,
    SUM(s.sack_fumbles) as sack_fumbles,
    SUM(s.sack_fumbles_lost) as sack_fumbles_lost,
    SUM(s.passing_air_yards) as passing_air_yards,
    SUM(s.passing_yards_after_catch) as passing_yards_after_catch,
    SUM(s.passing_first_downs) as passing_first_downs,
    SUM(s.passing_epa) as passing_epa,
    SUM(s.passing_2pt_conversions) as passing_2pt_conversions,
    SUM(s.carries) as carries,
    SUM(s.rushing_yards) as rushing_yards,
    SUM(s.rushing_tds) as rushing_tds,
    SUM(s.rushing_fumbles) as rushing_fumbles,
    SUM(s.rushing_fumbles_lost) as rushing_fumbles_lost,
    SUM(s.rushing_first_downs) as rushing_first_downs,
    SUM(s.rushing_epa) as rushing_epa,
    SUM(s.rushing_2pt_conversions) as rushing_2pt_conversions,
    SUM(s.receptions) as receptions,
    SUM(s.targets) as targets,
    SUM(s.receiving_yards) as receiving_yards,
    SUM(s.receiving_tds) as receiving_tds,
    SUM(s.receiving_fumbles) as receiving_fumbles,
    SUM(s.receiving_fumbles_lost) as receiving_fumbles_lost,
    SUM(s.receiving_air_yards) as receiving_air_yards,
    SUM(s.receiving_yards_after_catch) as receiving_yards_after_catch,
    SUM(s.receiving_first_downs) as receiving_first_downs,
    SUM(s.receiving_epa) as receiving_epa,
    SUM(s.receiving_2pt_conversions) as receiving_2pt_conversions,
    AVG(s.target_share) as target_share,
    AVG(s.air_yards_share) as air_yards_share,
    SUM(s.special_teams_tds) as special_teams_tds,
    SUM(s.fantasy_points) as fantasy_points,
    SUM(s.fantasy_points_ppr) as fantasy_points_ppr
FROM
    players.annual_regular_season_stats s
GROUP BY
    s.player_id,
    s.player_name,
    s.player_display_name,
    s.position_group,
    s.season;

ELSE
SELECT
    MAX(season) INTO current_season
FROM
    players.annual_regular_season_stats;

DELETE FROM players.player_stats_annual_regular_season
WHERE
    season = current_season;

INSERT INTO
    players.player_stats_annual_regular_season
SELECT
    s.player_id,
    s.player_name,
    s.player_display_name,
    s.position_group,
    s.season,
    COUNT(s.week) as games_played,
    SUM(s.completions) as completions,
    SUM(s.attempts) as attempts,
    SUM(s.passing_yards) as passing_yards,
    SUM(s.passing_tds) as passing_tds,
    SUM(s.interceptions) as interceptions,
    SUM(s.sacks) as sacks,
    SUM(s.sack_yards) as sack_yards,
    SUM(s.sack_fumbles) as sack_fumbles,
    SUM(s.sack_fumbles_lost) as sack_fumbles_lost,
    SUM(s.passing_air_yards) as passing_air_yards,
    SUM(s.passing_yards_after_catch) as passing_yards_after_catch,
    SUM(s.passing_first_downs) as passing_first_downs,
    SUM(s.passing_epa) as passing_epa,
    SUM(s.passing_2pt_conversions) as passing_2pt_conversions,
    SUM(s.carries) as carries,
    SUM(s.rushing_yards) as rushing_yards,
    SUM(s.rushing_tds) as rushing_tds,
    SUM(s.rushing_fumbles) as rushing_fumbles,
    SUM(s.rushing_fumbles_lost) as rushing_fumbles_lost,
    SUM(s.rushing_first_downs) as rushing_first_downs,
    SUM(s.rushing_epa) as rushing_epa,
    SUM(s.rushing_2pt_conversions) as rushing_2pt_conversions,
    SUM(s.receptions) as receptions,
    SUM(s.targets) as targets,
    SUM(s.receiving_yards) as receiving_yards,
    SUM(s.receiving_tds) as receiving_tds,
    SUM(s.receiving_fumbles) as receiving_fumbles,
    SUM(s.receiving_fumbles_lost) as receiving_fumbles_lost,
    SUM(s.receiving_air_yards) as receiving_air_yards,
    SUM(s.receiving_yards_after_catch) as receiving_yards_after_catch,
    SUM(s.receiving_first_downs) as receiving_first_downs,
    SUM(s.receiving_epa) as receiving_epa,
    SUM(s.receiving_2pt_conversions) as receiving_2pt_conversions,
    AVG(s.target_share) as target_share,
    AVG(s.air_yards_share) as air_yards_share,
    SUM(s.special_teams_tds) as special_teams_tds,
    SUM(s.fantasy_points) as fantasy_points,
    SUM(s.fantasy_points_ppr) as fantasy_points_ppr
FROM
    players.annual_regular_season_stats s
WHERE
    s.season = current_season
GROUP BY
    s.player_id,
    s.player_name,
    s.player_display_name,
    s.position_group,
    s.season;

END IF;
END;
$$;