CREATE OR REPLACE FUNCTION import_snaps_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.snaps', 
       '', 
       '(format csv, header true)', 
       'nfl-data-bucket', 
       'snaps/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;