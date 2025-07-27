CREATE OR REPLACE FUNCTION import_ftn_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.ftn', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'ftn/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;