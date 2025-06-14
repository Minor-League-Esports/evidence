---
title: S18 Stats
---


```sql dropdown_info

SELECT DISTINCT 
    p.name
    , p.salary::TEXT AS salary
    , s18.team_name AS team
    , s18.skill_group AS league
    , CASE
        WHEN s18.gamemode = 'RL_DOUBLES' THEN 'Doubles'
        WHEN s18.gamemode = 'RL_STANDARD' THEN 'Standard'
        ELSE 'Unknown'
    END AS game_mode
    , mg.match_group_title AS week

FROM S18_stats s18

LEFT JOIN players p
    ON s18.member_id = p.member_id

LEFT JOIN matches m
    ON s18.match_id = m.match_id

LEFT JOIN match_groups mg
    ON m.match_group_id = mg.match_group_id

WHERE mg.parent_group_title = 'Season 18'

```


<Tabs>
<Tab label="Player Stats">

<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions'>

Below you will find all stats for all players in MLE for S18.
- You can use the search bar above the table to search for a specific player.
- You can also use the drop down menus below to Filter the stats however you see fit.
- Lastly you can click on the stat column to put stats in ascending or descending order.

</Details>


```sql LeaderboardStats

SELECT
    p.name AS name,
    '/players/' || p.member_id AS playerLink,
    p.salary,
    s18.team_name AS team,
    s18.skill_group AS league,
    CASE
        WHEN s18.gamemode = 'RL_DOUBLES' THEN 'Doubles'
        WHEN s18.gamemode = 'RL_STANDARD' THEN 'Standard'
        ELSE 'Unknown'
    END AS game_mode,
    SUM(
        CASE
            WHEN (s18.team_name = m.home AND s18.home_won) 
                OR (s18.team_name = m.away AND NOT s18.home_won) THEN 1
            ELSE 0
        END
        )/COUNT(*) AS win_pct,
    COUNT(*) AS games_played,
    AVG(dpi) AS Avg_DPI,
    AVG(gpi) AS "Sprocket Rating",
    AVG(opi) AS Avg_OPI,
    AVG(score) AS Score_Per_Game,
    AVG(goals) AS Goals_Per_Game,
    SUM(goals) AS total_goals,
    AVG(assists) AS Assists_Per_Game,
    SUM(assists) AS total_assists,
    AVG(saves) AS Saves_Per_Game,
    SUM(saves) AS total_saves,
    AVG(shots) AS Shots_Per_Game,
    AVG(goals_against) AS goals_against_per_game,
    AVG(shots_against) AS shots_against_per_game,
    SUM(goals) / SUM(shots) AS shooting_pct

FROM S18_stats s18

INNER JOIN players p
    ON s18.member_id = p.member_id

LEFT JOIN matches m
    ON s18.match_id = m.match_id

LEFT JOIN match_groups mg
    ON m.match_group_id = mg.match_group_id

WHERE p.salary IN ${inputs.Salary.value}
    AND s18.team_name IN ${inputs.Team.value}
    AND s18.skill_group IN ${inputs.League.value}
    AND game_mode IN ${inputs.GameMode.value}
    AND mg.match_group_title IN ${inputs.Week.value}

GROUP BY
    p.name
    , p.salary
    , s18.team_name
    , s18.skill_group
    , s18.gamemode
    , p.member_id

ORDER BY
    p.name

```

<Dropdown data={dropdown_info} name=Salary value=salary multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_info} name=Team value=team multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_info} name=League value=league multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_info} name=GameMode value=game_mode multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_info} name=Week value=week multiple=true selectAllByDefault=true />

<DataTable data={LeaderboardStats} rows=20 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white link=playerLink >
    <Column id=name align=center />
    <Column id=salary align=center />
    <Column id=league align=center />
    <Column id=game_mode align=center />
    <Column id=games_played align=center />
    <Column id=win_pct align=center title="Win %"/>
    <Column id="Sprocket Rating" align=center />
    <Column id=Avg_OPI align=center />
    <Column id=Avg_DPI align=center />
    <Column id=Score_Per_Game align=center />
    <Column id=Goals_Per_Game align=center />
    <Column id=total_goals align=center />
    <Column id=Assists_Per_Game align=center />
    <Column id=total_assists align=center />
    <Column id=Saves_Per_Game align=center />
    <Column id=total_saves align=center />
    <Column id=Shots_Per_Game align=center />
    <Column id=goals_against_per_game align=center />
    <Column id=shots_against_per_game align=center />
    <Column id=shooting_pct align=center title="Shot %"/>
