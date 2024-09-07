---
title: Franchise Pages
---

<LastRefreshed prefix="Data last updated"/>

```sql franchises
select 
  Franchise,
  '/franchise_page/' || t.Franchise as franchise_link,
  t."Photo URL" as logo,
  SUM(team_wins)::int || ' - ' || SUM(team_losses)::int as Record,
from teams t
  inner join s17_standings s17
    on t.Franchise=s17.name
where not (s17.mode is null or s17.league is null or s17.conference is null or s17.division_name is null)
group by t.Franchise, t."Photo URL"
order by t.Franchise asc
```

<DataTable data={franchises} search=true rows=32 headerColor=#2a4b82 headerFontColor=white >
  <Column id="Franchise" align=center/>
  <Column id="logo" contentType=image height=40px align=center />
  <Column id="Record" align=center />
  <Column id="franchise_link" contentType=link linkLabel="Franchise Page" title="Franchise Link" align=center />

</DataTable>