SELECT
  MAX(CAST(regexp_extract(season, '[0-9]+') AS INTEGER)) AS season_number,
  'Season ' || MAX(CAST(regexp_extract(season, '[0-9]+') AS INTEGER)) AS season_title,
  'Season ' || MAX(CAST(regexp_extract(season, '[0-9]+') AS INTEGER)) || ' Playoffs' AS playoffs_title
FROM standings