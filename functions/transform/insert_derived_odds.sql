CREATE OR REPLACE PROCEDURE insert_derived_odds() AS $$
BEGIN
    INSERT INTO games.derived_odds (
        SELECT
            game_id,
            season,
            game_type,
            week,
            gameday,
            weekday,
            gametime,
            home_team,
            away_team as favored_team,
            home_team as underdog_team,
            abs(spread_line) as spread_line,
            total_line,
            (total_line / 2) - (spread_line/2) as favored_projected_total,
            (total_line / 2) + (spread_line/2) as underdog_projected_total,
            away_score as favored_actual,
            home_score as underdog_actual,
            total,
            CASE
                WHEN away_score > home_score THEN 'win'
                WHEN away_score < home_score THEN 'lose'
                WHEN home_score = away_score THEN 'tie'
            END AS ml_result,
            CASE
                WHEN (away_score - home_score) > abs(spread_line) THEN 'cover'
                WHEN (away_score - home_score) < abs(spread_line) THEN 'non-cover'
                WHEN (away_score - home_score) = abs(spread_line) THEN 'push'
            END AS spread_result,
            abs(result) as margin_of_victory,
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
            away_rest as favored_rest,
            home_rest as underdog_rest,
            away_moneyline as favored_moneyline,
            home_moneyline as underdog_monelyline,
            away_spread_odds as favored_spread_odds,
            home_spread_odds as underdog_spread_odds,
            under_odds,
            over_odds,
            div_game,
            roof,
            surface,
            "temp",
            wind,
            away_qb_id as favored_qb_id,
            home_qb_id as underdog_qb_id,
            away_qb_name as favored_qb_id,
            home_qb_name as underdog_qb_id,
            away_coach as favored_coach,
            home_coach as underdog_coach,
            referee,
            stadium_id,
            stadium
        FROM raw.odds
        WHERE spread_line < 0
        AND result IS NOT NULL
        AND insert_date = (SELECT MAX(insert_date) FROM raw.odds)

      	UNION

        SELECT
            game_id,
            season,
            game_type,
            week,
            gameday,
            weekday,
            gametime,
            home_team,
            home_team as favored_team,
            away_team as underdog_team,
            spread_line,
            total_line,
            (total_line / 2) + (spread_line/2) as favored_projected_total,
            (total_line / 2) - (spread_line/2) as underdog_projected_total,
            home_score as favored_actual,
            away_score as underdog_actual,
            total,
            CASE
                WHEN home_score > away_score THEN 'win'
                WHEN home_score < away_score THEN 'lose'
                WHEN home_score = away_score THEN 'tie'
            END AS ml_result,
            CASE
                WHEN (home_score - away_score) > spread_line THEN 'cover'
                WHEN (home_score - away_score) < spread_line THEN 'non-cover'
                WHEN (home_score - away_score) = abs(spread_line) THEN 'push'
            END AS spread_result,
            abs(result) as margin_of_victory,
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
            home_rest as favored_rest,
            away_rest as underdog_rest,
            home_moneyline as favored_moneyline,
            away_moneyline as underdog_monelyline,
            home_spread_odds as favored_spread_odds,
            away_spread_odds as underdog_spread_odds,
            under_odds,
            over_odds,
            div_game,
            roof,
            surface,
            "temp",
            wind,
            home_qb_id as favored_qb_id,
            away_qb_id as underdog_qb_id,
            home_qb_name as favored_qb_name,
            away_qb_name as underdog_qb_name,
            home_coach as favored_coach,
            away_coach as underdog_coach,
            referee,
            stadium_id,
            stadium
        FROM raw.odds
        WHERE spread_line >= 0
        AND result IS NOT NULL
        AND insert_date = (SELECT MAX(insert_date) FROM raw.odds)
    )
    ON CONFLICT(game_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;
