CREATE OR REPLACE FUNCTION import_depth_charts_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'dev.depth_charts', 
       '', 
       '(format csv, header true)', 
       'nfl-data-bucket', 
       'depth_charts/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;