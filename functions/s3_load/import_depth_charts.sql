CREATE OR REPLACE FUNCTION import_depth_charts_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.depth_charts', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'depth_charts/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;