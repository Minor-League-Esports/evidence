---
title: Scrim Stats
---

<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions' open>

Below you will find stats for scrims in MLE for S18 in the last 60 days.
- You can use the search bar above the table to search for a specific player.
- You can also use the drop down menus below to Filter the stats however you see fit.
- Lastly you can click on the stat column to put stats in ascending or descending order.

</Details>

```sql dropdown_info

SELECT DISTINCT 
    p.franchise AS team
    , ass.name
    , ass.salary::TEXT AS salary
    , ass.skill_group AS league
    , CASE
        WHEN ass.gamemode = 'RL_DOUBLES' THEN 'Doubles'
        WHEN ass.gamemode = 'RL_STANDARD' THEN 'Standard'
        ELSE 'Unknown'
    END AS game_mode

FROM avgScrimStats ass
LEFT JOIN players p
        ON p.sprocket_player_id = ass.sprocket_player_id

```

```sql scrimStats
SELECT 
    p.name
    , '/players/' || CAST(p.member_id AS INTEGER) as playerLink
    , p.member_id
    , p.salary
    , CASE WHEN ass.gamemode = 'RL_DOUBLES' THEN 'Doubles'
        WHEN ass.gamemode = 'RL_STANDARD' THEN 'Standard'
        ELSE 'Unknown' 
        END as game_mode
    , ass.skill_group as league
    , p.franchise
    , ass.scrim_games_played AS games_played
    , ass.win_percentage AS win_pct
    , ass.dpi_per_game as dpi
    , ass.opi_per_game as opi
    , ass.avg_sprocket_rating as sprocket_rating
    , ass.score_per_game as score
    , ass.goals_per_game as goals
    , ass.assists_per_game as assists
    , ass.saves_per_game as saves
    , ass.shots_per_game as shots
    , ass.avg_goals_against as goals_against
    , ass.avg_shots_against as shots_against
    , ass.demos_per_game as demos
    , p.current_scrim_points as scrim_points
    , p."Eligible Until" as eligible_until
FROM avgScrimStats ass 
    LEFT JOIN players p 
        ON p.sprocket_player_id = ass.sprocket_player_id
WHERE p.salary in ${inputs.Salary.value}
AND ass.skill_group in ${inputs.League.value}
AND game_mode in ${inputs.GameMode.value}
AND p.franchise in ${inputs.Team.value}
```

<Dropdown data={dropdown_info} name=Salary value=Salary multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_info} name=Team value=Team multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_info} name=League value=League multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_info} name=GameMode value=game_mode multiple=true selectAllByDefault=true />



## Scrim Stats from last 60 Days
<DataTable data={scrimStats} rows=20 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white link=playerLink >
        <Column id=name align=center />
        <Column id=salary align=center />
        <Column id=game_mode align=center />
        <Column id=league align=center />
        <Column id=games_played align=center />
        <Column id=win_pct align=center />
        <Column id=sprocket_rating align=center />
        <Column id=opi align=center />
        <Column id=dpi align=center />
        <Column id=score align=ceneter />
        <Column id=goals align=center />
        <Column id=assists align=center />
        <Column id=saves align=center />
        <Column id=shots align=center />
        <Column id=goals_against align=center />
        <Column id=shots_against align=center />
        <Column id=demos align=center />
</DataTable>

```sql HeatMap
SELECT
    DATE(tss.scrim_created_at) AS day
    , COUNT(distinct tss.scrim_meta_id) AS completed_scrims
    , CASE
        WHEN skill_group = 'FL' THEN 'Foundation League'
        WHEN skill_group = 'AL' THEN 'Academy League'
        WHEN skill_group = 'CL' THEN 'Champion League'
        WHEN skill_group = 'ML' THEN 'Master League'
        WHEN skill_group = 'PL' THEN 'Premier League'
        ELSE 'unknown'
    END AS league
FROM total_scrim_stats tss
    WHERE YEAR(tss.scrim_created_at) = 2026
    AND league IN ${inputs.League.value}
    GROUP BY DATE(tss.scrim_created_at) , league
    ORDER BY day
```


<CalendarHeatmap 
    data={HeatMap}
    date=day
    value=completed_scrims
    yearLabel={true}
    title="Scrims per Day in 2026"
/> 

```sql hourlyheatmap
WITH scrim_in_hours AS (
    SELECT
        dayname(timezone('America/New_York', timezone('UTC', scrim_created_at))) AS scrim_day
        , strftime(scrim_created_at AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York', '%I:00 %p') AS scrim_hour
        -- We keep the raw hour for sorting later
        , EXTRACT(HOUR FROM scrim_created_at AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS raw_hour
        , DATE(timezone('America/New_York', timezone('UTC', scrim_created_at))) AS scrim_date
        , COUNT(DISTINCT scrim_meta_id) AS total_hour
        , CASE
            WHEN skill_group = 'FL' THEN 'Foundation League'
            WHEN skill_group = 'AL' THEN 'Academy League'
            WHEN skill_group = 'CL' THEN 'Champion League'
            WHEN skill_group = 'ML' THEN 'Master League'
            WHEN skill_group = 'PL' THEN 'Premier League'
            ELSE 'unknown'
        END AS league
    FROM total_scrim_stats
    GROUP BY 1, 2, 3, 4, league
),
day_counts AS (
    SELECT
        dayname(timezone('America/New_York', timezone('UTC', scrim_created_at))) AS scrim_day,
        COUNT(DISTINCT DATE(timezone('America/New_York', timezone('UTC', scrim_created_at)))) AS day_count
    FROM total_scrim_stats
    WHERE DATE(timezone('America/New_York', timezone('UTC', scrim_created_at))) >= (NOW() AT TIME ZONE 'America/New_York')::date - INTERVAL '4 weeks'
    GROUP BY 1
)

SELECT
    s.scrim_day
    , s.scrim_hour
    , s.raw_hour
    , SUM(s.total_hour) / d.day_count AS avg_scrims
    , SUM(s.total_hour) as total_hour_sum
FROM scrim_in_hours s
JOIN day_counts d ON s.scrim_day = d.scrim_day
WHERE s.league IN ${inputs.League.value}
  AND s.scrim_date >= (NOW() AT TIME ZONE 'America/New_York')::date - INTERVAL '4 weeks'
GROUP BY s.scrim_day
        , s.scrim_hour
        , s.raw_hour
        , d.day_count
ORDER BY 
    (CASE WHEN s.scrim_day = 'Monday' THEN 0
          WHEN s.scrim_day = 'Tuesday' THEN 1
          WHEN s.scrim_day = 'Wednesday' THEN 2
          WHEN s.scrim_day = 'Thursday' THEN 3
          WHEN s.scrim_day = 'Friday' THEN 4
          WHEN s.scrim_day = 'Saturday' THEN 5
          WHEN s.scrim_day = 'Sunday' THEN 6 END)
    , s.raw_hour -- This handles the 0-23 chronological sort perfectly
```

<Heatmap 
    data={hourlyheatmap} 
    x=scrim_day 
    y=scrim_hour
    ySort=raw_hour 
    value=avg_scrims  
    title="Average Scrims by Day and Hour in EST (Last 4 Weeks)"
    cellHeight=20
/>