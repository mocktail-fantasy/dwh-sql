CREATE OR REPLACE FUNCTION import_odds_data()
RETURNS void AS $$
BEGIN
    PERFORM aws_s3.table_import_from_s3(
       'raw.odds', 
       '', 
       '(format csv, header true)', 
       'nfl-data-bucket', 
       'odds/odds.csv', 
       'us-east-1'
    );
END;
$$ LANGUAGE plpgsql;