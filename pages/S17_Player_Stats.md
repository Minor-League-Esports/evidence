---
title: S17 Player Stats
---

<Tabs>
<Tab label="Player Stats">

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
    count(score) as games_played,
    avg(dpi) as Avg_DPI,
    avg(gpi) as Avg_GPI,
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
    inner join S17_stats s17
        on p.member_id = s17.member_id
group by name, salary, team_name, League, gamemode)

select *
from playerstats
where Salary in ${inputs.Salary.value}
and Team in ${inputs.Team.value}
and League in ${inputs.League.value}
and GameMode in ${inputs.GameMode.value}
order by Score_Per_Game desc
```

<Dropdown data={Stats} name=Salary value=Salary multiple=true selectAllByDefault=true />

<Dropdown data={Stats} name=Team value=Team multiple=true selectAllByDefault=true />


<Dropdown data={Stats} name=League value=League multiple=true selectAllByDefault=true />


<Dropdown data={Stats} name=GameMode value=GameMode multiple=true selectAllByDefault=true />


<DataTable data={LeaderboardStats} rows=20 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white />

</Tab>

<Tab label="Player Comparison">

```sql Stats
With playerstats as (
    Select name,
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

```sql comparisonStats
With playerstats as (
    Select name,
    salary as Salary,
    team_name as Team,
    s17.skill_group as League,
    CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode,
    count(score) as games_played,
    avg(dpi) as Avg_DPI,
    avg(gpi) as Avg_GPI,
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
    inner join S17_stats s17
        on p.member_id = s17.member_id
group by name, salary, team_name, League, gamemode)

select 
name,
GameMode,
${inputs.stats.value} as stat1
from playerstats
where name in ${inputs.Player.value}
```



<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions'>

Below you can use the dropdown menus to select multiple players to compare stats against each other. <b>Please note that nothing will appear until you select the players you would like to compare.</b>


</Details>

<Dropdown data={Stats} name=Player value=name multiple=true />

<Dropdown name=stats defaultValue=score_per_game>
    <DropdownOption value=avg_dpi valueLabel=DPI />
    <DropdownOption value=avg_gpi valueLabel=GPI />
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
</Tabs>