</DataTable>

</Tab>

<Tab label="Scrim Stats">

```sql scrimStats
with scrims as(
SELECT 
    p.name
    , '/players/' || p.member_id as playerLink
    , member_id
    , p.salary
    , CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles'
        WHEN gamemode = 'RL_STANDARD' THEN 'Standard'
        ELSE 'Unknown' 
        END as game_mode
    , p.skill_group as league
    , franchise
    , scrim_games_played
    , win_percentage
    , dpi_per_game as dpi
    , opi_per_game as opi
    , avg_sprocket_rating as sprocket_rating
    , score_per_game as score
    , goals_per_game as goals
    , assists_per_game as assists
    , saves_per_game as saves
    , shots_per_game as shots
    , avg_goals_against as goals_against
    , avg_shots_against as shots_against
    , demos_per_game as demos
    , current_scrim_points as scrim_points
    , "Eligible Until" as eligible_until
FROM avgScrimStats ass 
    LEFT JOIN players p 
        ON p.sprocket_player_id = ass.sprocket_player_id)
SELECT *
From scrims
WHERE salary in ${inputs.Salary.value}
AND league in ${inputs.League.value}
AND game_mode in ${inputs.GameMode.value}
AND franchise in ${inputs.Team.value}
```

<Dropdown data={dropdown_info} name=Salary value=Salary multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_info} name=Team value=Team multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_info} name=League value=League multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_info} name=GameMode value=game_mode multiple=true selectAllByDefault=true />



>From Last 60 Days
<DataTable data={scrimStats} rows=20 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white link=playerLink >
        <Column id=name align=center />
        <Column id=salary align=center />
        <Column id=game_mode align=center />
        <Column id=league align=center />
        <Column id=scrim_games_played align=center />
        <Column id=win_percentage align=center />
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






</Tab>

<Tab label="Player Comparison">


```sql comparisonStats
With playerstats as (
    Select name,
    salary as Salary,
    team_name as Team,
    s18.skill_group as League,
    CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode,
    count(*) as games_played,
    avg(dpi) as Avg_DPI,
    avg(gpi) as sprocket_rating,
    avg(opi) as Avg_OPI,
    avg(score) as Score_Per_Game,
    avg(goals) as Goals_Per_Game,
    sum(goals) as total_goals,
    avg(assists) as Assists_Per_Game,
    sum(assists) as total_assists,
    avg(saves) as Saves_Per_Game,
    sum(saves) as total_saves,
    avg(shots) as Shots_Per_Game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) as shooting_pct2
 from players p
    inner join S18_stats s18
        on p.member_id = s18.member_id
group by name, salary, team_name, League, gamemode)

select 
name,
GameMode,
${inputs.stats.value} as stat1
from playerstats
where name in ${inputs.Player.value}
```



<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions' open>

<b>Below you can use the dropdown menus to select multiple players to compare stats against each other. </b>

</Details>

<Dropdown data={dropdown_info} name=Player value=name multiple=true defaultValue={['Ol Dirty Dirty','OwnerOfTheWhiteSedan']} />

<Dropdown name=stats defaultValue=score_per_game>
    <DropdownOption value=avg_dpi valueLabel=DPI />
    <DropdownOption value=sprocket_rating valueLabel="Sprocket Rating" />
    <DropdownOption value=avg_opi valueLabel=OPI />
    <DropdownOption value=score_per_game valueLabel=Score />
    <DropdownOption value=goals_per_game valueLabel=Goals />
    <DropdownOption value=total_goals valueLabel="Total Goals" />
    <DropdownOption value=assists_per_game valueLabel=Assists />
    <DropdownOption value=total_assists valueLabel="Total Assists" />
    <DropdownOption value=saves_per_game valueLabel=Saves />
    <DropdownOption value=total_saves valueLabel="Total Saves" />
    <DropdownOption value=shots_per_game valueLabel=Shots />
    <DropdownOption value=goals_against_per_game valueLabel="Goals Against" />
    <DropdownOption value=shots_against_per_game valueLabel="Shots Against"/>
    <DropdownOption value=shooting_pct2 valueLabel="Shooting %" />
