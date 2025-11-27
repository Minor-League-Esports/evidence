---
title: All-Time Player Stats
---

```sql dropdown_and_button_group
    SELECT
        name AS Name
        , 'players/' || ps.member_id as playerLink
        , CASE WHEN ps.gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN ps.gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode
        , season
        , team_name as Franchise
        , skill_group
        , SUM(games_played) as games_played

    FROM player_stats ps

    GROUP BY
        Name
        , gamemode
        , playerLink
        , season
        , team_name
        , skill_group
```

```sql slider
    SELECT
        name AS Name
        , CASE WHEN ps.gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN ps.gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode
        , SUM(games_played) as games_played

    FROM player_stats ps

    GROUP BY
        Name
        , GameMode

    ORDER BY
        games_played DESC
```

<ButtonGroup name=game_mode>
    <ButtonGroupItem valueLabel="Both" value="%" default/>
    <ButtonGroupItem valueLabel="Doubles" value="Doubles" />
    <ButtonGroupItem valueLabel="Standard" value="Standard" />
</ButtonGroup>

<Slider
    title='Games Played'
    name=games_played
    size=full
    step=1
    data={slider}
    min=1
    maxColumn=games_played
/>

<Tabs>
<Tab label=" Stats">

<LastRefreshed prefix="Data last updated"/>

```sql LeaderboardStats_career
With lifetime_stats as (
    Select name as Name
    ,'players/' || ps.member_id as playerLink
    ,CASE WHEN ps.gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN ps.gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode
    ,sum(games_played) as games_played
    ,avg(sprocket_rating) as 'Sprocket Rating'
    ,avg(opi_per_game) as OPI
    ,avg(dpi_per_game) as DPI
    ,avg(avg_score) as 'Avg Score'
    ,sum(total_goals) as Goals
    ,sum(total_assists) as Assists
    ,sum(total_saves) as Saves
    ,sum(total_shots) as Shots
    ,sum(total_goals)/sum(total_shots) as shooting_pct2
    ,sum(total_demos_inflicted) as 'Demos'
    ,sum(total_demos_taken) as 'Demos Taken'
    ,avg(goals_per_game) as 'Goals/ G'
    ,avg(assists_per_game) as 'Assists/ G'
    ,avg(saves_per_game) as 'Saves/ G'
    ,avg(shots_per_game) as 'Shots/ G'
    ,avg(avg_goals_against) as 'Goals Against/ G'
    ,avg(avg_shots_against) as 'Shots Against/ G'
    ,avg(avg_demos_inflicted) as 'Demos/ G'
    ,avg(avg_demos_taken) as 'Demos Taken/ G'
 from player_stats ps
group by Name, gamemode, playerLink
)

select *
from lifetime_stats
where GameMode like '${inputs.game_mode}'
and games_played >= ${inputs.games_played}
order by Name asc
```



<DataTable data={LeaderboardStats_career} rows=20 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white link=playerLink>
    <Column id=Name align=center />
    <Column id=GameMode align=center />
    <Column id=games_played align=center />
    <Column id='Sprocket Rating' align=center />
    <Column id='OPI' align=center />
    <Column id='DPI' align=center />
    <Column id='Avg Score' align=center />
    <Column id='Goals' align=center />
    <Column id='Assists' align=center />
    <Column id='Saves' align=center />
    <Column id='Shots' align=center />
    <Column id='shooting_pct2' align=center />
    <Column id='Demos' align=center />
    <Column id='Demos Taken' align=center />
    <Column id='Shots/ G' align=center />
    <Column id='Goals/ G' align=center />
    <Column id='Assists/ G' align=center />
    <Column id='Saves/ G' align=center />
    <Column id='Shots/ G' align=center />
    <Column id='Goals Against/ G' align=center />
    <Column id='Shots Against/ G' align=center />
    <Column id='Demos/ G' align=center />
    <Column id='Demos Taken/ G' align=center />
</DataTable>

</Tab>

<Tab label="Season Stats">

```sql SeasonStats_career
With lifetime_stats as (
    Select name as Name
    ,'players/' || ps.member_id as playerLink
    ,CASE WHEN ps.gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN ps.gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode
    ,season
    ,skill_group as 'League'
    ,team_name as Franchise
    ,sum(games_played) as games_played
    ,avg(sprocket_rating) as 'Sprocket Rating'
    ,avg(opi_per_game) as 'OPI'
    ,avg(dpi_per_game) as 'DPI'
    ,avg(avg_score) as 'Avg Score'
    ,sum(total_goals) as Goals
    ,sum(total_assists) as Assists
    ,sum(total_saves) as Saves
    ,sum(total_shots) as Shots
    ,sum(total_goals)/sum(total_shots) as shooting_pct2
    ,sum(total_demos_inflicted) as 'Demos'
    ,sum(total_demos_taken) as 'Demos Taken'
    ,avg(goals_per_game) as 'Goals/ G'
    ,avg(assists_per_game) as 'Assists/ G'
    ,avg(saves_per_game) as 'Saves/ G'
    ,avg(shots_per_game) as 'Shots/ G'
    ,avg(avg_goals_against) as 'Goals Against/ G'
    ,avg(avg_shots_against) as 'Shots Against/ G'
    ,avg(avg_demos_inflicted) as 'Demos/ G'
    ,avg(avg_demos_taken) as 'Demos Taken/ G'
 from player_stats ps
group by Name, gamemode, season, team_name, League, playerLink
)

select *
from lifetime_stats
where GameMode like '${inputs.game_mode}'
and games_played >= ${inputs.games_played}
and season in ${inputs.season.value}
and League in ${inputs.League.value}
order by Name, season
```


<Dropdown data={dropdown_and_button_group} name=season value=season multiple=true selectAllByDefault=true />

<Dropdown data={dropdown_and_button_group} name=League value=skill_group multiple=true selectAllByDefault=true />

<DataTable data={SeasonStats_career} rows=20 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white link=playerLink>
    <Column id=Name align=center />
    <Column id=GameMode align=center />
    <Column id='Franchise' align=center />
    <Column id='League' align=center />
    <Column id='season' align=center />
    <Column id='games_played' align=center />
    <Column id='Sprocket Rating' align=center />
    <Column id='OPI' align=center />
    <Column id='DPI' align=center />
    <Column id='Avg Score' align=center />
    <Column id='Goals' align=center />
    <Column id='Assists' align=center />
    <Column id='Saves' align=center />
    <Column id='Shots' align=center />
    <Column id='shooting_pct2' align=center />
    <Column id='Demos' align=center />
    <Column id='Demos Taken' align=center />
    <Column id='Goals/ G' align=center />
    <Column id='Assists/ G' align=center />
    <Column id='Saves/ G' align=center />
    <Column id='Shots/ G' align=center />
    <Column id='Goals Against/ G' align=center />
    <Column id='Shots Against/ G' align=center />
    <Column id='Demos/ G' align=center />
    <Column id='Demos Taken/ G' align=center />
</DataTable>

</Tab>

</Tabs>