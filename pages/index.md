---
title: Minor League Esports Statistics
sidebar_position: 1
---

```sql teamLogos
SELECT 
franchise,
'/franchises/' || franchise as franchiseLink,
"Photo URL" as logo
FROM teams
ORDER BY franchise ASC
```

<div style="width:100%; max-width:700px; margin:auto;">
<div style="display:flex; flex-direction:row; align-items:center; justify-content:center; flex-wrap:wrap; gap:0.25rem;">
{#each teamLogos || [] as t}
<a href="{t.franchiseLink}">
  {#if t.logo}
    <img class="h-10 w-10" alt={t.franchise} style="content: url({t.logo}); object-fit: contain;" />
  {/if}
</a>
{/each}
</div>
</div>

<h2 style="font-size: 25px;"><b><u> Season 19 Playoffs </u></b></h2>

<LastRefreshed prefix="Data last updated"/>

<ButtonGroup name=League>
    <ButtonGroupItem valueLabel="Foundation League" value="Foundation League" default />
    <ButtonGroupItem valueLabel="Academy League" value="Academy League" />
    <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
    <ButtonGroupItem valueLabel="Master League" value="Master League" />
    <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
</ButtonGroup>

<ButtonGroup name=GameMode>
    <ButtonGroupItem valueLabel="Doubles" value="Doubles" default />
    <ButtonGroupItem valueLabel="Standard" value="Standard" />
</ButtonGroup>

```sql playoff_seeds
WITH S19standings AS (
    SELECT
        *
        , CASE
            WHEN s19.mode IN ('Doubles', 'Standard') THEN s19.mode
            ELSE 'Overall'
        END AS game_mode
    FROM S19_standings s19
    INNER JOIN teams t ON s19.name = t.Franchise
),
results AS (
    SELECT
        r.match_id
        , m.league
        , m.game_mode
        , r.Home AS team_name
        , m.home_wins AS wins
        , m.away_wins AS loses
        , CASE WHEN r.Home = m.winning_team THEN 1 ELSE 0 END AS series_wins
        , CASE WHEN r.Home != m.winning_team THEN 1 ELSE 0 END AS series_loses
        , SUM(r."Home Goals") AS goals_for
        , SUM(r."Away Goals") AS goals_against
        , goals_for - goals_against AS goal_diff
    FROM s19_rounds r
    INNER JOIN matches m ON r.match_id = m.match_id
    INNER JOIN match_groups mg ON m.match_group_id = mg.match_group_id
    WHERE mg.parent_group_title = 'Season 19'
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
    UNION ALL
    SELECT
        r.match_id
        , m.league
        , m.game_mode
        , r.Away AS team_name
        , m.away_wins AS wins
        , m.home_wins AS loses
        , CASE WHEN r.Away = m.winning_team THEN 1 ELSE 0 END AS series_wins
        , CASE WHEN r.Away != m.winning_team THEN 1 ELSE 0 END AS series_loses
        , SUM(r."Away Goals") AS goals_for
        , SUM(r."Home Goals") AS goals_against
        , goals_for - goals_against AS goal_diff
    FROM s19_rounds r
    INNER JOIN matches m ON r.match_id = m.match_id
    INNER JOIN match_groups mg ON m.match_group_id = mg.match_group_id
    WHERE mg.parent_group_title = 'Season 19'
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
),
series_and_goal_diff AS (
    SELECT
        league, game_mode, team_name
        , SUM(wins) AS wins, SUM(loses) AS loses
        , SUM(series_wins) AS series_wins, SUM(series_loses) AS series_loses
        , SUM(goals_for) AS goals_for, SUM(goals_against) AS goals_against
        , SUM(goal_diff) AS goal_diff
    FROM results GROUP BY 1, 2, 3
    UNION ALL
    SELECT
        league, 'Overall' AS game_mode, team_name
        , SUM(wins) AS wins, SUM(loses) AS loses
        , SUM(series_wins) AS series_wins, SUM(series_loses) AS series_loses
        , SUM(goals_for) AS goals_for, SUM(goals_against) AS goals_against
        , SUM(goal_diff) AS goal_diff
    FROM results GROUP BY 1, 2, 3
),
staging AS (
    SELECT
        s19.Franchise AS team_name
        , s19."Photo URL" AS team_logo
        , s19."Super Division" AS super_division
        , CASE
            WHEN UPPER(s19.Conference) = 'BLUE' THEN 'Blue'
            WHEN UPPER(s19.Conference) = 'ORANGE' THEN 'Orange'
            ELSE s19.Conference
        END AS conference
        , s19.league
        , s19.game_mode
        , s19.Division AS division
        , s19.team_wins::INT || ' - ' || s19.team_losses::INT AS record
        , s19.team_wins / NULLIF(s19.team_wins + s19.team_losses, 0) AS win_pct
        , sagd.series_wins / NULLIF(sagd.series_wins + sagd.series_loses, 0) AS series_win_pct
        , sagd.goals_for
        , sagd.goal_diff AS goal_differential
        , CASE WHEN s19.ranking = 1 THEN 1 ELSE 0 END AS is_divisional_leader
    FROM S19standings s19
    INNER JOIN series_and_goal_diff sagd
        ON s19.Franchise = sagd.team_name
        AND s19.league = sagd.league
        AND s19.game_mode = sagd.game_mode
    WHERE s19.Conference NOT NULL
        AND s19.division_name NOT NULL
        AND s19.league = '${inputs.League}'
        AND s19.game_mode = '${inputs.GameMode}'
),
ranked AS (
    SELECT
        *
        , ROW_NUMBER() OVER (
            PARTITION BY CASE
                WHEN league IN ('Foundation League', 'Premier League') THEN conference
                ELSE super_division
            END
            ORDER BY
                is_divisional_leader DESC
                , win_pct DESC
                , series_win_pct DESC
                , goal_differential DESC
                , goals_for DESC
        ) AS seed_rank
    FROM staging
)
SELECT * FROM ranked
ORDER BY conference, super_division, seed_rank
```

```sql h2h_records
SELECT
    m.home AS team_a
    , m.away AS team_b
    , SUM(m.home_wins) AS a_game_wins
    , SUM(m.away_wins) AS b_game_wins
FROM matches m
INNER JOIN match_groups mg ON m.match_group_id = mg.match_group_id
WHERE mg.parent_group_title = 'Season 19'
    AND m.league = '${inputs.League}'
    AND m.game_mode = '${inputs.GameMode}'
GROUP BY m.home, m.away
```

```sql division_records
SELECT
    team_name
    , SUM(wins) AS div_wins
    , SUM(losses) AS div_losses
    , SUM(wins)::FLOAT / NULLIF(SUM(wins) + SUM(losses), 0) AS div_win_pct
FROM (
    SELECT
        m.home AS team_name
        , m.home_wins AS wins
        , m.away_wins AS losses
    FROM matches m
    INNER JOIN match_groups mg ON m.match_group_id = mg.match_group_id
    INNER JOIN teams t_home ON m.home = t_home.Franchise
    INNER JOIN teams t_away ON m.away = t_away.Franchise
    WHERE mg.parent_group_title = 'Season 19'
        AND m.league = '${inputs.League}'
        AND m.game_mode = '${inputs.GameMode}'
        AND t_home.Division = t_away.Division
    UNION ALL
    SELECT
        m.away AS team_name
        , m.away_wins AS wins
        , m.home_wins AS losses
    FROM matches m
    INNER JOIN match_groups mg ON m.match_group_id = mg.match_group_id
    INNER JOIN teams t_home ON m.home = t_home.Franchise
    INNER JOIN teams t_away ON m.away = t_away.Franchise
    WHERE mg.parent_group_title = 'Season 19'
        AND m.league = '${inputs.League}'
        AND m.game_mode = '${inputs.GameMode}'
        AND t_home.Division = t_away.Division
) div_matchups
GROUP BY team_name
```

```sql playoff_games
SELECT
    m.match_id
    , m.home
    , m.away
    , m.home_wins::INT AS home_wins
    , m.away_wins::INT AS away_wins
    , CASE
        WHEN m.winning_team = 'Not Played / Data Unavailable' OR m.winning_team IS NULL THEN NULL
        ELSE m.winning_team
    END AS winner
    , mg.match_group_title AS round
    , strftime(m.scheduled_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York', '%m/%d %I:%M %p') AS game_time
FROM matches m
INNER JOIN match_groups mg ON m.match_group_id = mg.match_group_id
WHERE mg.parent_group_title = 'Season 19 Playoffs'
    AND m.league = '${inputs.League}'
    AND m.game_mode = '${inputs.GameMode}'
ORDER BY mg.match_group_title
```

```sql team_logos
SELECT DISTINCT
    Franchise AS team_name
    , "Photo URL" AS team_logo
FROM teams
WHERE "Photo URL" IS NOT NULL AND "Photo URL" != ''
```

<PlayoffBracket {playoff_seeds} {playoff_games} {h2h_records} {division_records} {team_logos} league="{inputs.League}" />
