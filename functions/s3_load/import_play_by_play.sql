CREATE OR REPLACE FUNCTION import_play_by_play_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.play_by_play', 
       '', 
       '(format csv, header true)', 
       'nfl-data-bucket', 
       'play_by_play/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;