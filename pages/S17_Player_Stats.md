---
title: S17 Player Stats
---

<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions'>

<p>Below you will find all stats for all players in MLE for S17.</p>
<p>-You can use the search bar above the table to search for a specific player.</p>
<p>-You can also use the drop down menus below to Filter the stats however you see fit.</p>
<p>-Lastly you can click on the stat column to put stats in ascending or descending order.</p>
</Details>

```sql Stats
With playerstats as (
    Select name as Name,
    salary::text as Salary,
    team_name as Team,
    ps.skill_group as League,
    gamemode as GameMode
 from read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/players.parquet') p
    inner join read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/player_stats_s17.parquet') ps
        on p.member_id = ps.member_id
group by name, salary, team_name, League, gamemode)
select *
from playerstats
```

```sql LeaderboardStats
With playerstats as (
    Select name as Name,
    salary as Salary,
    team_name as Team,
    ps.skill_group as League,
    gamemode as GameMode,
    avg(dpi) as Avg_DPI,
    avg(gpi) as Avg_GPI,
    avg(opi) as Avg_OPI,
    avg(score) as Score_Per_Game,
    avg(goals) as Goals_Per_Game,
    avg(assists) as Assists_Per_Game,
    avg(saves) as Saves_Per_Game,
    avg(shots) as Shots_Per_Game
 from read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/players.parquet') p
    inner join read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/player_stats_s17.parquet') ps
        on p.member_id = ps.member_id
group by name, salary, team_name, League, gamemode)
select
Name,
Salary,
Team,
League,
gamemode,
Avg_DPI,
Avg_GPI,
Avg_OPI,
Score_Per_Game,
Goals_Per_Game,
Assists_Per_Game,
Saves_Per_Game,
Shots_Per_Game
from playerstats
where Salary like '${inputs.Salary.value}'
and Team like '${inputs.Team.value}'
and League like '${inputs.League.value}'
and GameMode like '${inputs.GameMode.value}'
order by Score_Per_Game desc
```

<Dropdown data={Stats} name=Salary value=Salary>
    <DropdownOption value="%" valueLabel="Filter By Salary"/>
</Dropdown>

<Dropdown data={Stats} name=Team value=Team>
    <DropdownOption value="%" valueLabel="Filter By Team"/>
</Dropdown>

<Dropdown data={Stats} name=League value=League>
    <DropdownOption value="%" valueLabel="Filter By League"/>
</Dropdown>

<Dropdown data={Stats} name=GameMode value=GameMode>
    <DropdownOption value="%" valueLabel="Filter By GameMode"/>
</Dropdown>

<DataTable data={LeaderboardStats} rows=20 search=true rowShading=true headerColor=#7FFFD4 backgroundColor=#A9A9A9 />