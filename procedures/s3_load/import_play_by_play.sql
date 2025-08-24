CREATE OR REPLACE PROCEDURE import_play_by_play_data(season INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.play_by_play', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'play_by_play/' || season || '.csv', 
       'us-east-1'
    );
END;
$$;