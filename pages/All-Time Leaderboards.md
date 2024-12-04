---
title: All-Time Player Stats
---

<LastRefreshed prefix="Data last updated"/>

```sql Stats
With player_stats as (
    Select name as Name
    ,CASE WHEN ps.gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN ps.gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode
    ,games_played
    ,sprocket_rating
    ,opi_per_game
    ,dpi_per_game
    ,avg_score
    ,total_goals
    ,total_assists 
    ,total_saves
    ,total_shots
    ,total_goals_against 
    ,total_shots_against
    ,total_demos_inflicted
    ,total_demos_taken
 from player_stats ps
)
select *
from player_stats
order by Name
```

```sql LeaderboardStats
With player_stats as (
    Select name as Name
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
group by Name, gamemode
)

select *
from player_stats
where GameMode in ${inputs.GameMode.value}
and games_played >= ${inputs.games_played}
order by Name asc, games_played desc
```

<Dropdown data={Stats} name=GameMode value=GameMode multiple=true selectAllByDefault=true />

<Slider
    title='Games Played'
    name=games_played
    data={Stats}
    defaultValue=1
    min=1
    max=165
    size=large
/>

<DataTable data={LeaderboardStats} rows=20 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white wrapTitles=true >
    <Column id=Name align=center />
    <Column id=GameMode align=center />
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