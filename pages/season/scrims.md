---
title: Scrim Results
sidebar_position: 5
---

<LastRefreshed prefix="Data last updated"/>

Completed scrims from the current rolling 13-month data window. Select a scrim to view player totals and individual game reports.

```sql dropdown_info
SELECT DISTINCT
    league,
    game_mode
FROM scrim_results
ORDER BY league, game_mode
```

```sql scrims
WITH filtered_rows AS (
    SELECT *
    FROM scrim_results
    WHERE league IN ${inputs.League.value}
        AND game_mode IN ${inputs.GameMode.value}
),
games AS (
    SELECT DISTINCT
        scrim_id,
        scrim_created_at,
        league,
        game_mode,
        game_number,
        blue_won
    FROM filtered_rows
),
player_counts AS (
    SELECT
        scrim_id,
        COUNT(DISTINCT sprocket_player_id) AS players
    FROM filtered_rows
    GROUP BY scrim_id
)
SELECT
    g.scrim_id,
    '/scrims/' || CAST(g.scrim_id AS INTEGER) AS scrim_link,
    MAX(g.scrim_created_at) AS played_at,
    MAX(g.league) AS league,
    MAX(g.game_mode) AS game_mode,
    COUNT(*) AS games,
    p.players,
    COUNT(*) FILTER (WHERE g.blue_won) || ' - ' || COUNT(*) FILTER (WHERE NOT g.blue_won) AS game_score
FROM games g
INNER JOIN player_counts p
    ON g.scrim_id = p.scrim_id
GROUP BY g.scrim_id, p.players
ORDER BY played_at DESC
```

<Dropdown data={dropdown_info} name=League value=league multiple=true selectAllByDefault=true />
<Dropdown data={dropdown_info} name=GameMode value=game_mode multiple=true selectAllByDefault=true />

## Completed Scrims

<DataTable data={scrims} rows=25 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white link=scrim_link>
    <Column id=played_at contentType=datetime format="MMM d, yyyy h:mm A" align=center title="Played" />
    <Column id=league align=center title="League" />
    <Column id=game_mode align=center title="Mode" />
    <Column id=players align=center title="Players" />
    <Column id=games align=center title="Games" />
    <Column id=game_score align=center title="Blue - Orange Wins" />
</DataTable>