</Dropdown>

> Comparitive stats between players
<BarChart 
data={comparisonStats}
x=GameMode
y=stat1
series=name
type=grouped
colorPalette={['#0c88fc', '#fd7600']}
sort=false
/>

</Tab>

<Tab label="League Comparison">

```sql leagueStats
select
    case
      when s18.skill_group = 'Foundation League' then 1
      when s18.skill_group = 'Academy League' then 2
      when s18.skill_group = 'Champion League' then 3
      when s18.skill_group = 'Master League' then 4
      when s18.skill_group = 'Premier League' then 5
    end as league_order,
    s18.skill_group as league,
    case
      when gamemode = 'RL_DOUBLES' then 'Doubles'
      when gamemode = 'RL_STANDARD' then 'Standard'
      else gamemode
    end as game_mode,
    avg(dpi) as Avg_DPI,
    avg(gpi) as sprocket_rating,
    avg(opi) as Avg_OPI,
    avg(score) as Score_Per_Game,
    avg(goals) as Goals_Per_Game,
    sum(goals) as total_goals,
    avg(assists) as Assists_Per_Game,
    sum(assists) as total_assists,
    avg(saves) as Saves_Per_Game,
    sum(saves) as total_saves,
    avg(shots) as Shots_Per_Game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) * 100 as shooting_pct2
 from players p
    inner join s18_stats s18
        on p.member_id = s18.member_id
group by League, game_mode
order by league_order
```

```sql leagueComparison
select 
league,
game_mode,
${inputs.Stats.value} as value
from ${leagueStats}
```

## League Averages

<Dropdown name=Stats defaultValue=score_per_game>
    <DropdownOption value=avg_dpi valueLabel="Avg DPI" />
    <DropdownOption value=sprocket_rating valueLabel="Avg Sprocket Rating" />
    <DropdownOption value=avg_opi valueLabel="Avg OPI" />
    <DropdownOption value=score_per_game valueLabel="Avg Score" />
    <DropdownOption value=goals_per_game valueLabel="Avg Goals" />
    <DropdownOption value=total_goals valueLabel="Total Goals" />
    <DropdownOption value=assists_per_game valueLabel="Avg Assists" />
    <DropdownOption value=total_assists valueLabel="Total Assists" />
    <DropdownOption value=saves_per_game valueLabel="Avg Saves" />
    <DropdownOption value=total_saves valueLabel="Total Saves" />
    <DropdownOption value=shots_per_game valueLabel="Avg Shots" />
    <DropdownOption value=goals_against_per_game valueLabel="Avg Goals Against" />
    <DropdownOption value=shots_against_per_game valueLabel="Avg Shots Against"/>
    <DropdownOption value=shooting_pct2 valueLabel="Avg Shooting %" />
</Dropdown>

<Dropdown name=mode defaultValue=Doubles >
    <DropdownOption value=Doubles />
    <DropdownOption value=Standard />
</Dropdown>

> ### {inputs.Stats.label} per League
<BarChart data={leagueComparison}
x=league
y=value
series=game_mode
type=grouped 
colorPalette={['#0c88fc', '#fd7600']}
sort=false
showAllXAxisLabels=true
labels=true
yFmt=0.00
/>


```sql allStats
select
    salary,
    case
      when s18.skill_group = 'Foundation League' then 1
      when s18.skill_group = 'Academy League' then 2
      when s18.skill_group = 'Champion League' then 3
      when s18.skill_group = 'Master League' then 4
      when s18.skill_group = 'Premier League' then 5
    end as league_order,
    s18.skill_group as league,
    case
      when gamemode = 'RL_DOUBLES' then 'Doubles'
      when gamemode = 'RL_STANDARD' then 'Standard'
      else gamemode
    end as game_mode,
    avg(dpi) as avg_dpi,
    avg(gpi) as sprocket_rating,
    avg(opi) as avg_opi,
    avg(score) as score_per_game,
    avg(goals) as goals_per_game,
    sum(goals) as total_goals,
    avg(assists) as assists_per_game,
    sum(assists) as total_assists,
    avg(saves) as saves_per_game,
    sum(saves) as total_saves,
    avg(shots) as shots_per_game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) * 100 as shooting_pct2,
    case
        when league = 'Foundation League' then ${inputs.Stats.value}
    end as FLstats,
    ${inputs.Stats.value} as value
 from players p
    inner join s18_stats s18
        on p.member_id = s18.member_id
where game_mode = '${inputs.mode.value}'
group by salary, league, game_mode
order by salary
```

