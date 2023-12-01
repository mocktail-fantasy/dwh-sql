CREATE OR REPLACE FUNCTION import_ftn_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'dev.ftn', 
       '', 
       '(format csv, header true)', 
       'nfl-data-bucket', 
       'ftn/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;