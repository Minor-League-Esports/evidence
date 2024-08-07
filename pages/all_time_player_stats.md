---
title: All-Time Player Stats
---

<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions'>

Below you will find stats for all players in MLE history.
- You can use the search bar above the table to search for a specific player.
- You can also use the drop down menu below to Filter the stats however you see fit.
- Lastly you can click on the stat column to put stats in ascending or descending order.

</Details>

```sql Stats
With playerstats as (
    Select name as Name,
    CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode
 from players p
    inner join S17_stats s17
        on p.member_id = s17.member_id
group by name, gamemode)
select *
from playerstats
```

```sql LeaderboardStats
With playerstats as (
    Select name as Name,
    CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode,
    count(*) as games_played,
    avg(opi) as Avg_OPI,
    avg(dpi) as Avg_DPI,
    avg(gpi) as Avg_GPI,
    avg(score) as Score_Per_Game,
    sum(goals) as total_goals,
    sum(assists) as total_assists,
    sum(saves) as total_saves,
    sum(shots) as total_shots,
    avg(goals) as Goals_Per_Game,
    avg(assists) as Assists_Per_Game,
    avg(saves) as Saves_Per_Game,
    avg(shots) as Shots_Per_Game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) as shooting_pct2
 from players p
    inner join S17_stats s17
        on p.member_id = s17.member_id
group by name, gamemode)
select *
from playerstats
where GameMode in ${inputs.GameMode.value}
order by Score_Per_Game desc
```



<Dropdown data={Stats} name=GameMode value=GameMode multiple=true selectAllByDefault=true />

<DataTable data={LeaderboardStats} rows=21 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white />



