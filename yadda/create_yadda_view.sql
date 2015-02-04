BEGIN;

CREATE OR REPLACE VIEW yadda.rating_view AS
  SELECT r.beer_id,r.user_id,r.created_on, (r.look+r.smell+r.taste+r.feel+r.overall) rating
  FROM yadda.ratings r
;

CREATE OR REPLACE VIEW yadda.average_rating_view AS
  SELECT st.style style_name,b.name as beer_name, AVG(r.rating) as rating FROM yadda.beers b
  JOIN yadda.rating_view r ON b.id = r.beer_id
  JOIN yadda.beer_styles st ON b.style_id = st.id group by st.style,b.name;

-- Time: 1196.521 ms
CREATE OR REPLACE VIEW yadda.top_beer_from_brewery AS
 SELECT beer_name,rating,style_name
  FROM (
    SELECT arv.beer_name,arv.rating,arv.style_name, rank() OVER(PARTITION BY beer_name
      ORDER BY rating DESC) AS rank FROM  yadda.average_rating_view arv)ss
where rank=1;
-- Time: 778.604 ms

CREATE OR REPLACE VIEW yadda.recent_average_rating_view AS
  SELECT st.style style_name,b.name as beer_name, AVG(r.rating) as rating FROM yadda.beers b
    JOIN yadda.rating_view r ON b.id = r.beer_id
    JOIN yadda.beer_styles st ON b.style_id = st.id
    WHERE r.created_on > CURRENT_DATE - INTERVAL '6 months'
    GROUP BY st.style,b.name
 ;
-- Time: 1744.182 ms

CREATE OR REPLACE FUNCTION yadda.you_might_also_enjoy(beer TEXT)
  RETURNS SETOF yadda.average_rating_view AS $$
    DECLARE
    sql text := 'SELECT * FROM
      (SELECT *
        FROM yadda.average_rating_view where style_name IN (
          SELECT st.style from yadda.beer_styles st
            JOIN yadda.beers b ON b.style_id = st.id
            AND b.name = '|| quote_literal($1) ||'
      )and beer_name <>'|| quote_literal($1) ||' ORDER BY rating DESC LIMIT 3
  )tmp ORDER by random()';
    BEGIN
      RETURN QUERY EXECUTE sql
      USING beer;
    END;
$$ LANGUAGE plpgsql;
COMMIT;
-- Time: 1356.372 ms

