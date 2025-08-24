CREATE OR REPLACE PROCEDURE export_players_to_s3()
LANGUAGE plpgsql
AS $$
DECLARE
    team_record RECORD;
    s3_uri aws_commons._s3_uri_1;
    query_text TEXT;
BEGIN
    FOR team_record IN SELECT DISTINCT team FROM players.active_rosters
    LOOP
        s3_uri := aws_commons.create_s3_uri(
            'nfl-cache',
            'rplayers/annual/' || team_record.team || '.json',
            'us-east-1'
        );  
        
        query_text := format(
            'SELECT json_agg(t)::text FROM players.annual_regular_season_stats t WHERE team = %L',
            team_record.team
        );

        PERFORM aws_s3.query_export_to_s3(query_text, s3_uri, options :='format text');

    END LOOP;
END;
$$;
