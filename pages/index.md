---
title: MLE Homepage
---

<LastRefreshed/>

### About Evidence:

Welcome to evidence where MLE's data lives. This website is living documentation on all things MLE. Here you can navigate the panel on the left hand side to find stats, standings or even trackers. We hope you enjoy your time here and if there is anything you would like to see add to evidence please follow the link below and let us know.

```sql player_page
  with players as (
  SELECT
  name,
  salary,
  p.member_id,
  '/player_page/' || p.member_id as id_link,
  franchise
     from read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/players.parquet') p
    inner join read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/player_stats_s17.parquet') ps
        on p.member_id = ps.member_id
  group by name, salary, p.member_id, franchise
  )
  select *
  from players
```

<Details title="Player Pages">

<p>In the table below you can find any player in MLE and click on their row to be directed to their personal player page.</p>

</Details>

<DataTable data={player_page} link=id_link search=true />

## Have ideas or need help?

- Message us on [Discord](https://discord.com/channels/172404472637685760/470327770443022346)
