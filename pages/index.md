---
title: MLE Homepage
---

<LastRefreshed prefix="Data last updated"/>


Evidence is your gateway into MLE's statistics. Here you will find pages for
many areas of current, and historical stats (performance, standings, etc).
If you don't see something here, or are unsure of how to use this tool, reach out
to the team on [Discord](https://discord.com/channels/172404472637685760/323511951357509642)

```sql player_page
SELECT
  NAME,
  salary,
  '/player_page/' || p.member_id as id_link,
  franchise
  from players p
  left join S17_stats s17
      on p.member_id = s17.member_id
group by name, salary, p.member_id, franchise
LIMIT 4500
```

## Player Summaries

<DataTable data={player_page} search=true rows=5 headerColor=#2a4b82 headerFontColor=white>
  <Column id="name"/>
  <Column id="salary"/>
  <Column id="franchise"/>
  <Column id="id_link" contentType=link linkLabel="Player Page" title="Link to Player Page"/>
</DataTable>

```sql leagueStats
select
    case
      when s17.skill_group = 'Foundation League' then 1
      when s17.skill_group = 'Academy League' then 2
      when s17.skill_group = 'Champion League' then 3
      when s17.skill_group = 'Master League' then 4
      when s17.skill_group = 'Premier League' then 5
    end as league_order,
    s17.skill_group as league,
    case
      when gamemode = 'RL_DOUBLES' then 'Doubles'
      when gamemode = 'RL_STANDARD' then 'Standard'
      else gamemode
    end as game_mode,
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
    sum(goals)/sum(shots) * 100 as shooting_pct2
 from players p
    inner join s17_stats s17
        on p.member_id = s17.member_id
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

## League Statistics

<Dropdown name=Stats defaultValue=score_per_game>
    <DropdownOption value=avg_dpi valueLabel="Avg DPI" />
    <DropdownOption value=avg_gpi valueLabel="Avg Sprocket Rating" />
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
