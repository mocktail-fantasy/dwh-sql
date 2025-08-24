CREATE OR REPLACE PROCEDURE import_injury_data(season INTEGER)
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.injuries', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'injuries/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;