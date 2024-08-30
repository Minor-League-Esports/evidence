---
title: Player Trackers
---

<LastRefreshed prefix="Data last updated"/>

```sql trackers
select
name,
tracker,
platform,
platform_id as gamertag
from trackers t
where name = '${inputs.Dropdown.value}'
order by name
```

```sql dropdown
select name from trackers
```

<Dropdown data={dropdown} name=Dropdown value=name />

<DataTable data={trackers} rows=20 rowShading=true headerColor=#2a4b82 headerFontColor=white>
    <Column id=name />
    <Column id=tracker contentType=link linkLabel=platform openInNewTab=true />
    <Column id=gamertag />
</DataTable>
