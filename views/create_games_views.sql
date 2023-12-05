CREATE SCHEMA IF NOT EXISTS game_views;

CREATE OR REPLACE VIEW game_views.qb_wins as (
	select
	home_qb_name as qb_name,
	case when game_type = 'REG' then 'Regular' else 'Playoff' end as game_type,
	case when gametime > '20:00' then 'PrimeTime' else 'Regular' end as play_time,
	'home' as location,
	SUM(case when away_score < home_score then 1 else 0 END ) as wins,
	SUM(case when away_score = home_score then 1 else 0 END ) as ties,
	SUM(case when away_score > home_score then 1 else 0 END ) as loses
	from raw.odds
	group by 1,2,3

	union

	select
	away_qb_name as qb_name,
	case when game_type = 'REG' then 'Regular' else 'Playoff' end as game_type,
	case when gametime > '20:00' then 'PrimeTime' else 'Regular' end as play_time,
	'away' as location,
	SUM(case when away_score > home_score then 1 else 0 END ) as wins,
	SUM(case when away_score = home_score then 1 else 0 END ) as ties,
	SUM(case when away_score < home_score then 1 else 0 END ) as loses
	from raw.odds
	group by 1,2,3

);
