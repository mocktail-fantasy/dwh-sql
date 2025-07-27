CREATE OR REPLACE FUNCTION import_player_ids_data()
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.player_ids', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'player_ids/player_ids.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;