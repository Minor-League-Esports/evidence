CREATE OR REPLACE TEMP TABLE avgScrimStats AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/Avg_Scrim_Stats.parquet'
	);

CREATE OR REPLACE TEMP TABLE total_scrim_stats AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/Total_Scrim_Stats.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE historical_player_stats AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/historicalAggregatedPlayerStats.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE leagues AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/leagues.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE members AS
    SELECT *
    FROM read_parquet(
         'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/members.parquet'
	);

CREATE OR REPLACE TEMP TABLE player_stats AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/player_stats.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE players AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/players.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE role_usages AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/role_usages.parquet'
	);

CREATE OR REPLACE TEMP TABLE scrim_stats AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/scrim_stats.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE standings AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/standings.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE teams AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/teams.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE trackers AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/trackers.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE s17_stats AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/player_stats_s17.parquet'
	);

CREATE OR REPLACE TEMP TABLE s17_rounds AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/rounds_s17.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE s17_standings AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/standings_s17.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE fixtures AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/schedules/fixtures.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE match_groups AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/schedules/match_groups.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE matches AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/schedules/matches.parquet'
	);

CREATE OR REPLACE TEMP TABLE s18_stats AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s18/player_stats_s18.parquet'
	);

CREATE OR REPLACE TEMP TABLE s18_rounds AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s18/rounds_s18.parquet'
	);
	
CREATE OR REPLACE TEMP TABLE s18_standings AS
    SELECT *
    FROM read_parquet(
        'https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s18/standings_s18.parquet'
	);
