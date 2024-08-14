---
title: Non-Rostered Players
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
INNER JOIN S17_stats st
    ON p.member_id = st.member_id
WHERE franchise IN ('FA', 'Pend', 'Waivers', 'RFA');
```

<Dropdown data={PWDropdown} name=League value=skill_group multiple=true selectAllByDefault=true />

<Dropdown data={PWDropdown} name=Salary value=salary multiple=true selectAllByDefault=true />

<Dropdown data={PWDropdown} name=Eligible value=Eligible multiple=true selectAllByDefault=true />

<Dropdown data={PWDropdown} name=Status value=franchise multiple=true selectAllByDefault=true />

```sql PWTable
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
INNER JOIN S17_stats st
    ON p.member_id = st.member_id
WHERE franchise IN ${inputs.Status.value}
    AND p.skill_group in ${inputs.League.value}
    AND salary in ${inputs.Salary.value}
    AND Eligible in ${inputs.Eligible.value}
ORDER BY name ASC;
```

<DataTable data={PWTable} rows=20 search=true rowShading=true headerColor=#2a4b82 headerFontColor=white> 
    <Column id=name align=center/> 
    <Column id=skill_group fmt=varhcar title=League align=center/> 
    <Column id=franchise title="Status" fmt=varchar align=center/> 
    <Column id=salary fmt=int align=center/> 
    <Column id=Eligible fmt=varchar align=center/> 
</DataTable>