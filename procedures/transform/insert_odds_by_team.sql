CREATE OR REPLACE PROCEDURE public.insert_odds_by_team()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
insert into games.odds_by_team (
    	-- Away Games
        SELECT
            game_id,
            season,
            game_type,
            week,
            gameday,
            weekday,
            gametime,
            away_team as team,
            'Away' as location,
            home_team as opponent,
            spread_line as spread,
            total_line,
            (total_line / 2) - (spread_line/2) as projected_total,
            (total_line / 2) + (spread_line/2) as opponent_projected_total,
            away_score as actual_score,
            home_score as opponent_actual,
            total,
            CASE
                WHEN away_score > home_score THEN 'win'
                WHEN away_score < home_score THEN 'lose'
                WHEN home_score = away_score THEN 'tie'
            END AS game_result,
            CASE
                WHEN (home_score - away_score) < spread_line THEN 'cover'
                WHEN (home_score - away_score) > spread_line THEN 'non-cover'
                WHEN (home_score - away_score) = spread_line THEN 'push'
            END AS spread_result,
            -result as margin_of_victory,
            CASE
                WHEN total > total_line THEN 'over'
                WHEN total < total_line THEN 'under'
                WHEN total = total_line THEN 'push'
            END AS total_result,
            CASE
                WHEN "location" != 'Home' THEN TRUE
                ELSE FALSE
            END AS is_neutral,
            overtime,
            old_game_id,
            gsis,
            nfl_detail_id,
            pfr,
            pff,
            espn,
            ftn,
            away_rest as rest,
            home_rest as opponent_rest,
            away_moneyline as moneyline,
            home_moneyline as opponent_monelyline,
            away_spread_odds as spread_odds,
            home_spread_odds as opponent_spread_odds,
            under_odds,
            over_odds,
            div_game,
            roof,
            surface,
            "temp",
            wind,
            away_qb_id as qb_id,
            home_qb_id as opponent_qb_id,
            away_qb_name as qb_name,
            home_qb_name as opponenet_qb_name,
            away_coach as coach,
            home_coach as opponent_coach,
            referee,
            stadium_id,
            stadium
        FROM raw.odds
        where result IS NOT NULL
        AND insert_date = (SELECT MAX(insert_date) FROM raw.odds)

      	UNION
		-- Home games
        SELECT
            game_id,
            season,
            game_type,
            week,
            gameday,
            weekday,
            gametime,
            home_team as team,
            'Home' as location,
            away_team as opponent_team,
            -spread_line as spread,
            total_line,
            (total_line / 2) + (spread_line/2) as projected_total,
            (total_line / 2) - (spread_line/2) as opponent_projected_total,
            home_score as actual_score,
            away_score as opponent_actual,
            total,
            CASE
                WHEN home_score > away_score THEN 'win'
                WHEN home_score < away_score THEN 'lose'
                WHEN home_score = away_score THEN 'tie'
            END AS game_result,
            CASE
                WHEN (home_score - away_score) > spread_line THEN 'cover'
                WHEN (home_score - away_score) < spread_line THEN 'non-cover'
                WHEN (home_score - away_score) = spread_line THEN 'push'
            END AS spread_result,
            result as margin_of_victory,
            CASE
                WHEN total > total_line THEN 'over'
                WHEN total < total_line THEN 'under'
                WHEN total = total_line THEN 'push'
            END AS total_result,
            CASE when "location" != 'Home' then true else false end as is_neutral,
            overtime,
            old_game_id,
            gsis,
            nfl_detail_id,
            pfr,
            pff,
            espn,
            ftn,
            home_rest as rest,
            away_rest as opponent_rest,
            home_moneyline as moneyline,
            away_moneyline as opponent_monelyline,
            home_spread_odds as spread_odds,
            away_spread_odds as opponent_spread_odds,
            under_odds,
            over_odds,
            div_game,
            roof,
            surface,
            "temp",
            wind,
            home_qb_id as qb_id,
            away_qb_id as opponent_qb_id,
            home_qb_name as qb_name,
            away_qb_name as opponent_qb_name,
            home_coach as coach,
            away_coach as opponent_coach,
            referee,
            stadium_id,
            stadium
        FROM raw.odds
        where result IS NOT NULL
        AND insert_date = (SELECT MAX(insert_date) FROM raw.odds)
)
on conflict(game_id, team) do UPDATE
SET 
    moneyline = EXCLUDED.moneyline,
    opponent_monelyline = EXCLUDED.opponent_monelyline,
    spread_odds = EXCLUDED.spread_odds,
    opponent_spread_odds = EXCLUDED.opponent_spread_odds,
    under_odds = EXCLUDED.under_odds,
    over_odds = EXCLUDED.over_odds,
    spread = EXCLUDED.spread,
    total_line = EXCLUDED.total_line,
    projected_total = EXCLUDED.projected_total,
    opponent_projected_total = EXCLUDED.opponent_projected_total,
    actual_score = EXCLUDED.actual_score,
    opponent_actual = EXCLUDED.opponent_actual,
    game_result = EXCLUDED.game_result,
    spread_result = EXCLUDED.spread_result,
    margin_of_victory = EXCLUDED.margin_of_victory,
    total_result = EXCLUDED.total_result,
    overtime = EXCLUDED.overtime;
END;
$procedure$
;