---
title: Franchise Pages
---

<LastRefreshed prefix="Data last updated"/>

```sql joined_franchises
WITH doubles AS ( 
  SELECT name,
  SUM(team_wins)::INT AS Doubles_Wins,
  SUM(team_losses)::INT AS Doubles_Losses,
  FROM s18_standings
  WHERE mode LIKE 'Doubles' AND NOT (league IS NULL OR conference IS NULL OR division_name IS NULL)
  GROUP BY name 
),
standard AS (
  SELECT name,
  SUM(team_wins)::INT AS Standard_Wins,
  SUM(team_losses)::INT AS Standard_Losses,
  FROM s18_standings
  WHERE mode LIKE 'Standard' AND NOT (league IS NULL OR conference IS NULL OR division_name IS NULL)
  GROUP BY name  
),
overall AS (
  SELECT name,
  SUM(team_wins)::INT AS Overall_Wins,
  SUM(team_losses)::INT as Overall_Losses,
  FROM s18_Standings
  WHERE NOT (mode IS NULL OR league IS NULL OR conference IS NULL OR division_name IS NULL)
  GROUP BY name 
)
SELECT
  t.Franchise,
  'franchise_page/' || t.Franchise AS Franchise_Link,
  -- t."Photo URL" AS logo,
  o.Overall_Wins::INT || ' - ' || o.Overall_Losses::INT AS Overall_Record,
  d.Doubles_Wins::INT || ' - ' || d.Doubles_Losses::INT AS Doubles_Record,
  s.Standard_Wins::INT || ' - ' || s.Standard_Losses::INT AS Standard_Record,
FROM teams t
LEFT JOIN standard s
  ON s.name = t.Franchise
LEFT JOIN doubles d 
  ON d.name = t.Franchise
LEFT JOIN overall o
  ON o.name = t.Franchise
ORDER BY t.Franchise
```

<DataTable data={joined_franchises} search=true rows=32 headerColor=#2a4b82 headerFontColor=white link=Franchise_Link>
  <Column id="Franchise" align=center/>
  <!-- <Column id="logo" contentType=image height=40px align=center /> -->
  <Column id="Overall_Record" align=center />
  <Column id="Standard_Record" align=center />
  <Column id="Doubles_Record" align=center />
</DataTable>
