CREATE TABLE IF NOT EXISTS players.active_rosters (
    season INT,
    team VARCHAR(10),
    current_week INT,
    pos VARCHAR(10),
    jersey_number INT,
    football_name VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birth_date DATE,
    height_inches NUMERIC(5, 2),
    weight NUMERIC(5, 2),
    gsis_id VARCHAR(20),
    sleeper_id TEXT,
    headshot_url TEXT,
    player_age INT
);