CREATE OR REPLACE PROCEDURE export_rosters_to_s3()
LANGUAGE plpgsql
AS $$
DECLARE
    team_record RECORD;
    s3_uri TEXT;
    query_text TEXT;
BEGIN
    FOR team_record IN SELECT DISTINCT team FROM players.active_rosters
    LOOP
        s3_uri := 's3-uri s3://nfl-cache/rosters/' || team_record.team || '.json';

        query_text := format(
            'SELECT json_agg(t)::text FROM players.active_rosters t WHERE team = %L',
            team_record.team
        );

        PERFORM aws_s3.query_export_to_s3(query_text, s3_uri, options :='format text');

    END LOOP;
END;
$$;
