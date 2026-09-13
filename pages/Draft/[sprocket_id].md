---
title: Draft Profile
sidebar_link: false
---

```sql player_info
-- Bridge row: `players` is the only table that carries both sprocket_player_id and
-- member_id, so every other section resolves member_id from here (see SCHEMA_NOTES.md).
SELECT
    p.name,
    p.sprocket_player_id,
    p.member_id,
    p.franchise,
    '/franchises/' || p.franchise AS franchise_link,
    t."Photo URL" AS logo
FROM players p
LEFT JOIN teams t
    ON p.franchise = t.Franchise
WHERE p.sprocket_player_id = '${params.sprocket_id}'
```

{#if player_info.length === 0}

## Player Not Found

No player exists with Sprocket ID `${params.sprocket_id}`.

{:else}

<LastRefreshed prefix="Data last updated"/>

{#if player_info[0].logo}
<a href="{player_info[0].franchise_link}">
<center><img class="h-16" alt="Team Logo" style="content: url({player_info[0].logo}); object-fit: contain;" /></center>
</a>
{/if}

# <center><Value data={player_info} column=name /></center>

```sql draft_pick_stub
-- GAP: no draft records table exists anywhere in sources/ (checked every sources/sprocket/*.sql
-- file, "Create All Sprocket Datasets.sql", and archive/ for a prior mockup — found none).
-- There is no season/round/pick-number/drafting-franchise dataset to join against.
-- TODO: once a real draft results source query exists, replace this stub with a join on
-- sprocket_player_id (or member_id) and format as e.g. 'S19 R3.04'. See SCHEMA_NOTES.md "Gaps".
SELECT 'Undrafted' AS draft_pick
```

```sql seasons_in_mle
-- Proxy for "seasons in MLE": distinct seasons this player has an aggregated stats
-- record in. No dedicated roster-history table exists (see SCHEMA_NOTES.md "Gaps"),
-- so this undercounts a player who was rostered but never recorded any stats.
-- Playoffs are an extension of a season, not a separate one, so rows like
-- "Season 19 Playoffs" are excluded here (team_history above still shows them).
SELECT COUNT(DISTINCT season) AS seasons_played
FROM player_stats
WHERE member_id = (SELECT member_id FROM ${player_info} LIMIT 1)
    AND season NOT LIKE '%Playoffs%'
```

<BigValue data={player_info} title="MLEID" value=member_id />
<BigValue data={player_info} title="Sprocket ID" value=sprocket_player_id />
<BigValue data={player_info} title="Current Franchise" value=franchise />
<BigValue data={draft_pick_stub} title="Draft Pick" value=draft_pick />
<BigValue data={seasons_in_mle} title="Seasons in MLE" value=seasons_played />

## Team History

```sql team_history
-- GAP: no dedicated roster-assignment table exists (see SCHEMA_NOTES.md "Gaps"). This uses
-- player_stats (a season+team+gamemode stats aggregation) as a proxy for roster history,
-- the same approach the existing Season Stats section on /players/[member_id] already takes.
SELECT
    season,
    team_name AS franchise,
    skill_group AS league,
    STRING_AGG(
        DISTINCT CASE
            WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles'
            WHEN gamemode = 'RL_STANDARD' THEN 'Standard'
            ELSE gamemode
        END,
        ' / '
    ) AS modes,
    -- season is a free-text string (not an integer) on this table, so pull the digits out
    -- to sort numerically regardless of exact formatting (e.g. "19" vs "Season 19")
    REGEXP_REPLACE(season, '[^0-9]', '', 'g')::INT AS season_sort
FROM player_stats
WHERE member_id = (SELECT member_id FROM ${player_info} LIMIT 1)
GROUP BY season, team_name, skill_group
ORDER BY season_sort DESC
```

{#if team_history.length > 0}
<DataTable data={team_history} rows=20 rowShading=true compact=true>
    <Column id=season align=center />
    <Column id=franchise align=center />
    <Column id=league align=center />
    <Column id=modes title="Game Mode" align=center />
</DataTable>
{:else}
<Alert status=info>
No team history found for this player. Team history is derived from season stat records
(<code>player_stats</code>) — a player rostered but never recorded in a scrim/match will not
appear here. This section will be supplied manually until a dedicated roster-history dataset
is available.
</Alert>
<!-- TODO: replace with a real roster-history source once one is added; see SCHEMA_NOTES.md. -->
{/if}

## Career Scrim Counting Stats

```sql career_scrim_counting
-- "Career" here means the ~13 months of scrim history in total_scrim_stats
-- (Total_Scrim_Stats_13m.parquet) — there is no longer-lived raw scrim log in sources/
-- (see SCHEMA_NOTES.md "Gaps").
WITH modes(mode) AS (
    VALUES ('Doubles'), ('Standard')
),
scoped AS (
    -- total_scrim_stats uses its own gamemode literals ('2s'/'3s'), distinct from the
    -- 'RL_DOUBLES'/'RL_STANDARD' used by every other table on this page — confirmed by
    -- querying the real data (see SCHEMA_NOTES.md).
    SELECT
        CASE gamemode
            WHEN '2s' THEN 'Doubles'
            WHEN '3s' THEN 'Standard'
            ELSE gamemode
        END AS mode,
        goals, assists, saves, shots, goals_against, round_wins, rounds_count
    FROM total_scrim_stats
    WHERE sprocket_player_id = '${params.sprocket_id}'
),
by_mode AS (
    -- LEFT JOIN against the fixed `modes` list guarantees a Doubles row and a Standard
    -- row always exist, even when the player has zero scrims in one of the modes.
    SELECT
        m.mode,
        COALESCE(SUM(s.goals), 0) AS goals,
        COALESCE(SUM(s.assists), 0) AS assists,
        COALESCE(SUM(s.saves), 0) AS saves,
        COALESCE(SUM(s.shots), 0) AS shots,
        COALESCE(SUM(s.goals_against), 0) AS goals_allowed,
        COALESCE(SUM(s.round_wins), 0) AS wins,
        COALESCE(SUM(s.rounds_count), 0) AS games
    FROM modes m
    LEFT JOIN scoped s ON s.mode = m.mode
    GROUP BY m.mode
)
SELECT 1 AS sort_order, mode, goals, assists, saves, shots, goals_allowed, wins, games
FROM by_mode WHERE mode = 'Doubles'
UNION ALL
SELECT 2, mode, goals, assists, saves, shots, goals_allowed, wins, games
FROM by_mode WHERE mode = 'Standard'
UNION ALL
SELECT 3, 'Combined',
    SUM(goals), SUM(assists), SUM(saves), SUM(shots), SUM(goals_allowed), SUM(wins), SUM(games)
FROM by_mode
ORDER BY sort_order
```

<DataTable data={career_scrim_counting} rowShading=true compact=true>
    <Column id=mode title="Mode" align=center />
    <Column id=goals title="Goals" align=center />
    <Column id=assists title="Assists" align=center />
    <Column id=saves title="Saves" align=center />
    <Column id=shots title="Shots" align=center />
    <Column id=goals_allowed title="Goals Allowed" align=center />
    <Column id=wins title="Wins" align=center />
    <Column id=games title="Games" align=center />
</DataTable>

## Career Scrim Rate Stats

```sql career_scrim_rate
-- Self-contained (does not reference career_scrim_counting) so a query error in one
-- section can't blank the other.
WITH modes(mode) AS (
    VALUES ('Doubles'), ('Standard')
),
scoped AS (
    -- total_scrim_stats uses its own gamemode literals ('2s'/'3s'), not 'RL_DOUBLES'/
    -- 'RL_STANDARD' — see SCHEMA_NOTES.md.
    SELECT
        CASE gamemode
            WHEN '2s' THEN 'Doubles'
            WHEN '3s' THEN 'Standard'
            ELSE gamemode
        END AS mode,
        goals, assists, saves, shots, goals_against, round_wins, rounds_count, avg_sprocket_rating
    FROM total_scrim_stats
    WHERE sprocket_player_id = '${params.sprocket_id}'
),
by_mode AS (
    SELECT
        m.mode,
        SUM(s.goals) AS goals,
        SUM(s.assists) AS assists,
        SUM(s.saves) AS saves,
        SUM(s.shots) AS shots,
        SUM(s.goals_against) AS goals_allowed,
        SUM(s.round_wins) AS wins,
        SUM(s.rounds_count) AS games,
        -- each scrim's avg_sprocket_rating weighted by the games (rounds) it covers
        SUM(s.avg_sprocket_rating * s.rounds_count) AS sr_weighted_sum
    FROM modes m
    LEFT JOIN scoped s ON s.mode = m.mode
    GROUP BY m.mode
),
combined AS (
    SELECT
        'Combined' AS mode,
        SUM(goals) AS goals, SUM(assists) AS assists, SUM(saves) AS saves, SUM(shots) AS shots,
        SUM(goals_allowed) AS goals_allowed, SUM(wins) AS wins, SUM(games) AS games,
        SUM(sr_weighted_sum) AS sr_weighted_sum
    FROM by_mode
),
unioned AS (
    SELECT 1 AS sort_order, * FROM by_mode WHERE mode = 'Doubles'
    UNION ALL
    SELECT 2, * FROM by_mode WHERE mode = 'Standard'
    UNION ALL
    SELECT 3, * FROM combined
)
SELECT
    mode,
    goals / NULLIF(games, 0) AS goals_per_game,
    assists / NULLIF(games, 0) AS assists_per_game,
    saves / NULLIF(games, 0) AS saves_per_game,
    shots / NULLIF(games, 0) AS shots_per_game,
    goals_allowed / NULLIF(games, 0) AS goals_allowed_per_game,
    goals / NULLIF(shots, 0) AS shooting_pct,
    sr_weighted_sum / NULLIF(games, 0) AS avg_sr,
    wins / NULLIF(games, 0) AS win_pct
FROM unioned
ORDER BY sort_order
```

<DataTable data={career_scrim_rate} rowShading=true compact=true>
    <Column id=mode title="Mode" align=center />
    <Column id=goals_per_game title="Goals/Game" align=center fmt=num2 />
    <Column id=assists_per_game title="Assists/Game" align=center fmt=num2 />
    <Column id=saves_per_game title="Saves/Game" align=center fmt=num2 />
    <Column id=shots_per_game title="Shots/Game" align=center fmt=num2 />
    <Column id=goals_allowed_per_game title="GoalsAllowed/Game" align=center fmt=num2 />
    <Column id=shooting_pct title="Shooting%" align=center fmt=pct1 />
    <Column id=avg_sr title="AVG SR" align=center fmt=num2 />
    <Column id=win_pct title="Win%" align=center fmt=pct1 />
</DataTable>

## Last 60 Day Scrim Stats

```sql last_60_days
-- Filters on scrim_created_at directly (relative to query run time), per spec, rather than
-- relying on the pre-windowed avgScrimStats table the rest of the site uses for "last 60
-- days" (see SCHEMA_NOTES.md — avgScrimStats has no date column to filter on at all).
-- Modes with zero scrims in the window are dropped via HAVING, so the app can render an
-- explicit "No scrim data" message instead of a row of nulls.
WITH scoped AS (
    -- total_scrim_stats uses its own gamemode literals ('2s'/'3s'), not 'RL_DOUBLES'/
    -- 'RL_STANDARD' — see SCHEMA_NOTES.md.
    SELECT
        CASE gamemode
            WHEN '2s' THEN 'Doubles'
            WHEN '3s' THEN 'Standard'
            ELSE gamemode
        END AS mode,
        goals, assists, saves, shots, goals_against, round_wins, rounds_count, avg_sprocket_rating
    FROM total_scrim_stats
    WHERE sprocket_player_id = '${params.sprocket_id}'
        AND scrim_created_at >= CURRENT_DATE - INTERVAL 60 DAY
)
SELECT
    mode,
    SUM(rounds_count) AS games,
    SUM(goals) / NULLIF(SUM(rounds_count), 0) AS goals_per_game,
    SUM(assists) / NULLIF(SUM(rounds_count), 0) AS assists_per_game,
    SUM(saves) / NULLIF(SUM(rounds_count), 0) AS saves_per_game,
    SUM(shots) / NULLIF(SUM(rounds_count), 0) AS shots_per_game,
    SUM(goals_against) / NULLIF(SUM(rounds_count), 0) AS goals_allowed_per_game,
    SUM(goals) / NULLIF(SUM(shots), 0) AS shooting_pct,
    SUM(avg_sprocket_rating * rounds_count) / NULLIF(SUM(rounds_count), 0) AS avg_sr,
    SUM(round_wins) / NULLIF(SUM(rounds_count), 0) AS win_pct
FROM scoped
GROUP BY mode
HAVING SUM(rounds_count) > 0
ORDER BY CASE mode WHEN 'Doubles' THEN 1 WHEN 'Standard' THEN 2 ELSE 3 END
```

{#if last_60_days.length > 0}
<DataTable data={last_60_days} rowShading=true compact=true>
    <Column id=mode title="Mode" align=center />
    <Column id=games title="Games" align=center />
    <Column id=goals_per_game title="Goals/Game" align=center fmt=num2 />
    <Column id=assists_per_game title="Assists/Game" align=center fmt=num2 />
    <Column id=saves_per_game title="Saves/Game" align=center fmt=num2 />
    <Column id=shots_per_game title="Shots/Game" align=center fmt=num2 />
    <Column id=goals_allowed_per_game title="GoalsAllowed/Game" align=center fmt=num2 />
    <Column id=shooting_pct title="Shooting%" align=center fmt=pct1 />
    <Column id=avg_sr title="AVG SR" align=center fmt=num2 />
    <Column id=win_pct title="Win%" align=center fmt=pct1 />
</DataTable>
{:else}
No scrim data
{/if}

{#if last_60_days.length > 0 && !last_60_days.some(r => r.mode === 'Doubles')}
<p><em>Doubles: No scrim data</em></p>
{/if}
{#if last_60_days.length > 0 && !last_60_days.some(r => r.mode === 'Standard')}
<p><em>Standard: No scrim data</em></p>
{/if}

## Season 19 League Play Rate Stats

```sql s19_league_play
-- S19_stats is round-level (one row per player per round played in Season 19) — it has
-- no season/games_played/total_* columns and no wins column, and confusingly "gpi" (not a
-- column literally named "sprocket rating") is what the rest of the site treats as the
-- player's Sprocket Rating (see the "Sprocket Rating" dropdown option in
-- pages/players/[member_id].md, which maps to avg(gpi)). Win/loss is derived by joining
-- each round to s19_rounds and comparing scorelines, the same approach that page uses.
WITH player_rounds AS (
    SELECT
        s.round_id,
        s.team_name,
        s.goals, s.assists, s.saves, s.shots, s.goals_against, s.gpi,
        CASE s.gamemode
            WHEN 'RL_DOUBLES' THEN 'Doubles'
            WHEN 'RL_STANDARD' THEN 'Standard'
            ELSE s.gamemode
        END AS mode
    FROM S19_stats s
    WHERE s.member_id = (SELECT member_id FROM ${player_info} LIMIT 1)
),
with_results AS (
    SELECT
        pr.*,
        CASE
            WHEN pr.team_name = r.Home AND r."Home Goals" > r."Away Goals" THEN 1
            WHEN pr.team_name = r.Away AND r."Away Goals" > r."Home Goals" THEN 1
            ELSE 0
        END AS won
    FROM player_rounds pr
    INNER JOIN s19_rounds r
        ON pr.round_id = r.round_id
)
SELECT
    mode,
    COUNT(*) AS games,
    SUM(goals) / NULLIF(COUNT(*), 0) AS goals_per_game,
    SUM(assists) / NULLIF(COUNT(*), 0) AS assists_per_game,
    SUM(saves) / NULLIF(COUNT(*), 0) AS saves_per_game,
    SUM(shots) / NULLIF(COUNT(*), 0) AS shots_per_game,
    SUM(goals_against) / NULLIF(COUNT(*), 0) AS goals_allowed_per_game,
    SUM(goals) / NULLIF(SUM(shots), 0) AS shooting_pct,
    AVG(gpi) AS avg_sr,
    SUM(won) / NULLIF(COUNT(*), 0) AS win_pct
FROM with_results
GROUP BY mode
ORDER BY CASE mode WHEN 'Doubles' THEN 1 WHEN 'Standard' THEN 2 ELSE 3 END
```

{#if s19_league_play.length > 0}
<DataTable data={s19_league_play} rowShading=true compact=true>
    <Column id=mode title="Mode" align=center />
    <Column id=games title="Games" align=center />
    <Column id=goals_per_game title="Goals/Game" align=center fmt=num2 />
    <Column id=assists_per_game title="Assists/Game" align=center fmt=num2 />
    <Column id=saves_per_game title="Saves/Game" align=center fmt=num2 />
    <Column id=shots_per_game title="Shots/Game" align=center fmt=num2 />
    <Column id=goals_allowed_per_game title="GoalsAllowed/Game" align=center fmt=num2 />
    <Column id=shooting_pct title="Shooting%" align=center fmt=pct1 />
    <Column id=avg_sr title="AVG SR" align=center fmt=num2 />
    <Column id=win_pct title="Win%" align=center fmt=pct1 />
</DataTable>
{:else}
Did not play in Season 19
{/if}

{#if s19_league_play.length > 0 && !s19_league_play.some(r => r.mode === 'Doubles')}
<p><em>Doubles: Did not play in Season 19</em></p>
{/if}
{#if s19_league_play.length > 0 && !s19_league_play.some(r => r.mode === 'Standard')}
<p><em>Standard: Did not play in Season 19</em></p>
{/if}

{/if}
