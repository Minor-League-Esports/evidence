---
title: All-Time Player Stats
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