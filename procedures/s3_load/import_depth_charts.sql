CREATE OR REPLACE PROCEDURE import_depth_charts_data(season INTEGER)
LANGUAGE plpgsql
AS $$
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
$$;