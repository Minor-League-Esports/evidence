---
title: S19 Playoff Results
---

<LastRefreshed prefix="Data last updated"/>

```sql playoffs
select
m.home, 
m.away,
concat(home_wins::INT, ' - ', away_wins::INT) as series_record,
case
  when winning_team = 'Not Played / Data Unavailable' then 'Results Pending'
  else winning_team
  end as series_winner,
match_group_title as round
from matches m
  inner join match_groups mg
    on m.match_group_id = mg.match_group_id
where parent_group_title = 'Season 19 Playoffs'
and league = '${inputs.leaguesButtons}'
and game_mode = '${inputs.gamemode}'

```

```sql leagues
select 
league,
game_mode
from matches m
```

<ButtonGroup name=leaguesButtons display=tabs>
    <ButtonGroupItem valueLabel="Foundation League" value="Foundation League" default />
    <ButtonGroupItem valueLabel="Academy League" value="Academy League" />
    <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
    <ButtonGroupItem valueLabel="Master League" value="Master League" />
    <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
</ButtonGroup>


<ButtonGroup name=gamemode display=tabs>
    <ButtonGroupItem valueLabel="Doubles" value="Doubles" default />
    <ButtonGroupItem valueLabel="Standard" value="Standard" />
</ButtonGroup>


<DataTable data={playoffs} textAlign=center groupBy=round rowShading=true headerColor=#2a4b82 headerFontColor=white groupType=section/>
