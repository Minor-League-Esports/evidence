---
title: Non-Rostered Players
sidebar_position: 2
---

<LastRefreshed prefix="Data last updated"/>


```sql PWDropdown
SELECT DISTINCT 
    name, 
    p.member_id, 
    franchise, 
    current_scrim_points, 
    p.skill_group AS skill_group, 
    salary, 
    CASE 
        WHEN current_scrim_points >= 30 THEN 'Yes' 
        ELSE 'No' 
    END AS Eligible 
FROM players p
WHERE franchise IN ('FA', 'Pend', 'Waivers', 'RFA');
```

<Dropdown data={PWDropdown} name=League value=skill_group multiple=true selectAllByDefault=true />

<Dropdown data={PWDropdown} name=Salary value=salary multiple=true selectAllByDefault=true />

<Dropdown data={PWDropdown} name=Eligible value=Eligible multiple=true selectAllByDefault=true />

<Dropdown data={PWDropdown} name=Status value=franchise multiple=true selectAllByDefault=true />


```sql PWChart
select
    franchise, 
    replace(skill_group, ' League', '') as shortened_skill_group,
    count(*) as data,
    case
      when skill_group = 'Foundation League' then 1
      when skill_group = 'Academy League' then 2
      when skill_group = 'Champion League' then 3
      when skill_group = 'Master League' then 4
      when skill_group = 'Premier League' then 5
    end as league_order,
FROM players p
WHERE franchise IN ${inputs.Status.value}
    AND skill_group in ${inputs.League.value}
    Group by skill_group, franchise, league_order
    order by league_order
   ```
<BarChart 
    data={PWChart}
    x=shortened_skill_group
    y=data
    showAllXAxisLabels=true
    series=franchise
    title="Total Per League"
    sort=false
/>

```sql PWTable
SELECT DISTINCT 
    name, 
    p.member_id,
    '/players/' || CAST(p.member_id AS INTEGER) as id_link, 
    franchise, 
    current_scrim_points, 
    replace(p.skill_group, 'League', '') as skill_group,
    salary, 
    CASE 
        WHEN current_scrim_points >= 30 THEN 'Yes' 
        ELSE 'No' 
    END AS Eligible,
    "Eligible Until"
FROM players p
WHERE franchise IN ${inputs.Status.value}
    AND p.skill_group in ${inputs.League.value}
    AND salary in ${inputs.Salary.value}
    AND Eligible in ${inputs.Eligible.value}
ORDER BY name ASC;
```

<DataTable data={PWTable} rows=20 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white link=id_link> 
    <Column id=name align=center/> 
    <Column id=skill_group fmt=varhcar title=League align=center/> 
    <Column id=franchise title="Status" fmt=varchar align=center/> 
    <Column id=salary fmt=int align=center/> 
    <Column id="Eligible Until" fmt=varchar align=center/> 
</DataTable>
