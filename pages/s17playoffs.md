---
title: S17 Playoff Results
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
where parent_group_title = 'Season 17 Playoffs'
and league = '${inputs.leagues.value}'
and game_mode = '${inputs.gamemode.value}'

```

```sql leagues
select 
league,
game_mode
from matches m
```

<Dropdown data={leagues} name=leagues value=league />

<Dropdown data={leagues} name=gamemode value=game_mode />

<DataTable data={playoffs} groupBy=round />