CREATE OR REPLACE FUNCTION import_rushing_next_gen_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.rushing_next_gen_stats', 
       '', 
       '(format csv, header true)', 
       'nfl-data-bucket', 
       'rushing_next_gen_stats/' || year || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;