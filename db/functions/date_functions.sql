
    /*
    This is some hand wavey stuff.  
    Don't love it one bit. 
    Leaving it for now while I think of something better.
    */
CREATE OR REPLACE FUNCTION get_nfl_playing_season()
RETURNS INTEGER AS $$
BEGIN
    IF EXTRACT(MONTH FROM NOW()) < 9 THEN
        RETURN EXTRACT(YEAR FROM NOW()) - 1;
    ELSE
        RETURN EXTRACT(YEAR FROM NOW());
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_nfl_league_year()
RETURNS INTEGER AS $$
BEGIN
    IF EXTRACT(MONTH FROM NOW()) < 3 THEN
        RETURN EXTRACT(YEAR FROM NOW()) - 1;
    ELSE
        RETURN EXTRACT(YEAR FROM NOW());
    END IF;
END;
$$ LANGUAGE plpgsql;