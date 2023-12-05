CREATE SCHEMA IF NOT EXISTS player_views;

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

CREATE OR REPLACE VIEW player_views.players AS (
SELECT
	esb_id,
	p.gsis_id,
	mfl_id,
	sportradar_id,
	fantasypros_id,
	pff_id,
	sleeper_id,
	nfl_id,
	espn_id,
	yahoo_id,
	fleaflicker_id,
	cbs_id,
	pfr_id,
	cfbref_id,
	rotowire_id,
	rotoworld_id,
	ktc_id,
	stats_id,
	stats_global_id,
	fantasy_data_id,
	swish_id,
	p.status,
	display_name,
	first_name,
	last_name,
	birth_date,
	college_name,
	position_group,
	p."position",
	jersey_number,
	p.height,
	p.weight,
	years_of_experience,
	team_abbr,
	team_seq,
	current_team_id,
	football_name,
	gsis_it_id,
	smart_id,
	entry_year,
	rookie_year,
	draft_club,
	draft_number,
	college_conference,
	status_description_abbr,
	status_short_description,
	uniform_number,
	suffix,
	p.draft_round,
	season
	FROM raw.players p
		LEFT JOIN raw.player_ids i
		    ON p.gsis_id = i.gsis_id
);