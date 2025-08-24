CREATE OR REPLACE PROCEDURE import_weekly_data(season INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.weekly', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'weekly/' || season || '.csv', 
       'us-east-1'
    );
END;
$$;