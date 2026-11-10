-- Placeholder until the Season 20 playoffs dataset exists (player_stats_playoffs_s20).
-- A source with zero rows cannot be read by Evidence, so this returns one row with
-- an impossible match_id (-1) that no match page will ever show.
-- Point it at the playoffs file once it is published.
SELECT * REPLACE (-1 AS match_id) FROM read_parquet(
    'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/player_stats_s20.parquet'
    )
LIMIT 1