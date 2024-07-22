---
title: S17 Player Stats
---

<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions'>

Below you will find all stats for all players in MLE for S17.
- You can use the search bar above the table to search for a specific player.
- You can also use the drop down menus below to Filter the stats however you see fit.
- Lastly you can click on the stat column to put stats in ascending or descending order.


</Details>

```sql Stats
With playerstats as (
    Select name as Name,
    salary::text as Salary,
    team_name as Team,
    s17.skill_group as League,
    CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode
 from players p
    inner join S17_stats s17
        on p.member_id = s17.member_id
group by name, salary, team_name, League, gamemode)
select *
from playerstats
```

```sql LeaderboardStats
With playerstats as (
    Select name as Name,
    salary as Salary,
    team_name as Team,
    s17.skill_group as League,
    CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode,
    avg(dpi) as Avg_DPI,
    avg(gpi) as Avg_GPI,
    avg(opi) as Avg_OPI,
    avg(score) as Score_Per_Game,
    avg(goals) as Goals_Per_Game,
    avg(assists) as Assists_Per_Game,
    avg(saves) as Saves_Per_Game,
    avg(shots) as Shots_Per_Game
 from players p
    inner join S17_stats s17
        on p.member_id = s17.member_id
group by name, salary, team_name, League, gamemode)

select *
from playerstats
where Salary like '${inputs.Salary.value}'
and Team like '${inputs.Team.value}'
and League like '${inputs.League.value}'
and GameMode like '${inputs.GameMode.value}'
order by Score_Per_Game desc
```

<Dropdown data={Stats} name=Salary value=Salary>
    <DropdownOption value="%" valueLabel="All Salaries"/>
</Dropdown>

<Dropdown data={Stats} name=Team value=Team>
    <DropdownOption value="%" valueLabel="All Teams"/>
</Dropdown>

<Dropdown data={Stats} name=League value=League>
    <DropdownOption value="%" valueLabel="All Leagues"/>
</Dropdown>

<Dropdown data={Stats} name=GameMode value=GameMode>
    <DropdownOption value="%" valueLabel="All Game Modes"/>
</Dropdown>

<DataTable data={LeaderboardStats} rows=20 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white />
