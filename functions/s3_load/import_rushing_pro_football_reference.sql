CREATE OR REPLACE FUNCTION import_rushing_pro_football_reference_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.rushing_pro_football_reference', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'rushing_pro_football_reference/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;