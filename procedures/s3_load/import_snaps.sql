CREATE OR REPLACE PROCEDURE import_snaps_data(season INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.snaps', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'snaps/' || season || '.csv', 
       'us-east-1'
    );
END;
$$;