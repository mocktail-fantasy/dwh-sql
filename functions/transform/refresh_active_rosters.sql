CREATE OR REPLACE PROCEDURE refresh_active_rosters()
LANGUAGE plpgsql
AS $$
BEGIN
    TRUNCATE TABLE players.active_rosters;

    WITH most_recent AS (
      SELECT
        season::INT,
        COALESCE(week::INT, 0) AS week_coalesced
      FROM raw.rosters
      ORDER BY
        season::INT DESC,
        week::INT DESC
      LIMIT 1
    )

    INSERT INTO players.active_rosters (
        season,
        team,
        current_week,
        pos,
        jersey_number,
        football_name,
        first_name,
        last_name,
        birth_date,
        height_inches,
        weight,
        gsis_id,
        sleeper_id,
        headshot_url,
        player_age
    )
    SELECT
      ar.season::INT,
      ar.team,
      COALESCE(ar.week::INT, 0),
      ar."position",
      ar.jersey_number::INT,
      ar.football_name,
      ar.first_name,
      ar.last_name,
      ar.birth_date::DATE,
      ar.height::NUMERIC(5, 2),
      ar.weight::NUMERIC(5, 2),
      ar.gsis_id,
      ar.sleeper_id,
      ar.headshot_url,
      EXTRACT(YEAR FROM AGE(NOW(), ar.birth_date::DATE)) AS player_age
    FROM raw.rosters AS ar
    JOIN most_recent AS mr
      ON ar.season = mr.season
      AND COALESCE(ar.week, 0) = mr.week_coalesced
    WHERE
      ar."position" IN ('QB', 'WR', 'TE', 'RB', 'K')
      AND ar.status = 'ACT';
END;
$$;