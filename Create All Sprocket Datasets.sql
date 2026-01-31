CREATE OR REPLACE TEMP TABLE avgScrimStats AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/Avg_Scrim_Stats.parquet'
	);

CREATE OR REPLACE TEMP TABLE fixtures AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/fixtures.parquet'
	);

CREATE OR REPLACE TEMP TABLE leagues AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/leagues.parquet'
	);

CREATE OR REPLACE TEMP TABLE match_groups AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/match_groups.parquet'
	);

CREATE OR REPLACE TEMP TABLE matches AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/matches.parquet'
	);

CREATE OR REPLACE TEMP TABLE player_stats AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/historicalAggregatedPlayerStats.parquet'
	);

CREATE OR REPLACE TEMP TABLE players AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/players.parquet'
	);

CREATE OR REPLACE TEMP TABLE role_usages AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/role_usages.parquet'
	);

--CREATE OR REPLACE TEMP TABLE s17_rounds AS
--    SELECT *
--    FROM read_parquet(
--        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/rounds_s17.parquet'
--	);
--	
--CREATE OR REPLACE TEMP TABLE s17_standings AS
--    SELECT *
--    FROM read_parquet(
--        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/standings_s17.parquet'
--	);
--
--CREATE OR REPLACE TEMP TABLE s17_stats AS
--    SELECT *
--    FROM read_parquet(
--        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/player_stats_s17.parquet'
--	);

CREATE OR REPLACE TEMP TABLE s18_rounds AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/rounds_s18.parquet'
	);

CREATE OR REPLACE TEMP TABLE s18_standings AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/standings_s18.parquet'
	);

CREATE OR REPLACE TEMP TABLE s18_stats AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/player_stats_s18.parquet'
	);

CREATE OR REPLACE TEMP TABLE standings AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/standings.parquet'
	);

CREATE OR REPLACE TEMP TABLE teams AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/teams.parquet'
	);

CREATE OR REPLACE TEMP TABLE total_scrim_stats AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/Total_Scrim_Stats_13m.parquet'
	);
	
	
CREATE OR REPLACE TEMP TABLE trackers AS
    SELECT *
    FROM read_parquet(
        'https://sprocket-public-datasets.nyc3.cdn.digitaloceanspaces.com/datasets/trackers.parquet'
	);


--not present in evidence
--CREATE OR REPLACE TEMP TABLE historical_player_stats AS
--    SELECT *
--    FROM read_parquet(
--        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/historicalAggregatedPlayerStats.parquet'
--	);
--	
--CREATE OR REPLACE TEMP TABLE members AS
--    SELECT *
--    FROM read_parquet(
--         'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/members.parquet'
--	);
--
--CREATE OR REPLACE TEMP TABLE scrim_stats AS
--    SELECT *
--    FROM read_parquet(
--        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/scrim_stats.parquet'
--	);
