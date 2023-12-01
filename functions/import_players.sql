CREATE OR REPLACE FUNCTION import_player_data()
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'dev.players', 
       '', 
       '(format csv, header true)', 
       'nfl-data-bucket', 
       'players/players.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;