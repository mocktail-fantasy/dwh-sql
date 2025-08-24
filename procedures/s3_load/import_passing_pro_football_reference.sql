CREATE OR REPLACE PROCEDURE import_passing_pro_football_reference_data(season INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.passing_pro_football_reference', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'passing_pro_football_reference/' || season || '.csv', 
       'us-east-1'
    );
END;
$$;