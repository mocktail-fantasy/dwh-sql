# NFL Data Warehouse

A local PostgreSQL data warehouse for NFL analytics, sourced from [nflverse](https://github.com/nflverse/nflverse-data). Covers play-by-play, weekly and annual player stats, betting odds, rosters, next-gen stats, and more — from 1999 through the current season.

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (includes both Docker and Docker Compose)
- `psql` command-line client (for connecting directly in the terminal — optional if you use a GUI)

---

## First-Time Setup

### 1. Download the CSV data

The database loads from local CSV files. Run the sync container to download all historical data from nflverse:

```bash
docker compose run --rm nfl-sync python sync.py initialize
```

This will populate the `./data/` directory with all datasets. It will take several minutes depending on your connection.

### 2. Start the database

```bash
docker compose up postgres
```

On the **first start**, the database auto-initializes:
- Creates all schemas, tables, functions, procedures, and views
- Loads all historical CSV data (backfill — 1999 to present)
- Runs the initial transforms: active rosters, weekly stats, and annual stats

Watch the logs. When you see:

```
>>> Initialization complete
```

the database is ready. This can take 10–30 minutes depending on your machine.

> **On subsequent starts**, `docker compose up postgres` simply restores your existing data from the named volume — no re-initialization.

### 3. Connect to the database

**Terminal (psql):**
```bash
./scripts/connect-db.sh
```

**GUI (TablePlus, DBeaver, DataGrip, etc.):**

| Field    | Value       |
|----------|-------------|
| Host     | `localhost` |
| Port     | `5432`      |
| Database | `nfl`       |
| Username | `postgres`  |
| Password | `postgres`  |

---

## Keeping Data Current

Run these two steps at the start of each week during the season:

**Step 1 — Download the latest CSVs:**
```bash
docker compose run --rm nfl-sync python sync.py update
```

**Step 2 — Load the new data and refresh all stats:**
```bash
docker compose exec postgres psql -U postgres -d nfl -c "CALL etl.run_etl();"
```

The ETL procedure loads new raw data, refreshes active rosters, and updates both weekly and annual player stats. Check the results in the log table:

```sql
SELECT * FROM etl.job_logs ORDER BY created_at DESC LIMIT 20;
```

---

## Resetting the Database

To wipe all data and start fresh (re-runs full initialization on next start):

```bash
docker compose down -v
docker compose up postgres
```

> The `-v` flag removes the named volume. All data will be reloaded from the CSV files on the next start.

---

## Schema Overview

| Schema         | Purpose                                              |
|----------------|------------------------------------------------------|
| `raw`          | Raw data loaded directly from CSV — source of truth  |
| `players`      | Cleaned, transformed player stats and rosters        |
| `player_views` | Joined views for player lookups                      |
| `games`        | Derived game-level tables (odds, spreads, totals)    |
| `game_views`   | Aggregated views for game analysis                   |
| `etl`          | Job logs for monitoring ETL runs                     |

---

## Tables Reference

### `raw` schema — source data

| Table | Description | Years Available |
|---|---|---|
| `raw.play_by_play` | Every play from every game | 1999–present |
| `raw.weekly` | Player stats per game week (115 columns) | 1999–present |
| `raw.rosters` | Weekly team rosters | 2002–present |
| `raw.players` | Player biographical and status data | Current |
| `raw.player_ids` | Cross-platform player ID mapping (Sleeper, ESPN, Yahoo, etc.) | Current |
| `raw.rushing_next_gen_stats` | NGS rushing metrics (efficiency, time to LOS, yards over expected) | 2016–present |
| `raw.receiving_next_gen_stats` | NGS receiving metrics (cushion, separation, YAC above expected) | 2016–present |
| `raw.passing_next_gen_stats` | NGS passing metrics (time to throw, aggressiveness, completion % above expected) | 2016–present |
| `raw.rushing_pro_football_reference` | PFR rushing data | 2018–present |
| `raw.receiving_pro_football_reference` | PFR receiving data | 2018–present |
| `raw.passing_pro_football_reference` | PFR passing data | 2018–present |
| `raw.snaps` | Offensive and defensive snap counts | 2012–present |
| `raw.ftn` | FTN charting data | 2022–present |
| `raw.depth_charts` | Team depth charts by week | 2001–present |
| `raw.odds` | Game-level betting lines, spreads, totals, and results | Historical |
| `raw.combine` | NFL combine measurements | Historical |
| `raw.injuries` | Weekly injury reports | Historical |

### `players` schema — transformed data

| Table | Description | Primary Key |
|---|---|---|
| `players.weekly_regular_season_stats` | Per-game stats for QB/WR/RB/TE/K (regular season) | `player_id, season, week` |
| `players.weekly_postseason_stats` | Per-game stats for QB/WR/RB/TE/K (playoffs) | `player_id, season, week` |
| `players.annual_regular_season_stats` | Season totals aggregated from weekly stats | `player_id, season` |
| `players.active_rosters` | Current week's active roster (ACT status only, skill positions) | — |

### `games` schema — derived game data

| Table | Description | Primary Key |
|---|---|---|
| `games.derived_odds` | Odds reframed from the favored team's perspective, with cover/ML/total results | `game_id` |
| `games.odds_by_team` | Odds from each team's perspective (one row per team per game) | `game_id, team` |

---

## Views Reference

### `player_views.players`
Full player lookup joining `raw.players` with `raw.player_ids`. Includes biographical data, position, status, draft info, and cross-platform IDs (Sleeper, ESPN, Yahoo, FantasyPros, PFR, PFF, etc.).

```sql
SELECT gsis_id, display_name, position, latest_team, draft_year, draft_round, draft_pick
FROM player_views.players
WHERE latest_team = 'KC';
```

### `game_views.over_under_frequency`
Aggregated over/under hit rates by total line. Useful for understanding how often a given total goes over, under, or pushes historically.

```sql
SELECT total_line, total_occurences, over_percentage, under_percentage, push_percentage
FROM game_views.over_under_frequency
ORDER BY total_line;
```

### `game_views.qb_wins`
Win/loss/tie records for every QB broken down by game type (Regular/Playoff) and time slot (PrimeTime/Regular) from both home and away perspectives.

```sql
SELECT qb_name, game_type, play_time, location, wins, loses, ties
FROM game_views.qb_wins
WHERE qb_name = 'P.Mahomes'
ORDER BY game_type, play_time;
```

---

## Stored Procedures Reference

### ETL & Loading

**`CALL etl.run_etl()`**
The main weekly update procedure. Runs the full pipeline in sequence:
1. `load_raw_data()` — loads current season CSVs into raw tables
2. `refresh_active_rosters()` — rebuilds the active roster snapshot
3. `load_weekly_player_stats()` — upserts weekly player stats (REG + POST)
4. `load_annual_player_stats()` — recalculates current season annual totals

**`CALL backfill_raw_data()`**
Full historical load — runs automatically on first init. Can be called manually to reload all raw tables from scratch. Expects all CSV files to already be present in `./data/`.

**`CALL load_raw_data()`**
Loads just the current season's raw data (incremental update, called by `etl.run_etl()`).

### Transforms

**`CALL refresh_active_rosters()`**
Truncates and rebuilds `players.active_rosters` from the most recent week in `raw.rosters`. Only includes active (ACT status) players at skill positions (QB, WR, RB, TE, K).

**`CALL load_weekly_player_stats()`**
Reads from `raw.weekly` and upserts into `players.weekly_regular_season_stats` and `players.weekly_postseason_stats`. Player names and position come from `raw.players` (joined on `gsis_id`) to ensure consistency. Skips rows on conflict (`player_id, season, week`).

**`CALL load_annual_player_stats()`**
Aggregates `players.weekly_regular_season_stats` into `players.annual_regular_season_stats`. Smart incremental: on first run loads all seasons; on subsequent runs deletes and reloads only the current season.

**`CALL insert_derived_odds()`**
Populates `games.derived_odds` from `raw.odds`, reframing each game from the favored team's perspective with derived spread/ML/total results.

**`CALL insert_odds_by_team()`**
Populates `games.odds_by_team` from `raw.odds` — one row per team per game, with spread, projected total, and result from that team's point of view. Upserts on conflict.

### Monitoring

```sql
-- View all recent ETL activity
SELECT procedure_name, status, message, created_at
FROM etl.job_logs
ORDER BY created_at DESC
LIMIT 50;

-- Check for any failures
SELECT * FROM etl.job_logs WHERE status = 'FAILED';
```

---

## Functions Reference

**`get_nfl_playing_season()`** → `INTEGER`
Returns the current NFL playing season year. Returns the prior year if the current month is before September (since the season runs Sep–Feb).

```sql
SELECT get_nfl_playing_season();  -- e.g. returns 2025 during the 2025 season
```

**`get_nfl_league_year()`** → `INTEGER`
Returns the current NFL league year. Returns the prior year if the current month is before March (accounts for the league year turning over in March).

```sql
SELECT get_nfl_league_year();
```

---

## Example Queries

```sql
-- Top 10 receivers by PPR points in 2024
SELECT player_name, SUM(fantasy_points_ppr) AS ppr_points
FROM players.annual_regular_season_stats
WHERE season = 2024 AND position_group = 'WR'
ORDER BY ppr_points DESC
LIMIT 10;

-- Josh Allen's weekly stats in 2024
SELECT week, passing_yards, passing_tds, interceptions, rushing_yards, fantasy_points_ppr
FROM players.weekly_regular_season_stats
WHERE player_id = (SELECT gsis_id FROM player_views.players WHERE display_name = 'Josh Allen')
  AND season = 2024
ORDER BY week;

-- Over/under hit rate for totals between 44 and 48
SELECT total_line, total_occurences, over_percentage, under_percentage
FROM game_views.over_under_frequency
WHERE total_line BETWEEN 44 AND 48
ORDER BY total_line;

-- Active Chiefs roster
SELECT pos, football_name, player_age, jersey_number
FROM players.active_rosters
WHERE team = 'KC'
ORDER BY pos, football_name;
```
