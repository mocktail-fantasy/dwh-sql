CREATE OR REPLACE FUNCTION import_combine_data()
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.combine', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'combine/combine.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;