CREATE OR REPLACE PROCEDURE import_odds_data()
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.odds', 
       '', 
       '(format csv, header true)', 
       'nfl-staging-datalake', 
       'odds/odds.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;