```sql statsFL
select
    salary,
    league,
    game_mode,
    CASE
        when league = 'Foundation League' then ${inputs.Stats.value}
    end as FLstats,
    CASE
        when league = 'Academy League' then ${inputs.Stats.value}
    end as ALstats,
    CASE
        when league = 'Champion League' then ${inputs.Stats.value}
    end as CLstats,
    CASE
        when league = 'Master League' then ${inputs.Stats.value}
    end as MLstats,
    CASE
        when league = 'Premier League' then ${inputs.Stats.value}
    end as PLstats
from ${allStats}
where league = 'Foundation League'
and salary <= 10
```

```sql statsAL
select
    salary,
    league,
    game_mode,
    CASE
        when league = 'Foundation League' then ${inputs.Stats.value}
    end as FLstats,
    CASE
        when league = 'Academy League' then ${inputs.Stats.value}
    end as ALstats,
    CASE
        when league = 'Champion League' then ${inputs.Stats.value}
    end as CLstats,
    CASE
        when league = 'Master League' then ${inputs.Stats.value}
    end as MLstats,
    CASE
        when league = 'Premier League' then ${inputs.Stats.value}
    end as PLstats
from ${allStats}
where league = 'Academy League'
and salary >= 10.5
and salary <= 12.5
```

```sql statsCL
select
    salary,
    league,
    game_mode,
    CASE
        when league = 'Foundation League' then ${inputs.Stats.value}
    end as FLstats,
    CASE
        when league = 'Academy League' then ${inputs.Stats.value}
    end as ALstats,
    CASE
        when league = 'Champion League' then ${inputs.Stats.value}
    end as CLstats,
    CASE
        when league = 'Master League' then ${inputs.Stats.value}
    end as MLstats,
    CASE
        when league = 'Premier League' then ${inputs.Stats.value}
    end as PLstats
from ${allStats}
where league = 'Champion League'
and salary >= 13
and salary <= 15
```

```sql statsML
select
    salary,
    league,
    game_mode,
    CASE
        when league = 'Foundation League' then ${inputs.Stats.value}
    end as FLstats,
    CASE
        when league = 'Academy League' then ${inputs.Stats.value}
    end as ALstats,
    CASE
        when league = 'Champion League' then ${inputs.Stats.value}
    end as CLstats,
    CASE
        when league = 'Master League' then ${inputs.Stats.value}
    end as MLstats,
    CASE
        when league = 'Premier League' then ${inputs.Stats.value}
    end as PLstats
from ${allStats}
where league = 'Master League'
and salary >= 15.5
and salary <= 18.5
```

```sql statsPL
select
    salary,
    league,
    game_mode,
    CASE
        when league = 'Foundation League' then ${inputs.Stats.value}
    end as FLstats,
    CASE
        when league = 'Academy League' then ${inputs.Stats.value}
    end as ALstats,
    CASE
        when league = 'Champion League' then ${inputs.Stats.value}
    end as CLstats,
    CASE
        when league = 'Master League' then ${inputs.Stats.value}
    end as MLstats,
    CASE
        when league = 'Premier League' then ${inputs.Stats.value}
    end as PLstats
from ${allStats}
where league = 'Premier League'
and salary >= 18
```

<Grid cols=2 title=Doubles >
    <LineChart data={statsFL} x=salary y=FLstats xFmt=#,##0.0 title="Foundation League" labels=true markers=true colorPalette='#4ebeec'
/>
    <LineChart data={statsAL} x=salary y=ALstats xFmt=#,##0.0 title="Academy League" labels=true markers=true colorPalette='#0085fa'
/>
    <LineChart data={statsCL} x=salary y=CLstats xFmt=#,##0.0 title="Champion League" labels=true markers=true colorPalette='#7e55ce'
/>
    <LineChart data={statsML} x=salary y=MLstats xFmt=#,##0.0 title="Master League" labels=true markers=true colorPalette='#d10057'
/>
    <LineChart data={statsPL} x=salary y=PLstats xFmt=#,##0.0 title="Premier League" labels=true markers=true colorPalette='#e2b22d'
/>
</Grid>


</Tab>
</Tabs>
