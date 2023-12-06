CREATE OR REPLACE VIEW game_views.over_under_frequency AS (
    SELECT
        *,
        (over::float /total_occurences::float) AS over_percentage,
        (under::float/total_occurences::float) under_percentage,
        (push::float/total_occurences::float) push_percentage FROM (
            SELECT
                total_line,
                COUNT(*) as total_occurences,
                SUM(CASE WHEN total_result = 'over' THEN 1 ELSE 0 END) AS over,
                SUM(CASE WHEN total_result = 'under' THEN 1 ELSE 0 END) AS under,
                SUM(CASE WHEN total_result = 'push' THEN 1 ELSE 0 END) AS push
            FROM games.derived_odds
            GROUP BY 1
    ) a
);