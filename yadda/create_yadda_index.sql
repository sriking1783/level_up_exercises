BEGIN;
  CREATE INDEX beer_id_idx ON yadda.ratings(beer_id);
  CREATE INDEX berewery_id_idx ON yadda.beers(brewery_id);
  CREATE INDEX style_id_idx ON yadda.beers(style_id);
  CREATE INDEX created_on_idx ON yadda.beer_styles(created_on);
COMMIT;