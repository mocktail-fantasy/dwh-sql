CREATE OR REPLACE PROCEDURE import_rosters_data(season INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.rosters', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'rosters/' || season || '.csv', 
       'us-east-1'
    );
END;
$$;