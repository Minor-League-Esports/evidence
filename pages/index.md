---
title: MLE Homepage
---

<LastRefreshed/>


Evidence is your gateway into MLE's statistics, here you will find pages for
many areas of current, and historical stats (performance, standings, etc).
If you don't see something here, or are unsure of how to use this tool, reach out
to the team on [Discord](https://discord.com/channels/172404472637685760/470327770443022346)

```sql player_page
SELECT
  name,
  salary,
  '/player_page/' || p.member_id as id_link,
  franchise
  from players p
  left join S17_stats s17
      on p.member_id = s17.member_id
group by name, salary, p.member_id, franchise
LIMIT 5
```

### Player Summaries

<DataTable data={player_page} search=true rows=5>
  <Column id="name"/>
  <Column id="salary"/>
  <Column id="franchise"/>
  <Column id="id_link" contentType=link linkLabel="Player Details" title="-"/>
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
    avg(dpi) as avg_dpi,
    avg(gpi) as avg_gpi,
    avg(opi) as avg_opi,
    avg(score) as score_per_game,
    avg(goals) as goals_per_game,
    avg(assists) as assists_per_game,
    avg(saves) as saves_per_game,
    avg(shots) as shots_per_game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) as shooting_pct2
 from players p
    inner join s17_stats s17
        on p.member_id = s17.member_id
group by League, game_mode
order by league_order
```

## League Averages

<Dropdown name=Stats defaultValue=score_per_game>
    <DropdownOption value=avg_dpi valueLabel=DPI />
    <DropdownOption value=avg_gpi valueLabel=GPI />
    <DropdownOption value=avg_opi valueLabel=OPI />
    <DropdownOption value=score_per_game valueLabel=Score />
    <DropdownOption value=goals_per_game valueLabel=Goals />
    <DropdownOption value=assists_per_game valueLabel=Assists />
    <DropdownOption value=saves_per_game valueLabel=Saves />
    <DropdownOption value=shots_per_game valueLabel=Shots />
    <DropdownOption value=goals_against_per_game valueLabel="Goals Against" />
    <DropdownOption value=shots_against_per_game valueLabel="Shots Against"/>
    <DropdownOption value=shooting_pct2 valueLabel="Shooting Percentage" />
</Dropdown>

> Comparitive stats between leagues

<BarChart data={leagueStats}
  x=league
  y='{inputs.Stats.value}'
  series=game_mode
  type=grouped 
  colorPalette={['#0c88fc', '#fd7600']}
  sort=false
/>


