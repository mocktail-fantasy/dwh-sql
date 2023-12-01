CREATE OR REPLACE FUNCTION import_injury_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'dev.injuries', 
       '', 
       '(format csv, header true)', 
       'nfl-data-bucket', 
       'injuries/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;