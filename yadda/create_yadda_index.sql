BEGIN;
  CREATE INDEX beer_id_idx ON yadda.ratings(beer_id);
  CREATE INDEX style_idx ON yadda.beer_styles(style);
  CREATE INDEX name_idx ON yadda.beers(name);
  CREATE INDEX berewery_id_idx ON yadda.beers(brewery_id);
  CREATE INDEX style_id_idx ON yadda.beers(style_id);
  CREATE INDEX created_on_idx ON yadda.ratings(created_on);
COMMIT;