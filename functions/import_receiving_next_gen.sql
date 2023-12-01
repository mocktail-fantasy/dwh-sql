CREATE OR REPLACE FUNCTION import_receiving_next_gen_data(season INTEGER)
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'dev.receiving_next_gen_stats', 
       '', 
       '(format csv, header true)', 
       'nfl-data-bucket', 
       'receiving_next_gen_stats/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;