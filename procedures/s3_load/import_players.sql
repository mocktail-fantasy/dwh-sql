CREATE OR REPLACE PROCEDURE import_player_data()
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.players', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'players/players.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;