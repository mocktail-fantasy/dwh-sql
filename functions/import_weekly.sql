CREATE OR REPLACE FUNCTION import_weekly_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'dev.weekly', 
       '', 
       '(format csv, header true)', 
       'nfl-data-bucket', 
       'weekly/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;