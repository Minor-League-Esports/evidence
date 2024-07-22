---
title: MLE Homepage
---

<LastRefreshed/>

### About Evidence:

Welcome to evidence where MLE's data lives. This website is living documentation on all things MLE. Here you can navigate the panel on the left hand side to find stats, standings or even trackers. We hope you enjoy your time here and if there is anything you would like to see add to evidence please follow the link below and let us know.

```sql player_page
  with player as (
  SELECT
  name,
  salary,
  '/player_page/' || p.member_id as id_link,
  franchise
    from players p
    left join S17_stats s17
        on p.member_id = s17.member_id
  group by name, salary, p.member_id, franchise
  )
  select *
  from player
```

<Details title="Player Pages">

<p>In the table below you can find any player in MLE and click on their row to be directed to their personal player page.</p>

</Details>

<DataTable data={player_page} link=id_link search=true rows=5 />

```sql leagueStats
With leaguestats as (
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
order by league_order)
select *
from leaguestats
```

```sql leagueComparison
select 
league,
game_mode,
${inputs.Stats.value} as value
from ${leagueStats}
```

## League Averages

<Details title="Sort By Stat">
<p>Below you can use the dropdown menu to compare the averages of each league for each game mode. </p>
</Details>

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

<BarChart data={leagueComparison}
x=league
y=value
series=game_mode
type=grouped 
colorPalette={['#0c88fc', '#fd7600']}
sort=false
/>

## Have ideas or need help?

- Message us on [Discord](https://discord.com/channels/172404472637685760/470327770443022346)
