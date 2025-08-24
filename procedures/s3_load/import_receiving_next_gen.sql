CREATE OR REPLACE PROCEDURE import_receiving_next_gen_data(season INTEGER)
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.receiving_next_gen_stats', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'receiving_next_gen_stats/' || season || '.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;