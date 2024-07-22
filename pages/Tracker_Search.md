---
title: Player Trackers
---

<LastRefreshed prefix="Data last updated"/>

```sql dropdown
with tracker_search as (
    SELECT * FROM trackers
)
select
name,
tracker,
platform,
platform_id as gamertag
from tracker_search
```

```sql trackers
with tracker_search as (
    SELECT * FROM trackers
)
select
name,
tracker,
platform,
platform_id as gamertag
from tracker_search
where name like '${inputs.Name.value}'
order by name
```

<Dropdown data={dropdown} name=Name value=name>
    <DropdownOption value="%" valueLabel="All Players"/>
</Dropdown>

<DataTable data={trackers} rows=20 rowShading=true>
    <Column id=name />
    <Column id=tracker contentType=link linkLabel=platform openInNewTab=true />
    <Column id=gamertag />
</DataTable>
